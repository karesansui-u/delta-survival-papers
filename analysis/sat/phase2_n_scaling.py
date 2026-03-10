#!/usr/bin/env python3
"""
Phase 2 実験A: Nスケーリング — c(N)の安定性テスト

N=100, 200 で同一αセットを走らせ、μ_c ∝ e^{c·δ} の c がN依存かテスト。
N=200のデータはv3パイロットと同じ設計だが、αを広げインスタンス数を増やす。
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


def run_for_N(N, alphas, budgets, n_instances, base_seed):
    I_per_clause = abs(math.log(7 / 8))
    print(f"\n{'#'*80}")
    print(f"# N = {N}")
    print(f"{'#'*80}")

    t_start = time.time()

    # Phase 1: unlimited solve
    print(f"Phase 1: Solving {len(alphas)*n_instances} instances unlimited...")
    instance_info = {}
    for ai, alpha in enumerate(alphas):
        sat_count = 0
        for i in range(n_instances):
            seed = base_seed + N * 1000000 + ai * 100000 + i
            cnf = generate_random_3sat(N, alpha, seed)
            r = solve_unlimited(cnf)
            instance_info[(ai, i)] = r
            if r["sat"]:
                sat_count += 1
        delta = alpha * N * I_per_clause
        print(f"  α={alpha:.2f} δ={delta:.1f}: {sat_count}/{n_instances} SAT ({sat_count/n_instances:.0%})")

    print(f"  Phase 1: {time.time()-t_start:.1f}s")

    # Phase 2: budget-limited (SAT only)
    print(f"Phase 2: Budget-limited solving...")
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
                seed = base_seed + N * 1000000 + ai * 100000 + i
                cnf = generate_random_3sat(N, alpha, seed)
                r = solve_with_budget(cnf, budget)
                if r["found"]:
                    found_count += 1
            budget_results[(ai, budget)] = {"n_sat": n_sat, "found": found_count}

    total_time = time.time() - t_start
    print(f"  Phase 2: {total_time:.1f}s total")

    # Analysis
    print(f"\n{'='*100}")
    print(f"P(found | SAT) — N={N}")
    print(f"{'='*100}")
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
        line = f"{alpha:5.2f} {delta:7.1f} {p_sat:7.2f} {n_sat:6d}"
        row = {"alpha": alpha, "delta": round(delta, 2), "p_sat": round(p_sat, 4), "n_sat": n_sat}
        for budget in budgets:
            br = budget_results[(ai, budget)]
            p_found = br["found"] / n_sat if n_sat > 0 else float("nan")
            line += f" {p_found:9.3f}"
            row[f"p_found_mu_{budget}"] = round(p_found, 4) if n_sat > 0 else None
        print(line)
        summary.append(row)

    # μ_c stats
    print(f"\n  SAT runtime stats:")
    mu_c_data = []
    for ai, alpha in enumerate(alphas):
        delta = alpha * N * I_per_clause
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        if not sat_indices:
            continue
        confs = [instance_info[(ai, i)]["conflicts"] for i in sat_indices]
        decs = [instance_info[(ai, i)]["decisions"] for i in sat_indices]
        props = [instance_info[(ai, i)]["propagations"] for i in sat_indices]
        med_c = float(np.median(confs))
        med_d = float(np.median(decs))
        med_p = float(np.median(props))
        print(f"    α={alpha:.2f} δ={delta:.1f}: med_conf={med_c:.0f}, med_dec={med_d:.0f}, med_prop={med_p:.0f}")
        mu_c_data.append({
            "alpha": alpha, "delta": round(delta, 2), "n_sat": len(sat_indices),
            "med_conflicts": med_c, "med_decisions": med_d, "med_propagations": med_p,
        })

    # e^{c·δ} fit
    fit_results = {}
    for metric_name, metric_key in [("conflicts", "med_conflicts"), ("decisions", "med_decisions"), ("propagations", "med_propagations")]:
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
            print(f"  {metric_name:>13}: ln(μ_c) = {c_slope:.4f}·δ + {intercept:.2f},  R² = {r_sq:.4f}")
            fit_results[metric_name] = {
                "c_slope": round(c_slope, 4), "intercept": round(intercept, 2),
                "r_squared": round(r_sq, 4), "n_points": len(deltas_fit),
            }

    # Universal curve
    mu_c_by_alpha = {d["alpha"]: d["med_conflicts"] for d in mu_c_data if d["med_conflicts"] > 0}
    universal_points = []
    for ai, alpha in enumerate(alphas):
        if alpha not in mu_c_by_alpha:
            continue
        mu_c = mu_c_by_alpha[alpha]
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat < 5:
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

    # Universality bins
    bins = [(0, 0.1), (0.1, 0.3), (0.3, 1.0), (1.0, 3.0), (3.0, 10.0), (10.0, 100.0), (100.0, float('inf'))]
    print(f"\n  Universality bins (N={N}):")
    print(f"  {'bin':>15} {'n':>4} {'mean_P':>8} {'std_P':>8}")
    for lo, hi in bins:
        pts = [p["p_found_given_sat"] for p in universal_points if lo <= p["mu_over_mu_c"] < hi]
        if pts:
            label = f"[{lo:.1f}, {hi:.1f})" if hi < float('inf') else f"[{lo:.1f}, ∞)"
            print(f"  {label:>15} {len(pts):4d} {np.mean(pts):8.3f} {np.std(pts):8.3f}")

    return {
        "N": N, "total_time_sec": round(total_time, 1),
        "summary": summary, "mu_c_sat_only": mu_c_data,
        "exp_delta_fit": fit_results, "universal_curve": universal_points,
    }


def main():
    alphas = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.27, 5.0]
    budgets = [100, 300, 1000, 3000, 10000, 30000, 100000]
    n_instances = 500
    base_seed = 20260308

    all_results = {}
    for N in [100, 200]:
        result = run_for_N(N, alphas, budgets, n_instances, base_seed)
        all_results[f"N={N}"] = result

    # Cross-N comparison
    print(f"\n{'='*100}")
    print(f"Cross-N comparison: c(N) stability")
    print(f"{'='*100}")
    for metric in ["conflicts", "decisions", "propagations"]:
        print(f"  {metric}:")
        for N_key in ["N=100", "N=200"]:
            fit = all_results[N_key]["exp_delta_fit"].get(metric)
            if fit:
                print(f"    {N_key}: c={fit['c_slope']:.4f}, R²={fit['r_squared']:.4f}")

    # Save
    output = {
        "config": {
            "alphas": alphas, "budgets": budgets,
            "n_instances": n_instances, "Ns": [100, 200],
            "timestamp": datetime.now().isoformat(),
        },
        "results": all_results,
    }
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"phase2_n_scaling_{timestamp}.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\nResults saved to {out_path}")


if __name__ == "__main__":
    main()
