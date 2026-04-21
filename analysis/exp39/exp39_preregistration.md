# Exp.39 Pre-registration: Prospective Contradiction-Dominance Test

Frozen before new data collection.

## 1. Purpose

Exp.36 already showed that structural contradictions can dominate long-context
filler in the original addition task. Exp.39 asks whether the same direction
holds in a minimal 2×2 prospective replication design.

## 2. Research Question

Does task-relevant structural contradiction in a 32K context degrade accuracy
more than task-irrelevant filler in a 256K context?

## 3. Experimental Design

| Factor | Levels |
|---|---|
| Context length | 32K, 256K |
| Condition | `zero`, `structural` |
| Trials per cell | 30 |
| Total trials | 120 |

The `zero` condition contains task-irrelevant factual filler only. The
`structural` condition replaces approximately 30% of filler sentences with
self-referential contradictions involving task variables.

## 4. Task

Each prompt defines three variables at the beginning:

```text
a = ...
b = ...
c = ...
```

The final task asks the model to compute:

```text
a + b + c
```

The model must output only the final integer.

This task and target set match Exp.36, preserving a clean baseline for the
focused prospective contrast.

## 4.1 Pilot Exclusion

Before the primary contrast, a held-out expression variant `2*a - b + c + d`
was attempted. It failed the sanity criterion because `32K zero` accuracy was
`0/30` for `gpt-4.1-nano`, before structural-condition trials were run. Those
partial data are archived separately as a failed pilot and are not part of the
Exp.39 primary test.

A second pilot with new target values for the same addition task also showed
target-specific arithmetic errors in `32K zero`. It is likewise archived as a
failed pilot. The primary Exp.39 test therefore uses the Exp.36 target sets
exactly, so that the prospective claim isolates the registered 2×2 contrast
rather than changing the arithmetic task.

## 5. Primary Prediction

Primary contrast:

```text
accuracy(structural, 32K) < accuracy(zero, 256K)
```

Interpretation:

- Support: the directional inequality holds.
- Strong support: the inequality holds with a margin of at least 20 percentage
  points.
- Failure: `accuracy(structural, 32K) >= accuracy(zero, 256K)`.

## 6. Secondary Predictions

1. `accuracy(zero, 32K) >= accuracy(zero, 256K)`.
2. `accuracy(structural, 32K) <= accuracy(zero, 32K)`.
3. `accuracy(structural, 256K) <= accuracy(zero, 256K)`.

These are secondary checks and do not replace the primary contrast.

## 7. Analysis Plan

For each cell, compute strict accuracy from the parsed final integer.

Report:

- 2×2 accuracy table
- primary contrast margin:
  `accuracy(zero, 256K) - accuracy(structural, 32K)`
- Fisher exact test for the primary contrast, if SciPy is available
- error count separately from incorrect answers

API errors are excluded from accuracy denominators and reported separately.

## 8. Falsification Rule

The central prospective prediction is not supported if the `32K structural`
condition is equal to or better than the `256K zero` condition under the same
model and evaluator.

## 9. Scope

This is not a claim about all models or all tasks. It is a focused prospective
test of the structural-persistence prediction against a context-length-only
baseline.
