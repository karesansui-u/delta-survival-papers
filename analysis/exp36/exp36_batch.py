#!/usr/bin/env python3
"""
Experiment 36: OpenAI Batch API Runner
======================================

Generates all 270 prompts as a Batch API JSONL, submits to OpenAI,
polls for completion, and converts results into the standard
exp36_{model}_trials.jsonl format.

Batch API gives 50% cost reduction:
  GPT-4.1 mini: $0.20/1M in, $0.80/1M out (vs $0.40/$1.60 standard)

Workflow:
  1. prepare  — Generate batch_input.jsonl (no API calls)
  2. submit   — Upload file + create batch
  3. status   — Check batch status
  4. collect  — Download results → convert to trials.jsonl
  5. run      — Full pipeline: prepare → submit → poll → collect

Usage:
  # Dry run (generate input JSONL, verify prompts):
  python analysis/exp36_batch.py prepare --model gpt-4.1-mini

  # Submit batch:
  python analysis/exp36_batch.py submit --model gpt-4.1-mini

  # Check status:
  python analysis/exp36_batch.py status --batch-id batch_xxx

  # Collect results:
  python analysis/exp36_batch.py collect --batch-id batch_xxx --model gpt-4.1-mini

  # Full pipeline (prepare + submit + poll + collect):
  python analysis/exp36_batch.py run --model gpt-4.1-mini
"""

import json
import os
import random
import re
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from exp36_context_delta_matrix import (
    CONTEXT_LENGTHS,
    DELTA_LEVELS,
    EXPERIMENT_ID,
    EXPERIMENT_VERSION,
    MAX_TOKENS,
    MODEL_CONFIGS,
    N_TRIALS,
    SYSTEM_PROMPT,
    TEMPERATURE,
    build_prompt,
    deterministic_seed,
    estimate_tokens,
    get_trials_path,
    load_completed_keys,
    parse_answer,
)

OUTPUT_DIR = Path(__file__).parent

BATCH_COSTS = {
    "gpt-4.1-mini": {"cost_per_1m_input": 0.20, "cost_per_1m_output": 0.80},
    "gpt-4.1-nano": {"cost_per_1m_input": 0.05, "cost_per_1m_output": 0.20},
    "gemini-3.1-flash-lite-preview": {"cost_per_1m_input": 0.125, "cost_per_1m_output": 0.75},
}

POLL_INTERVAL_INITIAL = 30
POLL_INTERVAL_MAX = 300
POLL_BACKOFF_FACTOR = 1.5


def _load_openai_key() -> str:
    paths = [
        os.path.expanduser("~/Project/chinju-protocol/chinju-sidecar/.env"),
        os.path.expanduser("~/.env"),
    ]
    for path in paths:
        if os.path.exists(path):
            with open(path) as f:
                for line in f:
                    if line.strip().startswith("OPENAI_API_KEY="):
                        return line.strip().split("=", 1)[1].strip().strip('"').strip("'")
    val = os.environ.get("OPENAI_API_KEY")
    if val:
        return val
    raise RuntimeError("OPENAI_API_KEY not found")


def _create_client():
    from openai import OpenAI
    return OpenAI(api_key=_load_openai_key())


def _safe_model_name(model_name: str) -> str:
    return model_name.replace(":", "_").replace("/", "_").replace(".", "_")


TOKEN_ENQUEUE_LIMIT = 9_500_000  # 20M hard limit; 50% margin for tokenizer drift + message overhead


def _batch_input_path(model_name: str, part: Optional[int] = None) -> Path:
    suffix = f"_part{part}" if part is not None else ""
    return OUTPUT_DIR / f"exp36_batch_{_safe_model_name(model_name)}{suffix}_input.jsonl"


