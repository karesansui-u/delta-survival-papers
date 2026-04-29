#!/usr/bin/env python3
"""Calibration sweep v0 for the M-profile flow-network testbed.

This is a dry-run calibration tool.  It searches candidate values of
required-flow Q, damage intensity, and horizon for non-degenerate regimes.  It
does not select or freeze a primary configuration by itself.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parents[1]
SCRIPT_DIR = HERE / "scripts"
DEFAULT_OUT_DIR = HERE / "dry_runs" / "calibration_sweep_v0"

if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import report_flow_degeneracy as degeneracy  # noqa: E402
import simulate_flow_network as simulator  # noqa: E402


DEFAULT_Q_VALUES = (3, 4, 5)
DEFAULT_DAMAGE_VALUES = (0.18, 0.24, 0.30)
DEFAULT_HORIZON_VALUES = (8, 10)


def run_candidate(
    *,
    q_value: int,
    damage_intensity: float,
    horizon: int,
    seeds: int,
    full_grid: bool,
) -> tuple[list[dict[str, Any]], dict[str, Any], list[dict[str, Any]]]:
    args = argparse.Namespace(
        seed=1000,
        seeds=seeds,
        layers=4,
        width=4,
        edge_density=0.45,
        capacity_max=4,
        required_flow=q_value,
        horizon=horizon,
        damage_intensity=damage_intensity,
        allocation=None,
        held_out_allocation=None,
        full_grid=full_grid,
    )
    held_out_allocations = set(simulator.DEFAULT_HELD_OUT_ALLOCATIONS)
    rows = [
        simulator.run_instance(
            seed=seed,
            graph_family=graph_family,
            damage_family=damage_family,
            allocation=allocation,
            held_out_allocations=held_out_allocations,
            n_layers=args.layers,
            width=args.width,
            edge_density=args.edge_density,
            capacity_max=args.capacity_max,
            required_flow_q=args.required_flow,
            horizon=args.horizon,
            damage_intensity=args.damage_intensity,
        )
        for seed, graph_family, damage_family, allocation in simulator.iter_plan(args)
    ]
    str_rows = [{key: str(value) for key, value in row.items()} for row in rows]
    run_flag_rows = degeneracy.build_run_flag_rows(str_rows)
    group_rows = degeneracy.build_group_rows(str_rows)
    summary = degeneracy.summarize(str_rows, run_flag_rows, group_rows)
    return rows, summary, group_rows


def collapse_fraction(rows: list[dict[str, Any]]) -> float:
    if not rows:
        return 0.0
    return sum(row["collapse_time"] != "" for row in rows) / len(rows)


def flag_fraction(summary: dict[str, Any], flag: str) -> float:
    count = int(summary["run_flag_counts"].get(flag, 0))
    return count / max(1, int(summary["runs"]))


def candidate_score(summary: dict[str, Any], rows: list[dict[str, Any]]) -> float:
    """Heuristic score for calibration only.

    Higher is better.  The target is a non-degenerate regime: some collapses,
    not mostly no-collapse, not many first-step collapses, and not mostly
    far-above-Q.
    """
    collapse = collapse_fraction(rows)
    no_collapse = flag_fraction(summary, "no_collapse")
    first_step = flag_fraction(summary, "collapse_at_first_step")
    far_above = flag_fraction(summary, "far_above_q")
    review = int(summary["exclusion_recommendation_counts"].get("review", 0))
    groups = max(1, int(summary["groups_evaluated"]))
    target_collapse = 0.45
    score = 1.0
    score -= abs(collapse - target_collapse)
    score -= 0.65 * no_collapse
    score -= 1.00 * first_step
    score -= 0.55 * far_above
    score -= 0.40 * (review / groups)
    return score


def summarize_candidate(
    *,
    q_value: int,
    damage_intensity: float,
    horizon: int,
    seeds: int,
    full_grid: bool,
    rows: list[dict[str, Any]],
    summary: dict[str, Any],
) -> dict[str, Any]:
    recommendations = summary["exclusion_recommendation_counts"]
    return {
        "required_flow_Q": q_value,
        "damage_intensity": damage_intensity,
        "horizon_T": horizon,
        "seeds": seeds,
        "full_grid": full_grid,
        "runs": summary["runs"],
        "groups_evaluated": summary["groups_evaluated"],
        "collapse_fraction": collapse_fraction(rows),
        "no_collapse_fraction": flag_fraction(summary, "no_collapse"),
        "far_above_q_fraction": flag_fraction(summary, "far_above_q"),
        "collapse_at_first_step_fraction": flag_fraction(summary, "collapse_at_first_step"),
        "post_policy_below_q_fraction": flag_fraction(summary, "post_policy_below_q"),
        "unflagged_fraction": flag_fraction(summary, "unflagged"),
        "review_group_count": int(recommendations.get("review", 0)),
        "keep_group_count": int(recommendations.get("keep", 0)),
        "candidate_score": candidate_score(summary, rows),
    }


def parse_float_list(text: str) -> tuple[float, ...]:
    return tuple(float(part) for part in text.split(",") if part)


def parse_int_list(text: str) -> tuple[int, ...]:
    return tuple(int(part) for part in text.split(",") if part)


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        return
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--q-values", type=parse_int_list, default=DEFAULT_Q_VALUES)
    parser.add_argument("--damage-values", type=parse_float_list, default=DEFAULT_DAMAGE_VALUES)
    parser.add_argument("--horizon-values", type=parse_int_list, default=DEFAULT_HORIZON_VALUES)
    parser.add_argument("--seeds", type=int, default=1)
    parser.add_argument("--full-grid", action="store_true")
    args = parser.parse_args()

    rows: list[dict[str, Any]] = []
    diagnostics: dict[str, Any] = {}
    for q_value in args.q_values:
        for damage_intensity in args.damage_values:
            for horizon in args.horizon_values:
                candidate_rows, summary, group_rows = run_candidate(
                    q_value=q_value,
                    damage_intensity=damage_intensity,
                    horizon=horizon,
                    seeds=args.seeds,
                    full_grid=args.full_grid,
                )
                key = f"Q{q_value}_D{damage_intensity:g}_T{horizon}"
                rows.append(
                    summarize_candidate(
                        q_value=q_value,
                        damage_intensity=damage_intensity,
                        horizon=horizon,
                        seeds=args.seeds,
                        full_grid=args.full_grid,
                        rows=candidate_rows,
                        summary=summary,
                    )
                )
                diagnostics[key] = {
                    "degeneracy_summary": summary,
                    "group_flag_counts": dict(
                        sorted(
                            Counter(
                                flag
                                for group in group_rows
                                for flag in str(group["group_degeneracy_flags"]).split("|")
                                if flag
                            ).items()
                        )
                    ),
                }

    rows.sort(key=lambda row: float(row["candidate_score"]), reverse=True)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    write_csv(args.out_dir / "sweep_summary.csv", rows)
    (args.out_dir / "sweep_diagnostics.json").write_text(
        json.dumps(
            {
                "status": "dry_run_calibration_sweep_v0_only",
                "non_claim": "calibration candidate screen only; no primary support",
                "candidate_count": len(rows),
                "best_candidate": rows[0] if rows else None,
                "diagnostics": diagnostics,
            },
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    print(json.dumps({"candidate_count": len(rows), "best_candidate": rows[0] if rows else None}, indent=2, sort_keys=True))
    print(f"wrote: {args.out_dir / 'sweep_summary.csv'}")
    print(f"wrote: {args.out_dir / 'sweep_diagnostics.json'}")


if __name__ == "__main__":
    main()
