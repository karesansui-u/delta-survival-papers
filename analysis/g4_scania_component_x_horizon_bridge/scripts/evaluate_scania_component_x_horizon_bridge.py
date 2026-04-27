#!/usr/bin/env python3
"""Scania Component X horizon-bridge evaluation script.

Modes:
- --metadata-only: file identity and structural facts only
- --validation-smoke: train + validation pipeline integration; no validation metrics
- --allow-primary-run: held-out test evaluation after freeze

This script intentionally does not make repair-flow or direct g_t claims.
"""

from __future__ import annotations

import argparse
import json
import hashlib
import inspect
import warnings
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, balanced_accuracy_score, confusion_matrix, f1_score, log_loss
from sklearn.preprocessing import OneHotEncoder


DATASET_FAMILY = "Scania Component X"
VERSION = "3"
DOI = "10.5878/bnh5-ka77"
RANDOM_SEED = 43001
CLASS_LABELS = [0, 1, 2, 3, 4]

LOGREG_KWARGS = {
    "penalty": "l2",
    "solver": "lbfgs",
    "C": 1.0,
    "max_iter": 2000,
    "class_weight": None,
    "random_state": RANDOM_SEED,
}

EXPECTED_FILES = {
    "train_operational_readouts.csv": {
        "bytes": 1219209878,
        "sha256": "e01cb0bd87dfab4c9dbad215d51d81282fc0d413be96d6f819ea872fb7a3c715",
        "rows": 1122452,
        "vehicles": 23550,
        "columns": 107,
    },
    "validation_operational_readouts.csv": {
        "bytes": 215593159,
        "sha256": "1e1597eec866588c2ad95eb923555ad719c64b3697d9140f9cec6809349809af",
        "rows": 196227,
        "vehicles": 5046,
        "columns": 107,
    },
    "test_operational_readouts.csv": {
        "bytes": 214897259,
        "sha256": "81f2709cd339e0ff561f5fd3188d7f431680e32400bd788814880d7759615ba1",
        "rows": 198140,
        "vehicles": 5045,
        "columns": 107,
    },
    "train_tte.csv": {
        "bytes": 345412,
        "sha256": "d8c2379ed7c95a575dd869730b2b3b96d660317f49e57de300518ff3b08d53a5",
        "rows": 23550,
    },
    "validation_labels.csv": {
        "bytes": 38742,
        "sha256": "ad876c95c3696f4cfca2d76212ad6bb3cac6b2d2950a4aeaf218ee8b1548d08c",
        "rows": 5046,
    },
    "test_labels.csv": {
        "bytes": 38682,
        "sha256": "60f923051d4ba1bef4c81166cf9e8ca01daf3b7a29c73016c6f48a23dcfa0223",
        "rows": 5045,
    },
    "train_specifications.csv": {
        "bytes": 1081118,
        "sha256": "47cc9a67aee19d5e2ee8620fe8e467490b2125bacc7787ce781ce9f3c1f0c38f",
        "rows": 23550,
    },
    "validation_specifications.csv": {
        "bytes": 231765,
        "sha256": "a31e832846538dd7a1829108b69420d9377dcd05d6446d8ac1270a974fc58ae2",
        "rows": 5046,
    },
    "test_specifications.csv": {
        "bytes": 231658,
        "sha256": "40ac8a111f6d5b416107ec1786f639766ecf1293a1c9c0c0dbf24f14c1c5d0e7",
        "rows": 5045,
    },
}

LABEL_GRAMMAR = {
    0: ">48",
    1: "48-24",
    2: "24-12",
    3: "12-6",
    4: "6-0",
}


@dataclass(frozen=True)
class FileIdentity:
    name: str
    path: str
    bytes: int
    sha256: str


@dataclass(frozen=True)
class Surface:
    vehicle_ids: np.ndarray
    time_step: np.ndarray
    raw: np.ndarray
    labels: np.ndarray | None


