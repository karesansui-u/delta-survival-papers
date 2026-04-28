#!/usr/bin/env python3
"""Oxford Path Dependent no-metric RPT / diagnostic structure counter.

This script parses archive entry names only. It does not open MATLAB files, read
capacity values, compute labels, construct features, fit models, or emit support
flags.
"""

from __future__ import annotations

import argparse
import json
import re
import zipfile
from collections import defaultdict
from pathlib import Path
from typing import Any


H_COUNT = 1
H_COUNT_SECONDARY = 2

PROMOTION_THRESHOLDS: dict[str, Any] = {
    "T1_unique_cells_min": 12,
    "T2_groups_min": 4,
    "T2_cells_per_group_min": 2,
    "T3_group_folds_min": 2,
    "T3_cell_folds_min": 6,
    "T4_candidate_rows_h1_min": 60,
    "T5_min_rows_per_fold_h1": 5,
    "T6_required_families": [
        "buffer",
        "recovery",
        "reconfiguration",
        "consumption",
    ],
    "T6_precutoff_features_only": True,
}

GROUP_ARCHIVES = {
    "part1": ["Group_1.zip", "Group_2.zip", "Group_3.zip", "Group_4.zip"],
}

ENTRY_RE = re.compile(
    r"^Group\s+(?P<group>\d+)/TPG(?P=group)(?:\.(?P<index>\d+))?\s*-\s*Cell\s*(?P<cell>\d+)\.mat$",
    re.IGNORECASE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        required=True,
        help="Directory containing Oxford Path Dependent files split into part1/part2/part3.",
    )
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--part",
        choices=sorted(GROUP_ARCHIVES),
        default="part1",
        help="Archive part to count. Currently only part1 is supported.",
    )
    return parser.parse_args()


def parse_entry_name(name: str) -> dict[str, Any] | None:
    match = ENTRY_RE.match(name)
    if match is None:
        return None
    group = int(match.group("group"))
    cell = int(match.group("cell"))
    raw_index = match.group("index")
    diagnostic_index = 0 if raw_index is None else int(raw_index)
    return {
        "group": group,
        "cell": cell,
        "diagnostic_index": diagnostic_index,
        "entry_name": name,
    }


