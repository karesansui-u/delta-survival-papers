# Backblaze Loss-Only v2 Preregistration Draft

Status: draft preregistration for a same-domain non-CSP loss-only retry.
Not frozen. Not validation evidence. Not repair-flow evidence.

Date opened: 2026-04-24

Upstream exploration / archive notes:

- `analysis/backblaze_loss_only_v2_exploration_note.md`
- `analysis/backblaze_loss_only_v2_archive_ranking_note.md`
- `analysis/g4_backblaze_q3_2025_archive_feasibility_note.md`

## 1. Purpose

This draft defines a Backblaze v2 same-domain retry after the closed Q4 2025
no-support result.

The target claim remains intentionally narrow:

```text
in a repeated-unit industrial reliability panel, a calibration-aware
loss-only degradation model predicts future failure better than preregistered
non-SMART baselines on a fresh untouched archive
```

This is still a loss-only branch:

```text
g_t = 0
```

It does not test repair flow, preventive maintenance, operational \(M_r\), or
G4 v2 repair / maintenance validation.

## 2. Evidence Tier

This draft is weaker than Route A primary evidence and weaker than a
first-attempt same-domain success.

| Anchor | Data generation | Primary strength |
|---|---|---|
| Exp43c q-coloring | Randomized generation from frozen rules | Route A primary validation |
| Backblaze v1 Q4 2025 | Existing observational logs | Closed same-domain no-support |
| Backblaze v2 Q3 2025 | Existing observational logs, same domain second attempt | Observational loss-only support only if it passes |

Even if Backblaze v2 passes, it may be reported only as:

```text
observational support for a revised calibration-aware loss-only design in the
Backblaze reliability domain
```

It must not be reported as:

```text
repair-flow evidence;
G4 v2 repair / maintenance validation;
evidence equal in strength to Exp43c;
retroactive cancellation of the Q4 2025 no-support result.
```

## 3. Q4 2025 Boundary

Backblaze Q4 2025 remains closed:

```text
analysis/backblaze_loss_only/primary_report.md
```

This v2 draft may reuse only qualitative lessons from Q4 2025:

- signal and calibration separated sharply;
- same-domain retry requires a fresh untouched archive;
- calibration should be explicit in the design;
- `smart_199_raw` requires domain-level handling rather than silent reuse.

This draft may not reuse Q4 2025 validation or test values for quantitative
tuning.

## 4. Selected Archive

Selected archive for this draft:

```text
data_Q3_2025.zip
URL: https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2025.zip
sha256: 0c8962e8efef6eba5ebe6f17f561265fef07df68c88fe3c65d4225159c54528c
```

Archive selection discipline:

- Q4 2025 is excluded because it was already consumed by the closed v1 primary;
- Q3 2025 was ranked first among untouched compatible quarters by
  metadata-only criteria;
- Q3 2025 passed the metadata-only feasibility check.

This draft therefore fixes the archive identity. The later freeze manifest
must still fix implementation details, split boundaries, script hash, and
claim wording.

## 5. Unit, Time, And Endpoint

Unit:

```text
serial_number
```

Time:

```text
date
```

Endpoint:

```text
future failure in (t, t + H]
```

Primary horizon:

```text
H = 30 days
```

Rationale:

1. it matches the v1 loss-only branch and therefore isolates the design change
   to calibration rather than horizon;
2. Q3 2025 feasibility has already shown that the 30-day endpoint lies fully
   inside the archive under eligible-date splitting;
3. the value is fixed before any predictor-level inspection on Q3 2025.

## 6. Predictors

### 6.1 Core theory-side SMART set

The primary theory-side degradation vector uses the following SMART raw fields:

```text
smart_5_raw
smart_187_raw
smart_188_raw
smart_197_raw
smart_198_raw
```

Primary transform:

```text
log1p(raw SMART value clipped at zero)
```

For each drive-day \(t\):

