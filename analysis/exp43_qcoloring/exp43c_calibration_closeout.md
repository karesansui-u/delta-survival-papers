# Exp43c q-coloring threshold-local calibration closeout

Status: calibration closeout / exploration artifact. Not validation evidence.

Date: 2026-04-23

## 1. Inputs

Calibration config:

```text
analysis/exp43_qcoloring/config/exp43c_calibration_config.json
```

Raw calibration output (gitignored):

```text
analysis/exp43_qcoloring/data/exp43c_calibration_results.jsonl
sha256: f4740795b7e94d40b6f540410591a209a8a1473943ed29ab1ddba13c753a428f
```

Summary output (gitignored):

```text
analysis/exp43_qcoloring/data/exp43c_calibration_summary.json
sha256: adb623f0f453eee839b562fd65347851123e22a0d7925cbd2a7730d0ae01599a
```

Run size:

```text
2100 records
42 cells
50 instances per cell
phase = exp43c_calibration
```

## 2. Global Summary

Solver statuses:

| status | count |
|---|---:|
| SAT | 1011 |
| UNSAT | 1089 |
| TIMEOUT | 0 |
| MALFORMED_ENCODING | 0 |

Summary gate:

| item | value |
|---|---:|
| total records | 2100 |
| cell count | 42 |
| suspended cells | 0 |
| suspended cell fraction | 0 |
| malformed encodings | 0 |

Calibration pass:

```text
true
```

## 3. Informative Cells

Informative cells are solved cells with SAT rate in `(5%, 95%)`.

| q | n | informative rho_fm bands | suspended rho_fm bands |
|---:|---:|---|---|
| 3 | 40 | 0.60, 0.65, 0.70, 0.75, 0.80, 0.85 | none |
| 3 | 80 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86, 0.88 | none |
| 4 | 40 | 0.74, 0.76, 0.78, 0.80, 0.82, 0.84 | none |
| 4 | 80 | 0.80, 0.82, 0.84, 0.86, 0.88 | none |
| 5 | 40 | 0.725, 0.75, 0.775, 0.80 | none |
| 5 | 60 | 0.78, 0.80, 0.82, 0.84 | none |

Each q in `{3,4,5}` has at least one n-specific primary-eligible unit.

## 4. Primary-Eligible Units

All q/n units are runtime-stable under the preregistered tolerance:

```text
max timeout rate = 0 for every q/n unit
```

The following q/n units are primary-eligible:

| q | eligible n values |
|---:|---|
| 3 | 40, 80 |
| 4 | 40, 80 |
| 5 | 40, 60 |

Exp43c §8 precommits that, if multiple n units are eligible for a q, the
closeout must either include all eligible units or choose the eligible unit
with lower maximum timeout rate, breaking ties by larger n.

This closeout chooses the second rule:

```text
choose lower max timeout rate; tie-break by larger n
```

Since every eligible q/n unit has max timeout rate 0, the selected units are:

| q | selected n |
|---:|---:|
| 3 | 80 |
| 4 | 80 |
| 5 | 60 |

## 5. Selected Primary Grid

The selected primary validation grid is:

| q | n | selected rho_fm bands |
|---:|---:|---|
| 3 | 80 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86, 0.88 |
| 4 | 80 | 0.78, 0.80, 0.82, 0.84, 0.86, 0.88, 0.90 |
| 5 | 60 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86 |

Planned primary size:

```text
20 cells * 200 instances per cell = 4000 primary instances
```

Primary generation remains forbidden until the full freeze package is committed.

## 6. Buffer Application Record

The buffer rule was applied mechanically:

1. Find the minimal interval covering informative cells.
2. Add one available grid step below and above.
3. Retain intermediate non-informative cells if they lie between informative
   cells.
4. Require that the selected buffered window contain no runtime-suspended cell.

Buffer outcomes:

| q | n | minimal informative interval | one-step buffered window |
|---:|---:|---|---|
| 3 | 80 | 0.76-0.88 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86, 0.88 |
| 4 | 80 | 0.80-0.88 | 0.78, 0.80, 0.82, 0.84, 0.86, 0.88, 0.90 |
| 5 | 60 | 0.78-0.84 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86 |

## 7. Rank-Correlation / Power-Collapse Diagnostic

The rank-correlation diagnostic was computed on the selected primary grid
using calibration-grid feature values only. Tuple predictors are represented
by scalar diagnostic projections for this freeze gate:

- `fm_plus_n_scalar = first_moment + n`
- `L_plus_n_scalar = L + n`
- `raw_plus_n_q_scalar = m + n + q`
- `density_plus_n_q_scalar = m/n + n + q`
- `avg_degree_plus_n_q_scalar = 2m/n + n + q`
- `cnf_count_plus_n_q_scalar = cnf_clause_count + n + q`

Spearman matrix:

| predictor | first_moment | fm_plus_n_scalar | L_plus_n_scalar | raw_plus_n_q_scalar | density_plus_n_q_scalar | avg_degree_plus_n_q_scalar | cnf_count_plus_n_q_scalar |
|---|---:|---:|---:|---:|---:|---:|---:|
| first_moment | 1.000 | 0.462 | -0.352 | -0.325 | -0.352 | -0.352 | -0.111 |
| fm_plus_n_scalar | 0.462 | 1.000 | 0.498 | -0.629 | 0.498 | 0.498 | -0.765 |
| L_plus_n_scalar | -0.352 | 0.498 | 1.000 | 0.105 | 1.000 | 1.000 | -0.263 |
| raw_plus_n_q_scalar | -0.325 | -0.629 | 0.105 | 1.000 | 0.105 | 0.105 | 0.917 |
| density_plus_n_q_scalar | -0.352 | 0.498 | 1.000 | 0.105 | 1.000 | 1.000 | -0.263 |
| avg_degree_plus_n_q_scalar | -0.352 | 0.498 | 1.000 | 0.105 | 1.000 | 1.000 | -0.263 |
| cnf_count_plus_n_q_scalar | -0.111 | -0.765 | -0.263 | 0.917 | -0.263 | -0.263 | 1.000 |

Power-collapse verdict:

```text
pass
```

Reason:

```text
abs(Spearman(fm_plus_n_scalar, baseline)) < 0.98 for every raw / density /
CNF-size baseline.
```

The highest absolute rank-correlation involving `fm_plus_n_scalar` and a
baseline is `0.765` against `cnf_count_plus_n_q_scalar`.

## 8. Deviations

No primary data were generated.

No validation claim is made from this calibration run.

No deviation from the frozen-before-primary rule occurred.

## 9. Decision

Decision:

```text
GO TO FREEZE PACKAGE
```

Primary generation:

```text
still forbidden until freeze package is committed
```

Interpretation:

```text
Exp43c calibration passed the runtime, informative-window, and power-collapse
gates. It may proceed to freeze-package assembly.
```

This is not evidence for Route A q-coloring support. It is only the required
calibration closeout before a possible primary validation run.

## 10. Remaining Freeze Items

Before primary data generation, Exp43c still needs:

1. frozen preregistration commit SHA;
2. primary instance manifest generation script;
3. exact regularization value for logistic regression;
4. evaluation script hash;
5. primary seed namespace confirmation: `exp43c_primary`;
6. final timeout / exclusion policy copied into the freeze package.