def group_archive_path(root: Path, part: str, filename: str) -> Path:
    candidates = [
        root / part / filename,
        root / part.upper() / filename,
        root / part.capitalize() / filename,
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise SystemExit(f"Missing required group archive for {part}: {filename}")


def count_candidate_rows(indices: list[int], horizon: int) -> int:
    ordered = sorted(set(indices))
    available = set(ordered)
    return sum(1 for idx in ordered if idx + horizon in available)


def main() -> None:
    args = parse_args()
    root = Path(args.root)
    output = Path(args.output)
    part = args.part

    parsed_entries: list[dict[str, Any]] = []
    unmatched_entries: list[str] = []
    archives: dict[str, dict[str, Any]] = {}

    for archive_name in GROUP_ARCHIVES[part]:
        archive_path = group_archive_path(root, part, archive_name)
        with zipfile.ZipFile(archive_path) as archive:
            mat_entries = [name for name in archive.namelist() if name.lower().endswith(".mat")]
        archive_parsed = []
        archive_unmatched = []
        for entry in mat_entries:
            parsed = parse_entry_name(entry)
            if parsed is None:
                archive_unmatched.append(entry)
                unmatched_entries.append(entry)
                continue
            parsed["part"] = part
            parsed["archive"] = archive_name
            archive_parsed.append(parsed)
            parsed_entries.append(parsed)
        archives[archive_name] = {
            "path": str(archive_path),
            "mat_entries": len(mat_entries),
            "parsed_entries": len(archive_parsed),
            "unmatched_entries": len(archive_unmatched),
        }

    by_cell_series: dict[int, list[tuple[int, list[int]]]] = defaultdict(list)
    by_group_cell: dict[int, dict[int, list[int]]] = defaultdict(lambda: defaultdict(list))
    for entry in parsed_entries:
        group = int(entry["group"])
        cell = int(entry["cell"])
        index = int(entry["diagnostic_index"])
        by_group_cell[group][cell].append(index)

    for group, cells in by_group_cell.items():
        for cell, indices in cells.items():
            by_cell_series[cell].append((group, indices))

    cells_per_group = {
        str(group): len(cells)
        for group, cells in sorted(by_group_cell.items())
    }
    group_cell_series = {
        f"group{group}_cell{cell}": sorted(set(indices))
        for group, cells in sorted(by_group_cell.items())
        for cell, indices in sorted(cells.items())
    }
    diagnostic_entries_per_cell = {
        str(cell): sum(len(sorted(set(indices))) for _, indices in series)
        for cell, series in sorted(by_cell_series.items())
    }
    diagnostic_index_min_max_per_group_cell = {
        key: {
            "min": min(indices),
            "max": max(indices),
        }
        for key, indices in sorted(group_cell_series.items())
    }

    candidate_rows_h1_per_cell = {
        str(cell): sum(count_candidate_rows(indices, H_COUNT) for _, indices in series)
        for cell, series in sorted(by_cell_series.items())
    }
    candidate_rows_h2_per_cell = {
        str(cell): sum(count_candidate_rows(indices, H_COUNT_SECONDARY) for _, indices in series)
        for cell, series in sorted(by_cell_series.items())
    }

    candidate_rows_h1_per_group = {}
    candidate_rows_h2_per_group = {}
    for group, cells in sorted(by_group_cell.items()):
        candidate_rows_h1_per_group[str(group)] = sum(
            count_candidate_rows(indices, H_COUNT) for indices in cells.values()
        )
        candidate_rows_h2_per_group[str(group)] = sum(
            count_candidate_rows(indices, H_COUNT_SECONDARY) for indices in cells.values()
        )

    cell_group_memberships = {
        str(cell): sorted(group for group, _ in series)
        for cell, series in sorted(by_cell_series.items())
    }
    duplicate_cell_ids = {
        cell: groups
        for cell, groups in cell_group_memberships.items()
        if len(groups) > 1
    }

    group_fold_cell_overlap: dict[str, list[int]] = {}
    group_fold_rows_h1: dict[str, int] = {}
    for group, cells in sorted(by_group_cell.items()):
        test_cell_ids = set(cells)
        train_cell_ids = {
            cell
            for other_group, other_cells in by_group_cell.items()
            if other_group != group
            for cell in other_cells
        }
        group_fold_cell_overlap[str(group)] = sorted(test_cell_ids & train_cell_ids)
        group_fold_rows_h1[str(group)] = candidate_rows_h1_per_group[str(group)]

    safe_group_fold_rows = [
        rows
        for group, rows in group_fold_rows_h1.items()
        if rows >= PROMOTION_THRESHOLDS["T5_min_rows_per_fold_h1"]
        and not group_fold_cell_overlap[group]
    ]
    heldout_group_folds = len(safe_group_fold_rows)
    heldout_cell_folds = sum(
        1
        for rows in candidate_rows_h1_per_cell.values()
        if rows >= PROMOTION_THRESHOLDS["T5_min_rows_per_fold_h1"]
    )
    min_group_rows = min(safe_group_fold_rows) if safe_group_fold_rows else 0
    min_cell_rows = min(candidate_rows_h1_per_cell.values()) if candidate_rows_h1_per_cell else 0

    unique_cells = len(by_cell_series)
    retained_groups = len(by_group_cell)
    candidate_rows_h1 = sum(candidate_rows_h1_per_cell.values())
    candidate_rows_h2 = sum(candidate_rows_h2_per_cell.values())
    chosen_split_level = (
        "heldout_protocol_group"
        if heldout_group_folds >= PROMOTION_THRESHOLDS["T3_group_folds_min"]
        else "heldout_cell_id"
        if heldout_cell_folds >= PROMOTION_THRESHOLDS["T3_cell_folds_min"]
        else "none"
    )

    t6_family_availability = {
        "basis_type": "manual_public_metadata_availability_assertion_only",
        "automated_from_zip_entries": False,
        "not_feature_computability_validation": True,
        "buffer_available": True,
        "buffer_basis": "Part 1 public guide/readme describe capacity and voltage fields; values not read.",
        "recovery_available": True,
        "recovery_basis": "Part 1 protocol includes calendar-aging/rest-like intervals and EIS archive; values not read.",
        "reconfiguration_available": True,
        "reconfiguration_basis": "Protocol group and cycling/calendar schedule metadata are available before cutoff.",
        "consumption_available": True,
        "consumption_basis": "Cycle/test indices, C-rate group, and schedule metadata are available before cutoff.",
        "precutoff_only": True,
    }

    threshold_checks = {
        "T1_unique_cells": unique_cells >= PROMOTION_THRESHOLDS["T1_unique_cells_min"],
        "T2_groups": retained_groups >= PROMOTION_THRESHOLDS["T2_groups_min"],
        "T2_cells_per_group": all(
            count >= PROMOTION_THRESHOLDS["T2_cells_per_group_min"]
            for count in cells_per_group.values()
        ),
        "T3_group_or_cell_folds": (
            heldout_group_folds >= PROMOTION_THRESHOLDS["T3_group_folds_min"]
            or heldout_cell_folds >= PROMOTION_THRESHOLDS["T3_cell_folds_min"]
        ),
        "T4_candidate_rows_h1": candidate_rows_h1 >= PROMOTION_THRESHOLDS["T4_candidate_rows_h1_min"],
        "T5_min_rows_per_fold_h1": (
            min_group_rows >= PROMOTION_THRESHOLDS["T5_min_rows_per_fold_h1"]
            if heldout_group_folds >= PROMOTION_THRESHOLDS["T3_group_folds_min"]
            else min_cell_rows >= PROMOTION_THRESHOLDS["T5_min_rows_per_fold_h1"]
        ),
        "T6_public_metadata_availability_only_buffer": bool(t6_family_availability["buffer_available"]),
        "T6_public_metadata_availability_only_recovery": bool(t6_family_availability["recovery_available"]),
        "T6_public_metadata_availability_only_reconfiguration": bool(t6_family_availability["reconfiguration_available"]),
        "T6_public_metadata_availability_only_consumption": bool(t6_family_availability["consumption_available"]),
        "T6_public_metadata_availability_only_precutoff": bool(t6_family_availability["precutoff_only"]),
    }

    payload: dict[str, Any] = {
        "status": "pre-freeze no-metric structural counts",
        "part": part,
        "count_source": "zip entry names and public guide/readme metadata only",
        "no_value_inspection": True,
        "h_count": H_COUNT,
        "h_count_secondary": H_COUNT_SECONDARY,
        "archives": archives,
        "unique_cells": unique_cells,
        "retained_protocol_groups": retained_groups,
        "cells_per_group": cells_per_group,
        "group_cell_series_count": len(group_cell_series),
        "cell_group_memberships": cell_group_memberships,
        "diagnostic_entries_per_cell": diagnostic_entries_per_cell,
        "diagnostic_index_min_max_per_group_cell": diagnostic_index_min_max_per_group_cell,
        "candidate_rows_h1": candidate_rows_h1,
        "candidate_rows_h2": candidate_rows_h2,
        "candidate_rows_h1_per_group": candidate_rows_h1_per_group,
        "candidate_rows_h2_per_group": candidate_rows_h2_per_group,
        "candidate_rows_h1_per_cell": candidate_rows_h1_per_cell,
        "candidate_rows_h2_per_cell": candidate_rows_h2_per_cell,
        "heldout_group_folds": heldout_group_folds,
        "heldout_cell_folds": heldout_cell_folds,
        "chosen_split_level_by_prefixed_rule": chosen_split_level,
        "nominal_heldout_group_folds_before_cell_leakage_check": len(candidate_rows_h1_per_group),
        "group_fold_cell_overlap": group_fold_cell_overlap,
        "min_candidate_rows_per_group_fold_h1": min_group_rows,
        "min_candidate_rows_per_cell_fold_h1": min_cell_rows,
        "duplicate_cell_reconciliation": {
            "scope": "part1 only",
            "needed": bool(duplicate_cell_ids),
            "duplicate_cell_ids": duplicate_cell_ids,
            "conservative_policy": "Treat repeated cell IDs across groups as the same physical unit unless the guide proves otherwise; do not split the same cell ID across train/test.",
        },
        "t6_family_availability": t6_family_availability,
        "promotion_thresholds": PROMOTION_THRESHOLDS,
        "threshold_checks": threshold_checks,
        "promotion_allowed_for_freeze_manifest_draft": all(threshold_checks.values()) and not unmatched_entries,
        "promotion_caveat": "T6 is a public-metadata availability assertion only, not an automated feature-computability validation.",
        "unmatched_entries": unmatched_entries,
        "non_claims": [
            "no capacity values emitted",
            "no labels emitted",
            "no features computed",
            "no model metrics computed",
            "no support flags emitted",
        ],
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")


if __name__ == "__main__":
    main()
