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
from dataclasses import dataclass, field
from datetime import date, timedelta
from pathlib import Path
from typing import Iterable

import numpy as np
import pandas as pd
from scipy import sparse
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import roc_auc_score


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

CATEGORICAL_FIELDS = [
    "model",
    "is_legacy_format",
    "datacenter",
    "cluster_id",
    "vault_id",
    "pod_id",
    "pod_slot_num",
]
NUMERIC_FIELDS = ["capacity_bytes", "drive_age_days"] + SMART_FIELDS

PRIMARY_HORIZON_DAYS = 30
MIN_FINAL_TEST_FAILURE_EVENTS = 200
SGD_ALPHA = 1.0e-4
SGD_EPOCHS = 1
RANDOM_SEED = 43001
CLIP_EPS = 1.0e-15


@dataclass(frozen=True)
class SplitDates:
    train: list[str]
    validation: list[str]
    test: list[str]


@dataclass(frozen=True)
class ModelSpec:
    numeric: list[str]
    categorical: list[str]


@dataclass
class NumericAccumulator:
    count: int = 0
    total: float = 0.0
    total_sq: float = 0.0

    def update(self, values: pd.Series) -> None:
        array = pd.to_numeric(values, errors="coerce").fillna(0.0).to_numpy(dtype=float)
        self.count += int(array.size)
        self.total += float(array.sum())
        self.total_sq += float(np.square(array).sum())

    @property
    def mean(self) -> float:
        if self.count == 0:
            return 0.0
        return self.total / self.count

    @property
    def scale(self) -> float:
        if self.count == 0:
            return 1.0
        variance = max(self.total_sq / self.count - self.mean * self.mean, 0.0)
        scale = math.sqrt(variance)
        return scale if scale > 0.0 else 1.0


@dataclass
class TrainingProfile:
    numeric: dict[str, NumericAccumulator] = field(
        default_factory=lambda: {name: NumericAccumulator() for name in ["intercept_only"] + NUMERIC_FIELDS}
    )
    categories: dict[str, set[str]] = field(default_factory=lambda: {name: set() for name in CATEGORICAL_FIELDS})
    class_counts: dict[int, int] = field(default_factory=lambda: {0: 0, 1: 0})

    def class_weights(self) -> dict[int, float]:
        count0 = self.class_counts[0]
        count1 = self.class_counts[1]
        if count0 == 0 or count1 == 0:
            raise SystemExit("Training split must contain both classes for weighted logistic fitting.")
        total = count0 + count1
        return {0: total / (2.0 * count0), 1: total / (2.0 * count1)}


@dataclass
class MatrixSpec:
    numeric: list[str]
    categorical: list[str]
    category_maps: dict[str, dict[str, int]]
    n_features: int
    column_names: list[str]


@dataclass
class MetricAccumulator:
    n: int = 0
    positives: int = 0
    log_loss_sum: float = 0.0
    brier_sum: float = 0.0
    probs: list[np.ndarray] = field(default_factory=list)
    labels: list[np.ndarray] = field(default_factory=list)

    def update(self, y_true: np.ndarray, proba: np.ndarray) -> None:
        clipped = np.clip(proba, CLIP_EPS, 1.0 - CLIP_EPS)
        self.n += int(y_true.size)
        self.positives += int(y_true.sum())
        self.log_loss_sum += float(-(y_true * np.log(clipped) + (1 - y_true) * np.log1p(-clipped)).sum())
        self.brier_sum += float(np.square(y_true - proba).sum())
        self.probs.append(proba.astype(np.float32))
        self.labels.append(y_true.astype(np.int8))

    def result(self, n_train: int, train_positive: int) -> dict[str, float | int | None]:
        output: dict[str, float | int | None] = {
            "n_train": int(n_train),
            "n_test": int(self.n),
            "train_positive": int(train_positive),
            "test_positive": int(self.positives),
            "log_loss": self.log_loss_sum / self.n,
            "brier": self.brier_sum / self.n,
        }
        labels = np.concatenate(self.labels) if self.labels else np.array([], dtype=np.int8)
        probs = np.concatenate(self.probs) if self.probs else np.array([], dtype=np.float32)
        output["auc"] = float(roc_auc_score(labels, probs)) if len(set(labels.tolist())) == 2 else None
        return output


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, help="Backblaze quarterly zip archive.")
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--max-rows",
        type=int,
        default=None,
        help="Debug-only row limit per split. Must be omitted for the frozen primary run.",
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
            "Enable final test-block model fitting/evaluation. Use only after the freeze "
            "manifest has recorded this script hash."
        ),
    )
    return parser.parse_args()


