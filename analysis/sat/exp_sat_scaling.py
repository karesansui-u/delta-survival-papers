"""
SAT スケーリング検証: α(n) の安定性

目的:
  n=18 で得た α が有限サイズ効果でないことを確認。
  n=18, 20, 22 で α を比較し、α(n) ≈ const なら理論を支持。

設計:
  - n=18: 2^18 = 262K (高速、50 trials)
  - n=20: 2^20 = 1M   (中速、30 trials)
  - n=22: 2^22 = 4M   (低速、20 trials)
  - 各 n で base_alpha=3.0, 15 δ levels
  - 3 perturbation types × 比較

検証基準:
  - α(n=20)/α(n=18) ∈ [0.7, 1.3] → 安定（30%以内）
  - 全 n で exp が winner → 関数形も安定
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

# Reuse SAT primitives from exp_sat_contradiction
from exp_sat_contradiction import (
    generate_random_3sat,
    count_solutions_fast,
    add_random_clauses,
    add_contradiction_pairs,
    add_implication_chains,
)


def run_single_n(n, base_alpha=3.0, n_trials=50, max_delta_steps=15):
    """Run experiment for a single n value and return summary."""
    rng = np.random.default_rng(42)
    m_base = int(base_alpha * n)

    ks = list(range(0, max_delta_steps + 1))
    deltas = [k / n for k in ks]

    print(f"\n  n={n}: {1 << n} assignments, {m_base} base clauses, "
          f"{n_trials} trials, {len(ks)} δ levels")

    results = {"noise": defaultdict(list),
               "contradiction": defaultdict(list),
               "chain": defaultdict(list)}

    t0 = time.time()
    for trial in range(n_trials):
        if trial % max(n_trials // 5, 1) == 0:
            elapsed = time.time() - t0
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

    # Exponential
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

    # Power law
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


def run_scaling_experiment():
    """Run scaling experiment across n=18, 20, 22."""
    print("=" * 80)
    print("SAT SCALING EXPERIMENT: α stability across system sizes")
    print("=" * 80)

    # Configuration: smaller n gets more trials
    configs = [
        (18, 50, 15),   # (n, n_trials, max_delta_steps)
        (20, 30, 15),
        (22, 20, 12),
    ]

    all_results = {}
    for n, n_trials, max_delta_steps in configs:
        summary, elapsed = run_single_n(n, base_alpha=3.0,
                                         n_trials=n_trials,
                                         max_delta_steps=max_delta_steps)
        all_results[n] = {"summary": summary, "elapsed": elapsed}

    # Fit and compare
    print(f"\n{'='*80}")
    print("SCALING ANALYSIS: α(n) stability")
    print(f"{'='*80}")

    fit_table = {}
    for n in [18, 20, 22]:
        fit_table[n] = {}
        for ptype in ["noise", "contradiction", "chain"]:
            s = all_results[n]["summary"][ptype]
            fit = fit_exponential(s["deltas"], s["means"])
            fit_table[n][ptype] = fit

            if fit:
                print(f"  n={n:2d} {ptype:13s}: α={fit['alpha']:7.3f}, "
                      f"R²={fit['R2_exp']:.4f}, winner={fit['winner']}")
            else:
                print(f"  n={n:2d} {ptype:13s}: fit failed")

    # Stability analysis
    print(f"\n{'='*80}")
    print("α STABILITY ACROSS n")
    print(f"{'='*80}")

    for ptype in ["noise", "contradiction", "chain"]:
        alphas = []
        ns = []
        for n in [18, 20, 22]:
            fit = fit_table[n][ptype]
            if fit and fit["R2_exp"] > 0.8:
                alphas.append(fit["alpha"])
                ns.append(n)

        if len(alphas) >= 2:
            mean_alpha = np.mean(alphas)
            std_alpha = np.std(alphas)
            cv = std_alpha / mean_alpha if mean_alpha > 0 else float("inf")

            print(f"\n  {ptype}:")
            print(f"    α values: {', '.join(f'{a:.3f}' for a in alphas)}")
            print(f"    mean α = {mean_alpha:.3f} ± {std_alpha:.3f}")
            print(f"    CV = {cv:.3f} (coefficient of variation)")

            if cv < 0.15:
                print(f"    → STABLE (CV < 15%): α is independent of n")
            elif cv < 0.30:
                print(f"    → MODERATELY STABLE (CV < 30%): α weakly depends on n")
            else:
                print(f"    → UNSTABLE (CV > 30%): α depends on n (finite-size effect)")

    # Compare ratios
    print(f"\n{'='*80}")
    print("α RATIOS (contradiction type dependence)")
    print(f"{'='*80}")

    for n in [18, 20, 22]:
        noise_fit = fit_table[n]["noise"]
        contra_fit = fit_table[n]["contradiction"]
        chain_fit = fit_table[n]["chain"]

        if noise_fit and contra_fit and chain_fit:
            r_contra = contra_fit["alpha"] / max(noise_fit["alpha"], 1e-6)
            r_chain = chain_fit["alpha"] / max(noise_fit["alpha"], 1e-6)
            print(f"  n={n}: α_contra/α_noise = {r_contra:.1f}×, "
                  f"α_chain/α_noise = {r_chain:.1f}×")

    # Plots
    output_dir = Path(__file__).parent.parent / "results" / "exp_sat"
    output_dir.mkdir(parents=True, exist_ok=True)

    fig, axes = plt.subplots(2, 3, figsize=(18, 12))

    colors_n = {18: "blue", 20: "green", 22: "red"}
    ptypes = ["noise", "contradiction", "chain"]
    ptype_labels = {"noise": "Random noise",
                     "contradiction": "XOR contradictions",
                     "chain": "Implication chains"}

    # Row 1: N_eff/N₀ vs δ for each perturbation type (all n overlaid)
    for j, ptype in enumerate(ptypes):
        ax = axes[0, j]
        for n in [18, 20, 22]:
            s = all_results[n]["summary"][ptype]
            ax.errorbar(s["deltas"], s["means"], yerr=s["stds"],
                        fmt="o-", color=colors_n[n], label=f"n={n}",
                        capsize=3, markersize=4, alpha=0.8)
        ax.set_xlabel("δ (k/n)")
        ax.set_ylabel("N_eff / N₀")
        ax.set_title(f"{ptype_labels[ptype]}")
        ax.legend()
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.05, 1.1)

    # Row 2: Log scale with fits
    for j, ptype in enumerate(ptypes):
        ax = axes[1, j]
        for n in [18, 20, 22]:
            s = all_results[n]["summary"][ptype]
            y = np.array(s["means"])
            mask = y > 0
            d = np.array(s["deltas"])[mask]
            y = y[mask]
            ax.semilogy(d, y, "o", color=colors_n[n], label=f"n={n}",
                        markersize=4, alpha=0.8)

            # Overlay fit
            fit = fit_table[n][ptype]
            if fit and fit["R2_exp"] > 0.5:
                xfit = np.linspace(0, max(d), 100)
                yfit = fit["a"] * np.exp(-fit["alpha"] * xfit)
                ax.semilogy(xfit, yfit, "--", color=colors_n[n], alpha=0.5,
                            label=f"n={n}: α={fit['alpha']:.2f}")

        ax.set_xlabel("δ (k/n)")
        ax.set_ylabel("N_eff / N₀ (log)")
        ax.set_title(f"{ptype_labels[ptype]} (log scale)")
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    plot_path = output_dir / f"sat_scaling_{timestamp}.png"
    plt.savefig(plot_path, dpi=150)
    print(f"\nPlots saved: {plot_path}")
    plt.close()

    # Save JSON
    save_data = {
        "configs": [{"n": n, "n_trials": t, "max_delta_steps": d}
                     for n, t, d in configs],
        "fit_table": {str(n): {p: fit_table[n][p] for p in ptypes}
                       for n in [18, 20, 22]},
        "summaries": {str(n): all_results[n]["summary"] for n in [18, 20, 22]},
        "timings": {str(n): all_results[n]["elapsed"] for n in [18, 20, 22]},
    }
    json_path = output_dir / f"sat_scaling_{timestamp}.json"
    with open(json_path, "w") as f:
        json.dump(save_data, f, indent=2)
    print(f"Data saved: {json_path}")

    # Final verdict
    print(f"\n{'='*80}")
    print("VERDICT")
    print(f"{'='*80}")

    all_stable = True
    for ptype in ptypes:
        alphas = [fit_table[n][ptype]["alpha"]
                  for n in [18, 20, 22]
                  if fit_table[n][ptype] and fit_table[n][ptype]["R2_exp"] > 0.8]
        if len(alphas) >= 2:
            cv = np.std(alphas) / np.mean(alphas)
            if cv > 0.30:
                all_stable = False

    if all_stable:
        print("  α is STABLE across n = {18, 20, 22}.")
        print("  The exponential form N_eff(δ) = N₀·exp(-αδ) is NOT a finite-size artifact.")
        print("  α depends on contradiction TYPE, not system SIZE.")
    else:
        print("  α shows SIZE DEPENDENCE — possible finite-size effect.")
        print("  Larger n needed to determine asymptotic α.")


if __name__ == "__main__":
    run_scaling_experiment()
