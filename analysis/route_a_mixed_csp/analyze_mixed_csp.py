#!/usr/bin/env python3
"""Analyze Mixed-CSP Route A feasibility results."""

from __future__ import annotations

import argparse
import json
import math
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Callable

import numpy as np
from scipy.optimize import minimize

HERE = Path(__file__).resolve().parent
TRIALS_PATH = HERE / "mixed_csp_trials.jsonl"
RESULTS_JSON = HERE / "mixed_csp_results.json"
RESULTS_MD = HERE / "mixed_csp_results_summary.md"
SMOKE_JSON = HERE / "mixed_csp_smoke_summary.json"
SMOKE_MD = HERE / "mixed_csp_smoke_summary.md"
EXACT_ONE_PILOT_MD = HERE / "exact_one_pilot_summary.md"

PRIMARY_MODELS: dict[str, list[str]] = {
    "raw_count": ["raw_count"],
    "raw_density": ["raw_density"],
    "L_only": ["L"],
    "first_moment": ["first_moment_log_count"],
    "L_plus_n": ["L", "n"],
    "raw_plus_n": ["raw_count", "n"],
    "cnf_count_plus_n": ["cnf_clause_count", "n"],
}


@dataclass(frozen=True)
class Row:
    instance_id: str
    phase: str
    n: int
    density: float
    mixture_id: str
    cell_id: str
    sat_feasible: bool | None
    timeout: bool
    status: str
    predictors: dict[str, float]
    cnf_clause_count: int
    semantic_raw_count: int
    counts: dict[str, int]


def load_rows(path: Path) -> list[Row]:
    rows: list[Row] = []
    if not path.exists():
        return rows
    with path.open() as f:
        for line in f:
            if not line.strip():
                continue
            rec = json.loads(line)
            predictors = dict(rec["predictors"])
            predictors.setdefault("n", rec["n"])
            predictors.setdefault("raw_count", rec["semantic_raw_count"])
            predictors.setdefault("raw_density", rec["density"])
            predictors.setdefault("cnf_clause_count", rec["cnf_clause_count"])
            cell_id = f"{rec['phase']}|n={rec['n']}|d={rec['density']}|{rec['mixture_id']}"
            rows.append(
                Row(
                    instance_id=rec["instance_id"],
                    phase=rec["phase"],
                    n=int(rec["n"]),
                    density=float(rec["density"]),
                    mixture_id=rec["mixture_id"],
                    cell_id=cell_id,
                    sat_feasible=rec.get("sat_feasible"),
                    timeout=bool(rec.get("timeout")),
                    status=rec.get("status", "unknown"),
                    predictors={k: float(v) for k, v in predictors.items()},
                    cnf_clause_count=int(rec["cnf_clause_count"]),
                    semantic_raw_count=int(rec["semantic_raw_count"]),
                    counts={k: int(v) for k, v in rec["counts"].items()},
                )
            )
    return rows


def eligible_primary_rows(rows: list[Row]) -> list[Row]:
    return [
        row
        for row in rows
        if row.phase == "primary"
        and row.status == "succeeded"
        and row.sat_feasible is not None
        and not row.timeout
    ]


def sigmoid(z: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(z, -50, 50)))


def design_matrix(
    rows: list[Row],
    columns: list[str],
    scaling: dict[str, tuple[float, float]] | None = None,
) -> tuple[np.ndarray, dict[str, tuple[float, float]]]:
    if scaling is None:
        scaling = {}
        for col in columns:
            values = np.asarray([row.predictors[col] for row in rows], dtype=float)
            mean = float(np.mean(values))
            sd = float(np.std(values))
            if sd == 0.0:
                sd = 1.0
            scaling[col] = (mean, sd)
    x = np.ones((len(rows), 1 + len(columns)), dtype=float)
    for idx, col in enumerate(columns, start=1):
        mean, sd = scaling[col]
        x[:, idx] = [(row.predictors[col] - mean) / sd for row in rows]
    return x, scaling


def labels(rows: list[Row]) -> np.ndarray:
    return np.asarray([1.0 if row.sat_feasible else 0.0 for row in rows], dtype=float)


def fit_logistic(x: np.ndarray, y: np.ndarray, l2: float = 0.5) -> np.ndarray:
    def objective(beta: np.ndarray) -> tuple[float, np.ndarray]:
        p = sigmoid(x @ beta)
        eps = 1e-12
        nll = -np.sum(y * np.log(p + eps) + (1 - y) * np.log(1 - p + eps))
        penalty = 0.5 * l2 * float(np.sum(beta[1:] ** 2))
        grad = x.T @ (p - y)
        grad[1:] += l2 * beta[1:]
        return nll + penalty, grad

    result = minimize(
        lambda b: objective(b)[0],
        np.zeros(x.shape[1], dtype=float),
        jac=lambda b: objective(b)[1],
        method="L-BFGS-B",
        options={"gtol": 1e-8, "maxiter": 1000, "ftol": 1e-12},
    )
    if not result.success:
        raise RuntimeError(f"logistic fit failed: {result.message}")
    return result.x


