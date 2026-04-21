# Exp.42 Model Comparison

Model: `gpt-4.1-mini`

Leave-one-target-out comparison over primary conditions only.

| Model | Log loss | Brier | Accuracy at 0.5 |
|---|---:|---:|---:|
| `scope_gradient` | 0.2646 | 0.0799 | 0.9050 |
| `binary_scoped` | 0.3012 | 0.0834 | 0.9050 |
| `quality_blind` | 0.5577 | 0.1853 | 0.7550 |

Preregistered direction: `scope_gradient` < `binary_scoped` < `quality_blind` in log loss.
