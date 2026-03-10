#!/usr/bin/env python3
"""
Phase 2C: ソルバー比較実験 — c はアルゴリズムの性質か、問題の性質か？

CDCL (MiniSat) で c ≈ 0.20 を確認済み。
WalkSAT（局所探索）とランダム探索で同じ実験を行い、c を比較する。

- c_CDCL ≠ c_WalkSAT → c はアルゴリズム効率の指標
- c_CDCL ≈ c_WalkSAT → c は問題構造の定数（1RSB的）

ソルバー3種:
  1. CDCL (MiniSat) — conflict budgetで制限
  2. WalkSAT — flip budgetで制限
  3. Random search — trial budgetで制限（c=1のベースライン）
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


def solve_cdcl_budgeted(cnf: CNF, budget: int) -> dict:
    s = Minisat22(bootstrap_with=cnf)
    s.conf_budget(budget)
    result = s.solve_limited()
    stats = s.accum_stats()
    s.delete()
    return {"found": result is True, "steps": stats["conflicts"]}


def walksat(clauses, n_vars, max_flips, noise=0.5, seed=None):
    """WalkSAT局所探索。返り値: (found, flips_used)"""
    rng = random.Random(seed)
    assignment = [rng.choice([True, False]) for _ in range(n_vars + 1)]

    def satisfied(clause):
        for lit in clause:
            val = assignment[abs(lit)]
            if (lit > 0 and val) or (lit < 0 and not val):
                return True
        return False

    def count_unsat():
        return sum(1 for c in clauses if not satisfied(c))

    for flip in range(1, max_flips + 1):
        unsat_clauses = [c for c in clauses if not satisfied(c)]
        if not unsat_clauses:
            return True, flip

        clause = rng.choice(unsat_clauses)

        if rng.random() < noise:
            var = abs(rng.choice(clause))
        else:
            best_var = None
            best_break = float("inf")
            for lit in clause:
                var = abs(lit)
                assignment[var] = not assignment[var]
                breaks = count_unsat()
                assignment[var] = not assignment[var]
                if breaks < best_break:
                    best_break = breaks
                    best_var = var
            var = best_var

        assignment[var] = not assignment[var]

    return False, max_flips


def walksat_with_restarts(clauses, n_vars, max_flips, noise=0.5, restart_len=1000, seed=None):
    """WalkSAT with random restarts。総flip数でbudget制限。"""
    rng = random.Random(seed)
    total_flips = 0
    while total_flips < max_flips:
        remaining = min(restart_len, max_flips - total_flips)
        found, flips = walksat(clauses, n_vars, remaining, noise=noise, seed=rng.randint(0, 2**31))
        total_flips += flips
        if found:
            return True, total_flips
    return False, total_flips


def random_search(clauses, n_vars, max_trials, seed=None):
    """完全ランダム探索（ベースライン、c=1期待）"""
    rng = random.Random(seed)
    for trial in range(1, max_trials + 1):
        assignment = [rng.choice([True, False]) for _ in range(n_vars + 1)]
        all_sat = True
        for clause in clauses:
            clause_sat = False
            for lit in clause:
                val = assignment[abs(lit)]
                if (lit > 0 and val) or (lit < 0 and not val):
                    clause_sat = True
                    break
            if not clause_sat:
                all_sat = False
                break
        if all_sat:
            return True, trial
    return False, max_trials


def run_experiment():
    N = 100  # reduced from 200 for WalkSAT feasibility (c's N-independence confirmed in Phase 2A)
    alphas = [3.0, 3.5, 3.86, 4.0, 4.2]
    n_instances = 100
    base_seed = 20260308

    # Budget ranges (different units per solver)
    cdcl_budgets = [100, 1000, 10000, 100000]
    walksat_budgets = [1000, 100000, 1000000]
    random_budgets = [10, 100, 1000, 10000]

    I_per_clause = abs(math.log(7 / 8))

    print(f"Phase 2C: Solver comparison (N={N}, {n_instances} instances)")
    print(f"  CDCL budgets: {cdcl_budgets}")
    print(f"  WalkSAT budgets: {walksat_budgets}")
    print(f"  Random budgets: {random_budgets}")
    print()

    t_start = time.time()

    # Phase 1: SAT/UNSAT determination (reuse same seeds as v3)
    print("Phase 1: SAT/UNSAT determination...")
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
        print(f"  alpha={alpha:.2f} delta={delta:.1f}: {sat_count}/{n_instances} SAT")

    print(f"  Phase 1: {time.time()-t_start:.1f}s\n")

    # Phase 2: Solve SAT instances with each solver
    results = {}

    # --- CDCL ---
    print("Phase 2a: CDCL (MiniSat)...")
    t_cdcl = time.time()
    cdcl_data = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            continue

        # Unlimited runtime stats
        runtimes = [instance_info[(ai, i)]["conflicts"] for i in sat_indices]
        med_runtime = float(np.median(runtimes))

        budget_p = {}
        for budget in cdcl_budgets:
            found = 0
            for i in sat_indices:
                seed = base_seed + ai * 100000 + i
                cnf = generate_random_3sat(N, alpha, seed)
                r = solve_cdcl_budgeted(cnf, budget)
                if r["found"]:
                    found += 1
            budget_p[budget] = found / n_sat

        cdcl_data[alpha] = {
            "n_sat": n_sat, "med_runtime": med_runtime,
            "budget_p": budget_p,
        }
        print(f"  alpha={alpha:.2f}: mu_c={med_runtime:.0f}")

    results["cdcl"] = cdcl_data
    print(f"  CDCL done: {time.time()-t_cdcl:.1f}s\n")

    # --- WalkSAT ---
    print("Phase 2b: WalkSAT (local search, noise=0.5, restart_len=1000)...")
    t_ws = time.time()
    walksat_data = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            continue

        # Unlimited: use large budget to find solutions and measure flips
        unlimited_flips = []
        for i in sat_indices:
            seed = base_seed + ai * 100000 + i
            cnf = generate_random_3sat(N, alpha, seed)
            clauses = cnf.clauses
            found, flips = walksat_with_restarts(clauses, N, max_flips=1_000_000, noise=0.5,
                                                  restart_len=1000, seed=seed + 999)
            if found:
                unlimited_flips.append(flips)

        if not unlimited_flips:
            print(f"  alpha={alpha:.2f}: WalkSAT found 0 solutions (skipping)")
            continue

        med_flips = float(np.median(unlimited_flips))
        solve_rate = len(unlimited_flips) / n_sat

        # Budgeted runs
        budget_p = {}
        for budget in walksat_budgets:
            found = 0
            for i in sat_indices:
                seed = base_seed + ai * 100000 + i
                cnf = generate_random_3sat(N, alpha, seed)
                f, _ = walksat_with_restarts(cnf.clauses, N, max_flips=budget, noise=0.5,
                                              restart_len=1000, seed=seed + 888)
                if f:
                    found += 1
            budget_p[budget] = found / n_sat

        walksat_data[alpha] = {
            "n_sat": n_sat, "med_runtime": med_flips,
            "unlimited_solve_rate": round(solve_rate, 4),
            "n_solved_unlimited": len(unlimited_flips),
            "budget_p": budget_p,
        }
        print(f"  alpha={alpha:.2f}: mu_c={med_flips:.0f} flips, solve_rate={solve_rate:.2f}")

    results["walksat"] = walksat_data
    print(f"  WalkSAT done: {time.time()-t_ws:.1f}s\n")

    # --- Random search ---
    print("Phase 2c: Random search (baseline, expect c~1.0)...")
    t_rs = time.time()
    random_data = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            continue

        # Theoretical mu_c for random search: 1 / P(random assignment satisfies)
        # P = (7/8)^m = e^{-delta}
        delta = alpha * N * I_per_clause
        theoretical_mu_c = math.exp(delta)

        # Budgeted runs (only for low alpha, random search is hopeless for high alpha at N=200)
        budget_p = {}
        for budget in random_budgets:
            found = 0
            for i in sat_indices:
                seed = base_seed + ai * 100000 + i
                cnf = generate_random_3sat(N, alpha, seed)
                f, _ = random_search(cnf.clauses, N, max_trials=budget, seed=seed + 777)
                if f:
                    found += 1
            budget_p[budget] = found / n_sat

        random_data[alpha] = {
            "n_sat": n_sat,
            "theoretical_mu_c": theoretical_mu_c,
            "delta": round(delta, 2),
            "budget_p": budget_p,
        }
        found_any = any(p > 0 for p in budget_p.values())
        print(f"  alpha={alpha:.2f}: e^delta={theoretical_mu_c:.1e}, found_any={found_any}")

    results["random"] = random_data
    print(f"  Random done: {time.time()-t_rs:.1f}s\n")

    # === Analysis ===
    total_time = time.time() - t_start
    print(f"\nTotal time: {total_time:.1f}s")

    print(f"\n{'='*80}")
    print("mu_c vs e^{c*delta} fit by solver")
    print(f"{'='*80}")

    fit_results = {}
    for solver_name, solver_data in [("cdcl", cdcl_data), ("walksat", walksat_data)]:
        deltas = []
        ln_mu_c = []
        for alpha, d in sorted(solver_data.items()):
            delta = alpha * N * I_per_clause
            mu_c = d["med_runtime"]
            if mu_c > 0:
                deltas.append(delta)
                ln_mu_c.append(math.log(mu_c))

        if len(deltas) >= 3:
            x = np.array(deltas)
            y = np.array(ln_mu_c)
            coeffs = np.polyfit(x, y, 1)
            c_val = coeffs[0]
            intercept = coeffs[1]
            y_pred = c_val * x + intercept
            ss_res = np.sum((y - y_pred) ** 2)
            ss_tot = np.sum((y - np.mean(y)) ** 2)
            r_sq = 1 - ss_res / ss_tot if ss_tot > 0 else 0

            print(f"  {solver_name:>10}: c = {c_val:.4f}, R^2 = {r_sq:.4f}  (n={len(deltas)} points)")
            fit_results[solver_name] = {
                "c": round(c_val, 4), "intercept": round(intercept, 2),
                "r_squared": round(r_sq, 4), "n_points": len(deltas),
            }

    # Random search: c should be ~1.0 theoretically
    # mu_c_theoretical = e^delta, so ln(mu_c) = delta, meaning c = 1.0 exactly
    print(f"  {'random':>10}: c = 1.0000 (theoretical, mu_c = e^delta by definition)")
    fit_results["random"] = {"c": 1.0, "note": "theoretical"}

    # Key comparison
    if "cdcl" in fit_results and "walksat" in fit_results:
        c_cdcl = fit_results["cdcl"]["c"]
        c_ws = fit_results["walksat"]["c"]
        ratio = c_ws / c_cdcl if c_cdcl != 0 else float("inf")
        print(f"\n  c_walksat / c_cdcl = {ratio:.2f}")
        if abs(c_cdcl - c_ws) / max(c_cdcl, c_ws) < 0.2:
            print("  --> c values are SIMILAR (<20% relative diff): c may be a problem property!")
        else:
            print("  --> c values DIFFER (>20% relative diff): c is an algorithm property")

    # Save
    output = {
        "config": {
            "N": N, "alphas": alphas, "n_instances": n_instances,
            "I_per_clause": I_per_clause,
            "cdcl_budgets": cdcl_budgets,
            "walksat_budgets": walksat_budgets,
            "random_budgets": random_budgets,
            "walksat_noise": 0.5, "walksat_restart_len": 1000,
            "timestamp": datetime.now().isoformat(),
            "total_time_sec": round(total_time, 1),
        },
        "solver_results": {
            "cdcl": {str(k): v for k, v in cdcl_data.items()},
            "walksat": {str(k): v for k, v in walksat_data.items()},
            "random": {str(k): v for k, v in random_data.items()},
        },
        "fit_results": fit_results,
    }

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"phase2c_solver_comparison_{timestamp}.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\nResults saved to {out_path}")


if __name__ == "__main__":
    run_experiment()
