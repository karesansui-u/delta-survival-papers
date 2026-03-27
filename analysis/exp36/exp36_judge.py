#!/usr/bin/env python3
"""
Experiment 36: LLM-as-Judge Post-Hoc Evaluation
================================================

Reads raw_response from exp36 trial JSONL and re-evaluates each trial
using a separate judge model. This addresses parse_answer false negatives
discovered in exp35's Sonnet 4.6 data.

Judge model: GPT-4.1 Nano (cheap, fast, separate from test subjects)
Cost: ~$0.10 for 270 trials

Outputs a new JSONL with judge verdicts appended to each trial record.

Usage:
  # Judge all trials for a model:
  python analysis/exp36_judge.py --model gpt-4.1-nano

  # Judge with a specific judge model:
  python analysis/exp36_judge.py --model gpt-4.1-nano --judge-model gpt-4.1-nano

  # Dry run (show judge prompts without calling API):
  python analysis/exp36_judge.py --model gpt-4.1-nano --dry-run

  # Also judge exp35 Sonnet 4.6 data (retroactive):
  python analysis/exp36_judge.py --exp35-sonnet
"""

import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

OUTPUT_DIR = Path(__file__).parent

JUDGE_MODEL = "gpt-4.1-nano"
JUDGE_BACKEND = "openai"
JUDGE_MAX_TOKENS = 256
JUDGE_TEMPERATURE = 0.0
RATE_LIMIT_SECONDS = 0.2

JUDGE_PROMPT_TEMPLATE = """\
You are an impartial judge evaluating an LLM experiment.

The test subject was given variable definitions (a, b, c) at the start of a \
long context, and asked to compute a + b + c.

Correct answer: {expected}
{subtle_info}
The test subject responded:
---
{raw_response}
---

Evaluate the response and return ONLY valid JSON (no markdown, no explanation):
{{
  "extracted_answer": <the numerical answer the subject gives, or null if none>,
  "correct_values_identified": <true if subject identifies the original a, b, c correctly>,
  "contradiction_detected": <true if subject mentions contradictions or conflicting info>,
  "refusal_or_hedge": <true if subject refuses to answer or heavily qualifies>,
  "wrong_val_adopted": <true if subject uses the wrong value from a secondary source>,
  "judge_verdict": "correct" | "incorrect" | "partial" | "refusal"
}}

Rules for judge_verdict:
- "correct": extracted_answer equals {expected}
- "incorrect": a clear numerical answer is given but it does not equal {expected}
- "partial": correct values identified but final sum not computed or truncated
- "refusal": subject refuses or gives no numerical answer"""


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


def create_judge_client():
    from openai import OpenAI
    return OpenAI(api_key=_load_openai_key())


def build_judge_prompt(trial: dict) -> str:
    delta_level = trial.get("delta_level", "zero")
    context_info = ""

    if delta_level == "subtle" and trial.get("wrong_sum") is not None:
        context_info = (
            f"\nNote: A secondary source in the context reported "
            f"{trial['injected_var']} = {trial['injected_wrong_val']} "
            f"(original was {trial['injected_original_val']}). "
            f"If the subject adopted this wrong value, the sum would be {trial['wrong_sum']}.\n"
        )
    elif delta_level == "structural":
        context_info = (
            "\nNote: The context contained logically impossible self-referential "
            "contradictions (e.g., 'x = x + 1') mixed into the filler text at ~30% density. "
            "Responses like '0', 'undefined', or 'Infinity' may indicate contradiction detection.\n"
        )

    return JUDGE_PROMPT_TEMPLATE.format(
        expected=trial["expected"],
        subtle_info=context_info,
        raw_response=trial.get("raw_response", ""),
    )


def call_judge(client, prompt: str) -> dict:
    response = client.chat.completions.create(
        model=JUDGE_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=JUDGE_TEMPERATURE,
        max_tokens=JUDGE_MAX_TOKENS,
    )
    text = response.choices[0].message.content.strip()
    if text.startswith("```"):
        text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text[:-3]
        text = text.strip()

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return {"parse_error": True, "raw_judge_response": text}


