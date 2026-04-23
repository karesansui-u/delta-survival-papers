# Exp43b q-coloring threshold-local calibration closeout

Status: calibration closeout / exploration artifact. Not validation evidence.

Date: 2026-04-23

## 1. Inputs

Calibration config:

```text
analysis/exp43_qcoloring/config/exp43b_calibration_config.json
```

Raw calibration output (gitignored):

```text
analysis/exp43_qcoloring/data/exp43b_calibration_results.jsonl
sha256: ee9be128646d645151e418b3b8deab4ec8398ead2fbdd40c6be2cefd0c87510c
```

Summary output (gitignored):

```text
analysis/exp43_qcoloring/data/exp43b_calibration_summary.json
sha256: 57df230aaf8981f65f5ca6485b2f6cccbda3ded7f06ccef9618c9b0328655465
```

Run size:

```text
2050 records
41 cells
50 instances per cell
phase = exp43b_calibration
```

## 2. Global Summary

Solver statuses:

| status | count |
|---|---:|
| SAT | 1004 |
| UNSAT | 1038 |
| TIMEOUT | 8 |
| MALFORMED_ENCODING | 0 |

Summary gate:

| item | value |
|---|---:|
| total records | 2050 |
| cell count | 41 |
| suspended cells | 1 |
| suspended cell fraction | 0.02439 |
| malformed encodings | 0 |

## 3. Suspended Cell

The following cell exceeds the preregistered timeout tolerance of 5%:

| q | n | rho_fm | SAT rate among solved | solved | timeout | timeout rate |
|---:|---:|---:|---:|---:|---:|---:|
| 5 | 80 | 0.86 | 0.2222 | 45 | 5/50 | 0.10 |

This violates the current Exp43b calibration pass rule:

```text
timeout rate <= 5% in every cell
```

Therefore Exp43b is not frozen and primary data must not be generated under
the current preregistration draft.

## 4. Informative Cells

Informative cells are solved cells with SAT rate in `(5%, 95%)`, excluding
cells marked suspended for timeout.

| q | n | informative rho_fm bands | suspended rho_fm bands |
|---:|---:|---|---|
| 3 | 40 | 0.65, 0.70, 0.75, 0.80, 0.85 | none |
| 3 | 80 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86 | none |
| 4 | 40 | 0.74, 0.76, 0.78, 0.80, 0.82, 0.84 | none |
| 4 | 80 | 0.82, 0.84, 0.86, 0.88 | none |
| 5 | 40 | 0.725, 0.75, 0.775, 0.80 | none |
| 5 | 80 | 0.82, 0.84 | 0.86 |

The threshold-local redesign worked in the narrow sense that each q has at
least one n-specific window with multiple informative bands. However, the
strict all-cell timeout gate fails because of `q=5, n=80, rho_fm=0.86`.

## 5. Candidate Windows If Runtime Gate Were Amended

The following windows are exploratory only. They are not frozen primary grids.

| q | n | minimal informative interval | one-step buffered window |
|---:|---:|---|---|
| 3 | 40 | 0.65-0.85 | 0.60, 0.65, 0.70, 0.75, 0.80, 0.85 |
| 3 | 80 | 0.76-0.86 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86, 0.88 |
| 4 | 40 | 0.74-0.84 | 0.74, 0.76, 0.78, 0.80, 0.82, 0.84, 0.86 |
| 4 | 80 | 0.82-0.88 | 0.80, 0.82, 0.84, 0.86, 0.88, 0.90 |
| 5 | 40 | 0.725-0.80 | 0.70, 0.725, 0.75, 0.775, 0.80, 0.825 |

The `q=5, n=80` candidate is not listed because its buffered window would
include the suspended `rho_fm=0.86` cell.

## 6. Buffer Application Record

The buffer rule was applied mechanically:

1. Find the minimal interval covering non-suspended informative cells.
2. Add one available grid step below and above.
3. Retain intermediate non-informative cells if they lie between informative
   cells.
4. Exclude q/n units whose buffered window includes a suspended cell.

Step 4 is a closeout-time safety rule for this calibration result. It is not
currently a frozen Exp43b primary rule and must not be used for primary data
generation without a new preregistration amendment.

## 7. Rank-Correlation / Power-Collapse Verdict

No frozen primary manifest is selected in this closeout, so the rank-correlation
matrix is not evaluated as a freeze package item.

Power-collapse verdict:

```text
not reached
```

Reason:

```text
the timeout gate fails before freeze
```

If Exp43b is amended and re-entered, the rank-correlation matrix must be
computed on the amended candidate primary manifest before any primary data are
generated.

## 8. Deviations

No primary data were generated.

No validation claim is made from this calibration run.

No deviation from the frozen-before-primary rule occurred.

## 9. Decision

Decision:

```text
NO-GO under the current Exp43b preregistration draft.
```

Primary generation:

```text
forbidden
```

Interpretation:

```text
Exp43b threshold-local calibration succeeded at locating informative windows,
but failed the current strict all-cell timeout gate.
```

This is not evidence against the structural balance law and not evidence for
Route A q-coloring support. It is an exploration result about the feasibility
of the current Exp43b calibration design.

## 10. Possible Next Moves

The clean options are:

1. Amend Exp43b before freeze to allow excluding runtime-unstable q/n units,
   then use q5/n40 as the q=5 primary candidate and recompute power-collapse
   diagnostics.
2. Run a new Exp43b calibration variant with smaller q=5 n or a revised
   timeout policy, explicitly marked as exploration.
3. Declare Exp43b inconclusive for now and pivot to another Route A or G4
   anchor.

Option 1 is scientifically plausible because each q has at least one
n-specific informative window. It is not currently permitted as primary
validation without an explicit preregistration amendment.
