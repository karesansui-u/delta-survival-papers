#!/usr/bin/env python3
"""
Phase 2C 追加分析: ソルバー横断の普遍曲線検証

問い: S_solve(μ/μ_c) は CDCL と WalkSAT で同じ曲線に乗るか？
μ_c（中央値ランタイム）で正規化すれば、αもソルバーも関係なく
同じ survival function に従うか検証する。
"""

import json
import math
import numpy as np
from pathlib import Path

# Load Phase 2C results
results_dir = Path(__file__).parent.parent / "results"
with open(results_dir / "phase2c_solver_comparison_20260308_035525.json") as f:
    data = json.load(f)

N = data["config"]["N"]
I = data["config"]["I_per_clause"]

print("=" * 70)
print("Phase 2C: Universal Curve Analysis")
print("S_solve(μ/μ_c) across solvers and α values")
print("=" * 70)

# Collect (mu/mu_c, P_found) for each solver
curves = {}

for solver_name in ["cdcl", "walksat"]:
    solver_data = data["solver_results"][solver_name]
    points = []  # (mu_ratio, p_found, alpha)

    for alpha_str, d in sorted(solver_data.items()):
        alpha = float(alpha_str)
        mu_c = d["med_runtime"]
        if mu_c <= 0:
            continue

        for budget_str, p_found in d["budget_p"].items():
            budget = float(budget_str)
            mu_ratio = budget / mu_c
            points.append((mu_ratio, p_found, alpha))

    curves[solver_name] = points

# Print raw data
for solver_name, points in curves.items():
    print(f"\n--- {solver_name.upper()} ---")
    print(f"  {'α':>5}  {'μ':>10}  {'μ_c':>10}  {'μ/μ_c':>10}  {'P(found)':>10}")
    solver_data = data["solver_results"][solver_name]
    for alpha_str, d in sorted(solver_data.items()):
        alpha = float(alpha_str)
        mu_c = d["med_runtime"]
        for budget_str, p_found in sorted(d["budget_p"].items(), key=lambda x: float(x[0])):
            budget = float(budget_str)
            mu_ratio = budget / mu_c
            print(f"  {alpha:5.2f}  {budget:10.0f}  {mu_c:10.1f}  {mu_ratio:10.2f}  {p_found:10.4f}")

# Universal curve test: bin by log(μ/μ_c) and compare P(found) across solvers
print(f"\n{'=' * 70}")
print("Universal Curve: Binned comparison")
print(f"{'=' * 70}")

# Collect all points excluding α=4.2 (survivor bias)
all_points = {}
for solver_name, points in curves.items():
    clean = [(r, p, a) for r, p, a in points if a <= 4.0]
    all_points[solver_name] = clean

# Define log-ratio bins
log_bins = [(-2, -0.5), (-0.5, 0.0), (0.0, 0.5), (0.5, 1.5), (1.5, 3.0), (3.0, 5.0)]

print(f"\n  {'log(μ/μ_c)':>15}  {'CDCL P':>10}  {'n_cdcl':>7}  {'WalkSAT P':>10}  {'n_ws':>7}  {'ΔP':>8}")
print(f"  {'-'*15}  {'-'*10}  {'-'*7}  {'-'*10}  {'-'*7}  {'-'*8}")

for lo, hi in log_bins:
    cdcl_ps = [p for r, p, a in all_points.get("cdcl", [])
               if lo <= math.log10(r) < hi and r > 0]
    ws_ps = [p for r, p, a in all_points.get("walksat", [])
             if lo <= math.log10(r) < hi and r > 0]

    if cdcl_ps or ws_ps:
        cdcl_mean = np.mean(cdcl_ps) if cdcl_ps else float('nan')
        ws_mean = np.mean(ws_ps) if ws_ps else float('nan')
        delta_p = cdcl_mean - ws_mean if cdcl_ps and ws_ps else float('nan')
        print(f"  [{lo:+.1f}, {hi:+.1f})  {cdcl_mean:10.3f}  {len(cdcl_ps):7d}  {ws_mean:10.3f}  {len(ws_ps):7d}  {delta_p:+8.3f}")

# More detailed: for each budget point, compute μ/μ_c and compare
print(f"\n{'=' * 70}")
print("Point-by-point: Same α, different solver")
print(f"{'=' * 70}")

alphas_common = sorted(set(data["solver_results"]["cdcl"].keys()) &
                       set(data["solver_results"]["walksat"].keys()))

print(f"\n  {'α':>5}  {'CDCL μ_c':>10}  {'WS μ_c':>10}  CDCL budget_p → WS budget_p at similar μ/μ_c")

