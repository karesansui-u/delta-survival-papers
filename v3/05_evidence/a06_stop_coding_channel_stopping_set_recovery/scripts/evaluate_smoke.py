#!/usr/bin/env python3
"""Evaluate a pre-freeze A06-stop BEC peeling / stopping-set smoke dataset."""

from __future__ import annotations

import argparse
import csv
import json
import math
import sys
import time
from collections import defaultdict
from pathlib import Path

import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler


B0_FEATURES = [
    "q",
    "n",
    "k",
    "r",
    "rate",
    "capacity_margin",
]

B1_SIMPLE_FEATURES = B0_FEATURES + [
    "parity_check_density",
]

B1_DEGREE_FEATURES = B1_SIMPLE_FEATURES + [
    "column_weight",
    "check_degree_mean",
    "check_degree_variance",
    "check_degree_min",
    "check_degree_max",
    "variable_degree_mean",
    "variable_degree_variance",
    "variable_degree_min",
    "variable_degree_max",
    "check_degree_count_1",
    "check_degree_count_2",
    "check_degree_count_3",
    "check_degree_count_4",
    "check_degree_count_ge5",
    "variable_degree_count_1",
    "variable_degree_count_2",
    "variable_degree_count_3",
    "variable_degree_count_4",
    "variable_degree_count_ge5",
]

B1_DEGREE_HAZARD_FEATURES = B1_DEGREE_FEATURES + [
    "q_power_2",
    "q_power_3",
    "q_power_4",
    "q_power_5",
]

STOP_SCALAR_FEATURES = B1_DEGREE_FEATURES + [
    "log1p_H_stop_5",
]

STOP_NORM_SCALAR_FEATURES = B1_DEGREE_FEATURES + [
    "log1p_H_stop_5_norm",
]

STOP_TERMS_FEATURES = B1_DEGREE_FEATURES + [
    "N_stop_2_q2",
    "N_stop_3_q3",
    "N_stop_4_q4",
    "N_stop_5_q5",
]

STOP_NORM_TERMS_FEATURES = B1_DEGREE_FEATURES + [
    "N_stop_2_norm_q2",
    "N_stop_3_norm_q3",
    "N_stop_4_norm_q4",
    "N_stop_5_norm_q5",
]

ORDERWISE_NORM_TERMS = [
    "N_stop_2_norm_q2",
    "N_stop_3_norm_q3",
    "N_stop_4_norm_q4",
    "N_stop_5_norm_q5",
]

RANKDEP_FEATURES = B1_DEGREE_FEATURES + [
    "log1p_H_dep_4",
]

MODEL_FEATURES = {
    "B0": B0_FEATURES,
    "B1_simple": B1_SIMPLE_FEATURES,
    "B1_degree": B1_DEGREE_FEATURES,
    "B1_degree_hazard": B1_DEGREE_HAZARD_FEATURES,
    "B1_SP_stop_scalar": STOP_SCALAR_FEATURES,
    "B1_SP_stop_terms": STOP_TERMS_FEATURES,
    "B1_degree_SP_stop_norm_scalar": STOP_NORM_SCALAR_FEATURES,
    "B1_degree_SP_stop_norm_terms": STOP_NORM_TERMS_FEATURES,
    "B1_degree_SP_stop_orderwise_norm_terms": B1_DEGREE_FEATURES + ORDERWISE_NORM_TERMS,
    "B1_degree_hazard_SP_stop_norm_scalar": B1_DEGREE_HAZARD_FEATURES + ["log1p_H_stop_5_norm"],
    "B1_degree_hazard_SP_stop_orderwise_norm_terms": B1_DEGREE_HAZARD_FEATURES + ORDERWISE_NORM_TERMS,
    "B1_degree_rankdep": RANKDEP_FEATURES,
    "B1_degree_rankdep_SP_stop_norm_scalar": RANKDEP_FEATURES + ["log1p_H_stop_5_norm"],
    "B1_degree_rankdep_SP_stop_orderwise_norm_terms": RANKDEP_FEATURES + ORDERWISE_NORM_TERMS,
}


