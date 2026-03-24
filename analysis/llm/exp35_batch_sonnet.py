#!/usr/bin/env python3
"""
Experiment 35: Sonnet 4.6 replication via Anthropic Batch API (50% off).

Usage:
  # Step 1: Generate batch and submit
  python analysis/exp35_batch_sonnet.py submit --max-context 8000 --trials 30

  # Step 2: Check status
  python analysis/exp35_batch_sonnet.py status

  # Step 3: Download results and analyze
  python analysis/exp35_batch_sonnet.py collect
"""

import json
import os
import random
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

import anthropic

# Reuse prompt generation from main experiment
sys.path.insert(0, str(Path(__file__).parent.parent))
from analysis.exp35_delta_zero_control import (
    CONTEXT_LENGTHS, DELTA_LEVELS, SEED_BASE, TARGET_SETS,
    build_prompt, estimate_tokens,
)

MODEL = "claude-sonnet-4-20250514"
MAX_TOKENS = 64
TEMPERATURE = 1.0
N_TRIALS = 30

BATCH_DIR = Path(__file__).parent / "exp35_sonnet_batch"


def load_anthropic_key() -> str:
    paths = [
        os.path.expanduser("~/Project/chinju-protocol/chinju-sidecar/.env"),
        os.path.expanduser("~/.env"),
    ]
    key_names = ["ANTHROPIC_API_KEY", "CLAUDE_API_KEY"]
    for path in paths:
        if os.path.exists(path):
            with open(path) as f:
                for line in f:
                    for key_name in key_names:
                        if line.strip().startswith(f"{key_name}="):
                            return line.strip().split("=", 1)[1].strip().strip('"').strip("'")
    for key_name in key_names:
        key = os.environ.get(key_name)
        if key:
            return key
    raise RuntimeError("Anthropic API key not found (tried ANTHROPIC_API_KEY, CLAUDE_API_KEY)")


def generate_batch_requests(max_context: Optional[int], n_trials: int) -> list[dict]:
    """Generate all batch request objects."""
    context_lengths = [l for l in CONTEXT_LENGTHS if (max_context is None or l <= max_context)]
    requests = []

    for delta_level in DELTA_LEVELS:
        for ctx_len in context_lengths:
            for trial_idx in range(n_trials):
                seed = SEED_BASE + hash((delta_level, ctx_len, trial_idx)) % 100000
                rng = random.Random(seed)
                target = rng.choice(TARGET_SETS)
                expected = target["a"] + target["b"] + target["c"]

                rng2 = random.Random(seed)
                prompt, exp_val, needle_pos = build_prompt(delta_level, ctx_len, trial_idx, rng2)

                custom_id = f"{delta_level}_{ctx_len}_{trial_idx}"

                requests.append({
                    "custom_id": custom_id,
                    "params": {
                        "model": MODEL,
                        "max_tokens": MAX_TOKENS,
                        "temperature": TEMPERATURE,
                        "system": "You are a precise calculator. Give ONLY the final numerical answer.",
                        "messages": [
                            {"role": "user", "content": prompt},
                        ],
                    },
                    # Metadata for later analysis
                    "_meta": {
                        "delta_level": delta_level,
                        "context_length": ctx_len,
                        "trial_idx": trial_idx,
                        "seed": seed,
                        "expected": exp_val,
                        "needle_position": needle_pos,
                        "actual_tokens": estimate_tokens(prompt),
                    },
                })

    return requests


def cmd_submit(args):
    """Generate and submit batch."""
    BATCH_DIR.mkdir(exist_ok=True)

    print("Generating requests...")
    requests = generate_batch_requests(args.max_context, args.trials)
    print(f"  Total requests: {len(requests)}")

    # Estimate cost
    total_input_tokens = sum(r["_meta"]["actual_tokens"] for r in requests)
    cost_full = total_input_tokens / 1_000_000 * 3.0  # $3/M input for Sonnet
    cost_batch = cost_full * 0.5
    print(f"  Total input tokens: {total_input_tokens:,}")
    print(f"  Estimated cost (full): ${cost_full:.2f}")
    print(f"  Estimated cost (batch 50% off): ${cost_batch:.2f}")

    # Save metadata (with _meta) for later collection
    meta_path = BATCH_DIR / "batch_meta.json"
    with open(meta_path, "w") as f:
        json.dump({
            "requests": [{
                "custom_id": r["custom_id"],
                **r["_meta"],
            } for r in requests],
            "model": MODEL,
            "submitted_at": datetime.now().isoformat(),
            "max_context": args.max_context,
            "trials": args.trials,
        }, f, indent=2)
    print(f"  Metadata saved: {meta_path}")

    # Write JSONL for batch
    jsonl_path = BATCH_DIR / "batch_requests.jsonl"
    with open(jsonl_path, "w") as f:
        for r in requests:
            f.write(json.dumps({
                "custom_id": r["custom_id"],
                "params": r["params"],
            }) + "\n")
    print(f"  JSONL saved: {jsonl_path}")

    # Submit
    print("\nSubmitting batch...")
    client = anthropic.Anthropic(api_key=load_anthropic_key())
    batch = client.messages.batches.create(
        requests=[
            {
                "custom_id": r["custom_id"],
                "params": r["params"],
            }
            for r in requests
        ]
    )
    print(f"  Batch ID: {batch.id}")
    print(f"  Status: {batch.processing_status}")

    # Save batch ID
    id_path = BATCH_DIR / "batch_id.txt"
    with open(id_path, "w") as f:
        f.write(batch.id)
    print(f"  Batch ID saved: {id_path}")
    print("\nDone. Use 'status' to check progress, 'collect' when complete.")