def metrics(rows: list[Row], beta: np.ndarray, columns: list[str], scaling: dict[str, tuple[float, float]]) -> dict:
    x, _ = design_matrix(rows, columns, scaling)
    y = labels(rows)
    p = np.clip(sigmoid(x @ beta), 1e-12, 1 - 1e-12)
    return {
        "n": len(rows),
        "log_loss": float(-np.mean(y * np.log(p) + (1 - y) * np.log(1 - p))),
        "brier": float(np.mean((p - y) ** 2)),
        "accuracy_at_0_5": float(np.mean((p >= 0.5) == y)),
    }


def leave_one_mixture_out(rows: list[Row]) -> dict[str, dict]:
    mixtures = sorted({row.mixture_id for row in rows})
    results: dict[str, dict] = {}
    for model_name, columns in PRIMARY_MODELS.items():
        folds = []
        for mixture_id in mixtures:
            train = [row for row in rows if row.mixture_id != mixture_id]
            test = [row for row in rows if row.mixture_id == mixture_id]
            if not train or not test:
                continue
            x_train, scaling = design_matrix(train, columns)
            y_train = labels(train)
            beta = fit_logistic(x_train, y_train)
            folds.append(
                {
                    "heldout_mixture": mixture_id,
                    "columns": columns,
                    "scaling": scaling,
                    "beta": [float(v) for v in beta],
                    "metrics": metrics(test, beta, columns, scaling),
                }
            )
        total_n = sum(fold["metrics"]["n"] for fold in folds)
        results[model_name] = {
            "columns": columns,
            "folds": folds,
            "weighted_log_loss": weighted_mean(folds, "log_loss", total_n),
            "weighted_brier": weighted_mean(folds, "brier", total_n),
            "weighted_accuracy_at_0_5": weighted_mean(folds, "accuracy_at_0_5", total_n),
        }
    return results


def weighted_mean(folds: list[dict], metric: str, total_n: int) -> float | None:
    if total_n == 0:
        return None
    return sum(fold["metrics"][metric] * fold["metrics"]["n"] for fold in folds) / total_n


def cell_diagnostics(rows: list[Row]) -> list[dict]:
    by_cell: dict[str, list[Row]] = defaultdict(list)
    for row in rows:
        by_cell[row.cell_id].append(row)
    out = []
    for cell_id, cell in sorted(by_cell.items()):
        succeeded = [row for row in cell if row.status == "succeeded" and row.sat_feasible is not None]
        sat = sum(1 for row in succeeded if row.sat_feasible)
        timeouts = sum(1 for row in cell if row.timeout)
        cnf_ratios = [row.cnf_clause_count / row.semantic_raw_count for row in cell]
        out.append(
            {
                "cell_id": cell_id,
                "n": len(cell),
                "valid_n": len(succeeded),
                "sat_count": sat,
                "sat_rate": sat / len(succeeded) if succeeded else None,
                "timeout_count": timeouts,
                "timeout_rate": timeouts / len(cell) if cell else None,
                "flag_timeout_gt_0_05": (timeouts / len(cell) > 0.05) if cell else None,
                "median_cnf_ratio": float(np.median(cnf_ratios)) if cnf_ratios else None,
            }
        )
    return out


def support_flags(model_results: dict[str, dict]) -> dict[str, bool | float | None]:
    lp = model_results.get("L_plus_n", {}).get("weighted_log_loss")
    raw = model_results.get("raw_plus_n", {}).get("weighted_log_loss")
    cnf = model_results.get("cnf_count_plus_n", {}).get("weighted_log_loss")
    fm = model_results.get("first_moment", {}).get("weighted_log_loss")
    rel = None
    if lp is not None and raw:
        rel = (raw - lp) / raw
    return {
        "primary_supported": lp is not None and raw is not None and lp < raw,
        "relative_improvement_vs_raw_plus_n": rel,
        "strong_support": (
            lp is not None
            and raw is not None
            and cnf is not None
            and lp < raw
            and rel is not None
            and rel >= 0.10
            and lp <= cnf
        ),
        "theory_pure_support": fm is not None and raw is not None and fm < raw,
        "encoding_guardrail_passed": lp is not None and cnf is not None and lp <= cnf,
    }