def log_progress(message: str) -> None:
    print(f"[a06-stop-evaluate] {message}", file=sys.stderr, flush=True)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fieldnames})


def as_float(row: dict[str, str], key: str) -> float:
    return float(row[key])


def rank_gf2(matrix: np.ndarray) -> int:
    mat = np.array(matrix, dtype=np.uint8, copy=True) & 1
    if mat.size == 0:
        return 0
    rows, cols = mat.shape
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if mat[row, col]:
                pivot = row
                break
        if pivot is None:
            continue
        if pivot != rank:
            mat[[rank, pivot]] = mat[[pivot, rank]]
        for row in range(rows):
            if row != rank and mat[row, col]:
                mat[row, :] ^= mat[rank, :]
        rank += 1
        if rank == rows:
            break
    return rank


def column_ints_to_matrix(columns: list[int], rows: int) -> np.ndarray:
    matrix = np.zeros((rows, len(columns)), dtype=np.uint8)
    for col_idx, value in enumerate(columns):
        for row_idx in range(rows):
            matrix[row_idx, col_idx] = (int(value) >> row_idx) & 1
    return matrix


def code_matrix(code_row: dict[str, str]) -> np.ndarray:
    columns = [int(value) for value in json.loads(code_row["columns"])]
    return column_ints_to_matrix(columns, int(code_row["r"]))


def peeling_residual(matrix: np.ndarray, erased: list[int]) -> list[int]:
    residual = set(erased)
    if not residual:
        return []
    supports = [set(np.flatnonzero(matrix[row, :]).tolist()) for row in range(matrix.shape[0])]
    changed = True
    while changed:
        changed = False
        for support in supports:
            unknown = support & residual
            if len(unknown) == 1:
                residual.remove(next(iter(unknown)))
                changed = True
    return sorted(residual)


def audit_samples_and_labels(
    codes: dict[str, dict[str, str]],
    samples: list[dict[str, str]],
    labels: list[dict[str, str]],
) -> dict[str, object]:
    matrices = {code_id: code_matrix(row) for code_id, row in codes.items()}
    failures_by_row: dict[str, list[int]] = defaultdict(list)
    rank_failures_by_row: dict[str, list[int]] = defaultdict(list)
    residual_sum_by_row: dict[str, int] = defaultdict(int)
    ambiguity_sum_by_row: dict[str, int] = defaultdict(int)
    audited_samples = 0

    for sample in samples:
        code_id = sample["code_id"]
        matrix = matrices[code_id]
        erased = [int(idx) for idx in json.loads(sample["erased_indices"])]
        recomputed_residual = peeling_residual(matrix, erased)
        recomputed_stop_failure = int(bool(recomputed_residual))
        recomputed_rank = rank_gf2(matrix[:, erased]) if erased else 0
        recomputed_ambiguity = len(erased) - recomputed_rank
        recomputed_rank_failure = int(recomputed_ambiguity > 0)
        observed_residual = [int(idx) for idx in json.loads(sample["peeling_residual"])]

        if recomputed_residual != observed_residual:
            raise RuntimeError(
                f"residual mismatch row_id={sample['row_id']} "
                f"sample_index={sample['sample_index']}"
            )
        if recomputed_stop_failure != int(sample["stopping_failure"]):
            raise RuntimeError(f"stopping failure mismatch for {sample['row_id']}")
        if recomputed_rank != int(sample["erased_rank"]):
            raise RuntimeError(f"rank mismatch for {sample['row_id']}")
        if recomputed_ambiguity != int(sample["ambiguity_dim"]):
            raise RuntimeError(f"ambiguity mismatch for {sample['row_id']}")
        if recomputed_rank_failure != int(sample["rank_failure"]):
            raise RuntimeError(f"rank failure mismatch for {sample['row_id']}")

        failures_by_row[sample["row_id"]].append(recomputed_stop_failure)
        rank_failures_by_row[sample["row_id"]].append(recomputed_rank_failure)
        residual_sum_by_row[sample["row_id"]] += len(recomputed_residual)
        ambiguity_sum_by_row[sample["row_id"]] += recomputed_ambiguity
        audited_samples += 1

    k_values = set()
    audited_labels = 0
    for label in labels:
        row_id = label["row_id"]
        if row_id not in failures_by_row:
            raise RuntimeError(f"label row has no samples: {row_id}")
        expected_k = len(failures_by_row[row_id])
        expected_z = sum(failures_by_row[row_id])
        expected_rank_z = sum(rank_failures_by_row[row_id])
        observed_k = int(label["K"])
        if expected_k != observed_k:
            raise RuntimeError(f"K mismatch for {row_id}: {observed_k} vs {expected_k}")
        if expected_z != int(label["z"]):
            raise RuntimeError(f"z mismatch for {row_id}")
        if expected_rank_z != int(label["rank_z"]):
            raise RuntimeError(f"rank_z mismatch for {row_id}")
        expected_residual_mean = residual_sum_by_row[row_id] / expected_k
        expected_ambiguity_mean = ambiguity_sum_by_row[row_id] / expected_k
        if abs(float(label["mean_residual_size"]) - expected_residual_mean) > 1.0e-12:
            raise RuntimeError(f"mean residual mismatch for {row_id}")
        if abs(float(label["mean_ambiguity_dim"]) - expected_ambiguity_mean) > 1.0e-12:
            raise RuntimeError(f"mean ambiguity mismatch for {row_id}")
        k_values.add(observed_k)
        audited_labels += 1

    if len(k_values) != 1:
        raise RuntimeError(f"multiple K values found: {sorted(k_values)}")

    return {
        "status": "passed",
        "audited_samples": audited_samples,
        "audited_label_rows": audited_labels,
        "K": next(iter(k_values)),
        "peeling_accounting": "failure iff residual core S_infty is nonempty",
        "rank_accounting_guardrail": "a(E)=|E|-rank_GF2(H_E); failure iff a(E)>0",
    }


