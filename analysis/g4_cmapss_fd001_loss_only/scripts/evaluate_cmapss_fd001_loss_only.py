#!/usr/bin/env python3
"""C-MAPSS FD001 loss-only evaluation script.

Modes:
- --metadata-only: archive / parser / structural facts only
- --train-smoke:   train-side integration smoke; no held-out metrics
- --allow-primary-run: full held-out evaluation on the frozen FD001 test units

This script intentionally contains no repair-flow logic.
"""

from __future__ import annotations

import argparse
import io
import json
import hashlib
import warnings
import zipfile
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss, roc_auc_score
from sklearn.preprocessing import StandardScaler


ARCHIVE_SHA256 = "74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f"
SUBSET = "FD001"
TRAIN_FILE = "train_FD001.txt"
TEST_FILE = "test_FD001.txt"
RUL_FILE = "RUL_FD001.txt"
HORIZON_CYCLES = 50
RANDOM_SEED = 43001
LOGREG_KWARGS = {
    "penalty": "l2",
    "solver": "lbfgs",
    "C": 1.0,
    "max_iter": 1000,
    "class_weight": None,
    "random_state": RANDOM_SEED,
}

warnings.filterwarnings(
    "ignore",
    message=r"'penalty' was deprecated in version 1\.8.*",
    category=FutureWarning,
    module=r"sklearn\.linear_model\._logistic",
)

SETTING_COLUMNS = ["setting_1", "setting_2", "setting_3"]
SENSOR_COLUMNS = [f"sensor_{i}" for i in range(1, 22)]
NONCONSTANT_SENSORS = [
    "sensor_2",
    "sensor_3",
    "sensor_4",
    "sensor_6",
    "sensor_7",
    "sensor_8",
    "sensor_9",
    "sensor_11",
    "sensor_12",
    "sensor_13",
    "sensor_14",
    "sensor_15",
    "sensor_17",
    "sensor_20",
    "sensor_21",
]
CONSTANT_SENSORS = [
    "sensor_1",
    "sensor_5",
    "sensor_10",
    "sensor_16",
    "sensor_18",
    "sensor_19",
]


@dataclass(frozen=True)
class StructuralBundle:
    archive_path: str
    archive_sha256: str
    train_rows: int
    train_units: int
    test_rows: int
    test_units: int
    test_positive_units: int
    test_negative_units: int


@dataclass(frozen=True)
class TrainBundle:
    meta: StructuralBundle
    train: pd.DataFrame


@dataclass(frozen=True)
class PrimaryBundle:
    meta: StructuralBundle
    train: pd.DataFrame
    test_final: pd.DataFrame


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, help="Path to CMAPSSData.zip")
    parser.add_argument("--output", required=True, help="JSON output path")
    parser.add_argument(
        "--report-output",
        default=None,
        help="Optional markdown report path; defaults to JSON path with .md suffix during primary runs",
    )
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="Emit only archive identity and structural facts; no model fitting.",
    )
    parser.add_argument(
        "--train-smoke",
        action="store_true",
        help="Run train-side parser / PCA / model-fit integration smoke without held-out evaluation.",
    )
    parser.add_argument(
        "--allow-primary-run",
        action="store_true",
        help="Enable the held-out FD001 test-unit evaluation. Use only after freeze.",
    )
    args = parser.parse_args()
    selected = [args.metadata_only, args.train_smoke, args.allow_primary_run]
    if sum(bool(x) for x in selected) != 1:
        raise SystemExit("Choose exactly one mode: --metadata-only, --train-smoke, or --allow-primary-run.")
    return args


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def cmapps_columns() -> list[str]:
    return ["unit_id", "cycle", *SETTING_COLUMNS, *SENSOR_COLUMNS]


def read_table_from_zip(archive: zipfile.ZipFile, filename: str) -> pd.DataFrame:
    with archive.open(filename) as handle:
        frame = pd.read_csv(
            io.TextIOWrapper(handle, encoding="utf-8", newline=""),
            sep=r"\s+",
            header=None,
            engine="python",
        )
    if frame.shape[1] != 26:
        raise SystemExit(f"{filename} expected 26 columns, found {frame.shape[1]}")
    frame.columns = cmapps_columns()
    return frame