def model_specs(available_smart: list[str]) -> dict[str, ModelSpec]:
    return {
        "B0_intercept": ModelSpec(numeric=["intercept_only"], categorical=[]),
        "B1_metadata": ModelSpec(numeric=["capacity_bytes"], categorical=["model", "is_legacy_format"]),
        "B2_fleet_context": ModelSpec(
            numeric=["capacity_bytes"],
            categorical=["model", "datacenter", "cluster_id", "vault_id", "pod_id", "pod_slot_num", "is_legacy_format"],
        ),
        "B3_exposure": ModelSpec(numeric=["capacity_bytes", "drive_age_days"], categorical=["model"]),
        "primary_metadata_plus_smart": ModelSpec(
            numeric=["capacity_bytes"] + available_smart,
            categorical=["model", "datacenter", "cluster_id", "vault_id", "pod_id", "pod_slot_num", "is_legacy_format"],
        ),
    }


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


def future_failure_label(serial_number: str, current_ordinal: int, failures: dict[str, list[int]]) -> int:
    serial_failures = failures.get(serial_number)
    if not serial_failures:
        return 0
    index = bisect.bisect_right(serial_failures, current_ordinal)
    if index >= len(serial_failures):
        return 0
    return int(serial_failures[index] <= current_ordinal + PRIMARY_HORIZON_DAYS)


def numeric_series(frame: pd.DataFrame, column: str) -> pd.Series:
    if column not in frame.columns:
        return pd.Series(np.zeros(len(frame)), index=frame.index)
    return pd.to_numeric(frame[column], errors="coerce").fillna(0.0)


def smart_series(frame: pd.DataFrame, column: str) -> pd.Series:
    values = numeric_series(frame, column).clip(lower=0.0)
    return np.log1p(values)


def daily_features_and_labels(
    frame: pd.DataFrame,
    current_ordinal: int,
    first_seen: dict[str, int],
    failures: dict[str, list[int]],
    available_smart: list[str],
) -> tuple[pd.DataFrame, np.ndarray]:
    serials = frame["serial_number"].astype(str)
    features = pd.DataFrame(index=frame.index)
    for column in CATEGORICAL_FIELDS:
        if column in frame.columns:
            features[column] = frame[column].fillna("").astype(str)
        else:
            features[column] = ""
    features["capacity_bytes"] = numeric_series(frame, "capacity_bytes")
    features["drive_age_days"] = np.array(
        [float(current_ordinal - first_seen[str(serial)]) for serial in serials],
        dtype=float,
    )
    features["intercept_only"] = 1.0
    for field in available_smart:
        features[field] = smart_series(frame, field)
    labels = np.array(
        [future_failure_label(str(serial), current_ordinal, failures) for serial in serials],
        dtype=np.int8,
    )
    return features.reset_index(drop=True), labels


def stream_batches(
    archive_path: Path,
    csv_names: list[str],
    dates: list[str],
    failures: dict[str, list[int]],
    available_smart: list[str],
    present_columns: set[str],
    max_rows: int | None,
) -> Iterable[tuple[pd.DataFrame, np.ndarray]]:
    wanted_dates = set(dates)
    max_wanted_date = max(wanted_dates)
    read_columns = sorted(
        (
            {
                "date",
                "serial_number",
                "model",
                "capacity_bytes",
                "failure",
                "is_legacy_format",
                "datacenter",
                "cluster_id",
                "vault_id",
                "pod_id",
                "pod_slot_num",
            }
            | set(available_smart)
        )
        & present_columns
    )
    first_seen: dict[str, int] = {}
    emitted = 0
    with zipfile.ZipFile(archive_path) as archive:
        for name in csv_names:
            current_date = Path(name).stem
            current_ordinal = date.fromisoformat(current_date).toordinal()
            frame = read_daily_frame(archive, name, read_columns)
            for serial in pd.unique(frame["serial_number"].astype(str)):
                first_seen.setdefault(str(serial), current_ordinal)
            if current_date not in wanted_dates:
                if current_date > max_wanted_date and (max_rows is None or emitted >= max_rows):
                    break
                continue
            if max_rows is not None:
                remaining = max_rows - emitted
                if remaining <= 0:
                    break
                frame = frame.head(remaining)
            features, labels = daily_features_and_labels(
                frame=frame,
                current_ordinal=current_ordinal,
                first_seen=first_seen,
                failures=failures,
                available_smart=available_smart,
            )
            emitted += len(features)
            yield features, labels
            if max_rows is not None and emitted >= max_rows:
                break


