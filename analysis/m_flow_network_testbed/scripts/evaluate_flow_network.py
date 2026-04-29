#!/usr/bin/env python3
"""Evaluator v1 for the M-profile flow-network testbed.

This evaluator is a dry-run ranking/schema checker, not a primary validation
runner. It trains only on calibration rows, then reports whether the emitted
simulator readouts are sufficient to compare total-resource, policy-prior, and
M-profile ranking predictors across held-out split axes.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
from collections import defaultdict
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parents[1]
DEFAULT_RUNS = HERE / "dry_runs" / "v0_smoke" / "runs.csv"
DEFAULT_OUT_DIR = HERE / "dry_runs" / "v0_smoke"

GROUP_COLUMNS = (
    "seed",
    "graph_family",
    "damage_family",
    "total_energy_E",
    "required_flow_Q",
    "horizon_T",
    "damage_intensity",
)

CALIBRATION_SPLITS = {
    "graph_split": "calibration",
    "damage_split": "calibration",
    "allocation_split": "calibration",
}

MODEL_PRED_KEYS = {
    "total_resource_tie": "pred_total_resource_tie",
    "policy_prior": "pred_policy_prior",
    "m_profile_linear": "pred_m_profile_linear",
}

METRIC_KEYS = (
    "top1_tie_adjusted",
    "top2_contains_observed_best",
    "kendall_tau",
    "regret",
)


def as_float(row: dict[str, str], key: str) -> float:
    value = row.get(key, "")
    if value == "":
        return float("nan")
    return float(value)


def allocation(row: dict[str, str]) -> tuple[int, int, int]:
    return (
        int(row["allocation_buffer"]),
        int(row["allocation_recovery"]),
        int(row["allocation_reconfiguration"]),
    )


def allocation_key(row: dict[str, str]) -> str:
    return ",".join(str(x) for x in allocation(row))


def group_key(row: dict[str, str]) -> tuple[str, ...]:
    return tuple(row[column] for column in GROUP_COLUMNS)


def observed_score(row: dict[str, str]) -> float:
    """Single v0 scalar used only for dry-run ranking smoke tests.

    The score favors maintained service first, then flow quality, then margin.
    Primary metrics are still defined separately in the preregistration draft.
    """
    return (
        as_float(row, "maintained_step_ratio")
        + as_float(row, "maintained_flow_ratio")
        + 0.01 * as_float(row, "minimum_margin")
    )


def is_calibration(row: dict[str, str]) -> bool:
    return all(row.get(column) == expected for column, expected in CALIBRATION_SPLITS.items())


def model_features(row: dict[str, str]) -> list[float]:
    total = max(as_float(row, "total_energy_E"), 1.0)
    return [
        as_float(row, "allocation_buffer") / total,
        as_float(row, "allocation_recovery") / total,
        as_float(row, "allocation_reconfiguration") / total,
    ]


def solve_3x3(a: list[list[float]], b: list[float]) -> list[float]:
    matrix = [row[:] + [rhs] for row, rhs in zip(a, b)]
    n = 3
    for col in range(n):
        pivot = max(range(col, n), key=lambda row: abs(matrix[row][col]))
        if abs(matrix[pivot][col]) < 1e-12:
            return [0.0, 0.0, 0.0]
        matrix[col], matrix[pivot] = matrix[pivot], matrix[col]
        scale = matrix[col][col]
        matrix[col] = [value / scale for value in matrix[col]]
        for row in range(n):
            if row == col:
                continue
            factor = matrix[row][col]
            matrix[row] = [
                value - factor * base
                for value, base in zip(matrix[row], matrix[col])
            ]
    return [matrix[row][n] for row in range(n)]


def fit_linear_m_profile(rows: list[dict[str, str]], ridge: float = 1e-6) -> list[float]:
    xtx = [[0.0 for _ in range(3)] for _ in range(3)]
    xty = [0.0 for _ in range(3)]
    for row in rows:
        x = model_features(row)
        y = observed_score(row)
        if not math.isfinite(y):
            continue
        for i in range(3):
            xty[i] += x[i] * y
            for j in range(3):
                xtx[i][j] += x[i] * x[j]
    for i in range(3):
        xtx[i][i] += ridge
    return solve_3x3(xtx, xty)


def fit_policy_prior(rows: list[dict[str, str]]) -> dict[str, Any]:
    by_exact: dict[str, list[float]] = defaultdict(list)
    by_damage: dict[str, list[float]] = defaultdict(list)
    by_graph: dict[str, list[float]] = defaultdict(list)
    by_policy: dict[str, list[float]] = defaultdict(list)
    for row in rows:
        score = observed_score(row)
        if math.isfinite(score):
            policy = row["policy_anchor"]
            by_exact["|".join((row["graph_family"], row["damage_family"], policy))].append(score)
            by_damage["|".join((row["damage_family"], policy))].append(score)
            by_graph["|".join((row["graph_family"], policy))].append(score)
            by_policy[policy].append(score)
    global_mean = (
        sum(score for scores in by_policy.values() for score in scores)
        / sum(len(scores) for scores in by_policy.values())
        if by_policy
        else 0.0
    )

    def means(values: dict[str, list[float]]) -> dict[str, float]:
        return {
            key: sum(scores) / len(scores)
            for key, scores in values.items()
            if scores
        }

    return {
        "exact": means(by_exact),
        "damage": means(by_damage),
        "graph": means(by_graph),
        "policy": means(by_policy),
        "fallback": global_mean,
    }


def policy_prior_score(prior: dict[str, Any], row: dict[str, str]) -> float:
    policy = row["policy_anchor"]
    exact_key = "|".join((row["graph_family"], row["damage_family"], policy))
    damage_key = "|".join((row["damage_family"], policy))
    graph_key = "|".join((row["graph_family"], policy))
    for section, key in (
        ("exact", exact_key),
        ("damage", damage_key),
        ("graph", graph_key),
        ("policy", policy),
    ):
        value = prior[section].get(key)
        if value is not None:
            return float(value)
    return float(prior["fallback"])


def sign(value: float, eps: float = 1e-12) -> int:
    if value > eps:
        return 1
    if value < -eps:
        return -1
    return 0


def top_set(rows: list[dict[str, Any]], key: str, *, reverse: bool = True) -> set[int]:
    values = [float(row[key]) for row in rows]
    target = max(values) if reverse else min(values)
    return {idx for idx, value in enumerate(values) if abs(value - target) <= 1e-12}


def top_k_set(rows: list[dict[str, Any]], key: str, k: int) -> set[int]:
    ranked_values = sorted({float(row[key]) for row in rows}, reverse=True)
    if not ranked_values:
        return set()
    threshold = ranked_values[min(k - 1, len(ranked_values) - 1)]
    return {idx for idx, row in enumerate(rows) if float(row[key]) >= threshold - 1e-12}


def kendall_tau(rows: list[dict[str, Any]], pred_key: str) -> float:
    concordant = 0
    discordant = 0
    for i in range(len(rows)):
        for j in range(i + 1, len(rows)):
            obs = sign(float(rows[i]["observed_score"]) - float(rows[j]["observed_score"]))
            pred = sign(float(rows[i][pred_key]) - float(rows[j][pred_key]))
            if obs == 0 or pred == 0:
                continue
            if obs == pred:
                concordant += 1
            else:
                discordant += 1
    total = concordant + discordant
    return (concordant - discordant) / total if total else 0.0


def group_metrics(rows: list[dict[str, Any]], pred_key: str) -> dict[str, float]:
    observed_top = top_set(rows, "observed_score")
    predicted_top = top_set(rows, pred_key)
    predicted_top2 = top_k_set(rows, pred_key, 2)
    top1 = len(observed_top & predicted_top) / max(1, len(predicted_top))
    top2 = 1.0 if observed_top & predicted_top2 else 0.0
    best_observed = max(float(row["observed_score"]) for row in rows)
    predicted_top_mean = sum(float(rows[idx]["observed_score"]) for idx in predicted_top) / max(1, len(predicted_top))
    return {
        "top1_tie_adjusted": top1,
        "top2_contains_observed_best": top2,
        "kendall_tau": kendall_tau(rows, pred_key),
        "regret": best_observed - predicted_top_mean,
    }


def mean_dict(dicts: list[dict[str, float]]) -> dict[str, float]:
    if not dicts:
        return {}
    keys = sorted(dicts[0])
    return {
        key: sum(item[key] for item in dicts) / len(dicts)
        for key in keys
    }


def group_split_info(items: list[dict[str, Any]]) -> dict[str, Any]:
    graph_splits = sorted({str(item["graph_split"]) for item in items})
    damage_splits = sorted({str(item["damage_split"]) for item in items})
    has_heldout_allocation = any(item["allocation_split"] == "primary_heldout" for item in items)
    axes: list[str] = []
    if any(split != "calibration" for split in graph_splits):
        axes.append("graph")
    if any(split != "calibration" for split in damage_splits):
        axes.append("damage")
    if has_heldout_allocation:
        axes.append("allocation")
    if not axes:
        group_split = "calibration_only"
    else:
        group_split = "heldout_" + "_".join(axes)
    return {
        "graph_split": "|".join(graph_splits),
        "damage_split": "|".join(damage_splits),
        "has_heldout_allocation": has_heldout_allocation,
        "primary_axes": "|".join(axes) if axes else "none",
        "group_split": group_split,
    }


def group_slice_names(group_row: dict[str, Any]) -> list[str]:
    names = ["all"]
    names.append(f"group_split:{group_row['group_split']}")
    names.append(f"graph_split:{group_row['graph_split']}")
    names.append(f"damage_split:{group_row['damage_split']}")
    allocation_name = "primary_heldout" if group_row["has_heldout_allocation"] else "calibration_only"
    names.append(f"allocation_split:{allocation_name}")
    for axis in str(group_row["primary_axes"]).split("|"):
        if axis and axis != "none":
            names.append(f"heldout_axis:{axis}")
    return names


def split_metric_rows(group_rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_slice: dict[str, dict[str, list[dict[str, float]]]] = defaultdict(
        lambda: {model: [] for model in MODEL_PRED_KEYS}
    )
    for row in group_rows:
        for slice_name in group_slice_names(row):
            for model in MODEL_PRED_KEYS:
                by_slice[slice_name][model].append(
                    {
                        metric: float(row[f"{model}_{metric}"])
                        for metric in METRIC_KEYS
                    }
                )

    slice_rows: list[dict[str, Any]] = []
    for slice_name, model_values in sorted(by_slice.items()):
        for model, values in sorted(model_values.items()):
            means = mean_dict(values)
            slice_rows.append(
                {
                    "slice": slice_name,
                    "model": model,
                    "n_groups": len(values),
                    **means,
                }
            )
    return slice_rows


def split_comparisons(group_rows: list[dict[str, Any]]) -> dict[str, Any]:
    comparisons: dict[str, Any] = {}
    by_slice: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in group_rows:
        for slice_name in group_slice_names(row):
            by_slice[slice_name].append(row)

    for slice_name, rows in sorted(by_slice.items()):
        n = len(rows)
        if n == 0:
            continue
        comparisons[slice_name] = {
            "n_groups": n,
            "m_beats_total_resource_regret_rate": sum(
                bool(row["m_profile_beats_total_resource_regret"]) for row in rows
            )
            / n,
            "m_beats_policy_prior_regret_rate": sum(
                bool(row["m_profile_beats_policy_prior_regret"]) for row in rows
            )
            / n,
            "m_beats_policy_prior_kendall_rate": sum(
                bool(row["m_profile_beats_policy_prior_kendall"]) for row in rows
            )
            / n,
            "m_clears_policy_prior_smoke_rate": sum(
                bool(row["m_profile_clears_policy_prior_smoke"]) for row in rows
            )
            / n,
        }
    return comparisons


def evaluate(
    rows: list[dict[str, str]],
    *,
    status: str,
    non_claim: str,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Any]]:
    calibration_rows = [row for row in rows if is_calibration(row)]
    policy_prior = fit_policy_prior(calibration_rows)
    weights = fit_linear_m_profile(calibration_rows)
    groups: dict[tuple[str, ...], list[dict[str, Any]]] = defaultdict(list)

    for row in rows:
        enriched: dict[str, Any] = dict(row)
        enriched["allocation"] = allocation_key(row)
        enriched["observed_score"] = observed_score(row)
        enriched["pred_total_resource_tie"] = 0.0
        enriched["pred_policy_prior"] = policy_prior_score(policy_prior, row)
        enriched["pred_m_profile_linear"] = sum(w * x for w, x in zip(weights, model_features(row)))
        groups[group_key(row)].append(enriched)

    group_rows: list[dict[str, Any]] = []
    metric_accumulator: dict[str, list[dict[str, float]]] = {model: [] for model in MODEL_PRED_KEYS}

    for key, items in sorted(groups.items()):
        if len(items) < 2:
            continue
        observed_best = top_set(items, "observed_score")
        metrics = {
            model: group_metrics(items, pred_key)
            for model, pred_key in MODEL_PRED_KEYS.items()
        }
        for model, model_metrics in metrics.items():
            metric_accumulator[model].append(model_metrics)
        best_allocations = [items[idx]["allocation"] for idx in sorted(observed_best)]
        split_info = group_split_info(items)
        row = {
            **{column: value for column, value in zip(GROUP_COLUMNS, key)},
            **split_info,
            "n_allocations": len(items),
            "observed_best_allocations": "|".join(best_allocations),
        }
        for model, model_metrics in metrics.items():
            for metric, value in model_metrics.items():
                row[f"{model}_{metric}"] = value
        row["m_profile_beats_total_resource_regret"] = (
            metrics["m_profile_linear"]["regret"] < metrics["total_resource_tie"]["regret"]
        )
        row["m_profile_beats_policy_prior_regret"] = (
            metrics["m_profile_linear"]["regret"] < metrics["policy_prior"]["regret"]
        )
        row["m_profile_beats_policy_prior_kendall"] = (
            metrics["m_profile_linear"]["kendall_tau"] > metrics["policy_prior"]["kendall_tau"]
        )
        row["m_profile_clears_policy_prior_smoke"] = (
            row["m_profile_beats_policy_prior_regret"]
            and row["m_profile_beats_policy_prior_kendall"]
        )
        group_rows.append(row)

    slice_rows = split_metric_rows(group_rows)
    comparisons = split_comparisons(group_rows)
    all_comparison = comparisons.get("all", {})
    m_clears_policy_prior_smoke = bool(
        all_comparison
        and all_comparison.get("m_clears_policy_prior_smoke_rate", 0.0) >= 0.5
    )

    summary = {
        "status": status,
        "non_claim": non_claim,
        "runs": len(rows),
        "calibration_rows": len(calibration_rows),
        "groups_evaluated": len(group_rows),
        "m_profile_linear_weights": {
            "buffer": weights[0],
            "recovery": weights[1],
            "reconfiguration": weights[2],
        },
        "policy_prior": policy_prior,
        "model_metrics": {
            model: mean_dict(values)
            for model, values in metric_accumulator.items()
        },
        "split_comparisons": comparisons,
        "guardrail_result": {
            "m_profile_clears_policy_prior_smoke": m_clears_policy_prior_smoke,
            "interpretation": (
                "schema guardrail only; a false value is acceptable in dry-run "
                "and means the strong policy-prior baseline is active"
            ),
        },
        "schema_fields": {
            "group_rankings": list(group_rows[0].keys()) if group_rows else [],
            "slice_metrics": list(slice_rows[0].keys()) if slice_rows else [],
        },
    }
    return group_rows, slice_rows, summary


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def write_outputs(
    group_rows: list[dict[str, Any]],
    slice_rows: list[dict[str, Any]],
    summary: dict[str, Any],
    out_dir: Path,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    group_path = out_dir / "evaluation_group_rankings.csv"
    slice_path = out_dir / "evaluation_slice_metrics.csv"
    summary_path = out_dir / "evaluation_summary.json"
    if group_rows:
        with group_path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(group_rows[0].keys()), lineterminator="\n")
            writer.writeheader()
            writer.writerows(group_rows)
    if slice_rows:
        with slice_path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(slice_rows[0].keys()), lineterminator="\n")
            writer.writeheader()
            writer.writerows(slice_rows)
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def fail_if_outputs_exist(out_dir: Path, filenames: tuple[str, ...], *, allow_overwrite: bool) -> None:
    existing = [str(out_dir / name) for name in filenames if (out_dir / name).exists()]
    if existing and not allow_overwrite:
        raise SystemExit(
            "refusing to overwrite existing evaluator output(s): "
            + ", ".join(existing)
            + " (use --allow-overwrite only for explicitly labeled reruns)"
        )


def require_primary_confirmation(args: argparse.Namespace) -> None:
    if not args.confirm_frozen_primary:
        raise SystemExit("--primary-run requires --confirm-frozen-primary")
    if not os.environ.get("CONFIRM_M_FLOW_PRIMARY"):
        raise SystemExit("--primary-run requires CONFIRM_M_FLOW_PRIMARY to be set")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=Path, default=DEFAULT_RUNS)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--primary-run", action="store_true")
    parser.add_argument("--confirm-frozen-primary", action="store_true")
    parser.add_argument("--allow-overwrite", action="store_true")
    args = parser.parse_args()

    if args.primary_run:
        require_primary_confirmation(args)
        fail_if_outputs_exist(
            args.out_dir,
            ("evaluation_group_rankings.csv", "evaluation_slice_metrics.csv", "evaluation_summary.json"),
            allow_overwrite=args.allow_overwrite,
        )
        status = "primary_evaluator_v1_uninterpreted"
        non_claim = (
            "primary evaluator metrics only; support requires the frozen "
            "support-rule decision and degeneracy review"
        )
    else:
        status = "dry_run_evaluator_v1_only"
        non_claim = "split-aware ranking smoke test only; not M-primary support"

    rows = read_rows(args.runs)
    group_rows, slice_rows, summary = evaluate(rows, status=status, non_claim=non_claim)
    write_outputs(group_rows, slice_rows, summary, args.out_dir)
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))
    print(f"wrote: {args.out_dir / 'evaluation_group_rankings.csv'}")
    print(f"wrote: {args.out_dir / 'evaluation_slice_metrics.csv'}")
    print(f"wrote: {args.out_dir / 'evaluation_summary.json'}")


if __name__ == "__main__":
    main()