def read_rul_from_zip(archive: zipfile.ZipFile, filename: str) -> pd.Series:
    with archive.open(filename) as handle:
        frame = pd.read_csv(
            io.TextIOWrapper(handle, encoding="utf-8", newline=""),
            sep=r"\s+",
            header=None,
            engine="python",
        )
    if frame.shape[1] == 0:
        raise SystemExit(f"{filename} is empty.")
    series = pd.to_numeric(frame.iloc[:, 0], errors="raise")
    return series


def validate_archive_sha256(archive_path: Path) -> str:
    archive_sha256 = sha256_file(archive_path)
    if archive_sha256 != ARCHIVE_SHA256:
        raise SystemExit(
            f"Archive sha256 mismatch: expected {ARCHIVE_SHA256}, observed {archive_sha256}"
        )
    return archive_sha256


def load_structural_bundle(archive_path: Path) -> StructuralBundle:
    archive_sha256 = validate_archive_sha256(archive_path)

    with zipfile.ZipFile(archive_path) as archive:
        names = set(archive.namelist())
        for required in (TRAIN_FILE, TEST_FILE, RUL_FILE):
            if required not in names:
                raise SystemExit(f"Missing required archive entry: {required}")

        train = read_table_from_zip(archive, TRAIN_FILE)
        test = read_table_from_zip(archive, TEST_FILE)
        rul = read_rul_from_zip(archive, RUL_FILE)

    test = test.copy()
    test["unit_id"] = test["unit_id"].astype(int)
    test["cycle"] = test["cycle"].astype(int)
    final_idx = test.groupby("unit_id")["cycle"].idxmax()
    test_final = test.loc[final_idx].sort_values("unit_id").reset_index(drop=True)
    unique_units = sorted(test_final["unit_id"].tolist())
    if len(unique_units) != len(rul):
        raise SystemExit(
            f"Test-unit count ({len(unique_units)}) does not match RUL targets ({len(rul)})."
        )
    test_final["rul_test"] = rul.to_numpy(dtype=int)
    test_final["event_50"] = (test_final["rul_test"] <= HORIZON_CYCLES).astype(int)

    return StructuralBundle(
        archive_path=str(archive_path),
        archive_sha256=archive_sha256,
        train_rows=int(len(train)),
        train_units=int(train["unit_id"].nunique()),
        test_rows=int(len(test)),
        test_units=int(test["unit_id"].nunique()),
        test_positive_units=int(test_final["event_50"].sum()),
        test_negative_units=int((1 - test_final["event_50"]).sum()),
    )


def load_train_bundle(archive_path: Path) -> TrainBundle:
    archive_sha256 = validate_archive_sha256(archive_path)
    with zipfile.ZipFile(archive_path) as archive:
        names = set(archive.namelist())
        if TRAIN_FILE not in names:
            raise SystemExit(f"Missing required archive entry: {TRAIN_FILE}")
        train = read_table_from_zip(archive, TRAIN_FILE)

    train = train.copy()
    train["unit_id"] = train["unit_id"].astype(int)
    train["cycle"] = train["cycle"].astype(int)
    final_cycle = train.groupby("unit_id")["cycle"].transform("max")
    train["rul_train"] = final_cycle - train["cycle"]
    train["event_50"] = (train["rul_train"] <= HORIZON_CYCLES).astype(int)
    meta = StructuralBundle(
        archive_path=str(archive_path),
        archive_sha256=archive_sha256,
        train_rows=int(len(train)),
        train_units=int(train["unit_id"].nunique()),
        test_rows=0,
        test_units=0,
        test_positive_units=0,
        test_negative_units=0,
    )
    return TrainBundle(meta=meta, train=train)


def load_primary_bundle(archive_path: Path) -> PrimaryBundle:
    meta = load_structural_bundle(archive_path)
    with zipfile.ZipFile(archive_path) as archive:
        train = read_table_from_zip(archive, TRAIN_FILE)
        test = read_table_from_zip(archive, TEST_FILE)
        rul = read_rul_from_zip(archive, RUL_FILE)

    train = train.copy()
    train["unit_id"] = train["unit_id"].astype(int)
    train["cycle"] = train["cycle"].astype(int)
    final_cycle = train.groupby("unit_id")["cycle"].transform("max")
    train["rul_train"] = final_cycle - train["cycle"]
    train["event_50"] = (train["rul_train"] <= HORIZON_CYCLES).astype(int)

    test = test.copy()
    test["unit_id"] = test["unit_id"].astype(int)
    test["cycle"] = test["cycle"].astype(int)
    final_idx = test.groupby("unit_id")["cycle"].idxmax()
    test_final = test.loc[final_idx].sort_values("unit_id").reset_index(drop=True)
    if len(test_final) != len(rul):
        raise SystemExit(
            f"Test-unit count ({len(test_final)}) does not match RUL targets ({len(rul)})."
        )
    test_final["rul_test"] = rul.to_numpy(dtype=int)
    test_final["event_50"] = (test_final["rul_test"] <= HORIZON_CYCLES).astype(int)
    return PrimaryBundle(meta=meta, train=train, test_final=test_final)


