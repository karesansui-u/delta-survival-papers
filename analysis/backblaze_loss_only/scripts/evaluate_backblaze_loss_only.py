#!/usr/bin/env python3
"""Frozen evaluation script for the Backblaze loss-only G4 anchor.

This script is intended to be hashed in the freeze manifest before any primary
run. It implements the preregistered loss-only observational analysis only.
It does not contain repair-flow logic.
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import math
import zipfile
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import Any, Iterable

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import brier_score_loss, log_loss, roc_auc_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


SMART_FIELDS = [
    "smart_5_raw",
    "smart_187_raw",
    "smart_188_raw",
    "smart_197_raw",
    "smart_198_raw",
    "smart_199_raw",
]

METADATA_B1 = ["model", "capacity_bytes", "is_legacy_format"]
METADATA_B2 = [
    "model",
    "capacity_bytes",
    "datacenter",
    "cluster_id",
    "vault_id",
    "pod_id",
    "pod_slot_num",
    "is_legacy_format",
]
METADATA_B3 = ["model", "capacity_bytes", "drive_age_days"]

PRIMARY_HORIZON_DAYS = 30
MIN_FINAL_TEST_FAILURE_EVENTS = 200
LOGISTIC_C = 1.0
RANDOM_SEED = 43001


@dataclass(frozen=True)
class SplitDates:
    train: list[str]
    validation: list[str]
    test: list[str]


@dataclass(frozen=True)
class Dataset:
    rows: list[dict[str, Any]]
    labels: list[int]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, help="Backblaze quarterly zip archive.")
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--max-rows",
        type=int,
        default=None,
        help="Debug-only row limit. Must be omitted for the frozen primary run.",
    )
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="Only emit archive metadata and split information; do not fit models.",
    )
    parser.add_argument(
        "--allow-primary-run",
        action="store_true",
        help=(
            "Enable model fitting. This flag is a structural guard: use it for synthetic "
            "smoke tests or after the freeze manifest has recorded this script hash."
        ),
    )
    return parser.parse_args()


def list_csv_files(archive: zipfile.ZipFile) -> list[str]:
    return sorted(info.filename for info in archive.infolist() if info.filename.endswith(".csv"))


def read_header(archive: zipfile.ZipFile, csv_name: str) -> list[str]:
    with archive.open(csv_name) as handle:
        text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
        return next(csv.reader(text))


def date_range_from_names(csv_names: Iterable[str]) -> list[str]:
    dates = []
    for name in csv_names:
        stem = Path(name).stem
        date.fromisoformat(stem)
        dates.append(stem)
    return sorted(dates)


def eligible_prediction_dates(all_dates: list[str], horizon_days: int) -> list[str]:
    max_date = date.fromisoformat(all_dates[-1])
    eligible = []
    for value in all_dates:
        current = date.fromisoformat(value)
        if current + timedelta(days=horizon_days) <= max_date:
            eligible.append(value)
    return eligible


def split_dates(eligible_dates: list[str]) -> SplitDates:
    n = len(eligible_dates)
    train_end = int(n * 0.70)
    validation_end = int(n * 0.85)
    return SplitDates(
        train=eligible_dates[:train_end],
        validation=eligible_dates[train_end:validation_end],
        test=eligible_dates[validation_end:],
    )


def required_columns_present(header: list[str]) -> dict[str, bool]:
    required = ["date", "serial_number", "model", "capacity_bytes", "failure"]
    metadata = sorted(set(METADATA_B2 + ["drive_age_days"]))
    fields = sorted(set(required + SMART_FIELDS + metadata) - {"drive_age_days"})
    return {field: field in header for field in fields}


def count_raw_failures_by_date(archive: zipfile.ZipFile, csv_names: list[str]) -> dict[str, int]:
    failures_by_date: dict[str, int] = defaultdict(int)
    for name in csv_names:
        with archive.open(name) as handle:
            text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
            reader = csv.DictReader(text)
            for row in reader:
                if row.get("failure") == "1":
                    failures_by_date[row["date"]] += 1
    return dict(failures_by_date)


def endpoint_dates_for_test(test_dates: list[str], horizon_days: int) -> list[str]:
    start = date.fromisoformat(test_dates[0]) + timedelta(days=1)
    end = date.fromisoformat(test_dates[-1]) + timedelta(days=horizon_days)
    return [(start + timedelta(days=i)).isoformat() for i in range((end - start).days + 1)]


def log1p_or_zero(value: str) -> float:
    if value == "" or value is None:
        return 0.0
    try:
        parsed = float(value)
    except ValueError:
        return 0.0
    if parsed < 0:
        return 0.0
    return math.log1p(parsed)


def failure_lookup(archive: zipfile.ZipFile, csv_names: list[str]) -> set[tuple[str, str]]:
    failures: set[tuple[str, str]] = set()
    for name in csv_names:
        with archive.open(name) as handle:
            text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
            reader = csv.DictReader(text)
            for row in reader:
                if row.get("failure") == "1":
                    failures.add((row["serial_number"], row["date"]))
    return failures


def future_failure_label(serial_number: str, current_date: str, failures: set[tuple[str, str]]) -> int:
    start = date.fromisoformat(current_date) + timedelta(days=1)
    for offset in range(PRIMARY_HORIZON_DAYS):
        check_date = (start + timedelta(days=offset)).isoformat()
        if (serial_number, check_date) in failures:
            return 1
    return 0


def as_float(value: str) -> float:
    if value == "" or value is None:
        return 0.0
    try:
        return float(value)
    except ValueError:
        return 0.0


def build_feature_row(row: dict[str, str], first_seen: dict[str, str], include_smart: bool) -> dict[str, Any]:
    serial = row["serial_number"]
    current = date.fromisoformat(row["date"])
    first = date.fromisoformat(first_seen[serial])
    result: dict[str, Any] = {
        "model": row.get("model", ""),
        "capacity_bytes": as_float(row.get("capacity_bytes", "")),
        "is_legacy_format": row.get("is_legacy_format", ""),
        "datacenter": row.get("datacenter", ""),
        "cluster_id": row.get("cluster_id", ""),
        "vault_id": row.get("vault_id", ""),
        "pod_id": row.get("pod_id", ""),
        "pod_slot_num": row.get("pod_slot_num", ""),
        "drive_age_days": float((current - first).days),
    }
    if include_smart:
        for field in SMART_FIELDS:
            result[field] = log1p_or_zero(row.get(field, ""))
    return result


def build_dataset(
    archive: zipfile.ZipFile,
    csv_names: list[str],
    dates: list[str],
    failures: set[tuple[str, str]],
    include_smart: bool,
    max_rows: int | None,
) -> Dataset:
    wanted_dates = set(dates)
    first_seen: dict[str, str] = {}
    rows: list[dict[str, Any]] = []
    labels: list[int] = []

    for name in csv_names:
        with archive.open(name) as handle:
            text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
            reader = csv.DictReader(text)
            for row in reader:
                serial = row["serial_number"]
                first_seen.setdefault(serial, row["date"])
                if row["date"] not in wanted_dates:
                    continue
                rows.append(build_feature_row(row, first_seen, include_smart=include_smart))
                labels.append(future_failure_label(serial, row["date"], failures))
                if max_rows is not None and len(rows) >= max_rows:
                    return Dataset(rows=rows, labels=labels)
    return Dataset(rows=rows, labels=labels)


def feature_columns(rows: list[dict[str, Any]], requested: list[str]) -> list[str]:
    if not rows:
        return []
    present = rows[0].keys()
    return [column for column in requested if column in present]


def fit_and_score(
    train: Dataset,
    test: Dataset,
    feature_names: list[str],
    categorical: list[str],
) -> dict[str, Any]:
    numeric = [name for name in feature_names if name not in categorical]
    categorical = [name for name in categorical if name in feature_names]

    transformer = ColumnTransformer(
        transformers=[
            ("numeric", StandardScaler(), numeric),
            (
                "categorical",
                OneHotEncoder(handle_unknown="ignore", sparse_output=False),
                categorical,
            ),
        ],
        remainder="drop",
    )
    model = LogisticRegression(
        C=LOGISTIC_C,
        solver="lbfgs",
        max_iter=1000,
        class_weight="balanced",
        random_state=RANDOM_SEED,
    )
    pipeline = Pipeline([("preprocess", transformer), ("model", model)])
    x_train = pd.DataFrame([{k: row.get(k) for k in feature_names} for row in train.rows])
    x_test = pd.DataFrame([{k: row.get(k) for k in feature_names} for row in test.rows])
    y_train = np.array(train.labels)
    y_test = np.array(test.labels)
    pipeline.fit(x_train, y_train)
    proba = pipeline.predict_proba(x_test)[:, 1]
    result: dict[str, Any] = {
        "n_train": int(len(y_train)),
        "n_test": int(len(y_test)),
        "train_positive": int(y_train.sum()),
        "test_positive": int(y_test.sum()),
        "log_loss": float(log_loss(y_test, proba, labels=[0, 1])),
        "brier": float(brier_score_loss(y_test, proba)),
    }
    if len(set(y_test.tolist())) == 2:
        result["auc"] = float(roc_auc_score(y_test, proba))
    else:
        result["auc"] = None
    return result


def sign_diagnostics(pipeline: Pipeline, feature_names: list[str]) -> dict[str, Any]:
    preprocess = pipeline.named_steps["preprocess"]
    model = pipeline.named_steps["model"]
    names = preprocess.get_feature_names_out()
    coefficients = model.coef_[0]
    by_name = {name: float(value) for name, value in zip(names, coefficients, strict=True)}
    smart_signs = {}
    for field in SMART_FIELDS:
        key = f"numeric__{field}"
        if key in by_name:
            value = by_name[key]
            smart_signs[field] = {
                "coefficient": value,
                "non_violating": value >= 0.0,
                "theory_supporting": value > 0.0,
            }
    return {"smart_signs": smart_signs, "feature_count": len(feature_names)}


def main() -> None:
    args = parse_args()
    archive_path = Path(args.archive)
    output_path = Path(args.output)

    with zipfile.ZipFile(archive_path) as archive:
        csv_names = list_csv_files(archive)
        if not csv_names:
            raise SystemExit("No CSV files found in archive.")

        header = read_header(archive, csv_names[0])
        all_dates = date_range_from_names(csv_names)
        eligible = eligible_prediction_dates(all_dates, PRIMARY_HORIZON_DAYS)
        splits = split_dates(eligible)
        failures_by_date = count_raw_failures_by_date(archive, csv_names)
        endpoint_dates = endpoint_dates_for_test(splits.test, PRIMARY_HORIZON_DAYS)
        endpoint_failures = sum(failures_by_date.get(d, 0) for d in endpoint_dates)
        failures = failure_lookup(archive, csv_names)

    metadata = {
        "archive": str(archive_path),
        "n_csv_files": len(csv_names),
        "date_range": [all_dates[0], all_dates[-1]],
        "eligible_prediction_date_range": [eligible[0], eligible[-1]],
        "split_dates": {
            "train": [splits.train[0], splits.train[-1], len(splits.train)],
            "validation": [splits.validation[0], splits.validation[-1], len(splits.validation)],
            "test": [splits.test[0], splits.test[-1], len(splits.test)],
        },
        "horizon_days": PRIMARY_HORIZON_DAYS,
        "min_final_test_failure_events": MIN_FINAL_TEST_FAILURE_EVENTS,
        "raw_failures_in_test_endpoint_horizon": endpoint_failures,
        "columns_present": required_columns_present(header),
        "model_class": "L2-regularized logistic regression",
        "regularization_C": LOGISTIC_C,
        "random_seed": RANDOM_SEED,
        "metadata_only": args.metadata_only,
        "allow_primary_run": args.allow_primary_run,
        "max_rows": args.max_rows,
    }

    if args.metadata_only:
        output_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n")
        return
    if not args.allow_primary_run:
        raise SystemExit(
            "Model fitting requires --allow-primary-run. Use this only for synthetic smoke "
            "tests or after the freeze manifest has recorded the final script hash."
        )

    train_dates = splits.train + splits.validation
    test_dates = splits.test
    with zipfile.ZipFile(archive_path) as archive:
        train_smart = build_dataset(
            archive, csv_names, train_dates, failures, include_smart=True, max_rows=args.max_rows
        )
        test_smart = build_dataset(
            archive, csv_names, test_dates, failures, include_smart=True, max_rows=args.max_rows
        )
        train_meta = Dataset(
            rows=[{k: v for k, v in row.items() if k not in SMART_FIELDS} for row in train_smart.rows],
            labels=train_smart.labels,
        )
        test_meta = Dataset(
            rows=[{k: v for k, v in row.items() if k not in SMART_FIELDS} for row in test_smart.rows],
            labels=test_smart.labels,
        )

    categorical_base = [
        "model",
        "is_legacy_format",
        "datacenter",
        "cluster_id",
        "vault_id",
        "pod_id",
        "pod_slot_num",
    ]
    models = {
        "B0_intercept": [],
        "B1_metadata": METADATA_B1,
        "B2_fleet_context": METADATA_B2,
        "B3_exposure": METADATA_B3,
        "primary_metadata_plus_smart": METADATA_B2 + SMART_FIELDS,
    }
    scores: dict[str, Any] = {}
    for name, requested in models.items():
        if name == "B0_intercept":
            for dataset in (train_meta, test_meta):
                for row in dataset.rows:
                    row["intercept_only"] = 1.0
            requested = ["intercept_only"]
        source_train = train_smart if name == "primary_metadata_plus_smart" else train_meta
        source_test = test_smart if name == "primary_metadata_plus_smart" else test_meta
        features = feature_columns(source_train.rows, requested)
        categorical = [value for value in categorical_base if value in features]
        score = fit_and_score(source_train, source_test, features, categorical)
        scores[name] = score

    # Refit primary once for sign diagnostics.
    primary_features = feature_columns(train_smart.rows, METADATA_B2 + SMART_FIELDS)
    primary_categorical = [value for value in categorical_base if value in primary_features]
    transformer = ColumnTransformer(
        transformers=[
            (
                "numeric",
                StandardScaler(),
                [name for name in primary_features if name not in primary_categorical],
            ),
            (
                "categorical",
                OneHotEncoder(handle_unknown="ignore", sparse_output=False),
                primary_categorical,
            ),
        ],
        remainder="drop",
    )
    primary_pipeline = Pipeline(
        [
            ("preprocess", transformer),
            (
                "model",
                LogisticRegression(
                    C=LOGISTIC_C,
                    solver="lbfgs",
                    max_iter=1000,
                    class_weight="balanced",
                    random_state=RANDOM_SEED,
                ),
            ),
        ]
    )
    primary_pipeline.fit(
        pd.DataFrame([{k: row.get(k) for k in primary_features} for row in train_smart.rows]),
        np.array(train_smart.labels),
    )

    best_baseline = min(
        scores[name]["log_loss"] for name in ["B0_intercept", "B1_metadata", "B2_fleet_context", "B3_exposure"]
    )
    primary_logloss = scores["primary_metadata_plus_smart"]["log_loss"]
    sign_info = sign_diagnostics(primary_pipeline, primary_features)
    sign_pass = all(item["non_violating"] for item in sign_info["smart_signs"].values())
    h1_pass = primary_logloss < 0.95 * best_baseline
    h2_pass = bool(sign_info["smart_signs"]) and sign_pass
    h3_pass = h1_pass

    output = {
        **metadata,
        "scores": scores,
        "best_baseline_log_loss": best_baseline,
        "primary_log_loss": primary_logloss,
        "decision": {
            "H1_predictive_improvement": h1_pass,
            "H2_directional_consistency": h2_pass,
            "H3_test_block_direction": h3_pass,
            "primary_support": h1_pass and h2_pass and h3_pass,
            "no_repair_flow_claim": True,
        },
        "sign_diagnostics": sign_info,
    }
    output_path.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
