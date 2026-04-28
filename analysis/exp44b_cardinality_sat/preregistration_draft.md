# Exp44b Cardinality-SAT Threshold-Local Preregistration Draft

Status: draft only. Not frozen. No primary data may be generated from this
document. Calibration v1 completed and closed as `calibration_no_go` because
the `M3_threeway_low` monotonicity gate failed. Exp44b v1 must not be promoted
to a freeze package or primary run.

Date: 2026-04-28

## 1. Purpose

Exp44b is a Route A width-extension candidate after:

1. Mixed-CSP passed as a mixed SAT / NAE-SAT primary and has `3/3` clean
   outside-group returns;
2. Exp43c q-coloring passed as a threshold-local graph-coloring primary and
   has `3/3` clean outside-group returns;
3. Exp44 Cardinality-SAT remained calibration-only because its low-drift
   mixtures did not satisfy the informative-window gate.

The narrow Exp44b question is:

```text
Inside a frozen threshold-local cardinality-constraint family, does the
theory-specified first-moment / structural-consumption coordinate predict
feasibility better than raw semantic count, density, and CNF-size baselines?
```

This is not a universal-law declaration. It is a stress-extension test inside
the Bernoulli-CSP / local forbidden-pattern corridor.

## 2. Relation To Exp44

Exp44b does not rescue Exp44.

The previous artifacts:

- `analysis/exp44_cardinality_sat/smoke_summary.md`;
- `analysis/exp44_cardinality_sat/pilot_runtime_probe.md`;
- `analysis/exp44_cardinality_sat/pilot_v2_summary.md`;
- `analysis/exp44_cardinality_sat/pilot_v3_summary.md`;

are calibration history only. They justify a new threshold-local grid, but they
are not validation evidence.

The key Exp44 lesson was:

```text
infrastructure clean, transition-window placement not freeze-ready
```

Pilot_v3 found:

```text
M0_low:          informative rho {0.90}
M1_low_med:      informative rho {0.90}
M2_bal_low_med:  informative rho {0.90}
M3_threeway_low: informative rho {0.70, 0.80, 0.90}
M4_threeway_med: informative rho {0.70, 0.80, 0.90}
M5_med_high:     informative rho {0.70, 0.80}
```

Exp44b is therefore designed as a fresh calibration pass with separate rho
windows for the low-drift and medium/high-drift mixture groups.

## 3. Constraint Family

Exp44b v1 keeps the existing Exp44 semantic type set so that the next test
changes the threshold-local window design, not the entire generator.

| Type id | Local condition | Allowed patterns | Survival ratio | Drift |
|---|---|---:|---:|---:|
| `AL1_4` | at least 1 of 4 signed literals is true | `15` | `15/16` | `log(16/15)` |
| `EX2_4` | exactly 2 of 4 signed literals are true | `6` | `6/16` | `log(16/6)` |
| `EX1_4` | exactly 1 of 4 signed literals is true | `4` | `4/16` | `log(16/4)` |

This covers a minimal threshold / exactly-r cardinality corridor using the
existing harness. At-most-r constraints remain a formal Lean-supported sibling
and can be opened as a later Exp44c-style extension if Exp44b warrants it.

Mixtures are unchanged:

| Mixture | `AL1_4` | `EX2_4` | `EX1_4` | Role |
|---|---:|---:|---:|---|
| `M0_low` | `1.00` | `0.00` | `0.00` | low-drift pure reference |
| `M1_low_med` | `0.75` | `0.25` | `0.00` | low / medium blend |
| `M2_bal_low_med` | `0.50` | `0.50` | `0.00` | balanced low / medium |
| `M3_threeway_low` | `0.50` | `0.25` | `0.25` | three-way low-heavy |
| `M4_threeway_med` | `0.25` | `0.50` | `0.25` | medium-heavy three-way |
| `M5_med_high` | `0.00` | `0.50` | `0.50` | medium / high blend |