def judge_exp36_trials(model_name: str, dry_run: bool = False):
    if model_name == JUDGE_MODEL:
        print(f"  ⚠ WARNING: Judge model ({JUDGE_MODEL}) is the same as the test subject.")
        print(f"    Self-evaluation bias possible. Consider --judge-model with a different model.")
        print()

    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    trials_path = OUTPUT_DIR / f"exp36_{safe}_trials.jsonl"
    judged_path = OUTPUT_DIR / f"exp36_{safe}_judged.jsonl"

    if not trials_path.exists():
        print(f"  No trials found: {trials_path}")
        return

    trials = []
    with open(trials_path) as f:
        for line in f:
            line = line.strip()
            if line:
                trials.append(json.loads(line))

    already_judged = set()
    if judged_path.exists():
        with open(judged_path) as f:
            for line in f:
                line = line.strip()
                if line:
                    rec = json.loads(line)
                    already_judged.add(
                        (rec["delta_level"], rec["context_length"], rec["trial_idx"])
                    )

    to_judge = [
        t for t in trials
        if t.get("result_type") == "succeeded"
        and (t["delta_level"], t["context_length"], t["trial_idx"]) not in already_judged
    ]

    print(f"  Total trials:    {len(trials)}")
    print(f"  Already judged:  {len(already_judged)}")
    print(f"  To judge:        {len(to_judge)}")
    print(f"  Skipped (error): {len(trials) - len([t for t in trials if t.get('result_type') == 'succeeded'])}")

    if not to_judge:
        print("  Nothing to judge.")
        return

    est_cost = len(to_judge) * 600 / 1_000_000 * 0.10 + len(to_judge) * 150 / 1_000_000 * 0.40
    print(f"  Est. judge cost: ~${est_cost:.3f}")
    print()

    if dry_run:
        sample = to_judge[0]
        print("  [DRY RUN] Sample judge prompt:")
        print("  " + "-" * 50)
        prompt = build_judge_prompt(sample)
        for line in prompt.split("\n"):
            print(f"  {line}")
        print("  " + "-" * 50)
        return

    client = create_judge_client()

    n_correct = 0
    n_incorrect = 0
    n_partial = 0
    n_refusal = 0
    n_errors = 0

    for i, trial in enumerate(to_judge):
        prompt = build_judge_prompt(trial)
        try:
            verdict = call_judge(client, prompt)
        except Exception as e:
            verdict = {"parse_error": True, "error": str(e)}
            n_errors += 1

        judged_record = {
            **trial,
            "judge_model": JUDGE_MODEL,
            "judge_verdict": verdict.get("judge_verdict"),
            "judge_extracted_answer": verdict.get("extracted_answer"),
            "judge_correct_values": verdict.get("correct_values_identified"),
            "judge_contradiction_detected": verdict.get("contradiction_detected"),
            "judge_refusal": verdict.get("refusal_or_hedge"),
            "judge_wrong_val_adopted": verdict.get("wrong_val_adopted"),
            "judge_raw": verdict,
            "judged_at": datetime.now().isoformat(),
        }

        with open(judged_path, "a") as f:
            f.write(json.dumps(judged_record, ensure_ascii=False) + "\n")

        v = verdict.get("judge_verdict", "?")
        if v == "correct":
            n_correct += 1
        elif v == "incorrect":
            n_incorrect += 1
        elif v == "partial":
            n_partial += 1
        elif v == "refusal":
            n_refusal += 1

        if (i + 1) % 20 == 0:
            print(f"  [{i+1}/{len(to_judge)}] correct={n_correct} incorrect={n_incorrect} "
                  f"partial={n_partial} refusal={n_refusal} errors={n_errors}")

        time.sleep(RATE_LIMIT_SECONDS)

    print(f"\n  Done! {len(to_judge)} trials judged.")
    print(f"  correct={n_correct} incorrect={n_incorrect} partial={n_partial} "
          f"refusal={n_refusal} errors={n_errors}")
    print(f"  Saved to: {judged_path}")

    _print_judge_summary(judged_path)


