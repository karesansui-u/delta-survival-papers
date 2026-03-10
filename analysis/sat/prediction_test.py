"""
Prediction test for Paper 2: Train on N=100+200, predict N=300.

Tests whether the model ln(mu_c) = c*delta + g(n) has predictive power,
not just descriptive (post-hoc fit) power.

Two tests:
1. Cross-N prediction: Train on N=100,200 -> predict N=300
2. Leave-one-alpha-out: Within each N, predict held-out alpha
"""

import json
import numpy as np
from pathlib import Path

RESULTS_DIR = Path(__file__).parent.parent / "results"
I_PER_CLAUSE = np.log(8/7)  # |ln(7/8)| = ln(8/7)


def load_cdcl_data(common_alphas_only=False):
    """Load CDCL median conflicts at each (alpha, N).

    If common_alphas_only=True, use only alpha values common to all N
    (3.0, 3.5, 4.0) to ensure fair comparison.
    """
    COMMON_ALPHAS = {3.0, 3.5, 4.0}

    # N=100, N=200 from phase2_n_scaling
    with open(RESULTS_DIR / "phase2_n_scaling_20260308_022448.json") as f:
        d12 = json.load(f)

    # N=300 from phase2a_n300
    with open(RESULTS_DIR / "phase2a_n300_20260308_141122.json") as f:
        d3 = json.load(f)

    data = {}
    for key, n_val in [("N=100", 100), ("N=200", 200)]:
        entries = []
        for row in d12["results"][key]["mu_c_sat_only"]:
            if row["med_conflicts"] <= 1 or row["n_sat"] < 10:
                continue
            if row["alpha"] < 3.0:
                continue
            if common_alphas_only and row["alpha"] not in COMMON_ALPHAS:
                continue
            entries.append({
                "alpha": row["alpha"],
                "delta": row["delta"],
                "ln_mu_c": np.log(row["med_conflicts"]),
                "mu_c": row["med_conflicts"],
                "n_sat": row["n_sat"],
            })
        data[n_val] = entries

    entries_300 = []
    for row in d3["mu_c_data"]:
        if row["med_conflicts"] <= 1:
            continue
        if common_alphas_only and row["alpha"] not in COMMON_ALPHAS:
            continue
        entries_300.append({
            "alpha": row["alpha"],
            "delta": row["delta"],
            "ln_mu_c": np.log(row["med_conflicts"]),
            "mu_c": row["med_conflicts"],
            "n_sat": row["n_sat"],
        })
    data[300] = entries_300

    return data


def load_walksat_data():
    """Load WalkSAT median flips at each (alpha, N)."""
    with open(RESULTS_DIR / "phase2a_walksat_nscaling_20260308_182044.json") as f:
        d = json.load(f)

    data = {}
    for n_str, n_val in [("100", 100), ("200", 200), ("300", 300)]:
        entries = []
        for row in d["results_by_N"][n_str]["mu_c_data"]:
            if row["med_flips"] > 0 and row["solve_rate"] >= 0.5:
                entries.append({
                    "alpha": row["alpha"],
                    "delta": row["delta"],
                    "ln_mu_c": np.log(row["med_flips"]),
                    "mu_c": row["med_flips"],
                    "solve_rate": row["solve_rate"],
                })
        data[n_val] = entries

    return data


def fit_linear(deltas, ln_mu_cs):
    """Fit ln(mu_c) = c*delta + a. Returns (c, a, R2)."""
    deltas = np.array(deltas)
    ln_mu_cs = np.array(ln_mu_cs)
    A = np.column_stack([deltas, np.ones(len(deltas))])
    params, residuals, _, _ = np.linalg.lstsq(A, ln_mu_cs, rcond=None)
    c, a = params
    ss_res = np.sum((ln_mu_cs - (c * deltas + a))**2)
    ss_tot = np.sum((ln_mu_cs - np.mean(ln_mu_cs))**2)
    r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 0
    return c, a, r2


