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
| Trials per cell | 50 |
| Total trials | 200 |
| Temperature | 1.0 |
| Target sets | 5 target triples reused from Exp.36/39 |
| Injection position | midpoint of the filler block |

All primary contradiction conditions contain a task-variable-related statement.
The difference is whether the contradiction is explicitly scoped away,
unscoped but mild, or structurally impossible.

The temperature, target sets, and midpoint injection policy are inherited from
Exp.36/39 for comparability. The trial count is increased from 30 to 50 per
cell because the decisive scoped-vs-subtle comparison may be smaller than the
structural-vs-zero contrast in Exp.39. No universal power claim is made; the
larger n is a low-cost precision increase before data collection.

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
accuracy(zero_sanity) ≈ accuracy(scoped) > accuracy(subtle) > accuracy(structural)
```

Strong support:

```text
accuracy(zero_sanity) - accuracy(scoped) <= 0.10
and
accuracy(scoped) - accuracy(subtle) >= 0.20
and
accuracy(subtle) - accuracy(structural) >= 0.20
```

The near-equality diagnostic tests whether explicit scope repairs a
contradiction-like surface conflict back toward the filler-only sanity level.
The second inequality tests whether scoped contradiction is less damaging than
unscoped subtle contradiction. The third tests whether subtle contradiction
remains weaker than structural contradiction.

## 8. Secondary Predictions

1. `accuracy(zero_sanity) >= 0.80`.
2. `accuracy(zero_sanity) - accuracy(scoped) <= 0.10`.
3. `accuracy(scoped) >= accuracy(subtle)`.
4. `accuracy(subtle) >= accuracy(structural)`.

## 9. Baseline-Model Test

Fit the same three model classes used in the Exp.36/39 reanalysis:

1. `token_only`
2. `quality_blind`
3. `structure_aware`

For Exp.40 alone, `token_only` is intentionally uninformative because context
length is fixed.

Pre-specified coding:

| Condition | `quality_blind` coding | `structure_aware` coding |
|---|---|---|
| `zero_sanity` | contradiction_present = 0 | zero-like |
| `scoped` | contradiction_present = 1 | repaired / zero-like |
| `subtle` | contradiction_present = 1 | subtle-loss |
| `structural` | contradiction_present = 1 | structural-loss |

Thus `quality_blind` predicts that `scoped`, `subtle`, and `structural` should
behave similarly after conditioning on context length. The structure-aware
prediction is different: `scoped` is an in-context repair / scoping
intervention and should move back toward `zero_sanity`, while `subtle` and
`structural` remain unscoped losses of different severity.

The decisive comparison is:

```text
structure_aware log loss < quality_blind log loss
```

on the primary contradiction conditions `scoped`, `subtle`, and `structural`.

## 10. Falsification Rules

The primary prediction is not supported if either:

1. `accuracy(scoped) <= accuracy(subtle)`, or
2. `accuracy(subtle) <= accuracy(structural)`.

The strong-support criterion fails if the ordered direction holds but either
margin is below 20 percentage points, or if `scoped` is more than 10 percentage
points below `zero_sanity`.

The scoped-as-repair interpretation is weakened if:

```text
accuracy(zero_sanity) - accuracy(scoped) > 0.10
```

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

This is a single-model prospective test. A later secondary confirmation may
repeat only the most diagnostic scoped-vs-structural contrast on additional
models, but such replication is outside the Exp.40 primary claim.
