#!/usr/bin/env python3
"""Exp.42: scope-strength dose response.

Paid API calls require the explicit `run --execute` command. Use `dry-run` to
inspect prompts, token counts, and cost estimates without spending money.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Callable

import numpy as np
from scipy.optimize import minimize

try:
    from scipy.stats import fisher_exact

    HAS_SCIPY_STATS = True
except Exception:
    fisher_exact = None
    HAS_SCIPY_STATS = False

EXP42_DIR = Path(__file__).resolve().parent
EXP36_DIR = EXP42_DIR.parent / "exp36"
sys.path.insert(0, str(EXP36_DIR))

from exp36_context_delta_matrix import (  # type: ignore
    MODEL_CONFIGS,
    SUBTLE_OFFSETS,
    TARGET_SETS,
    call_api,
    create_client,
    estimate_tokens,
    _generate_filler_block,
    _generate_structural_block,
)


EXPERIMENT_ID = "exp42_scope_gradient"
EXPERIMENT_VERSION = "1.0.0"
SEED_BASE = 420000

PRIMARY_CONDITIONS = ["strong_scope", "medium_scope", "weak_scope", "subtle"]
DIAGNOSTIC_CONDITIONS = ["zero_sanity", "structural_anchor"]
CONTEXT_LENGTH = 32_000
PRIMARY_TRIALS = 50
DIAGNOSTIC_TRIALS = 20
MAX_TOKENS = 512

DEFAULT_MODEL = "gpt-4.1-mini"

STRONG_SCOPE_TEMPLATES = [
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

MEDIUM_SCOPE_TEMPLATES = [
    "In the 2019 calibration context, Source B recorded {var} = {wrong_val}.",
    "For the archived 2019 dataset, a calibration entry lists {var} = {wrong_val}.",
    "During a previous calibration run, the legacy dataset recorded {var} = {wrong_val}.",
    "In a separate historical dataset, Source B logged {var} = {wrong_val}.",
]

WEAK_SCOPE_TEMPLATES = [
    "Source B reports {var} = {wrong_val}.",
    "Source B lists {var} = {wrong_val}.",
    "Source B has an entry with {var} = {wrong_val}.",
    "Source B's record says {var} = {wrong_val}.",
]

SUBTLE_TEMPLATES = [
    "A later note records {var} = {wrong_val}.",
    "A later note lists {var} as {wrong_val}.",
    "A later entry gives {var} = {wrong_val}.",
    "A later record contains {var} = {wrong_val}.",
]


def safe_name(model_name: str) -> str:
    return model_name.replace(":", "_").replace("/", "_").replace(".", "_")


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


def _inject_sentence(filler_sentences: list[str], sentence: str) -> float:
    mid = len(filler_sentences) // 2
    filler_sentences.insert(mid, sentence)
    return mid / max(len(filler_sentences), 1)


def _apply_conflict(
    rng: random.Random,
    filler_sentences: list[str],
    target: dict[str, int],
    templates: list[str],
    scope_strength: int,
) -> dict[str, Any]:
    var, original_val, wrong_val, wrong_sum = _wrong_value(rng, target)
    sentence = rng.choice(templates).format(var=var, wrong_val=wrong_val)
    position = _inject_sentence(filler_sentences, sentence)
    return {
        "injected_var": var,
        "injected_original_val": original_val,
        "injected_wrong_val": wrong_val,
        "injected_position": position,
        "wrong_sum": wrong_sum,
        "injected_sentence": sentence,
        "scope_strength": scope_strength,
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
        "scope_strength": None,
    }

    if condition == "zero_sanity":
        filler_sentences = _generate_filler_block(rng, filler_budget)
    elif condition == "structural_anchor":
        filler_sentences = _generate_structural_block(rng, filler_budget, target)
    elif condition == "strong_scope":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_conflict(rng, filler_sentences, target, STRONG_SCOPE_TEMPLATES, 3))
    elif condition == "medium_scope":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_conflict(rng, filler_sentences, target, MEDIUM_SCOPE_TEMPLATES, 2))
    elif condition == "weak_scope":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_conflict(rng, filler_sentences, target, WEAK_SCOPE_TEMPLATES, 1))
    elif condition == "subtle":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_conflict(rng, filler_sentences, target, SUBTLE_TEMPLATES, 0))
    else:
        raise ValueError(f"Unknown condition: {condition}")

    prompt = definition_block + "\n".join(filler_sentences) + question
    meta["tokens_estimate"] = estimate_tokens(prompt)
    return prompt, expected, meta


def trials_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_trials.jsonl"


def summary_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_summary.json"


def results_summary_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_results_summary.md"


def model_comparison_json_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_model_comparison.json"


def model_comparison_md_path(model_name: str) -> Path:
    return EXP42_DIR / f"exp42_{safe_name(model_name)}_model_comparison.md"


def planned_conditions(include_diagnostics: bool) -> list[tuple[str, int]]:
    plan = [(condition, PRIMARY_TRIALS) for condition in PRIMARY_CONDITIONS]
    if include_diagnostics:
        plan.extend((condition, DIAGNOSTIC_TRIALS) for condition in DIAGNOSTIC_CONDITIONS)
    return plan


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


def estimate_cost(model_name: str, include_diagnostics: bool, completed: set[tuple[str, int]]) -> tuple[int, float]:
    config = MODEL_CONFIGS[model_name]
    remaining_trials = 0
    for condition, n_trials in planned_conditions(include_diagnostics):
        for trial_idx in range(n_trials):
            if (condition, trial_idx) not in completed:
                remaining_trials += 1
    remaining_tokens = remaining_trials * CONTEXT_LENGTH
    cost = (
        remaining_tokens / 1_000_000 * config["cost_per_1m_input"]
        + remaining_trials * MAX_TOKENS / 1_000_000 * config["cost_per_1m_output"]
    )
    return remaining_trials, cost


def print_plan(model_name: str, include_diagnostics: bool) -> None:
    completed = load_completed(model_name)
    remaining, cost = estimate_cost(model_name, include_diagnostics, completed)
    print("=" * 72)
    print("EXP.42 SCOPE-STRENGTH DOSE RESPONSE")
    print("=" * 72)
    print(f"Model:          {model_name}")
    print(f"Primary cells:  {PRIMARY_CONDITIONS}")
    print(f"Diagnostics:    {DIAGNOSTIC_CONDITIONS if include_diagnostics else 'not planned'}")
    print(f"Context:        {CONTEXT_LENGTH//1000}K")
    print(f"Primary n/cell: {PRIMARY_TRIALS}")
    print(f"Diag n/cell:    {DIAGNOSTIC_TRIALS if include_diagnostics else 0}")
    print(f"Remaining:      {remaining} trials")
    print(f"Estimated cost: ${cost:.2f}")
    print(f"Output:         {trials_path(model_name)}")
    print()
    print("Primary prediction:")
    print("  accuracy(strong_scope) > accuracy(medium_scope) > accuracy(weak_scope)")


def dry_run(model_name: str, include_diagnostics: bool) -> None:
    print_plan(model_name, include_diagnostics)
    print("\nDry-run prompt checks:")
    for condition, _ in planned_conditions(include_diagnostics):
        seed = deterministic_seed(condition, 0)
        rng = random.Random(seed)
        prompt, expected, meta = build_prompt(condition, 0, rng)
        extra = ""
        if meta["injected_var"] is not None:
            extra = f" injected={meta['injected_var']}:{meta['injected_wrong_val']} strength={meta['scope_strength']}"
        print(
            f"  {condition:17s} tokens≈{meta['tokens_estimate']:,} "
            f"expected={expected} chars={len(prompt):,}{extra}"
        )
        if meta["injected_sentence"]:
            print(f"    sentence: {meta['injected_sentence']}")


def run(model_name: str, include_diagnostics: bool, execute: bool, resume: bool = True) -> None:
    if not execute:
        raise SystemExit("Refusing paid API calls without --execute. Use dry-run first.")

    config = MODEL_CONFIGS.get(model_name)
    if not config:
        raise SystemExit(f"Unknown model: {model_name}")
    if config["backend"] not in {"openai", "gemini"}:
        raise SystemExit(f"Unsupported backend for this runner: {config['backend']}")

    completed = load_completed(model_name) if resume else set()
    print_plan(model_name, include_diagnostics)
    client = create_client(config["backend"])

    for condition, n_trials in planned_conditions(include_diagnostics):
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
                "target_key": target_key(meta["target"]),
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
                "scope_strength": meta["scope_strength"],
                "timestamp": datetime.now().isoformat(),
            }
            append_record(model_name, record)
            status = "✓" if is_correct else "✗"
            print(f"  {trial_idx:02d} {status} expected={expected} answer={answer}")

    summarize(model_name)
    compare_models(model_name)


def load_records(model_name: str) -> list[dict[str, Any]]:
    path = trials_path(model_name)
    if not path.exists():
        raise SystemExit(f"No trials file found: {path}")
    with path.open() as f:
        return [json.loads(line) for line in f if line.strip()]


def finite_or_none(value: float) -> float | None:
    value = float(value)
    return value if math.isfinite(value) else None


def summarize(model_name: str) -> dict[str, Any]:
    records = load_records(model_name)
    conditions = PRIMARY_CONDITIONS + DIAGNOSTIC_CONDITIONS
    by_condition: dict[str, dict[str, Any]] = {}
    for condition in conditions:
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
        acc.get("strong_scope") is not None
        and acc.get("medium_scope") is not None
        and acc.get("weak_scope") is not None
        and acc["strong_scope"] > acc["medium_scope"] > acc["weak_scope"]
    )
    strong_support = (
        primary_supported
        and (acc["strong_scope"] - acc["medium_scope"]) >= 0.10
        and (acc["medium_scope"] - acc["weak_scope"]) >= 0.10
    )
    weak_subtle_gap = None
    weak_source_diagnostic_passed = None
    if acc.get("weak_scope") is not None and acc.get("subtle") is not None:
        weak_subtle_gap = acc["weak_scope"] - acc["subtle"]
        weak_source_diagnostic_passed = 0 <= weak_subtle_gap <= 0.15
    zero_sanity_passed = None
    if acc.get("zero_sanity") is not None:
        zero_sanity_passed = acc["zero_sanity"] >= 0.80
    structural_anchor_confirmed = None
    if acc.get("structural_anchor") is not None:
        structural_anchor_confirmed = acc["structural_anchor"] < 0.20
    secondary_checks = {
        "strong_above_0_80": (
            acc["strong_scope"] >= 0.80 if acc.get("strong_scope") is not None else None
        ),
        "weak_above_or_equal_subtle": (
            acc["weak_scope"] >= acc["subtle"]
            if acc.get("weak_scope") is not None and acc.get("subtle") is not None
            else None
        ),
        "strong_above_subtle": (
            acc["strong_scope"] > acc["subtle"]
            if acc.get("strong_scope") is not None and acc.get("subtle") is not None
            else None
        ),
        "medium_above_subtle": (
            acc["medium_scope"] > acc["subtle"]
            if acc.get("medium_scope") is not None and acc.get("subtle") is not None
            else None
        ),
    }

    fisher_tests = {"available": HAS_SCIPY_STATS, "tests": {}}
    if HAS_SCIPY_STATS:
        comparisons = [
            ("strong_vs_medium", "strong_scope", "medium_scope", "greater"),
            ("medium_vs_weak", "medium_scope", "weak_scope", "greater"),
            ("weak_vs_subtle", "weak_scope", "subtle", "greater"),
        ]
        for name, a, b, alternative in comparisons:
            a_cell = by_condition[a]
            b_cell = by_condition[b]
            if not a_cell["n"] or not b_cell["n"]:
                continue
            table = [
                [a_cell["correct"], a_cell["n"] - a_cell["correct"]],
                [b_cell["correct"], b_cell["n"] - b_cell["correct"]],
            ]
            odds_ratio, p_value = fisher_exact(table, alternative=alternative)
            fisher_tests["tests"][name] = {
                "condition_a": a,
                "condition_b": b,
                "alternative": alternative,
                "table": table,
                "odds_ratio": finite_or_none(odds_ratio),
                "p_value": finite_or_none(p_value),
            }

    summary = {
        "experiment": EXPERIMENT_ID,
        "version": EXPERIMENT_VERSION,
        "model": model_name,
        "conditions": by_condition,
        "primary_prediction_supported": primary_supported,
        "strong_support": strong_support,
        "weak_subtle_gap": weak_subtle_gap,
        "weak_source_diagnostic_passed": weak_source_diagnostic_passed,
        "secondary_checks": secondary_checks,
        "zero_sanity_passed": zero_sanity_passed,
        "structural_anchor_confirmed": structural_anchor_confirmed,
        "fisher_exact": fisher_tests,
        "generated_at": datetime.now().isoformat(),
    }
    summary_path(model_name).write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_results_markdown(model_name, summary)
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return summary


def write_results_markdown(model_name: str, summary: dict[str, Any]) -> None:
    lines: list[str] = []
    lines.append("# Exp.42 Results Summary")
    lines.append("")
    lines.append(f"Model: `{model_name}`")
    lines.append("")
    lines.append("| Condition | Correct | N | Accuracy | Errors |")
    lines.append("|---|---:|---:|---:|---:|")
    for condition, cell in summary["conditions"].items():
        accuracy = cell["accuracy"]
        acc_text = "NA" if accuracy is None else f"{accuracy:.3f}"
        lines.append(
            f"| `{condition}` | {cell['correct']} | {cell['n']} | {acc_text} | {cell['errors']} |"
        )
    lines.append("")
    lines.append(f"Primary prediction supported: `{summary['primary_prediction_supported']}`")
    lines.append(f"Strong support: `{summary['strong_support']}`")
    lines.append(f"Weak-source diagnostic gap: `{summary['weak_subtle_gap']}`")
    lines.append(f"Secondary checks: `{summary['secondary_checks']}`")
    lines.append(f"Zero sanity passed: `{summary['zero_sanity_passed']}`")
    lines.append(f"Structural anchor confirmed: `{summary['structural_anchor_confirmed']}`")
    lines.append("")
    results_summary_path(model_name).write_text("\n".join(lines), encoding="utf-8")


def target_key(target: dict[str, int]) -> str:
    return f"{target['a']}:{target['b']}:{target['c']}"


@dataclass(frozen=True)
class Row:
    condition: str
    target_key: str
    is_correct: bool


FeatureFn = Callable[[Row], list[float]]


FEATURE_SETS: dict[str, FeatureFn] = {
    "quality_blind": lambda r: [1.0],
    "binary_scoped": lambda r: [
        1.0,
        0.0 if r.condition == "subtle" else 1.0,
    ],
    "scope_gradient": lambda r: [
        1.0,
        {
            "strong_scope": 3.0,
            "medium_scope": 2.0,
            "weak_scope": 1.0,
            "subtle": 0.0,
        }[r.condition],
    ],
}


def load_rows_for_comparison(model_name: str) -> list[Row]:
    rows: list[Row] = []
    for rec in load_records(model_name):
        if rec["result_type"] != "succeeded":
            continue
        if rec["condition"] not in PRIMARY_CONDITIONS:
            continue
        rows.append(
            Row(
                condition=rec["condition"],
                target_key=rec.get("target_key") or target_key(rec["target"]),
                is_correct=bool(rec["is_correct"]),
            )
        )
    return rows


def sigmoid(z: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(z, -50, 50)))


def matrix(rows: list[Row], feature_fn: FeatureFn) -> tuple[np.ndarray, np.ndarray]:
    x = np.asarray([feature_fn(row) for row in rows], dtype=float)
    y = np.asarray([1.0 if row.is_correct else 0.0 for row in rows], dtype=float)
    return x, y


def fit_logistic(x: np.ndarray, y: np.ndarray, l2: float = 0.5) -> np.ndarray:
    def objective(beta: np.ndarray) -> tuple[float, np.ndarray]:
        p = sigmoid(x @ beta)
        eps = 1e-12
        nll = -np.sum(y * np.log(p + eps) + (1 - y) * np.log(1 - p + eps))
        penalty = 0.5 * l2 * float(np.sum(beta[1:] ** 2))
        grad = x.T @ (p - y)
        grad[1:] += l2 * beta[1:]
        return nll + penalty, grad

    init = np.zeros(x.shape[1], dtype=float)
    result = minimize(
        lambda b: objective(b)[0],
        init,
        jac=lambda b: objective(b)[1],
        method="L-BFGS-B",
        options={"gtol": 1e-8, "maxiter": 1000, "ftol": 1e-12},
    )
    if not result.success:
        raise RuntimeError(f"logistic fit failed: {result.message}")
    return result.x


def metrics(rows: list[Row], beta: np.ndarray, feature_fn: FeatureFn) -> dict[str, float]:
    x, y = matrix(rows, feature_fn)
    p = np.clip(sigmoid(x @ beta), 1e-12, 1 - 1e-12)
    return {
        "n": int(len(y)),
        "log_loss": float(-np.mean(y * np.log(p) + (1 - y) * np.log(1 - p))),
        "brier": float(np.mean((p - y) ** 2)),
        "accuracy_at_0_5": float(np.mean((p >= 0.5) == y)),
    }


def weighted_mean(folds: list[dict], metric: str) -> float:
    total_n = sum(fold["metrics"]["n"] for fold in folds)
    return sum(fold["metrics"][metric] * fold["metrics"]["n"] for fold in folds) / total_n


def leave_one_target_out(rows: list[Row]) -> dict[str, dict]:
    result: dict[str, dict] = {}
    targets = sorted({row.target_key for row in rows})
    for feature_name, feature_fn in FEATURE_SETS.items():
        folds = []
        for target in targets:
            train = [row for row in rows if row.target_key != target]
            test = [row for row in rows if row.target_key == target]
            x_train, y_train = matrix(train, feature_fn)
            beta = fit_logistic(x_train, y_train)
            folds.append(
                {
                    "heldout_target": target,
                    "beta": [float(v) for v in beta],
                    "metrics": metrics(test, beta, feature_fn),
                }
            )
        result[feature_name] = {
            "folds": folds,
            "weighted_log_loss": weighted_mean(folds, "log_loss"),
            "weighted_brier": weighted_mean(folds, "brier"),
            "weighted_accuracy_at_0_5": weighted_mean(folds, "accuracy_at_0_5"),
        }
    return result


def compare_models(model_name: str) -> dict[str, Any]:
    rows = load_rows_for_comparison(model_name)
    if not rows:
        raise SystemExit("No primary Exp.42 rows found for model comparison.")
    results = {
        "experiment": EXPERIMENT_ID,
        "model": model_name,
        "n": len(rows),
        "leave_one_target_out": leave_one_target_out(rows),
        "generated_at": datetime.now().isoformat(),
    }
    model_comparison_json_path(model_name).write_text(
        json.dumps(results, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_model_comparison_markdown(model_name, results["leave_one_target_out"])
    print(json.dumps({
        "model": model_name,
        "n": len(rows),
        "model_comparison": str(model_comparison_md_path(model_name)),
    }, ensure_ascii=False, indent=2))
    return results


def write_model_comparison_markdown(model_name: str, results: dict[str, dict]) -> None:
    lines: list[str] = []
    lines.append("# Exp.42 Model Comparison")
    lines.append("")
    lines.append(f"Model: `{model_name}`")
    lines.append("")
    lines.append("Leave-one-target-out comparison over primary conditions only.")
    lines.append("")
    lines.append("| Model | Log loss | Brier | Accuracy at 0.5 |")
    lines.append("|---|---:|---:|---:|")
    for name, values in sorted(results.items(), key=lambda item: item[1]["weighted_log_loss"]):
        lines.append(
            f"| `{name}` | {values['weighted_log_loss']:.4f} | "
            f"{values['weighted_brier']:.4f} | {values['weighted_accuracy_at_0_5']:.4f} |"
        )
    lines.append("")
    lines.append("Preregistered direction: `scope_gradient` < `binary_scoped` < `quality_blind` in log loss.")
    lines.append("")
    model_comparison_md_path(model_name).write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    dry = sub.add_parser("dry-run")
    dry.add_argument("--model", default=DEFAULT_MODEL)
    dry.add_argument("--include-diagnostics", action="store_true")

    run_p = sub.add_parser("run")
    run_p.add_argument("--model", default=DEFAULT_MODEL)
    run_p.add_argument("--include-diagnostics", action="store_true")
    run_p.add_argument("--execute", action="store_true")
    run_p.add_argument("--no-resume", action="store_true")

    summ = sub.add_parser("summarize")
    summ.add_argument("--model", default=DEFAULT_MODEL)

    cmp_p = sub.add_parser("compare")
    cmp_p.add_argument("--model", default=DEFAULT_MODEL)

    args = parser.parse_args()
    if args.cmd == "dry-run":
        dry_run(args.model, args.include_diagnostics)
    elif args.cmd == "run":
        run(args.model, args.include_diagnostics, execute=args.execute, resume=not args.no_resume)
    elif args.cmd == "summarize":
        summarize(args.model)
    elif args.cmd == "compare":
        compare_models(args.model)


if __name__ == "__main__":
    main()
