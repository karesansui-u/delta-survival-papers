#!/usr/bin/env python3
"""
Phase 2 実験B: α密度 — α_d周辺のμ_c挙動変化

N=200固定、α=3.5〜4.5を0.1刻みでμ_cの詳細プロファイルを測定。
α_d ≈ 3.86 でのclustering転移がμ_cに影響するか確認。
"""

import json
import random
import time
import math
import numpy as np
from datetime import datetime
from pathlib import Path
from pysat.solvers import Minisat22
from pysat.formula import CNF


def generate_random_3sat(n: int, alpha: float, seed: int) -> CNF:
    rng = random.Random(seed)
    m = int(alpha * n)
    cnf = CNF()
    for _ in range(m):
        vars_used = rng.sample(range(1, n + 1), 3)
        clause = [v if rng.random() > 0.5 else -v for v in vars_used]
        cnf.append(clause)
    return cnf


def solve_unlimited(cnf: CNF) -> dict:
    s = Minisat22(bootstrap_with=cnf)
    result = s.solve()
    stats = s.accum_stats()
    s.delete()
    return {
        "sat": result,
        "conflicts": stats["conflicts"],
        "decisions": stats["decisions"],
        "propagations": stats["propagations"],
    }


def solve_with_budget(cnf: CNF, budget: int) -> dict:
    s = Minisat22(bootstrap_with=cnf)
    s.conf_budget(budget)
    result = s.solve_limited()
    stats = s.accum_stats()
    s.delete()
    return {
        "found": result is True,
        "conflicts": stats["conflicts"],
        "decisions": stats["decisions"],
        "propagations": stats["propagations"],
    }


