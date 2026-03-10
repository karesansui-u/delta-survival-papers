#!/usr/bin/env python3
"""
Phase 2C追加: モデル比較分析

既存の遷移領域データに対して3つのCDFモデルをフィットし、
k差14%が「異なる関数形を同じモデルに押し込んだアーティファクト」かを検証。

モデル:
  1. Sigmoid (logistic CDF): P = 1/(1 + exp(-k*(ln(μ/μ_c) - x0)))
  2. Exponential CDF: P = 1 - exp(-λ * μ/μ_c)
  3. Weibull CDF: P = 1 - exp(-(μ/μ_c / η)^β)

各ソルバーで最良モデルが異なるか → k比較の意味を再評価
"""

import json
import math
import numpy as np
from pathlib import Path
from scipy.optimize import curve_fit
from scipy.special import gamma

results_dir = Path(__file__).parent.parent / "results"
with open(results_dir / "phase2c_transition_zone_20260308_132431.json") as f:
    data = json.load(f)

print("=" * 70)
print("Phase 2C: Model Comparison (Sigmoid vs Exponential vs Weibull)")
print("=" * 70)

# Collect data points
def collect_points(solver_key):
    solver_data = data[f"{solver_key}_results"]
    points = []
    for alpha_str, d in solver_data.items():
        mu_c = d["mu_c"]
        for budget_str, p in d["budget_p"].items():
            budget = float(budget_str)
            ratio = budget / mu_c
            if ratio > 0:
                points.append((ratio, math.log(ratio), p, float(alpha_str)))
    return points

# Models
def sigmoid(log_ratio, k, x0):
    return 1.0 / (1.0 + np.exp(-k * (log_ratio - x0)))

def exp_cdf(ratio, lam):
    return 1.0 - np.exp(-lam * ratio)

def weibull_cdf(ratio, eta, beta):
    return 1.0 - np.exp(-((ratio / eta) ** beta))

