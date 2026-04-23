# G4 Backblaze Loss-Only Preregistration Draft

Status: draft preregistration for a non-CSP loss-only observational anchor.
Not frozen. Not validation evidence. Not repair-flow evidence.

Date opened: 2026-04-23

Candidate dataset:

```text
Backblaze Drive Stats
```

Schema source:

- `analysis/g4_c3_backblaze_loss_only_schema_inspection_note.md`

## 1. Purpose

This draft defines a possible G4 non-CSP empirical anchor using Backblaze hard
drive reliability data.

The target claim is intentionally narrow:

```text
loss / degradation indicators in a repeated-unit industrial panel predict
future failure better than metadata-only or activity-only baselines.
```

This is a loss-only branch:

```text
g_t = 0
```

It does not test repair flow, compensation flow, preventive maintenance, or
operational \(M_r\). The G4 v2 repair-flow primary search remains paused.

## 2. Evidence Tier

This draft is below Exp43c in evidence strength.

| Anchor | Data generation | Primary strength |
|---|---|---|
| Exp43c q-coloring | Randomized generation from frozen rules | Route A primary validation |
| Backblaze loss-only | Existing observational industrial logs | G4 non-CSP observational support |

A passing Backblaze result may be reported as:

```text
observational support for the loss-only side of structural persistence in a
non-CSP industrial reliability panel.
```

It must not be reported as:

```text
repair-flow evidence;
G4 v2 repair / maintenance operational validation;
universal-law evidence equal in strength to Exp43c.
```

## 3. Dataset

Primary source:

- Backblaze Drive Stats data page:
  <https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data>

Schema files inspected:

```text
Drive_Stats_Schema_Current.csv
sha256: 365cf50ad5ebfc3e20d0959337d9877ce9539e0432955bda836b7482cd0f5358

Drive_Stats_Schema_2018_Onward.csv
sha256: 0ac0c6abcad39c22e590dd8a6ece897a8bb899e4618e67d5e78c0ced30282c37
```

The primary dataset archive and exact date range are not frozen in this draft.
They must be fixed before validation.

Recommended starting archive:

```text
data_Q4_2025.zip
HEAD check: Content-Length 1,157,851,346 bytes
```

If this archive is too large for the available environment, a smaller
pre-specified quarter may be chosen before freeze. The archive choice must be
made before inspecting predictor performance.

## 4. Unit, Time, And Endpoint

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

1. 30 days is long enough for operational prediction to be meaningful.
2. 30 days is short enough to avoid turning the task into a broad long-horizon
   survival study.
3. The value is fixed before outcome modeling.

Secondary horizons, if reported, must be labeled exploratory:

```text
H = 7 days
H = 90 days
```

They cannot replace the primary 30-day result.

## 5. Loss / Degradation Predictors

The primary theory-side predictor family uses lagged SMART degradation fields.

Allowed SMART fields:

```text
smart_5_raw      # reallocated sectors
smart_187_raw    # reported uncorrectable errors
smart_188_raw    # command timeout
smart_197_raw    # current pending sectors
smart_198_raw    # offline uncorrectable sectors
smart_199_raw    # UDMA CRC errors
```

If one or more of these fields is absent in the frozen archive, the field is
recorded as unavailable and omitted by the pre-specified missing-field rule.
No replacement SMART field may be chosen after inspecting performance.

Lag window:

```text
use values observed up to date t only
```

Primary feature transform:

```text
log1p(raw SMART value)
```

For each drive-day \(t\), the loss predictor vector is:

```text
L_obs(t) = [
  log1p(smart_5_raw),
  log1p(smart_187_raw),
  log1p(smart_188_raw),
  log1p(smart_197_raw),
  log1p(smart_198_raw),
  log1p(smart_199_raw)
]
```

No future SMART values may be used.

## 6. Baselines

The primary comparison is against metadata / exposure baselines.

Baseline B0: intercept only.

```text
failure_future ~ 1
```

Baseline B1: metadata only.

```text
failure_future ~ model + capacity_bytes + is_legacy_format
```

Baseline B2: location / fleet context.

```text
failure_future ~ model + capacity_bytes + datacenter + cluster_id + vault_id
                  + pod_id + pod_slot_num + is_legacy_format
```

Baseline B3: exposure proxy.

```text
failure_future ~ model + capacity_bytes + drive_age_days
```

`drive_age_days` is computed from the first observed date of the same
`serial_number` within the frozen archive. If the archive does not contain
enough history to define drive age cleanly, B3 is omitted and this omission is
reported.

Primary theory model:

```text
failure_future ~ metadata fields + L_obs(t)
```

