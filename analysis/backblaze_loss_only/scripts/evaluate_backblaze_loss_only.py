#!/usr/bin/env python3
"""Frozen evaluation script for the Backblaze loss-only G4 anchor.

This script is intended to be hashed in the freeze manifest before any primary
run. It implements the preregistered loss-only observational analysis only.
It does not contain repair-flow logic.
"""

from __future__ import annotations

import argparse
import bisect
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
    frame: pd.DataFrame
    labels: np.ndarray


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
        "--validation-smoke",
        action="store_true",
        help=(
            "Fit on the train split and evaluate only the validation split. This is an "
            "integration smoke test, not validation evidence, and it does not evaluate "
            "the final test prediction dates."
        ),
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


def read_daily_frame(archive: zipfile.ZipFile, csv_name: str, columns: list[str]) -> pd.DataFrame:
    with archive.open(csv_name) as handle:
        return pd.read_csv(handle, usecols=columns)


def collect_failure_metadata(
    archive: zipfile.ZipFile,
    csv_names: list[str],
    include_lookup: bool,
) -> tuple[dict[str, int], dict[str, list[int]] | None]:
    failures_by_date: dict[str, int] = defaultdict(int)
    failures: dict[str, list[int]] | None = defaultdict(list) if include_lookup else None
    columns = ["date", "serial_number", "failure"]
    for name in csv_names:
        frame = read_daily_frame(archive, name, columns)
        failed = frame[frame["failure"] == 1]
        if failed.empty:
            continue
        for failure_date, count in failed["date"].value_counts().items():
            failures_by_date[str(failure_date)] += int(count)
        if failures is not None:
            for serial, failure_date in zip(
                failed["serial_number"].astype(str),
                failed["date"].astype(str),
                strict=True,
            ):
                failures[serial].append(date.fromisoformat(failure_date).toordinal())
    if failures is not None:
        for values in failures.values():
            values.sort()
    return dict(failures_by_date), dict(failures) if failures is not None else None


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


def future_failure_label(serial_number: str, current_ordinal: int, failures: dict[str, list[int]]) -> int:
    serial_failures = failures.get(serial_number)
    if not serial_failures:
        return 0
    index = bisect.bisect_right(serial_failures, current_ordinal)
    if index >= len(serial_failures):
        return 0
    return int(serial_failures[index] <= current_ordinal + PRIMARY_HORIZON_DAYS)


def numeric_series(frame: pd.DataFrame, column: str) -> pd.Series:
    return pd.to_numeric(frame[column], errors="coerce").fillna(0.0)


def smart_series(frame: pd.DataFrame, column: str) -> pd.Series:
    values = numeric_series(frame, column).clip(lower=0.0)
    return np.log1p(values)


def build_dataset(
    archive: zipfile.ZipFile,
    csv_names: list[str],
    dates: list[str],
    failures: dict[str, list[int]],
    include_smart: bool,
    max_rows: int | None,
) -> Dataset:
    wanted_dates = set(dates)
    max_wanted_date = max(wanted_dates)
    first_seen: dict[str, int] = {}
    frames: list[pd.DataFrame] = []
    label_chunks: list[np.ndarray] = []
    total_rows = 0
    columns = sorted(
        set(
            [
                "date",
                "serial_number",
                "model",
                "capacity_bytes",
                "is_legacy_format",
                "datacenter",
                "cluster_id",
                "vault_id",
                "pod_id",
                "pod_slot_num",
            ]
            + SMART_FIELDS
        )
    )

    for name in csv_names:
        current_date = Path(name).stem
        frame = read_daily_frame(archive, name, columns)
        current_ordinal = date.fromisoformat(current_date).toordinal()
        serials = frame["serial_number"].astype(str)
        for serial in pd.unique(serials):
            first_seen.setdefault(serial, current_ordinal)
        if current_date not in wanted_dates:
            if current_date > max_wanted_date and (max_rows is None or total_rows >= max_rows):
                break
            continue

        if max_rows is not None:
            remaining = max_rows - total_rows
            if remaining <= 0:
                break
            frame = frame.head(remaining)
            serials = frame["serial_number"].astype(str)

        features = pd.DataFrame(index=frame.index)
        for column in ["model", "is_legacy_format", "datacenter", "cluster_id", "vault_id", "pod_id", "pod_slot_num"]:
            features[column] = frame[column].fillna("").astype(str)
        features["capacity_bytes"] = numeric_series(frame, "capacity_bytes")
        features["drive_age_days"] = [
            float(current_ordinal - first_seen[str(serial)])
            for serial in serials
        ]
        if include_smart:
            for field in SMART_FIELDS:
                features[field] = smart_series(frame, field)
        labels = np.array(
            [future_failure_label(str(serial), current_ordinal, failures) for serial in serials],
            dtype=np.int8,
        )
        frames.append(features.reset_index(drop=True))
        label_chunks.append(labels)
        total_rows += len(features)
        if max_rows is not None and total_rows >= max_rows:
            break

    if not frames:
        return Dataset(frame=pd.DataFrame(), labels=np.array([], dtype=np.int8))
    return Dataset(frame=pd.concat(frames, ignore_index=True), labels=np.concatenate(label_chunks))


def feature_columns(frame: pd.DataFrame, requested: list[str]) -> list[str]:
    if frame.empty:
        return []
    present = frame.columns
    return [column for column in requested if column in present]