@dataclass(frozen=True)
class DPC1Transform:
    mean: np.ndarray
    scale: np.ndarray
    component: np.ndarray
    oriented_corr_with_time_step: float


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-dir",
        required=True,
        help="Directory containing the nine Scania v3 CSV files.",
    )
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="Emit only archive identity and structural facts; no model fitting.",
    )
    parser.add_argument(
        "--validation-smoke",
        action="store_true",
        help="Run train->validation integration smoke with no validation metrics or predictions recorded.",
    )
    parser.add_argument(
        "--allow-primary-run",
        action="store_true",
        help="Enable held-out test evaluation. Use only after freeze.",
    )
    args = parser.parse_args()
    selected = [args.metadata_only, args.validation_smoke, args.allow_primary_run]
    if sum(bool(x) for x in selected) != 1:
        raise SystemExit(
            "Choose exactly one mode: --metadata-only, --validation-smoke, or --allow-primary-run."
        )
    return args


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def expected_paths(data_dir: Path) -> dict[str, Path]:
    return {name: data_dir / name for name in EXPECTED_FILES}


def verify_file_identities(data_dir: Path) -> dict[str, FileIdentity]:
    identities: dict[str, FileIdentity] = {}
    for name, expected in EXPECTED_FILES.items():
        path = data_dir / name
        if not path.exists():
            raise SystemExit(f"Missing required Scania file: {path}")
        size = path.stat().st_size
        if size != expected["bytes"]:
            raise SystemExit(f"{name} bytes mismatch: expected {expected['bytes']}, observed {size}")
        observed_sha256 = sha256_file(path)
        if observed_sha256 != expected["sha256"]:
            raise SystemExit(
                f"{name} sha256 mismatch: expected {expected['sha256']}, observed {observed_sha256}"
            )
        identities[name] = FileIdentity(
            name=name,
            path=str(path),
            bytes=size,
            sha256=observed_sha256,
        )
    return identities


def read_frame(path: Path, *, final_only: bool = False) -> pd.DataFrame:
    header = pd.read_csv(path, nrows=0)
    columns = header.columns.tolist()
    dtype_map = {"vehicle_id": np.int32}
    for name in columns:
        if name == "time_step":
            dtype_map[name] = np.float64
        elif name != "vehicle_id":
            dtype_map[name] = np.float32
    frame = pd.read_csv(path, dtype=dtype_map)
    if final_only:
        final_idx = frame.groupby("vehicle_id")["time_step"].idxmax()
        frame = frame.loc[final_idx].sort_values("vehicle_id").reset_index(drop=True)
    return frame


def read_small_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path)


def classify_delta(delta: np.ndarray) -> np.ndarray:
    labels = np.zeros(delta.shape[0], dtype=np.int8)
    labels[(delta <= 48.0) & (delta > 24.0)] = 1
    labels[(delta <= 24.0) & (delta > 12.0)] = 2
    labels[(delta <= 12.0) & (delta > 6.0)] = 3
    labels[delta <= 6.0] = 4
    return labels


def class_counts_dict(labels: np.ndarray) -> dict[str, int]:
    counts = pd.Series(labels, dtype="int64").value_counts().sort_index()
    return {str(i): int(counts.get(i, 0)) for i in CLASS_LABELS}


def validate_row_count(name: str, observed_rows: int) -> None:
    expected_rows = EXPECTED_FILES[name]["rows"]
    if observed_rows != expected_rows:
        raise SystemExit(f"{name} row-count mismatch: expected {expected_rows}, observed {observed_rows}")


def read_readout_columns(data_dir: Path) -> list[str]:
    cols = pd.read_csv(data_dir / "train_operational_readouts.csv", nrows=0).columns.tolist()
    if cols[:2] != ["vehicle_id", "time_step"]:
        raise SystemExit(f"Unexpected readout prefix: {cols[:2]}")
    if len(cols) != EXPECTED_FILES["train_operational_readouts.csv"]["columns"]:
        raise SystemExit(f"Unexpected readout column count: {len(cols)}")
    return [c for c in cols if c not in {"vehicle_id", "time_step"}]


