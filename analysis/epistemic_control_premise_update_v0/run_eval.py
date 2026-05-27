#!/usr/bin/env python3
"""Score the frozen premise-update epistemic-control protocol.

This runner is intentionally model-free. It reads the frozen
`llm_epistemic_premise_update_v0/tasks.jsonl` surface and a separate JSONL file
containing baseline / controlled outputs. It then applies the predeclared
stale-marker / updated-marker / safe-unknown readout and emits a result
certificate-shaped JSON summary.

It does not call an LLM, validate benchmark design, or prove real model
performance.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


PROTOCOL_ID = "llm_epistemic_premise_update_v0"
DEFAULT_RESULT_ID = "llm_epistemic_premise_update_v0_result_001"
RUNNER_VERSION = "0.1.0"
EXPECTED_TASKS_SHA256 = (
    "f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204"
)
EXPECTED_READOUT_ALIGNMENT = "premise_update_stale_loss_repair_v0"
EXPECTED_HORIZON = 1
EXPECTED_BASELINE_CONDITION = "ordinary_readout_without_dependency_refresh"
EXPECTED_CONTROLLED_CONDITION = "dependency_aware_premise_refresh"
EXPECTED_CASE_IDS = [
    "pu_001_office_relocation_station",
    "pu_002_address_change_local_services",
    "pu_003_job_change_commute",
    "pu_004_diet_change_lunch",
    "pu_005_allergy_update_menu",
    "pu_006_hobby_switch_sports_gear",
    "pu_007_household_change_housing",
    "pu_008_sleep_schedule_health",
    "pu_009_favorite_food_current_value",
    "pu_010_work_mode_commute_prep",
    "pu_011_language_goal_switch",
    "pu_012_deadline_extension",
]

TASK_REQUIRED_FIELDS = [
    "case_id",
    "failure_family",
    "horizon",
    "setup",
    "update",
    "probe",
    "baseline_condition",
    "controlled_condition",
    "oracle_pass",
    "oracle_fail",
    "stale_markers",
    "updated_markers",
    "safe_unknown_markers",
    "dependency_surface",
    "readout_alignment",
]
OUTPUT_REQUIRED_FIELDS = [
    "case_id",
    "horizon",
    "baseline_condition",
    "controlled_condition",
    "readout_alignment",
    "baseline_output",
    "controlled_output",
]


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_tasks_path() -> Path:
    return (
        repo_root()
        / "v3"
        / "05_evidence"
        / "llm_epistemic_premise_update_v0"
        / "tasks.jsonl"
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                value = json.loads(stripped)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{line_no}: invalid JSON: {exc}") from exc
            if not isinstance(value, dict):
                raise ValueError(f"{path}:{line_no}: expected a JSON object")
            rows.append(value)
    if not rows:
        raise ValueError(f"{path}: no rows found")
    return rows


def string_list(value: Any, field: str, case_id: str) -> list[str]:
    if not isinstance(value, list):
        raise ValueError(f"{case_id}: {field} must be a list")
    result: list[str] = []
    for index, item in enumerate(value):
        if not isinstance(item, str) or not item:
            raise ValueError(f"{case_id}: {field}[{index}] must be a nonempty string")
        result.append(item)
    return result


def contains_markers(text: str, markers: list[str]) -> list[str]:
    folded = text.casefold()
    return [marker for marker in markers if marker.casefold() in folded]


def validate_task_rows(rows: list[dict[str, Any]]) -> tuple[dict[str, dict[str, Any]], list[str]]:
    errors: list[str] = []
    tasks: dict[str, dict[str, Any]] = {}

    for row in rows:
        case_id = row.get("case_id", "<missing>")
        missing = [field for field in TASK_REQUIRED_FIELDS if field not in row]
        if missing:
            errors.append(f"{case_id}: task missing fields: {', '.join(missing)}")
            continue
        if not isinstance(case_id, str) or not case_id:
            errors.append("<unknown>: task case_id must be a nonempty string")
            continue
        if case_id in tasks:
            errors.append(f"{case_id}: duplicate task case_id")
            continue
        if row.get("horizon") != EXPECTED_HORIZON:
            errors.append(f"{case_id}: task horizon must be {EXPECTED_HORIZON}")
        if row.get("baseline_condition") != EXPECTED_BASELINE_CONDITION:
            errors.append(f"{case_id}: unexpected baseline_condition")
        if row.get("controlled_condition") != EXPECTED_CONTROLLED_CONDITION:
            errors.append(f"{case_id}: unexpected controlled_condition")
        if row.get("readout_alignment") != EXPECTED_READOUT_ALIGNMENT:
            errors.append(f"{case_id}: unexpected task readout_alignment")

        try:
            stale_markers = string_list(row["stale_markers"], "stale_markers", case_id)
            updated_markers = string_list(
                row["updated_markers"], "updated_markers", case_id
            )
            safe_unknown_markers = string_list(
                row["safe_unknown_markers"], "safe_unknown_markers", case_id
            )
            dependency_surface = string_list(
                row["dependency_surface"], "dependency_surface", case_id
            )
        except ValueError as exc:
            errors.append(str(exc))
            continue

        tasks[case_id] = {
            **row,
            "stale_markers": stale_markers,
            "updated_markers": updated_markers,
            "safe_unknown_markers": safe_unknown_markers,
            "dependency_surface": dependency_surface,
        }

    actual_ids = list(tasks)
    if actual_ids != EXPECTED_CASE_IDS:
        errors.append(
            "task surface case_ids/order mismatch: expected "
            f"{EXPECTED_CASE_IDS}, got {actual_ids}"
        )
    return tasks, errors


def validate_output_rows(rows: list[dict[str, Any]]) -> tuple[dict[str, dict[str, Any]], list[str]]:
    errors: list[str] = []
    outputs: dict[str, dict[str, Any]] = {}

    for row in rows:
        case_id = row.get("case_id", "<missing>")
        valid_for_scoring = True
        missing = [field for field in OUTPUT_REQUIRED_FIELDS if field not in row]
        if missing:
            errors.append(f"{case_id}: output missing fields: {', '.join(missing)}")
            continue
        if not isinstance(case_id, str) or not case_id:
            errors.append("<unknown>: output case_id must be a nonempty string")
            continue
        if case_id in outputs:
            errors.append(f"{case_id}: duplicate output case_id")
            continue
        if row.get("horizon") != EXPECTED_HORIZON:
            errors.append(f"{case_id}: output horizon must be {EXPECTED_HORIZON}")
        if row.get("baseline_condition") != EXPECTED_BASELINE_CONDITION:
            errors.append(f"{case_id}: unexpected output baseline_condition")
        if row.get("controlled_condition") != EXPECTED_CONTROLLED_CONDITION:
            errors.append(f"{case_id}: unexpected output controlled_condition")
        if row.get("readout_alignment") != EXPECTED_READOUT_ALIGNMENT:
            errors.append(f"{case_id}: unexpected output readout_alignment")

        baseline_output = row.get("baseline_output")
        controlled_output = row.get("controlled_output")
        if not isinstance(baseline_output, str) or not baseline_output.strip():
            errors.append(f"{case_id}: baseline_output must be a nonempty string")
            valid_for_scoring = False
        if not isinstance(controlled_output, str) or not controlled_output.strip():
            errors.append(f"{case_id}: controlled_output must be a nonempty string")
            valid_for_scoring = False

        if valid_for_scoring:
            outputs[case_id] = row

    actual_ids = list(outputs)
    if actual_ids != EXPECTED_CASE_IDS:
        errors.append(
            "output case_ids/order mismatch: expected "
            f"{EXPECTED_CASE_IDS}, got {actual_ids}"
        )
    return outputs, errors


def score_one(output: str, task: dict[str, Any]) -> dict[str, Any]:
    stale_hits = contains_markers(output, task["stale_markers"])
    updated_hits = contains_markers(output, task["updated_markers"])
    safe_unknown_hits = contains_markers(output, task["safe_unknown_markers"])
    folded_stale_hits = [marker.casefold() for marker in stale_hits]
    independent_updated_hits = [
        marker
        for marker in updated_hits
        if not any(marker.casefold() in stale for stale in folded_stale_hits)
    ]
    independent_safe_unknown_hits = [
        marker
        for marker in safe_unknown_hits
        if not any(marker.casefold() in stale for stale in folded_stale_hits)
    ]
    repair_hit = bool(independent_updated_hits or independent_safe_unknown_hits)

    # The frozen marker readout treats stale-only answers as contradiction loss.
    # Stale markers accompanied by an independent updated or safe-unknown marker
    # are kept audit-visible but not counted as stale-as-current by this
    # deterministic scorer.
    stale_as_current = bool(stale_hits and not repair_hit)
    mapped_to_frozen_fields = bool(stale_hits or updated_hits or safe_unknown_hits)

    return {
        "loss": 1 if stale_as_current else 0,
        "repair": 1 if repair_hit else 0,
        "stale_marker_hits": stale_hits,
        "updated_marker_hits": updated_hits,
        "safe_unknown_marker_hits": safe_unknown_hits,
        "mapped_to_frozen_fields": mapped_to_frozen_fields,
    }


def summarize(tasks_path: Path, outputs_path: Path, result_id: str) -> dict[str, Any]:
    task_sha = sha256_file(tasks_path)
    task_rows = load_jsonl(tasks_path)
    output_rows = load_jsonl(outputs_path)
    tasks, task_errors = validate_task_rows(task_rows)
    outputs, output_errors = validate_output_rows(output_rows)
    errors = [*task_errors, *output_errors]

    task_surface_digest_matches = task_sha == EXPECTED_TASKS_SHA256
    if not task_surface_digest_matches:
        errors.append(
            "task surface digest mismatch: expected "
            f"{EXPECTED_TASKS_SHA256}, got {task_sha}"
        )

    case_summaries: list[dict[str, Any]] = []
    silence_cases: list[str] = []
    for case_id in EXPECTED_CASE_IDS:
        task = tasks.get(case_id)
        output = outputs.get(case_id)
        if task is None or output is None:
            continue
        baseline_score = score_one(output["baseline_output"], task)
        controlled_score = score_one(output["controlled_output"], task)
        if not baseline_score["mapped_to_frozen_fields"] or not controlled_score[
            "mapped_to_frozen_fields"
        ]:
            silence_cases.append(case_id)

        case_summaries.append(
            {
                "case_id": case_id,
                "failure_family": task["failure_family"],
                "horizon": task["horizon"],
                "baseline_condition": output["baseline_condition"],
                "controlled_condition": output["controlled_condition"],
                "readout_alignment": output["readout_alignment"],
                "baseline_output": output["baseline_output"],
                "controlled_output": output["controlled_output"],
                "baseline_loss": baseline_score["loss"],
                "controlled_loss": controlled_score["loss"],
                "baseline_repair": baseline_score["repair"],
                "controlled_repair": controlled_score["repair"],
                "baseline_marker_hits": {
                    "stale": baseline_score["stale_marker_hits"],
                    "updated": baseline_score["updated_marker_hits"],
                    "safe_unknown": baseline_score["safe_unknown_marker_hits"],
                },
                "controlled_marker_hits": {
                    "stale": controlled_score["stale_marker_hits"],
                    "updated": controlled_score["updated_marker_hits"],
                    "safe_unknown": controlled_score["safe_unknown_marker_hits"],
                },
                "baseline_mapped_to_frozen_fields": baseline_score[
                    "mapped_to_frozen_fields"
                ],
                "controlled_mapped_to_frozen_fields": controlled_score[
                    "mapped_to_frozen_fields"
                ],
                "dependency_surface": task["dependency_surface"],
            }
        )

    baseline_loss_sum = sum(case["baseline_loss"] for case in case_summaries)
    controlled_loss_sum = sum(case["controlled_loss"] for case in case_summaries)
    baseline_repair_sum = sum(case["baseline_repair"] for case in case_summaries)
    controlled_repair_sum = sum(case["controlled_repair"] for case in case_summaries)
    baseline_net_action = baseline_loss_sum - baseline_repair_sum
    controlled_net_action = controlled_loss_sum - controlled_repair_sum
    aggregate_loss_dominance = controlled_loss_sum <= baseline_loss_sum
    aggregate_repair_dominance = baseline_repair_sum <= controlled_repair_sum
    metric_dominance = aggregate_loss_dominance and aggregate_repair_dominance
    no_worse_net_action = controlled_net_action <= baseline_net_action

    frozen_task_surface = (
        task_surface_digest_matches
        and list(tasks) == EXPECTED_CASE_IDS
        and list(outputs) == EXPECTED_CASE_IDS
    )
    same_horizon = all(case["horizon"] == EXPECTED_HORIZON for case in case_summaries)
    frozen_readout = all(
        case["readout_alignment"] == EXPECTED_READOUT_ALIGNMENT
        for case in case_summaries
    )
    outputs_complete = len(case_summaries) == len(EXPECTED_CASE_IDS)
    raw_outputs_retained = all(
        bool(case["baseline_output"].strip()) and bool(case["controlled_output"].strip())
        for case in case_summaries
    )
    silence = bool(silence_cases)
    invalid_run = bool(errors)
    protocol_shape_valid = (
        frozen_task_surface
        and same_horizon
        and frozen_readout
        and outputs_complete
        and raw_outputs_retained
        and not invalid_run
        and not silence
        and metric_dominance
        and no_worse_net_action
    )

    if invalid_run:
        decision = "invalid_run"
    elif silence:
        decision = "silence"
    elif metric_dominance and no_worse_net_action:
        decision = "support"
    else:
        decision = "no_support"

    return {
        "artifact_type": "premise_update_protocol_result",
        "protocol_id": PROTOCOL_ID,
        "result_id": result_id,
        "runner_version": RUNNER_VERSION,
        "tasks_path": str(tasks_path),
        "outputs_path": str(outputs_path),
        "tasks_sha256": task_sha,
        "expected_tasks_sha256": EXPECTED_TASKS_SHA256,
        "task_count": len(case_summaries),
        "case_ids": [case["case_id"] for case in case_summaries],
        "horizons": sorted({case["horizon"] for case in case_summaries}),
        "readout_alignment": EXPECTED_READOUT_ALIGNMENT,
        "checks": {
            "frozen_task_surface": frozen_task_surface,
            "task_surface_digest_matches": task_surface_digest_matches,
            "frozen_readout": frozen_readout,
            "same_horizon": same_horizon,
            "outputs_complete": outputs_complete,
            "raw_outputs_retained": raw_outputs_retained,
            "aggregate_loss_dominance": aggregate_loss_dominance,
            "aggregate_repair_dominance": aggregate_repair_dominance,
            "metric_dominance": metric_dominance,
            "readout_alignment": frozen_readout,
            "no_worse_net_action": no_worse_net_action,
            "silence": silence,
            "invalid_run": invalid_run,
            "protocol_shape_valid": protocol_shape_valid,
        },
        "totals": {
            "baseline_loss_sum": baseline_loss_sum,
            "controlled_loss_sum": controlled_loss_sum,
            "baseline_repair_sum": baseline_repair_sum,
            "controlled_repair_sum": controlled_repair_sum,
            "baseline_net_action": baseline_net_action,
            "controlled_net_action": controlled_net_action,
        },
        "decision": decision,
        "silence_cases": silence_cases,
        "case_summaries": case_summaries,
        "errors": errors,
        "claim_boundary": (
            "This result is a marker-based score over externally supplied "
            "baseline / controlled outputs for a frozen premise-update task "
            "surface. It does not prove real LLM semantics, model performance, "
            "memory safety, continual-learning safety, or workflow correctness."
        ),
    }


def markdown_value(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False)


def write_markdown(summary: dict[str, Any], path: Path) -> None:
    checks = summary["checks"]
    totals = summary["totals"]
    lines = [
        "LLM Epistemic Premise Update v0 Score Summary",
        "================================================",
        "",
        "Status: marker-based protocol score; not model validation by itself",
        "",
        f"artifact_type: `{summary['artifact_type']}`",
        f"protocol_id: `{summary['protocol_id']}`",
        f"result_id: `{summary['result_id']}`",
        f"runner_version: `{summary['runner_version']}`",
        f"decision: `{summary['decision']}`",
        f"tasks_sha256: `{summary['tasks_sha256']}`",
        "",
        "Checks",
        "------",
        "",
        f"- frozen_task_surface: `{markdown_value(checks['frozen_task_surface'])}`",
        f"- task_surface_digest_matches: `{markdown_value(checks['task_surface_digest_matches'])}`",
        f"- frozen_readout: `{markdown_value(checks['frozen_readout'])}`",
        f"- same_horizon: `{markdown_value(checks['same_horizon'])}`",
        f"- outputs_complete: `{markdown_value(checks['outputs_complete'])}`",
        f"- raw_outputs_retained: `{markdown_value(checks['raw_outputs_retained'])}`",
        f"- metric_dominance: `{markdown_value(checks['metric_dominance'])}`",
        f"- readout_alignment: `{markdown_value(checks['readout_alignment'])}`",
        f"- no_worse_net_action: `{markdown_value(checks['no_worse_net_action'])}`",
        f"- silence: `{markdown_value(checks['silence'])}`",
        f"- invalid_run: `{markdown_value(checks['invalid_run'])}`",
        f"- protocol_shape_valid: `{markdown_value(checks['protocol_shape_valid'])}`",
        "",
        "Totals",
        "------",
        "",
        f"- baseline_loss_sum: `{totals['baseline_loss_sum']}`",
        f"- controlled_loss_sum: `{totals['controlled_loss_sum']}`",
        f"- baseline_repair_sum: `{totals['baseline_repair_sum']}`",
        f"- controlled_repair_sum: `{totals['controlled_repair_sum']}`",
        f"- baseline_net_action: `{totals['baseline_net_action']}`",
        f"- controlled_net_action: `{totals['controlled_net_action']}`",
        "",
        "Claim Boundary",
        "--------------",
        "",
        summary["claim_boundary"],
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tasks",
        type=Path,
        default=default_tasks_path(),
        help="Path to the frozen premise-update tasks.jsonl file.",
    )
    parser.add_argument(
        "--outputs",
        type=Path,
        required=True,
        help="JSONL file with baseline_output and controlled_output rows.",
    )
    parser.add_argument(
        "--result-id",
        default=DEFAULT_RESULT_ID,
        help="Stable identifier for the emitted result artifact.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        help="Optional JSON output path. Defaults to stdout.",
    )
    parser.add_argument(
        "--summary-md",
        type=Path,
        help="Optional Markdown summary output path.",
    )
    args = parser.parse_args()

    summary = summarize(args.tasks, args.outputs, args.result_id)
    rendered = json.dumps(summary, indent=2, sort_keys=True, ensure_ascii=False)

    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered + "\n", encoding="utf-8")
    else:
        print(rendered)

    if args.summary_md:
        args.summary_md.parent.mkdir(parents=True, exist_ok=True)
        write_markdown(summary, args.summary_md)

    return 0 if summary["checks"]["protocol_shape_valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