def cross_n_prediction(data, solver_name):
    """Train on N=100+200, predict N=300."""
    print(f"\n{'='*60}")
    print(f"Cross-N Prediction Test: {solver_name}")
    print(f"{'='*60}")

    # Step 1: Fit separately at each N
    print("\n--- Per-N fits ---")
    fits = {}
    for n_val in sorted(data.keys()):
        entries = data[n_val]
        deltas = [e["delta"] for e in entries]
        ln_mu_cs = [e["ln_mu_c"] for e in entries]
        c, a, r2 = fit_linear(deltas, ln_mu_cs)
        fits[n_val] = (c, a, r2)
        alphas_str = ", ".join(f"{e['alpha']}" for e in entries)
        print(f"  N={n_val}: c={c:.4f}, a={a:.2f}, R2={r2:.4f}  "
              f"(alphas: {alphas_str})")

    # Step 2: Train model on N=100+200
    train_ns = [100, 200]
    test_n = 300

    # Method A: Average c, linear extrapolation of a
    c_train = np.mean([fits[n][0] for n in train_ns])
    a_values = [(n, fits[n][1]) for n in train_ns]

    # Linear fit of a vs n
    ns_train = np.array([n for n, _ in a_values])
    as_train = np.array([a for _, a in a_values])
    slope_a = (as_train[1] - as_train[0]) / (ns_train[1] - ns_train[0])
    a_pred_300 = as_train[1] + slope_a * (test_n - ns_train[1])

    print(f"\n--- Training model (N=100+200) ---")
    print(f"  c_bar = {c_train:.4f}")
    print(f"  a(n) slope = {slope_a:.4f}")
    print(f"  a(300) predicted = {a_pred_300:.2f}")
    print(f"  a(300) actual    = {fits[test_n][1]:.2f}")
    print(f"  a(300) error     = {a_pred_300 - fits[test_n][1]:.2f}")

    # Method B: Pooled regression ln(mu_c) = c*delta + b*n + a0
    all_deltas = []
    all_ns = []
    all_ln_mu_cs = []
    for n_val in train_ns:
        for e in data[n_val]:
            all_deltas.append(e["delta"])
            all_ns.append(n_val)
            all_ln_mu_cs.append(e["ln_mu_c"])

    all_deltas = np.array(all_deltas)
    all_ns = np.array(all_ns)
    all_ln_mu_cs = np.array(all_ln_mu_cs)

    A_mat = np.column_stack([all_deltas, all_ns, np.ones(len(all_deltas))])
    params, _, _, _ = np.linalg.lstsq(A_mat, all_ln_mu_cs, rcond=None)
    c_pooled, b_pooled, a0_pooled = params
    ss_res = np.sum((all_ln_mu_cs - (c_pooled * all_deltas + b_pooled * all_ns + a0_pooled))**2)
    ss_tot = np.sum((all_ln_mu_cs - np.mean(all_ln_mu_cs))**2)
    r2_pooled = 1 - ss_res / ss_tot

    print(f"\n--- Pooled regression (N=100+200) ---")
    print(f"  ln(mu_c) = {c_pooled:.4f}*delta + ({b_pooled:.4f})*n + ({a0_pooled:.2f})")
    print(f"  R2 = {r2_pooled:.4f}")
    print(f"  N_train = {len(all_deltas)}")

    # Step 3: Predict N=300
    print(f"\n--- Predictions for N={test_n} ---")
    print(f"  {'alpha':>5}  {'delta':>7}  {'ln_mc_pred':>10}  {'ln_mc_act':>9}  "
          f"{'err_log':>8}  {'mc_pred':>8}  {'mc_act':>8}  {'ratio':>6}")

    errors_log = []
    errors_ratio = []
    for e in data[test_n]:
        # Method B (pooled)
        ln_pred = c_pooled * e["delta"] + b_pooled * test_n + a0_pooled
        ln_act = e["ln_mu_c"]
        err_log = ln_pred - ln_act
        mc_pred = np.exp(ln_pred)
        ratio = mc_pred / e["mu_c"]

        errors_log.append(err_log)
        errors_ratio.append(ratio)

        print(f"  {e['alpha']:5.2f}  {e['delta']:7.2f}  {ln_pred:10.3f}  {ln_act:9.3f}  "
              f"{err_log:+8.3f}  {mc_pred:8.1f}  {e['mu_c']:8.1f}  {ratio:6.2f}x")

    rmse_log = np.sqrt(np.mean(np.array(errors_log)**2))
    mean_abs_log = np.mean(np.abs(errors_log))
    median_ratio = np.median(np.abs(np.array(errors_ratio) - 1))

    print(f"\n--- Summary ---")
    print(f"  RMSE (log space):  {rmse_log:.3f}  (= factor of {np.exp(rmse_log):.2f}x)")
    print(f"  MAE  (log space):  {mean_abs_log:.3f}  (= factor of {np.exp(mean_abs_log):.2f}x)")
    print(f"  Median |ratio-1|:  {median_ratio:.2f}")

    return {
        "solver": solver_name,
        "c_pooled": c_pooled,
        "b_pooled": b_pooled,
        "a0_pooled": a0_pooled,
        "r2_pooled": r2_pooled,
        "per_n_fits": {str(n): {"c": c, "a": a, "r2": r2} for n, (c, a, r2) in fits.items()},
        "predictions_n300": [
            {
                "alpha": e["alpha"],
                "delta": e["delta"],
                "ln_mu_c_pred": float(c_pooled * e["delta"] + b_pooled * test_n + a0_pooled),
                "ln_mu_c_actual": float(e["ln_mu_c"]),
                "error_log": float(c_pooled * e["delta"] + b_pooled * test_n + a0_pooled - e["ln_mu_c"]),
                "mu_c_pred": float(np.exp(c_pooled * e["delta"] + b_pooled * test_n + a0_pooled)),
                "mu_c_actual": float(e["mu_c"]),
                "ratio": float(np.exp(c_pooled * e["delta"] + b_pooled * test_n + a0_pooled) / e["mu_c"]),
            }
            for e in data[test_n]
        ],
        "rmse_log": float(rmse_log),
        "mae_log": float(mean_abs_log),
        "factor_rmse": float(np.exp(rmse_log)),
    }


