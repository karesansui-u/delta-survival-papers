"""
SAT実験: ノイズ vs 構造的矛盾

核心的問い:
  δ = 「ランダムノイズ」と δ = 「構造的矛盾」は系に異なる影響を与えるか？

実験設計:
  Base: 充足可能なランダム3-SAT (n変数, m=α·n節, α < α_c ≈ 4.27)
  摂動A (ノイズ): ランダムな3節を追加
  摂動B (矛盾):  同じ変数に対する矛盾する制約ペアを追加
  測定: #SAT (充足解の数) = N_eff

予測:
  ノイズ → 既知のスケーリング（ランダムk-SATの理論）
  矛盾 → 異なるスケーリング（もしexp(-αδ)なら理論支持）

補足:
  パーコレーションの結果（べき乗則）はノイズに対するN_eff。
  ここでテストするのは矛盾に対するN_eff。これが元の理論の本来のドメイン。
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


# ===================================================================
# SAT primitives
# ===================================================================

def generate_random_3sat(n, m, rng):
    """Generate random 3-SAT formula.
    Returns list of clauses, each clause = list of 3 literals.
    Literal i means x_i is true, -i means x_i is false.
    """
    clauses = []
    for _ in range(m):
        vars_chosen = rng.choice(n, size=3, replace=False) + 1  # 1-indexed
        signs = rng.choice([-1, 1], size=3)
        clause = tuple(int(v * s) for v, s in zip(vars_chosen, signs))
        clauses.append(clause)
    return clauses


def count_solutions_bruteforce(clauses, n):
    """Exact #SAT by brute force. Feasible for n ≤ 22."""
    count = 0
    for assignment_int in range(1 << n):
        satisfied = True
        for clause in clauses:
            clause_sat = False
            for lit in clause:
                var = abs(lit) - 1  # 0-indexed
                val = (assignment_int >> var) & 1
                if (lit > 0 and val == 1) or (lit < 0 and val == 0):
                    clause_sat = True
                    break
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            count += 1
    return count


def count_solutions_fast(clauses, n):
    """Faster #SAT using numpy vectorized evaluation."""
    # Generate all assignments as bit array
    assignments = np.arange(1 << n, dtype=np.uint32)

    # For each clause, compute satisfaction
    all_satisfied = np.ones(1 << n, dtype=bool)

    for clause in clauses:
        clause_sat = np.zeros(1 << n, dtype=bool)
        for lit in clause:
            var = abs(lit) - 1
            bit = (assignments >> var) & 1
            if lit > 0:
                clause_sat |= (bit == 1)
            else:
                clause_sat |= (bit == 0)
        all_satisfied &= clause_sat

    return int(np.sum(all_satisfied))


# ===================================================================
# Perturbation types
# ===================================================================

def add_random_clauses(base_clauses, n, k, rng):
    """Add k random 3-SAT clauses (noise perturbation)."""
    new_clauses = list(base_clauses)
    for _ in range(k):
        vars_chosen = rng.choice(n, size=3, replace=False) + 1
        signs = rng.choice([-1, 1], size=3)
        clause = tuple(int(v * s) for v, s in zip(vars_chosen, signs))
        new_clauses.append(clause)
    return new_clauses


def add_contradiction_pairs(base_clauses, n, k, rng):
    """Add k structural contradiction pairs.

    Each pair: choose 2 variables x_i, x_j and add:
      (x_i ∨ x_j)  AND  (¬x_i ∨ ¬x_j)
    This forces x_i ≠ x_j (XOR-like constraint).

    Each independent pair halves the solution space in expectation.
    Chains of such constraints create graph-coloring-like structures
    that can make the problem UNSAT via odd cycles.
    """
    new_clauses = list(base_clauses)
    used_pairs = set()

    for _ in range(k):
        # Pick a fresh pair of variables
        attempts = 0
        while attempts < 100:
            i, j = sorted(rng.choice(n, size=2, replace=False) + 1)
            if (i, j) not in used_pairs:
                used_pairs.add((i, j))
                break
            attempts += 1

        # Add contradiction pair: x_i ≠ x_j
        # (x_i ∨ x_j): at least one is true
        # (¬x_i ∨ ¬x_j): at least one is false
        new_clauses.append((i, j))      # 2-clause: x_i ∨ x_j
        new_clauses.append((-i, -j))    # 2-clause: ¬x_i ∨ ¬x_j

    return new_clauses


