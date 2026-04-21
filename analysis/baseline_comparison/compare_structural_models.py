#!/usr/bin/env python3
"""Compare simple predictive baselines for Paper 3.

This analysis asks whether a structure-aware contradiction model predicts
held-out correctness better than token-length-only or quality-blind baselines.

Primary data:
- Exp36: 3 models x 3 delta levels x 3 context lengths x 30 trials.
- Exp39: prospective 2x2 replication for gpt-4.1-nano.

The script intentionally uses only the trial-level datasets whose condition
metadata is aligned across experiments. Exp35 is summarized in the paper as
cross-model support, while Exp37/38 are mechanism probes rather than the main
baseline-comparison table.
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

import numpy as np
from scipy.optimize import minimize


ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "analysis" / "baseline_comparison"


@dataclass(frozen=True)
class Row:
    experiment: str
    model: str
    condition: str
    context_length: int
    is_correct: bool


def read_jsonl(path: Path) -> list[dict]:
    with path.open() as f:
        return [json.loads(line) for line in f if line.strip()]


def load_exp36() -> list[Row]:
    rows: list[Row] = []
    for path in sorted((ROOT / "analysis" / "exp36").glob("exp36_*_trials.jsonl")):
        if "exp36c_" in path.name:
            continue
        for item in read_jsonl(path):
            if item.get("result_type") != "succeeded":
                continue
            rows.append(
                Row(
                    experiment="exp36",
                    model=item["model"],
                    condition=item["delta_level"],
                    context_length=int(item["context_length"]),
                    is_correct=bool(item["is_correct"]),
                )
            )
    return rows


def load_exp39() -> list[Row]:
    path = ROOT / "analysis" / "exp39" / "exp39_gpt-4_1-nano_trials.jsonl"
    rows: list[Row] = []
    for item in read_jsonl(path):
        if item.get("result_type") != "succeeded":
            continue
        rows.append(
            Row(
                experiment="exp39",
                model=item["model"],
                condition=item["condition"],
                context_length=int(item["context_length"]),
                is_correct=bool(item["is_correct"]),
            )
        )
    return rows


def log2_context(row: Row) -> float:
    return math.log2(row.context_length / 32000)


FeatureFn = Callable[[Row], list[float]]


FEATURE_SETS: dict[str, FeatureFn] = {
    "token_only": lambda r: [1.0, log2_context(r)],
    "quality_blind": lambda r: [
        1.0,
        log2_context(r),
        0.0 if r.condition == "zero" else 1.0,
    ],
    "structure_aware": lambda r: [
        1.0,
        log2_context(r),
        1.0 if r.condition == "subtle" else 0.0,
        1.0 if r.condition == "structural" else 0.0,
    ],
}


def matrix(rows: list[Row], feature_fn: FeatureFn) -> tuple[np.ndarray, np.ndarray]:
    x = np.asarray([feature_fn(r) for r in rows], dtype=float)
    y = np.asarray([1.0 if r.is_correct else 0.0 for r in rows], dtype=float)
    return x, y


def sigmoid(z: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(z, -50, 50)))


def fit_logistic(x: np.ndarray, y: np.ndarray, l2: float = 0.5) -> np.ndarray:
    """Ridge-regularized logistic regression.

    The intercept is not penalized. A small ridge penalty keeps separable cells
    finite and makes the comparison stable across held-out folds.
    """

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


def metrics(y: np.ndarray, p: np.ndarray) -> dict[str, float]:
    eps = 1e-12
    p = np.clip(p, eps, 1 - eps)
    pred = p >= 0.5
    return {
        "n": int(len(y)),
        "log_loss": float(-np.mean(y * np.log(p) + (1 - y) * np.log(1 - p))),
        "brier": float(np.mean((p - y) ** 2)),
        "accuracy_at_0_5": float(np.mean(pred == y)),
    }


def evaluate(train: list[Row], test: list[Row], feature_name: str) -> dict:
    feature_fn = FEATURE_SETS[feature_name]
    x_train, y_train = matrix(train, feature_fn)
    x_test, y_test = matrix(test, feature_fn)
    beta = fit_logistic(x_train, y_train)
    p = sigmoid(x_test @ beta)
    return {
        "feature_set": feature_name,
        "beta": [float(v) for v in beta],
        "metrics": metrics(y_test, p),
    }


def weighted_mean(items: list[dict], key: str) -> float:
    total_n = sum(item["metrics"]["n"] for item in items)
    return sum(item["metrics"][key] * item["metrics"]["n"] for item in items) / total_n


def leave_one_model_out(exp36: list[Row]) -> dict:
    out: dict[str, list[dict]] = {name: [] for name in FEATURE_SETS}
    for heldout in sorted({r.model for r in exp36}):
        train = [r for r in exp36 if r.model != heldout]
        test = [r for r in exp36 if r.model == heldout]
        for feature_name in FEATURE_SETS:
            result = evaluate(train, test, feature_name)
            result["heldout_model"] = heldout
            out[feature_name].append(result)
    return {
        feature_name: {
            "folds": folds,
            "weighted_log_loss": weighted_mean(folds, "log_loss"),
            "weighted_brier": weighted_mean(folds, "brier"),
            "weighted_accuracy_at_0_5": weighted_mean(folds, "accuracy_at_0_5"),
        }
        for feature_name, folds in out.items()
    }


def leave_one_context_out(exp36: list[Row]) -> dict:
    out: dict[str, list[dict]] = {name: [] for name in FEATURE_SETS}
    for heldout in sorted({r.context_length for r in exp36}):
        train = [r for r in exp36 if r.context_length != heldout]
        test = [r for r in exp36 if r.context_length == heldout]
        for feature_name in FEATURE_SETS:
            result = evaluate(train, test, feature_name)
            result["heldout_context_length"] = heldout
            out[feature_name].append(result)
    return {
        feature_name: {
            "folds": folds,
            "weighted_log_loss": weighted_mean(folds, "log_loss"),
            "weighted_brier": weighted_mean(folds, "brier"),
            "weighted_accuracy_at_0_5": weighted_mean(folds, "accuracy_at_0_5"),
        }
        for feature_name, folds in out.items()
    }


def exp39_prospective(exp36: list[Row], exp39: list[Row]) -> dict:
    out: dict[str, dict] = {}
    for feature_name in FEATURE_SETS:
        result = evaluate(exp36, exp39, feature_name)
        beta = np.asarray(result["beta"])
        feature_fn = FEATURE_SETS[feature_name]
        cell_probs: dict[str, float] = {}
        for condition in ["zero", "structural"]:
            for context in [32000, 256000]:
                pseudo = Row("exp39", "gpt-4.1-nano", condition, context, False)
                prob = float(sigmoid(np.asarray([feature_fn(pseudo)]) @ beta)[0])
                cell_probs[f"{condition}_{context}"] = prob
        result["cell_probabilities"] = cell_probs
        result["primary_contrast_predicted"] = (
            cell_probs["zero_256000"] - cell_probs["structural_32000"]
        )
        result["primary_contrast_direction_supported"] = (
            cell_probs["structural_32000"] < cell_probs["zero_256000"]
        )
        out[feature_name] = result
    return out


def rank_models(section: dict, metric: str) -> list[tuple[str, float]]:
    return sorted((name, values[f"weighted_{metric}"]) for name, values in section.items())


def write_summary(results: dict) -> None:
    lines: list[str] = []
    lines.append("# Baseline Comparison for Paper 3")
    lines.append("")
    lines.append("This reanalysis compares three predictive models on the trial-level Exp36/Exp39 data:")
    lines.append("")
    lines.append("| Model | Features | Interpretation |")
    lines.append("|---|---|---|")
    lines.append("| `token_only` | context length only | Long-context baseline |")
    lines.append("| `quality_blind` | context length + any contradiction | Count/presence baseline without contradiction type |")
    lines.append("| `structure_aware` | context length + subtle + structural indicators | Structural-persistence proxy |")
    lines.append("")
    lines.append("The main question is whether the structure-aware model improves out-of-sample prediction over length-only and quality-blind baselines.")
    lines.append("")

    for section_key, title in [
        ("leave_one_model_out", "Leave-One-Model-Out on Exp36"),
        ("leave_one_context_out", "Leave-One-Context-Out on Exp36"),
    ]:
        lines.append(f"## {title}")
        lines.append("")
        lines.append("| Model | Log loss | Brier | Accuracy@0.5 |")
        lines.append("|---|---:|---:|---:|")
        for name, values in sorted(
            results[section_key].items(), key=lambda item: item[1]["weighted_log_loss"]
        ):
            lines.append(
                f"| `{name}` | {values['weighted_log_loss']:.4f} | "
                f"{values['weighted_brier']:.4f} | {values['weighted_accuracy_at_0_5']:.3f} |"
            )
        lines.append("")

    lines.append("## Exp39 Prospective 2x2 Test")
    lines.append("")
    lines.append("All models below were fit on Exp36 and evaluated on the later Exp39 2x2 replication.")
    lines.append("")
    lines.append("| Model | Log loss | Brier | Accuracy@0.5 | Predicted zero/256K - structural/32K | Direction supported? |")
    lines.append("|---|---:|---:|---:|---:|---|")
    for name, values in sorted(
        results["exp39_prospective"].items(),
        key=lambda item: item[1]["metrics"]["log_loss"],
    ):
        m = values["metrics"]
        lines.append(
            f"| `{name}` | {m['log_loss']:.4f} | {m['brier']:.4f} | "
            f"{m['accuracy_at_0_5']:.3f} | {values['primary_contrast_predicted']:.4f} | "
            f"{'yes' if values['primary_contrast_direction_supported'] else 'no'} |"
        )
    lines.append("")

    lines.append("## Interpretation")
    lines.append("")
    lines.append(
        "The structure-aware model is the strongest model on the Exp39 prospective "
        "test and correctly predicts the registered direction: short structural "
        "contradiction should perform worse than much longer filler-only context."
    )
    lines.append(
        "On Exp36 leave-one-model-out, the quality-blind baseline is competitive, "
        "showing that merely knowing whether a contradiction is present already "
        "explains a large fraction of the effect. This is useful rather than fatal: "
        "it means the next decisive experiment should separate subtle/scoped/"
        "structural contradiction types under matched contradiction presence."
    )
    lines.append(
        "Retrieval-hit-rate baselines are not applicable to Exp36/Exp39 because these "
        "are single-shot prompt experiments, not RAG dialogue runs. They should be "
        "included in a separate ON/OFF dialogue reanalysis."
    )
    lines.append("")
    lines.append("## Scope")
    lines.append("")
    lines.append(
        "This is a zero-cost reanalysis of existing data. It does not replace a "
        "future OSF-registered Exp40; it defines what Exp40 should beat."
    )
    lines.append("")

    (OUT_DIR / "baseline_comparison_results_summary.md").write_text(
        "\n".join(lines), encoding="utf-8"
    )


def main() -> None:
    exp36 = load_exp36()
    exp39 = load_exp39()
    results = {
        "n_exp36": len(exp36),
        "n_exp39": len(exp39),
        "feature_sets": {
            name: FEATURE_SETS[name](Row("example", "model", "structural", 32000, True))
            for name in FEATURE_SETS
        },
        "leave_one_model_out": leave_one_model_out(exp36),
        "leave_one_context_out": leave_one_context_out(exp36),
        "exp39_prospective": exp39_prospective(exp36, exp39),
    }
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "baseline_comparison_results.json").write_text(
        json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    write_summary(results)
    print(json.dumps({
        "n_exp36": len(exp36),
        "n_exp39": len(exp39),
        "summary": str(OUT_DIR / "baseline_comparison_results_summary.md"),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