def leave_one_alpha_out(data, solver_name):
    """Within each N, predict held-out alpha value."""
    print(f"\n{'='*60}")
    print(f"Leave-One-Alpha-Out: {solver_name}")
    print(f"{'='*60}")

    results = {}
    for n_val in sorted(data.keys()):
        entries = data[n_val]
        if len(entries) < 3:
            print(f"\n  N={n_val}: too few points ({len(entries)}), skipping")
            continue

        print(f"\n  N={n_val} ({len(entries)} alpha values):")
        errors = []
        for i in range(len(entries)):
            train = [e for j, e in enumerate(entries) if j != i]
            test = entries[i]

            deltas_tr = [e["delta"] for e in train]
            ln_tr = [e["ln_mu_c"] for e in train]
            c, a, _ = fit_linear(deltas_tr, ln_tr)

            ln_pred = c * test["delta"] + a
            err = ln_pred - test["ln_mu_c"]
            errors.append(err)

            ratio = np.exp(ln_pred) / test["mu_c"]
            print(f"    held-out alpha={test['alpha']:.2f}: "
                  f"pred={np.exp(ln_pred):.1f}, actual={test['mu_c']:.1f}, "
                  f"ratio={ratio:.2f}x, log_err={err:+.3f}")

        rmse = np.sqrt(np.mean(np.array(errors)**2))
        print(f"    RMSE(log) = {rmse:.3f} (= factor {np.exp(rmse):.2f}x)")
        results[n_val] = {"rmse_log": float(rmse), "factor": float(np.exp(rmse))}

    return results


def main():
    from datetime import datetime

    # Run both: all alphas and common-only
    for mode, common_only in [("ALL_ALPHAS", False), ("COMMON_ALPHAS_ONLY", True)]:
        print(f"\n{'#'*70}")
        print(f"# MODE: {mode}")
        print(f"{'#'*70}")

        cdcl_data = load_cdcl_data(common_alphas_only=common_only)
        walksat_data = load_walksat_data()
        if common_only:
            # Also filter WalkSAT to common alphas
            common = {3.0, 3.5, 4.0}
            for n in walksat_data:
                walksat_data[n] = [e for e in walksat_data[n]
                                   if e["alpha"] in common]

        print("\nData loaded:")
        for n in sorted(cdcl_data.keys()):
            print(f"  CDCL  N={n}: {len(cdcl_data[n])} alpha values "
                  f"(alphas: {[e['alpha'] for e in cdcl_data[n]]})")
        for n in sorted(walksat_data.keys()):
            print(f"  WalkSAT N={n}: {len(walksat_data[n])} alpha values "
                  f"(alphas: {[e['alpha'] for e in walksat_data[n]]})")

        # Cross-N prediction
        cdcl_cross = cross_n_prediction(cdcl_data, f"CDCL [{mode}]")
        ws_cross = cross_n_prediction(walksat_data, f"WalkSAT [{mode}]")

        # Leave-one-alpha-out
        cdcl_loo = leave_one_alpha_out(cdcl_data, f"CDCL [{mode}]")
        ws_loo = leave_one_alpha_out(walksat_data, f"WalkSAT [{mode}]")

        # Key comparison
        print(f"\n{'='*60}")
        print(f"COMPARISON [{mode}]: Cross-N (N=100+200 → N=300)")
        print(f"{'='*60}")
        print(f"  CDCL:    RMSE(log)={cdcl_cross['rmse_log']:.3f}  "
              f"(factor {cdcl_cross['factor_rmse']:.2f}x)")
        print(f"  WalkSAT: RMSE(log)={ws_cross['rmse_log']:.3f}  "
              f"(factor {ws_cross['factor_rmse']:.2f}x)")

        # c stability check
        print(f"\n  c stability:")
        for solver, cross in [("CDCL", cdcl_cross), ("WalkSAT", ws_cross)]:
            cs = [cross["per_n_fits"][str(n)]["c"] for n in [100, 200, 300]]
            c_range = (max(cs) - min(cs)) / np.mean(cs) * 100
            print(f"    {solver}: c = {cs} -> range {c_range:.1f}%")

    # Save
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    outpath = RESULTS_DIR / f"prediction_test_{timestamp}.json"
    print(f"\n(Results saved to {outpath})")


if __name__ == "__main__":
    main()
