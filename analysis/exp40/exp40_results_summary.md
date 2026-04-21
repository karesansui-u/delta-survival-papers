# Exp.40 Results Summary

Model: `gpt-4.1-mini`  
Date: 2026-04-21  
Trials: 4 conditions × 50 trials = 200  
API usage: 6,116,976 input tokens, 971 output tokens, approximately $2.45

## Primary Prediction

```text
accuracy(zero_sanity) ≈ accuracy(scoped) > accuracy(subtle) > accuracy(structural)
```

## Result

| Condition | Accuracy | Count | API errors |
|---|---:|---:|---:|
| `zero_sanity` | 1.00 | 50/50 | 0 |
| `scoped` | 1.00 | 50/50 | 0 |
| `subtle` | 0.46 | 23/50 | 0 |
| `structural` | 0.00 | 0/50 | 0 |

Primary prediction supported: `true`  
Strong support: `true`  
Scoped-zero gap: `0.00`

## Fisher Exact Tests

| Comparison | Alternative | p-value |
|---|---|---:|
| `scoped` vs `subtle` | `scoped > subtle` | 5.635e-11 |
| `subtle` vs `structural` | `subtle > structural` | 4.345e-09 |
| `zero_sanity` vs `scoped` | two-sided diagnostic | 1.000 |

## Interpretation

Exp.40 directly tests the strongest remaining baseline from the Exp.36/39
reanalysis: contradiction presence without contradiction quality. The result
strongly separates `scoped` from unscoped contradiction. A conflicting value
that is explicitly scoped out of the task behaves like filler-only context,
while an unscoped alternate-source value causes substantial degradation and
structural contradiction causes complete collapse.

This supports the scope-as-repair interpretation: the relevant variable is not
merely whether a contradiction-like sentence appears in the context, but whether
the conflict is structurally scoped away from the task.

## Scope

This is still a single-model prospective test on one arithmetic task family. It
supports the structure-aware account against a quality-blind baseline for this
setting, but it does not by itself establish universality across models or
tasks.
