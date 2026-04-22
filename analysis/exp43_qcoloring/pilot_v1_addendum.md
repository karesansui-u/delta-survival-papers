# Exp43 q-coloring pilot v1 fallback addendum

Status: freeze-preparation addendum, not primary data.

Date: 2026-04-22

## 1. Trigger

The first pilot run used the draft pilot grid:

```text
q in {3,4,5}
n in {50,100}
rho_fm in {0.60,0.80,1.00}
instances_per_cell = 50
timeout = 120 seconds
```

The run completed 900 instances:

```text
SAT: 493
UNSAT: 403
TIMEOUT: 4
MALFORMED: 0
ERROR: 0
SAT coloring_verified: 493/493
```

The pilot did not pass the preregistered pilot gate:

```text
pilot_pass = false
inconclusive_by_30pct_rule = false
suspended_cell_count = 1 / 18
```

The failure had two components.

1. Each q had only one informative rho band. The informative band was rho_fm = 0.80 for q=3, q=4, and q=5.
2. The cell (q=5, n=100, rho_fm=1.00) had 4/50 timeouts, i.e. timeout_rate = 8%, exceeding the 5% cell tolerance.

The run is therefore not inconclusive, but it requires the preregistered fallback before freeze.

## 2. Pilot v1 cell summary

| q | n | rho_fm | solved | colorability rate | timeouts |
|---|---:|---:|---:|---:|---:|
| 3 | 50 | 0.60 | 50 | 1.00 | 0 |
| 3 | 50 | 0.80 | 50 | 0.46 | 0 |
| 3 | 50 | 1.00 | 50 | 0.00 | 0 |
| 3 | 100 | 0.60 | 50 | 1.00 | 0 |
| 3 | 100 | 0.80 | 50 | 0.68 | 0 |
| 3 | 100 | 1.00 | 50 | 0.00 | 0 |
| 4 | 50 | 0.60 | 50 | 1.00 | 0 |
| 4 | 50 | 0.80 | 50 | 0.46 | 0 |
| 4 | 50 | 1.00 | 50 | 0.00 | 0 |
| 4 | 100 | 0.60 | 50 | 1.00 | 0 |
| 4 | 100 | 0.80 | 50 | 1.00 | 0 |
| 4 | 100 | 1.00 | 50 | 0.00 | 0 |
| 5 | 50 | 0.60 | 50 | 1.00 | 0 |
| 5 | 50 | 0.80 | 50 | 0.26 | 0 |
| 5 | 50 | 1.00 | 50 | 0.00 | 0 |
| 5 | 100 | 0.60 | 50 | 1.00 | 0 |
| 5 | 100 | 0.80 | 50 | 1.00 | 0 |
| 5 | 100 | 1.00 | 46 | 0.00 | 4 |

## 3. Chosen fallback

The fallback is selected before preregistration freeze and before any primary run.

The primary n grid is lowered according to the precommitted timeout fallback:

```text
n in {40,80}
```

The rho_fm grid is selected per q according to the precommitted saturation fallback:

```text
q=3: low-shift  {0.40,0.50,0.60,0.70,0.80,0.90}
q=4: low-shift  {0.40,0.50,0.60,0.70,0.80,0.90}
q=5: high-shift {0.80,0.90,1.00,1.10,1.20,1.30}
```

This choice remains inside the fallback rules already listed in the draft preregistration.

## 4. Rationale

For q=3 and q=4, the transition region is already visible at rho_fm = 0.80, while rho_fm = 0.60 is saturated SAT and rho_fm = 1.00 is saturated UNSAT. The low-shift grid adds rho_fm = 0.70 and rho_fm = 0.90 around the observed transition, aiming to obtain at least two informative bands.

For q=5, the pilot shows a split by finite size: n=50 has an informative band at rho_fm = 0.80, while n=100 remains SAT at rho_fm = 0.80 and becomes hard UNSAT at rho_fm = 1.00. The high-shift grid keeps rho_fm = 0.80 and adds rho_fm = 0.90 and above, while lowering n to {40,80} to reduce the timeout risk observed at n=100, rho_fm=1.00.

This is not a free grid search. The possible shifts were precommitted, and this addendum records the selected fallback before pilot_v2 and before freeze.

## 5. Next step

Run pilot_v2 using:

```text
analysis/exp43_qcoloring/config/pilot_v2_config.json
```

If pilot_v2 passes, freeze the preregistration, manifest, feature extraction, and analysis script before any primary run. If pilot_v2 fails, report the failure mode and decide whether Exp43 should be marked inconclusive rather than tuned further.
