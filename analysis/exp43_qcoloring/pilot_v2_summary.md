# Exp43 q-coloring pilot v2 summary

Status: pilot outcome summary, not primary data and not preregistration freeze.

Date: 2026-04-22

## 1. Configuration

Pilot v2 used the fallback selected in `pilot_v1_addendum.md`:

```text
n in {40,80}

q=3: rho_fm in {0.40,0.50,0.60,0.70,0.80,0.90}
q=4: rho_fm in {0.40,0.50,0.60,0.70,0.80,0.90}
q=5: rho_fm in {0.80,0.90,1.00,1.10,1.20,1.30}

instances_per_cell = 50
timeout = 120 seconds
```

The run completed 1,800 records:

```text
SAT: 955
UNSAT: 844
TIMEOUT: 1
MALFORMED: 0
ERROR: 0
SAT coloring_verified: 955/955
```

## 2. Gate result

The pilot_v2 run did not pass the preregistered pilot gate:

```text
pilot_pass = false
inconclusive_by_30pct_rule = false
suspended_cell_count = 0 / 36
```

Timeout behavior improved substantially relative to pilot_v1. The only timeout
occurred in `(q=5, n=80, rho_fm=0.90)`, giving `1/50 = 2%` for that cell, below
the 5% suspension threshold.

The remaining failure is not tractability. It is band placement:

```text
informative_rho_bands_by_q:
  q=3: {0.60, 0.70, 0.80}
  q=4: {0.80}
  q=5: {0.80}
```

Thus q=4 and q=5 still do not have the required two informative rho bands.

## 3. Cell summary

| q | n | rho_fm | solved | colorability rate | timeouts |
|---|---:|---:|---:|---:|---:|
| 3 | 40 | 0.40 | 50 | 1.00 | 0 |
| 3 | 40 | 0.50 | 50 | 1.00 | 0 |
| 3 | 40 | 0.60 | 50 | 0.94 | 0 |
| 3 | 40 | 0.70 | 50 | 0.74 | 0 |
| 3 | 40 | 0.80 | 50 | 0.46 | 0 |
| 3 | 40 | 0.90 | 50 | 0.00 | 0 |
| 3 | 80 | 0.40 | 50 | 1.00 | 0 |
| 3 | 80 | 0.50 | 50 | 1.00 | 0 |
| 3 | 80 | 0.60 | 50 | 0.96 | 0 |
| 3 | 80 | 0.70 | 50 | 1.00 | 0 |
| 3 | 80 | 0.80 | 50 | 0.58 | 0 |
| 3 | 80 | 0.90 | 50 | 0.02 | 0 |
| 4 | 40 | 0.40 | 50 | 1.00 | 0 |
| 4 | 40 | 0.50 | 50 | 1.00 | 0 |
| 4 | 40 | 0.60 | 50 | 1.00 | 0 |
| 4 | 40 | 0.70 | 50 | 1.00 | 0 |
| 4 | 40 | 0.80 | 50 | 0.32 | 0 |
| 4 | 40 | 0.90 | 50 | 0.02 | 0 |
| 4 | 80 | 0.40 | 50 | 1.00 | 0 |
| 4 | 80 | 0.50 | 50 | 1.00 | 0 |
| 4 | 80 | 0.60 | 50 | 1.00 | 0 |
| 4 | 80 | 0.70 | 50 | 1.00 | 0 |
| 4 | 80 | 0.80 | 50 | 0.96 | 0 |
| 4 | 80 | 0.90 | 50 | 0.00 | 0 |
| 5 | 40 | 0.80 | 50 | 0.10 | 0 |
| 5 | 40 | 0.90 | 50 | 0.00 | 0 |
| 5 | 40 | 1.00 | 50 | 0.00 | 0 |
| 5 | 40 | 1.10 | 50 | 0.00 | 0 |
| 5 | 40 | 1.20 | 50 | 0.00 | 0 |
| 5 | 40 | 1.30 | 50 | 0.00 | 0 |
| 5 | 80 | 0.80 | 50 | 1.00 | 0 |
| 5 | 80 | 0.90 | 49 | 0.00 | 1 |
| 5 | 80 | 1.00 | 50 | 0.00 | 0 |
| 5 | 80 | 1.10 | 50 | 0.00 | 0 |
| 5 | 80 | 1.20 | 50 | 0.00 | 0 |
| 5 | 80 | 1.30 | 50 | 0.00 | 0 |

## 4. Interpretation

Pilot_v2 solved the timeout problem but showed that the precommitted fallback
grids are still too coarse for q=4 and q=5. The transition region is narrow:

- q=4 needs finer resolution around rho_fm between roughly 0.80 and 0.90.
- q=5 shows a finite-size split: at n=40, rho_fm=0.80 is already close to the
  upper edge of the transition; at n=80, rho_fm=0.80 is still saturated SAT
  while rho_fm=0.90 is saturated UNSAT.

Because this second pilot still failed the pilot gate, the clean preregistration
move is not to keep tuning silently. The next step should be either:

1. mark the current Exp43 pilot-calibration phase as inconclusive and write a
   new freeze-ready preregistration using q-specific finer grids learned from
   pilot_v1/v2, or
2. explicitly downgrade any further grid search to exploratory calibration,
   then freeze only after a new preregistered design is fixed before primary
   data.

Primary data must not be generated from the current grid.
