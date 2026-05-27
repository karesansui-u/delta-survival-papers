#!/usr/bin/env python3
"""Emit a JSONL output template for the v1 premise-update protocol.

The template is for human or external-runner collection only. It copies the
frozen case ids, horizon, conditions, and readout alignment from `tasks.jsonl`
and adds placeholder fields for raw baseline / controlled outputs plus explicit
generation statuses.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


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


def make_template_row(task: dict[str, Any]) -> dict[str, Any]:
    return {
        "case_id": task["case_id"],
        "horizon": task["horizon"],
        "horizon_mode": task["horizon_mode"],
        "baseline_condition": task["baseline_condition"],
        "controlled_condition": task["controlled_condition"],
        "readout_alignment": task["readout_alignment"],
        "setup": task["setup"],
        "update": task["update"],
        "probe": task["probe"],
        "baseline_status": "ok",
        "controlled_status": "ok",
        "baseline_output": "TODO_BASELINE_RAW_OUTPUT",
        "controlled_output": "TODO_CONTROLLED_RAW_OUTPUT",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tasks",
        type=Path,
        default=default_tasks_path(),
        help="Path to the frozen premise-update v1 tasks.jsonl file.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        required=True,
        help="Output JSONL path for the collection template.",
    )
    args = parser.parse_args()

    rows = [make_template_row(task) for task in load_jsonl(args.tasks)]
    args.out.parent.mkdir(parents=True, exist_ok=True)
    rendered = "\n".join(json.dumps(row, ensure_ascii=False) for row in rows)
    args.out.write_text(rendered + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