def audit_split_integrity(
    codes: dict[str, dict[str, str]],
    features: list[dict[str, str]],
    samples: list[dict[str, str]],
    labels: list[dict[str, str]],
) -> dict[str, object]:
    code_splits = {code_id: row["split"] for code_id, row in codes.items()}
    row_splits: dict[str, str] = {}
    for row in features:
        code_id = row["code_id"]
        if row["split"] != code_splits.get(code_id):
            raise RuntimeError(f"feature split mismatch for row_id={row['row_id']}")
        row_splits[row["row_id"]] = row["split"]
    for label in labels:
        if label["split"] != row_splits.get(label["row_id"]):
            raise RuntimeError(f"label split mismatch for row_id={label['row_id']}")
    for sample in samples:
        if sample["split"] != row_splits.get(sample["row_id"]):
            raise RuntimeError(f"sample split mismatch for row_id={sample['row_id']}")
    counts_by_split: dict[str, int] = defaultdict(int)
    for split in code_splits.values():
        counts_by_split[split] += 1
    return {
        "status": "passed",
        "code_count_by_split": dict(sorted(counts_by_split.items())),
        "feature_row_count": len(features),
        "label_row_count": len(labels),
        "sample_row_count": len(samples),
    }


def prevalence_rows(labels: list[dict[str, str]]) -> list[dict[str, object]]:
    grouped: dict[tuple[str, str], dict[str, list[float]]] = defaultdict(lambda: defaultdict(list))
    for row in labels:
        grouped[(row["split"], row["q"])][row["code_id"]].append(float(row["failure_fraction"]))
    output: list[dict[str, object]] = []
    for (split, q_value), by_code in sorted(grouped.items()):
        code_means = [float(np.mean(values)) for values in by_code.values()]
        output.append(
            {
                "split": split,
                "q": q_value,
                "code_count": len(code_means),
                "code_balanced_prevalence": float(np.mean(code_means)),
                "min_code_prevalence": float(np.min(code_means)),
                "max_code_prevalence": float(np.max(code_means)),
            }
        )
    return output


