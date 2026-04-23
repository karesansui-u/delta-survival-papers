# Backblaze Loss-Only Freeze Manifest Draft

Status: draft freeze manifest. Not frozen until committed with final script
hash. Do not run primary validation until this file is promoted from draft.

Date opened: 2026-04-23

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
L2-regularized logistic regression
```

Implementation:

```text
scikit-learn LogisticRegression
solver = "lbfgs"
max_iter = 1000
```

Regularization:

```text
C = 1.0
```

Class weighting:

```text
class_weight = "balanced"
```

Standardization:

```text
numeric predictors standardized using train split mean and standard deviation;
categorical predictors one-hot encoded using train split categories;
unknown validation/test categories ignored.
```

Categorical encoder:

```text
scikit-learn OneHotEncoder(handle_unknown="ignore", sparse_output=False)
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
TO_BE_FILLED_AFTER_FINAL_EDIT
```

Primary validation must not run until this hash is filled and committed.

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

This manifest is not frozen yet because the script hash is not filled.

Next step:

```text
finalize evaluation script hash, commit this manifest as frozen, then and only
then run primary validation.
```
