# Exp.41 Model Comparison

Models: `['gpt-4.1-nano', 'gemini-3.1-flash-lite-preview']`

Descriptive leave-one-(model,target)-out comparison over primary conditions only.

| Model | Log loss | Brier | Accuracy at 0.5 |
|---|---:|---:|---:|
| `structure_aware_ordered` | 0.4715 | 0.1535 | 0.8000 |
| `structure_aware_categorical` | 0.5016 | 0.1637 | 0.8000 |
| `quality_blind` | 0.6588 | 0.2330 | 0.6333 |

Expected descriptive direction: structure-aware models beat `quality_blind`.