```text
L_obs_core(t) = [
  log1p(smart_5_raw),
  log1p(smart_187_raw),
  log1p(smart_188_raw),
  log1p(smart_197_raw),
  log1p(smart_198_raw)
]
```

### 6.2 smart_199 handling

`smart_199_raw` is excluded from the primary theory-side loss vector in this
draft.

Reason for exclusion:

```text
v2 treats UDMA CRC errors as an interface-integrity indicator rather than a
direct drive-internal degradation coordinate.
```

This exclusion is part of the v2 design, not a hidden post-test adjustment. It
must be understood as a domain-grounded precommitment for this draft. Any
reader-facing justification note or citation should be added before freeze,
not after a Q3 2025 primary result.

`smart_199_raw` is not part of any primary support claim in this draft.

## 7. Baselines And Model Path

### 7.1 Baselines

Baseline B0: intercept only.

```text
failure_future ~ 1
```

Operational implementation:

```text
predict a single probability equal to the empirical positive rate in the
training prediction rows
```

Baseline B1: metadata only.

```text
failure_future ~ model + capacity_bytes + is_legacy_format
```

Baseline B2: fleet context.

```text
failure_future ~ model + capacity_bytes + datacenter + cluster_id + vault_id
                  + pod_id + pod_slot_num + is_legacy_format
```

Baseline B3: exposure proxy.

```text
failure_future ~ model + capacity_bytes + drive_age_days
```

`drive_age_days` is computed from the first observed date of the same
`serial_number` within the frozen Q3 2025 archive.

### 7.2 Primary theory model

Primary model:

```text
failure_future ~ metadata fields + L_obs_core(t)
```

The key v2 design change is not a new domain or new endpoint. It is the
calibration-aware evaluation path below.

### 7.3 Two-stage calibration-aware path

For each non-intercept model in `{B1, B2, B3, Primary}`:

1. fit a stage-1 weighted streaming L2-logistic model on the training split;
2. compute the stage-1 decision score on the validation split only;
3. fit a one-dimensional Platt calibrator on validation scores only;
4. evaluate calibrated probabilities on the final held-out test block once.

Equivalent summary:

```text
stage 1 = ranking model
stage 2 = probability calibration
```

The validation block is therefore used for calibration, not for test-time
selection after seeing the final block.

Baseline B0 is not Platt-scaled. It remains the constant training-prevalence
reference model.

## 8. Model Class

Stage-1 model class:

```text
streaming L2-regularized logistic regression
```

Expected implementation family:

```text
sklearn.linear_model.SGDClassifier(loss="log_loss", penalty="l2")
```

Stage-2 calibrator:

```text
Platt scaling = one-dimensional logistic regression on stage-1 decision score
```

The draft fixes the model family and calibration family. The freeze manifest
must still fix:

- the exact implementation package;
- class-weight policy;
- alpha / regularization parameters;
- number of passes / epoch rule;
- calibrator implementation details;
- random seed;
- script hash.

## 9. Hypotheses

H1: Calibrated predictive improvement.

```text
logloss(calibrated primary) < 0.95 * min(
  logloss(B0),
  logloss(calibrated B1),
  logloss(calibrated B2),
  logloss(calibrated B3)
)
```

This requires at least a 5% log-loss improvement over the best eligible
baseline on the final held-out test block.

H2: Core directional consistency.

For the five core SMART fields with nonzero learned stage-1 coefficients, the
expected sign is risk-increasing:

```text
coefficient >= 0
```

A zero coefficient from regularization passes H2 as non-violating, not as
theory-supporting.

H3: Ranking-signal guardrail.

The calibration step must not rescue a model with no underlying ranking
signal. Therefore:

```text
AUC(stage-1 primary) > max(AUC(B0), AUC(stage-1 B1), AUC(stage-1 B2), AUC(stage-1 B3))
```

This is a guardrail, not a replacement primary metric. AUC cannot overturn a
log-loss failure.

H4: No repair-flow claim.

