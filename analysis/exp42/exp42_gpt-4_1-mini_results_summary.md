# Exp.42 Results Summary

Model: `gpt-4.1-mini`

| Condition | Correct | N | Accuracy | Errors |
|---|---:|---:|---:|---:|
| `strong_scope` | 50 | 50 | 1.000 | 0 |
| `medium_scope` | 49 | 50 | 0.980 | 0 |
| `weak_scope` | 42 | 50 | 0.840 | 0 |
| `subtle` | 10 | 50 | 0.200 | 0 |
| `zero_sanity` | 20 | 20 | 1.000 | 0 |
| `structural_anchor` | 0 | 20 | 0.000 | 0 |

Primary prediction supported: `True`
Strong support: `False`
Weak-source diagnostic gap: `0.6399999999999999`
Secondary checks: `{'strong_above_0_80': True, 'weak_above_or_equal_subtle': True, 'strong_above_subtle': True, 'medium_above_subtle': True}`
Zero sanity passed: `True`
Structural anchor confirmed: `True`
