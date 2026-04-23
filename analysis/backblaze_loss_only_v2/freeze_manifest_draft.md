# Backblaze Loss-Only v2 Freeze Manifest Draft

Status: draft freeze manifest. Not frozen. Not validation evidence. The final
test block must remain untouched until the script hash below is filled and this
manifest is explicitly frozen.

Date opened: 2026-04-24

Preregistration draft:

- `analysis/backblaze_loss_only_v2_preregistration_draft.md`

Supporting notes:

- `analysis/backblaze_loss_only_v2_exploration_note.md`
- `analysis/backblaze_loss_only_v2_archive_ranking_note.md`
- `analysis/g4_backblaze_q3_2025_archive_feasibility_note.md`

## 1. Archive

Archive URL:

```text
https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2025.zip
```

Archive SHA256:

```text
0c8962e8efef6eba5ebe6f17f561265fef07df68c88fe3c65d4225159c54528c
```

Archive date range:

```text
2025-07-01 through 2025-09-30
```

## 2. Prediction Horizon

Primary horizon:

```text
H = 30 days
```

Eligible prediction dates:

```text
2025-07-01 through 2025-08-31
```

This range is defined by:

```text
t + H <= 2025-09-30
```

## 3. Split

Split is by eligible prediction dates, not by all archive dates.

```text
train:      2025-07-01 through 2025-08-12  (43 dates)
validation: 2025-08-13 through 2025-08-21  ( 9 dates)
test:       2025-08-22 through 2025-08-31  (10 dates)
```

The final test endpoint horizon is:

```text
2025-08-23 through 2025-09-30
```

The Q3 feasibility note observed 571 raw failure rows in this endpoint horizon.

## 4. Predictors

Primary theory-side SMART fields:

```text
smart_5_raw
smart_187_raw
smart_188_raw
smart_197_raw
smart_198_raw
```

Excluded from the primary theory-side loss vector:

```text
smart_199_raw
```

Transform:

```text
log1p(max(raw value, 0))
```

No replacement SMART field may be added after freeze.

## 5. Baselines

B0:

```text
constant training-prevalence baseline
```

Interpretation:

```text
predict a single probability equal to the empirical positive rate in the
training prediction rows
```

B1:

```text
model + capacity_bytes + is_legacy_format
```

B2:

```text
model + capacity_bytes + datacenter + cluster_id + vault_id
+ pod_id + pod_slot_num + is_legacy_format
```

B3:

```text
model + capacity_bytes + drive_age_days
```

`drive_age_days` is computed from the first observed date of the same
`serial_number` within the frozen Q3 2025 archive.

## 6. Stage-1 Model

Stage-1 model class:

```text
streaming L2-regularized logistic regression
```

Implementation family:

```text
scikit-learn SGDClassifier
loss = "log_loss"
penalty = "l2"
learning_rate = "optimal"
average = True
```

Regularization / optimizer:

```text
alpha = 1.0e-4
epochs = 1 chronological pass over the training prediction dates
```

Class weighting:

```text
for B1, B2, B3, and Primary only:
w_c = n_train / (2 * n_c)
```

B0 uses no class weighting because it is not fit as a weighted SGD model.

Standardization:

```text
numeric predictors standardized using train split mean and standard deviation
```

Categorical encoding:

```text
manual sparse one-hot encoding using categories observed in the training
prediction rows; unknown validation/test categories ignored
```

Stage-1 score passed to the calibrator:

```text
raw decision_function output
```

Random seed:

```text
43001
```

## 7. Stage-2 Calibration

Calibration family:

```text
Platt scaling
```

Implementation family:

```text
scikit-learn LogisticRegression
penalty = "l2"
solver = "lbfgs"
C = 1.0
fit_intercept = True
max_iter = 1000
```

Calibration input:

```text
one-dimensional stage-1 decision_function score on the validation split only
```

Calibration output:

```text
probability of future failure in (t, t + H]
```

Calibration scope:

```text
fit one separate calibrator for each of B1, B2, B3, and Primary
```

B0 remains the constant training-prevalence baseline and is not Platt-scaled.

## 8. Metrics

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

## 9. Minimum Final-Test Failure Count

Draft value:

```text
N_f = 200
```

Feasibility check:

```text
raw failures in final test endpoint horizon: 571
```

## 10. Evaluation Script

Planned script path:

```text
analysis/backblaze_loss_only_v2/scripts/evaluate_backblaze_loss_only_v2.py
```

Script SHA256:

```text
TO_BE_FILLED_AFTER_FINAL_EDIT
```

Allowed pre-freeze modes:

```text
--metadata-only       inspect structural archive metadata only
--validation-smoke    fit on train dates and evaluate validation dates only
```

Not allowed before freeze:

```text
final test-block evaluation
```

Planned primary validation command:

```bash
python3 analysis/backblaze_loss_only_v2/scripts/evaluate_backblaze_loss_only_v2.py \
  --archive /tmp/backblaze_feasibility/data_Q3_2025.zip \
  --output analysis/backblaze_loss_only_v2/data/backblaze_q3_2025_primary_result.json \
  --allow-primary-run
```

## 11. Claim Wording

Allowed if primary support passes:

```text
Backblaze Q3 2025 provides observational support for a calibration-aware
loss-only structural-persistence design in the Backblaze reliability domain.
```

Forbidden:

```text
Backblaze validates repair flow g_t.
Backblaze completes G4 v2 repair / maintenance operational validation.
Backblaze v2 erases the Q4 2025 no-support result.
Backblaze evidence is equal in strength to Exp43c.
```

## 12. Current Status

This manifest is not frozen yet because:

1. the v2 evaluation script has not been finalized and hashed;
2. no validation-smoke on the v2 script has been recorded yet;
3. the explicit frozen wording has not yet been switched from draft to frozen.

Next step:

```text
implement the v2 evaluation script to match this manifest draft,
run metadata-only / validation-smoke modes only,
then fill the final script SHA and freeze this manifest before touching the
Q3 test block
```