def _batch_meta_path(model_name: str, part: Optional[int] = None) -> Path:
    suffix = f"_part{part}" if part is not None else ""
    return OUTPUT_DIR / f"exp36_batch_{_safe_model_name(model_name)}{suffix}_meta.json"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Prepare batch input JSONL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def prepare_batch(model_name: str, n_trials: int = N_TRIALS, skip_existing: bool = True):
    """Generate batch input JSONL(s), auto-splitting if over token enqueue limit."""
    completed = load_completed_keys(model_name) if skip_existing else set()

    all_requests = []
    all_meta = {}
    total_input_tokens = 0

    for delta_level in DELTA_LEVELS:
        for ctx_len in CONTEXT_LENGTHS:
            for trial_idx in range(n_trials):
                if (delta_level, ctx_len, trial_idx) in completed:
                    continue

                seed = deterministic_seed(delta_level, ctx_len, trial_idx)
                rng = random.Random(seed)
                prompt, expected, subtle_meta = build_prompt(
                    delta_level, ctx_len, trial_idx, rng
                )
                tokens_est = estimate_tokens(prompt)
                total_input_tokens += tokens_est

                custom_id = f"{delta_level}|{ctx_len}|{trial_idx}"

                request = {
                    "custom_id": custom_id,
                    "method": "POST",
                    "url": "/v1/chat/completions",
                    "body": {
                        "model": model_name,
                        "messages": [
                            {"role": "system", "content": SYSTEM_PROMPT},
                            {"role": "user", "content": prompt},
                        ],
                        "temperature": TEMPERATURE,
                        "max_tokens": MAX_TOKENS,
                    },
                }
                all_requests.append((request, tokens_est))

                all_meta[custom_id] = {
                    "delta_level": delta_level,
                    "context_length": ctx_len,
                    "trial_idx": trial_idx,
                    "seed": seed,
                    "expected": expected,
                    "tokens_estimate": tokens_est,
                    **subtle_meta,
                }

    parts: List[List[dict]] = []
    part_tokens: List[int] = []
    current_part: List[dict] = []
    current_tokens = 0

    for req, tok in all_requests:
        if current_part and current_tokens + tok > TOKEN_ENQUEUE_LIMIT:
            parts.append(current_part)
            part_tokens.append(current_tokens)
            current_part = []
            current_tokens = 0
        current_part.append(req)
        current_tokens += tok

    if current_part:
        parts.append(current_part)
        part_tokens.append(current_tokens)

    batch_costs = BATCH_COSTS.get(model_name, {"cost_per_1m_input": 0, "cost_per_1m_output": 0})
    est_cost = (
        total_input_tokens / 1_000_000 * batch_costs["cost_per_1m_input"]
        + len(all_requests) * MAX_TOKENS / 1_000_000 * batch_costs["cost_per_1m_output"]
    )

    print("=" * 60)
    print("BATCH PREPARE: Experiment 36")
    print("=" * 60)
    print(f"  Model:          {model_name}")
    print(f"  Requests:       {len(all_requests)} ({len(completed)} skipped)")
    print(f"  Input tokens:   ~{total_input_tokens:,}")
    print(f"  Est. cost:      ~${est_cost:.2f} (batch 50% discount)")
    print(f"  Parts:          {len(parts)}")
    print()

    output_paths = []
    for i, (part_reqs, pt) in enumerate(zip(parts, part_tokens)):
        part_idx = i + 1 if len(parts) > 1 else None
        input_path = _batch_input_path(model_name, part_idx)
        with open(input_path, "w") as f:
            for req in part_reqs:
                f.write(json.dumps(req, ensure_ascii=False) + "\n")

        file_size_mb = input_path.stat().st_size / (1024 * 1024)
        label = f"Part {part_idx}" if part_idx else "Single"
        print(f"  {label}: {len(part_reqs)} reqs, ~{pt:,} tokens ({pt/1e6:.1f}M), {file_size_mb:.1f} MB")
        print(f"    File: {input_path}")

        if file_size_mb > 190:
            print(f"    WARNING: File > 190 MB!")

        meta_path = _batch_meta_path(model_name, part_idx)
        part_meta_trials = {cid: all_meta[cid] for req in part_reqs
                           for cid in [req["custom_id"]]}
        with open(meta_path, "w") as f:
            json.dump({
                "model": model_name,
                "part": part_idx,
                "n_parts": len(parts),
                "n_requests": len(part_reqs),
                "n_skipped": len(completed),
                "total_input_tokens_est": pt,
                "created_at": datetime.now().isoformat(),
                "trials": part_meta_trials,
            }, f, indent=2, ensure_ascii=False)

        output_paths.append((input_path, meta_path, part_idx))

    print()
    return output_paths


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Submit batch
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def submit_batch(model_name: str, part: Optional[int] = None) -> str:
    """Upload input JSONL and create a batch. If part=None, auto-detect parts."""
    input_path = _batch_input_path(model_name, part)
    if not input_path.exists():
        raise FileNotFoundError(f"Run 'prepare' first: {input_path}")

    client = _create_client()
    label = f" (part {part})" if part else ""

    print(f"  Uploading file{label}...", end="", flush=True)
    with open(input_path, "rb") as f:
        file_obj = client.files.create(file=f, purpose="batch")
    print(f" done (id={file_obj.id})")

    n_reqs = sum(1 for _ in open(input_path))
    print(f"  Creating batch{label}...", end="", flush=True)
    batch = client.batches.create(
        input_file_id=file_obj.id,
        endpoint="/v1/chat/completions",
        completion_window="24h",
        metadata={"description": f"exp36 {model_name}{label} {n_reqs} trials"},
    )
    print(f" done (id={batch.id})")

    meta_path = _batch_meta_path(model_name, part)
    if meta_path.exists():
        with open(meta_path) as f:
            meta = json.load(f)
        meta["batch_id"] = batch.id
        meta["file_id"] = file_obj.id
        meta["submitted_at"] = datetime.now().isoformat()
        with open(meta_path, "w") as f:
            json.dump(meta, f, indent=2, ensure_ascii=False)

    print(f"\n  Batch ID:  {batch.id}")
    print(f"  Status:    {batch.status}")
    return batch.id


