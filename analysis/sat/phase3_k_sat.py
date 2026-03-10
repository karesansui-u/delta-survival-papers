#!/usr/bin/env python3
"""
Phase 3: k-SAT一般化 — c(k) = I_k / ln 2 仮説の検証

仮説: μ_c ∝ e^{c·δ} の c は k-SAT の k に依存し、
  c(k) = log_2(2^k / (2^k - 1)) = ln(2^k/(2^k-1)) / ln 2

予測値:
  k=3: c = log_2(8/7)   ≈ 0.193
  k=4: c = log_2(16/15) ≈ 0.093

k=3 は Phase 2 で c ≈ 0.19 を確認済み。k=4 で c ≈ 0.09 が出れば仮説を支持。

k=4 の既知パラメータ:
  α_c ≈ 9.93 (SAT/UNSAT転移)
  α_d ≈ 9.38 (clustering転移)
  I_clause = ln(16/15) ≈ 0.0645 nats
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


def generate_random_ksat(n: int, k: int, alpha: float, seed: int) -> CNF:
    rng = random.Random(seed)
    m = int(alpha * n)
    cnf = CNF()
    for _ in range(m):
        vars_used = rng.sample(range(1, n + 1), k)
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
    }


def run_for_k(k, N, alphas, budgets, n_instances, base_seed):
    I_per_clause = abs(math.log((2**k - 1) / 2**k))
    c_predicted = I_per_clause / math.log(2)

    print(f"\n{'#'*80}")
    print(f"# k={k}-SAT, N={N}")
    print(f"# I_clause = ln({2**k}/{2**k-1}) = {I_per_clause:.4f} nats")
    print(f"# c predicted = {c_predicted:.4f}")
    print(f"{'#'*80}")

    t_start = time.time()

    # Phase 1: unlimited solve
    print(f"Phase 1: Solving {len(alphas)*n_instances} instances unlimited...")
    instance_info = {}
    for ai, alpha in enumerate(alphas):
        sat_count = 0
        for i in range(n_instances):
            seed = base_seed + k * 10000000 + N * 1000000 + ai * 100000 + i
            cnf = generate_random_ksat(N, k, alpha, seed)
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
                seed = base_seed + k * 10000000 + N * 1000000 + ai * 100000 + i
                cnf = generate_random_ksat(N, k, alpha, seed)
                r = solve_with_budget(cnf, budget)
                if r["found"]:
                    found_count += 1
            budget_results[(ai, budget)] = {"n_sat": n_sat, "found": found_count}

    total_time = time.time() - t_start
    print(f"  Total: {total_time:.1f}s")

    # Table
    print(f"\n{'='*100}")
    print(f"P(found | SAT) — k={k}, N={N}")
    print(f"{'='*100}")
    header = f"{'α':>6} {'δ':>7} {'P(SAT)':>7} {'n_SAT':>6}"
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
        line = f"{alpha:6.2f} {delta:7.1f} {p_sat:7.2f} {n_sat:6d}"
        row = {"alpha": alpha, "delta": round(delta, 2), "p_sat": round(p_sat, 4), "n_sat": n_sat}
        for budget in budgets:
            br = budget_results[(ai, budget)]
            p_found = br["found"] / n_sat if n_sat > 0 else float("nan")
            line += f" {p_found:9.3f}"
            row[f"p_found_mu_{budget}"] = round(p_found, 4) if n_sat > 0 else None
        print(line)
        summary.append(row)

    # μ_c stats
    mu_c_data = []
    for ai, alpha in enumerate(alphas):
        delta = alpha * N * I_per_clause
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        if not sat_indices:
            continue
        confs = [instance_info[(ai, i)]["conflicts"] for i in sat_indices]
        med_c = float(np.median(confs))
        mu_c_data.append({
            "alpha": alpha, "delta": round(delta, 2), "n_sat": len(sat_indices),
            "med_conflicts": med_c,
        })

    # e^{c·δ} fit
    fit_result = {}
    deltas_fit = []
    ln_mu_fit = []
    for d in mu_c_data:
        val = d["med_conflicts"]
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
        print(f"\n  ln(μ_c) = {c_slope:.4f}·δ + {intercept:.2f},  R² = {r_sq:.4f}")
        print(f"  c measured  = {c_slope:.4f}")
        print(f"  c predicted = {c_predicted:.4f}  (= log₂({2**k}/{2**k-1}))")
        print(f"  ratio       = {c_slope/c_predicted:.2f}")
        fit_result = {
            "c_slope": round(c_slope, 4), "intercept": round(intercept, 2),
            "r_squared": round(r_sq, 4), "n_points": len(deltas_fit),
            "c_predicted": round(c_predicted, 4),
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

    return {
        "k": k, "N": N, "total_time_sec": round(total_time, 1),
        "I_per_clause": round(I_per_clause, 6),
        "c_predicted": round(c_predicted, 4),
        "summary": summary, "mu_c_data": mu_c_data,
        "fit": fit_result, "universal_curve": universal_points,
    }


def main():
    # k=3: α_c ≈ 4.27, use same range as Phase 2A
    alphas_k3 = [1.0, 2.0, 3.0, 3.5, 4.0, 4.27]
    # k=4: α_c ≈ 9.93, scale accordingly
    alphas_k4 = [2.0, 4.0, 6.0, 7.0, 8.0, 9.0, 9.93]

    N = 200
    budgets = [100, 300, 1000, 3000, 10000, 30000, 100000]
    n_instances = 500
    base_seed = 20260309

    print(f"Phase 3: k-SAT generalization")
    print(f"Hypothesis: c(k) = log₂(2^k/(2^k-1))")
    print(f"  k=3: c_pred = {math.log(8/7)/math.log(2):.4f}")
    print(f"  k=4: c_pred = {math.log(16/15)/math.log(2):.4f}")
    print(f"N={N}, n_instances={n_instances}\n")

    all_results = {}

    # k=3 (confirmation)
    result_k3 = run_for_k(3, N, alphas_k3, budgets, n_instances, base_seed)
    all_results["k=3"] = result_k3

    # k=4
    result_k4 = run_for_k(4, N, alphas_k4, budgets, n_instances, base_seed)
    all_results["k=4"] = result_k4

    # Cross-k comparison
    print(f"\n{'='*100}")
    print(f"Cross-k comparison: c(k) = I_k / ln 2 hypothesis")
    print(f"{'='*100}")
    print(f"{'k':>3} {'I_clause':>10} {'c_pred':>8} {'c_meas':>8} {'R²':>8} {'ratio':>8}")
    print("-" * 50)
    for key in ["k=3", "k=4"]:
        r = all_results[key]
        fit = r["fit"]
        if fit:
            print(f"{r['k']:3d} {r['I_per_clause']:10.4f} {r['c_predicted']:8.4f} {fit['c_slope']:8.4f} {fit['r_squared']:8.4f} {fit['c_slope']/r['c_predicted']:8.2f}")
        else:
            print(f"{r['k']:3d} {r['I_per_clause']:10.4f} {r['c_predicted']:8.4f}      —        —        —")

    # Save
    output = {
        "config": {
            "N": N, "budgets": budgets, "n_instances": n_instances,
            "timestamp": datetime.now().isoformat(),
            "hypothesis": "c(k) = log_2(2^k / (2^k - 1)) = I_clause / ln 2",
        },
        "results": all_results,
    }
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"phase3_k_sat_{timestamp}.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\nResults saved to {out_path}")


if __name__ == "__main__":
    main()