def main():
    N = 200
    alphas = [round(3.5 + 0.1 * i, 1) for i in range(11)]  # 3.5 to 4.5
    budgets = [100, 300, 1000, 3000, 10000, 30000, 100000]
    n_instances = 500
    base_seed = 20260309  # different seed from Nスケーリング
    I_per_clause = abs(math.log(7 / 8))

    print(f"Phase 2B: α density, N={N}, αs={alphas}")
    print(f"{len(alphas)} alphas × {len(budgets)} budgets × {n_instances} instances\n")

    t_start = time.time()

    # Phase 1: unlimited
    print("Phase 1: Unlimited solving...")
    instance_info = {}
    for ai, alpha in enumerate(alphas):
        sat_count = 0
        for i in range(n_instances):
            seed = base_seed + ai * 100000 + i
            cnf = generate_random_3sat(N, alpha, seed)
            r = solve_unlimited(cnf)
            instance_info[(ai, i)] = r
            if r["sat"]:
                sat_count += 1
        delta = alpha * N * I_per_clause
        print(f"  α={alpha:.1f} δ={delta:.1f}: {sat_count}/{n_instances} SAT ({sat_count/n_instances:.0%})")

    print(f"  Phase 1: {time.time()-t_start:.1f}s")

    # Phase 2: budgeted (SAT only)
    print("\nPhase 2: Budget-limited solving...")
    budget_results = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            for budget in budgets:
                budget_results[(ai, budget)] = {"n_sat": 0, "found": 0}
            continue
        for budget in budgets:
            found_count = 0
            for i in sat_indices:
                seed = base_seed + ai * 100000 + i
                cnf = generate_random_3sat(N, alpha, seed)
                r = solve_with_budget(cnf, budget)
                if r["found"]:
                    found_count += 1
            budget_results[(ai, budget)] = {"n_sat": n_sat, "found": found_count}
        print(f"  α={alpha:.1f}: {n_sat} SAT instances done")

    total_time = time.time() - t_start
    print(f"\nTotal time: {total_time:.1f}s")

    # Table
    print(f"\n{'='*110}")
    print(f"P(found | SAT) — N={N}, α density")
    print(f"{'='*110}")
    header = f"{'α':>5} {'δ':>7} {'P(SAT)':>7} {'n_SAT':>6}"
    for b in budgets:
        header += f" {'μ='+str(b):>9}"
    print(header)
    print("-" * len(header))

    summary = []
    for ai, alpha in enumerate(alphas):
        delta = alpha * N * I_per_clause
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        p_sat = n_sat / n_instances
        line = f"{alpha:5.1f} {delta:7.1f} {p_sat:7.2f} {n_sat:6d}"
        row = {"alpha": alpha, "delta": round(delta, 2), "p_sat": round(p_sat, 4), "n_sat": n_sat}
        for budget in budgets:
            br = budget_results[(ai, budget)]
            p_found = br["found"] / n_sat if n_sat > 0 else float("nan")
            line += f" {p_found:9.3f}"
            row[f"p_found_mu_{budget}"] = round(p_found, 4) if n_sat > 0 else None
        print(line)
        summary.append(row)

    # μ_c profile
    print(f"\n{'='*110}")
    print(f"μ_c profile across α (SAT instances only)")
    print(f"{'='*110}")
    print(f"{'α':>5} {'δ':>7} {'n_SAT':>6} {'med_conf':>9} {'p25_conf':>9} {'p75_conf':>9} {'p90_conf':>9} {'med_prop':>9}")
    print("-" * 75)

    mu_c_data = []
    for ai, alpha in enumerate(alphas):
        delta = alpha * N * I_per_clause
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        if not sat_indices:
            print(f"{alpha:5.1f} {delta:7.1f}      0       —         —         —         —         —")
            continue
        confs = [instance_info[(ai, i)]["conflicts"] for i in sat_indices]
        props = [instance_info[(ai, i)]["propagations"] for i in sat_indices]
        decs = [instance_info[(ai, i)]["decisions"] for i in sat_indices]
        med_c = float(np.median(confs))
        p25_c = float(np.percentile(confs, 25))
        p75_c = float(np.percentile(confs, 75))
        p90_c = float(np.percentile(confs, 90))
        med_p = float(np.median(props))
        med_d = float(np.median(decs))
        print(f"{alpha:5.1f} {delta:7.1f} {len(sat_indices):6d} {med_c:9.0f} {p25_c:9.0f} {p75_c:9.0f} {p90_c:9.0f} {med_p:9.0f}")
        mu_c_data.append({
            "alpha": alpha, "delta": round(delta, 2), "n_sat": len(sat_indices),
            "med_conflicts": med_c, "p25_conflicts": p25_c, "p75_conflicts": p75_c,
            "p90_conflicts": p90_c, "med_decisions": med_d, "med_propagations": med_p,
        })

    # Fit: ln(μ_c) vs δ — check for kink at α_d
    print(f"\n  e^{{c·δ}} fit (all α with SAT):")
    for metric_name, metric_key in [("conflicts", "med_conflicts"), ("propagations", "med_propagations")]:
        deltas_fit = []
        ln_mu_fit = []
        for d in mu_c_data:
            val = d[metric_key]
            if val > 0:
                deltas_fit.append(d["delta"])
                ln_mu_fit.append(math.log(val))
        if len(deltas_fit) >= 3:
            x = np.array(deltas_fit)
            y = np.array(ln_mu_fit)
            coeffs = np.polyfit(x, y, 1)
            c_slope = coeffs[0]
            intercept = coeffs[1]
            y_pred = c_slope * x + intercept
            ss_res = np.sum((y - y_pred) ** 2)
            ss_tot = np.sum((y - np.mean(y)) ** 2)
            r_sq = 1 - ss_res / ss_tot if ss_tot > 0 else 0
            residuals = y - y_pred
            print(f"    {metric_name:>13}: c={c_slope:.4f}, R²={r_sq:.4f}")
            print(f"      Residuals by α: ", end="")
            for d, r in zip(deltas_fit, residuals):
                alpha_approx = d / (N * I_per_clause)
                print(f"α≈{alpha_approx:.1f}:{r:+.2f} ", end="")
            print()

    # Universal curve
    mu_c_by_alpha = {d["alpha"]: d["med_conflicts"] for d in mu_c_data if d["med_conflicts"] > 0}
    universal_points = []
    for ai, alpha in enumerate(alphas):
        if alpha not in mu_c_by_alpha:
            continue
        mu_c = mu_c_by_alpha[alpha]
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat < 10:
            continue
        for budget in budgets:
            ratio = budget / mu_c
            br = budget_results[(ai, budget)]
            p_found = br["found"] / n_sat
            universal_points.append({
                "alpha": alpha, "budget": budget,
                "mu_over_mu_c": round(ratio, 3),
                "p_found_given_sat": round(p_found, 4),
                "n_sat": n_sat,
            })

    bins = [(0, 0.1), (0.1, 0.3), (0.3, 1.0), (1.0, 3.0), (3.0, 10.0), (10.0, 100.0), (100.0, float('inf'))]
    print(f"\n  Universality bins:")
    print(f"  {'bin':>15} {'n':>4} {'mean_P':>8} {'std_P':>8} {'range':>12}")
    for lo, hi in bins:
        pts = [p["p_found_given_sat"] for p in universal_points if lo <= p["mu_over_mu_c"] < hi]
        if pts:
            label = f"[{lo:.1f}, {hi:.1f})" if hi < float('inf') else f"[{lo:.1f}, ∞)"
            print(f"  {label:>15} {len(pts):4d} {np.mean(pts):8.3f} {np.std(pts):8.3f} {min(pts):.3f}-{max(pts):.3f}")

    # Save
    output = {
        "config": {
            "N": N, "alphas": alphas, "budgets": budgets,
            "n_instances": n_instances,
            "timestamp": datetime.now().isoformat(),
            "total_time_sec": round(total_time, 1),
        },
        "summary": summary,
        "mu_c_profile": mu_c_data,
        "universal_curve": universal_points,
    }
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"phase2_alpha_density_{timestamp}.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\nResults saved to {out_path}")


if __name__ == "__main__":
    main()