def prevalence(labels: pd.Series | np.ndarray) -> float:
    values = np.asarray(labels, dtype=float)
    return float(values.mean()) if values.size else 0.0


def fit_d_pc1_train_only(train: pd.DataFrame) -> tuple[np.ndarray, StandardScaler, PCA, float, float]:
    scaler = StandardScaler()
    train_sensors = scaler.fit_transform(train[NONCONSTANT_SENSORS].to_numpy(dtype=float))
    pca = PCA(n_components=1)
    train_pc1 = pca.fit_transform(train_sensors).reshape(-1)
    raw_corr = float(np.corrcoef(train_pc1, train["cycle"].to_numpy(dtype=float))[0, 1])
    sign = -1.0 if raw_corr < 0 else 1.0
    return train_pc1 * sign, scaler, pca, sign, raw_corr * sign


def transform_d_pc1_test(test_final: pd.DataFrame, scaler: StandardScaler, pca: PCA, sign: float) -> np.ndarray:
    test_sensors = scaler.transform(test_final[NONCONSTANT_SENSORS].to_numpy(dtype=float))
    test_pc1 = pca.transform(test_sensors).reshape(-1)
    return test_pc1 * sign


def matrix_for_model_train_only(
    train: pd.DataFrame,
    kind: str,
    train_d_pc1: np.ndarray | None,
) -> tuple[np.ndarray, list[str]]:
    if kind == "B1":
        cols = ["cycle"]
        train_x = train[cols].to_numpy(dtype=float)
        return train_x, cols
    if kind == "B2":
        cols = SETTING_COLUMNS.copy()
        train_x = train[cols].to_numpy(dtype=float)
        return train_x, cols
    if kind == "B3":
        cols = ["cycle", *SETTING_COLUMNS]
        train_x = train[cols].to_numpy(dtype=float)
        return train_x, cols
    if kind == "B4":
        cols = ["cycle", *SETTING_COLUMNS, *NONCONSTANT_SENSORS]
        train_x = train[cols].to_numpy(dtype=float)
        return train_x, cols
    if kind == "primary":
        if train_d_pc1 is None:
            raise SystemExit("Primary model requested without D_pc1 arrays.")
        cols = ["cycle", *SETTING_COLUMNS, "D_pc1"]
        train_x = np.column_stack(
            [train["cycle"].to_numpy(dtype=float), train[SETTING_COLUMNS].to_numpy(dtype=float), train_d_pc1]
        )
        return train_x, cols
    raise SystemExit(f"Unknown model kind: {kind}")


def matrix_for_model(
    train: pd.DataFrame,
    test_final: pd.DataFrame,
    kind: str,
    train_d_pc1: np.ndarray | None,
    test_d_pc1: np.ndarray | None,
) -> tuple[np.ndarray, np.ndarray, list[str]]:
    train_x, cols = matrix_for_model_train_only(train, kind, train_d_pc1)
    if kind == "B1":
        test_x = test_final[["cycle"]].to_numpy(dtype=float)
        return train_x, test_x, cols
    if kind == "B2":
        test_x = test_final[SETTING_COLUMNS].to_numpy(dtype=float)
        return train_x, test_x, cols
    if kind == "B3":
        test_x = test_final[["cycle", *SETTING_COLUMNS]].to_numpy(dtype=float)
        return train_x, test_x, cols
    if kind == "B4":
        test_x = test_final[["cycle", *SETTING_COLUMNS, *NONCONSTANT_SENSORS]].to_numpy(dtype=float)
        return train_x, test_x, cols
    if kind == "primary":
        if test_d_pc1 is None:
            raise SystemExit("Primary model requested without test D_pc1.")
        test_x = np.column_stack(
            [test_final["cycle"].to_numpy(dtype=float), test_final[SETTING_COLUMNS].to_numpy(dtype=float), test_d_pc1]
        )
        return train_x, test_x, cols
    raise SystemExit(f"Unknown model kind: {kind}")


