#!/usr/bin/env python3
"""Exploratory matched-residual analysis for A31.

This script is not support-bearing. It checks whether primary_v0 rows contain a
usable matched surface for a successor A31-v1 question: among graph states
matched on B1-style local robustness features, does log_tau retain residual
future-collapse information?
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path
from typing import Callable

import numpy as np


Row = dict[str, str]
KeyFn = Callable[[Row], tuple[object, ...]]


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


def load_horizon(input_dir: Path, requested: float | None) -> float:
    if requested is not None:
        return requested
    summary_path = input_dir / "evaluation_summary.json"
    if summary_path.exists():
        summary = json.loads(summary_path.read_text())
        if "chosen_horizon_fraction" in summary:
            return float(summary["chosen_horizon_fraction"])
    diagnostics_path = input_dir / "horizon_diagnostics.csv"
    if diagnostics_path.exists():
        rows = read_csv(diagnostics_path)
        for row in rows:
            if row.get("nondegenerate") in {"True", "true", "1"}:
                return float(row["horizon_fraction"])
    raise RuntimeError("could not infer horizon; pass --horizon-fraction")


def bucket(value: str, width: float) -> float:
    return round(float(value) / width) * width


def strict_key(row: Row) -> tuple[object, ...]:
    return (
        row["n"],
        row["et"],
        row["kappat"],
        row["bridge_count"],
        row["min_degree"],
        row["diameter"],
    )


def path_bucket_key(row: Row) -> tuple[object, ...]:
    return strict_key(row) + (bucket(row["avg_shortest_path_length"], 0.5),)


def coarse_diameter_key(row: Row) -> tuple[object, ...]:
    return (
        row["n"],
        row["et"],
        row["kappat"],
        row["bridge_count"],
        row["diameter"],
    )


KEY_SPECS: dict[str, KeyFn] = {
    "strict": strict_key,
    "path_b05": path_bucket_key,
    "coarse_diam": coarse_diameter_key,
}


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
    key_name: str,
    key_fn: KeyFn,
    split: str,
    min_group_size: int,
    min_logtau_spread: float,
    tail_fraction: float,
) -> list[dict[str, object]]:
    by_key: dict[tuple[object, ...], list[Row]] = defaultdict(list)
    for row in rows:
        if split != "all" and row["split"] != split:
            continue
        by_key[key_fn(row)].append(row)

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
                "key_name": key_name,
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


def summarize(
    rows: list[dict[str, object]],
    bootstrap_replicates: int,
    bootstrap_seed: int,
) -> list[dict[str, object]]:
    by_pair: dict[tuple[str, str], list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_pair[(str(row["key_name"]), str(row["split"]))].append(row)

    summary_rows: list[dict[str, object]] = []
    for (key_name, split), group_rows in sorted(by_pair.items()):
        effects = [float(row["low_minus_high"]) for row in group_rows]
        state_count = sum(int(row["state_count"]) for row in group_rows)
        summary_rows.append(
            {
                "key_name": key_name,
                "split": split,
                "matched_group_count": len(group_rows),
                "matched_state_count": state_count,
                "mean_low_minus_high": float(np.mean(effects)) if effects else float("nan"),
                "median_low_minus_high": float(np.median(effects)) if effects else float("nan"),
                "positive_group_count": sum(effect > 0.0 for effect in effects),
                "positive_group_rate": (
                    sum(effect > 0.0 for effect in effects) / len(effects)
                    if effects
                    else float("nan")
                ),
                "bootstrap_positive_rate": bootstrap_positive_rate(
                    effects, bootstrap_replicates, bootstrap_seed
                ),
            }
        )
    return summary_rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--horizon-fraction", type=float, default=None)
    parser.add_argument("--min-group-size", type=int, default=4)
    parser.add_argument("--min-logtau-spread", type=float, default=0.5)
    parser.add_argument("--tail-fraction", type=float, default=1.0 / 3.0)
    parser.add_argument("--bootstrap-replicates", type=int, default=2000)
    parser.add_argument("--bootstrap-seed", type=int, default=92051)
    args = parser.parse_args()

    horizon = load_horizon(args.input_dir, args.horizon_fraction)
    joined_rows = join_rows(args.input_dir, horizon)
    args.output_dir.mkdir(parents=True, exist_ok=True)

    effect_rows: list[dict[str, object]] = []
    for key_name, key_fn in KEY_SPECS.items():
        for split in ["train", "validation", "test", "all"]:
            effect_rows.extend(
                matched_effects(
                    joined_rows,
                    key_name,
                    key_fn,
                    split,
                    args.min_group_size,
                    args.min_logtau_spread,
                    args.tail_fraction,
                )
            )

    write_csv(
        args.output_dir / "matched_group_effects.csv",
        effect_rows,
        [
            "key_name",
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

    summary_rows = summarize(effect_rows, args.bootstrap_replicates, args.bootstrap_seed)
    write_csv(
        args.output_dir / "matched_residual_summary.csv",
        summary_rows,
        [
            "key_name",
            "split",
            "matched_group_count",
            "matched_state_count",
            "mean_low_minus_high",
            "median_low_minus_high",
            "positive_group_count",
            "positive_group_rate",
            "bootstrap_positive_rate",
        ],
    )
    summary = {
        "status": "exploratory_smoke_not_validation_evidence",
        "input_dir": str(args.input_dir),
        "horizon_fraction": horizon,
        "min_group_size": args.min_group_size,
        "min_logtau_spread": args.min_logtau_spread,
        "tail_fraction": args.tail_fraction,
        "bootstrap_replicates": args.bootstrap_replicates,
        "bootstrap_seed": args.bootstrap_seed,
        "summary": summary_rows,
        "notes": [
            "This analysis uses primary_v0 rows after the primary_v0 no-support result.",
            "It is design smoke for A31-v1 and cannot be treated as validation support.",
            "Positive low-minus-high means lower log_tau states collapsed more often within matched groups.",
        ],
    }
    (args.output_dir / "matched_residual_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