def cmd_status(args):
    """Check batch status."""
    id_path = BATCH_DIR / "batch_id.txt"
    if not id_path.exists():
        print("No batch ID found. Run 'submit' first.")
        return

    batch_id = id_path.read_text().strip()
    client = anthropic.Anthropic(api_key=load_anthropic_key())
    batch = client.messages.batches.retrieve(batch_id)

    print(f"Batch ID: {batch.id}")
    print(f"Status: {batch.processing_status}")
    counts = batch.request_counts
    print(f"  Processing: {counts.processing}")
    print(f"  Succeeded: {counts.succeeded}")
    print(f"  Errored: {counts.errored}")
    print(f"  Canceled: {counts.canceled}")
    print(f"  Expired: {counts.expired}")


def cmd_collect(args):
    """Download results and analyze."""
    import numpy as np

    id_path = BATCH_DIR / "batch_id.txt"
    meta_path = BATCH_DIR / "batch_meta.json"
    if not id_path.exists() or not meta_path.exists():
        print("No batch found. Run 'submit' first.")
        return

    batch_id = id_path.read_text().strip()
    with open(meta_path) as f:
        meta = json.load(f)

    # Build lookup from custom_id to metadata
    meta_lookup = {r["custom_id"]: r for r in meta["requests"]}

    client = anthropic.Anthropic(api_key=load_anthropic_key())

    # Check status first
    batch = client.messages.batches.retrieve(batch_id)
    if batch.processing_status != "ended":
        print(f"Batch not yet complete. Status: {batch.processing_status}")
        counts = batch.request_counts
        print(f"  Succeeded: {counts.succeeded}, Processing: {counts.processing}")
        return

    # Download results
    print("Downloading results...")
    results = []
    for result in client.messages.batches.results(batch_id):
        custom_id = result.custom_id
        m = meta_lookup.get(custom_id)
        if not m:
            continue

        # Extract answer
        raw_response = ""
        answer = None
        is_correct = False

        if result.result.type == "succeeded":
            msg = result.result.message
            if msg.content:
                raw_response = msg.content[0].text.strip()
                numbers = re.findall(r'-?\d+', raw_response)
                if numbers:
                    answer = int(numbers[-1])
                    is_correct = (answer == m["expected"])

        results.append({
            "delta_level": m["delta_level"],
            "context_length": m["context_length"],
            "trial_idx": m["trial_idx"],
            "seed": m["seed"],
            "expected": m["expected"],
            "answer": answer,
            "is_correct": is_correct,
            "raw_response": raw_response,
            "needle_position": m["needle_position"],
            "actual_tokens": m["actual_tokens"],
        })

    print(f"  Collected {len(results)} results")

    # Save raw trials
    trials_path = BATCH_DIR / "sonnet_trials.json"
    with open(trials_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"  Trials saved: {trials_path}")

    # Aggregate
    print("\n" + "=" * 60)
    print("RESULTS: Sonnet 4.6 (Batch API)")
    print("=" * 60)

    context_lengths = sorted(set(r["context_length"] for r in results))

    for delta in DELTA_LEVELS:
        print(f"\n  δ = {delta}")
        for ctx_len in context_lengths:
            cells = [r for r in results if r["delta_level"] == delta and r["context_length"] == ctx_len]
            acc = np.mean([r["is_correct"] for r in cells])
            n_correct = sum(r["is_correct"] for r in cells)
            print(f"    {ctx_len:>6,}: {acc:.2f}  ({n_correct}/{len(cells)})")

    # Summary
    print("\n" + "-" * 60)
    for delta in DELTA_LEVELS:
        cells = [r for r in results if r["delta_level"] == delta]
        acc = np.mean([r["is_correct"] for r in cells])
        n_correct = sum(r["is_correct"] for r in cells)
        print(f"  δ={delta}: {acc:.3f} ({n_correct}/{len(cells)})")

    # Save summary
    summary = {
        "model": MODEL,
        "collected_at": datetime.now().isoformat(),
        "total_trials": len(results),
        "results_by_cell": {},
    }
    for delta in DELTA_LEVELS:
        for ctx_len in context_lengths:
            cells = [r for r in results if r["delta_level"] == delta and r["context_length"] == ctx_len]
            key = f"{delta}_{ctx_len}"
            summary["results_by_cell"][key] = {
                "accuracy": float(np.mean([r["is_correct"] for r in cells])),
                "n_correct": sum(r["is_correct"] for r in cells),
                "n_total": len(cells),
            }

    summary_path = BATCH_DIR / "sonnet_results_summary.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)
    print(f"\n  Summary saved: {summary_path}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Exp.35: Sonnet 4.6 Batch Replication")
    sub = parser.add_subparsers(dest="command")

    p_submit = sub.add_parser("submit", help="Generate and submit batch")
    p_submit.add_argument("--max-context", type=int, default=None)
    p_submit.add_argument("--trials", type=int, default=N_TRIALS)

    p_status = sub.add_parser("status", help="Check batch status")
    p_collect = sub.add_parser("collect", help="Download and analyze results")

    args = parser.parse_args()

    if args.command == "submit":
        cmd_submit(args)
    elif args.command == "status":
        cmd_status(args)
    elif args.command == "collect":
        cmd_collect(args)
    else:
        parser.print_help()