def metadata_payload(data_dir: Path, identities: dict[str, FileIdentity]) -> dict:
    train_tte = read_small_csv(data_dir / "train_tte.csv")
    validation_labels = read_small_csv(data_dir / "validation_labels.csv")
    test_labels = read_small_csv(data_dir / "test_labels.csv")
    train_specs = read_small_csv(data_dir / "train_specifications.csv")
    validation_specs = read_small_csv(data_dir / "validation_specifications.csv")
    test_specs = read_small_csv(data_dir / "test_specifications.csv")

    for name, frame in (
        ("train_tte.csv", train_tte),
        ("validation_labels.csv", validation_labels),
        ("test_labels.csv", test_labels),
        ("train_specifications.csv", train_specs),
        ("validation_specifications.csv", validation_specs),
        ("test_specifications.csv", test_specs),
    ):
        validate_row_count(name, len(frame))

    readout_cols = read_readout_columns(data_dir)
    spec_cols = [c for c in train_specs.columns if c != "vehicle_id"]
    return {
        "mode": "metadata_only",
        "dataset": {
            "family": DATASET_FAMILY,
            "version": VERSION,
            "doi": DOI,
            "data_dir": str(data_dir),
        },
        "file_identities": {
            name: {
                "path": identities[name].path,
                "bytes": identities[name].bytes,
                "sha256": identities[name].sha256,
            }
            for name in EXPECTED_FILES
        },
        "structure": {
            "readout_columns": len(readout_cols) + 2,
            "raw_readout_feature_columns": len(readout_cols),
            "raw_readout_feature_names_prefix": readout_cols[:8],
            "specification_columns": spec_cols,
            "label_grammar": LABEL_GRAMMAR,
            "train_tte_rows": len(train_tte),
            "train_repair_counts": {
                str(k): int(v)
                for k, v in train_tte["in_study_repair"].value_counts().sort_index().to_dict().items()
            },
            "validation_label_counts": class_counts_dict(validation_labels["class_label"].to_numpy(dtype=np.int8)),
            "test_label_counts": class_counts_dict(test_labels["class_label"].to_numpy(dtype=np.int8)),
            "expected_readout_row_counts": {
                "train": EXPECTED_FILES["train_operational_readouts.csv"]["rows"],
                "validation": EXPECTED_FILES["validation_operational_readouts.csv"]["rows"],
                "test": EXPECTED_FILES["test_operational_readouts.csv"]["rows"],
            },
            "expected_unique_vehicle_counts": {
                "train": EXPECTED_FILES["train_operational_readouts.csv"]["vehicles"],
                "validation": EXPECTED_FILES["validation_operational_readouts.csv"]["vehicles"],
                "test": EXPECTED_FILES["test_operational_readouts.csv"]["vehicles"],
            },
        },
    }


