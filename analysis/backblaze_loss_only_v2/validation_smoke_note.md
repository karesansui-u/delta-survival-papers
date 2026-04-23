# Backblaze Loss-Only v2 Validation-Smoke Note

Status: pre-freeze integration check. Not validation evidence. Not a primary
result. The final test prediction dates were not evaluated.

Date: 2026-04-24

Script:

```text
analysis/backblaze_loss_only_v2/scripts/evaluate_backblaze_loss_only_v2.py
```

Archive:

```text
/tmp/backblaze_feasibility/data_Q3_2025.zip
```

Command:

```bash
python3 analysis/backblaze_loss_only_v2/scripts/evaluate_backblaze_loss_only_v2.py \
  --archive /tmp/backblaze_feasibility/data_Q3_2025.zip \
  --output /tmp/backblaze_q3_v2_validation_smoke_full.json \
  --validation-smoke
```

Checked output fields only:

```text
evaluation_mode: validation_smoke
train prediction dates: 2025-07-01 through 2025-08-12 (43 dates)
calibration prediction dates: 2025-08-13 through 2025-08-21 (9 dates)
evaluation prediction dates: 2025-08-13 through 2025-08-21 (9 dates)
```

Rows processed:

| quantity | rows |
|---|---:|
| train prediction rows | 13,872,636 |
| train positive rows | 16,428 |
| validation prediction rows | 2,915,604 |
| validation positive rows | 3,361 |

No log-loss values, AUC values, Brier values, calibration slopes, or
model-comparison outcomes from this validation-smoke output are recorded here
or used as evidence. The purpose of this check was only to confirm that the
streaming stage-1 + validation-only Platt stage-2 path can process the frozen
Q3 archive format before the final script hash is frozen.

Result:

```text
full-scale validation-smoke completed
```

Next step:

```text
insert the final script SHA into the freeze manifest, freeze the Q3 v2 package,
then run the primary test-block validation once.
```
