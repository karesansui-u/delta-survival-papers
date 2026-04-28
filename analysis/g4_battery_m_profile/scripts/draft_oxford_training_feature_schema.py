#!/usr/bin/env python3
"""Draft an Oxford training-feature schema from converted training headers only.

This helper is intentionally pre-feature-smoke:
- validates the converted training manifest guardrails;
- reads manifest/header metadata only;
- emits candidate column families and a non-runnable schema template;
- emits no table values, features, predictions, metrics, or support flags.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from evaluate_oxford_part1_m_profile import (  # noqa: E402
    TEST_CELL_IDS,
    TRAIN_CELL_IDS,
    validate_converted_training_manifest,
)


CANDIDATE_PATTERNS = {
    "endpoint_like_capacity": ["capacity", "cap", "qdis", "q_dis", "discharge"],
    "time_or_index": ["time", "cycle", "index", "diagnostic", "test"],
    "voltage": ["voltage", "volt"],
    "current": ["current", "amp"],
    "temperature": ["temperature", "temp"],
    "resistance_or_impedance": ["resistance", "impedance", "eis", "ohm"],
    "recovery_like": ["rest", "relax", "recovery", "rebound"],
    "protocol_like": ["protocol", "group", "rate", "soc", "schedule"],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--converted-train-root",
        required=True,
        help="Training-only converted table root containing conversion_manifest.json.",
    )
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--allow-partial-converted-smoke",
        action="store_true",
        help="Allow MAX_RECORDS partial input for runtime sanity only; never promotion-eligible.",
    )
    return parser.parse_args()


def classify_columns(columns: list[str]) -> dict[str, list[str]]:
    classified: dict[str, list[str]] = {}
    for family, patterns in CANDIDATE_PATTERNS.items():
        matches = []
        for column in columns:
            lowered = column.lower()
            if any(pattern in lowered for pattern in patterns):
                matches.append(column)
        classified[family] = matches
    classified["generated_metadata_available"] = [
        "_sp_group_id",
        "_sp_cell_id",
        "_sp_diagnostic_index",
    ]
    return classified


def load_manifest(converted_root: Path) -> dict[str, Any]:
    manifest_path = converted_root / "conversion_manifest.json"
    with manifest_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> None:
    args = parse_args()
    converted_root = Path(args.converted_train_root)
    output = Path(args.output)

    converted_summary = validate_converted_training_manifest(
        converted_root,
        allow_partial=args.allow_partial_converted_smoke,
        hash_csv_contents=False,
    )
    manifest = load_manifest(converted_root)
    records = manifest["records"]
    column_sets = []
    for record in records:
        column_sets.append(
            {
                "entry_name": record.get("entry_name"),
                "cell_id": record.get("cell_id"),
                "diagnostic_index": record.get("diagnostic_index"),
                "column_count": len(record.get("column_names", [])),
                "column_names": record.get("column_names", []),
            }
        )

    column_union = converted_summary["column_name_union"]
    classified = classify_columns(column_union)
    schema_template = {
        "status": "training_feature_smoke_schema_template",
        "mode": "training_feature_smoke",
        "accepted_schema_status": "training_feature_smoke_schema_frozen",
        "human_finalized": False,
        "train_cell_ids": sorted(TRAIN_CELL_IDS),
        "heldout_cell_ids": sorted(TEST_CELL_IDS),
        "endpoint_column": "TBD_SELECT_ONE_FROM_endpoint_like_capacity",
        "model_features": {
            "B1": ["_sp_diagnostic_index"],
            "B2": ["_sp_diagnostic_index", "_sp_group_id"],
            "B3": [
                "_sp_diagnostic_index",
                "TBD_STANDARD_BATTERY_PRE_CUTOFF_COLUMNS",
            ],
            "primary": [
                "_sp_diagnostic_index",
                "TBD_B3_COLUMNS",
                "TBD_M_BUFFER_RECOVERY_RECONFIGURATION_COLUMNS",
            ],
        },
    }

    payload = {
        "status": (
            "training_feature_schema_partial_runtime_sanity_draft"
            if args.allow_partial_converted_smoke
            else "training_feature_schema_header_draft"
        ),
        "mode": "training_feature_schema_draft",
        "converted_root": str(converted_root),
        "manifest_guardrails_checked": converted_summary["manifest_guardrails_checked"],
        "promotion_eligible_converted_smoke": converted_summary[
            "promotion_eligible_converted_smoke"
        ],
        "partial_runtime_sanity": converted_summary["partial_runtime_sanity"],
        "record_count": converted_summary["record_count"],
        "exported_training_cell_ids": converted_summary["exported_training_cell_ids"],
        "missing_training_cell_ids": converted_summary["missing_training_cell_ids"],
        "heldout_cell_ids": sorted(TEST_CELL_IDS),
        "column_name_union": column_union,
        "candidate_column_families": classified,
        "schema_template": schema_template,
        "per_record_column_sets": column_sets,
        "primary_blocked": True,
        "metrics_emitted": False,
        "support_flags_emitted": False,
        "non_claims": [
            "no held-out payload values opened",
            "no training values read",
            "no converted CSV content hashes computed",
            "no endpoint values emitted",
            "no feature values emitted",
            "no predictions emitted",
            "no metrics emitted",
            "no support flags emitted",
        ],
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
