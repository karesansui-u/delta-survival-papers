#!/usr/bin/env python3
"""Exp.40: contradiction-quality test under matched presence.

This is a prospective follow-up to the Exp.36/39 baseline comparison.

Paid API calls require the explicit `run --execute` command. Use `dry-run` to
inspect token counts and prompts without spending money.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

EXP40_DIR = Path(__file__).resolve().parent
EXP36_DIR = EXP40_DIR.parent / "exp36"
sys.path.insert(0, str(EXP36_DIR))

from exp36_context_delta_matrix import (  # type: ignore
    MODEL_CONFIGS,
    SUBTLE_OFFSETS,
    SUBTLE_TEMPLATES,
    call_api,
    create_client,
    estimate_tokens,
    _generate_filler_block,
    _generate_structural_block,
)

EXPERIMENT_ID = "exp40_contradiction_quality"
EXPERIMENT_VERSION = "1.0.0"
SEED_BASE = 400000

CONDITIONS = ["zero_sanity", "scoped", "subtle", "structural"]
PRIMARY_CONDITIONS = ["scoped", "subtle", "structural"]
CONTEXT_LENGTH = 32_000
N_TRIALS = 50
MAX_TOKENS = 512

DEFAULT_MODEL = "gpt-4.1-mini"

TARGET_SETS = [
    {"a": 127, "b": 348, "c": 215},  # 690
    {"a": 263, "b": 184, "c": 439},  # 886
    {"a": 371, "b": 256, "c": 108},  # 735
    {"a": 492, "b": 137, "c": 284},  # 913
    {"a": 158, "b": 423, "c": 376},  # 957
]

SCOPED_TEMPLATES = [
    (
        "In a separate calibration notebook that is explicitly not used for the "
        "final task, {var} was temporarily recorded as {wrong_val}. For the final "
        "task, use only the VARIABLE DEFINITIONS section above."
    ),
    (
        "Historical archive note: an unrelated measurement context lists "
        "{var} = {wrong_val}. This archive note is out of scope for the final "
        "calculation; the initial variable definitions remain authoritative."
    ),
    (
        "Counterfactual scenario, not applicable here: if the experiment were run "
        "with an alternate sample, {var} would be {wrong_val}. This counterfactual "
        "must not override the definitions at the start."
    ),
    (
        "Source B reports {var} = {wrong_val} for a different dataset. The current "
        "task uses Source A, namely the VARIABLE DEFINITIONS section above."
    ),
]


def deterministic_seed(condition: str, trial_idx: int) -> int:
    key = f"{condition}:{CONTEXT_LENGTH}:{trial_idx}"
    h = int(hashlib.md5(key.encode()).hexdigest()[:8], 16)
    return SEED_BASE + h % 100000


def expected_answer(target: dict[str, int]) -> int:
    return target["a"] + target["b"] + target["c"]


def parse_answer(response: str) -> int | None:
    numbers = re.findall(r"-?\d+", response)
    if not numbers:
        return None
    return int(numbers[-1])


def _wrong_value(rng: random.Random, target: dict[str, int]) -> tuple[str, int, int, int]:
    var = rng.choice(list(target.keys()))
    original_val = target[var]
    offset = rng.choice(SUBTLE_OFFSETS)
    sign = rng.choice([-1, 1])
    wrong_val = original_val + sign * offset
    wrong_sum = expected_answer(target) - original_val + wrong_val
    return var, original_val, wrong_val, wrong_sum


def _inject_sentence(
    rng: random.Random,
    filler_sentences: list[str],
    sentence: str,
) -> float:
    mid = len(filler_sentences) // 2
    filler_sentences.insert(mid, sentence)
    return mid / max(len(filler_sentences), 1)


def _apply_scoped(
    rng: random.Random,
    filler_sentences: list[str],
    target: dict[str, int],
) -> dict[str, Any]:
    var, original_val, wrong_val, wrong_sum = _wrong_value(rng, target)
    sentence = rng.choice(SCOPED_TEMPLATES).format(var=var, wrong_val=wrong_val)
    position = _inject_sentence(rng, filler_sentences, sentence)
    return {
        "injected_var": var,
        "injected_original_val": original_val,
        "injected_wrong_val": wrong_val,
        "injected_position": position,
        "wrong_sum": wrong_sum,
        "injected_sentence": sentence,
    }


def _apply_subtle(
    rng: random.Random,
    filler_sentences: list[str],
    target: dict[str, int],
) -> dict[str, Any]:
    var, original_val, wrong_val, wrong_sum = _wrong_value(rng, target)
    sentence = rng.choice(SUBTLE_TEMPLATES).format(var=var, wrong_val=wrong_val)
    position = _inject_sentence(rng, filler_sentences, sentence)
    return {
        "injected_var": var,
        "injected_original_val": original_val,
        "injected_wrong_val": wrong_val,
        "injected_position": position,
        "wrong_sum": wrong_sum,
        "injected_sentence": sentence,
    }


def build_prompt(
    condition: str,
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
        CONTEXT_LENGTH - estimate_tokens(definition_block) - estimate_tokens(question) - 10,
    )

    meta: dict[str, Any] = {
        "target": target,
        "expression": "a + b + c",
        "expected": expected,
        "condition": condition,
        "context_length": CONTEXT_LENGTH,
        "injected_var": None,
        "injected_original_val": None,
        "injected_wrong_val": None,
        "injected_position": None,
        "wrong_sum": None,
        "injected_sentence": None,
    }

    if condition == "zero_sanity":
        filler_sentences = _generate_filler_block(rng, filler_budget)
    elif condition == "scoped":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_scoped(rng, filler_sentences, target))
    elif condition == "subtle":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_subtle(rng, filler_sentences, target))
    elif condition == "structural":
        filler_sentences = _generate_structural_block(rng, filler_budget, target)
    else:
        raise ValueError(f"Unknown condition: {condition}")

    prompt = definition_block + "\n".join(filler_sentences) + question
    meta["tokens_estimate"] = estimate_tokens(prompt)
    return prompt, expected, meta


def trials_path(model_name: str) -> Path:
    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    return EXP40_DIR / f"exp40_{safe}_trials.jsonl"


def summary_path(model_name: str) -> Path:
    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    return EXP40_DIR / f"exp40_{safe}_summary.json"


def load_completed(model_name: str) -> set[tuple[str, int]]:
    path = trials_path(model_name)
    completed: set[tuple[str, int]] = set()
    if not path.exists():
        return completed
    with path.open() as f:
        for line in f:
            if not line.strip():
                continue
            rec = json.loads(line)
            completed.add((rec["condition"], rec["trial_idx"]))
    return completed


def append_record(model_name: str, record: dict[str, Any]) -> None:
    with trials_path(model_name).open("a") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


def estimate_cost(model_name: str, n_trials: int, completed: set[tuple[str, int]]) -> tuple[int, float]:
    config = MODEL_CONFIGS[model_name]
    remaining_trials = 0
    for condition in CONDITIONS:
        for trial_idx in range(n_trials):
            if (condition, trial_idx) in completed:
                continue
            remaining_trials += 1
    remaining_tokens = remaining_trials * CONTEXT_LENGTH
    cost = (
        remaining_tokens / 1_000_000 * config["cost_per_1m_input"]
        + remaining_trials * MAX_TOKENS / 1_000_000 * config["cost_per_1m_output"]
    )
    return remaining_trials, cost


def print_plan(model_name: str, n_trials: int) -> None:
    completed = load_completed(model_name)
    remaining, cost = estimate_cost(model_name, n_trials, completed)
    print("=" * 72)
    print("EXP.40 CONTRADICTION-QUALITY TEST")
    print("=" * 72)
    print(f"Model:          {model_name}")
    print(f"Conditions:     {CONDITIONS}")
    print(f"Context:        {CONTEXT_LENGTH//1000}K")
    print(f"Trials/cell:    {n_trials}")
    print(f"Remaining:      {remaining} trials")
    print(f"Estimated cost: ${cost:.2f}")
    print(f"Output:         {trials_path(model_name)}")
    print()
    print("Primary prediction:")
    print("  accuracy(zero_sanity) ≈ accuracy(scoped) > accuracy(subtle) > accuracy(structural)")


def dry_run(model_name: str, n_trials: int) -> None:
    print_plan(model_name, n_trials)
    print("\nDry-run prompt checks:")
    for condition in CONDITIONS:
        seed = deterministic_seed(condition, 0)
        rng = random.Random(seed)
        prompt, expected, meta = build_prompt(condition, 0, rng)
        extra = ""
        if meta["injected_var"] is not None:
            extra = f" injected={meta['injected_var']}:{meta['injected_wrong_val']}"
        print(
            f"  {condition:12s} tokens≈{meta['tokens_estimate']:,} "
            f"expected={expected} chars={len(prompt):,}{extra}"
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
        print(f"\nCell: {condition} / {CONTEXT_LENGTH//1000}K")
        for trial_idx in range(n_trials):
            key = (condition, trial_idx)
            if key in completed:
                continue

            seed = deterministic_seed(condition, trial_idx)
            rng = random.Random(seed)
            prompt, expected, meta = build_prompt(condition, trial_idx, rng)

            raw_response = ""
            answer = None
            is_correct = False
            usage = {"input_tokens": None, "output_tokens": None}
            result_type = "succeeded"

            try:
                raw_response, usage = call_api(client, model_name, prompt, config["backend"])
                answer = parse_answer(raw_response)
                is_correct = answer == expected
            except Exception as exc:
                raw_response = f"ERROR: {exc}"
                result_type = "errored"

            record = {
                "experiment": EXPERIMENT_ID,
                "version": EXPERIMENT_VERSION,
                "model": model_name,
                "condition": condition,
                "context_length": CONTEXT_LENGTH,
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
                "injected_var": meta["injected_var"],
                "injected_original_val": meta["injected_original_val"],
                "injected_wrong_val": meta["injected_wrong_val"],
                "injected_position": meta["injected_position"],
                "wrong_sum": meta["wrong_sum"],
                "injected_sentence": meta["injected_sentence"],
                "timestamp": datetime.now().isoformat(),
            }
            append_record(model_name, record)
            status = "✓" if is_correct else "✗"
            print(f"  {trial_idx:02d} {status} expected={expected} answer={answer}")

    summarize(model_name)


def load_records(model_name: str) -> list[dict[str, Any]]:
    path = trials_path(model_name)
    if not path.exists():
        raise SystemExit(f"No trials file found: {path}")
    with path.open() as f:
        return [json.loads(line) for line in f if line.strip()]


def summarize(model_name: str) -> dict[str, Any]:
    records = load_records(model_name)
    by_condition: dict[str, dict[str, int]] = {}
    for condition in CONDITIONS:
        cell = [r for r in records if r["condition"] == condition and r["result_type"] == "succeeded"]
        n = len(cell)
        correct = sum(1 for r in cell if r["is_correct"])
        errors = sum(1 for r in records if r["condition"] == condition and r["result_type"] == "errored")
        by_condition[condition] = {
            "correct": correct,
            "n": n,
            "errors": errors,
            "accuracy": correct / n if n else None,
        }

    acc = {k: v["accuracy"] for k, v in by_condition.items()}
    primary_supported = (
        acc.get("scoped") is not None
        and acc.get("subtle") is not None
        and acc.get("structural") is not None
        and acc["scoped"] > acc["subtle"] > acc["structural"]
    )
    zero_sanity_passed = acc.get("zero_sanity") is not None and acc["zero_sanity"] >= 0.80
    scoped_zero_gap = None
    scoped_near_zero = None
    if acc.get("zero_sanity") is not None and acc.get("scoped") is not None:
        scoped_zero_gap = acc["zero_sanity"] - acc["scoped"]
        scoped_near_zero = scoped_zero_gap <= 0.10
    strong_support = (
        primary_supported
        and scoped_near_zero is True
        and (acc["scoped"] - acc["subtle"]) >= 0.20
        and (acc["subtle"] - acc["structural"]) >= 0.20
    )

    summary = {
        "experiment": EXPERIMENT_ID,
        "version": EXPERIMENT_VERSION,
        "model": model_name,
        "conditions": by_condition,
        "primary_prediction_supported": primary_supported,
        "strong_support": strong_support,
        "zero_sanity_passed": zero_sanity_passed,
        "scoped_zero_gap": scoped_zero_gap,
        "scoped_within_10pt_of_zero_sanity": scoped_near_zero,
        "generated_at": datetime.now().isoformat(),
    }
    summary_path(model_name).write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    dry = sub.add_parser("dry-run")
    dry.add_argument("--model", default=DEFAULT_MODEL)
    dry.add_argument("--trials", type=int, default=N_TRIALS)

    run_p = sub.add_parser("run")
    run_p.add_argument("--model", default=DEFAULT_MODEL)
    run_p.add_argument("--trials", type=int, default=N_TRIALS)
    run_p.add_argument("--execute", action="store_true")
    run_p.add_argument("--no-resume", action="store_true")

    summ = sub.add_parser("summarize")
    summ.add_argument("--model", default=DEFAULT_MODEL)

    args = parser.parse_args()
    if args.cmd == "dry-run":
        dry_run(args.model, args.trials)
    elif args.cmd == "run":
        run(args.model, args.trials, execute=args.execute, resume=not args.no_resume)
    elif args.cmd == "summarize":
        summarize(args.model)


if __name__ == "__main__":
    main()