def analyze(path: Path) -> dict:
    rows = load_rows(path)
    primary = eligible_primary_rows(rows)
    model_results = leave_one_mixture_out(primary) if primary else {}
    diagnostics = cell_diagnostics(rows)
    results = {
        "experiment": "route_a_mixed_csp",
        "version": "1.0.0",
        "source": str(path),
        "generated_at": datetime.now().isoformat(),
        "rows_total": len(rows),
        "primary_rows_eligible": len(primary),
        "cell_diagnostics": diagnostics,
        "leave_one_mixture_out": model_results,
        "support": support_flags(model_results) if model_results else {},
    }
    RESULTS_JSON.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    write_markdown(results)
    return results


def write_markdown(results: dict) -> None:
    lines = [
        "# Mixed-CSP Results Summary",
        "",
        f"Generated: {results['generated_at']}",
        f"Rows total: `{results['rows_total']}`",
        f"Eligible primary rows: `{results['primary_rows_eligible']}`",
        "",
        "## Primary Model Comparison",
        "",
        "| Model | Log loss | Brier | Accuracy@0.5 |",
        "|---|---:|---:|---:|",
    ]
    comparison = results.get("leave_one_mixture_out", {})
    for name, values in sorted(
        comparison.items(),
        key=lambda item: float("inf") if item[1]["weighted_log_loss"] is None else item[1]["weighted_log_loss"],
    ):
        lines.append(
            f"| `{name}` | {fmt(values['weighted_log_loss'])} | "
            f"{fmt(values['weighted_brier'])} | {fmt(values['weighted_accuracy_at_0_5'])} |"
        )
    lines.extend(
        [
            "",
            "## Support Flags",
            "",
            "```json",
            json.dumps(results.get("support", {}), ensure_ascii=False, indent=2),
            "```",
            "",
            "## Cell Diagnostics",
            "",
            "| Cell | n | valid | SAT rate | timeout rate | median CNF/raw | timeout flag |",
            "|---|---:|---:|---:|---:|---:|---|",
        ]
    )
    for cell in results["cell_diagnostics"]:
        lines.append(
            f"| `{cell['cell_id']}` | {cell['n']} | {cell['valid_n']} | "
            f"{fmt(cell['sat_rate'])} | {fmt(cell['timeout_rate'])} | "
            f"{fmt(cell['median_cnf_ratio'])} | `{cell['flag_timeout_gt_0_05']}` |"
        )
    RESULTS_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def fmt(value: float | None) -> str:
    if value is None:
        return "NA"
    return f"{value:.4f}"


def summarize_exact_one_pilot(path: Path) -> dict:
    rows = [row for row in load_rows(path) if row.phase == "exact_one_pilot"]
    diagnostics = cell_diagnostics(rows)
    by_mixture_n: dict[tuple[str, int], list[dict]] = defaultdict(list)
    for cell in diagnostics:
        parts = cell["cell_id"].split("|")
        n = int(parts[1].removeprefix("n="))
        mixture = parts[3]
        by_mixture_n[(mixture, n)].append(cell)

    mixture_passes: dict[str, dict] = {}
    for mixture in sorted({key[0] for key in by_mixture_n}):
        n_pass = 0
        cnf_ok = True
        details = []
        for n in sorted({key[1] for key in by_mixture_n if key[0] == mixture}):
            cells = by_mixture_n[(mixture, n)]
            sat_rates = [cell["sat_rate"] for cell in cells if cell["sat_rate"] is not None]
            cnf_ratios = [cell["median_cnf_ratio"] for cell in cells if cell["median_cnf_ratio"] is not None]
            sat_rate_mean = float(np.mean(sat_rates)) if sat_rates else None
            cnf_ratio_max = max(cnf_ratios) if cnf_ratios else None
            n_ok = sat_rate_mean is not None and sat_rate_mean > 0.30
            n_pass += int(n_ok)
            cnf_ok = cnf_ok and cnf_ratio_max is not None and cnf_ratio_max < 5.0
            details.append({"n": n, "sat_rate_mean": sat_rate_mean, "cnf_ratio_max": cnf_ratio_max, "n_ok": n_ok})
        mixture_passes[mixture] = {
            "sat_rate_pass_count": n_pass,
            "sat_rate_criterion": n_pass >= 2,
            "cnf_criterion": cnf_ok,
            "promotion_criteria_passed": n_pass >= 2 and cnf_ok,
            "details": details,
        }

    summary = {
        "generated_at": datetime.now().isoformat(),
        "rows": len(rows),
        "mixtures": mixture_passes,
        "promote_exact_one": bool(mixture_passes)
        and all(value["promotion_criteria_passed"] for value in mixture_passes.values()),
    }
    write_exact_one_markdown(summary)
    return summary


