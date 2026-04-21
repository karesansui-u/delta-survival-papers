# Exp.40 Model Comparison

Model: `gpt-4.1-mini`

Leave-one-target-out comparison. The primary scope is `scoped`, `subtle`, and `structural`; `zero_sanity` is used for training/calibration but is not part of the primary baseline comparison.

| Model | Primary log loss | Primary Brier | All log loss | All Brier |
|---|---:|---:|---:|---:|
| `structure_aware` | 0.2763 | 0.0876 | 0.2207 | 0.0664 |
| `quality_blind` | 0.6944 | 0.2506 | 0.5310 | 0.1884 |

The structure-aware coding treats `scoped` as repaired / zero-like, while the quality-blind baseline treats `scoped`, `subtle`, and `structural` as contradiction-present.
