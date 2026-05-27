#!/usr/bin/env python3
"""Score the v1 premise-update epistemic-control protocol.

This scorer is model-free. It consumes a frozen task surface and externally
supplied baseline / controlled outputs, then applies a predeclared slot-state
readout. The readout is deterministic and finite: regex concept hits, stance
hits, and scope hits are all frozen in the task file before outcome-bearing
execution.

It does not call an LLM, validate natural-language semantics, validate a real
benchmark, or prove model performance.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


PROTOCOL_ID = "llm_epistemic_premise_update_v1"
DEFAULT_RESULT_ID = "llm_epistemic_premise_update_v1_result_001"
RUNNER_VERSION = "0.1.0"
EXPECTED_TASKS_SHA256 = (
    "ba273ed2f870a241053a508538ea39bf5c6c0a353d44c3b82005487be7279efb"
)
EXPECTED_READOUT_ALIGNMENT = "premise_update_slot_state_v1"
EXPECTED_HORIZON = 1
EXPECTED_HORIZON_MODE = "batch_as_single_step_horizon_1"
EXPECTED_BASELINE_CONDITION = "ordinary_readout_without_dependency_refresh"
EXPECTED_CONTROLLED_CONDITION = "dependency_aware_premise_refresh"
EXPECTED_OUTPUT_STATUSES = {"ok", "timeout", "tool_error", "refusal", "empty", "truncated"}
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
    "horizon_mode",
    "setup",
    "update",
    "probe",
    "baseline_condition",
    "controlled_condition",
    "answer_target",
    "concept_patterns",
    "stale_current_patterns",
    "updated_current_patterns",
    "safe_unknown_patterns",
    "historical_scope_patterns",
    "negation_scope_patterns",
    "invalidation_scope_patterns",
    "dependency_surface",
    "readout_alignment",
]

OUTPUT_REQUIRED_FIELDS = [
    "case_id",
    "horizon",
    "horizon_mode",
    "baseline_condition",
    "controlled_condition",
    "readout_alignment",
    "setup",
    "update",
    "probe",
    "baseline_status",
    "controlled_status",
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
        / "llm_epistemic_premise_update_v1"
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


def dict_field(value: Any, field: str, case_id: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ValueError(f"{case_id}: {field} must be an object")
    return value


def regex_matches(text: str, patterns: list[str]) -> list[dict[str, Any]]:
    matches: list[dict[str, Any]] = []
    for pattern in patterns:
        for match in re.finditer(pattern, text, flags=re.IGNORECASE):
            matches.append(
                {"pattern": pattern, "start": match.start(), "end": match.end()}
            )
    return matches


def match_patterns(matches: list[dict[str, Any]]) -> list[str]:
    return sorted({match["pattern"] for match in matches})


def overlaps(left: dict[str, Any], right: dict[str, Any]) -> bool:
    return left["start"] < right["end"] and right["start"] < left["end"]


def nearby(left: dict[str, Any], right: dict[str, Any], window: int = 36) -> bool:
    return right["start"] <= left["end"] + window and left["start"] <= right["end"] + window


def stale_match_scoped(
    stale_match: dict[str, Any],
    updated_matches: list[dict[str, Any]],
    safe_unknown_matches: list[dict[str, Any]],
    historical_matches: list[dict[str, Any]],
    negation_matches: list[dict[str, Any]],
) -> bool:
    """Conservatively decide whether a stale hit is visibly non-current.

    Broad scope terms elsewhere in the claim unit must not erase stale-current
    loss. A stale hit is non-current only when it overlaps a repair/scope phrase
    or has a frozen historical / negation marker close to the stale span itself.
    """

    if any(overlaps(stale_match, match) for match in updated_matches):
        return True
    if any(overlaps(stale_match, match) for match in safe_unknown_matches):
        return True
    if any(overlaps(stale_match, match) for match in historical_matches):
        return True
    if any(overlaps(stale_match, match) for match in negation_matches):
        return True
    return any(nearby(stale_match, match) for match in [*historical_matches, *negation_matches])


def split_claim_units(text: str) -> list[str]:
    raw_units = re.split(r"[\n\r]+|(?<=[.!?。！？])\s+|;\s+|\s+-\s+", text.strip())
    units = [unit.strip(" \t-*") for unit in raw_units if unit.strip(" \t-*")]
    return units or [text.strip()]


def normalize_task_row(row: dict[str, Any]) -> dict[str, Any]:
    case_id = row["case_id"]
    answer_target = dict_field(row["answer_target"], "answer_target", case_id)
    for required in ["slot_id", "probe_act", "expected_stance"]:
        if not isinstance(answer_target.get(required), str) or not answer_target[required]:
            raise ValueError(f"{case_id}: answer_target.{required} must be a nonempty string")

    normalized = {
        **row,
        "answer_target": answer_target,
        "concept_patterns": string_list(row["concept_patterns"], "concept_patterns", case_id),
        "stale_current_patterns": string_list(
            row["stale_current_patterns"], "stale_current_patterns", case_id
        ),
        "updated_current_patterns": string_list(
            row["updated_current_patterns"], "updated_current_patterns", case_id
        ),
        "safe_unknown_patterns": string_list(
            row["safe_unknown_patterns"], "safe_unknown_patterns", case_id
        ),
        "historical_scope_patterns": string_list(
            row["historical_scope_patterns"], "historical_scope_patterns", case_id
        ),
        "negation_scope_patterns": string_list(
            row["negation_scope_patterns"], "negation_scope_patterns", case_id
        ),
        "invalidation_scope_patterns": string_list(
            row["invalidation_scope_patterns"], "invalidation_scope_patterns", case_id
        ),
        "dependency_surface": string_list(
            row["dependency_surface"], "dependency_surface", case_id
        ),
    }
    return normalized


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
        if row.get("horizon_mode") != EXPECTED_HORIZON_MODE:
            errors.append(f"{case_id}: unexpected horizon_mode")
        if row.get("baseline_condition") != EXPECTED_BASELINE_CONDITION:
            errors.append(f"{case_id}: unexpected baseline_condition")
        if row.get("controlled_condition") != EXPECTED_CONTROLLED_CONDITION:
            errors.append(f"{case_id}: unexpected controlled_condition")
        if row.get("readout_alignment") != EXPECTED_READOUT_ALIGNMENT:
            errors.append(f"{case_id}: unexpected task readout_alignment")
        try:
            tasks[case_id] = normalize_task_row(row)
        except ValueError as exc:
            errors.append(str(exc))

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
        if row.get("horizon_mode") != EXPECTED_HORIZON_MODE:
            errors.append(f"{case_id}: unexpected output horizon_mode")
        if row.get("baseline_condition") != EXPECTED_BASELINE_CONDITION:
            errors.append(f"{case_id}: unexpected output baseline_condition")
        if row.get("controlled_condition") != EXPECTED_CONTROLLED_CONDITION:
            errors.append(f"{case_id}: unexpected output controlled_condition")
        if row.get("readout_alignment") != EXPECTED_READOUT_ALIGNMENT:
            errors.append(f"{case_id}: unexpected output readout_alignment")

        for field in ["baseline_status", "controlled_status"]:
            if row.get(field) not in EXPECTED_OUTPUT_STATUSES:
                errors.append(f"{case_id}: {field} must be one of {sorted(EXPECTED_OUTPUT_STATUSES)}")
        for field in ["setup", "update", "probe", "baseline_output", "controlled_output"]:
            if not isinstance(row.get(field), str):
                errors.append(f"{case_id}: {field} must be a string")

        outputs[case_id] = row

    actual_ids = list(outputs)
    if actual_ids != EXPECTED_CASE_IDS:
        errors.append(
            "output case_ids/order mismatch: expected "
            f"{EXPECTED_CASE_IDS}, got {actual_ids}"
        )
    return outputs, errors


def score_claim_unit(text: str, task: dict[str, Any]) -> dict[str, Any]:
    concept_matches = regex_matches(text, task["concept_patterns"])
    stale_matches = regex_matches(text, task["stale_current_patterns"])
    updated_matches = regex_matches(text, task["updated_current_patterns"])
    safe_unknown_matches = regex_matches(text, task["safe_unknown_patterns"])
    historical_matches = regex_matches(text, task["historical_scope_patterns"])
    negation_matches = regex_matches(text, task["negation_scope_patterns"])
    invalidation_matches = regex_matches(text, task["invalidation_scope_patterns"])

    stale_current_matches = [
        match
        for match in stale_matches
        if not stale_match_scoped(
            match,
            updated_matches,
            safe_unknown_matches,
            historical_matches,
            negation_matches,
        )
    ]
    stale_noncurrent_matches = [
        match for match in stale_matches if match not in stale_current_matches
    ]
    concept_hits = match_patterns(concept_matches)
    stale_current_hits = match_patterns(stale_current_matches)
    stale_noncurrent_hits = match_patterns(stale_noncurrent_matches)
    updated_hits = match_patterns(updated_matches)
    safe_unknown_hits = match_patterns(safe_unknown_matches)
    historical_hits = match_patterns(historical_matches)
    negation_hits = match_patterns(negation_matches)
    invalidation_hits = match_patterns(invalidation_matches)

    stale_current = bool(stale_current_matches)
    stale_noncurrent = bool(stale_noncurrent_matches)
    repair_or_refresh = bool(updated_hits or safe_unknown_hits)

    if stale_current and repair_or_refresh:
        unit_label = "mixed_current"
    elif stale_current:
        unit_label = "stale_current"
    elif updated_hits:
        unit_label = "updated_current"
    elif safe_unknown_hits or invalidation_hits:
        unit_label = "safe_unknown"
    elif stale_noncurrent:
        unit_label = "historical_or_negated_stale"
    elif concept_hits:
        unit_label = "ambiguous_elliptical"
    else:
        unit_label = "unmapped"

    return {
        "text": text,
        "unit_label": unit_label,
        "concept_hits": concept_hits,
        "stale_current_hits": stale_current_hits,
        "stale_noncurrent_hits": stale_noncurrent_hits,
        "updated_current_hits": updated_hits,
        "safe_unknown_hits": safe_unknown_hits,
        "historical_scope_hits": historical_hits,
        "negation_scope_hits": negation_hits,
        "invalidation_scope_hits": invalidation_hits,
        "slot_id": task["answer_target"]["slot_id"],
    }


def score_output(output: str, status: str, task: dict[str, Any]) -> dict[str, Any]:
    if status != "ok":
        return {
            "decision_label": f"status_{status}",
            "loss": 0,
            "repair": 0,
            "mappable": False,
            "determinate": False,
            "ambiguous": False,
            "mixed": False,
            "status_ok": False,
            "claim_units": [],
            "audit_flags": [f"non_ok_status:{status}"],
        }

    units = [score_claim_unit(unit, task) for unit in split_claim_units(output)]
    mapped_units = [unit for unit in units if unit["unit_label"] != "unmapped"]
    stale_units = [
        unit for unit in units if unit["unit_label"] in {"stale_current", "mixed_current"}
    ]
    repair_units = [
        unit
        for unit in units
        if unit["unit_label"] in {"updated_current", "safe_unknown", "mixed_current"}
    ]
    ambiguous_units = [unit for unit in units if unit["unit_label"] == "ambiguous_elliptical"]
    mixed_units = [unit for unit in units if unit["unit_label"] == "mixed_current"]
    historical_units = [
        unit for unit in units if unit["unit_label"] == "historical_or_negated_stale"
    ]

    mappable = bool(mapped_units)
    ambiguous = bool(ambiguous_units)
    mixed = bool(mixed_units) or (bool(stale_units) and bool(repair_units))
    determinate = mappable and not ambiguous and not mixed

    if not mappable:
        decision_label = "unmapped"
    elif mixed:
        decision_label = "mixed_current"
    elif ambiguous:
        decision_label = "ambiguous_elliptical"
    elif stale_units:
        decision_label = "stale_current"
    elif repair_units:
        if all(unit["unit_label"] == "safe_unknown" for unit in repair_units):
            decision_label = "safe_unknown"
        else:
            decision_label = "updated_current"
    elif historical_units:
        decision_label = "historical_or_negated_stale"
    else:
        decision_label = "unmapped"

    audit_flags: list[str] = []
    if ambiguous:
        audit_flags.append("concept_without_explicit_stance")
    if mixed:
        audit_flags.append("stale_current_and_repair_cooccur")
    if historical_units:
        audit_flags.append("historical_or_negated_stale_visible")

    return {
        "decision_label": decision_label,
        "loss": 1 if stale_units else 0,
        "repair": 1 if repair_units else 0,
        "mappable": mappable,
        "determinate": determinate,
        "ambiguous": ambiguous,
        "mixed": mixed,
        "status_ok": True,
        "claim_units": units,
        "audit_flags": audit_flags,
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
    ambiguous_cases: list[str] = []
    mixed_cases: list[str] = []
    non_ok_status_cases: list[str] = []
    determinate_cases: list[str] = []

    for case_id in EXPECTED_CASE_IDS:
        task = tasks.get(case_id)
        output = outputs.get(case_id)
        if task is None or output is None:
            continue
        for field in ["setup", "update", "probe"]:
            if output.get(field) != task.get(field):
                errors.append(f"{case_id}: output {field} does not match frozen task row")

        baseline_score = score_output(
            output.get("baseline_output", ""),
            output.get("baseline_status", "empty"),
            task,
        )
        controlled_score = score_output(
            output.get("controlled_output", ""),
            output.get("controlled_status", "empty"),
            task,
        )

        if not baseline_score["status_ok"] or not controlled_score["status_ok"]:
            non_ok_status_cases.append(case_id)
        if not baseline_score["mappable"] or not controlled_score["mappable"]:
            silence_cases.append(case_id)
        if baseline_score["ambiguous"] or controlled_score["ambiguous"]:
            ambiguous_cases.append(case_id)
        if baseline_score["mixed"] or controlled_score["mixed"]:
            mixed_cases.append(case_id)
        if baseline_score["determinate"] and controlled_score["determinate"]:
            determinate_cases.append(case_id)

        case_summaries.append(
            {
                "case_id": case_id,
                "failure_family": task["failure_family"],
                "horizon": task["horizon"],
                "horizon_mode": task["horizon_mode"],
                "baseline_condition": output["baseline_condition"],
                "controlled_condition": output["controlled_condition"],
                "readout_alignment": output["readout_alignment"],
                "setup": output["setup"],
                "update": output["update"],
                "probe": output["probe"],
                "answer_target": task["answer_target"],
                "baseline_status": output["baseline_status"],
                "controlled_status": output["controlled_status"],
                "baseline_output": output["baseline_output"],
                "controlled_output": output["controlled_output"],
                "baseline_readout": baseline_score,
                "controlled_readout": controlled_score,
                "baseline_loss": baseline_score["loss"],
                "controlled_loss": controlled_score["loss"],
                "baseline_repair": baseline_score["repair"],
                "controlled_repair": controlled_score["repair"],
                "determinate_for_primary_dominance": (
                    baseline_score["determinate"] and controlled_score["determinate"]
                ),
                "dependency_surface": task["dependency_surface"],
            }
        )

    determinate_summaries = [
        case for case in case_summaries if case["determinate_for_primary_dominance"]
    ]
    has_determinate_cases = bool(determinate_summaries)
    baseline_loss_sum = sum(case["baseline_loss"] for case in case_summaries)
    controlled_loss_sum = sum(case["controlled_loss"] for case in case_summaries)
    baseline_repair_sum = sum(case["baseline_repair"] for case in case_summaries)
    controlled_repair_sum = sum(case["controlled_repair"] for case in case_summaries)
    determinate_baseline_loss_sum = sum(case["baseline_loss"] for case in determinate_summaries)
    determinate_controlled_loss_sum = sum(
        case["controlled_loss"] for case in determinate_summaries
    )
    determinate_baseline_repair_sum = sum(
        case["baseline_repair"] for case in determinate_summaries
    )
    determinate_controlled_repair_sum = sum(
        case["controlled_repair"] for case in determinate_summaries
    )

    baseline_net_action = baseline_loss_sum - baseline_repair_sum
    controlled_net_action = controlled_loss_sum - controlled_repair_sum
    determinate_baseline_net_action = (
        determinate_baseline_loss_sum - determinate_baseline_repair_sum
    )
    determinate_controlled_net_action = (
        determinate_controlled_loss_sum - determinate_controlled_repair_sum
    )

    aggregate_loss_dominance = controlled_loss_sum <= baseline_loss_sum
    aggregate_repair_dominance = baseline_repair_sum <= controlled_repair_sum
    determinate_loss_dominance = determinate_controlled_loss_sum <= determinate_baseline_loss_sum
    determinate_repair_dominance = (
        determinate_baseline_repair_sum <= determinate_controlled_repair_sum
    )
    metric_dominance = aggregate_loss_dominance and aggregate_repair_dominance
    determinate_metric_dominance = (
        has_determinate_cases and determinate_loss_dominance and determinate_repair_dominance
    )
    no_worse_net_action = controlled_net_action <= baseline_net_action
    determinate_no_worse_net_action = (
        determinate_controlled_net_action <= determinate_baseline_net_action
    )

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
        isinstance(case["baseline_output"], str)
        and isinstance(case["controlled_output"], str)
        for case in case_summaries
    )
    silence = bool(silence_cases)
    ambiguous = bool(ambiguous_cases)
    mixed = bool(mixed_cases)
    invalid_run = bool(errors or non_ok_status_cases)

    protocol_shape_valid = (
        frozen_task_surface
        and same_horizon
        and frozen_readout
        and outputs_complete
        and raw_outputs_retained
        and not invalid_run
        and not silence
    )
    clean_support = (
        protocol_shape_valid
        and not ambiguous
        and not mixed
        and metric_dominance
        and no_worse_net_action
    )

    if invalid_run:
        decision = "invalid_run"
    elif silence:
        decision = "silence"
    elif mixed:
        decision = "mixed_inconclusive"
    elif ambiguous:
        if determinate_metric_dominance and determinate_no_worse_net_action:
            decision = "support_with_ambiguity"
        else:
            decision = "ambiguous_inconclusive"
    elif metric_dominance and no_worse_net_action:
        decision = "support_clean"
    else:
        decision = "no_support"
    promotable = decision == "support_clean" and protocol_shape_valid

    return {
        "artifact_type": "premise_update_protocol_result",
        "protocol_id": PROTOCOL_ID,
        "result_id": result_id,
        "runner_version": RUNNER_VERSION,
        "tasks_path": str(tasks_path),
        "outputs_path": str(outputs_path),
        "tasks_sha256": task_sha,
        "outputs_sha256": sha256_file(outputs_path),
        "expected_tasks_sha256": EXPECTED_TASKS_SHA256,
        "task_count": len(case_summaries),
        "case_ids": [case["case_id"] for case in case_summaries],
        "horizons": sorted({case["horizon"] for case in case_summaries}),
        "horizon_mode": EXPECTED_HORIZON_MODE,
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
            "determinate_metric_dominance": determinate_metric_dominance,
            "readout_alignment": frozen_readout,
            "no_worse_net_action": no_worse_net_action,
            "determinate_no_worse_net_action": determinate_no_worse_net_action,
            "has_determinate_cases": has_determinate_cases,
            "silence": silence,
            "ambiguous": ambiguous,
            "mixed": mixed,
            "invalid_run": invalid_run,
            "protocol_shape_valid": protocol_shape_valid,
            "promotable": promotable,
        },
        "totals": {
            "baseline_loss_sum": baseline_loss_sum,
            "controlled_loss_sum": controlled_loss_sum,
            "baseline_repair_sum": baseline_repair_sum,
            "controlled_repair_sum": controlled_repair_sum,
            "baseline_net_action": baseline_net_action,
            "controlled_net_action": controlled_net_action,
            "determinate_case_count": len(determinate_cases),
            "determinate_baseline_loss_sum": determinate_baseline_loss_sum,
            "determinate_controlled_loss_sum": determinate_controlled_loss_sum,
            "determinate_baseline_repair_sum": determinate_baseline_repair_sum,
            "determinate_controlled_repair_sum": determinate_controlled_repair_sum,
            "determinate_baseline_net_action": determinate_baseline_net_action,
            "determinate_controlled_net_action": determinate_controlled_net_action,
            "baseline_stale_current_sum": sum(
                1 for case in case_summaries if case["baseline_readout"]["loss"]
            ),
            "controlled_stale_current_sum": sum(
                1 for case in case_summaries if case["controlled_readout"]["loss"]
            ),
            "baseline_updated_or_safe_sum": sum(
                1 for case in case_summaries if case["baseline_readout"]["repair"]
            ),
            "controlled_updated_or_safe_sum": sum(
                1 for case in case_summaries if case["controlled_readout"]["repair"]
            ),
            "baseline_mixed_sum": sum(
                1 for case in case_summaries if case["baseline_readout"]["mixed"]
            ),
            "controlled_mixed_sum": sum(
                1 for case in case_summaries if case["controlled_readout"]["mixed"]
            ),
            "baseline_ambiguous_sum": sum(
                1 for case in case_summaries if case["baseline_readout"]["ambiguous"]
            ),
            "controlled_ambiguous_sum": sum(
                1 for case in case_summaries if case["controlled_readout"]["ambiguous"]
            ),
        },
        "decision": decision,
        "silence_cases": silence_cases,
        "ambiguous_cases": ambiguous_cases,
        "mixed_cases": mixed_cases,
        "non_ok_status_cases": non_ok_status_cases,
        "determinate_cases": determinate_cases,
        "case_summaries": case_summaries,
        "errors": errors,
        "claim_boundary": (
            "This result is a v1 slot-state readout over externally supplied "
            "baseline / controlled outputs for a frozen premise-update task "
            "surface. Only decision=support_clean with promotable=true is a "
            "candidate Lean certificate witness. This does not prove real LLM "
            "semantics, model performance, memory safety, continual-learning "
            "safety, or workflow correctness."
        ),
    }


def markdown_value(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False)


def write_markdown(summary: dict[str, Any], path: Path) -> None:
    checks = summary["checks"]
    totals = summary["totals"]
    lines = [
        "LLM Epistemic Premise Update v1 Score Summary",
        "================================================",
        "",
        "Status: slot-state protocol score; not model validation by itself",
        "",
        f"artifact_type: `{summary['artifact_type']}`",
        f"protocol_id: `{summary['protocol_id']}`",
        f"result_id: `{summary['result_id']}`",
        f"runner_version: `{summary['runner_version']}`",
        f"decision: `{summary['decision']}`",
        f"promotable: `{markdown_value(checks['promotable'])}`",
        f"tasks_sha256: `{summary['tasks_sha256']}`",
        f"outputs_sha256: `{summary['outputs_sha256']}`",
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
        f"- determinate_metric_dominance: `{markdown_value(checks['determinate_metric_dominance'])}`",
        f"- readout_alignment: `{markdown_value(checks['readout_alignment'])}`",
        f"- no_worse_net_action: `{markdown_value(checks['no_worse_net_action'])}`",
        f"- determinate_no_worse_net_action: `{markdown_value(checks['determinate_no_worse_net_action'])}`",
        f"- silence: `{markdown_value(checks['silence'])}`",
        f"- ambiguous: `{markdown_value(checks['ambiguous'])}`",
        f"- mixed: `{markdown_value(checks['mixed'])}`",
        f"- invalid_run: `{markdown_value(checks['invalid_run'])}`",
        f"- protocol_shape_valid: `{markdown_value(checks['protocol_shape_valid'])}`",
        f"- silence_cases: `{markdown_value(summary['silence_cases'])}`",
        f"- ambiguous_cases: `{markdown_value(summary['ambiguous_cases'])}`",
        f"- mixed_cases: `{markdown_value(summary['mixed_cases'])}`",
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
        f"- determinate_case_count: `{totals['determinate_case_count']}`",
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
        help="Path to the frozen premise-update v1 tasks.jsonl file.",
    )
    parser.add_argument(
        "--outputs",
        type=Path,
        required=True,
        help="JSONL file with baseline / controlled statuses and outputs.",
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
