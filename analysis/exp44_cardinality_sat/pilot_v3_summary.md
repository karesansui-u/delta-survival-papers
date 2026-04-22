# Exp44 Cardinality-SAT pilot v3 summary

Status: pilot calibration outcome, not primary data and not validation
evidence.

Date: 2026-04-23

## 1. Configuration

Pilot_v3 used the precommitted fine-grid fallback after pilot_v2 showed that
the transition was too sharp for the coarse grid:

```text
n in {60, 100}
rho_fm in {0.70, 0.80, 0.90, 1.00, 1.10, 1.20}
mixtures = M0_low, M1_low_med, M2_bal_low_med,
           M3_threeway_low, M4_threeway_med, M5_med_high
instances_per_cell = 50
timeout = 120 seconds
```

The run completed 3,600 records:

```text
SAT: 1087
UNSAT: 2513
TIMEOUT: 0
MALFORMED: 0
SAT assignment_verified: 1087 / 1087
max runtime: 11.63 seconds
runtime-unstable cells: none
```

## 2. Gate result

Pilot_v3 did not pass the pilot gate:

```text
pilot_pass = false
inconclusive_by_30pct_rule = false
suspended_cell_count = 0 / 72
malformed_total = 0
monotone_mixture_count = 6 / 6
```

The failure mode is again band placement, not infrastructure:

```text
informative_rho_bands_by_mixture:
  M0_low:          {0.90}
  M1_low_med:      {0.90}
  M2_bal_low_med:  {0.90}
  M3_threeway_low: {0.70, 0.80, 0.90}
  M4_threeway_med: {0.70, 0.80, 0.90}
  M5_med_high:     {0.70, 0.80}
```

Thus M3/M4/M5 pass the informative-band criterion, but M0/M1/M2 still do not.

## 3. Mixture-level SAT rates

Rates are aggregated over `n in {60,100}`.

| mixture | rho=0.70 | rho=0.80 | rho=0.90 | rho=1.00 | rho=1.10 | rho=1.20 |
|---|---:|---:|---:|---:|---:|---:|
| M0_low | 1.00 | 1.00 | 0.79 | 0.04 | 0.00 | 0.00 |
| M1_low_med | 1.00 | 0.97 | 0.60 | 0.01 | 0.00 | 0.00 |
| M2_bal_low_med | 0.99 | 0.96 | 0.57 | 0.01 | 0.01 | 0.00 |
| M3_threeway_low | 0.54 | 0.29 | 0.08 | 0.00 | 0.00 | 0.00 |
| M4_threeway_med | 0.77 | 0.36 | 0.09 | 0.00 | 0.00 | 0.00 |
| M5_med_high | 0.52 | 0.21 | 0.05 | 0.01 | 0.00 | 0.00 |

All mixtures are monotone non-increasing in `rho_fm`.

## 4. Interpretation

Pilot_v3 showed that the Exp44 harness and solver path are robust:

```text
timeout = 0
malformed = 0
runtime guard passed
monotonicity passed for all mixtures
```

But the low-drift mixtures M0/M1/M2 still have a transition that is too sharp
for the precommitted fine grid. In particular, their second informative point
would likely require additional grid tuning between `rho_fm = 0.90` and
`rho_fm = 1.00`.

That further tuning was not precommitted in the current Exp44 draft.

## 5. Decision

Do not freeze the current Exp44 grid.

Do not run Exp44 primary data from this design.

The disciplined interpretation is:

```text
Exp44 has not failed as a theory test, because it has not entered validation.
The current Exp44 calibration design is inconclusive / not freeze-ready.
```

Any future Cardinality-SAT validation should be written as a new Exp44b
preregistration, explicitly treating Exp44 pilot_v1/v2/v3 as calibration and
fixing a new grid before primary data.

## 6. Recommended next options

The clean next options are:

1. Write Exp44b with a new low-drift-focused grid, explicitly derived from
   this calibration history.
2. Return to Exp43b q-coloring with a fine-grid preregistration.
3. Move to G4/G6 non-CSP formal mapping, since Route A width calibration has
   now produced useful but not validation-ready feedback.

Do not silently continue grid search inside the current Exp44 design.

