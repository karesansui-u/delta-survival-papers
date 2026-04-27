# Backblaze Loss-Only v2 Primary Report

Status: primary validation completed. Primary support passed under the frozen
v2 decision rule. This is same-domain observational loss-only support only. It
is not repair-flow evidence and it does not erase the Q4 2025 no-support
result.

Date run: 2026-04-26

Freeze commit:

```text
ba98d64 Freeze Backblaze v2 loss-only primary package
```

Evaluation script SHA256:

```text
58d2b17ee8fa91446156fb4d9215dc365d69c274347f3af7c2f210979116616c
```

Raw primary JSON:

```text
analysis/backblaze_loss_only_v2/data/backblaze_q3_2025_primary_result.json
sha256: 9ee59f8680f6139a02ae8b8f3c312d224e90ee94ad1b3f005c32e9bd1f26a032
```

The raw JSON is intentionally kept under `analysis/backblaze_loss_only_v2/data/`,
which is git-ignored. This report records the decision-relevant results.

## 1. Scope

This is a G4 non-CSP observational loss-only retry on a fresh untouched
Backblaze archive.

It tests whether a calibration-aware SMART degradation model improves
prediction of future drive failure over preregistered metadata / fleet /
exposure baselines.

It does not test:

- recovery amount \(r_t\);
- preventive maintenance;
- operational \(M_{\mathrm{recovery}}\);
- G4 v2 repair / maintenance validation;
- universal-law status;
- retroactive cancellation of the Q4 2025 no-support result.

## 2. Frozen Run

Archive:

```text
Backblaze data_Q3_2025.zip
```

Prediction horizon:

```text
H = 30 days
```

Training prediction dates:

```text
2025-07-01 through 2025-08-12 (43 dates)
```

Calibration prediction dates:

```text
2025-08-13 through 2025-08-21 (9 dates)
```

Test prediction dates:

```text
2025-08-22 through 2025-08-31 (10 dates)
```

Rows:

```text
train rows: 13,872,636
test rows:   3,248,187
train positives: 16,428
test positives:   3,983
```

Training class weights for stage-1 B1/B2/B3/Primary:

```text
class 0: 0.5005928029
class 1: 422.2253469686
```

## 3. Primary Results

Primary metric:

```text
held-out calibrated log loss on final test block
```

| Model | Log loss | Stage-1 AUC | Brier |
|---|---:|---:|---:|
| B0 training prevalence | 0.009447 | 0.500000 | 0.001225 |
| B1 metadata | 0.008959 | 0.696162 | 0.001222 |
| B2 fleet context | 0.008801 | 0.739014 | 0.001221 |
| B3 exposure | 0.009049 | 0.693592 | 0.001223 |
| Primary metadata + SMART | 0.007936 | 0.882895 | 0.001187 |

Best baseline:

```text
B2_fleet_context, log loss = 0.0088012192
```

Primary model:

```text
metadata + SMART, calibrated log loss = 0.0079358992
```

Primary decision rule:

```text
logloss(primary) < 0.95 * min(logloss(B0), logloss(B1), logloss(B2), logloss(B3))
```

Decision:

```text
H1 calibrated predictive improvement: true
```

Relative improvement over the best baseline:

```text
9.83%
```

This exceeds the preregistered 5% threshold.

## 4. Directional Consistency

H2 required the five core SMART coefficients to be non-negative as a direction
test.

| SMART field | Coefficient | Non-violating |
|---|---:|---|
| `smart_5_raw` | 10.653083 | true |
| `smart_187_raw` | 18.309913 | true |
| `smart_188_raw` | 4.009310 | true |
| `smart_197_raw` | 25.442836 | true |
| `smart_198_raw` | 30.984224 | true |

Decision:

```text
H2 core directional consistency: true
```

All five preregistered core SMART coefficients are directionally consistent.

## 5. Ranking Guardrail

H3 required the stage-1 primary model to retain stronger ranking signal than
the preregistered baselines.

Key comparison:

```text
stage-1 primary AUC = 0.8828952372
max baseline stage-1 AUC = 0.7390138398
```

Decision:

```text
H3 ranking-signal guardrail: true
```

This means the calibrated log-loss gain is not merely a calibration artifact
on top of a weak ranking model; the primary model also retains the strongest
stage-1 ordering signal among the preregistered candidates.

## 6. Overall Decision

Frozen decision output:

```text
H1_calibrated_predictive_improvement: true
H2_core_directional_consistency: true
H3_ranking_signal_guardrail: true
primary_support: true
no_repair_flow_claim: true
```

Therefore:

```text
Backblaze Q3 2025 provides observational support for a calibration-aware
loss-only structural-persistence design in the Backblaze reliability domain.
```

This is the allowed wording under the frozen manifest. It is not repair-flow
evidence, not equal in strength to Exp43c, and not a universal-law claim.

## 7. Interpretation Boundary

This is a same-domain second attempt after a closed Q4 2025 no-support result.
That matters for evidence weight.

What this result supports:

- a calibration-aware SMART loss-only design can beat preregistered
  metadata / fleet / exposure baselines on a fresh untouched Backblaze archive;
- the five-field core SMART vector carries directionally consistent reduction-side
  signal in this archive;
- the signal survives both calibrated log-loss evaluation and the stage-1 AUC
  guardrail.

What this result does not support:

- repair-flow \(r_t\) or maintenance evidence;
- cancellation of the Q4 2025 no-support result;
- non-CSP universality on its own;
- evidence equal in strength to a first-attempt randomized Route A primary.

The clean reading is:

```text
Backblaze v1 showed that a poorly calibrated same-domain design can fail badly
under log loss. Backblaze v2 shows that a preregistered calibration-aware
same-domain redesign can pass on a fresh untouched archive.
```

That is real progress, but it remains observational and same-domain.
