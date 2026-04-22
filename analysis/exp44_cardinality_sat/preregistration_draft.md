# Exp44 Cardinality-SAT preregistration draft

Status: draft only. Not frozen. No primary data may be generated from this
document until the freeze checklist in §14 is completed and committed.

Date: 2026-04-22

## 1. Purpose

Exp44 is a Route A width-extension candidate after the Exp43 q-coloring pilot
calibration did not reach a freeze-ready grid. The goal is not to replace
q-coloring, and not to declare a universal law. The goal is narrower:

```text
Test whether the theory-specified first-moment coordinate

  first_moment_log_count = n log 2 - L

predicts feasibility better than raw semantic count and CNF encoding-size
baselines in a cardinality-constraint CSP family with multiple drift levels.
```

This experiment is a stress extension, not the first "visibly non-SAT" Route A
domain. Cardinality-SAT is SAT-adjacent, but it has a useful feature: the
per-constraint drift varies by an explicit binomial count,

\[
  \ell(k,r,\mathrm{mode})
    = -\log(\mathrm{allowed}(k,r,\mathrm{mode}) / 2^k).
\]

That makes it a clean dose-response test of the structural-loss coordinate
inside the Bernoulli-CSP universality class.

## 2. Phase discipline

Exp44 has three phases:

| Phase | Meaning | Status |
|---|---|---|
| Exploration / pilot | Check grid informativeness, timeout rate, encoding correctness | Current target |
| Freeze | Commit preregistration, generator, manifest rules, feature schema, and analysis script | Not reached |
| Validation | Generate primary data once and run the frozen analysis | Not reached |

Pilot data are calibration data only. They are not validation evidence.

Before the primary run, the frozen preregistration and analysis code must be
committed and pushed or otherwise timestamped. This is the same guardrail used
after Exp43: exploration may iterate, validation may not.

## 3. Constraint family

All constraints are random signed cardinality constraints on \(k=4\) literals.
Each constraint chooses four distinct variables uniformly without replacement
and assigns each literal a random polarity independently.

The primary semantic types are:

| Type id | Name | Local condition | Allowed patterns | Survival ratio | Drift \(\ell\) | Direct forbidden-pattern CNF clauses |
|---|---|---|---:|---:|---:|---:|
| `AL1_4` | at-least-one-of-4 | at least 1 signed literal is true | 15 | 15/16 | log(16/15) = 0.06454 | 1 |
| `EX2_4` | exactly-two-of-4 | exactly 2 signed literals are true | 6 | 6/16 | log(16/6) = 0.98083 | 10 |
| `EX1_4` | exactly-one-of-4 | exactly 1 signed literal is true | 4 | 4/16 | log(16/4) = 1.38629 | 12 |

The local count is theory-specified:

\[
  \ell_j = \log(2^4 / a_j),
\]

where \(a_j\) is the number of allowed truth patterns for type \(j\).

The type selection is deliberately heterogeneous:

- `AL1_4` is close to ordinary 4-SAT and has small drift with tiny CNF footprint.
- `EX2_4` has medium drift and large CNF footprint.
- `EX1_4` has high drift and large CNF footprint.

This creates the intended pressure test:

```text
If first_moment wins, it is not merely raw constraint count.
If cnf_clause_count wins, the observed signal may be encoding-size driven.
```

## 4. Instance generation

For each cell:

1. Choose \(n\).
2. Choose a mixture vector \(w = (w_{\mathrm{AL1}}, w_{\mathrm{EX2}}, w_{\mathrm{EX1}})\).
3. Choose \(\rho_{\mathrm{fm}}\).
4. Compute the average drift:

\[
  \bar\ell(w) =
    w_{\mathrm{AL1}}\ell_{\mathrm{AL1}}
    + w_{\mathrm{EX2}}\ell_{\mathrm{EX2}}
    + w_{\mathrm{EX1}}\ell_{\mathrm{EX1}}.
\]

5. Set total semantic constraint count:

\[
  m = \mathrm{round}\left(
    \frac{\rho_{\mathrm{fm}} \, n \log 2}{\bar\ell(w)}
  \right).
\]

