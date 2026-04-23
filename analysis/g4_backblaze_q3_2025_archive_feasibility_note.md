# G4 Backblaze Q3 2025 Archive Feasibility Note

Status: archive feasibility check only. Not frozen. Not validation evidence.
No model performance inspected.

Date: 2026-04-24

Upstream ranking / design notes:

- `analysis/backblaze_loss_only_v2_exploration_note.md`
- `analysis/backblaze_loss_only_v2_archive_ranking_note.md`

Archive:

```text
data_Q3_2025.zip
URL: https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2025.zip
Content-Length (HEAD): 1,111,587,745 bytes
sha256: 0c8962e8efef6eba5ebe6f17f561265fef07df68c88fe3c65d4225159c54528c
```

Boundary:

This check only verifies physical feasibility, columns, date span, and
endpoint eligibility for a possible Backblaze v2 retry. It does not compute
model performance, SMART predictive power, survival curves, calibration, or
any model comparison.

## 1. Archive Structure

Zip contents:

```text
92 CSV files
data_Q3_2025/2025-07-01.csv
...
data_Q3_2025/2025-09-30.csv
```

Observed uncompressed row count:

```text
29,844,451 drive-day rows
```

Observed date range:

```text
2025-07-01 through 2025-09-30
```

## 2. Required Columns

The first daily CSV contains 197 columns.

Required fields:

| Field | Present |
|---|---|
| `date` | yes |
| `serial_number` | yes |
| `model` | yes |
| `capacity_bytes` | yes |
| `failure` | yes |

Allowed SMART raw fields:

| Field | Present |
|---|---|
| `smart_5_raw` | yes |
| `smart_187_raw` | yes |
| `smart_188_raw` | yes |
| `smart_197_raw` | yes |
| `smart_198_raw` | yes |
| `smart_199_raw` | yes |

Metadata / fleet context fields:

| Field | Present |
|---|---|
| `datacenter` | yes |
| `cluster_id` | yes |
| `vault_id` | yes |
| `pod_id` | yes |
| `pod_slot_num` | yes |
| `is_legacy_format` | yes |

## 3. Horizon Eligibility

Primary horizon carried forward from the Backblaze loss-only branch:

```text
H = 30 days
```

As in the Q4 2025 feasibility note, split boundaries must be defined on
eligible prediction dates:

```text
eligible date t iff t + H <= max_archive_date
```

For this archive:

```text
eligible prediction dates: 2025-07-01 through 2025-08-31
number of eligible dates: 62
```

Applying 70/15/15 to eligible dates gives:

```text
train dates:      43
validation dates:  9
test dates:       10
test date range: 2025-08-22 through 2025-08-31
```

The future endpoint horizon covered by those test dates is:

```text
2025-08-23 through 2025-09-30
```

This lies fully inside the archive.

## 4. Minimum Label Feasibility

Raw failure-event counts were checked only to verify endpoint feasibility. No
predictor relationship was inspected.

Observed raw failure rows:

```text
raw failure rows on test dates: 129
raw failure rows in test endpoint horizon: 571
```

The Backblaze loss-only branch used the recommendation:

```text
N_f >= 200
```

Q3 2025 appears feasible under that floor because the test endpoint horizon
contains 571 raw failure rows. Final \(N_f\) would still need to be fixed in a
new Backblaze v2 freeze manifest.

## 5. Feasibility Verdict

```text
physically feasible: yes
required columns: yes
allowed SMART fields: yes
metadata baselines: yes
H=30 endpoint support: yes, if split is applied to eligible prediction dates
minimum raw endpoint failures: yes, 571 >= 200
```

Therefore:

```text
Q3 2025 is a feasible fresh archive candidate for a Backblaze v2 retry at the
metadata-only level.
```

This is not a validation result. It only means the archive is eligible to
serve as the basis for a new preregistration / freeze package if the program
chooses to continue the same-domain Backblaze branch.

## 6. Next Action

If the same-domain Backblaze branch continues, the next clean step is:

1. write a Backblaze v2 preregistration on Q3 2025;
2. fix the calibration-aware design before any predictor-level inspection;
3. freeze the new archive, split, model path, and evaluation script;
4. run one new primary validation on Q3 2025 only after freeze.

No predictor-level or model-comparison inspection should occur before that new
freeze point.
