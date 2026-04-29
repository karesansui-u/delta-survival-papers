#!/usr/bin/env python3
"""Degeneracy report v1 for the M-profile flow-network testbed.

This report is a dry-run guardrail.  It makes run-level and group-level
degeneracy visible before any primary freeze.  It does not decide support.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parents[1]
DEFAULT_RUNS = HERE / "dry_runs" / "v0_smoke" / "runs.csv"
DEFAULT_OUT_DIR = HERE / "dry_runs" / "v0_smoke"

GROUP_COLUMNS = (
    "seed",
    "graph_family",
    "damage_family",
    "total_energy_E",
    "required_flow_Q",
    "horizon_T",
    "damage_intensity",
)

PRIMARY_DEGENERACY_FLAGS = (
    "initially_collapsed",
    "collapse_at_first_step",
    "no_collapse",
    "far_above_q",
    "post_policy_below_q",
    "recovery_unused",
    "reconfiguration_impossible",
    "no_alternate_path",
)


def as_float(row: dict[str, str], key: str) -> float:
    value = row.get(key, "")
    if value == "":
        return 0.0
    return float(value)


def as_int(row: dict[str, str], key: str) -> int:
    value = row.get(key, "")
    if value == "":
        return 0
    return int(float(value))


def flag_set(row: dict[str, str]) -> set[str]:
    raw = row.get("degeneracy_flags", "")
    return {part for part in raw.split("|") if part}


def group_key(row: dict[str, str]) -> tuple[str, ...]:
    return tuple(row[column] for column in GROUP_COLUMNS)


def observed_score(row: dict[str, str]) -> float:
    return (
        as_float(row, "maintained_step_ratio")
        + as_float(row, "maintained_flow_ratio")
        + 0.01 * as_float(row, "minimum_margin")
    )


def count_by(rows: list[dict[str, str]], column: str) -> dict[str, int]:
    return dict(sorted(Counter(row[column] for row in rows).items()))


def group_split_info(rows: list[dict[str, str]]) -> dict[str, Any]:
    graph_splits = sorted({row["graph_split"] for row in rows})
    damage_splits = sorted({row["damage_split"] for row in rows})
    has_heldout_allocation = any(row["allocation_split"] == "primary_heldout" for row in rows)
    axes: list[str] = []
    if any(split != "calibration" for split in graph_splits):
        axes.append("graph")
    if any(split != "calibration" for split in damage_splits):
        axes.append("damage")
    if has_heldout_allocation:
        axes.append("allocation")
    return {
        "graph_split": "|".join(graph_splits),
        "damage_split": "|".join(damage_splits),
        "has_heldout_allocation": has_heldout_allocation,
        "primary_axes": "|".join(axes) if axes else "none",
        "group_split": "calibration_only" if not axes else "heldout_" + "_".join(axes),
    }


def build_run_flag_rows(rows: list[dict[str, str]]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    total = max(1, len(rows))
    for flag in PRIMARY_DEGENERACY_FLAGS:
        flagged = [row for row in rows if flag in flag_set(row)]
        out.append(
            {
                "flag": flag,
                "count": len(flagged),
                "fraction": len(flagged) / total,
                "graph_family_counts": json.dumps(count_by(flagged, "graph_family"), sort_keys=True),
                "damage_family_counts": json.dumps(count_by(flagged, "damage_family"), sort_keys=True),
                "allocation_split_counts": json.dumps(count_by(flagged, "allocation_split"), sort_keys=True),
            }
        )
    unflagged = [row for row in rows if not flag_set(row)]
    out.append(
        {
            "flag": "unflagged",
            "count": len(unflagged),
            "fraction": len(unflagged) / total,
            "graph_family_counts": json.dumps(count_by(unflagged, "graph_family"), sort_keys=True),
            "damage_family_counts": json.dumps(count_by(unflagged, "damage_family"), sort_keys=True),
            "allocation_split_counts": json.dumps(count_by(unflagged, "allocation_split"), sort_keys=True),
        }
    )
    return out


def value_range(rows: list[dict[str, str]], key: str) -> float:
    values = [as_float(row, key) for row in rows]
    return max(values) - min(values) if values else 0.0


def group_summary_row(key: tuple[str, ...], rows: list[dict[str, str]]) -> dict[str, Any]:
    n = len(rows)
    flags = [flag_set(row) for row in rows]
    any_flag_fraction = sum(bool(item) for item in flags) / max(1, n)
    no_collapse_fraction = sum("no_collapse" in item for item in flags) / max(1, n)
    collapse_first_fraction = sum("collapse_at_first_step" in item for item in flags) / max(1, n)
    far_above_fraction = sum("far_above_q" in item for item in flags) / max(1, n)
    post_policy_below_fraction = sum("post_policy_below_q" in item for item in flags) / max(1, n)
    recovery_rows = [row for row in rows if as_int(row, "allocation_recovery") > 0]
    reconfiguration_rows = [row for row in rows if as_int(row, "allocation_reconfiguration") > 0]
    recovery_unused_fraction = (
        sum(as_int(row, "recovery_energy_spent") == 0 for row in recovery_rows) / len(recovery_rows)
        if recovery_rows
        else 0.0
    )
    reconfiguration_unused_fraction = (
        sum(as_int(row, "reconfiguration_energy_spent") == 0 for row in reconfiguration_rows)
        / len(reconfiguration_rows)
        if reconfiguration_rows
        else 0.0
    )
    score_values = [observed_score(row) for row in rows]
    score_range = max(score_values) - min(score_values) if score_values else 0.0

    group_flags: list[str] = []
    if no_collapse_fraction >= 1.0:
        group_flags.append("all_no_collapse")
    if collapse_first_fraction >= 1.0:
        group_flags.append("all_collapse_at_first_step")
    if far_above_fraction >= 1.0:
        group_flags.append("all_far_above_q")
    if post_policy_below_fraction >= 1.0:
        group_flags.append("all_post_policy_below_q")
    if score_range <= 1e-12:
        group_flags.append("no_outcome_variation")
    if recovery_rows and recovery_unused_fraction >= 1.0:
        group_flags.append("recovery_never_used")
    if reconfiguration_rows and reconfiguration_unused_fraction >= 1.0:
        group_flags.append("reconfiguration_never_used")
    if any_flag_fraction >= 0.8:
        group_flags.append("high_flag_fraction")

    recommendation = "review" if group_flags else "keep"
    return {
        **{column: value for column, value in zip(GROUP_COLUMNS, key)},
        **group_split_info(rows),
        "n_allocations": n,
        "flagged_run_fraction": any_flag_fraction,
        "no_collapse_fraction": no_collapse_fraction,
        "collapse_at_first_step_fraction": collapse_first_fraction,
        "far_above_q_fraction": far_above_fraction,
        "post_policy_below_q_fraction": post_policy_below_fraction,
        "recovery_unused_fraction_among_recovery_allocations": recovery_unused_fraction,
        "reconfiguration_unused_fraction_among_reconfiguration_allocations": reconfiguration_unused_fraction,
        "maintained_step_ratio_range": value_range(rows, "maintained_step_ratio"),
        "maintained_flow_ratio_range": value_range(rows, "maintained_flow_ratio"),
        "minimum_margin_range": value_range(rows, "minimum_margin"),
        "observed_score_range": score_range,
        "group_degeneracy_flags": "|".join(group_flags),
        "exclusion_recommendation": recommendation,
    }


def build_group_rows(rows: list[dict[str, str]]) -> list[dict[str, Any]]:
    grouped: dict[tuple[str, ...], list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[group_key(row)].append(row)
    return [
        group_summary_row(key, items)
        for key, items in sorted(grouped.items())
    ]


def summarize(
    rows: list[dict[str, str]],
    run_flag_rows: list[dict[str, Any]],
    group_rows: list[dict[str, Any]],
    *,
    status: str,
    non_claim: str,
) -> dict[str, Any]:
    group_flag_counts: Counter[str] = Counter()
    for row in group_rows:
        for flag in str(row["group_degeneracy_flags"]).split("|"):
            if flag:
                group_flag_counts[flag] += 1
    recommendation_counts = Counter(str(row["exclusion_recommendation"]) for row in group_rows)
    by_group_split: dict[str, Counter[str]] = defaultdict(Counter)
    for row in group_rows:
        by_group_split[str(row["group_split"])][str(row["exclusion_recommendation"])] += 1

    return {
        "status": status,
        "non_claim": non_claim,
        "runs": len(rows),
        "groups_evaluated": len(group_rows),
        "run_flag_counts": {
            str(row["flag"]): int(row["count"])
            for row in run_flag_rows
        },
        "group_flag_counts": dict(sorted(group_flag_counts.items())),
        "exclusion_recommendation_counts": dict(sorted(recommendation_counts.items())),
        "exclusion_recommendation_by_group_split": {
            key: dict(sorted(value.items()))
            for key, value in sorted(by_group_split.items())
        },
        "schema_fields": {
            "run_flags": list(run_flag_rows[0].keys()) if run_flag_rows else [],
            "group_summary": list(group_rows[0].keys()) if group_rows else [],
        },
    }


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        return
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def write_outputs(
    run_flag_rows: list[dict[str, Any]],
    group_rows: list[dict[str, Any]],
    summary: dict[str, Any],
    out_dir: Path,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    write_csv(out_dir / "degeneracy_run_flags.csv", run_flag_rows)
    write_csv(out_dir / "degeneracy_group_summary.csv", group_rows)
    (out_dir / "degeneracy_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def fail_if_outputs_exist(out_dir: Path, filenames: tuple[str, ...], *, allow_overwrite: bool) -> None:
    existing = [str(out_dir / name) for name in filenames if (out_dir / name).exists()]
    if existing and not allow_overwrite:
        raise SystemExit(
            "refusing to overwrite existing degeneracy output(s): "
            + ", ".join(existing)
            + " (use --allow-overwrite only for explicitly labeled reruns)"
        )


def require_primary_confirmation(args: argparse.Namespace) -> None:
    if not args.confirm_frozen_primary:
        raise SystemExit("--primary-run requires --confirm-frozen-primary")
    if not os.environ.get("CONFIRM_M_FLOW_PRIMARY"):
        raise SystemExit("--primary-run requires CONFIRM_M_FLOW_PRIMARY to be set")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=Path, default=DEFAULT_RUNS)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--primary-run", action="store_true")
    parser.add_argument("--confirm-frozen-primary", action="store_true")
    parser.add_argument("--allow-overwrite", action="store_true")
    args = parser.parse_args()

    if args.primary_run:
        require_primary_confirmation(args)
        fail_if_outputs_exist(
            args.out_dir,
            ("degeneracy_run_flags.csv", "degeneracy_group_summary.csv", "degeneracy_summary.json"),
            allow_overwrite=args.allow_overwrite,
        )
        status = "primary_degeneracy_report_v1_uninterpreted"
        non_claim = (
            "primary degeneracy report only; exclusion and support decisions "
            "must follow the frozen manifest"
        )
    else:
        status = "dry_run_degeneracy_report_v1_only"
        non_claim = "degeneracy schema/reporting smoke test only; not an exclusion decision"

    rows = read_rows(args.runs)
    run_flag_rows = build_run_flag_rows(rows)
    group_rows = build_group_rows(rows)
    summary = summarize(rows, run_flag_rows, group_rows, status=status, non_claim=non_claim)
    write_outputs(run_flag_rows, group_rows, summary, args.out_dir)
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))
    print(f"wrote: {args.out_dir / 'degeneracy_run_flags.csv'}")
    print(f"wrote: {args.out_dir / 'degeneracy_group_summary.csv'}")
    print(f"wrote: {args.out_dir / 'degeneracy_summary.json'}")


if __name__ == "__main__":
    main()
