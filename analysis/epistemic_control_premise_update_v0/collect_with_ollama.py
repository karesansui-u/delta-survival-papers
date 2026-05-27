#!/usr/bin/env python3
"""Collect raw baseline / controlled outputs with a local Ollama model.

This collector implements the run condition fixed for
`llm_epistemic_premise_update_v0_result_001`. It reads the frozen task surface,
calls a local Ollama HTTP endpoint, and writes raw baseline / controlled output
rows for the model-free scorer.

It does not score the outputs and does not validate model performance.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


MODEL = "gemma4:e4b"
RUN_ID = "llm_epistemic_premise_update_v0_result_001"
COLLECTOR_VERSION = "0.1.0"
BASELINE_PROMPT_VERSION = "ordinary_readout_without_dependency_refresh_v0"
CONTROLLED_PROMPT_VERSION = "dependency_aware_premise_refresh_v0"
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
OPTIONS = {
    "temperature": 0,
    "top_p": 1,
    "seed": 20260527,
    "num_predict": 64,
}


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


def baseline_prompt(task: dict[str, Any]) -> str:
    return f"""You are answering from a small stored memory record.

Use the stored record and appended update exactly as written.
Do not add a dependency-refresh or downstream-rewrite step.
Return one concise answer to the probe.

STORED SETUP:
{task["setup"]}

APPENDED UPDATE:
{task["update"]}

PROBE:
{task["probe"]}

ANSWER:"""


def controlled_prompt(task: dict[str, Any]) -> str:
    dependency_surface = ", ".join(task["dependency_surface"])
    return f"""You are a dependency-aware premise-refresh control layer.

Treat the appended update as the current premise. Before answering, invalidate
or refresh downstream fields tied to the old premise. If the exact downstream
value is not given, answer that it must be recomputed or is unknown rather than
using stale information.

DEPENDENCY SURFACE:
{dependency_surface}

STORED SETUP:
{task["setup"]}

APPENDED UPDATE:
{task["update"]}

PROBE:
{task["probe"]}

ANSWER:"""


def generate(prompt: str, timeout: int) -> tuple[str, dict[str, Any]]:
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "think": False,
        "options": OPTIONS,
    }
    request = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    started = time.monotonic()
    with urllib.request.urlopen(request, timeout=timeout) as response:
        body = json.loads(response.read().decode("utf-8"))
    elapsed = time.monotonic() - started
    return str(body.get("response", "")).strip(), {
        "done": body.get("done"),
        "total_duration": body.get("total_duration"),
        "load_duration": body.get("load_duration"),
        "prompt_eval_count": body.get("prompt_eval_count"),
        "eval_count": body.get("eval_count"),
        "elapsed_seconds": round(elapsed, 3),
    }


def collect(tasks: list[dict[str, Any]], timeout: int) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    rows: list[dict[str, Any]] = []
    diagnostics: list[dict[str, Any]] = []
    for index, task in enumerate(tasks, start=1):
        case_id = task["case_id"]
        print(f"[{index}/{len(tasks)}] baseline {case_id}", flush=True)
        baseline_text, baseline_diag = generate(baseline_prompt(task), timeout)
        print(f"[{index}/{len(tasks)}] controlled {case_id}", flush=True)
        controlled_text, controlled_diag = generate(controlled_prompt(task), timeout)
        rows.append(
            {
                "case_id": case_id,
                "horizon": task["horizon"],
                "baseline_condition": task["baseline_condition"],
                "controlled_condition": task["controlled_condition"],
                "readout_alignment": task["readout_alignment"],
                "baseline_output": baseline_text,
                "controlled_output": controlled_text,
            }
        )
        diagnostics.append(
            {
                "case_id": case_id,
                "baseline_diagnostics": baseline_diag,
                "controlled_diagnostics": controlled_diag,
            }
        )
    return rows, diagnostics


def write_jsonl(rows: list[dict[str, Any]], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rendered = "\n".join(json.dumps(row, ensure_ascii=False) for row in rows)
    path.write_text(rendered + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tasks",
        type=Path,
        default=default_tasks_path(),
        help="Path to the frozen premise-update tasks.jsonl file.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        required=True,
        help="Output JSONL path for raw baseline / controlled outputs.",
    )
    parser.add_argument(
        "--metadata",
        type=Path,
        required=True,
        help="Output JSON path for collection metadata.",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=180,
        help="Per-generation timeout in seconds.",
    )
    args = parser.parse_args()

    tasks = load_jsonl(args.tasks)
    rows, diagnostics = collect(tasks, args.timeout)
    write_jsonl(rows, args.out)
    metadata = {
        "artifact_type": "premise_update_output_collection_metadata",
        "run_id": RUN_ID,
        "collector_version": COLLECTOR_VERSION,
        "model": MODEL,
        "ollama_url": OLLAMA_URL,
        "options": OPTIONS,
        "baseline_prompt_version": BASELINE_PROMPT_VERSION,
        "controlled_prompt_version": CONTROLLED_PROMPT_VERSION,
        "task_path": str(args.tasks),
        "task_sha256": sha256_file(args.tasks),
        "output_path": str(args.out),
        "output_sha256": sha256_file(args.out),
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "case_count": len(rows),
        "diagnostics": diagnostics,
        "claim_boundary": (
            "This metadata records a local output collection run. It does not "
            "score the outputs or prove model performance."
        ),
    }
    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    args.metadata.write_text(
        json.dumps(metadata, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
