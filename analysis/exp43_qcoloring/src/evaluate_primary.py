#!/usr/bin/env python3
"""Frozen Exp43c primary analysis script.

This script evaluates preregistered logistic-regression predictors with
leave-one-q-out cross-validation. It must be hashed in the freeze package
before primary data generation.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, brier_score_loss, log_loss, roc_auc_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

L2_C = 1.0
MAX_ITER = 1000

PREDICTORS: dict[str, list[str]] = {
    "raw_edge": ["m"],
    "raw_density": ["edge_density"],
    "avg_degree": ["avg_degree"],
    "raw_plus_n_q": ["m", "n", "q"],
    "density_plus_n_q": ["edge_density", "n", "q"],
    "avg_degree_plus_n_q": ["avg_degree", "n", "q"],
    "cnf_count_plus_n_q": ["cnf_clause_count", "n", "q"],
    "L_plus_n": ["L", "n"],
    "L_plus_n_plus_q": ["L", "n", "q"],
    "fm_plus_n": ["first_moment_log_count", "n"],
    "first_moment": ["first_moment_log_count"],
}


def load_records(path: Path) -> list[dict[str, Any]]:
    records = []
    with path.open(encoding="utf-8") as f:
        for line in f:
            if line.strip():
                records.append(json.loads(line))
    return records


def solved_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [rec for rec in records if rec.get("q_colorable") is not None]


def feature_matrix(records: list[dict[str, Any]], feature_names: list[str]) -> np.ndarray:
    return np.asarray([[float(rec[name]) for name in feature_names] for rec in records], dtype=float)


def labels(records: list[dict[str, Any]]) -> np.ndarray:
    return np.asarray([1 if rec["q_colorable"] is True else 0 for rec in records], dtype=int)


def evaluate_predictor(records: list[dict[str, Any]], predictor: str, feature_names: list[str]) -> dict[str, Any]:
    q_values = sorted({int(rec["q"]) for rec in records})
    fold_results = []
    all_y: list[int] = []
    all_p: list[float] = []

    for heldout_q in q_values:
        train = [rec for rec in records if int(rec["q"]) != heldout_q]
        test = [rec for rec in records if int(rec["q"]) == heldout_q]
        x_train = feature_matrix(train, feature_names)
        y_train = labels(train)
        x_test = feature_matrix(test, feature_names)
        y_test = labels(test)

        model = make_pipeline(
            StandardScaler(),
            LogisticRegression(C=L2_C, penalty="l2", solver="lbfgs", max_iter=MAX_ITER),
        )
        model.fit(x_train, y_train)
        p = model.predict_proba(x_test)[:, 1]
        pred = (p >= 0.5).astype(int)
        fold = {
            "heldout_q": heldout_q,
            "n_test": int(len(test)),
            "log_loss": float(log_loss(y_test, p, labels=[0, 1])),
            "brier": float(brier_score_loss(y_test, p)),
            "accuracy_at_0_5": float(accuracy_score(y_test, pred)),
            "auroc": None,
        }
        if len(set(y_test.tolist())) == 2:
            fold["auroc"] = float(roc_auc_score(y_test, p))
        fold_results.append(fold)
        all_y.extend(y_test.tolist())
        all_p.extend(p.tolist())

    return {
        "predictor": predictor,
        "features": feature_names,
        "folds": fold_results,
        "mean_heldout_log_loss": float(np.mean([fold["log_loss"] for fold in fold_results])),
        "mean_heldout_brier": float(np.mean([fold["brier"] for fold in fold_results])),
        "pooled_log_loss": float(log_loss(np.asarray(all_y), np.asarray(all_p), labels=[0, 1])),
    }


def summarize_timeouts(records: list[dict[str, Any]]) -> dict[str, Any]:
    cells: dict[tuple[int, int, float], dict[str, int]] = {}
    for rec in records:
        key = (int(rec["q"]), int(rec["n"]), float(rec["rho_fm"]))
        cell = cells.setdefault(key, {"total": 0, "timeout": 0, "malformed": 0})
        cell["total"] += 1
        cell["timeout"] += int(rec.get("status") == "TIMEOUT" or rec.get("timeout") is True)
        cell["malformed"] += int(rec.get("status") == "MALFORMED_ENCODING")
    return {
        "cells": [
            {
                "q": q,
                "n": n,
                "rho_fm": rho,
                "total": counts["total"],
                "timeout_count": counts["timeout"],
                "timeout_rate": counts["timeout"] / counts["total"] if counts["total"] else 0.0,
                "malformed_count": counts["malformed"],
            }
            for (q, n, rho), counts in sorted(cells.items())
        ]
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jsonl", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    records = load_records(args.jsonl)
    solved = solved_records(records)
    results = {
        "script": "analysis/exp43_qcoloring/src/evaluate_primary.py",
        "l2_C": L2_C,
        "max_iter": MAX_ITER,
        "total_records": len(records),
        "solved_records": len(solved),
        "timeout_summary": summarize_timeouts(records),
        "predictors": [
            evaluate_predictor(solved, predictor, features)
            for predictor, features in PREDICTORS.items()
        ],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(results, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {args.output}")


if __name__ == "__main__":
    main()
