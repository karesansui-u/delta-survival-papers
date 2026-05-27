#!/usr/bin/env python3
"""Run the v1 scorer preflight suite.

The preflight suite is a frozen set of synthetic outputs used to check marker
coverage before outcome-bearing model output collection starts. It is not a
model evaluation.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from run_eval import default_tasks_path, load_jsonl, score_output, sha256_file, validate_task_rows


EXPECTED_PREFLIGHT_SHA256 = (
    "c29cf2a943955eb05f849cbf0a333394c88e8ad6547f3bdc70f2f1a8fb3a6266"
)
EXPECTED_SAMPLE_IDS = [
    "pf_001_stale_current",
    "pf_002_updated_current",
    "pf_003_mixed_current",
    "pf_004_historical_then_updated",
    "pf_005_terse_ambiguous",
    "pf_006_unmapped",
    "pf_007_timeout_status",
    "pf_008_negated_stale_then_updated",
    "pf_009_updated_phrase_contains_stale_token",
    "pf_010_far_historical_scope_does_not_cancel_stale",
    "pf_011_confirm_stale_current",
    "pf_012_pure_safe_unknown",
    "pf_013_ambiguous_plus_repair",
]


def default_preflight_path() -> Path:
    return Path(__file__).resolve().parent / "preflight_cases.jsonl"


def expected_matches(actual: dict[str, Any], expected: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for field, expected_value in expected.items():
        actual_value = actual.get(field)
        if actual_value != expected_value:
            errors.append(f"{field}: expected {expected_value!r}, got {actual_value!r}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tasks",
        type=Path,
        default=default_tasks_path(),
        help="Path to the frozen v1 tasks.jsonl file.",
    )
    parser.add_argument(
        "--preflight",
        type=Path,
        default=default_preflight_path(),
        help="Path to the frozen preflight_cases.jsonl file.",
    )
    args = parser.parse_args()

    tasks, task_errors = validate_task_rows(load_jsonl(args.tasks))
    if task_errors:
        for error in task_errors:
            print(f"task_error: {error}")
        return 1

    failures: list[str] = []
    checked = 0
    preflight_sha = sha256_file(args.preflight)
    if preflight_sha != EXPECTED_PREFLIGHT_SHA256:
        failures.append(
            "preflight digest mismatch: expected "
            f"{EXPECTED_PREFLIGHT_SHA256}, got {preflight_sha}"
        )
    rows = load_jsonl(args.preflight)
    sample_ids = [row.get("sample_id") for row in rows]
    if sample_ids != EXPECTED_SAMPLE_IDS:
        failures.append(
            "preflight sample_ids/order mismatch: expected "
            f"{EXPECTED_SAMPLE_IDS}, got {sample_ids}"
        )

    for row in rows:
        sample_id = row.get("sample_id", "<missing>")
        case_id = row.get("case_id")
        output = row.get("output")
        status = row.get("status", "ok")
        expected = row.get("expected")
        if not isinstance(case_id, str) or case_id not in tasks:
            failures.append(f"{sample_id}: unknown case_id {case_id!r}")
            continue
        if not isinstance(output, str):
            failures.append(f"{sample_id}: output must be a string")
            continue
        if not isinstance(expected, dict):
            failures.append(f"{sample_id}: expected must be an object")
            continue
        actual = score_output(output, status, tasks[case_id])
        mismatches = expected_matches(actual, expected)
        if mismatches:
            failures.append(f"{sample_id}: " + "; ".join(mismatches))
        checked += 1

    if failures:
        print(
            json.dumps(
                {
                    "preflight_ok": False,
                    "checked": checked,
                    "preflight_sha256": preflight_sha,
                    "failures": failures,
                },
                indent=2,
            )
        )
        return 1

    print(
        json.dumps(
            {
                "preflight_ok": True,
                "checked": checked,
                "preflight_sha256": preflight_sha,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