6. Convert \(m w_j\) to integer type counts using the fixed rounding rule:
   floor all but the last type in the order `AL1_4`, `EX2_4`, `EX1_4`, then
   assign the remainder to the last type.
7. Generate each constraint independently with the specified type, random
   variable set, and random signs.

The expected first-moment log count is:

\[
  \mathrm{FM}
    = n\log 2
      - m_{\mathrm{AL1}}\ell_{\mathrm{AL1}}
      - m_{\mathrm{EX2}}\ell_{\mathrm{EX2}}
      - m_{\mathrm{EX1}}\ell_{\mathrm{EX1}}.
\]

## 5. Candidate grids

### 5.1 Pilot grid

Pilot grid:

```text
n in {80, 120}
rho_fm in {0.70, 0.85, 1.00, 1.15}
instances_per_cell = 50
timeout = 120 seconds
```

Pilot mixture grid:

| mixture id | AL1_4 | EX2_4 | EX1_4 | Role |
|---|---:|---:|---:|---|
| `M0_low` | 1.00 | 0.00 | 0.00 | low-drift pure reference |
| `M1_low_med` | 0.75 | 0.25 | 0.00 | low / medium blend |
| `M2_bal_low_med` | 0.50 | 0.50 | 0.00 | balanced low / medium |
| `M3_threeway_low` | 0.50 | 0.25 | 0.25 | three-way blend |
| `M4_threeway_med` | 0.25 | 0.50 | 0.25 | medium-heavy three-way blend |
| `M5_med_high` | 0.00 | 0.50 | 0.50 | medium / high blend |

Pilot size:

```text
2 n-values * 4 rho-values * 6 mixtures * 50 = 2,400 instances
```

### 5.2 Pilot pass criteria

The pilot passes if all conditions hold:

1. Timeout rate is at most 5% in every cell.
2. MALFORMED / encoding-verifier failure count is 0.
3. For every mixture id, at least two \(\rho_{\mathrm{fm}}\) bands have SAT
   rate in `(5%, 95%)` after excluding timeouts.
4. At least four of six mixtures have monotone non-increasing SAT rate as
   \(\rho_{\mathrm{fm}}\) increases.
5. No pilot cell is runtime-unstable, where runtime-unstable means either:
   median runtime exceeds 30 seconds, or at least 20% of completed instances in
   that cell have runtime greater than 60 seconds.

If the pilot fails, the result is calibration feedback, not theory evidence.

### 5.3 Pilot fallback rules

Fallback rules must be chosen before any primary data:

| Failure pattern | Precommitted fallback |
|---|---|
| Most cells SAT-saturated | shift rho grid up to `{0.90, 1.05, 1.20, 1.35}` |
| Most cells UNSAT-saturated | shift rho grid down to `{0.45, 0.60, 0.75, 0.90}` |
| Transition too sharp | use fine grid `{0.70, 0.80, 0.90, 1.00, 1.10, 1.20}` with `instances_per_cell = 50` |
| Timeout > 5% in any cell but < 30% of cells suspended | reduce `n` to `{60, 100}` and keep the same rho grid |
| Runtime-unstable cell without hard timeout | reduce `n` to `{60, 100}` and keep the same rho grid |
| Timeout suspension in at least 30% of cells | mark Exp44 pilot inconclusive; do not freeze |

Any fallback decision must be recorded in an addendum before the next pilot run.

### 5.4 Primary grid, if pilot passes

If the pilot passes without fallback, the primary grid is:

```text
n in {80, 120}
rho_fm in {0.70, 0.85, 1.00, 1.15}
mixtures = M0_low, M1_low_med, M2_bal_low_med,
           M3_threeway_low, M4_threeway_med, M5_med_high
instances_per_cell = 200
```

Primary size:

```text
2 * 4 * 6 * 200 = 9,600 instances
```

If a precommitted fallback passes, the primary grid is the passed fallback
grid, recorded in the freeze addendum.

## 6. Encoding and solver endpoint

Primary endpoint:

```text
sat_feasible in {0,1}
```

where `sat_feasible = 1` iff the solver proves the CNF encoding satisfiable
within the timeout and the returned assignment passes an independent
cardinality-constraint verifier on the original semantic constraints.