def fit_logistic(train_x: np.ndarray, train_y: np.ndarray) -> tuple[LogisticRegression, StandardScaler]:
    scaler = StandardScaler()
    train_scaled = scaler.fit_transform(train_x)
    model = LogisticRegression(**LOGREG_KWARGS)
    model.fit(train_scaled, train_y)
    return model, scaler


def predict_probability(model: LogisticRegression, scaler: StandardScaler, x: np.ndarray) -> np.ndarray:
    return model.predict_proba(scaler.transform(x))[:, 1]


def metrics_dict(y_true: np.ndarray, y_prob: np.ndarray) -> dict[str, float]:
    return {
        "log_loss": float(log_loss(y_true, y_prob, labels=[0, 1])),
        "brier": float(np.mean((y_prob - y_true) ** 2)),
        "auc": float(roc_auc_score(y_true, y_prob)),
        "accuracy_at_0_5": float(accuracy_score(y_true, (y_prob >= 0.5).astype(int))),
    }


def metadata_payload(bundle: StructuralBundle) -> dict:
    return {
        "mode": "metadata_only",
        "archive": {
            "path": bundle.archive_path,
            "sha256": bundle.archive_sha256,
            "subset": SUBSET,
        },
        "structure": {
            "train_rows": bundle.train_rows,
            "train_units": bundle.train_units,
            "test_rows": bundle.test_rows,
            "test_units": bundle.test_units,
            "test_positive_units_h50": bundle.test_positive_units,
            "test_negative_units_h50": bundle.test_negative_units,
            "expected_nonconstant_sensors": NONCONSTANT_SENSORS,
            "expected_constant_sensors": CONSTANT_SENSORS,
        },
    }


def train_smoke_payload(bundle: TrainBundle) -> dict:
    train = bundle.train.copy()
    train_y = train["event_50"].to_numpy(dtype=int)
    train_d_pc1, _, _, _, oriented_corr = fit_d_pc1_train_only(train)

    fit_status = {}
    feature_dims = {}
    for kind in ("B1", "B2", "B3", "B4", "primary"):
        train_x, cols = matrix_for_model_train_only(train, kind, train_d_pc1)
        model, scaler = fit_logistic(train_x, train_y)
        _ = model
        _ = scaler
        fit_status[kind] = True
        feature_dims[kind] = len(cols)

    return {
        "mode": "train_smoke",
        "archive": {
            "path": bundle.meta.archive_path,
            "sha256": bundle.meta.archive_sha256,
            "subset": SUBSET,
        },
        "structure": {
            "train_rows": bundle.meta.train_rows,
            "train_units": bundle.meta.train_units,
        },
        "train_only": {
            "positive_rows_h50": int(train_y.sum()),
            "negative_rows_h50": int((1 - train_y).sum()),
            "training_prevalence_h50": prevalence(train_y),
            "oriented_corr_d_pc1_cycle_train": oriented_corr,
            "fit_status": fit_status,
            "feature_dims": feature_dims,
        },
        "no_peek": {
            "held_out_test_files_loaded_by_train_smoke": False,
            "held_out_test_feature_construction_performed": False,
            "held_out_test_metrics_recorded": False,
            "held_out_test_predictions_recorded": False,
        },
    }


