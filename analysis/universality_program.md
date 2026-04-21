# Structural Persistence Universality Program — Draft

Status: frozen program plan before next-stage data collection.

## Purpose

The next stage should test universality by asking whether a pre-specified
structure-aware coordinate outperforms simpler baselines, not by adding many
loosely related examples.

The shared test form is:

```text
structure-aware / L-normalized model
  beats
raw length / raw count / quality-blind baseline
```

The universality claim is therefore not that every domain has the same
coefficient. It is that, after the target structure and measurement rule are
fixed before observation, cumulative structural loss `L` carries predictive
information that simpler unweighted baselines miss.

## Axes

| Axis | Question | Proposed experiment | Primary contribution |
|---|---|---|---|
| Width | Does the scoped-vs-structural direction survive across models? | Exp.41 | Paper 3 defensibility |
| Gradient | Does scope strength produce an ordered response? | Exp.42 | Blocks the "just instruction following" objection |
| Route A replication | Does drift-weighted `L` beat raw count in a hard domain? | Mixed-CSP empirical | Empirical universality-class anchor |
| Formal | Under which assumptions does balance become tendency? | Lean theorem work | Law-strength upgrade |

## Recommended Order

1. Exp.41: small cross-model replication.
2. Exp.42: scope-strength dose response.
3. Mixed-CSP empirical Route A replication.
4. Formal work proceeds in parallel because it does not consume API budget.

This is an execution order, not a scientific-priority order. Exp.41 is first
because it is cheap and raises the defensive floor for Paper 3 width claims.
Exp.42 and Mixed-CSP carry the core prospective content for universality.

## Key Guardrail

Do not test `L > raw count` inside a single constant-drift family such as
NAE-SAT alone. In such a family, `L = m * constant`, so `L` and raw count are
regression-equivalent. Route A empirical tests must use either mixed-constraint
instances or cross-family comparisons.
