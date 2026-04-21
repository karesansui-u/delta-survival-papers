#!/usr/bin/env python3
"""Exp.39: prospective contradiction-dominance test.

This runner reuses Exp.36's filler/structural context generator and API helper,
but keeps the arithmetic task family focused:

    a + b + c

The primary prospective contrast is:

    accuracy(32K structural) < accuracy(256K zero)

Paid API calls require the explicit `run --execute` command.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import re
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any

EXP39_DIR = Path(__file__).resolve().parent
EXP36_DIR = EXP39_DIR.parent / "exp36"
sys.path.insert(0, str(EXP36_DIR))

from exp36_context_delta_matrix import (  # type: ignore
    MODEL_CONFIGS,
    call_api,
    create_client,
    estimate_tokens,
    _generate_filler_block,
    _generate_structural_block,
)

EXPERIMENT_ID = "exp39_prospective_contradiction_dominance"
EXPERIMENT_VERSION = "1.0.0"
SEED_BASE = 390000

CONDITIONS = ["zero", "structural"]
CONTEXT_LENGTHS = [32_000, 256_000]
N_TRIALS = 30
MAX_TOKENS = 512

DEFAULT_MODEL = "gpt-4.1-nano"

TARGET_SETS = [
    {"a": 127, "b": 348, "c": 215},  # 690
    {"a": 263, "b": 184, "c": 439},  # 886
    {"a": 371, "b": 256, "c": 108},  # 735
    {"a": 492, "b": 137, "c": 284},  # 913
    {"a": 158, "b": 423, "c": 376},  # 957
]


def deterministic_seed(condition: str, context_length: int, trial_idx: int) -> int:
    key = f"{condition}:{context_length}:{trial_idx}"
    h = int(hashlib.md5(key.encode()).hexdigest()[:8], 16)
    return SEED_BASE + h % 100000


def expected_answer(target: dict[str, int]) -> int:
    return target["a"] + target["b"] + target["c"]


def parse_answer(response: str) -> int | None:
    numbers = re.findall(r"-?\d+", response)
    if not numbers:
        return None
    return int(numbers[-1])


def build_prompt(
    condition: str,
    context_length: int,
    trial_idx: int,
    rng: random.Random,
) -> tuple[str, int, dict[str, Any]]:
    target = TARGET_SETS[trial_idx % len(TARGET_SETS)]
    expected = expected_answer(target)

    definition_block = (
        "=== VARIABLE DEFINITIONS ===\n"
        f"a = {target['a']}\n"
        f"b = {target['b']}\n"
        f"c = {target['c']}\n"
        "=== END DEFINITIONS ===\n\n"
        "The following is additional context information:\n"
    )

    question = (
        "\n\n=== TASK ===\n"
        "Using the variable definitions given at the start, compute: a + b + c\n"
        "Give ONLY the final numerical answer, nothing else."
    )

    filler_budget = max(
        0,
        context_length - estimate_tokens(definition_block) - estimate_tokens(question) - 10,
    )

    if condition == "zero":
        filler_sentences = _generate_filler_block(rng, filler_budget)
    elif condition == "structural":
        filler_sentences = _generate_structural_block(rng, filler_budget, target)
    else:
        raise ValueError(f"Unknown condition: {condition}")

    prompt = definition_block + "\n".join(filler_sentences) + question
    meta = {
        "target": target,
        "expression": "a + b + c",
        "expected": expected,
        "condition": condition,
        "context_length": context_length,
        "tokens_estimate": estimate_tokens(prompt),
    }
    return prompt, expected, meta


def trials_path(model_name: str) -> Path:
    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    return EXP39_DIR / f"exp39_{safe}_trials.jsonl"


def load_completed(model_name: str) -> set[tuple[str, int, int]]:
    path = trials_path(model_name)
    completed: set[tuple[str, int, int]] = set()
    if not path.exists():
        return completed
    with open(path) as f:
        for line in f:
            if not line.strip():
                continue
            rec = json.loads(line)
            completed.add((rec["condition"], rec["context_length"], rec["trial_idx"]))
    return completed


def append_record(model_name: str, record: dict[str, Any]) -> None:
    with open(trials_path(model_name), "a") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


def estimate_cost(model_name: str, n_trials: int, completed: set[tuple[str, int, int]]) -> tuple[int, float]:
    config = MODEL_CONFIGS[model_name]
    remaining_tokens = 0
    remaining_trials = 0
    for condition in CONDITIONS:
        for context_length in CONTEXT_LENGTHS:
            for trial_idx in range(n_trials):
                if (condition, context_length, trial_idx) in completed:
                    continue
                remaining_tokens += context_length
                remaining_trials += 1
    cost = (
        remaining_tokens / 1_000_000 * config["cost_per_1m_input"]
        + remaining_trials * MAX_TOKENS / 1_000_000 * config["cost_per_1m_output"]
    )
    return remaining_trials, cost


def print_plan(model_name: str, n_trials: int) -> None:
    completed = load_completed(model_name)
    remaining, cost = estimate_cost(model_name, n_trials, completed)
    print("=" * 72)
    print("EXP.39 PROSPECTIVE CONTRADICTION-DOMINANCE TEST")
    print("=" * 72)
    print(f"Model:          {model_name}")
    print(f"Conditions:     {CONDITIONS}")
    print(f"Contexts:       {[f'{c//1000}K' for c in CONTEXT_LENGTHS]}")
    print(f"Trials/cell:    {n_trials}")
    print(f"Remaining:      {remaining} trials")
    print(f"Estimated cost: ${cost:.2f}")
    print(f"Output:         {trials_path(model_name)}")
    print()
    print("Primary prediction:")
    print("  accuracy(32K structural) < accuracy(256K zero)")


def dry_run(model_name: str, n_trials: int) -> None:
    print_plan(model_name, n_trials)
    print("\nDry-run prompt checks:")
    for condition in CONDITIONS:
        for context_length in CONTEXT_LENGTHS:
            seed = deterministic_seed(condition, context_length, 0)
            rng = random.Random(seed)
            prompt, expected, meta = build_prompt(condition, context_length, 0, rng)
            print(
                f"  {condition:10s} {context_length//1000:>3}K "
                f"tokens≈{meta['tokens_estimate']:,} expected={expected} "
                f"chars={len(prompt):,}"
            )


def run(model_name: str, n_trials: int, execute: bool, resume: bool = True) -> None:
    if not execute:
        raise SystemExit("Refusing paid API calls without --execute. Use dry-run first.")

    config = MODEL_CONFIGS.get(model_name)
    if not config:
        raise SystemExit(f"Unknown model: {model_name}")
    if config["backend"] not in {"openai", "gemini"}:
        raise SystemExit(f"Unsupported backend for this runner: {config['backend']}")

    completed = load_completed(model_name) if resume else set()
    print_plan(model_name, n_trials)
    client = create_client(config["backend"])

    for condition in CONDITIONS:
        for context_length in CONTEXT_LENGTHS:
            print(f"\nCell: {condition} / {context_length//1000}K")
            for trial_idx in range(n_trials):
                key = (condition, context_length, trial_idx)
                if key in completed:
                    continue

                seed = deterministic_seed(condition, context_length, trial_idx)
                rng = random.Random(seed)
                prompt, expected, meta = build_prompt(condition, context_length, trial_idx, rng)

                raw_response = ""
                answer = None
                is_correct = False
                usage = {"input_tokens": None, "output_tokens": None}
                result_type = "succeeded"

                try:
                    raw_response, usage = call_api(client, model_name, prompt, config["backend"])
                    answer = parse_answer(raw_response)
                    is_correct = answer == expected
                except Exception as exc:  # Keep append-safe error accounting.
                    raw_response = f"ERROR: {exc}"
                    result_type = "errored"

                record = {
                    "experiment": EXPERIMENT_ID,
                    "version": EXPERIMENT_VERSION,
                    "model": model_name,
                    "condition": condition,
                    "context_length": context_length,
                    "trial_idx": trial_idx,
                    "seed": seed,
                    "target": meta["target"],
                    "expression": meta["expression"],
                    "expected": expected,
                    "answer": answer,
                    "is_correct": is_correct,
                    "raw_response": raw_response,
                    "result_type": result_type,
                    "tokens_estimate": meta["tokens_estimate"],
                    "api_input_tokens": usage["input_tokens"],
                    "api_output_tokens": usage["output_tokens"],
                    "timestamp": datetime.now().isoformat(),
                }
                append_record(model_name, record)
                status = "✓" if is_correct else "✗"
                print(f"  trial {trial_idx:02d}: {status} answer={answer} expected={expected}")
                time.sleep(0.3)


def summarize(model_name: str) -> None:
    path = trials_path(model_name)
    if not path.exists():
        raise SystemExit(f"No trials file found: {path}")

    records = []
    with open(path) as f:
        for line in f:
            if line.strip():
                records.append(json.loads(line))

    by_cell: dict[tuple[str, int], list[dict[str, Any]]] = {}
    for rec in records:
        by_cell.setdefault((rec["condition"], rec["context_length"]), []).append(rec)

    print("=" * 72)
    print(f"EXP.39 SUMMARY: {model_name}")
    print("=" * 72)
    acc: dict[tuple[str, int], float] = {}
    counts: dict[tuple[str, int], tuple[int, int, int]] = {}

    for condition in CONDITIONS:
        for context_length in CONTEXT_LENGTHS:
            cell = by_cell.get((condition, context_length), [])
            valid = [r for r in cell if r.get("result_type") == "succeeded"]
            correct = sum(1 for r in valid if r.get("is_correct"))
            errors = len(cell) - len(valid)
            denom = len(valid)
            value = correct / denom if denom else float("nan")
            acc[(condition, context_length)] = value
            counts[(condition, context_length)] = (correct, denom, errors)
            print(
                f"{condition:10s} {context_length//1000:>3}K: "
                f"{value:.3f} ({correct}/{denom}, errors={errors})"
            )

    primary_margin = acc[("zero", 256_000)] - acc[("structural", 32_000)]
    print("\nPrimary contrast:")
    print("  margin = accuracy(256K zero) - accuracy(32K structural)")
    print(f"  margin = {primary_margin:.3f}")
    if primary_margin > 0:
        print("  Directional prediction: SUPPORTED")
    else:
        print("  Directional prediction: NOT SUPPORTED")
    if primary_margin >= 0.20:
        print("  Strong-support threshold (>= 20pp): MET")
    else:
        print("  Strong-support threshold (>= 20pp): NOT MET")

    try:
        from scipy.stats import fisher_exact

        s_correct, s_total, _ = counts[("structural", 32_000)]
        z_correct, z_total, _ = counts[("zero", 256_000)]
        table = [
            [s_correct, s_total - s_correct],
            [z_correct, z_total - z_correct],
        ]
        _, p_less = fisher_exact(table, alternative="less")
        print(f"  Fisher exact p(structural32 < zero256): {p_less:.4g}")
    except Exception:
        print("  Fisher exact test skipped (SciPy unavailable or insufficient data).")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    def add_common(p: argparse.ArgumentParser) -> None:
        p.add_argument("--model", default=DEFAULT_MODEL, choices=sorted(MODEL_CONFIGS.keys()))
        p.add_argument("--trials", type=int, default=N_TRIALS)

    p_plan = sub.add_parser("plan", help="Show the pre-registered design and cost estimate")
    add_common(p_plan)

    p_dry = sub.add_parser("dry-run", help="Build one prompt per cell, no API calls")
    add_common(p_dry)

    p_run = sub.add_parser("run", help="Run paid API calls; requires --execute")
    add_common(p_run)
    p_run.add_argument("--execute", action="store_true")
    p_run.add_argument("--no-resume", action="store_true")

    p_sum = sub.add_parser("summarize", help="Summarize an existing JSONL output")
    p_sum.add_argument("--model", default=DEFAULT_MODEL, choices=sorted(MODEL_CONFIGS.keys()))

    args = parser.parse_args()
    if args.command == "plan":
        print_plan(args.model, args.trials)
    elif args.command == "dry-run":
        dry_run(args.model, args.trials)
    elif args.command == "run":
        run(args.model, args.trials, execute=args.execute, resume=not args.no_resume)
    elif args.command == "summarize":
        summarize(args.model)


if __name__ == "__main__":
    main()
