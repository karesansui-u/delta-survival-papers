#!/usr/bin/env python3
"""Evaluate A31 matched-residual v1 under a frozen primary key.

This evaluator is intended for support-bearing A31-v1 runs only when its exact
path, hash, command, seeds, and output directory are pinned by a frozen manifest
before execution.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path

import numpy as np


Row = dict[str, str]


def read_csv(path: Path) -> list[Row]:
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        for row in rows:
            writer.writerow({name: row.get(name, "") for name in fieldnames})


def parse_first_disconnect_step(raw: str) -> int | None:
    if raw == "":
        return None
    return int(raw)


def future_count_by_state(future_paths: list[Row]) -> dict[str, int]:
    counts: dict[str, int] = defaultdict(int)
    for row in future_paths:
        counts[row["state_id"]] += 1
    return dict(counts)


def audit_label_counts(label_rows: list[Row], future_paths: list[Row]) -> dict[str, object]:
    steps_by_state: dict[str, list[int | None]] = defaultdict(list)
    for row in future_paths:
        steps_by_state[row["state_id"]].append(
            parse_first_disconnect_step(row["first_disconnect_step"])
        )

    k_values = set()
    audited = 0
    for row in label_rows:
        state_id = row["state_id"]
        label_k = int(row["K"])
        if state_id not in steps_by_state:
            raise RuntimeError(f"label row has no future paths: {state_id}")
        if len(steps_by_state[state_id]) != label_k:
            raise RuntimeError(
                f"K mismatch for {state_id}: labels K={label_k}, "
                f"future paths={len(steps_by_state[state_id])}"
            )
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
        if observed_z > label_k:
            raise RuntimeError(f"collapse count exceeds K for {state_id}")
        k_values.add(label_k)
        audited += 1

    if len(k_values) != 1:
        raise RuntimeError(f"multiple K values found: {sorted(k_values)}")

    return {
        "status": "passed",
        "future_trajectories": next(iter(k_values)),
        "audited_label_rows": audited,
        "audited_state_count": len(steps_by_state),
    }


def graph_balanced_prevalence(label_rows: list[Row], splits: set[str]) -> float:
    by_graph: dict[str, list[float]] = defaultdict(list)
    for row in label_rows:
        if row["split"] in splits:
            by_graph[row["graph_id"]].append(float(row["collapse_fraction"]))
    graph_means = [float(np.mean(values)) for values in by_graph.values() if values]
    if not graph_means:
        return float("nan")
    return float(np.mean(graph_means))


def choose_horizon(label_rows: list[Row]) -> tuple[float | None, list[dict[str, object]]]:
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


def bucket(value: str, width: float) -> float:
    return round(float(value) / width) * width


def path_b05_key(row: Row) -> tuple[object, ...]:
    return (
        row["n"],
        row["et"],
        row["kappat"],
        row["bridge_count"],
        row["min_degree"],
        row["diameter"],
        bucket(row["avg_shortest_path_length"], 0.5),
    )


def join_rows(input_dir: Path, horizon: float) -> list[Row]:
    states = {row["state_id"]: row for row in read_csv(input_dir / "states.csv")}
    labels = [
        row
        for row in read_csv(input_dir / "labels_by_horizon.csv")
        if float(row["horizon_fraction"]) == horizon
    ]
    rows: list[Row] = []
    for label in labels:
        state = states[label["state_id"]]
        rows.append({**state, "collapse_fraction": label["collapse_fraction"]})
    return rows


def matched_effects(
    rows: list[Row],
    split: str,
    min_group_size: int,
    min_logtau_spread: float,
    tail_fraction: float,
) -> list[dict[str, object]]:
    by_key: dict[tuple[object, ...], list[Row]] = defaultdict(list)
    for row in rows:
        if split != "all" and row["split"] != split:
            continue
        by_key[path_b05_key(row)].append(row)

    out: list[dict[str, object]] = []
    for group_index, (key, group_rows) in enumerate(sorted(by_key.items(), key=lambda item: str(item[0]))):
        if len(group_rows) < min_group_size:
            continue
        ordered = sorted(group_rows, key=lambda row: float(row["log_tau"]))
        spread = float(ordered[-1]["log_tau"]) - float(ordered[0]["log_tau"])
        if spread < min_logtau_spread:
            continue
        tail_count = max(1, int(math.floor(len(ordered) * tail_fraction)))
        low = ordered[:tail_count]
        high = ordered[-tail_count:]
        low_mean = float(np.mean([float(row["collapse_fraction"]) for row in low]))
        high_mean = float(np.mean([float(row["collapse_fraction"]) for row in high]))
        out.append(
            {
                "primary_key": "path_b05",
                "split": split,
                "group_index": group_index,
                "match_key": repr(key),
                "state_count": len(group_rows),
                "tail_count": tail_count,
                "log_tau_min": float(ordered[0]["log_tau"]),
                "log_tau_max": float(ordered[-1]["log_tau"]),
                "log_tau_spread": spread,
                "low_mean_collapse_fraction": low_mean,
                "high_mean_collapse_fraction": high_mean,
                "low_minus_high": low_mean - high_mean,
            }
        )
    return out


def summarize_effects(rows: list[dict[str, object]]) -> dict[str, object]:
    effects = [float(row["low_minus_high"]) for row in rows]
    if not effects:
        return {
            "matched_group_count": 0,
            "matched_state_count": 0,
            "mean_low_minus_high": float("nan"),
            "median_low_minus_high": float("nan"),
            "positive_group_count": 0,
            "positive_group_rate": float("nan"),
        }
    return {
        "matched_group_count": len(rows),
        "matched_state_count": sum(int(row["state_count"]) for row in rows),
        "mean_low_minus_high": float(np.mean(effects)),
        "median_low_minus_high": float(np.median(effects)),
        "positive_group_count": sum(effect > 0.0 for effect in effects),
        "positive_group_rate": sum(effect > 0.0 for effect in effects) / len(effects),
    }


def bootstrap_positive_rate(effects: list[float], replicates: int, seed: int) -> float:
    if not effects:
        return float("nan")
    rng = np.random.default_rng(seed)
    values = np.array(effects, dtype=float)
    positive = 0
    for _ in range(replicates):
        sample = rng.choice(values, size=len(values), replace=True)
        if float(np.mean(sample)) > 0.0:
            positive += 1
    return positive / replicates


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--min-group-size", type=int, default=4)
    parser.add_argument("--min-logtau-spread", type=float, default=0.5)
    parser.add_argument("--tail-fraction", type=float, default=1.0 / 3.0)
    parser.add_argument("--test-min-groups", type=int, default=30)
    parser.add_argument("--effect-threshold", type=float, default=0.03)
    parser.add_argument("--bootstrap-replicates", type=int, default=2000)
    parser.add_argument("--bootstrap-seed", type=int, default=95051)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    label_rows = read_csv(args.input_dir / "labels_by_horizon.csv")
    future_paths = read_csv(args.input_dir / "future_paths.csv")
    label_audit = audit_label_counts(label_rows, future_paths)

    chosen_horizon, horizon_diagnostics = choose_horizon(label_rows)
    write_csv(
        args.output_dir / "horizon_diagnostics.csv",
        horizon_diagnostics,
        ["horizon_fraction", "calibration_graph_balanced_prevalence", "nondegenerate"],
    )
    if chosen_horizon is None:
        summary = {
            "status": "redesign_required_no_nondegenerate_horizon",
            "label_count_audit": label_audit,
            "horizon_diagnostics": horizon_diagnostics,
        }
        (args.output_dir / "evaluation_summary.json").write_text(
            json.dumps(summary, indent=2, sort_keys=True) + "\n"
        )
        return 0

    joined_rows = join_rows(args.input_dir, chosen_horizon)
    effect_rows: list[dict[str, object]] = []
    by_split: dict[str, list[dict[str, object]]] = {}
    for split in ["train", "validation", "test", "all"]:
        split_rows = matched_effects(
            joined_rows,
            split,
            args.min_group_size,
            args.min_logtau_spread,
            args.tail_fraction,
        )
        by_split[split] = split_rows
        effect_rows.extend(split_rows)

    write_csv(
        args.output_dir / "matched_group_effects.csv",
        effect_rows,
        [
            "primary_key",
            "split",
            "group_index",
            "match_key",
            "state_count",
            "tail_count",
            "log_tau_min",
            "log_tau_max",
            "log_tau_spread",
            "low_mean_collapse_fraction",
            "high_mean_collapse_fraction",
            "low_minus_high",
        ],
    )

    summary_rows: list[dict[str, object]] = []
    split_summaries: dict[str, dict[str, object]] = {}
    for split in ["train", "validation", "test", "all"]:
        split_summary = summarize_effects(by_split[split])
        split_summary["split"] = split
        split_summary["primary_key"] = "path_b05"
        split_summaries[split] = split_summary
        summary_rows.append(split_summary)

    write_csv(
        args.output_dir / "matched_residual_summary.csv",
        summary_rows,
        [
            "primary_key",
            "split",
            "matched_group_count",
            "matched_state_count",
            "mean_low_minus_high",
            "median_low_minus_high",
            "positive_group_count",
            "positive_group_rate",
        ],
    )

    test_effects = [float(row["low_minus_high"]) for row in by_split["test"]]
    bootstrap_rate = bootstrap_positive_rate(
        test_effects, args.bootstrap_replicates, args.bootstrap_seed
    )
    validation_direction_pass = float(split_summaries["validation"]["mean_low_minus_high"]) > 0.0
    test_group_count_pass = int(split_summaries["test"]["matched_group_count"]) >= args.test_min_groups
    test_effect_pass = float(split_summaries["test"]["mean_low_minus_high"]) >= args.effect_threshold
    bootstrap_pass = bootstrap_rate >= 0.90
    test_prevalence = graph_balanced_prevalence(
        [
            row
            for row in label_rows
            if float(row["horizon_fraction"]) == chosen_horizon
        ],
        {"test"},
    )
    endpoint_degenerate = test_prevalence < 0.02 or test_prevalence > 0.98

    primary_support = (
        validation_direction_pass
        and test_group_count_pass
        and test_effect_pass
        and bootstrap_pass
        and not endpoint_degenerate
    )
    if primary_support:
        decision = "support"
    elif endpoint_degenerate:
        decision = "no_support_endpoint_degeneracy"
    elif not test_group_count_pass:
        decision = "no_support_test_matched_group_count"
    elif not validation_direction_pass:
        decision = "no_support_validation_direction"
    elif not test_effect_pass:
        decision = "no_support_effect_threshold"
    elif not bootstrap_pass:
        decision = "no_support_bootstrap"
    else:
        decision = "no_support"

    summary = {
        "status": "matched_residual_v1_evaluated",
        "decision": decision,
        "primary_support": primary_support,
        "primary_key": "path_b05",
        "chosen_horizon_fraction": chosen_horizon,
        "test_graph_balanced_prevalence": test_prevalence,
        "endpoint_degenerate": endpoint_degenerate,
        "min_group_size": args.min_group_size,
        "min_logtau_spread": args.min_logtau_spread,
        "tail_fraction": args.tail_fraction,
        "test_min_groups": args.test_min_groups,
        "effect_threshold": args.effect_threshold,
        "bootstrap_replicates": args.bootstrap_replicates,
        "bootstrap_seed": args.bootstrap_seed,
        "test_bootstrap_positive_rate": bootstrap_rate,
        "validation_direction_pass": validation_direction_pass,
        "test_group_count_pass": test_group_count_pass,
        "test_effect_pass": test_effect_pass,
        "bootstrap_pass": bootstrap_pass,
        "label_count_audit": label_audit,
        "split_summaries": split_summaries,
        "notes": [
            "Primary support uses path_b05 and held-out test only.",
            "All split summaries are diagnostics only.",
            "Positive low-minus-high means lower log_tau states collapsed more often within matched groups.",
        ],
    }
    (args.output_dir / "evaluation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
