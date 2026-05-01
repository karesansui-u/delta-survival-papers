#!/usr/bin/env python3
"""Evaluate an A12 s-t cut-spectrum reliability dataset.

By default this is a smoke harness. It becomes support-bearing only when its
path, content hash, command, seeds, and output directory are pinned by a frozen
manifest before outcome-bearing execution.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import sys
import time
from collections import defaultdict, deque
from pathlib import Path

import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler


B0_FEATURES = [
    "q",
    "n",
    "m",
    "edge_density",
    "mean_degree",
]

B1_FEATURES = B0_FEATURES + [
    "degree_s",
    "degree_t",
    "degree_variance",
    "kappa",
    "shortest_st_path_length",
    "bridge_count",
]

B1_HAZARD_FEATURES = B1_FEATURES + [
    "q_power_kappa",
    "q_power_kappa_plus_1",
    "q_power_kappa_plus_2",
]

SP_TERMS_FEATURES = B1_FEATURES + [
    "N_kappa_q_kappa",
    "N_kappa_plus_1_q",
    "N_kappa_plus_2_q",
]

SP_SCALAR_FEATURES = B1_FEATURES + [
    "log1p_H_cut_2",
]

SP_FEATURES = SP_TERMS_FEATURES + [
    "log1p_H_cut_2",
]

B2_FEATURES = B1_FEATURES + [
    "algebraic_connectivity",
    "laplacian_spectral_radius",
    "effective_resistance_st",
    "betweenness_mean",
    "betweenness_max",
    "betweenness_std",
]

MODEL_FEATURES = {
    "B0": B0_FEATURES,
    "B1": B1_FEATURES,
    "B1_hazard": B1_HAZARD_FEATURES,
    "B1_SP_scalar": SP_SCALAR_FEATURES,
    "B1_SP_terms": SP_TERMS_FEATURES,
    "B1_SP_bundle": SP_FEATURES,
    "B1_hazard_SP_scalar": B1_HAZARD_FEATURES + ["log1p_H_cut_2"],
    "B2_guardrail": B2_FEATURES,
}


def log_progress(message: str) -> None:
    print(f"[a12-evaluate] {message}", file=sys.stderr, flush=True)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({name: row.get(name, "") for name in fieldnames})


def as_float(row: dict[str, str], key: str) -> float:
    return float(row[key])


def norm_edge(edge: tuple[int, int]) -> tuple[int, int]:
    u, v = edge
    return (u, v) if u < v else (v, u)


def st_connected_without(
    adjacency: dict[int, list[int]],
    removed: set[tuple[int, int]],
    source: int,
    target: int,
) -> bool:
    seen = {source}
    queue: deque[int] = deque([source])
    while queue:
        node = queue.popleft()
        for nbr in adjacency[node]:
            if norm_edge((node, nbr)) in removed:
                continue
            if nbr == target:
                return True
            if nbr not in seen:
                seen.add(nbr)
                queue.append(nbr)
    return source == target


def graph_adjacency(graph_row: dict[str, str]) -> tuple[list[tuple[int, int]], dict[int, list[int]], int, int]:
    edges = [tuple(edge) for edge in json.loads(graph_row["edges"])]
    adjacency: dict[int, list[int]] = defaultdict(list)
    for u, v in edges:
        adjacency[int(u)].append(int(v))
        adjacency[int(v)].append(int(u))
    source = int(graph_row["source"])
    target = int(graph_row["target"])
    return [(int(u), int(v)) for u, v in edges], dict(adjacency), source, target


def audit_samples_and_labels(
    graphs: dict[str, dict[str, str]],
    samples: list[dict[str, str]],
    labels: list[dict[str, str]],
) -> dict[str, object]:
    graph_cache = {
        graph_id: graph_adjacency(row) for graph_id, row in graphs.items()
    }
    disconnected_by_row: dict[str, list[int]] = defaultdict(list)
    audited_samples = 0
    for sample in samples:
        graph_id = sample["graph_id"]
        edges, adjacency, source, target = graph_cache[graph_id]
        failed_indices = [int(idx) for idx in json.loads(sample["failed_edge_indices"])]
        removed = {edges[idx] for idx in failed_indices}
        recomputed = int(not st_connected_without(adjacency, removed, source, target))
        observed = int(sample["disconnected"])
        if recomputed != observed:
            raise RuntimeError(
                f"sample label mismatch for row_id={sample['row_id']} "
                f"sample_index={sample['sample_index']}: observed={observed}, "
                f"recomputed={recomputed}"
            )
        disconnected_by_row[sample["row_id"]].append(observed)
        audited_samples += 1

    k_values = set()
    audited_labels = 0
    for label in labels:
        row_id = label["row_id"]
        if row_id not in disconnected_by_row:
            raise RuntimeError(f"label row has no samples: {row_id}")
        expected_k = len(disconnected_by_row[row_id])
        expected_z = sum(disconnected_by_row[row_id])
        observed_k = int(label["K"])
        observed_z = int(label["z"])
        if expected_k != observed_k:
            raise RuntimeError(f"K mismatch for {row_id}: {observed_k} vs {expected_k}")
        if expected_z != observed_z:
            raise RuntimeError(f"z mismatch for {row_id}: {observed_z} vs {expected_z}")
        k_values.add(observed_k)
        audited_labels += 1

    if len(k_values) != 1:
        raise RuntimeError(f"multiple K values found: {sorted(k_values)}")

    return {
        "status": "passed",
        "audited_samples": audited_samples,
        "audited_label_rows": audited_labels,
        "K": next(iter(k_values)),
    }


def audit_split_integrity(
    graphs: dict[str, dict[str, str]],
    features: list[dict[str, str]],
    samples: list[dict[str, str]],
    labels: list[dict[str, str]],
) -> dict[str, object]:
    graph_splits = {graph_id: row["split"] for graph_id, row in graphs.items()}
    row_splits: dict[str, str] = {}
    for row in features:
        graph_id = row["graph_id"]
        if graph_id not in graph_splits:
            raise RuntimeError(f"feature row has unknown graph_id: {graph_id}")
        if row["split"] != graph_splits[graph_id]:
            raise RuntimeError(f"feature split mismatch for row_id={row['row_id']}")
        row_splits[row["row_id"]] = row["split"]
    for label in labels:
        row_id = label["row_id"]
        if row_id not in row_splits:
            raise RuntimeError(f"label row has unknown row_id: {row_id}")
        if label["split"] != row_splits[row_id]:
            raise RuntimeError(f"label split mismatch for row_id={row_id}")
    for sample in samples:
        row_id = sample["row_id"]
        if row_id not in row_splits:
            raise RuntimeError(f"sample row has unknown row_id: {row_id}")
        if sample["split"] != row_splits[row_id]:
            raise RuntimeError(f"sample split mismatch for row_id={row_id}")
    counts_by_split: dict[str, int] = defaultdict(int)
    for split in graph_splits.values():
        counts_by_split[split] += 1
    return {
        "status": "passed",
        "graph_count_by_split": dict(sorted(counts_by_split.items())),
        "feature_row_count": len(features),
        "label_row_count": len(labels),
        "sample_row_count": len(samples),
    }


def graph_balanced_prevalence(labels: list[dict[str, str]], splits: set[str]) -> float:
    by_graph: dict[str, list[float]] = defaultdict(list)
    for row in labels:
        if row["split"] in splits:
            by_graph[row["graph_id"]].append(float(row["disconnect_fraction"]))
    graph_means = [float(np.mean(values)) for values in by_graph.values() if values]
    if not graph_means:
        return float("nan")
    return float(np.mean(graph_means))


def prevalence_rows(labels: list[dict[str, str]]) -> list[dict[str, object]]:
    grouped: dict[tuple[str, str], dict[str, list[float]]] = defaultdict(lambda: defaultdict(list))
    for row in labels:
        grouped[(row["split"], row["q"])][row["graph_id"]].append(float(row["disconnect_fraction"]))
    output: list[dict[str, object]] = []
    for (split, q_value), by_graph in sorted(grouped.items()):
        graph_means = [float(np.mean(values)) for values in by_graph.values()]
        output.append(
            {
                "split": split,
                "q": q_value,
                "graph_count": len(graph_means),
                "graph_balanced_prevalence": float(np.mean(graph_means)),
                "min_graph_prevalence": float(np.min(graph_means)),
                "max_graph_prevalence": float(np.max(graph_means)),
            }
        )
    return output


def matrix(rows: list[dict[str, str]], features: list[str]) -> np.ndarray:
    return np.array([[as_float(row, feature) for feature in features] for row in rows], dtype=float)


def q_row_counts_by_graph(features: list[dict[str, str]], splits: set[str]) -> dict[str, int]:
    counts: dict[str, int] = defaultdict(int)
    for row in features:
        if row["split"] in splits:
            counts[row["graph_id"]] += 1
    return dict(counts)


def build_expanded_rows(
    features_by_row: dict[str, dict[str, str]],
    samples: list[dict[str, str]],
    splits: set[str],
) -> tuple[list[dict[str, str]], np.ndarray, np.ndarray]:
    feature_rows = [row for row in features_by_row.values() if row["split"] in splits]
    q_counts = q_row_counts_by_graph(feature_rows, splits)
    sample_counts: dict[str, int] = defaultdict(int)
    for sample in samples:
        if sample["split"] in splits:
            sample_counts[sample["row_id"]] += 1
    graph_ids = sorted(q_counts)
    graph_count = len(graph_ids)
    if graph_count == 0:
        raise RuntimeError(f"no graph ids for splits: {splits}")

    rows: list[dict[str, str]] = []
    labels: list[int] = []
    weights: list[float] = []
    for sample in samples:
        if sample["split"] not in splits:
            continue
        row = features_by_row[sample["row_id"]]
        weight = 1.0 / (
            graph_count * q_counts[row["graph_id"]] * sample_counts[sample["row_id"]]
        )
        rows.append(row)
        labels.append(int(sample["disconnected"]))
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
    losses_by_graph: dict[str, list[float]] = defaultdict(list)
    for row, prob in zip(feature_rows, probs, strict=True):
        label = label_by_row[row["row_id"]]
        k_value = int(label["K"])
        z_value = int(label["z"])
        p_value = min(max(float(prob), epsilon), 1.0 - epsilon)
        loss = -(
            z_value * math.log(p_value) + (k_value - z_value) * math.log(1.0 - p_value)
        ) / k_value
        losses_by_graph[row["graph_id"]].append(loss)
    graph_losses = {
        graph_id: float(np.mean(losses)) for graph_id, losses in losses_by_graph.items()
    }
    return float(np.mean(list(graph_losses.values()))), graph_losses


def fit_model(
    train_rows: list[dict[str, str]],
    train_y: np.ndarray,
    train_w: np.ndarray,
    val_rows: list[dict[str, str]],
    val_labels: dict[str, dict[str, str]],
    features: list[str],
    c_grid: list[float],
) -> tuple[float, float]:
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
    scaler = StandardScaler()
    x_scaled = scaler.fit_transform(matrix(rows, features))
    model = LogisticRegression(C=c_value, solver="liblinear", max_iter=1000)
    model.fit(x_scaled, y, sample_weight=weights)
    return scaler, model


def paired_bootstrap_positive_rate(
    b1_losses: dict[str, float],
    sp_losses: dict[str, float],
    replicates: int,
    seed: int,
) -> float:
    rng = np.random.default_rng(seed)
    graph_ids = sorted(set(b1_losses) & set(sp_losses))
    improvements = np.array([b1_losses[gid] - sp_losses[gid] for gid in graph_ids], dtype=float)
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
    parser.add_argument("--bootstrap-replicates", type=int, default=1000)
    parser.add_argument("--bootstrap-seed", type=int, default=71237)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    c_grid = [float(part) for part in args.c_grid.split(",") if part]
    log_progress(f"start input={args.input_dir} output={args.output_dir} c_grid={c_grid}")

    graphs = {row["graph_id"]: row for row in read_csv(args.input_dir / "graphs.csv")}
    features_list = read_csv(args.input_dir / "features.csv")
    samples = read_csv(args.input_dir / "failure_samples.csv")
    labels = read_csv(args.input_dir / "labels.csv")
    features_by_row = {row["row_id"]: row for row in features_list}
    log_progress(
        f"loaded graphs={len(graphs)} features={len(features_list)} "
        f"samples={len(samples)} labels={len(labels)}"
    )

    split_audit = audit_split_integrity(graphs, features_list, samples, labels)
    log_progress(f"split audit {split_audit['status']} {split_audit['graph_count_by_split']}")
    label_audit = audit_samples_and_labels(graphs, samples, labels)
    log_progress(
        f"label/sample audit {label_audit['status']} "
        f"samples={label_audit['audited_samples']} labels={label_audit['audited_label_rows']}"
    )
    test_prevalence = graph_balanced_prevalence(labels, {"test"})
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
    graph_loss_by_model: dict[str, dict[str, float]] = {}
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
        test_loss, graph_losses = grouped_binomial_loss(
            model, scaler, test_rows, test_labels, model_features
        )
        graph_loss_by_model[model_name] = graph_losses
        metric_rows.append(
            {
                "model": model_name,
                "feature_count": len(model_features),
                "selected_C": c_value,
                "validation_graph_grouped_log_loss": val_loss,
                "test_graph_grouped_log_loss": test_loss,
            }
        )
        log_progress(
            f"model done={model_name} C={c_value} "
            f"val={val_loss:.6f} test={test_loss:.6f}"
        )

    metrics = {row["model"]: row for row in metric_rows}
    b1_loss = float(metrics["B1"]["test_graph_grouped_log_loss"])
    sp_loss = float(metrics["B1_SP_scalar"]["test_graph_grouped_log_loss"])
    relative_improvement = (b1_loss - sp_loss) / b1_loss if b1_loss > 0 else float("nan")
    bootstrap_positive_rate = paired_bootstrap_positive_rate(
        graph_loss_by_model["B1"],
        graph_loss_by_model["B1_SP_scalar"],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )
    hazard_loss = float(metrics["B1_hazard"]["test_graph_grouped_log_loss"])
    hazard_sp_loss = float(metrics["B1_hazard_SP_scalar"]["test_graph_grouped_log_loss"])
    hazard_relative_improvement = (
        (hazard_loss - hazard_sp_loss) / hazard_loss if hazard_loss > 0 else float("nan")
    )
    hazard_bootstrap_positive_rate = paired_bootstrap_positive_rate(
        graph_loss_by_model["B1_hazard"],
        graph_loss_by_model["B1_hazard_SP_scalar"],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )
    support_primary = (
        sp_loss < b1_loss
        and relative_improvement >= 0.01
        and bootstrap_positive_rate >= 0.90
        and not endpoint_degenerate
    )

    write_csv(
        args.output_dir / "model_metrics.csv",
        metric_rows,
        [
            "model",
            "feature_count",
            "selected_C",
            "validation_graph_grouped_log_loss",
            "test_graph_grouped_log_loss",
        ],
    )
    prevalence_diagnostics = prevalence_rows(labels)
    write_csv(
        args.output_dir / "prevalence_by_q_split.csv",
        prevalence_diagnostics,
        [
            "split",
            "q",
            "graph_count",
            "graph_balanced_prevalence",
            "min_graph_prevalence",
            "max_graph_prevalence",
        ],
    )
    log_progress("wrote model_metrics.csv and prevalence_by_q_split.csv")

    summary = {
        "status": "smoke_evaluated_not_evidence",
        "test_graph_balanced_prevalence": test_prevalence,
        "endpoint_degenerate": endpoint_degenerate,
        "B1_test_log_loss": b1_loss,
        "B1_SP_scalar_test_log_loss": sp_loss,
        "relative_log_loss_improvement": relative_improvement,
        "bootstrap_positive_rate": bootstrap_positive_rate,
        "B1_hazard_test_log_loss": hazard_loss,
        "B1_hazard_SP_scalar_test_log_loss": hazard_sp_loss,
        "hazard_guardrail_relative_log_loss_improvement": hazard_relative_improvement,
        "hazard_guardrail_bootstrap_positive_rate": hazard_bootstrap_positive_rate,
        "bootstrap_replicates": args.bootstrap_replicates,
        "bootstrap_seed": args.bootstrap_seed,
        "label_sample_audit": label_audit,
        "split_integrity_audit": split_audit,
        "primary_support_rule_would_pass_on_smoke": bool(support_primary),
        "primary_model": "B1_SP_scalar",
        "guardrail_models": ["B1_hazard", "B1_hazard_SP_scalar", "B2_guardrail"],
        "attribution_models": ["B1_SP_terms", "B1_SP_bundle"],
        "notes": [
            "Smoke output is not validation evidence.",
            "Primary scoring used graph-id grouped binomial log loss.",
            "No exact reliability, Monte Carlo reliability estimate, or realized target state is used as a feature.",
        ],
    }
    (args.output_dir / "evaluation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    log_progress(f"done elapsed_s={time.monotonic() - started_at:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
