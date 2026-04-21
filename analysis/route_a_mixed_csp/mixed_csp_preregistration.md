# Mixed-CSP Empirical Pre-registration

Status: frozen before primary data collection. The exact-one stress extension
requires the pre-primary pilot decision specified below before inclusion in the
primary grid.

## 1. Purpose

This Route A empirical test asks whether drift-weighted structural loss `L`
predicts feasibility better than raw constraint count when constraint types
with different bad-event probabilities are mixed. Solver cost is a secondary
computational-cost endpoint derived from the same instances.

This is the hard-domain analog of the LLM baseline comparison:

```text
LLM: structure-aware contradiction coding > quality-blind contradiction coding
Route A: drift-weighted L > raw constraint count for feasibility
Secondary cost: drift-weighted L > raw constraint count for solver cost
```

## 2. Core Guardrail

A single constant-drift family cannot test `L > raw count`. For example:

```text
NAE-SAT: L = m * log(4/3)
```

so `L` and raw count are regression-equivalent. This experiment therefore uses
mixed-constraint instances with at least two constraint types whose per-clause
drifts differ.

## 3. Candidate Constraint Types

Primary mixed family:

| Type | Semantics under fixed assignment | Bad probability | Drift |
|---|---|---:|---:|
| 3-SAT | Random signed 3-clause is unsatisfied | `1/8` | `log(8/7)` |
| 3-NAE-SAT | Random signed 3-clause is not-all-equal violated | `1/4` | `log(4/3)` |
| Exactly-one-3-SAT | Exactly one literal true; violation otherwise | `5/8` | `log(8/3)` |

Exactly-one constraints have much larger drift and may dominate feasibility too
strongly. They also create a larger CNF encoding footprint. Therefore the
initial primary grid is the clean two-type SAT/NAE mix below. Exactly-one is a
conditional stress extension that can be promoted only by the pre-primary pilot
specified in §4.1; otherwise it remains exploratory.

## 4. Instance Generation

For each instance:

1. Choose `n` variables.
2. Choose total raw constraint count `m`.
3. Choose mixture vector `w = (w_sat, w_nae, w_exact1)`.
4. Generate each constraint type iid according to `w`.
5. Record:

```text
raw_count = m
raw_density = m / n
L = m_sat * log(8/7)
  + m_nae * log(4/3)
  + m_exact1 * log(8/3)
first_moment_log_count = n * log(2) - L
```

Primary `n` grid:

```text
n in {80, 120, 160}
```

Primary raw count grid:

```text
m/n in {2.0, 2.5, 3.0, 3.5}
```

This grid intentionally avoids the random 3-SAT threshold neighborhood
(`alpha_c ≈ 4.27`) and uses the same caution as the SAT cost supplement:
near-threshold cells can introduce survivor bias and unstable conditioning.

Primary mixture grid:

```text
(1.0, 0.0, 0.0)
(0.75, 0.25, 0.0)
(0.50, 0.50, 0.0)
(0.25, 0.75, 0.0)
(0.0, 1.0, 0.0)
```

Optional stress grid with exactly-one:

```text
(0.80, 0.10, 0.10)
(0.60, 0.20, 0.20)
```

The exact-one stress grid is not primary by default.

### 4.1 Exact-One Pre-primary Pilot

Before freezing the primary grid, run a small exact-one pilot:

```text
n in {80, 120, 160}
stress mixtures in {(0.80, 0.10, 0.10), (0.60, 0.20, 0.20)}
instances per cell = 50
```

Promotion criteria:

```text
SAT rate > 30% in at least 2/3 n values for each stress mixture
and
median(cnf_clause_count / semantic_raw_count) < 5.0 in every stress cell
```

If both criteria pass, the stress grid may be promoted into the frozen primary
grid before primary data collection. If either criterion fails, exact-one
remains exploratory only. This promotion decision and pilot summary must be
recorded in the frozen preregistration before any primary mixed-CSP data are
collected.

Mixture rounding rule:
  Convert `m * w_type` to integer counts by flooring all but the last type in a
  fixed order `(sat, nae, exact1)`, then assign the remaining constraints to the
  last type so that counts sum exactly to `m`. The fixed order and resulting
  counts are recorded for every cell.

Instances per cell:

```text
generated_instances_per_cell = 200
minimum_valid_instances_per_cell = 150
```

Each instance receives:

```text
instance_seed = sha256(experiment_id, n, m, mixture_id, instance_idx)
```

and the seed is recorded in the raw trial record.

## 5. Solvers and Outcome

Primary solver:

```text
MiniSat / CDCL after CNF encoding of all constraint types
```

Primary Route A outcome:

```text
sat_feasible in {0, 1}
```

where `sat_feasible = 1` iff MiniSat proves the encoded instance satisfiable
within the feasibility timeout.

Primary feasibility timeout:

```text
MiniSat wall-clock timeout = 30 seconds per instance
```

Timeouts are recorded separately. A timeout is not counted as UNSAT in the
primary feasibility analysis; if timeout rate exceeds 5% in any primary cell,
the cell is flagged and primary interpretation is suspended for that cell.

Secondary computational-cost outcome:

```text
log(1 + conflicts)
```

on SAT instances only.