## 4. Calibration V1 Grid

Calibration v1 uses:

```text
n in {60, 100}
instances_per_cell = 50
timeout = 120 seconds
solver_backend = minisat22
```

Low-drift mixtures use a fine local grid around the previous single
informative point:

```text
M0_low, M1_low_med, M2_bal_low_med:
rho_fm in {0.86, 0.88, 0.90, 0.92, 0.94, 0.96, 0.98, 1.00}
```

Medium/high-drift mixtures keep a wider local window around the previous
multi-point transition:

```text
M3_threeway_low, M4_threeway_med, M5_med_high:
rho_fm in {0.64, 0.68, 0.72, 0.76, 0.80, 0.84, 0.88, 0.92}
```

Total calibration size:

```text
6 mixtures * 2 n-values * 8 rho-values * 50 = 4800 instances
```

The calibration config is:

```text
analysis/exp44b_cardinality_sat/config/calibration_v1_config.json
```

## 5. Calibration Pass Gate

Calibration passes only if all conditions hold:

1. `MALFORMED = 0`;
2. timeout rate is at most `5%` in every cell;
3. no runtime-unstable cell, where runtime-unstable means median runtime
   greater than `30` seconds or at least `20%` of completed instances above
   `60` seconds;
4. every mixture has at least two pooled informative rho bands, where
   informative means SAT rate in `(5%, 95%)` after excluding timeouts;
5. every mixture has at least one n-specific primary-eligible window after the
   buffer rule in `analysis/protocols/threshold_local_route_a_v1.md`;
6. all six mixtures are monotone non-increasing in SAT rate with respect to
   `rho_fm`, allowing finite-sample ties;
7. the freeze-time rank-correlation / power-collapse diagnostic does not show
   the primary theory predictor to be collinear with every raw / density /
   CNF-size baseline. The operational cutoff follows
   `analysis/protocols/threshold_local_route_a_v1.md`: if absolute Spearman
   correlation is `>= 0.98` against every such baseline, the calibration cannot
   be promoted to freeze.

If this gate fails, Exp44b remains calibration-only. Do not tune the same
Exp44b design into a primary. A later attempt must be a new versioned
candidate.

The closeout must use an Exp44b-specific checklist or script implementing the
above gates. The historical Exp44 `pilot_summary.py` may be useful for quick
summaries, but it is not sufficient to decide the Exp44b gate.

## 6. Primary Window Rule If Calibration Passes

For each mixture:

1. mark informative calibration rho bands under the rule above;
2. choose the minimal interval covering the informative bands;
3. add one available grid step of buffer on both sides;
4. exclude any runtime-suspended cell;
5. require at least three rho values after buffering.

The primary grid is not allowed to be invented after seeing primary outcomes.
It must be written into a calibration closeout and freeze manifest before any
primary data are generated.

Primary size target after freeze:

```text
instances_per_cell = 200
primary phase namespace = exp44b_primary_v1
```

The actual primary row count depends on the frozen buffered windows.

## 7. Seed And Reuse Policy

Exp44b may reuse the existing Exp44 harness for calibration planning, but the
seed stream must be disjoint.

Current calibration phase namespace:

```text
exp44b_calibration_v1
```

Required future primary namespace:

```text
exp44b_primary_v1
```

Before primary validation, the freeze package must state whether the generator
identity remains `exp44_cardinality_sat` with phase-separated Exp44b streams,
or whether the generator is mechanically renamed to `exp44b_cardinality_sat`.
Either choice is acceptable only if it is frozen before primary data.

## 8. Predictors

Primary theory predictor:

```text
fm_plus_n:
  sat_feasible ~ first_moment_log_count + n
```

Theory-pure diagnostic:

```text
first_moment_only:
  sat_feasible ~ first_moment_log_count
```

Raw baselines:

