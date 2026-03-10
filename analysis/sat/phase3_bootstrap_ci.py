#!/usr/bin/env python3
"""
Phase 3: Bootstrap confidence intervals for sensitivity exponent c.

For each (solver, N, α), collect per-instance runtimes.
Bootstrap resample medians → refit c (local slope α=3.5→4.0) → 95% CI.
Test: is c_CDCL > c_WalkSAT statistically significant at each N?

Output: per-instance runtimes + bootstrap CI for c.
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

RESULTS_DIR = Path(__file__).parent.parent / "results"
I_CLAUSE = math.log(8 / 7)  # ≈ 0.1335 nats


def generate_random_3sat(n: int, alpha: float, seed: int) -> CNF:
    rng = random.Random(seed)
    m = int(alpha * n)
    cnf = CNF()
    for _ in range(m):
        vars_used = rng.sample(range(1, n + 1), 3)
        clause = [v if rng.random() > 0.5 else -v for v in vars_used]
        cnf.append(clause)
    return cnf


def solve_cdcl(cnf: CNF) -> dict:
    """Solve with CDCL, return stats."""
    s = Minisat22(bootstrap_with=cnf)
    result = s.solve()
    stats = s.accum_stats()
    s.delete()
    return {"sat": result, "conflicts": stats["conflicts"]}


def solve_walksat(cnf: CNF, n: int, max_flips: int = 500000,
                  noise: float = 0.5, restart_len: int = 1000) -> dict:
    """Solve with WalkSAT, return flips count."""
    rng = random.Random()
    clauses = cnf.clauses
    m = len(clauses)

    # Initialize random assignment
    assignment = [False] + [rng.random() < 0.5 for _ in range(n)]

    def is_satisfied(clause):
        for lit in clause:
            if (lit > 0 and assignment[abs(lit)]) or (lit < 0 and not assignment[abs(lit)]):
                return True
        return False

    def get_unsat_clauses():
        return [i for i in range(m) if not is_satisfied(clauses[i])]

    for flip in range(1, max_flips + 1):
        if flip % restart_len == 0:
            assignment = [False] + [rng.random() < 0.5 for _ in range(n)]

        unsat = get_unsat_clauses()
        if not unsat:
            return {"sat": True, "flips": flip}

        # Pick random unsatisfied clause
        clause = clauses[rng.choice(unsat)]

        if rng.random() < noise:
            # Random walk: flip random variable in clause
            var = abs(rng.choice(clause))
        else:
            # Greedy: flip variable that minimizes breaks
            best_var = abs(clause[0])
            best_breaks = float('inf')
            for lit in clause:
                var = abs(lit)
                assignment[var] = not assignment[var]
                breaks = len(get_unsat_clauses())
                assignment[var] = not assignment[var]
                if breaks < best_breaks:
                    best_breaks = breaks
                    best_var = var
            var = best_var

        assignment[var] = not assignment[var]

    return {"sat": False, "flips": max_flips}


def collect_runtimes(n: int, alpha: float, n_instances: int,
                     solver: str) -> dict:
    """Collect per-instance runtimes for one (solver, N, α) setting."""
    delta = alpha * n * I_CLAUSE
    runtimes = []
    n_sat = 0
    n_solved = 0

    for seed in range(n_instances):
        cnf = generate_random_3sat(n, alpha, seed * 1000 + n)

        if solver == "cdcl":
            result = solve_cdcl(cnf)
            if result["sat"]:
                n_sat += 1
                n_solved += 1
                runtimes.append(result["conflicts"])
        else:  # walksat
            # First check satisfiability with CDCL
            check = solve_cdcl(cnf)
            if check["sat"]:
                n_sat += 1
                result = solve_walksat(cnf, n)
                if result["sat"]:
                    n_solved += 1
                    runtimes.append(result["flips"])

    return {
        "alpha": alpha,
        "delta": round(delta, 2),
        "n_instances": n_instances,
        "n_sat": n_sat,
        "n_solved": n_solved,
        "solve_rate": round(n_solved / n_sat, 4) if n_sat > 0 else 0,
        "runtimes": runtimes,
        "median": float(np.median(runtimes)) if runtimes else None,
        "p25": float(np.percentile(runtimes, 25)) if runtimes else None,
        "p75": float(np.percentile(runtimes, 75)) if runtimes else None,
    }


def bootstrap_slope(runtimes_lo: list, runtimes_hi: list,
                    delta_lo: float, delta_hi: float,
                    n_bootstrap: int = 10000) -> dict:
    """Bootstrap CI for local slope c = (ln med_hi - ln med_lo) / (delta_hi - delta_lo)."""
    rng = np.random.RandomState(42)
    arr_lo = np.array(runtimes_lo)
    arr_hi = np.array(runtimes_hi)
    n_lo = len(arr_lo)
    n_hi = len(arr_hi)

    slopes = []
    for _ in range(n_bootstrap):
        med_lo = np.median(rng.choice(arr_lo, size=n_lo, replace=True))
        med_hi = np.median(rng.choice(arr_hi, size=n_hi, replace=True))
        if med_lo > 0 and med_hi > 0:
            c = (np.log(med_hi) - np.log(med_lo)) / (delta_hi - delta_lo)
            slopes.append(c)

    slopes = np.array(slopes)
    return {
        "mean": float(np.mean(slopes)),
        "std": float(np.std(slopes)),
        "ci_025": float(np.percentile(slopes, 2.5)),
        "ci_975": float(np.percentile(slopes, 97.5)),
        "median": float(np.median(slopes)),
        "n_valid": len(slopes),
    }


def bootstrap_difference(runtimes_cdcl_lo, runtimes_cdcl_hi,
                         runtimes_ws_lo, runtimes_ws_hi,
                         delta_lo, delta_hi,
                         n_bootstrap=10000):
    """Bootstrap CI for (c_CDCL - c_WalkSAT) at given N."""
    rng = np.random.RandomState(42)
    arr_cl = np.array(runtimes_cdcl_lo)
    arr_ch = np.array(runtimes_cdcl_hi)
    arr_wl = np.array(runtimes_ws_lo)
    arr_wh = np.array(runtimes_ws_hi)

    diffs = []
    for _ in range(n_bootstrap):
        med_cl = np.median(rng.choice(arr_cl, size=len(arr_cl), replace=True))
        med_ch = np.median(rng.choice(arr_ch, size=len(arr_ch), replace=True))
        med_wl = np.median(rng.choice(arr_wl, size=len(arr_wl), replace=True))
        med_wh = np.median(rng.choice(arr_wh, size=len(arr_wh), replace=True))

        if all(v > 0 for v in [med_cl, med_ch, med_wl, med_wh]):
            c_cdcl = (np.log(med_ch) - np.log(med_cl)) / (delta_hi - delta_lo)
            c_ws = (np.log(med_wh) - np.log(med_wl)) / (delta_hi - delta_lo)
            diffs.append(c_cdcl - c_ws)

    diffs = np.array(diffs)
    p_positive = float(np.mean(diffs > 0))
    return {
        "mean_diff": float(np.mean(diffs)),
        "ci_025": float(np.percentile(diffs, 2.5)),
        "ci_975": float(np.percentile(diffs, 97.5)),
        "p_cdcl_gt_ws": p_positive,
        "n_valid": len(diffs),
    }


def main():
    Ns = [100, 200, 300]
    alphas = [3.5, 4.0]  # Floor-free regime
    n_instances = 200
    n_bootstrap = 10000

    print(f"Phase 3: Bootstrap CI for c")
    print(f"  Ns = {Ns}, alphas = {alphas}")
    print(f"  n_instances = {n_instances}, n_bootstrap = {n_bootstrap}")
    print()

    t0 = time.time()
    results = {}

    for N in Ns:
        results[N] = {"cdcl": {}, "walksat": {}}

        for alpha in alphas:
            delta = alpha * N * I_CLAUSE

            # CDCL
            print(f"  CDCL N={N} α={alpha}...", end=" ", flush=True)
            t1 = time.time()
            cdcl_data = collect_runtimes(N, alpha, n_instances, "cdcl")
            print(f"done ({time.time()-t1:.1f}s, "
                  f"n_sat={cdcl_data['n_sat']}, "
                  f"median={cdcl_data['median']})")
            results[N]["cdcl"][alpha] = cdcl_data

            # WalkSAT
            print(f"  WalkSAT N={N} α={alpha}...", end=" ", flush=True)
            t1 = time.time()
            ws_data = collect_runtimes(N, alpha, n_instances, "walksat")
            print(f"done ({time.time()-t1:.1f}s, "
                  f"n_sat={ws_data['n_sat']}, "
                  f"median={ws_data['median']})")
            results[N]["walksat"][alpha] = ws_data

        print()

    # Bootstrap analysis
    print("Bootstrap analysis...")
    bootstrap_results = {}

    for N in Ns:
        delta_lo = alphas[0] * N * I_CLAUSE
        delta_hi = alphas[1] * N * I_CLAUSE

        # CDCL bootstrap
        cdcl_lo = results[N]["cdcl"][alphas[0]]["runtimes"]
        cdcl_hi = results[N]["cdcl"][alphas[1]]["runtimes"]
        cdcl_boot = bootstrap_slope(cdcl_lo, cdcl_hi, delta_lo, delta_hi,
                                    n_bootstrap)

        # WalkSAT bootstrap
        ws_lo = results[N]["walksat"][alphas[0]]["runtimes"]
        ws_hi = results[N]["walksat"][alphas[1]]["runtimes"]
        ws_boot = bootstrap_slope(ws_lo, ws_hi, delta_lo, delta_hi,
                                  n_bootstrap)

        # Difference test
        diff_boot = bootstrap_difference(cdcl_lo, cdcl_hi, ws_lo, ws_hi,
                                         delta_lo, delta_hi, n_bootstrap)

        bootstrap_results[N] = {
            "cdcl": cdcl_boot,
            "walksat": ws_boot,
            "difference": diff_boot,
        }

        print(f"  N={N}:")
        print(f"    CDCL c = {cdcl_boot['mean']:.4f} "
              f"[{cdcl_boot['ci_025']:.4f}, {cdcl_boot['ci_975']:.4f}]")
        print(f"    WalkSAT c = {ws_boot['mean']:.4f} "
              f"[{ws_boot['ci_025']:.4f}, {ws_boot['ci_975']:.4f}]")
        print(f"    Δc = {diff_boot['mean_diff']:.4f} "
              f"[{diff_boot['ci_025']:.4f}, {diff_boot['ci_975']:.4f}]")
        print(f"    P(c_CDCL > c_WalkSAT) = {diff_boot['p_cdcl_gt_ws']:.4f}")

    total_time = time.time() - t0

    # Save results
    output = {
        "config": {
            "Ns": Ns,
            "alphas": alphas,
            "n_instances": n_instances,
            "n_bootstrap": n_bootstrap,
            "purpose": "Bootstrap CI for c (local slope α=3.5→4.0)",
            "timestamp": datetime.now().isoformat(),
            "total_time_sec": round(total_time, 1),
        },
        "runtimes": {
            str(N): {
                "cdcl": {
                    str(a): results[N]["cdcl"][a] for a in alphas
                },
                "walksat": {
                    str(a): results[N]["walksat"][a] for a in alphas
                },
            } for N in Ns
        },
        "bootstrap": {
            str(N): bootstrap_results[N] for N in Ns
        },
    }

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    outpath = RESULTS_DIR / f"phase3_bootstrap_ci_{ts}.json"
    with open(outpath, "w") as f:
        json.dump(output, f, indent=2)
    print(f"\nSaved to {outpath}")
    print(f"Total time: {total_time:.1f}s")


if __name__ == "__main__":
    main()
