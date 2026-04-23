# Backblaze Loss-Only Validation-Smoke Note

Status: pre-freeze integration check. Not validation evidence. Not a primary
result. The final test prediction dates were not evaluated.

Date: 2026-04-23

Script:

```text
analysis/backblaze_loss_only/scripts/evaluate_backblaze_loss_only.py
```

Archive:

```text
/tmp/backblaze_feasibility/data_Q4_2025.zip
```

Command:

```bash
python3 analysis/backblaze_loss_only/scripts/evaluate_backblaze_loss_only.py \
  --archive /tmp/backblaze_feasibility/data_Q4_2025.zip \
  --output /tmp/backblaze_real_validation_smoke_full.json \
  --validation-smoke
```

Checked output fields only:

```text
evaluation_mode: validation_smoke
train prediction dates: 2025-10-01 through 2025-11-12 (43 dates)
evaluation prediction dates: 2025-11-13 through 2025-11-21 (9 dates)
```

Rows processed:

| model | train rows | validation rows |
|---|---:|---:|
| B0_intercept | 14,387,368 | 3,030,067 |
| B1_metadata | 14,387,368 | 3,030,067 |
| B2_fleet_context | 14,387,368 | 3,030,067 |
| B3_exposure | 14,387,368 | 3,030,067 |
| primary_metadata_plus_smart | 14,387,368 | 3,030,067 |

No score values, coefficients, AUC values, or model-comparison outcomes from
this validation-smoke output are recorded here or used as evidence. The purpose
of this check was only to confirm that the streaming implementation can process
the frozen archive format at full train/validation scale before the final
script hash is frozen.

Result:

```text
full-scale validation-smoke completed
```

Next step:

```text
insert the final script SHA into the freeze manifest, commit the freeze package,
then run the primary test-block validation once.
```