Important encoding guardrail:
  All predictors must distinguish semantic constraint count from generated CNF
  clause count. Exactly-one constraints expand into multiple CNF clauses, so a
  solver may respond to encoding size rather than semantic drift. Therefore the
  analysis must record both:

```text
semantic_raw_count = original mixed-CSP constraint count
cnf_clause_count = number of clauses after encoding
```

and include `cnf_clause_count` as an additional baseline / diagnostic predictor.

Solver metadata:
  Record PySAT package version, MiniSat backend name/version if available,
  Python version, OS, CPU model if available, wall-clock timeout, and start/end
  timestamps for every run.

Secondary solver:

```text
WalkSAT-style local search, if a shared mixed-constraint evaluator is built.
```

Secondary outcome:

```text
log(1 + flips)
```

WalkSAT reproducibility:
  If the secondary WalkSAT-style solver is used, its random seed is
  `hash(instance_id, "walksat")` and is recorded per trial.

## 6. Feasibility and SAT Conditioning

The primary Route A analysis is not conditional on satisfiability. It predicts
the binary feasibility endpoint / SAT rate across all generated instances.

The secondary solver-cost analysis is conditional on instances that are
satisfiable. Unsatisfiable instances are not discarded silently; report SAT rate
per cell and timeout rate as diagnostics.

If a cell has fewer than 30 SAT instances after generation, that cell is marked
underpowered and excluded from secondary cost regression, with the exclusion
reported.

## 7. Primary Model Comparison

Train/test split:

```text
leave-one-mixture-out
```

Candidate predictive models:

1. `raw_count`: `sat_feasible ~ raw_count`
2. `raw_density`: `sat_feasible ~ m/n`
3. `L_only`: `sat_feasible ~ L`
4. `first_moment`: `sat_feasible ~ first_moment_log_count`
5. `L_plus_n`: `sat_feasible ~ L + n`
6. `raw_plus_n`: `sat_feasible ~ raw_count + n`
7. `cnf_count_plus_n`: `sat_feasible ~ cnf_clause_count + n`

Primary comparison:

```text
L_plus_n test log loss < raw_plus_n test log loss
```

Theory-pure strong-support comparison:

```text
first_moment test log loss < raw_plus_n test log loss
```

Encoding diagnostic:

```text
L_plus_n test log loss < cnf_count_plus_n test log loss
```

If `L_plus_n` beats semantic raw count but not CNF count, the result supports
encoding-size sensitivity more than semantic drift weighting.

Secondary comparison:

```text
L_only test log loss < raw_count test log loss
```

Use held-out trial-level log loss from leave-one-mixture-out logistic models.
The solver-cost endpoint repeats the same model family on
`log(1 + conflicts)` with held-out RMSE and log likelihood as secondary metrics.

## 8. Primary Prediction

Primary support:

```text
L_plus_n beats raw_plus_n in leave-one-mixture-out feasibility prediction
```

Strong support:

```text
L_plus_n reduces held-out log loss by at least 10%
relative to raw_plus_n
and does not lose to cnf_count_plus_n
```

Theory-pure strong support additionally requires:

```text
first_moment beats raw_plus_n in held-out log loss
```

## 9. Secondary Universality Diagnostic

Fit family/mixture-specific slopes:

```text
logit(P(sat_feasible)) ~ L
```

and compare the dispersion of slopes to slopes from:

```text
logit(P(sat_feasible)) ~ raw_count
```

Secondary universality signal:

```text
family/mixture slope variance is smaller under L normalization
than under raw-count normalization.
```

This is descriptive unless frozen as primary in a later cross-family experiment.

## 10. Falsification / Weakening Rules

The Route A predictive claim is not supported if:

```text
raw_plus_n held-out log loss <= L_plus_n held-out log loss
```

across the primary leave-one-mixture-out evaluation.

The drift-weighting interpretation is weakened if `L_plus_n` gains
predictive power only through CNF encoding size or hidden generation artifacts.
Report CNF clause count, mixture composition, timeout rate, and residual /
calibration diagnostics to guard against this.

For the secondary solver-cost endpoint, the computational-cost claim is not
supported if `raw_plus_n` or `cnf_count_plus_n` matches or beats `L_plus_n` on
held-out cost prediction.

## 11. Exclusions

Exclude from primary feasibility regression:

- solver runtime failures unrelated to satisfiability;
- cells with timeout rate above the preregistered tolerance;
- instances where CNF encoding is malformed or verification of the returned
  assignment fails.

Exclude from secondary cost regression:

- unsatisfiable instances;
- timeout instances;
- cells with fewer than 30 SAT instances;
- malformed encodings or failed assignment verification.

All exclusions are counted and reported.

Cost-distribution diagnostic:
  The secondary CDCL regression assumes `log(1 + conflicts)` is sufficiently
  well behaved for held-out RMSE. Report residual histograms and per-cell
  residual summaries. If residuals are strongly bimodal or dominated by
  timeouts, the secondary specification switches to a preregistered logistic
  budgeted-success model and is labeled secondary-exploratory.

## 12. Scope

This experiment tests whether drift-weighted `L` / first-moment log count is a
better feasibility coordinate than raw count in a mixed finite CSP setting.
Solver cost is secondary. The experiment does not claim a universal `c`
coefficient. A later cross-family experiment may test whether `L` also reduces
family-to-family slope dispersion.