def load_surfaces(data_dir: Path, include_validation: bool, include_test: bool) -> tuple[
    Surface,
    pd.DataFrame,
    Surface | None,
    pd.DataFrame | None,
    Surface | None,
    pd.DataFrame | None,
    list[str],
]:
    readout_cols = read_readout_columns(data_dir)

    train_readouts = read_frame(data_dir / "train_operational_readouts.csv", final_only=False)
    validate_row_count("train_operational_readouts.csv", len(train_readouts))
    train_tte = read_small_csv(data_dir / "train_tte.csv")
    validate_row_count("train_tte.csv", len(train_tte))
    train_specs = read_small_csv(data_dir / "train_specifications.csv")
    validate_row_count("train_specifications.csv", len(train_specs))

    train_tte_indexed = train_tte.set_index("vehicle_id").sort_index()
    train_specs = train_specs.sort_values("vehicle_id").reset_index(drop=True)
    train_vehicle_ids = train_readouts["vehicle_id"].to_numpy(dtype=np.int32)
    joined_tte = train_tte_indexed.loc[train_vehicle_ids]
    delta = joined_tte["length_of_study_time_step"].to_numpy(dtype=np.float64) - train_readouts["time_step"].to_numpy(
        dtype=np.float64
    )
    in_study_repair = joined_tte["in_study_repair"].to_numpy(dtype=np.int8)
    train_labels = np.where(in_study_repair == 0, 0, classify_delta(delta)).astype(np.int8)
    train_surface = Surface(
        vehicle_ids=train_vehicle_ids,
        time_step=train_readouts["time_step"].to_numpy(dtype=np.float64),
        raw=train_readouts[readout_cols].fillna(0.0).to_numpy(dtype=np.float32),
        labels=train_labels,
    )
    del train_readouts

    validation_surface: Surface | None = None
    validation_specs_df: pd.DataFrame | None = None
    if include_validation:
        validation_readouts = read_frame(data_dir / "validation_operational_readouts.csv", final_only=True)
        if validation_readouts["vehicle_id"].nunique() != EXPECTED_FILES["validation_operational_readouts.csv"]["vehicles"]:
            raise SystemExit("validation_operational_readouts.csv unique-vehicle mismatch.")
        validation_labels = read_small_csv(data_dir / "validation_labels.csv").sort_values("vehicle_id").reset_index(drop=True)
        validate_row_count("validation_labels.csv", len(validation_labels))
        validation_specs_df = read_small_csv(data_dir / "validation_specifications.csv").sort_values("vehicle_id").reset_index(drop=True)
        validate_row_count("validation_specifications.csv", len(validation_specs_df))
        validation_label_indexed = validation_labels.set_index("vehicle_id").sort_index()
        validation_vehicle_ids = validation_readouts["vehicle_id"].to_numpy(dtype=np.int32)
        validation_surface = Surface(
            vehicle_ids=validation_vehicle_ids,
            time_step=validation_readouts["time_step"].to_numpy(dtype=np.float64),
            raw=validation_readouts[readout_cols].fillna(0.0).to_numpy(dtype=np.float32),
            labels=validation_label_indexed.loc[validation_vehicle_ids, "class_label"].to_numpy(dtype=np.int8),
        )
        del validation_readouts

    test_surface: Surface | None = None
    test_specs_df: pd.DataFrame | None = None
    if include_test:
        test_readouts = read_frame(data_dir / "test_operational_readouts.csv", final_only=True)
        if test_readouts["vehicle_id"].nunique() != EXPECTED_FILES["test_operational_readouts.csv"]["vehicles"]:
            raise SystemExit("test_operational_readouts.csv unique-vehicle mismatch.")
        test_labels = read_small_csv(data_dir / "test_labels.csv").sort_values("vehicle_id").reset_index(drop=True)
        validate_row_count("test_labels.csv", len(test_labels))
        test_specs_df = read_small_csv(data_dir / "test_specifications.csv").sort_values("vehicle_id").reset_index(drop=True)
        validate_row_count("test_specifications.csv", len(test_specs_df))
        test_label_indexed = test_labels.set_index("vehicle_id").sort_index()
        test_vehicle_ids = test_readouts["vehicle_id"].to_numpy(dtype=np.int32)
        test_surface = Surface(
            vehicle_ids=test_vehicle_ids,
            time_step=test_readouts["time_step"].to_numpy(dtype=np.float64),
            raw=test_readouts[readout_cols].fillna(0.0).to_numpy(dtype=np.float32),
            labels=test_label_indexed.loc[test_vehicle_ids, "class_label"].to_numpy(dtype=np.int8),
        )
        del test_readouts

    return (
        train_surface,
        train_specs,
        validation_surface,
        validation_specs_df,
        test_surface,
        test_specs_df,
        readout_cols,
    )