```text
raw_plus_n:
  sat_feasible ~ m_semantic + n

density_plus_n:
  sat_feasible ~ semantic_density + n

```

Encoding-size guardrails:

```text
cnf_count_plus_n:
  sat_feasible ~ cnf_clause_count + n

cnf_density_plus_n:
  sat_feasible ~ cnf_density + n
```

Flexible diagnostic, not primary support:

```text
type_counts_plus_n:
  sat_feasible ~ m_AL1_4 + m_EX2_4 + m_EX1_4 + n

raw_plus_n_mixture:
  sat_feasible ~ m_semantic + n + mixture_id
```

`raw_plus_n_mixture` is diagnostic-only. Under leave-one-mixture-out, a held-out
mixture label is not a stable learned category in the training folds, and the
main question is structural extrapolation rather than mixture-id memorization.

## 9. Split And Metric

Primary split:

```text
leave-one-mixture-out
```

Primary metric:

```text
equal-mixture-weighted held-out log loss
```

Model family:

```text
logistic regression with L2 regularization
regularization selected inside training folds only
```

No model selection may use held-out fold performance.

## 10. Decision Rules

### H1 Primary Support

H1 passes if:

```text
logloss(fm_plus_n)
  < 0.90 * min(
      logloss(raw_plus_n),
      logloss(density_plus_n),
      logloss(cnf_count_plus_n),
      logloss(cnf_density_plus_n)
    )
```

and no primary cell is suspended.

### H2 Theory-Pure Direction

H2 passes if:

```text
logloss(first_moment_only)
  < min(logloss(raw_plus_n), logloss(density_plus_n))
```

H2 is a secondary theory-pure diagnostic. It strengthens interpretation if it
passes, but H1/H3 define the primary support decision.

### H3 Encoding Guardrail

H3 passes if:

```text
logloss(fm_plus_n) <= logloss(cnf_count_plus_n)
```

### H4 Dose-Response Diagnostic

Fit `type_counts_plus_n` and report whether learned type coefficients are
ordered consistently with drift magnitude. Since the response is
`sat_feasible`, higher drift should push SAT log-odds downward; higher-drift
type coefficients are therefore expected to be more negative.

H4 is diagnostic only.

## 11. Interpretation Table

| Outcome | Interpretation |
|---|---|
| H1 + H2 + H3 pass | Strong Exp44b support: both the adjusted and theory-pure coordinates beat the relevant baselines |
| H1 + H3 pass, H2 fail | Primary support with a theory-pure weakness; report as support but not strong support |
| H1 pass, H3 fail | Possible encoding-size explanation; weakening outcome |
| `type_counts_plus_n` wins but `fm_plus_n` does not | Flexible count tuning helps; theory-specified coordinate not supported |
| raw / density / CNF baselines beat `fm_plus_n` | No-support for this Exp44b mapping |
| calibration gate fails | Exp44b remains calibration-only; no validation claim |

## 12. Non-Claims

Even if Exp44b passes, do not claim:

1. universal law established;
2. all CSPs covered;
3. at-most-r cardinality family empirically validated;
4. solver cost predicted;
5. threshold location predicted;
6. q-coloring replaced;
7. Route C / LLM mechanisms validated;
8. independent replication achieved.

The strongest allowed wording after a clean pass is:

```text
Exp44b provides a third Route A empirical width anchor showing that a
theory-specified first-moment / structural-consumption coordinate predicts
feasibility better than raw semantic count and CNF-size baselines in a
heterogeneous cardinality-constraint family.
```

## 13. Immediate Next Actions

1. Dry-run the calibration plan.
2. Review the dry-run feature ranges and row count.
3. If accepted, run calibration only, not primary.
4. Write a calibration closeout with per-cell SAT rates, timeout/malformed
   counts, monotonicity, informative windows, and power-collapse diagnostic.
5. Only if the calibration pass gate succeeds, write a freeze manifest and a
   primary evaluation script.
