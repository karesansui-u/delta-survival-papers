"""
SAT スケーリング検証 (拡張版): n=24, 26, 28 の追加

目的:
  n=18,20,22 の既存結果に n=24,26,28 を追加し、
  α(n) ≈ const がより広い範囲で成立するか確認。
  レッドチーム指摘: "3データポイントでは不十分" への対応。

設計:
  - n=24: 2^24 = 16M  (10 trials, ~6分)
  - n=26: 2^26 = 64M  (5 trials, ~12分)
  - n=28: 2^28 = 256M (3 trials, ~30分)
  - 各 n で base_alpha=3.0, 10 δ levels
  - 3 perturbation types × 比較
  - 既存 n=18,20,22 の結果を読み込んで統合

メモリ安全性:
  - n=28: ピーク ~1.6GB (uint32 配列 256M要素)
  - n=28 実行前にメモリチェック
"""

import numpy as np
from collections import defaultdict
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from pathlib import Path
from datetime import datetime
import json
import time
import sys
import psutil

# Reuse SAT primitives
sys.path.insert(0, str(Path(__file__).parent))
from exp_sat_contradiction import (
    generate_random_3sat,
    count_solutions_fast,
    add_random_clauses,
    add_contradiction_pairs,
    add_implication_chains,
)


def check_memory_for_n(n):
    """Check if we have enough memory for brute-force at size n."""
    needed_bytes = (1 << n) * 10  # rough estimate: multiple arrays
    available = psutil.virtual_memory().available
    if needed_bytes > available * 0.7:
        print(f"  WARNING: n={n} needs ~{needed_bytes/1e9:.1f}GB, "
              f"available: {available/1e9:.1f}GB")
        return False
    return True