def fit_spec_encoder(train_specs: pd.DataFrame) -> tuple[OneHotEncoder, list[str]]:
    spec_cols = [c for c in train_specs.columns if c != "vehicle_id"]
    encoder = OneHotEncoder(handle_unknown="ignore", sparse_output=False, dtype=np.float32)
    encoder.fit(train_specs[spec_cols])
    return encoder, spec_cols


def encode_specs_for_surface(
    specs_df: pd.DataFrame,
    vehicle_ids: np.ndarray,
    encoder: OneHotEncoder,
    spec_cols: list[str],
) -> np.ndarray:
    indexed = specs_df.set_index("vehicle_id").sort_index()
    repeated = indexed.loc[vehicle_ids, spec_cols]
    return encoder.transform(repeated).astype(np.float32, copy=False)


def fit_d_pc1(train_raw: np.ndarray, train_time_step: np.ndarray) -> tuple[np.ndarray, DPC1Transform]:
    mean = train_raw.mean(axis=0, dtype=np.float64)
    scale = train_raw.std(axis=0, dtype=np.float64)
    scale = np.where(scale > 0.0, scale, 1.0)
    standardized = (train_raw.astype(np.float64) - mean) / scale
    pca = PCA(n_components=1, svd_solver="auto", random_state=RANDOM_SEED)
    train_scores = pca.fit_transform(standardized).reshape(-1)
    raw_corr = float(np.corrcoef(train_scores, train_time_step.astype(np.float64))[0, 1])
    sign = -1.0 if raw_corr < 0 else 1.0
    train_scores = train_scores * sign
    component = pca.components_.reshape(-1) * sign
    transform = DPC1Transform(
        mean=mean,
        scale=scale,
        component=component,
        oriented_corr_with_time_step=raw_corr * sign,
    )
    return train_scores.astype(np.float32), transform


def transform_d_pc1(raw: np.ndarray, transform: DPC1Transform) -> np.ndarray:
    standardized = (raw.astype(np.float64) - transform.mean) / transform.scale
    scores = standardized @ transform.component.reshape(-1, 1)
    return scores.reshape(-1).astype(np.float32)