def collect_training_profile(
    archive_path: Path,
    csv_names: list[str],
    train_dates: list[str],
    failures: dict[str, list[int]],
    available_smart: list[str],
    present_columns: set[str],
    max_rows: int | None,
) -> TrainingProfile:
    profile = TrainingProfile()
    for features, labels in stream_batches(
        archive_path, csv_names, train_dates, failures, available_smart, present_columns, max_rows
    ):
        profile.class_counts[0] += int((labels == 0).sum())
        profile.class_counts[1] += int((labels == 1).sum())
        for field in NUMERIC_FIELDS:
            if field in features.columns:
                profile.numeric[field].update(features[field])
        profile.numeric["intercept_only"].update(features["intercept_only"])
        for field in CATEGORICAL_FIELDS:
            if field in features.columns:
                profile.categories[field].update(features[field].astype(str).unique().tolist())
    return profile


def build_matrix_spec(spec: ModelSpec, profile: TrainingProfile) -> MatrixSpec:
    category_maps: dict[str, dict[str, int]] = {}
    column_names = list(spec.numeric)
    offset = len(column_names)
    for field in spec.categorical:
        values = sorted(profile.categories.get(field, set()))
        category_maps[field] = {value: offset + index for index, value in enumerate(values)}
        column_names.extend([f"{field}={value}" for value in values])
        offset += len(values)
    return MatrixSpec(
        numeric=list(spec.numeric),
        categorical=list(spec.categorical),
        category_maps=category_maps,
        n_features=len(column_names),
        column_names=column_names,
    )


def design_matrix(frame: pd.DataFrame, matrix_spec: MatrixSpec, profile: TrainingProfile) -> sparse.csr_matrix:
    blocks: list[sparse.csr_matrix] = []
    n_rows = len(frame)
    if matrix_spec.numeric:
        numeric_columns = []
        for field in matrix_spec.numeric:
            values = numeric_series(frame, field).to_numpy(dtype=float)
            if field != "intercept_only":
                acc = profile.numeric[field]
                values = (values - acc.mean) / acc.scale
            numeric_columns.append(values)
        numeric_array = np.column_stack(numeric_columns) if numeric_columns else np.empty((n_rows, 0))
        blocks.append(sparse.csr_matrix(numeric_array))

    row_indices: list[np.ndarray] = []
    col_indices: list[np.ndarray] = []
    for field in matrix_spec.categorical:
        mapping = matrix_spec.category_maps.get(field, {})
        if not mapping:
            continue
        codes = frame[field].astype(str).map(mapping).fillna(-1).to_numpy(dtype=int)
        mask = codes >= 0
        row_indices.append(np.nonzero(mask)[0])
        col_indices.append(codes[mask])
    if row_indices:
        rows = np.concatenate(row_indices)
        cols = np.concatenate(col_indices)
        data = np.ones(len(rows), dtype=float)
        categorical = sparse.csr_matrix((data, (rows, cols)), shape=(n_rows, matrix_spec.n_features))
        if matrix_spec.numeric:
            categorical = categorical[:, len(matrix_spec.numeric) :]
        blocks.append(categorical)

    if not blocks:
        return sparse.csr_matrix((n_rows, matrix_spec.n_features))
    return sparse.hstack(blocks, format="csr")


def new_classifier(class_weights: dict[int, float]) -> SGDClassifier:
    return SGDClassifier(
        loss="log_loss",
        penalty="l2",
        alpha=SGD_ALPHA,
        learning_rate="optimal",
        average=True,
        class_weight=class_weights,
        random_state=RANDOM_SEED,
    )


def fit_models(
    archive_path: Path,
    csv_names: list[str],
    train_dates: list[str],
    failures: dict[str, list[int]],
    available_smart: list[str],
    present_columns: set[str],
    max_rows: int | None,
    specs: dict[str, ModelSpec],
    profile: TrainingProfile,
) -> tuple[dict[str, SGDClassifier], dict[str, MatrixSpec]]:
    class_weights = profile.class_weights()
    matrix_specs = {name: build_matrix_spec(spec, profile) for name, spec in specs.items()}
    classifiers = {name: new_classifier(class_weights) for name in specs}
    initialized = {name: False for name in specs}
    classes = np.array([0, 1], dtype=np.int8)

    for _ in range(SGD_EPOCHS):
        for features, labels in stream_batches(
            archive_path, csv_names, train_dates, failures, available_smart, present_columns, max_rows
        ):
            for name, classifier in classifiers.items():
                matrix = design_matrix(features, matrix_specs[name], profile)
                if initialized[name]:
                    classifier.partial_fit(matrix, labels)
                else:
                    classifier.partial_fit(matrix, labels, classes=classes)
                    initialized[name] = True
    return classifiers, matrix_specs