def code_balanced_prevalence(labels: list[dict[str, str]], splits: set[str]) -> float:
    by_code: dict[str, list[float]] = defaultdict(list)
    for row in labels:
        if row["split"] in splits:
            by_code[row["code_id"]].append(float(row["failure_fraction"]))
    code_means = [float(np.mean(values)) for values in by_code.values() if values]
    return float(np.mean(code_means)) if code_means else float("nan")


def matrix(rows: list[dict[str, str]], features: list[str]) -> np.ndarray:
    return np.array([[as_float(row, feature) for feature in features] for row in rows], dtype=float)


def q_row_counts_by_code(features: list[dict[str, str]], splits: set[str]) -> dict[str, int]:
    counts: dict[str, int] = defaultdict(int)
    for row in features:
        if row["split"] in splits:
            counts[row["code_id"]] += 1
    return dict(counts)


def build_expanded_rows(
    features_by_row: dict[str, dict[str, str]],
    samples: list[dict[str, str]],
    splits: set[str],
) -> tuple[list[dict[str, str]], np.ndarray, np.ndarray]:
    feature_rows = [row for row in features_by_row.values() if row["split"] in splits]
    q_counts = q_row_counts_by_code(feature_rows, splits)
    code_ids = sorted(q_counts)
    code_count = len(code_ids)
    if code_count == 0:
        raise RuntimeError(f"no code ids for splits: {splits}")
    sample_counts: dict[str, int] = defaultdict(int)
    for sample in samples:
        if sample["split"] in splits:
            sample_counts[sample["row_id"]] += 1

    rows: list[dict[str, str]] = []
    labels: list[int] = []
    weights: list[float] = []
    for sample in samples:
        if sample["split"] not in splits:
            continue
        row = features_by_row[sample["row_id"]]
        weight = 1.0 / (
            code_count * q_counts[row["code_id"]] * sample_counts[sample["row_id"]]
        )
        rows.append(row)
        labels.append(int(sample["stopping_failure"]))
        weights.append(weight)
    return rows, np.array(labels, dtype=int), np.array(weights, dtype=float)


def feature_rows_for_split(features_by_row: dict[str, dict[str, str]], split: str) -> list[dict[str, str]]:
    return [row for row in features_by_row.values() if row["split"] == split]


def labels_for_split(labels: list[dict[str, str]], split: str) -> dict[str, dict[str, str]]:
    return {row["row_id"]: row for row in labels if row["split"] == split}


def grouped_binomial_loss(
    model: LogisticRegression,
    scaler: StandardScaler,
    feature_rows: list[dict[str, str]],
    label_by_row: dict[str, dict[str, str]],
    features: list[str],
) -> tuple[float, dict[str, float]]:
    epsilon = 1.0e-15
    x = scaler.transform(matrix(feature_rows, features))
    probs = model.predict_proba(x)[:, 1]
    losses_by_code: dict[str, list[float]] = defaultdict(list)
    for row, prob in zip(feature_rows, probs, strict=True):
        label = label_by_row[row["row_id"]]
        k_value = int(label["K"])
        z_value = int(label["z"])
        p_value = min(max(float(prob), epsilon), 1.0 - epsilon)
        loss = -(
            z_value * math.log(p_value) + (k_value - z_value) * math.log(1.0 - p_value)
        ) / k_value
        losses_by_code[row["code_id"]].append(loss)
    code_losses = {code_id: float(np.mean(losses)) for code_id, losses in losses_by_code.items()}
    return float(np.mean(list(code_losses.values()))), code_losses


def fit_model(
    train_rows: list[dict[str, str]],
    train_y: np.ndarray,
    train_w: np.ndarray,
    val_rows: list[dict[str, str]],
    val_labels: dict[str, dict[str, str]],
    features: list[str],
    c_grid: list[float],
) -> tuple[float, float]:
    if len(set(train_y.tolist())) < 2:
        raise RuntimeError("training labels contain only one class")
    x_train = matrix(train_rows, features)
    best: tuple[float, float] | None = None
    for c_value in c_grid:
        scaler = StandardScaler()
        x_scaled = scaler.fit_transform(x_train)
        model = LogisticRegression(C=c_value, solver="liblinear", max_iter=1000)
        model.fit(x_scaled, train_y, sample_weight=train_w)
        val_loss, _ = grouped_binomial_loss(model, scaler, val_rows, val_labels, features)
        if best is None or val_loss < best[0]:
            best = (val_loss, c_value)
    if best is None:
        raise RuntimeError("no model selected")
    return best[1], best[0]


