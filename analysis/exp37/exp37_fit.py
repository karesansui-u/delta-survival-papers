#!/usr/bin/env python3
"""
Experiment 37: Function Form Discrimination via AIC/BIC
========================================================

Fits 4 functional forms to accuracy vs. density data from exp37_density_sweep.py:
  1. Exponential:  acc = mu * exp(-k * density)
  2. Power law:    acc = mu * (1 + density)^{-beta}
  3. Linear:       acc = max(0, mu * (1 - k * density))
  4. Sigmoid:      acc = L + (mu - L) / (1 + exp(k * (density - d0)))

Model comparison via AIC and BIC (assuming normal residuals).

Usage:
  python analysis/exp37/exp37_fit.py --model gpt-4.1-nano
  python analysis/exp37/exp37_fit.py --model gpt-4.1-nano --context 32000
  python analysis/exp37/exp37_fit.py --model gpt-4.1-nano --plot   # requires matplotlib
"""

import argparse
import json
import math
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np

try:
    from scipy.optimize import curve_fit
    from scipy.stats import pearsonr
    HAS_SCIPY = True
except ImportError:
    HAS_SCIPY = False
    print("WARNING: scipy not found. Install with: pip install scipy")

OUTPUT_DIR = Path(__file__).parent

DENSITY_LEVELS = [0.00, 0.03, 0.06, 0.09, 0.12, 0.18, 0.24, 0.30]
CONTEXT_LENGTHS = [32_000, 128_000, 256_000]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Model Definitions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def model_exponential(x, mu, k):
    """acc = mu * exp(-k * x)"""
    return mu * np.exp(-k * x)


def model_power_law(x, mu, beta):
    """acc = mu * (1 + x)^{-beta}  [well-defined at x=0]"""
    return mu * np.power(1.0 + x, -beta)


def model_linear(x, mu, k):
    """acc = max(0, mu * (1 - k * x))"""
    return np.maximum(0.0, mu * (1.0 - k * x))


def model_sigmoid(x, L, mu, k, d0):
    """acc = L + (mu - L) / (1 + exp(k * (x - d0)))"""
    return L + (mu - L) / (1.0 + np.exp(k * (x - d0)))


