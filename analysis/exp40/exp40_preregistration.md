# Exp.40 Pre-registration: Contradiction Quality Under Matched Presence

Frozen before new data collection.

## 1. Purpose

Exp.36 and Exp.39 showed that structural contradiction can dominate context
length. The strongest remaining baseline is not token length, but
`quality_blind`: knowing only whether a contradiction is present already
predicts much of the effect.

Exp.40 therefore fixes contradiction presence and context length, and varies
only the quality / scope of the contradiction.

## 2. Research Question

When context length and contradiction presence are matched, does a
structure-aware model predict accuracy better than a quality-blind
contradiction-presence model?

## 3. Primary Model

Primary model: `gpt-4.1-mini`

Reason: Exp.36 showed that `gpt-4.1-mini` is sensitive to subtle contradiction
at 32K, while `gpt-4.1-nano` was nearly insensitive to the same subtle condition.
Using `gpt-4.1-mini` makes the scoped/subtle/structural ordering measurable
without changing the task family.

## 4. Experimental Design

| Factor | Levels |
|---|---|
| Context length | 32K only |
| Conditions | `zero_sanity`, `scoped`, `subtle`, `structural` |
| Trials per cell | 30 |
| Total trials | 120 |

All primary contradiction conditions contain a task-variable-related statement.
The difference is whether the contradiction is explicitly scoped away,
unscoped but mild, or structurally impossible.

## 5. Conditions

`zero_sanity`
  Filler-only sanity check. It is not part of the primary ordered contrast, but
  verifies that the arithmetic task remains solvable under the generated 32K
  context.

`scoped`
  A conflicting value is presented as belonging to a separate measurement
  context that is explicitly not the context used for the final task. This is a
  scoped contradiction / non-collapse intervention.

`subtle`
  A conflicting value is presented as an unscoped alternate source report, as in
  Exp.36. This matches contradiction presence while removing explicit scope.

`structural`
  The context contains self-referential impossible constraints involving task
  variables, as in Exp.36/39.

## 6. Task

Each prompt defines three variables at the beginning:

```text
a = ...
b = ...
c = ...
```

The final task asks:

```text
a + b + c
```

The model must output only the final integer.

## 7. Primary Prediction

Primary ordered prediction:

```text
accuracy(scoped) > accuracy(subtle) > accuracy(structural)
```

Strong support:

```text
accuracy(scoped) - accuracy(subtle) >= 0.20
and
accuracy(subtle) - accuracy(structural) >= 0.20
```

The first inequality tests whether explicit scope repairs a contradiction-like
surface conflict. The second tests whether subtle contradiction remains weaker
than structural contradiction.

## 8. Secondary Predictions

1. `accuracy(zero_sanity) >= 0.80`.
2. `accuracy(scoped) >= accuracy(subtle)`.
3. `accuracy(subtle) >= accuracy(structural)`.

## 9. Baseline-Model Test

Fit the same three model classes used in the Exp.36/39 reanalysis:

1. `token_only`
2. `quality_blind`
3. `structure_aware`

For Exp.40 alone, `token_only` is intentionally uninformative because context
length is fixed. The decisive comparison is:

```text
structure_aware log loss < quality_blind log loss
```

on the primary contradiction conditions `scoped`, `subtle`, and `structural`.

## 10. Falsification Rules

The primary prediction is not supported if either:

1. `accuracy(scoped) <= accuracy(subtle)`, or
2. `accuracy(subtle) <= accuracy(structural)`.

The strong-support criterion fails if the ordered direction holds but either
margin is below 20 percentage points.

The broader structure-aware claim is weakened if the quality-blind model has
equal or lower log loss than the structure-aware model on Exp.40 primary
conditions.

## 11. Exclusions

API errors are excluded from accuracy denominators and reported separately.
Trials with successful API responses but wrong / missing numerical answers are
counted as incorrect, not excluded.

If `zero_sanity` accuracy is below 80%, the run is treated as a failed task
sanity check and primary interpretation is suspended until the task is repaired.

## 12. Scope

This experiment does not claim a universal contradiction taxonomy. It tests
whether the structure-aware account improves over a contradiction-presence-only
baseline under one fixed task family and one model where subtle contradiction is
known to be measurable.