def judge_exp35_sonnet(dry_run: bool = False):
    """Retroactively judge exp35 Sonnet 4.6 trials that have raw_response."""
    merged_path = OUTPUT_DIR / "exp35_sonnet_batch_claude_sonnet_4_6" / "merged_trials.json"
    judged_path = OUTPUT_DIR / "exp35_sonnet46_judged.jsonl"

    if not merged_path.exists():
        print(f"  No exp35 Sonnet data: {merged_path}")
        return

    with open(merged_path) as f:
        trials = json.load(f)

    trials_with_response = [
        t for t in trials
        if t.get("raw_response") and t.get("result_type", "succeeded") == "succeeded"
    ]

    already_judged = set()
    if judged_path.exists():
        with open(judged_path) as f:
            for line in f:
                line = line.strip()
                if line:
                    rec = json.loads(line)
                    already_judged.add(
                        (rec["delta_level"], rec["context_length"], rec["trial_idx"])
                    )

    to_judge = [
        t for t in trials_with_response
        if (t["delta_level"], t["context_length"], t["trial_idx"]) not in already_judged
    ]

    print(f"  Exp35 Sonnet 4.6 retroactive judge")
    print(f"  Total trials:    {len(trials)}")
    print(f"  With response:   {len(trials_with_response)}")
    print(f"  Already judged:  {len(already_judged)}")
    print(f"  To judge:        {len(to_judge)}")

    if not to_judge:
        print("  Nothing to judge.")
        return

    if dry_run:
        print("  [DRY RUN] Would judge", len(to_judge), "trials")
        return

    client = create_judge_client()

    for i, trial in enumerate(to_judge):
        adapted_trial = {
            "expected": trial["expected"],
            "raw_response": trial.get("raw_response", ""),
            "delta_level": trial["delta_level"],
            "context_length": trial["context_length"],
            "trial_idx": trial["trial_idx"],
            "injected_var": None,
            "injected_wrong_val": None,
            "injected_original_val": None,
            "wrong_sum": None,
        }

        prompt = build_judge_prompt(adapted_trial)
        try:
            verdict = call_judge(client, prompt)
        except Exception as e:
            verdict = {"parse_error": True, "error": str(e)}

        judged_record = {
            **trial,
            "judge_model": JUDGE_MODEL,
            "judge_verdict": verdict.get("judge_verdict"),
            "judge_extracted_answer": verdict.get("extracted_answer"),
            "judge_correct_values": verdict.get("correct_values_identified"),
            "judge_contradiction_detected": verdict.get("contradiction_detected"),
            "judge_refusal": verdict.get("refusal_or_hedge"),
            "judge_raw": verdict,
            "judged_at": datetime.now().isoformat(),
        }

        with open(judged_path, "a") as f:
            f.write(json.dumps(judged_record, ensure_ascii=False) + "\n")

        if (i + 1) % 20 == 0:
            print(f"  [{i+1}/{len(to_judge)}]")

        time.sleep(RATE_LIMIT_SECONDS)

    print(f"\n  Done! Saved to: {judged_path}")


def _print_judge_summary(judged_path: Path):
    if not judged_path.exists():
        return

    records = []
    with open(judged_path) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))

    print(f"\n{'=' * 60}")
    print(f"JUDGE SUMMARY ({len(records)} trials)")
    print(f"{'=' * 60}")

    from collections import Counter

    for delta in ["zero", "subtle", "structural"]:
        cells = [r for r in records if r.get("delta_level") == delta]
        if not cells:
            continue
        print(f"\n  δ = {delta}")
        for ctx in sorted(set(r["context_length"] for r in cells)):
            ctx_cells = [r for r in cells if r["context_length"] == ctx]
            verdicts = Counter(r.get("judge_verdict") for r in ctx_cells)
            strict_acc = sum(1 for r in ctx_cells if r.get("is_correct")) / len(ctx_cells)
            judge_acc = verdicts.get("correct", 0) / len(ctx_cells)
            partial = verdicts.get("partial", 0)
            extra = f"  partial={partial}" if partial else ""
            print(f"    {ctx // 1000:>4}K: strict={strict_acc:.2f} judge={judge_acc:.2f} "
                  f"(n={len(ctx_cells)}){extra}")


def main():
    global JUDGE_MODEL
    import argparse

    parser = argparse.ArgumentParser(description="Exp.36 LLM-as-Judge")
    parser.add_argument("--model", default="gpt-4.1-nano",
                        help="Model whose trials to judge")
    parser.add_argument("--judge-model", default=JUDGE_MODEL,
                        help="Model to use as judge")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--exp35-sonnet", action="store_true",
                        help="Judge exp35 Sonnet 4.6 data retroactively")

    args = parser.parse_args()
    JUDGE_MODEL = args.judge_model

    if args.exp35_sonnet:
        judge_exp35_sonnet(dry_run=args.dry_run)
    else:
        judge_exp36_trials(args.model, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
