# Mixed-CSP Smoke Summary

Generated: 2026-04-22T03:36:53.909166
Rows: `20`
Median runtime: `0.0595` sec
P90 runtime: `0.0611` sec
Primary runtime extrapolation, median: `713.6453` sec
Primary runtime extrapolation, P90: `733.5011` sec

## Checks

| Check | Passed |
|---|---|
| `all_solver_statuses_succeeded` | `True` |
| `all_sat_assignments_verified` | `True` |
| `pure_sat_cnf_ratio_1` | `True` |
| `pure_nae_cnf_ratio_2` | `True` |
| `pure_exact_one_cnf_ratio_4` | `True` |
| `mixed_sat_nae_cnf_ratio_1_5` | `True` |

## Cells

| Cell | n | SAT rate | timeout rate | median CNF/raw |
|---|---:|---:|---:|---:|
| `smoke|n=20|d=1.0|sat_0.00__nae_0.00__exact1_1.00` | 5 | 0.0000 | 0.0000 | 4.0000 |
| `smoke|n=20|d=1.0|sat_0.00__nae_1.00__exact1_0.00` | 5 | 1.0000 | 0.0000 | 2.0000 |
| `smoke|n=20|d=1.0|sat_0.50__nae_0.50__exact1_0.00` | 5 | 1.0000 | 0.0000 | 1.5000 |
| `smoke|n=20|d=1.0|sat_1.00__nae_0.00__exact1_0.00` | 5 | 1.0000 | 0.0000 | 1.0000 |
