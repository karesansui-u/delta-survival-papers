# Backblaze Loss-Only Freeze Manifest

Status: frozen freeze manifest. Primary validation may be run once using the
script hash recorded below. Do not change the script, archive, split,
predictors, model, or decision rules before the primary run.

Date opened: 2026-04-23
Date frozen: 2026-04-23

Preregistration draft:

- `analysis/g4_backblaze_loss_only_preregistration_draft.md`

Feasibility note:

- `analysis/g4_backblaze_q4_2025_archive_feasibility_note.md`

## 1. Archive

Archive URL:

```text
https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2025.zip
```

Archive SHA256:

```text
57d0667cc03f23f16ded693e1e83e1ed28b7ea42d54b88d221734f5926030cb5
```

Archive date range:

```text
2025-10-01 through 2025-12-31
```

## 2. Prediction Horizon

Primary horizon:

```text
H = 30 days
```

Eligible prediction dates:

```text
2025-10-01 through 2025-12-01
```

This date range is defined by:

```text
t + H <= 2025-12-31
```

## 3. Split

Split is by eligible prediction dates, not by all archive dates.

```text
train:      2025-10-01 through 2025-11-12  (43 dates)
validation: 2025-11-13 through 2025-11-21  (9 dates)
test:       2025-11-22 through 2025-12-01  (10 dates)
```

The final test endpoint horizon is:

```text
2025-11-23 through 2025-12-31
```

The feasibility note observed 237 raw failure rows in this endpoint horizon.

## 4. Predictors

Allowed SMART loss fields:

```text
smart_5_raw
smart_187_raw
smart_188_raw
smart_197_raw
smart_198_raw
smart_199_raw
```

Transform:

```text
log1p(raw value)
```

No replacement SMART fields may be added after this manifest is frozen.

## 5. Baselines

B0:

```text
intercept only
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

`drive_age_days` is computed from first observed date of the same
`serial_number` within the frozen archive.

## 6. Model

Model class:

```text
streaming L2-regularized logistic regression
```

Implementation:

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
class weights are computed from the training prediction rows:
w_c = n_train / (2 * n_c)
```

Standardization:

```text
numeric predictors standardized using train split mean and standard deviation;
categorical predictors one-hot encoded using train split categories;
unknown validation/test categories ignored.
```

Categorical encoder:

```text
manual sparse one-hot encoding using categories observed in the training
prediction rows; unknown validation/test categories ignored.
```

Random seed:

```text
43001
```

## 7. Metrics

Primary metric:

```text
held-out log loss on final test block
```

Secondary metrics:

```text
AUC
Brier score
calibration curve summary
```

Secondary metrics cannot overturn the primary log-loss decision.

## 8. Minimum Final-Test Failure Count

Frozen value:

```text
N_f = 200
```

Feasibility check:

```text
raw failures in final test endpoint horizon: 237
```

## 9. Evaluation Script

Script:

```text
analysis/backblaze_loss_only/scripts/evaluate_backblaze_loss_only.py
```

Script SHA256:

```text
af3f5c44b55fb97869e421a26f492b7dc1837a1f7c4e3e7025e77801ef2c9945
```

Before this freeze, the script was allowed to run only in metadata-only mode or
validation-smoke mode:

```text
--metadata-only       inspect structural archive metadata only
--validation-smoke    fit on train dates and evaluate validation dates only
```

Validation-smoke output is an integration check, not validation evidence. The
final test prediction dates have not been evaluated at the time of this freeze.

Primary validation command:

```bash
python3 analysis/backblaze_loss_only/scripts/evaluate_backblaze_loss_only.py \
  --archive /tmp/backblaze_feasibility/data_Q4_2025.zip \
  --output analysis/backblaze_loss_only/data/backblaze_q4_2025_primary_result.json \
  --allow-primary-run
```

## 10. Claim Wording

Allowed if primary support passes:

```text
Backblaze provides observational support for the loss-only side of structural
persistence in a non-CSP industrial reliability panel.
```

Forbidden:

```text
Backblaze validates repair flow g_t.
Backblaze completes G4 v2 repair / maintenance operational validation.
Backblaze evidence is equal in strength to Exp43c.
```

## 11. Current Status

This manifest is frozen. The primary run has not yet been executed.

Next step:

```text
run primary validation once, then write the primary report without changing
this manifest or the evaluation script.
```
