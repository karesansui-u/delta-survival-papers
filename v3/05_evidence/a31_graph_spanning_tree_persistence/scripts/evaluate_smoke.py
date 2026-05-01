#!/usr/bin/env python3
"""Evaluate an A31 dataset with grouped binomial log loss.

By default this is used for smoke checks. It becomes support-bearing only when
its exact path, content hash, command, seeds, and output location are pinned by
a frozen manifest before outcome-bearing execution.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path

import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler


B0_FEATURES = [
    "n",
    "et",
    "edge_density",
    "deleted_edge_count",
    "deleted_edge_fraction",
    "mean_degree",
    "degree_variance",
]

B1_FEATURES = B0_FEATURES + [
    "min_degree",
    "kappat",
    "bridge_count",
    "avg_shortest_path_length",
    "diameter",
]

LOGTAU_FEATURES = B1_FEATURES + ["log_tau"]
L_FEATURES = B1_FEATURES + ["L_t"]
SP_BUNDLE_FEATURES = B1_FEATURES + ["log_tau", "L_t"]

B2_FEATURES = B1_FEATURES + [
    "algebraic_connectivity",
    "laplacian_spectral_radius",
    "adjacency_spectral_gap",
    "kirchhoff_index",
    "betweenness_mean",
    "betweenness_max",
    "betweenness_std",
]

MODEL_FEATURES = {
    "B0": B0_FEATURES,
    "B1": B1_FEATURES,
    "B1_logtau": LOGTAU_FEATURES,
    "B1_L": L_FEATURES,
    "B1_SP_bundle": SP_BUNDLE_FEATURES,
    "B2_guardrail": B2_FEATURES,
}


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


def graph_balanced_prevalence(label_rows: list[dict[str, str]], splits: set[str]) -> float:
    by_graph: dict[str, list[float]] = defaultdict(list)
    for row in label_rows:
        if row["split"] in splits:
            by_graph[row["graph_id"]].append(float(row["collapse_fraction"]))
    graph_means = [float(np.mean(values)) for values in by_graph.values() if values]
    if not graph_means:
        return float("nan")
    return float(np.mean(graph_means))


def future_count_by_state(future_paths: list[dict[str, str]]) -> dict[str, int]:
    counts: dict[str, int] = defaultdict(int)
    for row in future_paths:
        counts[row["state_id"]] += 1
    return dict(counts)


def validate_k_consistency(
    label_rows: list[dict[str, str]],
    future_paths: list[dict[str, str]],
) -> int:
    counts = future_count_by_state(future_paths)
    k_values = set()
    for row in label_rows:
        state_id = row["state_id"]
        label_k = int(row["K"])
        if state_id not in counts:
            raise RuntimeError(f"label row has no future paths: {state_id}")
        if counts[state_id] != label_k:
            raise RuntimeError(
                f"K mismatch for {state_id}: labels K={label_k}, "
                f"future paths={counts[state_id]}"
            )
        if int(row["z"]) > label_k:
            raise RuntimeError(f"collapse count exceeds K for {state_id}")
        k_values.add(label_k)
    if len(k_values) != 1:
        raise RuntimeError(f"multiple K values found: {sorted(k_values)}")
    return next(iter(k_values))


def parse_first_disconnect_step(raw: str) -> int | None:
    if raw == "":
        return None
    return int(raw)


def audit_label_counts(
    label_rows: list[dict[str, str]],
    future_paths: list[dict[str, str]],
) -> dict[str, object]:
    steps_by_state: dict[str, list[int | None]] = defaultdict(list)
    for row in future_paths:
        steps_by_state[row["state_id"]].append(
            parse_first_disconnect_step(row["first_disconnect_step"])
        )

    audited = 0
    for row in label_rows:
        state_id = row["state_id"]
        if state_id not in steps_by_state:
            raise RuntimeError(f"label row has no future paths: {state_id}")
        h_steps = int(row["h_steps"])
        expected_z = sum(
            1 for step in steps_by_state[state_id] if step is not None and step <= h_steps
        )
        observed_z = int(row["z"])
        if expected_z != observed_z:
            raise RuntimeError(
                f"label z mismatch for state={state_id}, h_steps={h_steps}: "
                f"labels z={observed_z}, recomputed z={expected_z}"
            )
        audited += 1

    return {
        "status": "passed",
        "audited_label_rows": audited,
        "audited_state_count": len(steps_by_state),
    }


def choose_horizon(label_rows: list[dict[str, str]]) -> tuple[float | None, list[dict[str, object]]]:
    candidates = sorted({float(row["horizon_fraction"]) for row in label_rows})
    diagnostics: list[dict[str, object]] = []
    chosen: float | None = None
    for horizon in candidates:
        rows = [row for row in label_rows if float(row["horizon_fraction"]) == horizon]
        prevalence = graph_balanced_prevalence(rows, {"train", "validation"})
        nondegenerate = 0.10 <= prevalence <= 0.90
        diagnostics.append(
            {
                "horizon_fraction": horizon,
                "calibration_graph_balanced_prevalence": prevalence,
                "nondegenerate": nondegenerate,
            }
        )
        if chosen is None and nondegenerate:
            chosen = horizon
    return chosen, diagnostics


def build_expanded_rows(
    states: dict[str, dict[str, str]],
    future_paths: list[dict[str, str]],
    future_counts: dict[str, int],
    horizon_fraction: float,
    splits: set[str],
) -> tuple[list[dict[str, str]], np.ndarray, np.ndarray]:
    by_graph_states: dict[str, set[str]] = defaultdict(set)
    graph_ids = set()
    for state in states.values():
        if state["split"] in splits:
            graph_ids.add(state["graph_id"])
            by_graph_states[state["graph_id"]].add(state["state_id"])
    n_graphs = len(graph_ids)

    rows: list[dict[str, str]] = []
    labels: list[int] = []
    weights: list[float] = []
    for path in future_paths:
        if path["split"] not in splits:
            continue
        state = states[path["state_id"]]
        et = int(float(state["et"]))
        h_steps = int(math.ceil(horizon_fraction * et))
        first = path["first_disconnect_step"]
        label = bool(first) and int(first) <= h_steps
        state_count = len(by_graph_states[state["graph_id"]])
        future_count = future_counts[path["state_id"]]
        weight = 1.0 / (n_graphs * state_count * future_count)
        rows.append(state)
        labels.append(1 if label else 0)
        weights.append(weight)
    return rows, np.array(labels, dtype=int), np.array(weights, dtype=float)


def matrix(rows: list[dict[str, str]], features: list[str]) -> np.ndarray:
    return np.array([[as_float(row, feature) for feature in features] for row in rows], dtype=float)


def fit_model(
    train_rows: list[dict[str, str]],
    train_y: np.ndarray,
    train_w: np.ndarray,
    val_states: list[dict[str, str]],
    val_labels: dict[str, dict[str, str]],
    features: list[str],
    c_grid: list[float],
) -> tuple[float, float]:
    best: tuple[float, float] | None = None
    x_train = matrix(train_rows, features)
    for c_value in c_grid:
        scaler = StandardScaler()
        x_scaled = scaler.fit_transform(x_train)
        model = LogisticRegression(C=c_value, solver="liblinear", max_iter=1000)
        model.fit(x_scaled, train_y, sample_weight=train_w)
        val_loss, _ = grouped_binomial_loss(model, scaler, val_states, val_labels, features)
        if best is None or val_loss < best[0]:
            best = (val_loss, c_value)
    if best is None:
        raise RuntimeError("no model selected")
    val_loss, c_value = best

    # Refit on train+validation after selecting C by validation only.
    return c_value, val_loss


def fit_fixed_c(
    rows: list[dict[str, str]],
    y: np.ndarray,
    w: np.ndarray,
    features: list[str],
    c_value: float,
) -> tuple[StandardScaler, LogisticRegression]:
    scaler = StandardScaler()
    x_scaled = scaler.fit_transform(matrix(rows, features))
    model = LogisticRegression(C=c_value, solver="liblinear", max_iter=1000)
    model.fit(x_scaled, y, sample_weight=w)
    return scaler, model


def grouped_binomial_loss(
    model: LogisticRegression,
    scaler: StandardScaler,
    state_rows: list[dict[str, str]],
    label_by_state: dict[str, dict[str, str]],
    features: list[str],
) -> tuple[float, dict[str, float]]:
    epsilon = 1.0e-15
    losses_by_graph: dict[str, list[float]] = defaultdict(list)
    x = scaler.transform(matrix(state_rows, features))
    probs = model.predict_proba(x)[:, 1]
    for row, prob in zip(state_rows, probs, strict=True):
        label = label_by_state[row["state_id"]]
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


def labels_for_horizon(label_rows: list[dict[str, str]], horizon: float, split: str | None = None) -> dict[str, dict[str, str]]:
    out = {}
    for row in label_rows:
        if float(row["horizon_fraction"]) != horizon:
            continue
        if split is not None and row["split"] != split:
            continue
        out[row["state_id"]] = row
    return out


def state_rows_for_split(states: dict[str, dict[str, str]], split: str) -> list[dict[str, str]]:
    return [row for row in states.values() if row["split"] == split]


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
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--c-grid", default="0.01,0.1,1,10")
    parser.add_argument("--bootstrap-replicates", type=int, default=2000)
    parser.add_argument("--bootstrap-seed", type=int, default=83171)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    c_grid = [float(part) for part in args.c_grid.split(",") if part]

    states_list = read_csv(args.input_dir / "states.csv")
    future_paths = read_csv(args.input_dir / "future_paths.csv")
    label_rows = read_csv(args.input_dir / "labels_by_horizon.csv")
    states = {row["state_id"]: row for row in states_list}
    future_counts = future_count_by_state(future_paths)
    future_trajectories = validate_k_consistency(label_rows, future_paths)
    label_audit = audit_label_counts(label_rows, future_paths)

    chosen_horizon, horizon_diagnostics = choose_horizon(label_rows)
    if chosen_horizon is None:
        summary = {
            "status": "redesign_required_no_nondegenerate_horizon",
            "horizon_diagnostics": horizon_diagnostics,
        }
        (args.output_dir / "evaluation_summary.json").write_text(
            json.dumps(summary, indent=2, sort_keys=True) + "\n"
        )
        return 0

    train_rows, train_y, train_w = build_expanded_rows(
        states, future_paths, future_counts, chosen_horizon, {"train"}
    )
    train_val_rows, train_val_y, train_val_w = build_expanded_rows(
        states, future_paths, future_counts, chosen_horizon, {"train", "validation"}
    )
    val_states = state_rows_for_split(states, "validation")
    test_states = state_rows_for_split(states, "test")
    val_labels = labels_for_horizon(label_rows, chosen_horizon, "validation")
    test_labels = labels_for_horizon(label_rows, chosen_horizon, "test")

    metric_rows: list[dict[str, object]] = []
    graph_loss_by_model: dict[str, dict[str, float]] = {}
    for model_name, features in MODEL_FEATURES.items():
        c_value, val_loss = fit_model(
            train_rows,
            train_y,
            train_w,
            val_states,
            val_labels,
            features,
            c_grid,
        )
        scaler, model = fit_fixed_c(train_val_rows, train_val_y, train_val_w, features, c_value)
        test_loss, graph_losses = grouped_binomial_loss(
            model, scaler, test_states, test_labels, features
        )
        graph_loss_by_model[model_name] = graph_losses
        metric_rows.append(
            {
                "model": model_name,
                "feature_count": len(features),
                "selected_C": c_value,
                "validation_graph_grouped_log_loss": val_loss,
                "test_graph_grouped_log_loss": test_loss,
            }
        )

    metrics = {row["model"]: row for row in metric_rows}
    b1_loss = float(metrics["B1"]["test_graph_grouped_log_loss"])
    sp_loss = float(metrics["B1_SP_bundle"]["test_graph_grouped_log_loss"])
    relative_improvement = (b1_loss - sp_loss) / b1_loss if b1_loss > 0 else float("nan")
    bootstrap_positive_rate = paired_bootstrap_positive_rate(
        graph_loss_by_model["B1"],
        graph_loss_by_model["B1_SP_bundle"],
        args.bootstrap_replicates,
        args.bootstrap_seed,
    )

    support_primary = (
        sp_loss < b1_loss
        and relative_improvement >= 0.01
        and bootstrap_positive_rate >= 0.90
    )

    test_prevalence = graph_balanced_prevalence(
        [row for row in label_rows if float(row["horizon_fraction"]) == chosen_horizon],
        {"test"},
    )
    endpoint_degenerate = test_prevalence < 0.02 or test_prevalence > 0.98

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
    write_csv(
        args.output_dir / "horizon_diagnostics.csv",
        horizon_diagnostics,
        ["horizon_fraction", "calibration_graph_balanced_prevalence", "nondegenerate"],
    )

    summary = {
        "status": "smoke_evaluated_not_evidence",
        "chosen_horizon_fraction": chosen_horizon,
        "test_graph_balanced_prevalence": test_prevalence,
        "endpoint_degenerate": endpoint_degenerate,
        "B1_test_log_loss": b1_loss,
        "B1_SP_bundle_test_log_loss": sp_loss,
        "relative_log_loss_improvement": relative_improvement,
        "bootstrap_positive_rate": bootstrap_positive_rate,
        "bootstrap_replicates": args.bootstrap_replicates,
        "bootstrap_seed": args.bootstrap_seed,
        "future_trajectories": future_trajectories,
        "label_count_audit": label_audit,
        "primary_support_rule_would_pass_on_smoke": bool(
            support_primary and not endpoint_degenerate
        ),
        "notes": [
            "Smoke output is not validation evidence.",
            "Horizon selection used calibration prevalence only.",
            "Primary scoring used graph-id grouped binomial log loss.",
        ],
    }
    (args.output_dir / "evaluation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