def submit_all_parts(model_name: str) -> List[str]:
    """Submit all prepared parts sequentially, waiting for each to leave 'validating'."""
    parts = _find_parts(model_name)
    if not parts:
        print("  No prepared parts found. Run 'prepare' first.")
        return []

    client = _create_client()
    batch_ids = []

    for part_idx in parts:
        label = f"Part {part_idx}" if part_idx else "Single"
        print(f"\n{'─' * 50}")
        print(f"  Submitting {label}...")
        print(f"{'─' * 50}")

        batch_id = submit_batch(model_name, part_idx)
        batch_ids.append((part_idx, batch_id))

        if part_idx != parts[-1]:
            print(f"  Waiting for validation before next submit...")
            _wait_past_validating(client, batch_id)

    print(f"\n{'=' * 50}")
    print(f"  All {len(batch_ids)} batches submitted:")
    for p, bid in batch_ids:
        label = f"Part {p}" if p else "Single"
        print(f"    {label}: {bid}")
    return batch_ids


def _find_parts(model_name: str) -> list:
    """Find which part numbers exist (None for single, or [1,2,...] for multi)."""
    single = _batch_input_path(model_name, None)
    if single.exists():
        meta = _batch_meta_path(model_name, None)
        if meta.exists():
            with open(meta) as f:
                m = json.load(f)
            if m.get("n_parts", 1) == 1:
                return [None]

    parts = []
    for i in range(1, 20):
        if _batch_input_path(model_name, i).exists():
            parts.append(i)
        else:
            break
    return parts


def _wait_past_validating(client, batch_id: str, timeout: int = 300):
    """Wait until batch leaves 'validating' state."""
    start = time.time()
    while time.time() - start < timeout:
        batch = client.batches.retrieve(batch_id)
        if batch.status != "validating":
            print(f"  → {batch.status}")
            return
        time.sleep(10)
    print(f"  → Still validating after {timeout}s, proceeding anyway.")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Check status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def check_status(batch_id: str) -> dict:
    client = _create_client()
    batch = client.batches.retrieve(batch_id)

    print(f"  Batch:     {batch.id}")
    print(f"  Status:    {batch.status}")
    if hasattr(batch, "request_counts") and batch.request_counts:
        rc = batch.request_counts
        print(f"  Completed: {rc.completed}/{rc.total} (failed: {rc.failed})")
    if batch.output_file_id:
        print(f"  Output:    {batch.output_file_id}")
    if batch.error_file_id:
        print(f"  Errors:    {batch.error_file_id}")

    return {
        "id": batch.id,
        "status": batch.status,
        "output_file_id": batch.output_file_id,
        "error_file_id": batch.error_file_id,
    }