Model class:

```text
L2-regularized logistic regression
```

The model class is fixed by this draft. The exact implementation package,
standardization rule, class-weight policy, and regularization value \(C\) must
be fixed in the freeze manifest before any validation run.

## 7. Primary Hypotheses

H1: Predictive improvement.

```text
logloss(metadata + L_obs) < 0.95 * min(logloss(B0), logloss(B1), logloss(B2), logloss(B3 available))
```

This requires at least a 5% log-loss improvement over the best eligible
non-SMART baseline, including the intercept-only baseline.

H2: Directional consistency.

For the SMART fields that have nonzero learned coefficients, the expected sign
is risk-increasing:

```text
coefficient >= 0
```

This is checked only for numeric SMART features after standardization. If a
field has zero variance in the training split, it is excluded by the
missing-field / no-variation rule.

A zero coefficient from regularization passes H2 as non-violating, not as
theory-supporting. H2 is a direction test, not a strength test.

H3: Time-split robustness.

The H1 direction must hold on the final held-out time block.

H4: No repair-flow claim.

Even if H1-H3 pass, the result is interpreted only as loss-only observational
support. It does not advance the paused G4 v2 repair-flow primary gate.

## 8. Split Discipline

Random row split is forbidden.

Primary split:

```text
train: earliest 70% of dates in the frozen archive
validation: next 15% of dates
test: latest 15% of dates
```

The final test block is used once.

All feature engineering rules, missing-field rules, model hyperparameters, and
evaluation code must be frozen before evaluating the test block.

Drive identity can appear in multiple splits over time because the task is a
temporal prediction task. However, no future observations for a drive may be
used to construct features at date \(t\).

## 9. Missingness And Eligibility

A frozen archive is eligible only if:

1. It contains `serial_number`, `date`, and `failure`.
2. It contains at least three of the six allowed SMART raw fields.
3. It contains at least one metadata baseline field among `model` and
   `capacity_bytes`.
4. The final held-out block contains both failure and non-failure labels.
5. The final held-out block contains at least \(N_f\) failure events, where
   \(N_f\) is fixed in the freeze manifest.

If condition 4 fails, the archive is not eligible for primary validation under
this draft. A different archive may be chosen only before freeze.

Recommended floor:

```text
N_f >= 200
```

The final \(N_f\) value must be fixed before inspecting model performance.

Missing SMART fields:

```text
omit the field; do not substitute post-hoc alternatives.
```

Missing metadata fields:

```text
omit the field from the relevant baseline; report the omission.
```

## 10. Metrics

Primary metric:

```text
held-out log loss on the final test block
```

Secondary metrics:

```text
AUC
Brier score
calibration curve summary
```

Secondary metrics cannot overturn the primary log-loss decision.

## 11. Decision Rules

Primary support:

```text
H1, H2, and H3 all pass.
```

Weak support:

```text
H1 passes but H2 fails or is mixed.
```

No support:

```text
H1 fails on the final test block.
```

Inconclusive:

```text
archive eligibility fails;
or final test block has only one class;
or too many required fields are absent.
```

No outcome permits a repair-flow claim.

## 12. Non-Claims

This preregistration does not claim:

1. Backblaze validates repair flow \(g_t\).
2. SMART degradation is the universal loss variable.
3. Drive failure prediction is causal.
4. This result identifies an optimal intervention policy.
5. A passing result is equal in strength to Exp43c.
6. A failing result falsifies the structural balance law.
7. Failure of one archive implies all Backblaze archives would fail.
8. The result transfers automatically to other industrial reliability systems.

## 13. Freeze Checklist

Before validation, freeze:

1. Exact archive URL and SHA256.
2. Exact date range.
3. Exact primary horizon \(H=30\) days.
4. Exact allowed SMART field list.
5. Exact metadata baseline fields.
6. Missing-field rule implementation.
7. Train / validation / test date boundaries.
8. L2-logistic implementation package, standardization rule, class-weight
   policy, and regularization value \(C\).
9. Evaluation script hash.
10. Primary metric and secondary metric code.
11. Minimum final-test failure count \(N_f\).
12. Claim wording.
13. Statement that repair-flow G4 v2 remains paused.

## 14. Current Status

This is a draft. It should not be run as validation until:

1. a specific Backblaze archive is downloaded and hashed;
2. a freeze manifest is committed;
3. evaluation code is committed;
4. the primary test block remains uninspected until after freeze.

The immediate next step, if continuing, is not model training. It is a small
archive feasibility check:

```text
download one preselected quarter;
verify required columns and date span;
do not compute model performance.
```