CNF encoding:

Use direct forbidden-pattern clauses. For a signed local truth pattern that
violates the cardinality condition, add one clause excluding that pattern.

This gives the following per-semantic-constraint CNF clause counts:

```text
AL1_4:  1
EX2_4: 10
EX1_4: 12
```

The direct encoding is intentionally simple and auditable. It is not claimed to
be solver-optimal.

Timeouts:

- Timeout is recorded separately.
- Timeout is not counted as UNSAT.
- If timeout rate exceeds 5% in any primary cell, interpretation is suspended
  for that cell.
- If at least 30% of primary cells exceed the timeout threshold, the primary
  result is reported as inconclusive.

## 7. Recorded fields

For every instance, record:

```text
experiment_id
phase
instance_id
seed_hex
n
rho_fm
mixture_id
m_semantic
m_AL1_4
m_EX2_4
m_EX1_4
L
first_moment_log_count
semantic_raw_count
semantic_density
cnf_clause_count
cnf_var_count
solver_backend
solver_version
timeout_sec
solver_status
sat_feasible
assignment_verified
conflicts
decisions
propagations
wall_clock_seconds
timestamp_start
timestamp_end
```

The semantic constraint list should be hashed using SHA256 over a canonical
UTF-8 serialization of sorted constraint records:

```text
type_id|var0,sign0|var1,sign1|var2,sign2|var3,sign3\n
```

Within each constraint, variables are sorted by variable id after signs are
attached to the chosen variables. The exact serialization code must be frozen
before primary data.

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
  sat_feasible ~ semantic_raw_count + n

density_plus_n:
  sat_feasible ~ semantic_density + n

raw_plus_n_mixture:
  sat_feasible ~ semantic_raw_count + n + mixture_id
```

Encoding-size guardrail baselines:

```text
cnf_count_plus_n:
  sat_feasible ~ cnf_clause_count + n

cnf_density_plus_n:
  sat_feasible ~ (cnf_clause_count / n) + n
```

Coefficient-tuned diagnostic:

```text
type_counts_plus_n:
  sat_feasible ~ m_AL1_4 + m_EX2_4 + m_EX1_4 + n
```

The coefficient-tuned diagnostic is not primary support. It measures whether a
flexible model can learn a better finite-size correction than the
theory-specified first-moment coordinate.

## 9. Split and metric

Primary split:

```text
leave-one-mixture-out
```

For each held-out mixture:

1. Train each predictor family on the other mixtures.
2. Evaluate held-out log loss on the held-out mixture.
3. Average log loss across held-out mixtures, weighting each mixture equally.

Primary metric:

```text
held-out log loss
```

Secondary metrics:

```text
Brier score
calibration curve by rho_fm
SAT-rate monotonicity by rho_fm
```

Model fitting:

- Logistic regression.
- L2 regularization.
- Regularization selected only inside training folds.
- No primary model selection using held-out fold performance.

## 10. Hypotheses and decision rules

### H1 Primary Route A support

Primary support holds if:

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

This is the main Exp44 test: a theory-specified first-moment coordinate must
beat raw semantic count, raw density, and CNF encoding-size baselines by at
least 10%.

### H2 Theory-pure support

Theory-pure support holds if:

```text
logloss(first_moment_only)
  < min(logloss(raw_plus_n), logloss(density_plus_n))