MODELS = {
    "exponential": {
        "func": model_exponential,
        "n_params": 2,
        "p0": [1.0, 5.0],
        "bounds": ([0.0, 0.0], [1.0, 100.0]),
        "param_names": ["mu", "k"],
    },
    "power_law": {
        "func": model_power_law,
        "n_params": 2,
        "p0": [1.0, 2.0],
        "bounds": ([0.0, 0.0], [1.0, 50.0]),
        "param_names": ["mu", "beta"],
    },
    "linear": {
        "func": model_linear,
        "n_params": 2,
        "p0": [1.0, 3.0],
        "bounds": ([0.0, 0.0], [1.0, 100.0]),
        "param_names": ["mu", "k"],
    },
    "sigmoid": {
        "func": model_sigmoid,
        "n_params": 4,
        "p0": [0.0, 1.0, 20.0, 0.15],
        "bounds": ([0.0, 0.0, 0.0, 0.0], [0.5, 1.0, 200.0, 0.50]),
        "param_names": ["L", "mu", "k", "d0"],
    },
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AIC / BIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def compute_aic_bic(y_true, y_pred, n_params):
    """
    AIC and BIC assuming normal residuals (regression setting).
    AIC = n * ln(RSS/n) + 2k
    BIC = n * ln(RSS/n) + k * ln(n)
    """
    n = len(y_true)
    rss = np.sum((y_true - y_pred) ** 2)
    if rss <= 0:
        rss = 1e-12
    log_likelihood_term = n * math.log(rss / n)
    aic = log_likelihood_term + 2 * n_params
    bic = log_likelihood_term + n_params * math.log(n)
    r2 = 1.0 - rss / max(np.sum((y_true - np.mean(y_true)) ** 2), 1e-12)
    rmse = math.sqrt(rss / n)
    return {"aic": aic, "bic": bic, "r2": r2, "rmse": rmse, "rss": rss}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Data Loading
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def load_logprob_by_density(
    model_name: str,
    context_filter: Optional[int] = None,
    contradiction_type: str = "structural",
) -> Tuple[np.ndarray, np.ndarray, Dict]:
    """
    Load mean log_p_correct per density level.
    Returns (densities, mean_log_p_correct, cell_info).
    """
    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    path = OUTPUT_DIR / f"exp37_{safe}_{contradiction_type}_trials.jsonl"
    if not path.exists():
        raise FileNotFoundError(f"No data: {path}")

    trials = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                trials.append(json.loads(line))

    trials = [t for t in trials if t.get("result_type") == "succeeded"
              and t.get("log_p_correct") is not None]
    if context_filter:
        trials = [t for t in trials if t["context_length"] == context_filter]

    density_vals, logprob_vals, cell_info = [], [], {}
    for density in DENSITY_LEVELS:
        cells = [t for t in trials if abs(t["density"] - density) < 1e-6]
        if not cells:
            continue
        mean_lp = sum(t["log_p_correct"] for t in cells) / len(cells)
        density_vals.append(density)
        logprob_vals.append(mean_lp)
        cell_info[density] = {"n": len(cells), "mean_log_p": mean_lp}

    return np.array(density_vals), np.array(logprob_vals), cell_info


def test_logprob_linearity(x: np.ndarray, log_p: np.ndarray) -> Dict:
    """
    Test H: log P(correct | density=d) = intercept + slope * d  (linear in d)
    If confirmed → P = exp(intercept) * exp(slope*d) = μ * exp(-k*d)
    i.e., the exponential decay theorem holds empirically.
    """
    if not HAS_SCIPY:
        return {}
    # Linear fit
    coeffs = np.polyfit(x, log_p, 1)
    slope, intercept = coeffs
    y_pred = np.polyval(coeffs, x)
    ss_res = np.sum((log_p - y_pred) ** 2)
    ss_tot = np.sum((log_p - np.mean(log_p)) ** 2)
    r2_linear = 1 - ss_res / max(ss_tot, 1e-12)

    # Quadratic fit (alternative)
    coeffs2 = np.polyfit(x, log_p, 2)
    y_pred2 = np.polyval(coeffs2, x)
    ss_res2 = np.sum((log_p - y_pred2) ** 2)
    r2_quad = 1 - ss_res2 / max(ss_tot, 1e-12)

    n = len(x)
    # AIC for linear (k=2) vs quadratic (k=3)
    aic_linear = n * math.log(max(ss_res / n, 1e-12)) + 2 * 2
    aic_quad   = n * math.log(max(ss_res2 / n, 1e-12)) + 2 * 3

    return {
        "slope": slope,
        "intercept": intercept,
        "mu_implied": math.exp(intercept),  # = P(correct) at density=0 predicted by linear fit
        "k_implied": -slope,                # per-unit decay rate
        "r2_linear": r2_linear,
        "r2_quadratic": r2_quad,
        "aic_linear": aic_linear,
        "aic_quadratic": aic_quad,
        "delta_aic": aic_quad - aic_linear,  # positive → linear preferred
        "verdict": "exponential supported" if r2_linear > 0.95 and (aic_quad - aic_linear) > -2
                   else "non-linear — more data needed" if r2_linear > 0.80
                   else "unclear",
    }


def load_accuracy_by_density(
    model_name: str,
    context_filter: Optional[int] = None,
    contradiction_type: str = "structural",
) -> Tuple[np.ndarray, np.ndarray, Dict]:
    """
    Load JSONL, aggregate accuracy per density level.
    Returns (densities, accuracies, cell_counts).
    If context_filter is None, averages across all context lengths.
    """
    safe = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    path = OUTPUT_DIR / f"exp37_{safe}_{contradiction_type}_trials.jsonl"

    if not path.exists():
        raise FileNotFoundError(f"No data file: {path}")

    trials = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                trials.append(json.loads(line))

    trials = [t for t in trials if t.get("result_type") == "succeeded"]

    if context_filter is not None:
        trials = [t for t in trials if t["context_length"] == context_filter]

    density_vals = []
    accuracy_vals = []
    cell_info = {}

    for density in DENSITY_LEVELS:
        cells = [t for t in trials if abs(t["density"] - density) < 1e-6]
        if not cells:
            continue
        acc = sum(1 for t in cells if t["is_correct"]) / len(cells)
        density_vals.append(density)
        accuracy_vals.append(acc)
        cell_info[density] = {"n": len(cells), "acc": acc}

    return np.array(density_vals), np.array(accuracy_vals), cell_info


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Fitting
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def fit_all_models(x: np.ndarray, y: np.ndarray) -> Dict:
    results = {}
    for name, spec in MODELS.items():
        try:
            popt, _ = curve_fit(
                spec["func"], x, y,
                p0=spec["p0"],
                bounds=spec["bounds"],
                maxfev=10000,
            )
            y_pred = spec["func"](x, *popt)
            metrics = compute_aic_bic(y, y_pred, spec["n_params"])
            results[name] = {
                "params": dict(zip(spec["param_names"], popt.tolist())),
                **metrics,
                "converged": True,
            }
        except Exception as e:
            results[name] = {"converged": False, "error": str(e)}
    return results


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Report
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def print_report(
    model_name: str,
    x: np.ndarray,
    y: np.ndarray,
    cell_info: Dict,
    fit_results: Dict,
    context_label: str,
):
    print(f"\n{'=' * 65}")
    print(f"EXP37 FUNCTION FORM DISCRIMINATION")
    print(f"  Model:   {model_name}")
    print(f"  Context: {context_label}")
    print(f"  Points:  {len(x)} density levels")
    print(f"{'=' * 65}")

    print(f"\nData:")
    print(f"  {'density':>8}  {'acc':>6}  {'n':>5}")
    for d, a in zip(x, y):
        n = cell_info.get(d, {}).get("n", "?")
        print(f"  {d:>7.0%}  {a:>6.3f}  {n:>5}")

    # AIC comparison table
    converged = {k: v for k, v in fit_results.items() if v.get("converged")}
    if not converged:
        print("\nNo models converged.")
        return

    min_aic = min(v["aic"] for v in converged.values())
    min_bic = min(v["bic"] for v in converged.values())

    print(f"\nModel Comparison (lower AIC/BIC = better fit):")
    print(f"  {'Model':>12}  {'AIC':>7}  {'ΔAIC':>6}  {'BIC':>7}  {'ΔBIC':>6}  {'R²':>6}  {'RMSE':>7}  {'k/params':>20}")
    print(f"  {'-'*12}  {'-'*7}  {'-'*6}  {'-'*7}  {'-'*6}  {'-'*6}  {'-'*7}  {'-'*20}")

    ranked = sorted(converged.items(), key=lambda kv: kv[1]["aic"])
    for name, v in ranked:
        delta_aic = v["aic"] - min_aic
        delta_bic = v["bic"] - min_bic
        param_str = ", ".join(f"{k}={val:.3f}" for k, val in v["params"].items())
        marker = " ◀ BEST" if delta_aic < 0.01 else ""
        print(
            f"  {name:>12}  {v['aic']:>7.2f}  {delta_aic:>6.2f}  "
            f"{v['bic']:>7.2f}  {delta_bic:>6.2f}  "
            f"{v['r2']:>6.3f}  {v['rmse']:>7.4f}  {param_str:<20}{marker}"
        )

    # Interpretation
    best_name = ranked[0][0]
    best = ranked[0][1]
    print(f"\nInterpretation:")
    if best_name == "exponential":
        k_val = best["params"].get("k", "?")
        mu_val = best["params"].get("mu", "?")
        print(f"  Exponential wins: acc = {mu_val:.3f} * exp(-{k_val:.3f} * density)")
        print(f"  → Consistent with S = N_eff * mu * e^(-δ) theorem.")
        print(f"  → Per-unit δ (density=1.0 equivalent): k = {k_val:.3f} nats^-1")
    elif best_name == "power_law":
        print(f"  Power law wins: contradicts pure exponential δ-framework.")
        print(f"  → Possible explanation: non-independence of constraints.")
    elif best_name == "linear":
        print(f"  Linear wins: accuracy has not entered deep collapse regime yet.")
        print(f"  → Try higher density levels or longer contexts.")
    elif best_name == "sigmoid":
        print(f"  Sigmoid wins: threshold effect — collapse onset at d0={best['params'].get('d0', '?'):.3f}")
        print(f"  → May indicate δ_c threshold in this model.")

    # ΔAIC > 2 = substantial evidence
    if len(ranked) > 1:
        second_delta_aic = ranked[1][1]["aic"] - min_aic
        if second_delta_aic > 2:
            print(f"  ΔAIC={second_delta_aic:.1f} (>2): substantial evidence favoring {best_name}.")
        elif second_delta_aic > 0.5:
            print(f"  ΔAIC={second_delta_aic:.1f}: weak discrimination — more data needed.")
        else:
            print(f"  ΔAIC={second_delta_aic:.1f}: models are statistically indistinguishable.")


def save_results(model_name: str, context_label: str, fit_results: Dict, x, y):
    safe_model = model_name.replace(":", "_").replace("/", "_").replace(".", "_")
    safe_ctx = context_label.replace(" ", "_")
    out_path = OUTPUT_DIR / f"exp37_{safe_model}_{safe_ctx}_fit.json"

    output = {
        "model": model_name,
        "context": context_label,
        "data": {"density": x.tolist(), "accuracy": y.tolist()},
        "fits": fit_results,
    }
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\n  Results saved: {out_path}")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Optional Plot
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def plot_fits(x, y, fit_results, title: str, save_path: Optional[Path] = None):
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available. Skipping plot.")
        return

    x_smooth = np.linspace(0, x.max(), 200)
    colors = {"exponential": "tab:red", "power_law": "tab:blue",
               "linear": "tab:green", "sigmoid": "tab:orange"}

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.scatter(x, y, s=60, zorder=5, color="black", label="Observed")

    converged = {k: v for k, v in fit_results.items() if v.get("converged")}
    min_aic = min(v["aic"] for v in converged.values()) if converged else 0

    for name, spec in MODELS.items():
        v = fit_results.get(name, {})
        if not v.get("converged"):
            continue
        params = list(v["params"].values())
        y_smooth = spec["func"](x_smooth, *params)
        delta_aic = v["aic"] - min_aic
        label = f"{name} (ΔAIC={delta_aic:.1f}, R²={v['r2']:.3f})"
        lw = 2.5 if delta_aic < 0.01 else 1.2
        ax.plot(x_smooth, y_smooth, color=colors[name], linewidth=lw, label=label)

    ax.set_xlabel("Contradiction density")
    ax.set_ylabel("Accuracy")
    ax.set_title(title)
    ax.legend(fontsize=9)
    ax.set_xlim(-0.01, x.max() + 0.02)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(alpha=0.3)

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches="tight")
        print(f"  Plot saved: {save_path}")
    else:
        plt.tight_layout()
        plt.show()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def print_logprob_report(model_name: str, x_lp, log_p, cell_info_lp, lin, context_label: str):
    print(f"\n{'=' * 65}")
    print(f"LOG-PROBABILITY LINEARITY TEST  (key test for e^{{-δ}} theorem)")
    print(f"  Model:   {model_name}  |  Context: {context_label}")
    print(f"{'=' * 65}")
    print(f"\n  {'density':>8}  {'mean log P':>12}  {'P(correct)':>12}  {'n':>5}")
    for d, lp in zip(x_lp, log_p):
        n = cell_info_lp.get(d, {}).get("n", "?")
        print(f"  {d:>7.0%}  {lp:>12.3f}  {math.exp(lp):>12.4f}  {n:>5}")

    print(f"\n  Linear fit: log P = {lin['intercept']:.3f} + ({lin['slope']:.3f}) × density")
    print(f"  → μ_implied = exp({lin['intercept']:.3f}) = {lin['mu_implied']:.3f}")
    print(f"  → k (decay rate) = {lin['k_implied']:.3f} per unit density")
    print(f"  R² linear:    {lin['r2_linear']:.4f}")
    print(f"  R² quadratic: {lin['r2_quadratic']:.4f}")
    print(f"  ΔAIC (quad−linear): {lin['delta_aic']:+.2f}  (positive = linear preferred)")
    print(f"\n  Verdict: {lin['verdict'].upper()}")
    if lin['verdict'] == "exponential supported":
        print(f"  → log P is linear in density → P = μ·exp(−k·density)")
        print(f"  → Consistent with S = N_eff·μ·e^{{−δ}} theorem.")
        print(f"  → Independence axiom: each contradiction contributes fixed −{lin['k_implied']/1:.4f} to log P.")
    elif "non-linear" in lin['verdict']:
        print(f"  → Moderate fit. More density levels or trials may clarify.")
    else:
        print(f"  → Insufficient signal. Try longer context or more trials.")