def poll_until_complete(batch_id: str) -> dict:
    """Poll batch status with exponential backoff until terminal state."""
    interval = POLL_INTERVAL_INITIAL
    terminal = {"completed", "failed", "expired", "cancelled"}
    start = time.time()

    while True:
        info = check_status(batch_id)
        if info["status"] in terminal:
            elapsed = time.time() - start
            print(f"\n  Batch reached terminal state: {info['status']} ({elapsed:.0f}s)")
            return info

        print(f"  Waiting {interval}s...\n")
        time.sleep(interval)
        interval = min(interval * POLL_BACKOFF_FACTOR, POLL_INTERVAL_MAX)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Collect results
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def collect_results(batch_id: str, model_name: str, part: Optional[int] = None):
    """Download batch output and convert to trials.jsonl."""
    client = _create_client()
    batch = client.batches.retrieve(batch_id)

    if batch.status != "completed":
        print(f"  Batch status is '{batch.status}', not 'completed'. Aborting.")
        return

    meta_path = _batch_meta_path(model_name, part)
    if not meta_path.exists():
        meta_path = _batch_meta_path(model_name, None)
    if not meta_path.exists():
        raise FileNotFoundError(f"Metadata not found. Run 'prepare' first.")

    with open(meta_path) as f:
        meta = json.load(f)
    trial_meta = meta["trials"]

    output_content = client.files.content(batch.output_file_id)
    part_suffix = f"_part{part}" if part is not None else ""
    raw_output_path = OUTPUT_DIR / f"exp36_batch_{_safe_model_name(model_name)}{part_suffix}_output.jsonl"
    with open(raw_output_path, "wb") as f:
        f.write(output_content.content)
    print(f"  Raw output saved: {raw_output_path}")

    results = []
    with open(raw_output_path) as f:
        for line in f:
            if line.strip():
                results.append(json.loads(line.strip()))

    error_lines = []
    if batch.error_file_id:
        error_content = client.files.content(batch.error_file_id)
        error_path = OUTPUT_DIR / f"exp36_batch_{_safe_model_name(model_name)}{part_suffix}_errors.jsonl"
        with open(error_path, "wb") as f:
            f.write(error_content.content)
        with open(error_path) as f:
            for line in f:
                if line.strip():
                    error_lines.append(json.loads(line.strip()))
        if error_lines:
            print(f"  Errors file saved: {error_path} ({len(error_lines)} errors)")

    trials_path = get_trials_path(model_name)
    existing_keys = load_completed_keys(model_name)
    n_written = 0
    n_skipped = 0
    n_errors = 0

    for result in results:
        custom_id = result["custom_id"]
        tm = trial_meta.get(custom_id)
        if tm is None:
            print(f"  WARNING: Unknown custom_id: {custom_id}")
            continue

        key = (tm["delta_level"], tm["context_length"], tm["trial_idx"])
        if key in existing_keys:
            n_skipped += 1
            continue

        response_body = (result.get("response") or {}).get("body", {})
        error = result.get("error")

        if error:
            raw_response = f"BATCH_ERROR: {json.dumps(error)}"
            result_type = "errored"
            answer = None
            is_correct = False
            usage = {"input_tokens": None, "output_tokens": None}
            n_errors += 1
        else:
            choices = response_body.get("choices", [])
            raw_response = choices[0]["message"]["content"].strip() if choices else ""
            answer = parse_answer(raw_response)
            is_correct = (answer == tm["expected"])
            result_type = "succeeded"
            api_usage = response_body.get("usage", {})
            usage = {
                "input_tokens": api_usage.get("prompt_tokens"),
                "output_tokens": api_usage.get("completion_tokens"),
            }

        wrong_val_adopted = False
        if tm["delta_level"] == "subtle" and tm.get("wrong_sum") is not None:
            wrong_val_adopted = (answer == tm["wrong_sum"])

        record = {
            "experiment": EXPERIMENT_ID,
            "version": EXPERIMENT_VERSION,
            "model": model_name,
            "delta_level": tm["delta_level"],
            "context_length": tm["context_length"],
            "trial_idx": tm["trial_idx"],
            "seed": tm["seed"],
            "expected": tm["expected"],
            "answer": answer,
            "is_correct": is_correct,
            "wrong_val_adopted": wrong_val_adopted,
            "raw_response": raw_response,
            "result_type": result_type,
            "tokens_estimate": tm["tokens_estimate"],
            "api_input_tokens": usage["input_tokens"],
            "api_output_tokens": usage["output_tokens"],
            "injected_var": tm.get("injected_var"),
            "injected_original_val": tm.get("injected_original_val"),
            "injected_wrong_val": tm.get("injected_wrong_val"),
            "injected_position": tm.get("injected_position"),
            "wrong_sum": tm.get("wrong_sum"),
            "subtle_sentence": tm.get("subtle_sentence"),
            "timestamp": datetime.now().isoformat(),
            "batch_id": batch_id,
        }

        with open(trials_path, "a") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
        n_written += 1

    print(f"\n  Results: {n_written} written, {n_skipped} skipped, {n_errors} errors")
    print(f"  Trials:  {trials_path}")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Full pipeline
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def run_full(model_name: str, n_trials: int = N_TRIALS):
    """prepare → submit all parts → poll each → collect each"""
    print("\n[1/4] Preparing batch input...")
    output_paths = prepare_batch(model_name, n_trials)

    print("\n[2/4] Submitting batches...")
    batch_ids = submit_all_parts(model_name)

    if not batch_ids:
        return

    print("\n[3/4] Polling for completion...")
    for part_idx, batch_id in batch_ids:
        label = f"Part {part_idx}" if part_idx else "Single"
        print(f"\n  Polling {label} ({batch_id})...")
        info = poll_until_complete(batch_id)

        if info["status"] != "completed":
            print(f"\n  {label} did not complete: {info['status']}")
            continue

        print(f"\n  Collecting {label}...")
        collect_results(batch_id, model_name, part_idx)

    print("\n[4/4] Summary")
    from exp36_context_delta_matrix import _print_summary
    _print_summary(model_name)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Exp.36 Batch API Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command")

    p_prep = sub.add_parser("prepare", help="Generate batch input JSONL")
    p_prep.add_argument("--model", required=True)
    p_prep.add_argument("--trials", type=int, default=N_TRIALS)
    p_prep.add_argument("--no-skip", action="store_true",
                        help="Do not skip existing trials")

    p_submit = sub.add_parser("submit", help="Upload and create batch(es)")
    p_submit.add_argument("--model", required=True)
    p_submit.add_argument("--part", type=int, default=None,
                          help="Submit only this part (default: all)")

    p_status = sub.add_parser("status", help="Check batch status")
    p_status.add_argument("--batch-id", required=True)

    p_collect = sub.add_parser("collect", help="Download and convert results")
    p_collect.add_argument("--batch-id", required=True)
    p_collect.add_argument("--model", required=True)
    p_collect.add_argument("--part", type=int, default=None)

    p_run = sub.add_parser("run", help="Full pipeline (all parts)")
    p_run.add_argument("--model", required=True)
    p_run.add_argument("--trials", type=int, default=N_TRIALS)

    args = parser.parse_args()

    if args.command == "prepare":
        prepare_batch(args.model, args.trials, skip_existing=not args.no_skip)
    elif args.command == "submit":
        if args.part is not None:
            submit_batch(args.model, args.part)
        else:
            submit_all_parts(args.model)
    elif args.command == "status":
        check_status(args.batch_id)
    elif args.command == "collect":
        collect_results(args.batch_id, args.model, args.part)
    elif args.command == "run":
        run_full(args.model, args.trials)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
