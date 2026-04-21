# Baseline Comparison for Paper 3

This reanalysis compares three predictive models on the trial-level Exp36/Exp39 data:

| Model | Features | Interpretation |
|---|---|---|
| `token_only` | context length only | Long-context baseline |
| `quality_blind` | context length + any contradiction | Count/presence baseline without contradiction type |
| `structure_aware` | context length + subtle + structural indicators | Structural-persistence proxy |

The main question is whether the structure-aware model improves out-of-sample prediction over length-only and quality-blind baselines.

## Leave-One-Model-Out on Exp36

| Model | Log loss | Brier | Accuracy@0.5 |
|---|---:|---:|---:|
| `structure_aware` | 0.4963 | 0.1582 | 0.737 |
| `quality_blind` | 0.5627 | 0.1872 | 0.720 |
| `token_only` | 0.7191 | 0.2627 | 0.473 |

## Leave-One-Context-Out on Exp36

| Model | Log loss | Brier | Accuracy@0.5 |
|---|---:|---:|---:|
| `structure_aware` | 0.3893 | 0.1218 | 0.804 |
| `quality_blind` | 0.5004 | 0.1660 | 0.767 |
| `token_only` | 0.6951 | 0.2510 | 0.530 |

## Exp39 Prospective 2x2 Test

All models below were fit on Exp36 and evaluated on the later Exp39 2x2 replication.

| Model | Log loss | Brier | Accuracy@0.5 | Predicted zero/256K - structural/32K | Direction supported? |
|---|---:|---:|---:|---:|---|
| `structure_aware` | 0.3090 | 0.0880 | 0.900 | 0.8092 | yes |
| `quality_blind` | 0.4899 | 0.1447 | 0.900 | 0.5267 | yes |
| `token_only` | 0.6983 | 0.2525 | 0.583 | -0.0951 | no |

## Interpretation

The structure-aware model is the strongest model on the Exp39 prospective test and correctly predicts the registered direction: short structural contradiction should perform worse than much longer filler-only context.
On Exp36 leave-one-model-out, the quality-blind baseline is competitive, showing that merely knowing whether a contradiction is present already explains a large fraction of the effect. This is useful rather than fatal: it means the next decisive experiment should separate subtle/scoped/structural contradiction types under matched contradiction presence.
Retrieval-hit-rate baselines are not applicable to Exp36/Exp39 because these are single-shot prompt experiments, not RAG dialogue runs. They should be included in a separate ON/OFF dialogue reanalysis.

## Scope

This is a zero-cost reanalysis of existing data. It does not replace a future OSF-registered Exp40; it defines what Exp40 should beat.