def summarize_smoke(path: Path) -> dict:
    rows = [row for row in load_rows(path) if row.phase == "smoke"]
    diagnostics = cell_diagnostics(rows)
    runtimes = []
    raw_records = []
    if path.exists():
        with path.open() as f:
            raw_records = [json.loads(line) for line in f if line.strip()]
    for rec in raw_records:
        if rec.get("phase") == "smoke" and rec.get("runtime_sec") is not None:
            runtimes.append(float(rec["runtime_sec"]))

    ratio_by_mixture: dict[str, set[float]] = defaultdict(set)
    for row in rows:
        ratio_by_mixture[row.mixture_id].add(row.cnf_clause_count / row.semantic_raw_count)

    smoke_records = [rec for rec in raw_records if rec.get("phase") == "smoke"]
    sat_records = [rec for rec in smoke_records if rec.get("sat_feasible") is True]

    checks = {
        "all_solver_statuses_succeeded": all(row.status == "succeeded" for row in rows),
        "all_sat_assignments_verified": all(rec.get("assignment_verified") is True for rec in sat_records),
        "pure_sat_cnf_ratio_1": ratio_by_mixture.get("sat_1.00__nae_0.00__exact1_0.00") == {1.0},
        "pure_nae_cnf_ratio_2": ratio_by_mixture.get("sat_0.00__nae_1.00__exact1_0.00") == {2.0},
        "pure_exact_one_cnf_ratio_4": ratio_by_mixture.get("sat_0.00__nae_0.00__exact1_1.00") == {4.0},
        "mixed_sat_nae_cnf_ratio_1_5": ratio_by_mixture.get("sat_0.50__nae_0.50__exact1_0.00") == {1.5},
    }
    median_runtime = float(np.median(runtimes)) if runtimes else None
    p90_runtime = float(np.percentile(runtimes, 90)) if runtimes else None
    summary = {
        "generated_at": datetime.now().isoformat(),
        "rows": len(rows),
        "checks": checks,
        "median_runtime_sec": median_runtime,
        "p90_runtime_sec": p90_runtime,
        "primary_runtime_extrapolation_median_sec": median_runtime * 12000 if median_runtime is not None else None,
        "primary_runtime_extrapolation_p90_sec": p90_runtime * 12000 if p90_runtime is not None else None,
        "cell_diagnostics": diagnostics,
    }
    SMOKE_JSON.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    write_smoke_markdown(summary)
    return summary


def write_smoke_markdown(summary: dict) -> None:
    lines = [
        "# Mixed-CSP Smoke Summary",
        "",
        f"Generated: {summary['generated_at']}",
        f"Rows: `{summary['rows']}`",
        f"Median runtime: `{fmt(summary['median_runtime_sec'])}` sec",
        f"P90 runtime: `{fmt(summary['p90_runtime_sec'])}` sec",
        f"Primary runtime extrapolation, median: `{fmt(summary['primary_runtime_extrapolation_median_sec'])}` sec",
        f"Primary runtime extrapolation, P90: `{fmt(summary['primary_runtime_extrapolation_p90_sec'])}` sec",
        "",
        "## Checks",
        "",
        "| Check | Passed |",
        "|---|---|",
    ]
    for key, value in summary["checks"].items():
        lines.append(f"| `{key}` | `{value}` |")
    lines.extend(
        [
            "",
            "## Cells",
            "",
            "| Cell | n | SAT rate | timeout rate | median CNF/raw |",
            "|---|---:|---:|---:|---:|",
        ]
    )
    for cell in summary["cell_diagnostics"]:
        lines.append(
            f"| `{cell['cell_id']}` | {cell['n']} | {fmt(cell['sat_rate'])} | "
            f"{fmt(cell['timeout_rate'])} | {fmt(cell['median_cnf_ratio'])} |"
        )
    SMOKE_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_exact_one_markdown(summary: dict) -> None:
    lines = [
        "# Exact-One Pilot Summary",
        "",
        f"Generated: {summary['generated_at']}",
        f"Rows: `{summary['rows']}`",
        f"Promote exact-one: `{summary['promote_exact_one']}`",
        "",
        "| Mixture | SAT-rate pass count | SAT criterion | CNF criterion | Promotion passed |",
        "|---|---:|---|---|---|",
    ]
    for mixture, info in summary["mixtures"].items():
        lines.append(
            f"| `{mixture}` | {info['sat_rate_pass_count']} | `{info['sat_rate_criterion']}` "
            f"| `{info['cnf_criterion']}` | `{info['promotion_criteria_passed']}` |"
        )
    EXACT_ONE_PILOT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=TRIALS_PATH)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("analyze")
    sub.add_parser("exact-one-pilot")
    sub.add_parser("smoke")
    args = parser.parse_args()
    if args.cmd == "analyze":
        print(json.dumps(analyze(args.input), ensure_ascii=False, indent=2))
    elif args.cmd == "exact-one-pilot":
        print(json.dumps(summarize_exact_one_pilot(args.input), ensure_ascii=False, indent=2))
    elif args.cmd == "smoke":
        print(json.dumps(summarize_smoke(args.input), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
