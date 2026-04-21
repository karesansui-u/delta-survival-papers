# Exp.41 Pre-registration: Cross-Model Width Replication

Status: frozen before data collection.

## 1. Purpose

Exp.40 showed on `gpt-4.1-mini` that scoped conflict behaves like a repaired /
zero-like condition while unscoped subtle and structural conflicts reduce
accuracy. Exp.41 asks whether the most important direction, scoped beating
structural, survives across additional models.

## 2. Research Question

Across models, does explicit scoping protect logical consistency relative to an
unscoped structural contradiction under the same 32K arithmetic task family?

## 3. Models

Frozen primary model set:

| Model | Role |
|---|---|
| `gpt-4.1-nano` | Known to be robust to subtle in Exp.36 but vulnerable to structural |
| `gemini-3.1-flash-lite-preview` | Cross-provider width check from Exp.36 |

Recommended positive-control model:

| Model | Role |
|---|---|
| `gpt-4.1-mini` | Positive-control repeat of Exp.40 |

If any model ID is unavailable at freeze time, the replacement must be selected
and recorded before data collection. Replacement selection cannot depend on new
Exp.41 outcomes.

## 4. Experimental Design

| Factor | Levels |
|---|---|
| Context length | 32K only |
| Conditions | `scoped`, `subtle`, `structural` |
| Trials per cell | 30 |
| Temperature | 1.0 |
| Target sets | Same five target triples as Exp.40 |
| Injection position | Midpoint of filler block |

No `zero_sanity` primary cell is included to keep width cost low. A small
`zero_sanity` diagnostic may be run with 10 trials per model before the primary
cells. If diagnostic accuracy is below 80%, primary interpretation for that
model is suspended.

## 5. Conditions

`scoped`
  Same condition family as Exp.40: conflicting task-variable value is explicitly
  assigned to a separate, out-of-scope context.

`subtle`
  Same unscoped alternate-source condition family as Exp.40.

`structural`
  Same self-referential impossible constraint family as Exp.40.

## 6. Primary Prediction

Primary per-model prediction:

```text
accuracy(scoped) > accuracy(structural)
```

Primary across-model support:

```text
scoped > structural in at least 2/2 primary models
```

The `gpt-4.1-mini` positive control is reported separately and does not rescue
the primary width decision. Primary support is judged on the new primary models
only. Adding another primary model would require a new preregistration version
before any new data are collected.

## 7. Secondary Predictions

Secondary ordered diagnostic:

```text
accuracy(scoped) >= accuracy(subtle) >= accuracy(structural)
```

`subtle` is model-sensitive by design. Exp.36 already suggests that `nano` can
be insensitive to subtle contradiction. Therefore failure of
`scoped >= subtle >= structural` in a model where `subtle` is near `scoped` does
not falsify the primary width claim.

## 8. Statistical Reporting

The primary decision rule is the sign of the per-model contrast
`accuracy(scoped) - accuracy(structural)`.

For transparency, report:

- per-model cell accuracies;
- scoped-structural margin;
- one-sided Fisher exact test for `scoped > structural`;
- optional sign test across models.

No p-value threshold replaces the preregistered directional criterion.

## 9. Baseline-Model Test

Exp.41 is primarily a width replication, not a new baseline-model comparison.
However, report a descriptive quality-blind vs structure-aware comparison:

| Condition | `quality_blind` coding | `structure_aware` coding |
|---|---|---|
| `scoped` | contradiction_present = 1 | repaired / zero-like |
| `subtle` | contradiction_present = 1 | subtle-loss |
| `structural` | contradiction_present = 1 | structural-loss |

The expected descriptive direction is:

```text
structure_aware log loss < quality_blind log loss
```

## 10. Falsification / Weakening Rules

Primary width support fails if:

```text
accuracy(scoped) <= accuracy(structural)
```

in either primary model.

The broader scope-as-repair interpretation is weakened if `scoped` is not above
`structural` in any primary model, or if diagnostic `zero_sanity` fails for most
models.

## 11. Exclusions

API errors are excluded from denominators and reported separately. Successful
API responses with wrong, missing, or nonnumeric final answers are counted as
incorrect.

## 12. Scope

Exp.41 tests width, not gradient. It does not claim a universal subtle
contradiction response and does not estimate a universal coefficient.
