#!/usr/bin/env python3
"""Exp.41: cross-model width replication.

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

EXP41_DIR = Path(__file__).resolve().parent
EXP36_DIR = EXP41_DIR.parent / "exp36"
sys.path.insert(0, str(EXP36_DIR))

from exp36_context_delta_matrix import (  # type: ignore
    MODEL_CONFIGS,
    SUBTLE_OFFSETS,
    SUBTLE_TEMPLATES,
    TARGET_SETS,
    call_api,
    create_client,
    estimate_tokens,
    _generate_filler_block,
    _generate_structural_block,
)


EXPERIMENT_ID = "exp41_width_replication"
EXPERIMENT_VERSION = "1.0.0"
SEED_BASE = 410000

PRIMARY_MODELS = ["gpt-4.1-nano", "gemini-3.1-flash-lite-preview"]
POSITIVE_CONTROL_MODELS = ["gpt-4.1-mini"]

PRIMARY_CONDITIONS = ["scoped", "subtle", "structural"]
DIAGNOSTIC_CONDITIONS = ["zero_sanity"]
CONTEXT_LENGTH = 32_000
PRIMARY_TRIALS = 30
DIAGNOSTIC_TRIALS = 10
MAX_TOKENS = 512

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


def safe_name(model_name: str) -> str:
    return model_name.replace(":", "_").replace("/", "_").replace(".", "_")


def parse_models(raw: str) -> list[str]:
    return [item.strip() for item in raw.split(",") if item.strip()]


def selected_models(include_positive_control: bool, models_arg: str | None = None) -> list[str]:
    if models_arg:
        return parse_models(models_arg)
    models = list(PRIMARY_MODELS)
    if include_positive_control:
        models.extend(POSITIVE_CONTROL_MODELS)
    return models


def model_role(model_name: str) -> str:
    if model_name in PRIMARY_MODELS:
        return "primary"
    if model_name in POSITIVE_CONTROL_MODELS:
        return "positive_control"
    return "replacement_or_exploratory"


def deterministic_seed(model_name: str, condition: str, trial_idx: int) -> int:
    key = f"{model_name}:{condition}:{CONTEXT_LENGTH}:{trial_idx}"
    h = int(hashlib.md5(key.encode()).hexdigest()[:8], 16)
    return SEED_BASE + h % 100000


def expected_answer(target: dict[str, int]) -> int:
    return target["a"] + target["b"] + target["c"]


def target_key(target: dict[str, int]) -> str:
    return f"{target['a']}:{target['b']}:{target['c']}"


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
        "target_key": target_key(target),
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
        meta.update(_apply_conflict(rng, filler_sentences, target, SCOPED_TEMPLATES))
    elif condition == "subtle":
        filler_sentences = _generate_filler_block(rng, filler_budget)
        meta.update(_apply_conflict(rng, filler_sentences, target, SUBTLE_TEMPLATES))
    elif condition == "structural":
        filler_sentences = _generate_structural_block(rng, filler_budget, target)
    else:
        raise ValueError(f"Unknown condition: {condition}")

    prompt = definition_block + "\n".join(filler_sentences) + question
    meta["tokens_estimate"] = estimate_tokens(prompt)
    return prompt, expected, meta


def trials_path(model_name: str) -> Path:
    return EXP41_DIR / f"exp41_{safe_name(model_name)}_trials.jsonl"


def summary_path() -> Path:
    return EXP41_DIR / "exp41_summary.json"


def results_summary_path() -> Path:
    return EXP41_DIR / "exp41_results_summary.md"


def model_comparison_json_path() -> Path:
    return EXP41_DIR / "exp41_model_comparison.json"


def model_comparison_md_path() -> Path:
    return EXP41_DIR / "exp41_model_comparison.md"


def planned_conditions(include_diagnostic: bool) -> list[tuple[str, int]]:
    plan = [(condition, PRIMARY_TRIALS) for condition in PRIMARY_CONDITIONS]
    if include_diagnostic:
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


def estimate_cost_for_model(
    model_name: str,
    include_diagnostic: bool,
    completed: set[tuple[str, int]],
) -> tuple[int, float]:
    config = MODEL_CONFIGS[model_name]
    remaining_trials = 0
    for condition, n_trials in planned_conditions(include_diagnostic):
        for trial_idx in range(n_trials):
            if (condition, trial_idx) not in completed:
                remaining_trials += 1
    remaining_tokens = remaining_trials * CONTEXT_LENGTH
    cost = (
        remaining_tokens / 1_000_000 * config["cost_per_1m_input"]
        + remaining_trials * MAX_TOKENS / 1_000_000 * config["cost_per_1m_output"]
    )
    return remaining_trials, cost


def print_plan(models: list[str], include_diagnostic: bool) -> None:
    print("=" * 72)
    print("EXP.41 CROSS-MODEL WIDTH REPLICATION")
    print("=" * 72)
    print(f"Primary models: {PRIMARY_MODELS}")
    print(f"Positive control models: {POSITIVE_CONTROL_MODELS}")
    print(f"Selected models: {models}")
    print(f"Primary cells: {PRIMARY_CONDITIONS}")
    print(f"Diagnostic cells: {DIAGNOSTIC_CONDITIONS if include_diagnostic else 'not planned'}")
    print(f"Context: {CONTEXT_LENGTH//1000}K")
    print(f"Primary n/cell: {PRIMARY_TRIALS}")
    print(f"Diagnostic n/cell: {DIAGNOSTIC_TRIALS if include_diagnostic else 0}")
    print()
    total_remaining = 0
    total_cost = 0.0
    for model_name in models:
        completed = load_completed(model_name)
        remaining, cost = estimate_cost_for_model(model_name, include_diagnostic, completed)
        total_remaining += remaining
        total_cost += cost
        print(
            f"  {model_name:34s} role={model_role(model_name):22s} "
            f"remaining={remaining:3d} estimated_cost=${cost:.2f} "
            f"output={trials_path(model_name).name}"
        )
    print()
    print(f"Total remaining: {total_remaining} trials")
    print(f"Estimated total cost: ${total_cost:.2f}")
    print()
    print("Primary prediction:")
    print("  accuracy(scoped) > accuracy(structural) in both primary models")


def dry_run(models: list[str], include_diagnostic: bool) -> None:
    print_plan(models, include_diagnostic)
    print("\nDry-run prompt checks:")
    for model_name in models:
        print(f"\nModel: {model_name}")
        for condition, _ in planned_conditions(include_diagnostic):
            seed = deterministic_seed(model_name, condition, 0)
            rng = random.Random(seed)
            prompt, expected, meta = build_prompt(condition, 0, rng)
            extra = ""
            if meta["injected_var"] is not None:
                extra = f" injected={meta['injected_var']}:{meta['injected_wrong_val']}"
            print(
                f"  {condition:12s} tokens≈{meta['tokens_estimate']:,} "
                f"expected={expected} chars={len(prompt):,}{extra}"
            )
            if meta["injected_sentence"]:
                print(f"    sentence: {meta['injected_sentence']}")


def run(models: list[str], include_diagnostic: bool, execute: bool, resume: bool = True) -> None:
    if not execute:
        raise SystemExit("Refusing paid API calls without --execute. Use dry-run first.")

    print_plan(models, include_diagnostic)

    clients: dict[str, Any] = {}
    for model_name in models:
        config = MODEL_CONFIGS.get(model_name)
        if not config:
            raise SystemExit(f"Unknown model: {model_name}")
        if config["backend"] not in {"openai", "gemini"}:
            raise SystemExit(f"Unsupported backend for this runner: {config['backend']}")
        if config["backend"] not in clients:
            clients[config["backend"]] = create_client(config["backend"])

    for model_name in models:
        config = MODEL_CONFIGS[model_name]
        client = clients[config["backend"]]
        completed = load_completed(model_name) if resume else set()
        print(f"\nModel: {model_name} ({model_role(model_name)})")
        for condition, n_trials in planned_conditions(include_diagnostic):
            print(f"Cell: {condition} / {CONTEXT_LENGTH//1000}K")
            for trial_idx in range(n_trials):
                key = (condition, trial_idx)
                if key in completed:
                    continue

                seed = deterministic_seed(model_name, condition, trial_idx)
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
                    "model_role": model_role(model_name),
                    "condition": condition,
                    "context_length": CONTEXT_LENGTH,
                    "trial_idx": trial_idx,
                    "seed": seed,
                    "target": meta["target"],
                    "target_key": meta["target_key"],
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

    summarize(models)
    compare_models(models)


def load_records(model_name: str) -> list[dict[str, Any]]:
    path = trials_path(model_name)
    if not path.exists():
        return []
    with path.open() as f:
        return [json.loads(line) for line in f if line.strip()]


def finite_or_none(value: float) -> float | None:
    value = float(value)
    return value if math.isfinite(value) else None


def condition_summary(records: list[dict[str, Any]], condition: str) -> dict[str, Any]:
    cell = [r for r in records if r["condition"] == condition and r["result_type"] == "succeeded"]
    n = len(cell)
    correct = sum(1 for r in cell if r["is_correct"])
    errors = sum(1 for r in records if r["condition"] == condition and r["result_type"] == "errored")
    return {
        "correct": correct,
        "n": n,
        "errors": errors,
        "accuracy": correct / n if n else None,
    }


def fisher_greater(a: dict[str, Any], b: dict[str, Any]) -> dict[str, Any] | None:
    if not HAS_SCIPY_STATS or not a["n"] or not b["n"]:
        return None
    table = [
        [a["correct"], a["n"] - a["correct"]],
        [b["correct"], b["n"] - b["correct"]],
    ]
    odds_ratio, p_value = fisher_exact(table, alternative="greater")
    return {
        "alternative": "greater",
        "table": table,
        "odds_ratio": finite_or_none(odds_ratio),
        "p_value": finite_or_none(p_value),
    }


def summarize(models: list[str] | None = None) -> dict[str, Any]:
    if models is None:
        models = discover_models()

    by_model: dict[str, Any] = {}
    for model_name in models:
        records = load_records(model_name)
        conditions = PRIMARY_CONDITIONS + DIAGNOSTIC_CONDITIONS
        cells = {condition: condition_summary(records, condition) for condition in conditions}
        acc = {condition: cells[condition]["accuracy"] for condition in conditions}
        primary_supported = (
            acc.get("scoped") is not None
            and acc.get("structural") is not None
            and acc["scoped"] > acc["structural"]
        )
        secondary_order_supported = (
            acc.get("scoped") is not None
            and acc.get("subtle") is not None
            and acc.get("structural") is not None
            and acc["scoped"] >= acc["subtle"] >= acc["structural"]
        )
        zero_sanity_passed = None
        if acc.get("zero_sanity") is not None:
            zero_sanity_passed = acc["zero_sanity"] >= 0.80
        scoped_structural_margin = None
        if acc.get("scoped") is not None and acc.get("structural") is not None:
            scoped_structural_margin = acc["scoped"] - acc["structural"]

        by_model[model_name] = {
            "role": model_role(model_name),
            "conditions": cells,
            "primary_supported": primary_supported,
            "secondary_order_supported": secondary_order_supported,
            "scoped_structural_margin": scoped_structural_margin,
            "zero_sanity_passed": zero_sanity_passed,
            "fisher_scoped_vs_structural": fisher_greater(cells["scoped"], cells["structural"]),
        }

    primary_models_with_data = [
        model for model in PRIMARY_MODELS if model in by_model and by_model[model]["conditions"]["scoped"]["n"]
    ]
    primary_support_count = sum(1 for model in primary_models_with_data if by_model[model]["primary_supported"])
    primary_width_supported = (
        len(primary_models_with_data) == len(PRIMARY_MODELS)
        and primary_support_count == len(PRIMARY_MODELS)
    )
    sign_test_p_one_sided = None
    if primary_models_with_data:
        n = len(primary_models_with_data)
        k = primary_support_count
        sign_test_p_one_sided = sum(math.comb(n, j) for j in range(k, n + 1)) / (2**n)

    summary = {
        "experiment": EXPERIMENT_ID,
        "version": EXPERIMENT_VERSION,
        "primary_models": PRIMARY_MODELS,
        "positive_control_models": POSITIVE_CONTROL_MODELS,
        "models_analyzed": models,
        "by_model": by_model,
        "primary_models_with_data": primary_models_with_data,
        "primary_support_count": primary_support_count,
        "primary_width_supported": primary_width_supported,
        "sign_test_p_one_sided": sign_test_p_one_sided,
        "positive_control_reported_separately": True,
        "generated_at": datetime.now().isoformat(),
    }
    summary_path().write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_results_markdown(summary)
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return summary


def discover_models() -> list[str]:
    models = []
    for path in sorted(EXP41_DIR.glob("exp41_*_trials.jsonl")):
        safe = path.name.removeprefix("exp41_").removesuffix("_trials.jsonl")
        for model_name in list(MODEL_CONFIGS):
            if safe_name(model_name) == safe:
                models.append(model_name)
                break
    return models


def write_results_markdown(summary: dict[str, Any]) -> None:
    lines = [
        "# Exp.41 Results Summary",
        "",
        f"Generated: {summary['generated_at']}",
        "",
        "| Model | Role | scoped | subtle | structural | zero_sanity | Primary scoped>structural | Secondary order | Margin | Fisher p |",
        "|---|---|---:|---:|---:|---:|---|---|---:|---:|",
    ]
    for model_name, info in summary["by_model"].items():
        cells = info["conditions"]

        def fmt(condition: str) -> str:
            cell = cells[condition]
            acc = cell["accuracy"]
            if acc is None:
                return "NA"
            return f"{cell['correct']}/{cell['n']} = {acc:.2f}"

        fisher = info["fisher_scoped_vs_structural"]
        fisher_p = "NA" if fisher is None else f"{fisher['p_value']:.3g}"
        margin = info["scoped_structural_margin"]
        margin_text = "NA" if margin is None else f"{margin:.2f}"
        lines.append(
            f"| `{model_name}` | {info['role']} | {fmt('scoped')} | {fmt('subtle')} "
            f"| {fmt('structural')} | {fmt('zero_sanity')} | `{info['primary_supported']}` "
            f"| `{info['secondary_order_supported']}` | {margin_text} | {fisher_p} |"
        )

    lines.extend(
        [
            "",
            f"Primary models with data: `{summary['primary_models_with_data']}`",
            f"Primary support count: `{summary['primary_support_count']}`",
            f"Primary width supported: `{summary['primary_width_supported']}`",
            f"One-sided sign-test p-value: `{summary['sign_test_p_one_sided']}`",
            "",
            "The positive-control model, if present, is reported separately and does not rescue the primary width decision.",
            "",
        ]
    )
    results_summary_path().write_text("\n".join(lines), encoding="utf-8")


@dataclass(frozen=True)
class Row:
    model: str
    condition: str
    target_key: str
    is_correct: bool


FeatureFn = Callable[[Row], list[float]]


FEATURE_SETS: dict[str, FeatureFn] = {
    "quality_blind": lambda r: [1.0],
    "structure_aware_ordered": lambda r: [
        1.0,
        {"scoped": 0.0, "subtle": 1.0, "structural": 2.0}[r.condition],
    ],
    "structure_aware_categorical": lambda r: [
        1.0,
        1.0 if r.condition == "subtle" else 0.0,
        1.0 if r.condition == "structural" else 0.0,
    ],
}


def load_rows_for_comparison(models: list[str]) -> list[Row]:
    rows: list[Row] = []
    for model_name in models:
        for rec in load_records(model_name):
            if rec["result_type"] != "succeeded":
                continue
            if rec["condition"] not in PRIMARY_CONDITIONS:
                continue
            rows.append(
                Row(
                    model=model_name,
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


def leave_one_model_target_out(rows: list[Row]) -> dict[str, dict]:
    result: dict[str, dict] = {}
    folds_keys = sorted({(row.model, row.target_key) for row in rows})
    for feature_name, feature_fn in FEATURE_SETS.items():
        folds = []
        for model_name, heldout_target in folds_keys:
            train = [row for row in rows if (row.model, row.target_key) != (model_name, heldout_target)]
            test = [row for row in rows if (row.model, row.target_key) == (model_name, heldout_target)]
            if not train or not test:
                continue
            x_train, y_train = matrix(train, feature_fn)
            beta = fit_logistic(x_train, y_train)
            folds.append(
                {
                    "heldout_model": model_name,
                    "heldout_target": heldout_target,
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


def compare_models(models: list[str] | None = None) -> dict[str, Any]:
    if models is None:
        models = discover_models()
    rows = load_rows_for_comparison(models)
    if not rows:
        raise SystemExit("No primary Exp.41 rows found for model comparison.")
    results = {
        "experiment": EXPERIMENT_ID,
        "version": EXPERIMENT_VERSION,
        "models": models,
        "n": len(rows),
        "leave_one_model_target_out": leave_one_model_target_out(rows),
        "generated_at": datetime.now().isoformat(),
    }
    model_comparison_json_path().write_text(
        json.dumps(results, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_model_comparison_markdown(results)
    print(json.dumps(
        {
            "models": models,
            "n": len(rows),
            "model_comparison": str(model_comparison_md_path()),
        },
        ensure_ascii=False,
        indent=2,
    ))
    return results


def write_model_comparison_markdown(results: dict[str, Any]) -> None:
    lines = [
        "# Exp.41 Model Comparison",
        "",
        f"Models: `{results['models']}`",
        "",
        "Descriptive leave-one-(model,target)-out comparison over primary conditions only.",
        "",
        "| Model | Log loss | Brier | Accuracy at 0.5 |",
        "|---|---:|---:|---:|",
    ]
    comparison = results["leave_one_model_target_out"]
    for name, values in sorted(comparison.items(), key=lambda item: item[1]["weighted_log_loss"]):
        lines.append(
            f"| `{name}` | {values['weighted_log_loss']:.4f} | "
            f"{values['weighted_brier']:.4f} | {values['weighted_accuracy_at_0_5']:.4f} |"
        )
    lines.extend(
        [
            "",
            "Expected descriptive direction: structure-aware models beat `quality_blind`.",
            "",
        ]
    )
    model_comparison_md_path().write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--models",
        default=None,
        help="Comma-separated override. Defaults to primary models, plus positive control if requested.",
    )
    parser.add_argument("--include-positive-control", action="store_true")
    parser.add_argument("--include-diagnostic", action="store_true")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("dry-run")

    run_p = sub.add_parser("run")
    run_p.add_argument("--execute", action="store_true")
    run_p.add_argument("--no-resume", action="store_true")

    sub.add_parser("summarize")
    sub.add_parser("compare")

    args = parser.parse_args()
    models = selected_models(args.include_positive_control, args.models)

    if args.cmd == "dry-run":
        dry_run(models, args.include_diagnostic)
    elif args.cmd == "run":
        run(models, args.include_diagnostic, execute=args.execute, resume=not args.no_resume)
    elif args.cmd == "summarize":
        summarize(models)
    elif args.cmd == "compare":
        compare_models(models)


if __name__ == "__main__":
    main()