def fit_fixed_c(
    rows: list[dict[str, str]],
    y: np.ndarray,
    weights: np.ndarray,
    features: list[str],
    c_value: float,
) -> tuple[StandardScaler, LogisticRegression]:
    if len(set(y.tolist())) < 2:
        raise RuntimeError("refit labels contain only one class")
    scaler = StandardScaler()
    x_scaled = scaler.fit_transform(matrix(rows, features))
    model = LogisticRegression(C=c_value, solver="liblinear", max_iter=1000)
    model.fit(x_scaled, y, sample_weight=weights)
    return scaler, model


def paired_bootstrap_positive_rate(
    base_losses: dict[str, float],
    sp_losses: dict[str, float],
    replicates: int,
    seed: int,
) -> float:
    rng = np.random.default_rng(seed)
    code_ids = sorted(set(base_losses) & set(sp_losses))
    improvements = np.array([base_losses[cid] - sp_losses[cid] for cid in code_ids], dtype=float)
    if len(improvements) == 0:
        return float("nan")
    positive = 0
    for _ in range(replicates):
        sample = rng.choice(improvements, size=len(improvements), replace=True)
        if float(np.mean(sample)) > 0.0:
            positive += 1
    return positive / replicates


def main() -> int:
    started_at = time.monotonic()
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--c-grid", default="0.01,0.1,1,10")
    parser.add_argument("--bootstrap-replicates", type=int, default=500)
    parser.add_argument("--bootstrap-seed", type=int, default=12341)
    parser.add_argument("--primary-baseline", default="B1_degree")
    parser.add_argument("--primary-model", default="B1_degree_SP_stop_norm_scalar")
    parser.add_argument("--hazard-baseline", default="B1_degree_hazard")
    parser.add_argument("--hazard-model", default="B1_degree_hazard_SP_stop_norm_scalar")
    parser.add_argument("--rankdep-baseline", default="B1_degree_rankdep")
    parser.add_argument("--rankdep-model", default="B1_degree_rankdep_SP_stop_norm_scalar")
    args = parser.parse_args()

    selected_models = [
        args.primary_baseline,
        args.primary_model,
        args.hazard_baseline,
        args.hazard_model,
        args.rankdep_baseline,
        args.rankdep_model,
    ]
    missing_models = [name for name in selected_models if name not in MODEL_FEATURES]
    if missing_models:
        raise RuntimeError(f"unknown model name(s): {', '.join(missing_models)}")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    c_grid = [float(part) for part in args.c_grid.split(",") if part]
    log_progress(f"start input={args.input_dir} output={args.output_dir} c_grid={c_grid}")

    codes = {row["code_id"]: row for row in read_csv(args.input_dir / "codes.csv")}
    features_list = read_csv(args.input_dir / "features.csv")
    samples = read_csv(args.input_dir / "erasure_samples.csv")
    labels = read_csv(args.input_dir / "labels.csv")
    features_by_row = {row["row_id"]: row for row in features_list}
    log_progress(
        f"loaded codes={len(codes)} features={len(features_list)} "
        f"samples={len(samples)} labels={len(labels)}"
    )

    split_audit = audit_split_integrity(codes, features_list, samples, labels)
    log_progress(f"split audit {split_audit['status']} {split_audit['code_count_by_split']}")
    label_audit = audit_samples_and_labels(codes, samples, labels)
    log_progress(
        f"label/sample audit {label_audit['status']} "
        f"samples={label_audit['audited_samples']} labels={label_audit['audited_label_rows']}"
    )
    test_prevalence = code_balanced_prevalence(labels, {"test"})
    endpoint_degenerate = test_prevalence < 0.02 or test_prevalence > 0.98
    log_progress(
        f"test prevalence={test_prevalence:.6f} endpoint_degenerate={endpoint_degenerate}"
    )

    train_rows, train_y, train_w = build_expanded_rows(features_by_row, samples, {"train"})
    train_val_rows, train_val_y, train_val_w = build_expanded_rows(
        features_by_row, samples, {"train", "validation"}
    )
    val_rows = feature_rows_for_split(features_by_row, "validation")
    test_rows = feature_rows_for_split(features_by_row, "test")
    val_labels = labels_for_split(labels, "validation")
    test_labels = labels_for_split(labels, "test")

    metric_rows: list[dict[str, object]] = []
    code_loss_by_model: dict[str, dict[str, float]] = {}
    for model_name, model_features in MODEL_FEATURES.items():
        log_progress(f"fit model={model_name} features={len(model_features)}")
        c_value, val_loss = fit_model(
            train_rows,
            train_y,
            train_w,
            val_rows,
            val_labels,
            model_features,
            c_grid,
        )
        scaler, model = fit_fixed_c(
            train_val_rows,
            train_val_y,
            train_val_w,
            model_features,
            c_value,
        )
        test_loss, code_losses = grouped_binomial_loss(
            model, scaler, test_rows, test_labels, model_features
        )
        code_loss_by_model[model_name] = code_losses
        metric_rows.append(
            {
                "model": model_name,
                "feature_count": len(model_features),
                "selected_C": c_value,
                "validation_code_grouped_log_loss": val_loss,
                "test_code_grouped_log_loss": test_loss,
            }
        )
        log_progress(
            f"model done={model_name} C={c_value} "
            f"val={val_loss:.6f} test={test_loss:.6f}"
        )

    metrics = {row["model"]: row for row in metric_rows}
    b1_loss = float(metrics[args.primary_baseline]["test_code_grouped_log_loss"])
    sp_loss = float(metrics[args.primary_model]["test_code_grouped_log_loss"])
    relative_improvement = (b1_loss - sp_loss) / b1_loss if b1_loss > 0 else float("nan")
    bootstrap_positive_rate = paired_bootstrap_positive_rate(
        code_loss_by_model[args.primary_baseline],
        code_loss_by_model[args.primary_model],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )

    hazard_loss = float(metrics[args.hazard_baseline]["test_code_grouped_log_loss"])
    hazard_sp_loss = float(metrics[args.hazard_model]["test_code_grouped_log_loss"])
    hazard_relative_improvement = (
        (hazard_loss - hazard_sp_loss) / hazard_loss if hazard_loss > 0 else float("nan")
    )
    hazard_bootstrap_positive_rate = paired_bootstrap_positive_rate(
        code_loss_by_model[args.hazard_baseline],
        code_loss_by_model[args.hazard_model],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )

    rankdep_loss = float(metrics[args.rankdep_baseline]["test_code_grouped_log_loss"])
    rankdep_sp_loss = float(metrics[args.rankdep_model]["test_code_grouped_log_loss"])
    rankdep_relative_improvement = (
        (rankdep_loss - rankdep_sp_loss) / rankdep_loss if rankdep_loss > 0 else float("nan")
    )
    rankdep_bootstrap_positive_rate = paired_bootstrap_positive_rate(
        code_loss_by_model[args.rankdep_baseline],
        code_loss_by_model[args.rankdep_model],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )

    primary_smoke_gate_would_pass = (
        sp_loss < b1_loss
        and relative_improvement >= 0.01
        and bootstrap_positive_rate >= 0.90
        and not endpoint_degenerate
        and label_audit["status"] == "passed"
        and split_audit["status"] == "passed"
    )
    clean_guardrails_would_pass = (
        hazard_sp_loss < hazard_loss
        and hazard_bootstrap_positive_rate >= 0.90
        and rankdep_sp_loss < rankdep_loss
        and rankdep_bootstrap_positive_rate >= 0.90
    )

    write_csv(
        args.output_dir / "model_metrics.csv",
        metric_rows,
        [
            "model",
            "feature_count",
            "selected_C",
            "validation_code_grouped_log_loss",
            "test_code_grouped_log_loss",
        ],
    )
    write_csv(
        args.output_dir / "prevalence_by_q_split.csv",
        prevalence_rows(labels),
        [
            "split",
            "q",
            "code_count",
            "code_balanced_prevalence",
            "min_code_prevalence",
            "max_code_prevalence",
        ],
    )
    write_csv(
        args.output_dir / "guardrail_summary.csv",
        [
            {
                "comparison": "primary",
                "baseline": args.primary_baseline,
                "model": args.primary_model,
                "baseline_test_log_loss": b1_loss,
                "model_test_log_loss": sp_loss,
                "relative_log_loss_improvement": relative_improvement,
                "bootstrap_positive_rate": bootstrap_positive_rate,
            },
            {
                "comparison": "hazard_guardrail",
                "baseline": args.hazard_baseline,
                "model": args.hazard_model,
                "baseline_test_log_loss": hazard_loss,
                "model_test_log_loss": hazard_sp_loss,
                "relative_log_loss_improvement": hazard_relative_improvement,
                "bootstrap_positive_rate": hazard_bootstrap_positive_rate,
            },
            {
                "comparison": "rankdep_guardrail",
                "baseline": args.rankdep_baseline,
                "model": args.rankdep_model,
                "baseline_test_log_loss": rankdep_loss,
                "model_test_log_loss": rankdep_sp_loss,
                "relative_log_loss_improvement": rankdep_relative_improvement,
                "bootstrap_positive_rate": rankdep_bootstrap_positive_rate,
            },
        ],
        [
            "comparison",
            "baseline",
            "model",
            "baseline_test_log_loss",
            "model_test_log_loss",
            "relative_log_loss_improvement",
            "bootstrap_positive_rate",
        ],
    )

    summary = {
        "status": "smoke_evaluated_not_evidence",
        "notes": [
            "Smoke output is not validation evidence.",
            "Primary scoring used code-id grouped binomial log loss.",
            "Peeling residual is used for label/accounting audit, not as a prediction feature.",
        ],
        "primary_model": args.primary_model,
        "primary_baseline": args.primary_baseline,
        "primary_baseline_test_log_loss": b1_loss,
        "primary_model_test_log_loss": sp_loss,
        "relative_log_loss_improvement": relative_improvement,
        "bootstrap_positive_rate": bootstrap_positive_rate,
        "hazard_baseline": args.hazard_baseline,
        "hazard_model": args.hazard_model,
        "hazard_baseline_test_log_loss": hazard_loss,
        "hazard_model_test_log_loss": hazard_sp_loss,
        "hazard_guardrail_relative_log_loss_improvement": hazard_relative_improvement,
        "hazard_guardrail_bootstrap_positive_rate": hazard_bootstrap_positive_rate,
        "rankdep_baseline": args.rankdep_baseline,
        "rankdep_model": args.rankdep_model,
        "rankdep_baseline_test_log_loss": rankdep_loss,
        "rankdep_model_test_log_loss": rankdep_sp_loss,
        "rankdep_guardrail_relative_log_loss_improvement": rankdep_relative_improvement,
        "rankdep_guardrail_bootstrap_positive_rate": rankdep_bootstrap_positive_rate,
        "primary_smoke_gate_would_pass": primary_smoke_gate_would_pass,
        "smoke_support_rule_would_pass": primary_smoke_gate_would_pass,
        "smoke_support_rule_name_note": (
            "Legacy alias for primary_smoke_gate_would_pass; guardrails are "
            "reported separately and are not included in this value."
        ),
        "clean_guardrails_would_pass": clean_guardrails_would_pass,
        "endpoint_degenerate": endpoint_degenerate,
        "test_code_balanced_prevalence": test_prevalence,
        "bootstrap_replicates": args.bootstrap_replicates,
        "bootstrap_seed": args.bootstrap_seed,
        "label_sample_audit": label_audit,
        "split_integrity_audit": split_audit,
        "elapsed_s": time.monotonic() - started_at,
    }
    (args.output_dir / "evaluation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    log_progress(f"done elapsed_s={time.monotonic() - started_at:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