def evaluate_models(
    archive_path: Path,
    csv_names: list[str],
    evaluation_dates: list[str],
    failures: dict[str, list[int]],
    available_smart: list[str],
    present_columns: set[str],
    max_rows: int | None,
    classifiers: dict[str, SGDClassifier],
    matrix_specs: dict[str, MatrixSpec],
    profile: TrainingProfile,
) -> dict[str, dict[str, float | int | None]]:
    metrics = {name: MetricAccumulator() for name in classifiers}
    for features, labels in stream_batches(
        archive_path, csv_names, evaluation_dates, failures, available_smart, present_columns, max_rows
    ):
        for name, classifier in classifiers.items():
            matrix = design_matrix(features, matrix_specs[name], profile)
            proba = classifier.predict_proba(matrix)[:, 1]
            metrics[name].update(labels, proba)
    return {
        name: accumulator.result(
            n_train=profile.class_counts[0] + profile.class_counts[1],
            train_positive=profile.class_counts[1],
        )
        for name, accumulator in metrics.items()
    }


def sign_diagnostics(classifier: SGDClassifier, matrix_spec: MatrixSpec) -> dict[str, object]:
    coefficients = classifier.coef_[0]
    by_name = {name: float(coefficients[index]) for index, name in enumerate(matrix_spec.column_names)}
    smart_signs = {}
    for field in SMART_FIELDS:
        if field in by_name:
            value = by_name[field]
            smart_signs[field] = {
                "coefficient": value,
                "non_violating": value >= 0.0,
                "theory_supporting": value > 0.0,
            }
    return {"smart_signs": smart_signs, "feature_count": len(matrix_spec.column_names)}


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
        present_columns = set(header)
        available_smart = [field for field in SMART_FIELDS if field in present_columns]
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
        "available_smart_fields": available_smart,
        "model_class": "streaming L2-regularized logistic regression",
        "optimizer": "sklearn.linear_model.SGDClassifier(loss='log_loss')",
        "sgd_alpha": SGD_ALPHA,
        "sgd_epochs": SGD_EPOCHS,
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
        evaluation_dates = splits.validation
    else:
        evaluation_mode = "primary_test"
        train_dates = splits.train + splits.validation
        evaluation_dates = splits.test

    specs = model_specs(available_smart)
    profile = collect_training_profile(
        archive_path, csv_names, train_dates, failures, available_smart, present_columns, args.max_rows
    )
    classifiers, matrix_specs = fit_models(
        archive_path,
        csv_names,
        train_dates,
        failures,
        available_smart,
        present_columns,
        args.max_rows,
        specs,
        profile,
    )
    scores = evaluate_models(
        archive_path,
        csv_names,
        evaluation_dates,
        failures,
        available_smart,
        present_columns,
        args.max_rows,
        classifiers,
        matrix_specs,
        profile,
    )

    best_baseline = min(
        scores[name]["log_loss"] for name in ["B0_intercept", "B1_metadata", "B2_fleet_context", "B3_exposure"]
    )
    primary_logloss = scores["primary_metadata_plus_smart"]["log_loss"]
    sign_info = sign_diagnostics(
        classifiers["primary_metadata_plus_smart"],
        matrix_specs["primary_metadata_plus_smart"],
    )
    sign_pass = all(item["non_violating"] for item in sign_info["smart_signs"].values())
    h1_pass = primary_logloss < 0.95 * best_baseline
    h2_pass = bool(sign_info["smart_signs"]) and sign_pass
    h3_pass = h1_pass

    output = {
        **metadata,
        "evaluation_mode": evaluation_mode,
        "train_prediction_dates": [train_dates[0], train_dates[-1], len(train_dates)],
        "evaluation_prediction_dates": [evaluation_dates[0], evaluation_dates[-1], len(evaluation_dates)],
        "training_profile": {
            "class_counts": profile.class_counts,
            "class_weights": profile.class_weights(),
        },
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
