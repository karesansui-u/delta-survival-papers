# Backblaze Loss-Only Primary Report

Status: primary validation completed. No primary support under the frozen
decision rule. Not repair-flow evidence.

Date run: 2026-04-23

Freeze commit:

```text
d499843 Freeze Backblaze loss-only primary package
```

Evaluation script SHA256:

```text
af3f5c44b55fb97869e421a26f492b7dc1837a1f7c4e3e7025e77801ef2c9945
```

Raw primary JSON:

```text
analysis/backblaze_loss_only/data/backblaze_q4_2025_primary_result.json
sha256: 529f801d2b872a4d3189fd716f57c99a02dc0f7e66f4923a05b3b9771109aafc
```

The raw JSON is intentionally kept under `analysis/backblaze_loss_only/data/`,
which is git-ignored. This report records the decision-relevant results.

## 1. Scope

This is a G4 non-CSP observational loss-only test.

It tests whether lagged SMART degradation indicators improve prediction of
future drive failure over preregistered metadata / exposure baselines.

It does not test:

- repair flow \(g_t\);
- preventive maintenance;
- operational \(M_r\);
- G4 v2 repair / maintenance validation;
- universal-law status.

## 2. Frozen Run

Archive:

```text
Backblaze data_Q4_2025.zip
```

Prediction horizon:

```text
H = 30 days
```

Training prediction dates:

```text
2025-10-01 through 2025-11-21 (52 dates)
```

Test prediction dates:

```text
2025-11-22 through 2025-12-01 (10 dates)
```

Rows:

```text
train rows: 17,417,435
test rows:   3,372,672
train positives: 16,329
test positives:   1,529
```

Training class weights:

```text
class 0: 0.5004691943
class 1: 533.3282809725
```

## 3. Primary Results

Primary metric:

```text
held-out log loss on final test block
```

| Model | Log loss | AUC | Brier |
|---|---:|---:|---:|
| B0 intercept | 0.934999 | 0.500000 | 0.368948 |
| B1 metadata | 0.865056 | 0.744594 | 0.298335 |
| B2 fleet context | 1.102710 | 0.768462 | 0.295160 |
| B3 exposure | 0.157102 | 0.739333 | 0.043814 |
| Primary metadata + SMART | 1.779176 | 0.902456 | 0.105413 |

Best baseline:

```text
B3_exposure, log loss = 0.1571015483
```

Primary model:

```text
metadata + SMART, log loss = 1.7791763468
```

Primary decision rule:

```text
logloss(primary) < 0.95 * min(logloss(B0), logloss(B1), logloss(B2), logloss(B3))
```

Decision:

```text
H1 predictive improvement: false
```

The primary model has high AUC, but the preregistered primary metric is log
loss. Secondary metrics cannot overturn the primary log-loss decision.

## 4. Directional Consistency

H2 required SMART coefficients to be non-negative as a direction test.

| SMART field | Coefficient | Non-violating |
|---|---:|---|
| `smart_5_raw` | 4.785349 | true |
| `smart_187_raw` | 17.631894 | true |
| `smart_188_raw` | 11.936678 | true |
| `smart_197_raw` | 18.599214 | true |
| `smart_198_raw` | 12.589274 | true |
| `smart_199_raw` | -7.020659 | false |

Decision:

```text
H2 directional consistency: false
```

Five of six SMART coefficients are directionally consistent, but
`smart_199_raw` violates the frozen sign rule. Therefore H2 fails.

## 5. Overall Decision

Frozen decision output:

```text
H1_predictive_improvement: false
H2_directional_consistency: false
H3_test_block_direction: false
primary_support: false
no_repair_flow_claim: true
```

Therefore:

```text
Backblaze Q4 2025 does not provide primary support for the preregistered
loss-only non-CSP observational anchor.
```

This is not a falsification of the structural balance law. It is a failed
observational anchor under this archive, feature set, optimizer, horizon,
split, and primary metric.

## 6. Interpretation

The result separates ranking from calibrated predictive support:

- The SMART model ranks failures well by AUC (`0.902456`).
- The same model performs poorly under log loss (`1.779176`), losing to the
  exposure baseline (`0.157102`).
- This suggests that the frozen streaming weighted-logistic implementation
  produces risk ordering but not well-calibrated probabilities on this held-out
  test block.

Because log loss was the primary metric, this is a no-support outcome.

Any follow-up using calibration, different class weighting, a survival model,
longer historical context, or a different Backblaze archive would require a
new preregistration / freeze package. It cannot rescue this primary result.