def fit_and_score(
    train: Dataset,
    test: Dataset,
    feature_names: list[str],
    categorical: list[str],
) -> tuple[dict[str, Any], Pipeline]:
    numeric = [name for name in feature_names if name not in categorical]
    categorical = [name for name in categorical if name in feature_names]

    transformer = ColumnTransformer(
        transformers=[
            ("numeric", StandardScaler(), numeric),
            (
                "categorical",
                OneHotEncoder(handle_unknown="ignore", sparse_output=True),
                categorical,
            ),
        ],
        remainder="drop",
        sparse_threshold=1.0,
    )
    model = LogisticRegression(
        C=LOGISTIC_C,
        solver="lbfgs",
        max_iter=1000,
        class_weight="balanced",
        random_state=RANDOM_SEED,
    )
    pipeline = Pipeline([("preprocess", transformer), ("model", model)])
    x_train = train.frame.loc[:, feature_names]
    x_test = test.frame.loc[:, feature_names]
    y_train = train.labels
    y_test = test.labels
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
    return result, pipeline


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
    if args.validation_smoke and args.allow_primary_run:
        raise SystemExit("--validation-smoke and --allow-primary-run are mutually exclusive.")

    with zipfile.ZipFile(archive_path) as archive:
        csv_names = list_csv_files(archive)
        if not csv_names:
            raise SystemExit("No CSV files found in archive.")

        header = read_header(archive, csv_names[0])
        all_dates = date_range_from_names(csv_names)
        eligible = eligible_prediction_dates(all_dates, PRIMARY_HORIZON_DAYS)
        splits = split_dates(eligible)
        failures_by_date, failures = collect_failure_metadata(
            archive, csv_names, include_lookup=not args.metadata_only
        )
        endpoint_dates = endpoint_dates_for_test(splits.test, PRIMARY_HORIZON_DAYS)
        endpoint_failures = sum(failures_by_date.get(d, 0) for d in endpoint_dates)

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
        "validation_smoke": args.validation_smoke,
        "allow_primary_run": args.allow_primary_run,
        "max_rows": args.max_rows,
    }

    if args.metadata_only:
        output_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n")
        return
    if not args.allow_primary_run and not args.validation_smoke:
        raise SystemExit(
            "Model fitting requires --validation-smoke or --allow-primary-run. Use "
            "--validation-smoke for pre-freeze integration checks, and use "
            "--allow-primary-run only after the freeze manifest has recorded the final "
            "script hash."
        )

    if failures is None:
        raise AssertionError("failure lookup is required for model fitting")

    if args.validation_smoke:
        evaluation_mode = "validation_smoke"
        train_dates = splits.train
        eval_dates = splits.validation
    else:
        evaluation_mode = "primary_test"
        train_dates = splits.train + splits.validation
        eval_dates = splits.test

    with zipfile.ZipFile(archive_path) as archive:
        train_smart = build_dataset(
            archive, csv_names, train_dates, failures, include_smart=True, max_rows=args.max_rows
        )
        eval_smart = build_dataset(
            archive, csv_names, eval_dates, failures, include_smart=True, max_rows=args.max_rows
        )
        train_meta = Dataset(
            frame=train_smart.frame.drop(columns=SMART_FIELDS, errors="ignore"),
            labels=train_smart.labels,
        )
        eval_meta = Dataset(
            frame=eval_smart.frame.drop(columns=SMART_FIELDS, errors="ignore"),
            labels=eval_smart.labels,
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
    primary_pipeline: Pipeline | None = None
    primary_features: list[str] = []
    for name, requested in models.items():
        if name == "B0_intercept":
            train_meta = Dataset(frame=train_meta.frame.assign(intercept_only=1.0), labels=train_meta.labels)
            eval_meta = Dataset(frame=eval_meta.frame.assign(intercept_only=1.0), labels=eval_meta.labels)
            requested = ["intercept_only"]
        source_train = train_smart if name == "primary_metadata_plus_smart" else train_meta
        source_test = eval_smart if name == "primary_metadata_plus_smart" else eval_meta
        features = feature_columns(source_train.frame, requested)
        categorical = [value for value in categorical_base if value in features]
        score, pipeline = fit_and_score(source_train, source_test, features, categorical)
        scores[name] = score
        if name == "primary_metadata_plus_smart":
            primary_pipeline = pipeline
            primary_features = features

    best_baseline = min(
        scores[name]["log_loss"] for name in ["B0_intercept", "B1_metadata", "B2_fleet_context", "B3_exposure"]
    )
    primary_logloss = scores["primary_metadata_plus_smart"]["log_loss"]
    if primary_pipeline is None:
        raise AssertionError("primary pipeline was not fitted")
    sign_info = sign_diagnostics(primary_pipeline, primary_features)
    sign_pass = all(item["non_violating"] for item in sign_info["smart_signs"].values())
    h1_pass = primary_logloss < 0.95 * best_baseline
    h2_pass = bool(sign_info["smart_signs"]) and sign_pass
    h3_pass = h1_pass

    output = {
        **metadata,
        "evaluation_mode": evaluation_mode,
        "train_prediction_dates": [train_dates[0], train_dates[-1], len(train_dates)],
        "evaluation_prediction_dates": [eval_dates[0], eval_dates[-1], len(eval_dates)],
        "scores": scores,
        "best_baseline_log_loss": best_baseline,
        "primary_log_loss": primary_logloss,
        "decision": {
            "H1_predictive_improvement": h1_pass,
            "H2_directional_consistency": h2_pass,
            "H3_test_block_direction": h3_pass,
            "primary_support": None if args.validation_smoke else h1_pass and h2_pass and h3_pass,
            "validation_smoke_only": args.validation_smoke,
            "not_validation_evidence": args.validation_smoke,
            "no_repair_flow_claim": True,
        },
        "sign_diagnostics": sign_info,
    }
    output_path.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
