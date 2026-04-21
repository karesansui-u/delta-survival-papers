#!/usr/bin/env python3
"""Analyze Exp.40 results, including the preregistered baseline comparison."""

from __future__ import annotations

import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

import numpy as np
from scipy.optimize import minimize


EXP40_DIR = Path(__file__).resolve().parent
DEFAULT_MODEL = "gpt-4.1-mini"
PRIMARY_CONDITIONS = {"scoped", "subtle", "structural"}


@dataclass(frozen=True)
class Row:
    condition: str
    target_key: str
    is_correct: bool


FeatureFn = Callable[[Row], list[float]]


FEATURE_SETS: dict[str, FeatureFn] = {
    "quality_blind": lambda r: [
        1.0,
        0.0 if r.condition == "zero_sanity" else 1.0,
    ],
    "structure_aware": lambda r: [
        1.0,
        1.0 if r.condition == "subtle" else 0.0,
        1.0 if r.condition == "structural" else 0.0,
    ],
}


def safe_name(model_name: str) -> str:
    return model_name.replace(":", "_").replace("/", "_").replace(".", "_")


def trials_path(model_name: str) -> Path:
    return EXP40_DIR / f"exp40_{safe_name(model_name)}_trials.jsonl"


def output_json_path(model_name: str) -> Path:
    return EXP40_DIR / f"exp40_{safe_name(model_name)}_model_comparison.json"


def output_md_path(model_name: str) -> Path:
    return EXP40_DIR / f"exp40_{safe_name(model_name)}_model_comparison.md"


def load_rows(model_name: str) -> list[Row]:
    rows: list[Row] = []
    with trials_path(model_name).open() as f:
        for line in f:
            if not line.strip():
                continue
            rec = json.loads(line)
            if rec["result_type"] != "succeeded":
                continue
            target = rec["target"]
            target_key = f"{target['a']}:{target['b']}:{target['c']}"
            rows.append(
                Row(
                    condition=rec["condition"],
                    target_key=target_key,
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
    primary_mask = np.asarray([row.condition in PRIMARY_CONDITIONS for row in rows])

    def compute(mask: np.ndarray) -> dict[str, float]:
        yy = y[mask]
        pp = p[mask]
        return {
            "n": int(len(yy)),
            "log_loss": float(-np.mean(yy * np.log(pp) + (1 - yy) * np.log(1 - pp))),
            "brier": float(np.mean((pp - yy) ** 2)),
            "accuracy_at_0_5": float(np.mean((pp >= 0.5) == yy)),
        }

    return {
        "all": compute(np.ones_like(y, dtype=bool)),
        "primary": compute(primary_mask),
    }


def weighted_mean(folds: list[dict], scope: str, metric: str) -> float:
    total_n = sum(fold["metrics"][scope]["n"] for fold in folds)
    return (
        sum(fold["metrics"][scope][metric] * fold["metrics"][scope]["n"] for fold in folds)
        / total_n
    )


def leave_one_target_out(rows: list[Row]) -> dict:
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
            "weighted_all_log_loss": weighted_mean(folds, "all", "log_loss"),
            "weighted_primary_log_loss": weighted_mean(folds, "primary", "log_loss"),
            "weighted_all_brier": weighted_mean(folds, "all", "brier"),
            "weighted_primary_brier": weighted_mean(folds, "primary", "brier"),
        }
    return result


def write_markdown(model_name: str, results: dict) -> None:
    lines: list[str] = []
    lines.append("# Exp.40 Model Comparison")
    lines.append("")
    lines.append(f"Model: `{model_name}`")
    lines.append("")
    lines.append("Leave-one-target-out comparison. The primary scope is `scoped`, `subtle`, and `structural`; `zero_sanity` is used for training/calibration but is not part of the primary baseline comparison.")
    lines.append("")
    lines.append("| Model | Primary log loss | Primary Brier | All log loss | All Brier |")
    lines.append("|---|---:|---:|---:|---:|")
    for name, values in sorted(results.items(), key=lambda item: item[1]["weighted_primary_log_loss"]):
        lines.append(
            f"| `{name}` | {values['weighted_primary_log_loss']:.4f} | "
            f"{values['weighted_primary_brier']:.4f} | "
            f"{values['weighted_all_log_loss']:.4f} | {values['weighted_all_brier']:.4f} |"
        )
    lines.append("")
    lines.append("The structure-aware coding treats `scoped` as repaired / zero-like, while the quality-blind baseline treats `scoped`, `subtle`, and `structural` as contradiction-present.")
    lines.append("")
    output_md_path(model_name).write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    model_name = DEFAULT_MODEL
    rows = load_rows(model_name)
    if not rows:
        raise SystemExit("No Exp.40 rows found.")
    results = {
        "model": model_name,
        "n": len(rows),
        "leave_one_target_out": leave_one_target_out(rows),
    }
    output_json_path(model_name).write_text(
        json.dumps(results, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_markdown(model_name, results["leave_one_target_out"])
    print(json.dumps({
        "model": model_name,
        "n": len(rows),
        "summary": str(output_md_path(model_name)),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
