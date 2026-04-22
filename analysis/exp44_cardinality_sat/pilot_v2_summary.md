# Exp44 Cardinality-SAT pilot v2 summary

Status: pilot calibration outcome, not primary data and not validation
evidence.

Date: 2026-04-23

## 1. Configuration

Pilot_v2 used the runtime-guard fallback selected after
`pilot_runtime_probe.md`:

```text
n in {60, 100}
rho_fm in {0.70, 0.85, 1.00, 1.15}
mixtures = M0_low, M1_low_med, M2_bal_low_med,
           M3_threeway_low, M4_threeway_med, M5_med_high
instances_per_cell = 50
timeout = 120 seconds
```

The run completed 2,400 records:

```text
SAT: 809
UNSAT: 1591
TIMEOUT: 0
MALFORMED: 0
SAT assignment_verified: 809 / 809
max runtime: 19.68 seconds
runtime-unstable cells: none
```

The decoder issue observed in the first pilot_v2 attempt was fixed before this
run by treating variables absent from the CNF as free variables with a
deterministic default assignment, then verifying the resulting assignment
against the original semantic constraints.

## 2. Gate result

Pilot_v2 did not pass the preregistered pilot gate:

```text
pilot_pass = false
inconclusive_by_30pct_rule = false
suspended_cell_count = 0 / 48
malformed_total = 0
monotone_mixture_count = 6 / 6
```

The remaining failure is not tractability, timeout, malformed encoding, or
monotonicity. It is band placement:

```text
informative_rho_bands_by_mixture:
  M0_low:          {1.00}
  M1_low_med:      {0.85}
  M2_bal_low_med:  {0.85}
  M3_threeway_low: {0.70, 0.85}
  M4_threeway_med: {0.70, 0.85}
  M5_med_high:     {0.70, 0.85}
```

Thus M3/M4/M5 pass the informative-band criterion, while M0/M1/M2 each need
one additional transition-band point.

## 3. Mixture-level SAT rates

Rates are aggregated over `n in {60,100}`.

| mixture | rho=0.70 | rho=0.85 | rho=1.00 | rho=1.15 |
|---|---:|---:|---:|---:|
| M0_low | 1.00 | 0.98 | 0.07 | 0.00 |
| M1_low_med | 1.00 | 0.88 | 0.02 | 0.00 |
| M2_bal_low_med | 1.00 | 0.79 | 0.03 | 0.00 |
| M3_threeway_low | 0.56 | 0.17 | 0.00 | 0.00 |
| M4_threeway_med | 0.84 | 0.20 | 0.00 | 0.00 |
| M5_med_high | 0.46 | 0.08 | 0.01 | 0.00 |

All mixtures are monotone non-increasing in `rho_fm`.

## 4. Interpretation

Pilot_v2 solved the runtime and decoder issues:

```text
timeout = 0
malformed = 0
runtime guard passed
monotonicity passed for all mixtures
```

The pilot still failed because the transition for the low-drift mixtures
M0/M1/M2 is too sharp for the coarse `rho_fm` grid. This matches the
precommitted fallback condition:

```text
Transition too sharp -> use fine grid
{0.70, 0.80, 0.90, 1.00, 1.10, 1.20}
with instances_per_cell = 50
```

## 5. Next step

Do not freeze the current pilot_v2 grid.

The clean next exploration step is pilot_v3:

```text
n in {60,100}
rho_fm in {0.70,0.80,0.90,1.00,1.10,1.20}
same six mixtures
instances_per_cell = 50
```

If pilot_v3 passes, the corresponding fine grid can be considered for freeze.
If pilot_v3 also fails, Exp44 should be marked calibration-inconclusive rather
than tuned silently.

