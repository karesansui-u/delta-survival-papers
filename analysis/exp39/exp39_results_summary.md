# Exp.39 Results Summary

Model: `gpt-4.1-nano`  
Date: 2026-04-21  
Trials: 2 conditions × 2 context lengths × 30 trials = 120

## Primary Prediction

`accuracy(32K structural) < accuracy(256K zero)`

## Result

| Condition | Context | Accuracy | Count |
|---|---:|---:|---:|
| zero | 32K | 0.967 | 29/30 |
| zero | 256K | 0.633 | 19/30 |
| structural | 32K | 0.000 | 0/30 |
| structural | 256K | 0.000 | 0/30 |

Primary margin:

```text
accuracy(256K zero) - accuracy(32K structural) = 0.633
```

The directional prediction is supported, and the pre-registered strong-support
threshold of 20 percentage points is met. Fisher exact test for the primary
contrast gives `p = 2.672e-08`.

## Interpretation

This is a focused prospective replication of the key Exp.36 direction: a short
context with task-relevant structural contradiction performs worse than a much
longer context containing task-irrelevant filler only.

The result does not show that context length is harmless. In fact, `zero / 256K`
drops from `29/30` to `19/30`. The supported claim is narrower: structural
contradiction remains a stronger collapse driver than filler length alone under
this registered comparison.

## Pilot Exclusions

Two pilot variants were attempted and excluded before the primary contrast:

- `exp39_failed_expression_pilot_gpt-4_1-nano_trials.jsonl`: a held-out
  expression task `2*a - b + c + d` failed sanity because `32K zero` was `0/30`.
- `exp39_failed_new_targets_pilot_gpt-4_1-nano_trials.jsonl`: new target values
  for the addition task produced target-specific arithmetic errors in `32K zero`.

The primary Exp.39 run therefore used the Exp.36 target sets exactly, isolating
the registered 2×2 contrast.

