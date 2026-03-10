#!/usr/bin/env python3
"""
Phase 2C補足: α_d付近の高解像度ソルバー比較

WalkSATのcがα_d(≈3.86)付近で急変することを高解像度で確認し、
CDCLのcの安定性と対比する。

α = [3.7, 3.75, 3.8, 3.85, 3.86, 3.9, 3.95, 4.0], N=100, 100 instances
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
        vs = rng.sample(range(1, n + 1), 3)
        cl = [v if rng.random() > 0.5 else -v for v in vs]
        cnf.append(cl)
    return cnf


def solve_unlimited(cnf):
    s = Minisat22(bootstrap_with=cnf)
    result = s.solve()
    stats = s.accum_stats()
    s.delete()
    return {"sat": result, "conflicts": stats.get("conflicts", 0)}


def walksat(clauses, n_vars, max_flips, noise=0.5, seed=None):
    rng = random.Random(seed)
    assignment = [False] + [rng.random() > 0.5 for _ in range(n_vars)]

    clause_list = []
    for cl in clauses:
        clause_list.append(cl)

    def satisfied(lit):
        return (lit > 0) == assignment[abs(lit)]

    def count_unsat():
        return [i for i, cl in enumerate(clause_list) if not any(satisfied(l) for l in cl)]

    for flip in range(1, max_flips + 1):
        unsat = count_unsat()
        if not unsat:
            return True, flip

        ci = rng.choice(unsat)
        clause = clause_list[ci]

        if rng.random() < noise:
            var = abs(rng.choice(clause))
        else:
            best_var = None
            best_breaks = float("inf")
            for lit in clause:
                var = abs(lit)
                assignment[var] = not assignment[var]
                breaks = len(count_unsat())
                assignment[var] = not assignment[var]
                if breaks < best_breaks:
                    best_breaks = breaks
                    best_var = var
            var = best_var

        assignment[var] = not assignment[var]

    return False, max_flips


def walksat_with_restarts(clauses, n_vars, max_flips, noise=0.5, restart_len=1000, seed=None):
    rng = random.Random(seed)
    total_flips = 0
    while total_flips < max_flips:
        remaining = min(restart_len, max_flips - total_flips)
        found, flips = walksat(clauses, n_vars, remaining, noise, seed=rng.randint(0, 2**31))
        total_flips += flips
        if found:
            return True, total_flips
    return False, max_flips


def run_experiment():
    N = 100
    # Fine grid around alpha_d ≈ 3.86
    alphas = [3.7, 3.75, 3.8, 3.85, 3.86, 3.9, 3.95, 4.0]
    n_instances = 100
    base_seed = 20260308_2

    I_per_clause = abs(math.log(7 / 8))

    print(f"Phase 2C fine grid: alpha_d region (N={N}, {n_instances} instances)")
    print(f"  alphas: {alphas}")
    print()

    t_start = time.time()

    # Phase 1: SAT/UNSAT
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

    # --- CDCL ---
    print("CDCL (MiniSat)...")
    t_cdcl = time.time()
    cdcl_data = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            continue

        runtimes = []
        for i in sat_indices:
            seed = base_seed + ai * 100000 + i
            cnf = generate_random_3sat(N, alpha, seed)
            s = Minisat22(bootstrap_with=cnf)
            s.solve()
            stats = s.accum_stats()
            s.delete()
            runtimes.append(stats.get("conflicts", 0))

        med_runtime = float(np.median(runtimes))
        cdcl_data[alpha] = {"n_sat": n_sat, "med_runtime": med_runtime}
        print(f"  alpha={alpha:.2f}: mu_c={med_runtime:.0f} conflicts")

    print(f"  CDCL done: {time.time()-t_cdcl:.1f}s\n")

    # --- WalkSAT ---
    print("WalkSAT (noise=0.5, restart_len=1000)...")
    t_ws = time.time()
    walksat_data = {}
    for ai, alpha in enumerate(alphas):
        sat_indices = [i for i in range(n_instances) if instance_info[(ai, i)]["sat"]]
        n_sat = len(sat_indices)
        if n_sat == 0:
            continue

        unlimited_flips = []
        for i in sat_indices:
            seed = base_seed + ai * 100000 + i
            cnf = generate_random_3sat(N, alpha, seed)
            found, flips = walksat_with_restarts(
                cnf.clauses, N, max_flips=1_000_000, noise=0.5,
                restart_len=1000, seed=seed + 999
            )
            if found:
                unlimited_flips.append(flips)

        if not unlimited_flips:
            print(f"  alpha={alpha:.2f}: WalkSAT found 0 solutions (skipping)")
            continue

        med_flips = float(np.median(unlimited_flips))
        solve_rate = len(unlimited_flips) / n_sat

        walksat_data[alpha] = {
            "n_sat": n_sat,
            "med_runtime": med_flips,
            "unlimited_solve_rate": round(solve_rate, 4),
            "n_solved_unlimited": len(unlimited_flips),
        }
        print(f"  alpha={alpha:.2f}: mu_c={med_flips:.0f} flips, solve_rate={solve_rate:.2f}")

    print(f"  WalkSAT done: {time.time()-t_ws:.1f}s\n")

    # === Analysis: local slopes ===
    total_time = time.time() - t_start
    print(f"Total time: {total_time:.1f}s\n")

    print("=" * 80)
    print("Local slopes (c_local) by solver")
    print("=" * 80)

    for solver_name, solver_data in [("CDCL", cdcl_data), ("WalkSAT", walksat_data)]:
        print(f"\n  {solver_name}:")
        alphas_sorted = sorted(solver_data.keys())
        local_slopes = []
        for j in range(len(alphas_sorted) - 1):
            a1, a2 = alphas_sorted[j], alphas_sorted[j + 1]
            d1 = a1 * N * I_per_clause
            d2 = a2 * N * I_per_clause
            m1 = solver_data[a1]["med_runtime"]
            m2 = solver_data[a2]["med_runtime"]
            if m1 > 0 and m2 > 0:
                c_local = (math.log(m2) - math.log(m1)) / (d2 - d1)
                local_slopes.append({"from": a1, "to": a2, "c_local": round(c_local, 4)})
                print(f"    alpha={a1:.2f} -> {a2:.2f}: c_local = {c_local:.4f}")

    # Global fits
    print(f"\n{'='*80}")
    print("Global fits: ln(mu_c) = c*delta + intercept")
    print(f"{'='*80}")

    fit_results = {}
    for solver_name, solver_data in [("CDCL", cdcl_data), ("WalkSAT", walksat_data)]:
        deltas = []
        ln_mu_c = []
        for alpha in sorted(solver_data.keys()):
            delta = alpha * N * I_per_clause
            mu_c = solver_data[alpha]["med_runtime"]
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
            print(f"  {solver_name:>10}: c = {c_val:.4f}, R^2 = {r_sq:.4f}  ({len(deltas)} points)")
            fit_results[solver_name.lower()] = {
                "c": round(c_val, 4), "intercept": round(intercept, 2),
                "r_squared": round(r_sq, 4), "n_points": len(deltas),
            }

    # Save
    output = {
        "config": {
            "N": N, "alphas": alphas, "n_instances": n_instances,
            "I_per_clause": I_per_clause,
            "purpose": "Fine grid around alpha_d to resolve WalkSAT c-collapse",
            "timestamp": datetime.now().isoformat(),
            "total_time_sec": round(total_time, 1),
        },
        "solver_results": {
            "cdcl": {str(k): v for k, v in cdcl_data.items()},
            "walksat": {str(k): v for k, v in walksat_data.items()},
        },
        "fit_results": fit_results,
    }

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"phase2c_fine_grid_{timestamp}.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\nResults saved to {out_path}")


if __name__ == "__main__":
    run_experiment()
