# Exp.42 Pre-registration: Scope-Strength Dose Response

Status: frozen before data collection.

## 1. Purpose

Exp.40 showed that an explicitly scoped conflict behaves like a repaired /
zero-like condition. The strongest objection is that the model was simply told
to ignore the conflicting value. Exp.42 therefore varies the strength of the
scope marker while keeping contradiction-like content and context length fixed.

## 2. Research Question

Does logical-consistency accuracy increase monotonically with the strength of
the scope marker?

## 3. Primary Model

Primary model: `gpt-4.1-mini`.

Reason: Exp.40 used this model and showed measurable separation among scoped,
subtle, and structural conditions at 32K.

## 4. Experimental Design

| Factor | Levels |
|---|---|
| Context length | 32K only |
| Conditions | `strong_scope`, `medium_scope`, `weak_scope`, `subtle` |
| Trials per cell | 50 |
| Total trials | 200 |
| Temperature | 1.0 |
| Target sets | Same five target triples as Exp.40 |
| Injection position | Midpoint of filler block |

Optional diagnostic:

| Condition | Trials | Purpose |
|---|---:|---|
| `zero_sanity` | 20 | Confirms the arithmetic task remains solvable |
| `structural_anchor` | 20 | Confirms the structural-collapse anchor remains severe |

Diagnostics are not part of the primary ordering.
Diagnostic pass criteria: `zero_sanity` passes at accuracy >= 0.80;
`structural_anchor` confirms the anchor at accuracy < 0.20.

## 5. Conditions

`strong_scope`
  Exp.40-style explicit out-of-scope language. It states that the conflicting
  value belongs to a separate context and that the initial variable definitions
  remain authoritative.

`medium_scope`
  Temporal or dataset scope without a direct instruction to ignore. Example:
  "In the 2019 calibration context, Source B recorded a = 349." The prompt does
  not explicitly say "do not use this" but makes the scope different from the
  current task context. Medium-scope templates must not contain imperative
  language such as "do not use", "ignore", "must not override", or "use only".

`weak_scope`
  Source label only. Example: "Source B reports a = 349." No temporal boundary,
  no dataset boundary, and no explicit instruction to ignore.

`subtle`
  Bare unscoped conflicting value with no source label, no temporal boundary,
  no dataset boundary, and no instruction. Example: "A later note records
  a = 349." This is the unscoped-loss baseline.

This deliberately differs from Exp.40's inherited subtle template pool, which
included weak source / measurement language. Exp.42 separates the minimal source
label from the fully unscoped conflicting assertion so that `weak_scope` and
`subtle` are not template-identical.

The phrase "a later note" is a narrative device, not a scope marker. It does
not identify a source, dataset, or temporal context distinct from the task.

## 6. Primary Prediction

Primary ordered prediction:

```text
accuracy(strong_scope) > accuracy(medium_scope) > accuracy(weak_scope)
```

Primary strong support:

```text
accuracy(strong_scope) - accuracy(medium_scope) >= 0.10
and
accuracy(medium_scope) - accuracy(weak_scope) >= 0.10
```

The 10-point margins are smaller than Exp.40 because gradient effects may be
weaker than scoped-vs-unscoped separation.

## 7. Secondary Predictions

Secondary predictions:

```text
accuracy(strong_scope) >= 0.80
accuracy(weak_scope) >= accuracy(subtle)
accuracy(strong_scope) > accuracy(subtle)
accuracy(medium_scope) > accuracy(subtle)
```

Expected weak-source diagnostic:

```text
0 <= accuracy(weak_scope) - accuracy(subtle) <= 0.15
```

This is a diagnostic, not a primary falsification rule. If the gap exceeds 15
points, the result suggests that even a minimal source label carries more repair
information than expected.

## 8. Baseline-Model Test

Compare:

1. `quality_blind`: all primary conditions are contradiction-present.
2. `binary_scoped`: strong/medium/weak all treated as scoped, subtle unscoped.
3. `scope_gradient`: ordinal scope-strength coding.

Pre-specified coding:

| Condition | `quality_blind` | `binary_scoped` | `scope_gradient` |
|---|---:|---:|---:|
| `strong_scope` | 1 | 1 | 3 |
| `medium_scope` | 1 | 1 | 2 |
| `weak_scope` | 1 | 1 | 1 |
| `subtle` | 1 | 0 | 0 |

The decisive model comparison is:

```text
scope_gradient log loss < binary_scoped log loss < quality_blind log loss
```

on the four primary conditions.

Model-comparison estimation:
  Use leave-one-target-out cross-validation over the five target triples. Within
  each training fold, fit cell-level binomial logistic models with a fixed weak
  L2 penalty matching the Exp.36/39 baseline-comparison convention. Report
  held-out trial-level log loss. If a cell is perfectly separated, clipping is
  applied only through the preregistered L2 fit, not by post-hoc probability
  editing.

## 9. Statistical Reporting

The primary decision rule is the ordered accuracy pattern and margin criteria,
not a p-value threshold.

Report:

- per-condition accuracies;
- adjacent margins;
- one-sided Fisher exact tests for strong > medium and medium > weak;
- leave-one-target-out model-comparison log loss.

## 10. Falsification / Weakening Rules

Primary gradient support fails if either adjacent direction reverses:

```text
accuracy(strong_scope) <= accuracy(medium_scope)
or
accuracy(medium_scope) <= accuracy(weak_scope)
```

Strong support fails if directions hold but either adjacent margin is below 10
percentage points.

The instruction-following objection remains strong if:

```text
accuracy(strong_scope) is high
and accuracy(medium_scope) ≈ accuracy(weak_scope) ≈ accuracy(subtle)
```

because that pattern would suggest that only explicit instruction, not scope
strength, produced the Exp.40 repair effect.

## 11. Exclusions

API errors are excluded from denominators and reported separately. Successful
API responses with wrong, missing, or nonnumeric final answers are counted as
incorrect.

If `zero_sanity` diagnostic accuracy is below 80%, primary interpretation is
suspended until task construction is repaired.

## 12. Scope

Exp.42 tests a scope-strength gradient in one model and one arithmetic task
family. It does not establish cross-model universality by itself.