```

This is stronger than H1 because no finite-size correction is allowed.

### H3 Encoding guardrail

Encoding guardrail passes if:

```text
logloss(fm_plus_n) <= logloss(cnf_count_plus_n)
```

If H1 passes but H3 fails, the result is weakened:

```text
The endpoint may be better explained by generated CNF size than by semantic
structural drift.
```

### H4 Dose-response diagnostic

Fit the coefficient-tuned diagnostic `type_counts_plus_n`. Record whether the
learned type coefficients are ordered consistently with drift magnitude:

```text
AL1_4 coefficient > EX2_4 coefficient > EX1_4 coefficient
```

This is not required for primary support, because coefficients can be distorted
by finite-size effects and solver/encoding behavior. It is a diagnostic for
whether learned count weights point in the same direction as the theory. Since
the response is `sat_feasible`, larger drift should push the log-odds of SAT
downward, so the higher-drift coefficients are expected to be more negative.

### H5 Null / weakening outcomes

Precommitted interpretations:

| Result pattern | Interpretation |
|---|---|
| H1 + H3 pass | Exp44 supports Route A drift-weighted feasibility beyond raw and encoding-size baselines |
| H1 passes, H3 fails | Possible encoding-size explanation; do not count as strong Route A support |
| `type_counts_plus_n` wins but `fm_plus_n` does not | Coefficient tuning helps, but theory-specified form is not confirmed |
| raw / density baselines beat `fm_plus_n` | Exp44 does not support the Route A width claim |
| pilot cannot find informative bands | Exp44 remains exploratory / inconclusive; no validation claim |

## 11. Non-claims

Even if Exp44 passes, do not claim:

1. universal law established;
2. q-coloring recovered or validated;
3. solver cost predicted by structural drift;
4. SAT threshold theorem proved;
5. all cardinality constraints follow the same finite-size curve;
6. CNF encoding effects are eliminated;
7. Route C / LLM mechanisms validated by this experiment;
8. independent replication achieved.

The strongest allowed wording after a clean pass is:

```text
Exp44 provides another internal Route A width anchor showing that a
theory-specified first-moment / drift coordinate predicts feasibility better
than raw semantic count and CNF-size baselines in a heterogeneous
Cardinality-SAT family.
```

## 12. Relation to Exp43

Exp43 q-coloring is currently exploration / pilot calibration. Its pilot_v1/v2
results should not be treated as negative validation evidence. They showed that
the first q-coloring grid was under-calibrated for q=4 and q=5.

Exp44 is not a substitute proof for q-coloring. It is a separate Route A width
stress test with more directly controllable drift levels.

If Exp44 passes, the correct combined interpretation is:

```text
Mixed-CSP and Cardinality-SAT both support drift-weighted feasibility inside
the Bernoulli-CSP / cardinality-constraint corridor.
q-coloring remains an open or separately calibrated Route A target.
```

## 13. Lean correspondence

Exp44 is supported conceptually by existing Lean modules:

| Empirical object | Lean correspondence |
|---|---|
| exactly-r cardinality drift | `CardinalitySATChernoffCollapse.lean` |
| at-most / at-least threshold cardinality drift | `ThresholdCardinalitySATChernoffCollapse.lean` |
| exactly-one specialization | `ExactlyOneSATChernoffCollapse.lean` |
| generic forbidden-pattern bridge | `MultiForbiddenPatternCSP.lean` |
| Bernoulli-CSP universality interface | `BernoulliCSPUniversality.lean` |

Lean supports the fixed-assignment Bernoulli exposure semantics:

\[
  \ell = \log(2^k / \mathrm{allowed}).
\]

The empirical endpoint is full formula feasibility under random constraints.
Therefore the Lean correspondence is not a proof of the empirical result; it
is a formal anchor for the drift values and Chernoff-style Route A semantics.

## 14. Freeze checklist

Before primary validation, freeze all of the following:

1. final type set;
2. final mixture grid;
3. final \(n\) grid;
4. final \(\rho_{\mathrm{fm}}\) grid;
5. instance count per cell;
6. timeout;
7. solver backend and version;
8. direct CNF encoding procedure;
9. independent semantic verifier;
10. seed derivation and constraint serialization hash;
11. feature schema;
12. train/test split;
13. primary and secondary predictors;
14. primary decision rule;
15. exclusion / timeout handling;
16. analysis script;
17. statement that all pilot data are exploration only.

Only after this checklist is committed should primary data be generated.

## 15. Immediate next actions

1. Implement a small Exp44 pilot harness or adapt the Mixed-CSP harness.
2. Run a smoke test with known satisfiable / unsatisfiable cardinality formulas.
3. Run the pilot grid in §5.1.
4. Record a pilot summary before any freeze decision.
5. If the pilot passes, freeze preregistration + code + analysis script.
6. Only then run primary validation.

Recommended commit message for the draft:

```text
Draft Exp44 Cardinality-SAT Route A preregistration
```