def primary_payload(bundle: PrimaryBundle) -> dict:
    train = bundle.train.copy()
    test_final = bundle.test_final.copy()
    train_y = train["event_50"].to_numpy(dtype=int)
    test_y = test_final["event_50"].to_numpy(dtype=int)
    train_d_pc1, scaler_d_pc1, pca_d_pc1, sign_d_pc1, oriented_corr = fit_d_pc1_train_only(train)
    test_d_pc1 = transform_d_pc1_test(test_final, scaler_d_pc1, pca_d_pc1, sign_d_pc1)

    results = {
        "mode": "primary",
        "archive": {
            "path": bundle.meta.archive_path,
            "sha256": bundle.meta.archive_sha256,
            "subset": SUBSET,
        },
        "structure": {
            "train_rows": bundle.meta.train_rows,
            "train_units": bundle.meta.train_units,
            "test_rows": bundle.meta.test_rows,
            "test_units": bundle.meta.test_units,
            "test_positive_units_h50": bundle.meta.test_positive_units,
            "test_negative_units_h50": bundle.meta.test_negative_units,
        },
        "model_class": {
            "family": "sklearn LogisticRegression",
            **LOGREG_KWARGS,
        },
        "coordinate": {
            "name": "D_pc1",
            "nonconstant_sensors": NONCONSTANT_SENSORS,
            "constant_sensors": CONSTANT_SENSORS,
            "oriented_corr_d_pc1_cycle_train": oriented_corr,
        },
        "models": {},
    }

    train_prevalence = prevalence(train_y)
    b0_prob = np.full_like(test_y, fill_value=train_prevalence, dtype=float)
    results["models"]["B0"] = {
        "features": ["constant_prevalence"],
        "metrics": metrics_dict(test_y, b0_prob),
        "training_prevalence_h50": train_prevalence,
    }

    trained = {}
    for kind in ("B1", "B2", "B3", "B4", "primary"):
        train_x, test_x, cols = matrix_for_model(train, test_final, kind, train_d_pc1, test_d_pc1)
        model, scaler = fit_logistic(train_x, train_y)
        y_prob = predict_probability(model, scaler, test_x)
        entry = {
            "features": cols,
            "metrics": metrics_dict(test_y, y_prob),
            "coefficients": {name: float(value) for name, value in zip(cols, model.coef_.ravel(), strict=True)},
            "intercept": float(model.intercept_[0]),
        }
        results["models"][kind] = entry
        trained[kind] = entry

    best_simple = min(
        results["models"][name]["metrics"]["log_loss"] for name in ("B1", "B2", "B3")
    )
    primary_logloss = results["models"]["primary"]["metrics"]["log_loss"]
    b4_logloss = results["models"]["B4"]["metrics"]["log_loss"]
    beta_d_pc1 = results["models"]["primary"]["coefficients"]["D_pc1"]

    h1 = primary_logloss <= 0.95 * best_simple
    h2 = primary_logloss <= 1.10 * b4_logloss
    h3 = beta_d_pc1 >= 0.0

    results["decisions"] = {
        "H1_loss_only_support": bool(h1),
        "H2_compression_guardrail": bool(h2),
        "H3_direction_consistency": bool(h3),
        "H4_no_repair_flow_claim": True,
        "primary_support": bool(h1 and h2 and h3),
        "relative_improvement_vs_best_simple": float(1.0 - (primary_logloss / best_simple)),
        "relative_gap_vs_B4": float((primary_logloss / b4_logloss) - 1.0),
    }
    return results


def markdown_report(payload: dict) -> str:
    if payload["mode"] != "primary":
        raise SystemExit("Markdown report is only defined for primary mode.")
    lines = [
        "# G4 C-MAPSS FD001 Loss-Only Primary Report",
        "",
        "Status: frozen-style primary report draft produced by the execution script.",
        "",
        "## Result",
        "",
        f"- `primary_support`: `{str(payload['decisions']['primary_support']).lower()}`",
        f"- `H1_loss_only_support`: `{str(payload['decisions']['H1_loss_only_support']).lower()}`",
        f"- `H2_compression_guardrail`: `{str(payload['decisions']['H2_compression_guardrail']).lower()}`",
        f"- `H3_direction_consistency`: `{str(payload['decisions']['H3_direction_consistency']).lower()}`",
        "",
        "## Held-Out Log Loss",
        "",
        "| model | log loss |",
        "|---|---:|",
    ]
    for name in ("B0", "B1", "B2", "B3", "B4", "primary"):
        lines.append(f"| `{name}` | `{payload['models'][name]['metrics']['log_loss']:.9f}` |")
    lines.extend(
        [
            "",
            "## Boundary",
            "",
            "- This branch is loss-only (`r_t = 0`).",
            "- It is not repair-flow evidence.",
            "- It is not evidence equal in strength to randomized Route A primaries.",
        ]
    )
    return "\n".join(lines) + "\n"


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def main() -> None:
    args = parse_args()
    archive_path = Path(args.archive)
    output_path = Path(args.output)
    ensure_parent(output_path)

    if args.metadata_only:
        bundle = load_structural_bundle(archive_path)
        payload = metadata_payload(bundle)
    elif args.train_smoke:
        bundle = load_train_bundle(archive_path)
        payload = train_smoke_payload(bundle)
    else:
        bundle = load_primary_bundle(archive_path)
        payload = primary_payload(bundle)

    output_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    if args.allow_primary_run:
        report_path = Path(args.report_output) if args.report_output else output_path.with_suffix(".md")
        ensure_parent(report_path)
        report_path.write_text(markdown_report(payload), encoding="utf-8")


if __name__ == "__main__":
    main()