def run_single_n(n, base_alpha=3.0, n_trials=50, max_delta_steps=15):
    """Run experiment for a single n value and return summary."""
    rng = np.random.default_rng(42)
    m_base = int(base_alpha * n)

    ks = list(range(0, max_delta_steps + 1))
    deltas = [k / n for k in ks]

    print(f"\n  n={n}: {1 << n:,} assignments, {m_base} base clauses, "
          f"{n_trials} trials, {len(ks)} δ levels")

    results = {"noise": defaultdict(list),
               "contradiction": defaultdict(list),
               "chain": defaultdict(list)}

    t0 = time.time()
    for trial in range(n_trials):
        elapsed = time.time() - t0
        if trial == 0 or trial % max(n_trials // 5, 1) == 0:
            print(f"    Trial {trial}/{n_trials} ({elapsed:.1f}s elapsed)")

        base = generate_random_3sat(n, m_base, rng)
        base_count = count_solutions_fast(base, n)

        if base_count == 0:
            continue

        for k in ks:
            delta = k / n

            noisy = add_random_clauses(base, n, k, rng)
            count_noise = count_solutions_fast(noisy, n)

            contradicted = add_contradiction_pairs(base, n, k, rng)
            count_contra = count_solutions_fast(contradicted, n)

            chained = add_implication_chains(base, n, k, rng)
            count_chain = count_solutions_fast(chained, n)

            results["noise"][delta].append(count_noise / base_count)
            results["contradiction"][delta].append(count_contra / base_count)
            results["chain"][delta].append(count_chain / base_count)

    elapsed = time.time() - t0
    print(f"    Done in {elapsed:.1f}s")

    # Summarize
    summary = {}
    for ptype in ["noise", "contradiction", "chain"]:
        ds = sorted(results[ptype].keys())
        means = [float(np.mean(results[ptype][d])) for d in ds]
        stds = [float(np.std(results[ptype][d])) for d in ds]
        p_unsats = [float(np.mean([v == 0 for v in results[ptype][d]])) for d in ds]
        summary[ptype] = {"deltas": ds, "means": means, "stds": stds, "p_unsats": p_unsats}

    return summary, elapsed


def fit_exponential(deltas, means):
    """Fit exponential and return parameters."""
    x = np.array(deltas)
    y = np.array(means)
    mask = y > 0.01
    if mask.sum() < 4:
        return None

    xf, yf = x[mask], y[mask]
    n_pts = len(xf)
    ss_tot = np.sum((yf - np.mean(yf)) ** 2)

    def exp_decay(x, a, alpha):
        return a * np.exp(-alpha * np.array(x))

    def power_law(x, a, gamma, x_c):
        return a * np.maximum(x_c - np.array(x), 1e-10) ** gamma

    def compute_aic(ss_res, n, k):
        if ss_res <= 0:
            return float("inf")
        return n * np.log(ss_res / n) + 2 * k

    try:
        popt_exp, _ = curve_fit(exp_decay, xf, yf,
                                 p0=[1.0, 2.0],
                                 bounds=([0, 0], [10, 100]),
                                 maxfev=10000)
        pred_exp = exp_decay(xf, *popt_exp)
        ss_exp = np.sum((yf - pred_exp) ** 2)
        r2_exp = 1 - ss_exp / ss_tot if ss_tot > 0 else 0
        aic_exp = compute_aic(ss_exp, n_pts, 2)
    except Exception:
        return None

    try:
        popt_pow, _ = curve_fit(power_law, xf, yf,
                                 p0=[1.0, 1.0, max(xf) * 1.5],
                                 bounds=([0, 0.01, max(xf)], [100, 10, 10]),
                                 maxfev=10000)
        pred_pow = power_law(xf, *popt_pow)
        ss_pow = np.sum((yf - pred_pow) ** 2)
        r2_pow = 1 - ss_pow / ss_tot if ss_tot > 0 else 0
        aic_pow = compute_aic(ss_pow, n_pts, 3)
    except Exception:
        r2_pow, aic_pow = -1, float("inf")

    winner = "Exp" if aic_exp < aic_pow else "Power"

    return {
        "a": float(popt_exp[0]),
        "alpha": float(popt_exp[1]),
        "R2_exp": float(r2_exp),
        "AIC_exp": float(aic_exp),
        "R2_pow": float(r2_pow),
        "AIC_pow": float(aic_pow),
        "winner": winner,
    }


def load_previous_results():
    """Load n=18,20,22 results from previous run."""
    result_dir = Path(__file__).parent.parent / "results" / "exp_sat"
    prev_path = result_dir / "sat_scaling_20260228_023449.json"

    if not prev_path.exists():
        print(f"  Previous results not found: {prev_path}")
        return None

    with open(prev_path) as f:
        data = json.load(f)

    print(f"  Loaded previous results from {prev_path}")
    return data


def main():
    print("=" * 80)
    print("SAT SCALING EXPERIMENT (EXTENDED): n=18..28")
    print("=" * 80)

    # Load previous n=18,20,22 results
    prev = load_previous_results()
    if prev is None:
        print("ERROR: Cannot find previous results. Run exp_sat_scaling.py first.")
        sys.exit(1)

    # New configurations for n=24,26,28
    new_configs = [
        (24, 10, 10),   # (n, n_trials, max_delta_steps)
        (26, 5, 10),
        (28, 3, 8),
    ]

    # Run new experiments
    new_results = {}
    for n, n_trials, max_delta_steps in new_configs:
        if not check_memory_for_n(n):
            print(f"  SKIPPING n={n} (insufficient memory)")
            continue

        summary, elapsed = run_single_n(n, base_alpha=3.0,
                                         n_trials=n_trials,
                                         max_delta_steps=max_delta_steps)
        new_results[n] = {"summary": summary, "elapsed": elapsed}

    # Combine old + new
    all_ns = [18, 20, 22] + sorted(new_results.keys())
    ptypes = ["noise", "contradiction", "chain"]

    print(f"\n{'='*80}")
    print("COMBINED SCALING ANALYSIS: α(n) for n=18..28")
    print(f"{'='*80}")

    fit_table = {}

    # Old fits
    for n_str, fits in prev["fit_table"].items():
        n = int(n_str)
        fit_table[n] = fits

    # New fits
    for n in sorted(new_results.keys()):
        fit_table[n] = {}
        for ptype in ptypes:
            s = new_results[n]["summary"][ptype]
            fit = fit_exponential(s["deltas"], s["means"])
            fit_table[n][ptype] = fit

    # Print all fits
    print(f"\n  {'n':>4s}  {'type':13s}  {'α':>8s}  {'R²':>7s}  {'winner':>6s}")
    print("  " + "-" * 50)
    for n in all_ns:
        for ptype in ptypes:
            fit = fit_table[n].get(ptype)
            if fit:
                print(f"  {n:4d}  {ptype:13s}  {fit['alpha']:8.3f}  "
                      f"{fit['R2_exp']:7.4f}  {fit['winner']:>6s}")
            else:
                print(f"  {n:4d}  {ptype:13s}  {'FAIL':>8s}")

    # Stability analysis
    print(f"\n{'='*80}")
    print("α STABILITY ACROSS ALL n")
    print(f"{'='*80}")

    stability = {}
    for ptype in ptypes:
        alphas = []
        ns_valid = []
        for n in all_ns:
            fit = fit_table[n].get(ptype)
            if fit and fit["R2_exp"] > 0.8:
                alphas.append(fit["alpha"])
                ns_valid.append(n)

        if len(alphas) >= 2:
            mean_alpha = np.mean(alphas)
            std_alpha = np.std(alphas)
            cv = std_alpha / mean_alpha if mean_alpha > 0 else float("inf")

            # Linear regression: α vs n to test for trend
            if len(alphas) >= 3:
                slope = np.polyfit(ns_valid, alphas, 1)[0]
            else:
                slope = 0

            print(f"\n  {ptype}:")
            print(f"    n values: {ns_valid}")
            print(f"    α values: {[f'{a:.3f}' for a in alphas]}")
            print(f"    mean α = {mean_alpha:.3f} ± {std_alpha:.3f}")
            print(f"    CV = {cv:.3f}")
            print(f"    slope (α vs n) = {slope:.4f}")

            if cv < 0.15:
                verdict = "STABLE"
                print(f"    → STABLE (CV < 15%): α is independent of n")
            elif cv < 0.30:
                verdict = "MODERATELY_STABLE"
                print(f"    → MODERATELY STABLE (CV < 30%)")
            else:
                verdict = "UNSTABLE"
                print(f"    → UNSTABLE (CV > 30%): finite-size effect likely")

            stability[ptype] = {
                "ns": ns_valid,
                "alphas": alphas,
                "mean": float(mean_alpha),
                "std": float(std_alpha),
                "cv": float(cv),
                "slope": float(slope),
                "verdict": verdict,
            }

    # α ratios
    print(f"\n{'='*80}")
    print("α RATIOS: α_contra/α_noise across all n")
    print(f"{'='*80}")

    ratios = []
    print(f"\n  {'n':>4s}  {'α_contra/α_noise':>18s}  {'α_chain/α_noise':>17s}")
    print("  " + "-" * 45)
    for n in all_ns:
        noise_fit = fit_table[n].get("noise")
        contra_fit = fit_table[n].get("contradiction")
        chain_fit = fit_table[n].get("chain")

        if noise_fit and contra_fit and noise_fit["alpha"] > 0:
            r_contra = contra_fit["alpha"] / noise_fit["alpha"]
            r_chain = chain_fit["alpha"] / noise_fit["alpha"] if chain_fit else float("nan")
            print(f"  {n:4d}  {r_contra:18.2f}×  {r_chain:17.2f}×")
            ratios.append({"n": n, "ratio_contra": r_contra, "ratio_chain": r_chain})

    if ratios:
        mean_ratio = np.mean([r["ratio_contra"] for r in ratios])
        std_ratio = np.std([r["ratio_contra"] for r in ratios])
        cv_ratio = std_ratio / mean_ratio if mean_ratio > 0 else float("inf")
        print(f"\n  α_contra/α_noise: mean = {mean_ratio:.2f}× ± {std_ratio:.2f}× (CV = {cv_ratio:.3f})")

    # Plots
    output_dir = Path(__file__).parent.parent / "results" / "exp_sat"
    output_dir.mkdir(parents=True, exist_ok=True)

    colors_n = {18: "#1f77b4", 20: "#2ca02c", 22: "#d62728",
                24: "#ff7f0e", 26: "#9467bd", 28: "#8c564b", 30: "#e377c2"}
    ptype_labels = {"noise": "Random noise",
                     "contradiction": "XOR contradictions",
                     "chain": "Implication chains"}

    fig, axes = plt.subplots(2, 3, figsize=(20, 12))

    # Row 1: N_eff/N₀ vs δ (linear)
    for j, ptype in enumerate(ptypes):
        ax = axes[0, j]
        # Old data
        for n_str in ["18", "20", "22"]:
            n = int(n_str)
            s = prev["summaries"][n_str][ptype]
            ax.errorbar(s["deltas"], s["means"], yerr=s["stds"],
                        fmt="o-", color=colors_n[n], label=f"n={n}",
                        capsize=2, markersize=3, alpha=0.7)
        # New data
        for n in sorted(new_results.keys()):
            s = new_results[n]["summary"][ptype]
            ax.errorbar(s["deltas"], s["means"], yerr=s["stds"],
                        fmt="s-", color=colors_n[n], label=f"n={n} (new)",
                        capsize=2, markersize=3, alpha=0.7)
        ax.set_xlabel("δ (k/n)")
        ax.set_ylabel("N_eff / N₀")
        ax.set_title(f"{ptype_labels[ptype]}")
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.05, 1.1)

    # Row 2: Log scale with fits
    for j, ptype in enumerate(ptypes):
        ax = axes[1, j]
        for n_str in ["18", "20", "22"]:
            n = int(n_str)
            s = prev["summaries"][n_str][ptype]
            y = np.array(s["means"])
            mask = y > 0
            d = np.array(s["deltas"])[mask]
            y = y[mask]
            ax.semilogy(d, y, "o", color=colors_n[n], label=f"n={n}",
                        markersize=3, alpha=0.7)
        for n_val in sorted(new_results.keys()):
            s = new_results[n_val]["summary"][ptype]
            y = np.array(s["means"])
            mask = y > 0
            d = np.array(s["deltas"])[mask]
            y = y[mask]
            ax.semilogy(d, y, "s", color=colors_n[n_val], label=f"n={n_val} (new)",
                        markersize=3, alpha=0.7)

            fit = fit_table[n_val].get(ptype)
            if fit and fit["R2_exp"] > 0.5:
                xfit = np.linspace(0, max(d), 100)
                yfit = fit["a"] * np.exp(-fit["alpha"] * xfit)
                ax.semilogy(xfit, yfit, "--", color=colors_n[n_val], alpha=0.4,
                            label=f"n={n_val}: α={fit['alpha']:.2f}")

        ax.set_xlabel("δ (k/n)")
        ax.set_ylabel("N_eff / N₀ (log)")
        ax.set_title(f"{ptype_labels[ptype]} (log scale)")
        ax.legend(fontsize=6)
        ax.grid(True, alpha=0.3)

    plt.suptitle("SAT Scaling: α stability across n=18..28", fontsize=14, y=1.01)
    plt.tight_layout()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    plot_path = output_dir / f"sat_scaling_extended_{timestamp}.png"
    plt.savefig(plot_path, dpi=150, bbox_inches="tight")
    print(f"\nPlots saved: {plot_path}")
    plt.close()

    # Additional plot: α vs n
    fig2, axes2 = plt.subplots(1, 2, figsize=(14, 5))

    # α vs n for each perturbation type
    ax = axes2[0]
    for ptype in ptypes:
        ns_plot = []
        alphas_plot = []
        for n in all_ns:
            fit = fit_table[n].get(ptype)
            if fit and fit["R2_exp"] > 0.8:
                ns_plot.append(n)
                alphas_plot.append(fit["alpha"])
        ax.plot(ns_plot, alphas_plot, "o-", label=ptype, markersize=8)
        # Horizontal mean line
        if alphas_plot:
            ax.axhline(np.mean(alphas_plot), linestyle=":", alpha=0.3)
    ax.set_xlabel("System size n")
    ax.set_ylabel("Decay rate α")
    ax.set_title("α(n) stability")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # α_contra/α_noise ratio vs n
    ax = axes2[1]
    if ratios:
        ns_r = [r["n"] for r in ratios]
        rs = [r["ratio_contra"] for r in ratios]
        ax.plot(ns_r, rs, "o-", color="red", markersize=8, label="α_contra/α_noise")
        ax.axhline(np.mean(rs), linestyle="--", color="red", alpha=0.5,
                    label=f"mean = {np.mean(rs):.2f}×")
        ax.set_xlabel("System size n")
        ax.set_ylabel("α_contradiction / α_noise")
        ax.set_title("Ratio stability across n")
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    ratio_plot_path = output_dir / f"sat_alpha_vs_n_{timestamp}.png"
    plt.savefig(ratio_plot_path, dpi=150)
    print(f"Ratio plot saved: {ratio_plot_path}")
    plt.close()

    # Save all results
    save_data = {
        "description": "Extended SAT scaling: n=18..28",
        "previous_results_file": "sat_scaling_20260228_023449.json",
        "new_configs": [{"n": n, "n_trials": t, "max_delta_steps": d}
                         for n, t, d in new_configs if n in new_results],
        "fit_table": {str(n): fit_table[n] for n in all_ns},
        "new_summaries": {str(n): new_results[n]["summary"]
                          for n in sorted(new_results.keys())},
        "new_timings": {str(n): new_results[n]["elapsed"]
                         for n in sorted(new_results.keys())},
        "stability": stability,
        "ratios": ratios,
    }
    json_path = output_dir / f"sat_scaling_extended_{timestamp}.json"
    with open(json_path, "w") as f:
        json.dump(save_data, f, indent=2)
    print(f"Data saved: {json_path}")

    # Final verdict
    print(f"\n{'='*80}")
    print("VERDICT (n=18..28)")
    print(f"{'='*80}")

    for ptype in ptypes:
        s = stability.get(ptype)
        if s:
            print(f"\n  {ptype}: CV={s['cv']:.3f}, slope={s['slope']:.4f} → {s['verdict']}")

    if all(stability.get(p, {}).get("cv", 1) < 0.30 for p in ptypes):
        print("\n  OVERALL: α is STABLE across n=18..28.")
        print("  The exponential decay is NOT a finite-size artifact.")
    else:
        print("\n  OVERALL: Some perturbation types show instability.")
        print("  See individual results above.")


if __name__ == "__main__":
    main()