def numeric_stats(train_numeric: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    mean = train_numeric.mean(axis=0, dtype=np.float64)
    scale = train_numeric.std(axis=0, dtype=np.float64)
    scale = np.where(scale > 0.0, scale, 1.0)
    return mean, scale


def standardize_numeric(matrix: np.ndarray, mean: np.ndarray, scale: np.ndarray) -> np.ndarray:
    return ((matrix.astype(np.float64) - mean) / scale).astype(np.float32)


def model_matrices(
    model_name: str,
    train_surface: Surface,
    eval_surface: Surface,
    train_specs_encoded: np.ndarray,
    eval_specs_encoded: np.ndarray,
    train_d_pc1: np.ndarray,
    eval_d_pc1: np.ndarray,
) -> tuple[np.ndarray, np.ndarray, list[str]]:
    if model_name == "B1":
        train_numeric = train_surface.time_step.reshape(-1, 1)
        eval_numeric = eval_surface.time_step.reshape(-1, 1)
        mean, scale = numeric_stats(train_numeric)
        return (
            standardize_numeric(train_numeric, mean, scale),
            standardize_numeric(eval_numeric, mean, scale),
            ["time_step"],
        )
    if model_name == "B2":
        train_numeric = train_surface.time_step.reshape(-1, 1)
        eval_numeric = eval_surface.time_step.reshape(-1, 1)
        mean, scale = numeric_stats(train_numeric)
        train_block = standardize_numeric(train_numeric, mean, scale)
        eval_block = standardize_numeric(eval_numeric, mean, scale)
        feature_names = ["time_step"] + [f"spec::{i}" for i in range(train_specs_encoded.shape[1])]
        return (
            np.concatenate([train_block, train_specs_encoded], axis=1),
            np.concatenate([eval_block, eval_specs_encoded], axis=1),
            feature_names,
        )
    if model_name == "B3":
        train_numeric = np.concatenate([train_surface.time_step.reshape(-1, 1), train_surface.raw], axis=1)
        eval_numeric = np.concatenate([eval_surface.time_step.reshape(-1, 1), eval_surface.raw], axis=1)
        mean, scale = numeric_stats(train_numeric)
        train_block = standardize_numeric(train_numeric, mean, scale)
        eval_block = standardize_numeric(eval_numeric, mean, scale)
        feature_names = ["time_step"] + [f"readout::{i}" for i in range(train_surface.raw.shape[1])] + [
            f"spec::{i}" for i in range(train_specs_encoded.shape[1])
        ]
        return (
            np.concatenate([train_block, train_specs_encoded], axis=1),
            np.concatenate([eval_block, eval_specs_encoded], axis=1),
            feature_names,
        )
    if model_name == "primary":
        train_numeric = np.column_stack([train_surface.time_step, train_d_pc1]).astype(np.float32)
        eval_numeric = np.column_stack([eval_surface.time_step, eval_d_pc1]).astype(np.float32)
        mean, scale = numeric_stats(train_numeric)
        train_block = standardize_numeric(train_numeric, mean, scale)
        eval_block = standardize_numeric(eval_numeric, mean, scale)
        feature_names = ["time_step", "D_pc1"] + [f"spec::{i}" for i in range(train_specs_encoded.shape[1])]
        return (
            np.concatenate([train_block, train_specs_encoded], axis=1),
            np.concatenate([eval_block, eval_specs_encoded], axis=1),
            feature_names,
        )
    raise SystemExit(f"Unknown model name: {model_name}")


def fit_multinomial_logistic(train_x: np.ndarray, train_y: np.ndarray) -> LogisticRegression:
    kwargs = dict(LOGREG_KWARGS)
    if "multi_class" in inspect.signature(LogisticRegression).parameters:
        kwargs["multi_class"] = "multinomial"
    model = LogisticRegression(**kwargs)
    model.fit(train_x, train_y)
    return model


def prior_probabilities(train_y: np.ndarray, size: int) -> np.ndarray:
    counts = np.bincount(train_y.astype(np.int64), minlength=len(CLASS_LABELS)).astype(np.float64)
    probs = counts / counts.sum()
    return np.tile(probs.reshape(1, -1), (size, 1))


def evaluate_probabilities(y_true: np.ndarray, y_prob: np.ndarray) -> dict[str, float | list[list[int]]]:
    y_pred = y_prob.argmax(axis=1)
    return {
        "multiclass_log_loss": float(log_loss(y_true, y_prob, labels=CLASS_LABELS)),
        "macro_f1": float(f1_score(y_true, y_pred, labels=CLASS_LABELS, average="macro")),
        "balanced_accuracy": float(balanced_accuracy_score(y_true, y_pred)),
        "plain_accuracy": float(accuracy_score(y_true, y_pred)),
        "ordered_distance_mean": float(np.mean(np.abs(y_pred - y_true))),
        "confusion_matrix": confusion_matrix(y_true, y_pred, labels=CLASS_LABELS).astype(int).tolist(),
    }


def validation_smoke_payload(data_dir: Path, identities: dict[str, FileIdentity]) -> dict:
    train_surface, train_specs, validation_surface, validation_specs, _, _, readout_cols = load_surfaces(
        data_dir,
        include_validation=True,
        include_test=False,
    )
    if validation_surface is None or validation_specs is None:
        raise SystemExit("Validation surface missing in validation-smoke mode.")

    encoder, spec_cols = fit_spec_encoder(train_specs)
    train_specs_encoded = encode_specs_for_surface(train_specs, train_surface.vehicle_ids, encoder, spec_cols)
    validation_specs_encoded = encode_specs_for_surface(
        validation_specs, validation_surface.vehicle_ids, encoder, spec_cols
    )

    train_d_pc1, dpc1_transform = fit_d_pc1(train_surface.raw, train_surface.time_step)
    validation_d_pc1 = transform_d_pc1(validation_surface.raw, dpc1_transform)

    fit_status: dict[str, bool] = {}
    feature_dims: dict[str, int] = {}
    probability_shapes: dict[str, list[int]] = {}
    for model_name in ("B1", "B2", "B3", "primary"):
        train_x, validation_x, feature_names = model_matrices(
            model_name,
            train_surface,
            validation_surface,
            train_specs_encoded,
            validation_specs_encoded,
            train_d_pc1,
            validation_d_pc1,
        )
        model = fit_multinomial_logistic(train_x, train_surface.labels)
        probs = model.predict_proba(validation_x)
        fit_status[model_name] = True
        feature_dims[model_name] = len(feature_names)
        probability_shapes[model_name] = [int(probs.shape[0]), int(probs.shape[1])]
        del train_x, validation_x, probs, model

    b0_probs = prior_probabilities(train_surface.labels, validation_surface.labels.shape[0])

    return {
        "mode": "validation_smoke",
        "dataset": {
            "family": DATASET_FAMILY,
            "version": VERSION,
            "doi": DOI,
            "data_dir": str(data_dir),
        },
        "file_identities": {
            name: {
                "path": identities[name].path,
                "bytes": identities[name].bytes,
                "sha256": identities[name].sha256,
            }
            for name in EXPECTED_FILES
        },
        "structure": {
            "train_rows": int(train_surface.raw.shape[0]),
            "train_unique_vehicles": int(np.unique(train_surface.vehicle_ids).size),
            "validation_surface_rows": int(validation_surface.raw.shape[0]),
            "validation_unique_vehicles": int(np.unique(validation_surface.vehicle_ids).size),
            "readout_feature_columns": len(readout_cols),
            "specification_columns": spec_cols,
            "train_label_counts": class_counts_dict(train_surface.labels),
            "validation_label_counts": class_counts_dict(validation_surface.labels),
        },
        "coordinate": {
            "name": "D_pc1",
            "oriented_corr_with_time_step_train": dpc1_transform.oriented_corr_with_time_step,
        },
        "fit_status": fit_status,
        "feature_dims": feature_dims,
        "probability_shapes": {
            "B0": [int(b0_probs.shape[0]), int(b0_probs.shape[1])],
            **probability_shapes,
        },
        "design_lock": {
            "censored_as_class_0_rule": True,
            "row_level_training": True,
            "vehicle_balanced_resampling": False,
            "vehicle_level_weighting": False,
            "downsampling": False,
            "class_weight": None,
        },
        "no_peek": {
            "validation_metrics_recorded": False,
            "validation_predictions_recorded": False,
            "held_out_test_loaded": False,
            "held_out_test_metrics_recorded": False,
            "held_out_test_predictions_recorded": False,
        },
    }


def primary_payload(data_dir: Path, identities: dict[str, FileIdentity]) -> dict:
    (
        train_surface,
        train_specs,
        _validation_surface,
        _validation_specs,
        test_surface,
        test_specs,
        readout_cols,
    ) = load_surfaces(data_dir, include_validation=False, include_test=True)
    if test_surface is None or test_specs is None:
        raise SystemExit("Test surface missing in primary mode.")

    encoder, spec_cols = fit_spec_encoder(train_specs)
    train_specs_encoded = encode_specs_for_surface(train_specs, train_surface.vehicle_ids, encoder, spec_cols)
    test_specs_encoded = encode_specs_for_surface(test_specs, test_surface.vehicle_ids, encoder, spec_cols)

    train_d_pc1, dpc1_transform = fit_d_pc1(train_surface.raw, train_surface.time_step)
    test_d_pc1 = transform_d_pc1(test_surface.raw, dpc1_transform)

    results: dict[str, dict] = {}
    b0_probs = prior_probabilities(train_surface.labels, test_surface.labels.shape[0])
    results["B0"] = {
        "metrics": evaluate_probabilities(test_surface.labels, b0_probs),
        "training_class_prior": {
            str(i): float((train_surface.labels == i).mean()) for i in CLASS_LABELS
        },
    }

    for model_name in ("B1", "B2", "B3", "primary"):
        train_x, test_x, feature_names = model_matrices(
            model_name,
            train_surface,
            test_surface,
            train_specs_encoded,
            test_specs_encoded,
            train_d_pc1,
            test_d_pc1,
        )
        model = fit_multinomial_logistic(train_x, train_surface.labels)
        probs = model.predict_proba(test_x)
        results[model_name] = {
            "feature_count": len(feature_names),
            "metrics": evaluate_probabilities(test_surface.labels, probs),
        }
        if model_name == "primary":
            results[model_name]["coordinate"] = {
                "name": "D_pc1",
                "oriented_corr_with_time_step_train": dpc1_transform.oriented_corr_with_time_step,
            }
        del train_x, test_x, probs, model

    h1_target = min(
        results["B1"]["metrics"]["multiclass_log_loss"],
        results["B2"]["metrics"]["multiclass_log_loss"],
    )
    h1 = results["primary"]["metrics"]["multiclass_log_loss"] <= 0.95 * h1_target
    h2 = results["primary"]["metrics"]["multiclass_log_loss"] <= 1.10 * results["B3"]["metrics"]["multiclass_log_loss"]

    return {
        "mode": "primary",
        "dataset": {
            "family": DATASET_FAMILY,
            "version": VERSION,
            "doi": DOI,
            "data_dir": str(data_dir),
        },
        "file_identities": {
            name: {
                "path": identities[name].path,
                "bytes": identities[name].bytes,
                "sha256": identities[name].sha256,
            }
            for name in EXPECTED_FILES
        },
        "structure": {
            "train_rows": int(train_surface.raw.shape[0]),
            "train_unique_vehicles": int(np.unique(train_surface.vehicle_ids).size),
            "test_surface_rows": int(test_surface.raw.shape[0]),
            "test_unique_vehicles": int(np.unique(test_surface.vehicle_ids).size),
            "readout_feature_columns": len(readout_cols),
            "specification_columns": spec_cols,
            "train_label_counts": class_counts_dict(train_surface.labels),
            "test_label_counts": class_counts_dict(test_surface.labels),
        },
        "model_class": {**LOGREG_KWARGS, "multi_class": "multinomial"},
        "design_lock": {
            "censored_as_class_0_rule": True,
            "row_level_training": True,
            "vehicle_balanced_resampling": False,
            "vehicle_level_weighting": False,
            "downsampling": False,
            "class_weight": None,
            "primary_metric": "multiclass_log_loss",
            "primary_model": "time_step + specifications + D_pc1",
            "wide_baseline": "time_step + specifications + all raw operational readout features",
        },
        "models": results,
        "decisions": {
            "H1_primary_beats_simple_baselines": bool(h1),
            "H2_primary_not_much_worse_than_wide_baseline": bool(h2),
            "H3_no_direct_repair_flow_claim": True,
            "primary_support": bool(h1 and h2),
        },
    }


def main() -> None:
    warnings.filterwarnings(
        "ignore",
        message=r"'multi_class' was deprecated in version 1\.5 and will be removed in 1\.7\.",
        category=FutureWarning,
        module=r"sklearn\.linear_model\._logistic",
    )
    warnings.filterwarnings(
        "ignore",
        message=r"'penalty' was deprecated in version 1\.8 and will be removed in 1\.10\..*",
        category=FutureWarning,
        module=r"sklearn\.linear_model\._logistic",
    )
    args = parse_args()
    data_dir = Path(args.data_dir)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    identities = verify_file_identities(data_dir)
    if args.metadata_only:
        payload = metadata_payload(data_dir, identities)
    elif args.validation_smoke:
        payload = validation_smoke_payload(data_dir, identities)
    else:
        payload = primary_payload(data_dir, identities)

    output_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