Even if H1-H3 pass, the result remains loss-only same-domain observational
support only.

## 10. Split Discipline

Random row split is forbidden.

Eligible prediction dates:

```text
date t is eligible iff t + H <= max date in the frozen archive
```

For `data_Q3_2025.zip` with `H = 30`, the eligible prediction dates are:

```text
2025-07-01 through 2025-08-31
```

Primary split for this draft:

```text
train:      2025-07-01 through 2025-08-12   (43 dates)
validation: 2025-08-13 through 2025-08-21   ( 9 dates)
test:       2025-08-22 through 2025-08-31   (10 dates)
```

Rows outside the eligible prediction-date range are not used as prediction
rows. They may still serve as future endpoint support for earlier prediction
dates.

The final test block is used once.

All feature engineering rules, model hyperparameters, calibration rules, and
evaluation code must be frozen before evaluating the final test block.

## 11. Missingness And Eligibility

The frozen Q3 2025 archive is eligible only if:

1. it still contains `serial_number`, `date`, and `failure`;
2. it contains all five core SMART fields;
3. it contains at least one metadata baseline field among `model` and
   `capacity_bytes`;
4. the final held-out block contains both failure and non-failure labels;
5. the final held-out block contains at least \(N_f\) failure events, where
   \(N_f\) is fixed in the freeze manifest.

For this draft, recommended floor:

```text
N_f >= 200
```

The Q3 feasibility note observed:

```text
raw failure rows in test endpoint horizon: 571
```

This is a feasibility fact only, not a performance result.

If any core SMART field is absent at freeze time, this draft becomes
ineligible rather than silently substituting a new field.

## 12. Metrics

Primary metric:

```text
held-out calibrated log loss on the final test block
```

Secondary metrics:

```text
AUC of stage-1 scores
Brier score of calibrated probabilities
calibration curve summary
```

Secondary metrics cannot overturn the primary calibrated log-loss decision.

## 13. Decision Rules

Primary support:

```text
H1, H2, and H3 all pass
```

Weak support:

```text
H1 passes but H2 fails or is mixed
```

No support:

```text
H1 fails on the final test block
```

Inconclusive:

```text
archive eligibility fails;
or final test block has only one class;
or the frozen calibration path cannot be executed as specified.
```

No outcome permits a repair-flow claim.

## 14. Non-claims

This draft does not claim:

1. that Backblaze validates repair flow \(g_t\);
2. that a pass would erase the Q4 2025 no-support result;
3. that the structural balance law is falsified if Q3 2025 fails;
4. that `smart_199_raw` is universally irrelevant in all reliability systems;
5. that the result would be equal in strength to Exp43c;
6. that the result would automatically transfer to non-Backblaze industrial
   systems;
7. that this same-domain second attempt is sufficient for universal non-CSP
   support.

## 15. Freeze Checklist

Before validation, freeze:

1. exact archive path / URL / SHA256 for Q3 2025;
2. exact eligible prediction-date range;
3. exact train / validation / test date boundaries;
4. exact horizon \(H = 30\);
5. exact five-field core SMART set;
6. exact metadata baseline fields;
7. exact drive-age construction rule;
8. stage-1 implementation package, optimizer, class-weight policy, alpha, seed,
   and epoch rule;
9. exact Platt calibrator implementation and its input score definition;
10. evaluation script hash;
11. minimum final-test failure count \(N_f\);
12. primary claim wording;
13. explicit statement that repair-flow G4 v2 remains paused.

## 16. Current Status

This is a draft. It should not be run as validation until:

1. the Q3 2025 archive is frozen in a manifest;
2. the evaluation script is finalized and hashed;
3. no predictor-level inspection has occurred on Q3 2025 beyond metadata-only
   feasibility facts;
4. the test block remains untouched until after freeze.

The next step, if continuing immediately, is:

```text
turn this draft into a freeze-manifest candidate by fixing the calibration
path, implementation choices, and script package before any Q3 predictor-level
inspection
```