# Per-alpha analysis
for solver_name in ["cdcl", "walksat"]:
    points = collect_points(solver_name)
    print(f"\n{'=' * 60}")
    print(f"  {solver_name.upper()}")
    print(f"{'=' * 60}")

    # Overall fit
    ratios = np.array([p[0] for p in points])
    log_ratios = np.array([p[1] for p in points])
    p_found = np.array([p[2] for p in points])

    # Filter out exact 0 and 1 for better fitting (keep for evaluation)
    mask = (p_found > 0.001) & (p_found < 0.999)

    print(f"\n  Total points: {len(points)}, transition zone (0<P<1): {mask.sum()}")

    # 1. Sigmoid
    try:
        popt_s, _ = curve_fit(sigmoid, log_ratios, p_found, p0=[2.0, 0.0], maxfev=10000)
        y_pred_s = sigmoid(log_ratios, *popt_s)
        ss_res = np.sum((p_found - y_pred_s) ** 2)
        ss_tot = np.sum((p_found - np.mean(p_found)) ** 2)
        r2_s = 1 - ss_res / ss_tot
        rmse_s = np.sqrt(np.mean((p_found - y_pred_s) ** 2))
        aic_s = len(p_found) * np.log(np.mean((p_found - y_pred_s) ** 2)) + 2 * 2
        print(f"\n  Sigmoid:  k={popt_s[0]:.3f}, x0={popt_s[1]:.3f}")
        print(f"            R²={r2_s:.4f}, RMSE={rmse_s:.4f}, AIC={aic_s:.1f}")
    except Exception as e:
        print(f"  Sigmoid fit failed: {e}")
        popt_s = None

    # 2. Exponential CDF
    try:
        # Constraint: P(μ_c) = 0.5 → λ = ln(2) ≈ 0.693
        # But fit freely first
        popt_e, _ = curve_fit(exp_cdf, ratios, p_found, p0=[0.7], maxfev=10000,
                              bounds=(0.01, 10.0))
        y_pred_e = exp_cdf(ratios, *popt_e)
        ss_res = np.sum((p_found - y_pred_e) ** 2)
        r2_e = 1 - ss_res / ss_tot
        rmse_e = np.sqrt(np.mean((p_found - y_pred_e) ** 2))
        aic_e = len(p_found) * np.log(np.mean((p_found - y_pred_e) ** 2)) + 2 * 1
        print(f"\n  Exp CDF:  λ={popt_e[0]:.3f} (ln2={math.log(2):.3f})")
        print(f"            R²={r2_e:.4f}, RMSE={rmse_e:.4f}, AIC={aic_e:.1f}")
    except Exception as e:
        print(f"  Exp CDF fit failed: {e}")
        popt_e = None

    # 3. Weibull CDF
    try:
        popt_w, _ = curve_fit(weibull_cdf, ratios, p_found, p0=[1.0, 1.0], maxfev=10000,
                              bounds=([0.01, 0.1], [100.0, 10.0]))
        y_pred_w = weibull_cdf(ratios, *popt_w)
        ss_res = np.sum((p_found - y_pred_w) ** 2)
        r2_w = 1 - ss_res / ss_tot
        rmse_w = np.sqrt(np.mean((p_found - y_pred_w) ** 2))
        aic_w = len(p_found) * np.log(np.mean((p_found - y_pred_w) ** 2)) + 2 * 2
        # Weibull median: η * (ln2)^{1/β}
        weibull_median = popt_w[0] * (math.log(2)) ** (1.0 / popt_w[1])
        print(f"\n  Weibull:  η={popt_w[0]:.3f}, β={popt_w[1]:.3f} (median ratio={weibull_median:.3f})")
        print(f"            R²={r2_w:.4f}, RMSE={rmse_w:.4f}, AIC={aic_w:.1f}")
    except Exception as e:
        print(f"  Weibull fit failed: {e}")
        popt_w = None

    # Summary
    print(f"\n  Model ranking by AIC:")
    models = []
    if popt_s is not None:
        models.append(("Sigmoid", aic_s, rmse_s, r2_s))
    if popt_e is not None:
        models.append(("Exp CDF", aic_e, rmse_e, r2_e))
    if popt_w is not None:
        models.append(("Weibull", aic_w, rmse_w, r2_w))
    models.sort(key=lambda x: x[1])
    for rank, (name, aic, rmse, r2) in enumerate(models, 1):
        delta_aic = aic - models[0][1]
        print(f"    {rank}. {name:>10}: AIC={aic:.1f} (ΔAIC={delta_aic:+.1f}), R²={r2:.4f}")

    # Per-alpha breakdown
    print(f"\n  Per-alpha RMSE:")
    alphas = sorted(set(p[3] for p in points))
    print(f"  {'α':>6}  {'Sigmoid':>10}  {'Exp CDF':>10}  {'Weibull':>10}  {'n':>5}  {'Best':>10}")
    for alpha in alphas:
        ap = [(r, lr, p, a) for r, lr, p, a in points if a == alpha]
        ar = np.array([p[0] for p in ap])
        alr = np.array([p[1] for p in ap])
        ay = np.array([p[2] for p in ap])

        rmses = {}
        if popt_s is not None:
            rmses["Sigmoid"] = np.sqrt(np.mean((ay - sigmoid(alr, *popt_s)) ** 2))
        if popt_e is not None:
            rmses["Exp CDF"] = np.sqrt(np.mean((ay - exp_cdf(ar, *popt_e)) ** 2))
        if popt_w is not None:
            rmses["Weibull"] = np.sqrt(np.mean((ay - weibull_cdf(ar, *popt_w)) ** 2))

        best = min(rmses, key=rmses.get) if rmses else "N/A"
        print(f"  {alpha:6.2f}  {rmses.get('Sigmoid', float('nan')):10.4f}  "
              f"{rmses.get('Exp CDF', float('nan')):10.4f}  "
              f"{rmses.get('Weibull', float('nan')):10.4f}  {len(ap):5d}  {best:>10}")

# Cross-solver Weibull comparison
print(f"\n{'=' * 70}")
print("Cross-solver Weibull comparison")
print("If both fit Weibull well, compare β (shape) instead of k")
print(f"{'=' * 70}")

for solver_name in ["cdcl", "walksat"]:
    points = collect_points(solver_name)
    ratios = np.array([p[0] for p in points])
    p_found = np.array([p[2] for p in points])
    try:
        popt, _ = curve_fit(weibull_cdf, ratios, p_found, p0=[1.0, 1.0], maxfev=10000,
                            bounds=([0.01, 0.1], [100.0, 10.0]))
        median = popt[0] * (math.log(2)) ** (1.0 / popt[1])
        print(f"  {solver_name:>10}: η={popt[0]:.3f}, β={popt[1]:.3f}, median={median:.3f}")
    except Exception as e:
        print(f"  {solver_name:>10}: fit failed: {e}")

print(f"\nDone.")