for alpha_str in alphas_common:
    alpha = float(alpha_str)
    if alpha > 4.0:
        continue

    cdcl_d = data["solver_results"]["cdcl"][alpha_str]
    ws_d = data["solver_results"]["walksat"][alpha_str]

    cdcl_mc = cdcl_d["med_runtime"]
    ws_mc = ws_d["med_runtime"]

    print(f"\n  α={alpha:.2f}  CDCL μ_c={cdcl_mc:.0f}  WalkSAT μ_c={ws_mc:.0f}")

    # For each CDCL budget, find closest WalkSAT μ/μ_c
    for cb_str, cp in sorted(cdcl_d["budget_p"].items(), key=lambda x: float(x[0])):
        cb = float(cb_str)
        cdcl_ratio = cb / cdcl_mc

        # Find WalkSAT budget with closest μ/μ_c ratio
        best_ws = None
        best_dist = float('inf')
        for wb_str, wp in ws_d["budget_p"].items():
            wb = float(wb_str)
            ws_ratio = wb / ws_mc
            dist = abs(math.log(ws_ratio / cdcl_ratio)) if cdcl_ratio > 0 and ws_ratio > 0 else float('inf')
            if dist < best_dist:
                best_dist = dist
                best_ws = (wb, ws_ratio, wp)

        if best_ws:
            wb, ws_ratio, wp = best_ws
            print(f"    CDCL: μ/μ_c={cdcl_ratio:8.2f} → P={cp:.3f}  |  "
                  f"WalkSAT: μ/μ_c={ws_ratio:8.2f} → P={wp:.3f}  |  "
                  f"ΔP={cp-wp:+.3f}")

# Sigmoid fit to combined data
print(f"\n{'=' * 70}")
print("Sigmoid fit: P = 1 / (1 + exp(-k*(log(μ/μ_c) - x0)))")
print(f"{'=' * 70}")

from scipy.optimize import curve_fit

def sigmoid(log_ratio, k, x0):
    return 1.0 / (1.0 + np.exp(-k * (log_ratio - x0)))

for solver_name in ["cdcl", "walksat", "combined"]:
    if solver_name == "combined":
        pts = all_points.get("cdcl", []) + all_points.get("walksat", [])
    else:
        pts = all_points.get(solver_name, [])

    # Filter: only points where 0 < P < 1 contribute to shape, include boundary points
    log_ratios = []
    p_founds = []
    for r, p, a in pts:
        if r > 0:
            log_ratios.append(math.log(r))
            p_founds.append(p)

    if len(log_ratios) < 3:
        continue

    x = np.array(log_ratios)
    y = np.array(p_founds)

    try:
        popt, pcov = curve_fit(sigmoid, x, y, p0=[2.0, 0.0], maxfev=10000)
        k_fit, x0_fit = popt
        y_pred = sigmoid(x, k_fit, x0_fit)
        ss_res = np.sum((y - y_pred) ** 2)
        ss_tot = np.sum((y - np.mean(y)) ** 2)
        r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 0
        print(f"  {solver_name:>10}: k={k_fit:.3f}, x0={x0_fit:.3f}, R²={r2:.4f} (n={len(x)})")
    except Exception as e:
        print(f"  {solver_name:>10}: fit failed: {e}")

# Test: does combined fit improve or worsen compared to separate fits?
print(f"\n{'=' * 70}")
print("Key question: Do CDCL and WalkSAT follow the SAME universal curve?")
print(f"{'=' * 70}")

# Compute residuals of each solver against the combined fit
try:
    all_pts = all_points.get("cdcl", []) + all_points.get("walksat", [])
    all_x = np.array([math.log(r) for r, p, a in all_pts if r > 0])
    all_y = np.array([p for r, p, a in all_pts if r > 0])
    popt_combined, _ = curve_fit(sigmoid, all_x, all_y, p0=[2.0, 0.0], maxfev=10000)

    for solver_name in ["cdcl", "walksat"]:
        pts = all_points.get(solver_name, [])
        x = np.array([math.log(r) for r, p, a in pts if r > 0])
        y = np.array([p for r, p, a in pts if r > 0])

        # Residuals against combined fit
        y_pred = sigmoid(x, *popt_combined)
        rmse = np.sqrt(np.mean((y - y_pred) ** 2))
        max_resid = np.max(np.abs(y - y_pred))

        # Residuals against own fit
        popt_own, _ = curve_fit(sigmoid, x, y, p0=[2.0, 0.0], maxfev=10000)
        y_pred_own = sigmoid(x, *popt_own)
        rmse_own = np.sqrt(np.mean((y - y_pred_own) ** 2))

        print(f"  {solver_name:>10}: RMSE(combined)={rmse:.4f}, RMSE(own)={rmse_own:.4f}, "
              f"max|resid|={max_resid:.4f}")

    print(f"\n  Combined fit: k={popt_combined[0]:.3f}, x0={popt_combined[1]:.3f}")
    print(f"  If RMSE(combined) ≈ RMSE(own) for both → universal curve is supported")

except Exception as e:
    print(f"  Analysis failed: {e}")

print(f"\nDone.")