def add_implication_chains(base_clauses, n, k, rng):
    """Add k implication chain constraints.

    Create chain: x_1 → x_2 → x_3 → ... → ¬x_1
    Each implication x→y is encoded as (¬x ∨ y).
    A chain of length L creates a cycle that forces specific structure.
    Odd-length chains involving negation create contradictions.

    This models cascading dependencies (technical debt chains).
    """
    new_clauses = list(base_clauses)

    for _ in range(k):
        # Chain length 3-5
        chain_len = rng.integers(3, 6)
        vars_chain = rng.choice(n, size=chain_len, replace=False) + 1

        # x_0 → x_1 → x_2 → ... → ¬x_0
        for step in range(chain_len - 1):
            # x_i → x_{i+1}: encoded as (¬x_i ∨ x_{i+1})
            new_clauses.append((-int(vars_chain[step]), int(vars_chain[step + 1])))

        # Close the loop with negation: x_{last} → ¬x_0
        # encoded as (¬x_last ∨ ¬x_0)
        new_clauses.append((-int(vars_chain[-1]), -int(vars_chain[0])))

    return new_clauses


# ===================================================================
# Experiment
# ===================================================================

def run_experiment(n=18, base_alpha=3.0, n_trials=50, max_delta_steps=20):
    """
    Main experiment: compare N_eff decay under noise vs contradictions.

    Parameters:
      n: number of variables (n=18 → 2^18 = 262K assignments, fast)
      base_alpha: clause density for base formula (α < 4.27)
      n_trials: repetitions per condition
      max_delta_steps: number of perturbation levels
    """
    rng = np.random.default_rng(42)
    m_base = int(base_alpha * n)

    # δ levels: number of added perturbations
    ks = list(range(0, max_delta_steps + 1))
    # Normalize: δ = k / n (fraction of variables affected)
    deltas = [k / n for k in ks]

    print(f"{'='*80}")
    print(f"SAT EXPERIMENT: Noise vs Structural Contradiction")
    print(f"{'='*80}")
    print(f"  n = {n} variables, base α = {base_alpha} ({m_base} clauses)")
    print(f"  Trials per condition: {n_trials}")
    print(f"  δ levels (k perturbations): {ks}")
    print(f"  Total: {len(ks)} × 3 types × {n_trials} trials = "
          f"{len(ks) * 3 * n_trials} SAT evaluations")
    print()

    results = {"noise": defaultdict(list),
               "contradiction": defaultdict(list),
               "chain": defaultdict(list)}

    for trial in range(n_trials):
        if trial % 10 == 0:
            print(f"  Trial {trial}/{n_trials}...")

        # Generate base formula (same for all perturbation types in this trial)
        base = generate_random_3sat(n, m_base, rng)
        base_count = count_solutions_fast(base, n)

        if base_count == 0:
            continue  # Skip unsatisfiable bases

        for k in ks:
            delta = k / n

            # Type A: Random noise (add k random 3-clauses)
            noisy = add_random_clauses(base, n, k, rng)
            count_noise = count_solutions_fast(noisy, n)

            # Type B: Contradiction pairs (add k XOR-like constraints)
            contradicted = add_contradiction_pairs(base, n, k, rng)
            count_contra = count_solutions_fast(contradicted, n)

            # Type C: Implication chains (cascading contradictions)
            chained = add_implication_chains(base, n, k, rng)
            count_chain = count_solutions_fast(chained, n)

            # Normalize by base count → N_eff / N_eff(0)
            results["noise"][delta].append(count_noise / base_count)
            results["contradiction"][delta].append(count_contra / base_count)
            results["chain"][delta].append(count_chain / base_count)

    # ===================================================================
    # Analysis
    # ===================================================================
    print(f"\n{'='*80}")
    print("RESULTS")
    print(f"{'='*80}")

    summary = {}
    for ptype in ["noise", "contradiction", "chain"]:
        print(f"\n--- {ptype.upper()} ---")
        print(f"  {'δ':>6} {'k':>4} {'mean N_eff/N₀':>14} {'std':>8} {'P(UNSAT)':>10}")

        ds = sorted(results[ptype].keys())
        means = []
        stds = []
        p_unsats = []
        for d in ds:
            vals = results[ptype][d]
            m = np.mean(vals)
            s = np.std(vals)
            p_unsat = np.mean([v == 0 for v in vals])
            means.append(m)
            stds.append(s)
            p_unsats.append(p_unsat)
            k = int(d * n)
            print(f"  {d:6.3f} {k:4d} {m:14.4f} {s:8.4f} {p_unsat:10.3f}")

        summary[ptype] = {
            "deltas": ds,
            "means": means,
            "stds": stds,
            "p_unsats": p_unsats,
        }

    # ===================================================================
    # Model fitting
    # ===================================================================
    print(f"\n{'='*80}")
    print("MODEL FITTING")
    print(f"{'='*80}")

    def exp_decay(x, a, alpha):
        return a * np.exp(-alpha * np.array(x))

    def power_law(x, a, gamma, x_c):
        return a * np.maximum(x_c - np.array(x), 1e-10) ** gamma

    def linear_decay(x, a, b):
        return np.maximum(a - b * np.array(x), 0)

    fit_results = {}
    for ptype in ["noise", "contradiction", "chain"]:
        s = summary[ptype]
        x = np.array(s["deltas"])
        y = np.array(s["means"])

        # Only fit where N_eff > 0
        mask = y > 0.01
        if mask.sum() < 4:
            print(f"\n{ptype}: insufficient data points for fitting")
            continue

        xf, yf = x[mask], y[mask]
        n_pts = len(xf)
        ss_tot = np.sum((yf - np.mean(yf)) ** 2)

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
            r2_exp, aic_exp, popt_exp = -1, float("inf"), [0, 0]

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
            r2_pow, aic_pow, popt_pow = -1, float("inf"), [0, 0, 0]

        # Linear
        try:
            popt_lin, _ = curve_fit(linear_decay, xf, yf,
                                     p0=[1.0, 1.0],
                                     bounds=([0, 0], [10, 100]),
                                     maxfev=10000)
            pred_lin = linear_decay(xf, *popt_lin)
            ss_lin = np.sum((yf - pred_lin) ** 2)
            r2_lin = 1 - ss_lin / ss_tot if ss_tot > 0 else 0
            aic_lin = compute_aic(ss_lin, n_pts, 2)
        except Exception:
            r2_lin, aic_lin, popt_lin = -1, float("inf"), [0, 0]

        models = {"Exp": aic_exp, "Power": aic_pow, "Linear": aic_lin}
        winner = min(models, key=models.get)

        print(f"\n{ptype.upper()}:")
        print(f"  Exponential (2p): R²={r2_exp:.4f}, AIC={aic_exp:.1f}, "
              f"a={popt_exp[0]:.3f}, α={popt_exp[1]:.3f}")
        print(f"  Power law   (3p): R²={r2_pow:.4f}, AIC={aic_pow:.1f}")
        print(f"  Linear      (2p): R²={r2_lin:.4f}, AIC={aic_lin:.1f}")
        print(f"  → Winner: {winner}")

        fit_results[ptype] = {
            "exp_R2": r2_exp, "exp_AIC": aic_exp,
            "exp_params": list(popt_exp) if hasattr(popt_exp, '__iter__') else [0, 0],
            "pow_R2": r2_pow, "pow_AIC": aic_pow,
            "lin_R2": r2_lin, "lin_AIC": aic_lin,
            "winner": winner,
        }

    # ===================================================================
    # Plots
    # ===================================================================
    output_dir = Path(__file__).parent.parent / "results" / "exp_sat"
    output_dir.mkdir(parents=True, exist_ok=True)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    colors = {"noise": "blue", "contradiction": "red", "chain": "orange"}
    labels = {"noise": "Random noise (+ clauses)",
              "contradiction": "XOR contradictions (x_i ≠ x_j)",
              "chain": "Implication chains (x→y→z→¬x)"}

    # Plot 1: N_eff/N₀ vs δ
    ax = axes[0]
    for ptype in ["noise", "contradiction", "chain"]:
        s = summary[ptype]
        ax.errorbar(s["deltas"], s["means"], yerr=s["stds"],
                    fmt="o-", color=colors[ptype], label=labels[ptype],
                    capsize=3, markersize=4)
    ax.set_xlabel("δ (perturbation density = k/n)")
    ax.set_ylabel("N_eff / N₀")
    ax.set_title("Solution count decay: Noise vs Contradiction")
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.1)

    # Plot 2: Log scale
    ax = axes[1]
    for ptype in ["noise", "contradiction", "chain"]:
        s = summary[ptype]
        y = np.array(s["means"])
        mask = y > 0
        d = np.array(s["deltas"])[mask]
        y = y[mask]
        ax.semilogy(d, y, "o-", color=colors[ptype], label=labels[ptype],
                    markersize=4)
        # Fit line on log scale
        if ptype in fit_results and fit_results[ptype]["exp_R2"] > 0:
            p = fit_results[ptype]["exp_params"]
            xfit = np.linspace(min(d), max(d), 100)
            ax.semilogy(xfit, exp_decay(xfit, *p), "--",
                        color=colors[ptype], alpha=0.5)
    ax.set_xlabel("δ")
    ax.set_ylabel("N_eff / N₀ (log scale)")
    ax.set_title("Log-scale: straight line = exponential")
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    # Plot 3: P(UNSAT)
    ax = axes[2]
    for ptype in ["noise", "contradiction", "chain"]:
        s = summary[ptype]
        ax.plot(s["deltas"], s["p_unsats"], "o-", color=colors[ptype],
                label=labels[ptype], markersize=4)
    ax.set_xlabel("δ")
    ax.set_ylabel("P(UNSAT)")
    ax.set_title("Probability of becoming unsatisfiable")
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    plot_path = output_dir / f"sat_contradiction_{timestamp}.png"
    plt.savefig(plot_path, dpi=150)
    print(f"\nPlots saved: {plot_path}")
    plt.close()

    # Save results
    save_data = {
        "params": {"n": n, "base_alpha": base_alpha,
                    "n_trials": n_trials, "max_delta_steps": max_delta_steps},
        "summary": {k: {"deltas": v["deltas"],
                         "means": [float(x) for x in v["means"]],
                         "stds": [float(x) for x in v["stds"]],
                         "p_unsats": [float(x) for x in v["p_unsats"]]}
                    for k, v in summary.items()},
        "fit_results": fit_results,
    }
    json_path = output_dir / f"sat_contradiction_{timestamp}.json"
    with open(json_path, "w") as f:
        json.dump(save_data, f, indent=2)

    # ===================================================================
    # Interpretation
    # ===================================================================
    print(f"\n{'='*80}")
    print("INTERPRETATION")
    print(f"{'='*80}")

    noise_winner = fit_results.get("noise", {}).get("winner", "?")
    contra_winner = fit_results.get("contradiction", {}).get("winner", "?")
    chain_winner = fit_results.get("chain", {}).get("winner", "?")

    print(f"\n  Noise:         best fit = {noise_winner}")
    print(f"  Contradiction: best fit = {contra_winner}")
    print(f"  Chain:         best fit = {chain_winner}")

    # Compare decay rates
    noise_alpha = fit_results.get("noise", {}).get("exp_params", [0, 0])[1]
    contra_alpha = fit_results.get("contradiction", {}).get("exp_params", [0, 0])[1]
    chain_alpha = fit_results.get("chain", {}).get("exp_params", [0, 0])[1]

    print(f"\n  Exponential decay rates (α):")
    print(f"    Noise:         α = {noise_alpha:.3f}")
    print(f"    Contradiction: α = {contra_alpha:.3f}")
    print(f"    Chain:         α = {chain_alpha:.3f}")

    if contra_alpha > noise_alpha * 1.5:
        print(f"\n  Contradictions decay {contra_alpha/max(noise_alpha, 0.001):.1f}× "
              f"faster than noise!")
        print(f"  → Structural contradictions are qualitatively different from noise.")
        print(f"  → This supports the delta framework distinction:")
        print(f"     δ_noise (random) ≠ δ_structural (contradictions)")
    elif contra_alpha > noise_alpha:
        print(f"\n  Contradictions decay somewhat faster than noise "
              f"({contra_alpha/max(noise_alpha, 0.001):.1f}×)")
    else:
        print(f"\n  Contradictions and noise have similar decay rates.")
        print(f"  → No evidence for qualitative distinction.")

    # Check if contradictions show sharper UNSAT transition
    noise_unsat = summary["noise"]["p_unsats"]
    contra_unsat = summary["contradiction"]["p_unsats"]
    # Find δ where P(UNSAT) first exceeds 0.5
    for i, (pn, pc) in enumerate(zip(noise_unsat, contra_unsat)):
        if pc > 0.5:
            print(f"\n  Contradiction reaches P(UNSAT)>0.5 at δ={summary['contradiction']['deltas'][i]:.3f}")
            break
    for i, pn in enumerate(noise_unsat):
        if pn > 0.5:
            print(f"  Noise reaches P(UNSAT)>0.5 at δ={summary['noise']['deltas'][i]:.3f}")
            break


if __name__ == "__main__":
    run_experiment(n=18, base_alpha=3.0, n_trials=50, max_delta_steps=20)