def main():
    parser = argparse.ArgumentParser(description="Exp.37: Function form discrimination + logprob test")
    parser.add_argument("--model", default="gpt-4.1-nano")
    parser.add_argument("--context", type=int, default=None,
                        help="Filter to single context length (e.g. 32000). Default: average all.")
    parser.add_argument("--subtle", action="store_true",
                        help="Use subtle contradiction data (default: structural)")
    parser.add_argument("--plot", action="store_true", help="Show matplotlib plot")
    parser.add_argument("--save-plot", type=str, default=None, help="Save plot to path")
    args = parser.parse_args()

    if not HAS_SCIPY:
        print("scipy required: pip install scipy numpy")
        return

    ctype = "subtle" if args.subtle else "structural"
    context_label = f"{args.context // 1000}K" if args.context else "all contexts"

    # ── 1. Log-probability linearity test (primary test for e^{-δ}) ──
    try:
        x_lp, log_p, cell_info_lp = load_logprob_by_density(args.model, args.context, ctype)
        if len(x_lp) >= 3:
            lin = test_logprob_linearity(x_lp, log_p)
            print_logprob_report(args.model, x_lp, log_p, cell_info_lp, lin, context_label)
        else:
            print(f"Not enough logprob data yet ({len(x_lp)} levels). Run more trials first.")
    except FileNotFoundError as e:
        print(f"No logprob data: {e}")

    # ── 2. Binary accuracy function form (secondary) ──
    try:
        x, y, cell_info = load_accuracy_by_density(args.model, args.context, ctype)
        if len(x) >= 4:
            print(f"\n\nLoaded {sum(c['n'] for c in cell_info.values())} trials for binary accuracy fit.")
            fit_results = fit_all_models(x, y)
            print_report(args.model, x, y, cell_info, fit_results, context_label)
            save_results(args.model, context_label, fit_results, x, y)
            if args.plot or args.save_plot:
                title = f"Exp.37 Function Form — {args.model} ({context_label})"
                save_path = Path(args.save_plot) if args.save_plot else None
                plot_fits(x, y, fit_results, title, save_path)
    except FileNotFoundError as e:
        print(f"No accuracy data: {e}")


if __name__ == "__main__":
    main()
