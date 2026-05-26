#!/usr/bin/env python3
"""Score the frozen epistemic-control toy protocol.

This runner is intentionally small and model-free. It reads the frozen
`tasks.jsonl` packet, checks that the task surface and readout fields match the
v0 protocol, and computes the loss / repair dominance summary used by the
Lean-side evaluation contract.

It does not call an LLM and does not validate real model performance.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


PROTOCOL_ID = "llm_epistemic_control_frozen_toy_v0"
RUNNER_VERSION = "0.1.0"
EXPECTED_CASE_IDS = [
    "toy_contradiction_001",
    "toy_memory_001",
    "toy_dependency_001",
]
REQUIRED_ARRAY_FIELDS = [
    "baselineLoss",
    "controlledLoss",
    "baselineRepair",
    "controlledRepair",
]
REQUIRED_FIELDS = [
    "case_id",
    "family",
    "horizon",
    "initial_state",
    "update",
    "baseline_action",
    "controlled_action",
    "readout_alignment",
    *REQUIRED_ARRAY_FIELDS,
]
EXPECTED_READOUT_ALIGNMENT = "toy_loss_minus_repair_sum"


def markdown_value(value: Any) -> str:
    return json.dumps(value)


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_tasks_path() -> Path:
    return (
        repo_root()
        / "v3"
        / "05_evidence"
        / "llm_epistemic_control_frozen_toy_v0"
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
        raise ValueError(f"{path}: no task rows found")
    return rows


def require_number_list(row: dict[str, Any], field: str) -> list[float]:
    value = row.get(field)
    if not isinstance(value, list):
        raise ValueError(f"{row.get('case_id', '<unknown>')}: {field} is not a list")
    result: list[float] = []
    for index, item in enumerate(value):
        if not isinstance(item, (int, float)) or isinstance(item, bool):
            raise ValueError(
                f"{row.get('case_id', '<unknown>')}: {field}[{index}] is not numeric"
            )
        result.append(float(item))
    return result


def validate_rows(rows: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], list[str]]:
    errors: list[str] = []
    cases: list[dict[str, Any]] = []
    seen_case_ids: set[str] = set()

    for row in rows:
        case_id = row.get("case_id", "<missing>")
        missing = [field for field in REQUIRED_FIELDS if field not in row]
        if missing:
            errors.append(f"{case_id}: missing fields: {', '.join(missing)}")
            continue

        if not isinstance(case_id, str) or not case_id:
            errors.append("<unknown>: case_id must be a nonempty string")
            continue
        if case_id in seen_case_ids:
            errors.append(f"{case_id}: duplicate case_id")
            continue
        seen_case_ids.add(case_id)

        horizon = row["horizon"]
        if not isinstance(horizon, int) or isinstance(horizon, bool) or horizon <= 0:
            errors.append(f"{case_id}: horizon must be a positive integer")
            continue

        arrays: dict[str, list[float]] = {}
        for field in REQUIRED_ARRAY_FIELDS:
            try:
                arrays[field] = require_number_list(row, field)
            except ValueError as exc:
                errors.append(str(exc))
                continue
            if len(arrays[field]) != horizon:
                errors.append(
                    f"{case_id}: {field} length {len(arrays[field])} "
                    f"does not match horizon {horizon}"
                )

        if row.get("readout_alignment") != EXPECTED_READOUT_ALIGNMENT:
            errors.append(
                f"{case_id}: readout_alignment must be "
                f"{EXPECTED_READOUT_ALIGNMENT!r}"
            )

        cases.append(
            {
                "case_id": case_id,
                "family": row["family"],
                "horizon": horizon,
                "baseline_loss": sum(arrays.get("baselineLoss", [])),
                "controlled_loss": sum(arrays.get("controlledLoss", [])),
                "baseline_repair": sum(arrays.get("baselineRepair", [])),
                "controlled_repair": sum(arrays.get("controlledRepair", [])),
                "per_step_loss_dominance": all(
                    c <= b
                    for b, c in zip(
                        arrays.get("baselineLoss", []),
                        arrays.get("controlledLoss", []),
                    )
                ),
                "per_step_repair_dominance": all(
                    b <= c
                    for b, c in zip(
                        arrays.get("baselineRepair", []),
                        arrays.get("controlledRepair", []),
                    )
                ),
            }
        )

    return cases, errors


def summarize(tasks_path: Path) -> dict[str, Any]:
    rows = load_jsonl(tasks_path)
    cases, errors = validate_rows(rows)
    case_ids = [case["case_id"] for case in cases]
    horizons = sorted({case["horizon"] for case in cases})

    expected_surface = case_ids == EXPECTED_CASE_IDS
    baseline_loss_sum = sum(case["baseline_loss"] for case in cases)
    controlled_loss_sum = sum(case["controlled_loss"] for case in cases)
    baseline_repair_sum = sum(case["baseline_repair"] for case in cases)
    controlled_repair_sum = sum(case["controlled_repair"] for case in cases)
    baseline_net_action = baseline_loss_sum - baseline_repair_sum
    controlled_net_action = controlled_loss_sum - controlled_repair_sum

    aggregate_loss_dominance = controlled_loss_sum <= baseline_loss_sum
    aggregate_repair_dominance = baseline_repair_sum <= controlled_repair_sum
    per_step_loss_dominance = all(
        case["per_step_loss_dominance"] for case in cases
    )
    per_step_repair_dominance = all(
        case["per_step_repair_dominance"] for case in cases
    )
    frozen_readout = not errors
    same_horizon = len(horizons) == 1
    readout_alignment = not errors
    metric_dominance = aggregate_loss_dominance and aggregate_repair_dominance
    no_worse_net_action = controlled_net_action <= baseline_net_action

    protocol_shape_valid = (
        expected_surface
        and frozen_readout
        and same_horizon
        and readout_alignment
        and metric_dominance
        and no_worse_net_action
    )

    return {
        "protocol_id": PROTOCOL_ID,
        "runner_version": RUNNER_VERSION,
        "tasks_path": str(tasks_path),
        "tasks_sha256": sha256_file(tasks_path),
        "task_count": len(cases),
        "case_ids": case_ids,
        "families": sorted({str(case["family"]) for case in cases}),
        "horizons": horizons,
        "checks": {
            "frozen_task_surface": expected_surface,
            "frozen_readout": frozen_readout,
            "same_horizon": same_horizon,
            "same_initial_mass": "assumed_by_freeze_manifest",
            "positive_trajectories": "assumed_by_lean_protocol",
            "aggregate_loss_dominance": aggregate_loss_dominance,
            "aggregate_repair_dominance": aggregate_repair_dominance,
            "per_step_loss_dominance": per_step_loss_dominance,
            "per_step_repair_dominance": per_step_repair_dominance,
            "metric_dominance": metric_dominance,
            "readout_alignment": readout_alignment,
            "no_worse_net_action": no_worse_net_action,
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
        "case_summaries": cases,
        "errors": errors,
        "claim_boundary": (
            "This is a deterministic toy-protocol scoring summary. It does not "
            "prove real LLM semantics, model performance, memory safety, or "
            "workflow correctness."
        ),
    }


def write_markdown(summary: dict[str, Any], path: Path) -> None:
    checks = summary["checks"]
    totals = summary["totals"]
    lines = [
        "LLM Epistemic-Control Frozen Toy v0 Score Summary",
        "=================================================",
        "",
        "Status: deterministic toy-protocol score; not validation evidence",
        "",
        f"protocol_id: `{summary['protocol_id']}`",
        f"runner_version: `{summary['runner_version']}`",
        f"tasks_sha256: `{summary['tasks_sha256']}`",
        "",
        "Checks",
        "------",
        "",
        f"- frozen_task_surface: `{markdown_value(checks['frozen_task_surface'])}`",
        f"- frozen_readout: `{markdown_value(checks['frozen_readout'])}`",
        f"- same_horizon: `{markdown_value(checks['same_horizon'])}`",
        f"- metric_dominance: `{markdown_value(checks['metric_dominance'])}`",
        f"- readout_alignment: `{markdown_value(checks['readout_alignment'])}`",
        f"- no_worse_net_action: `{markdown_value(checks['no_worse_net_action'])}`",
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
        help="Path to the frozen tasks.jsonl file.",
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

    summary = summarize(args.tasks)
    rendered = json.dumps(summary, indent=2, sort_keys=True)

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
