# G4 Backblaze Q4 2025 Archive Feasibility Note

Status: archive feasibility check only. Not frozen. Not validation evidence.
No model performance inspected.

Date: 2026-04-23

Prereg draft:

- `analysis/g4_backblaze_loss_only_preregistration_draft.md`

Archive:

```text
data_Q4_2025.zip
URL: https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2025.zip
Content-Length (HEAD): 1,157,851,346 bytes
sha256: 57d0667cc03f23f16ded693e1e83e1ed28b7ea42d54b88d221734f5926030cb5
```

Boundary:

This check only verifies physical feasibility, columns, date span, and endpoint
eligibility. It does not compute model performance, SMART predictive power,
failure rates by predictor, survival curves, or any model comparison.

## 1. Archive Structure

Zip contents:

```text
92 CSV files
data_Q4_2025/2025-10-01.csv
...
data_Q4_2025/2025-12-31.csv
```

Observed uncompressed row count:

```text
30,941,708 drive-day rows
```

Observed date range:

```text
2025-10-01 through 2025-12-31
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

Primary horizon in the draft:

```text
H = 30 days
```

A direct 70/15/15 split over all archive dates would put the latest test dates
near the end of the archive, where \(t+H\) extends beyond `2025-12-31`. That
would right-censor the future-failure endpoint.

Therefore the preregistration draft should use eligible prediction dates:

```text
eligible date t iff t + H <= max_archive_date
```

For this archive:

```text
eligible prediction dates: 2025-10-01 through 2025-12-01
number of eligible dates: 62
```

Applying 70/15/15 to eligible dates gives:

```text
train dates:      43
validation dates:  9
test dates:       10
test date range: 2025-11-22 through 2025-12-01
```

The future endpoint horizon covered by those test dates is:

```text
2025-11-23 through 2025-12-31
```

This lies fully inside the archive.

## 4. Minimum Label Feasibility

Raw failure-event counts were checked only to verify eligibility. No predictor
relationship was inspected.

Observed raw failure rows:

```text
total raw failure rows in archive: 945
raw failure rows on test dates: 100
raw failure rows in test endpoint horizon: 237
```

The preregistration draft recommends:

```text
N_f >= 200
```

This archive appears feasible under that recommendation because the test
endpoint horizon contains 237 raw failure rows. Final \(N_f\) must still be
fixed in the freeze manifest.

## 5. Feasibility Verdict

```text
physically feasible: yes
required columns: yes
allowed SMART fields: yes
metadata baselines: yes
H=30 endpoint support: yes, if split is applied to eligible prediction dates
minimum raw endpoint failures: yes, 237 >= 200
```

Q4 2025 is feasible for a Backblaze loss-only freeze package if the draft is
updated to split over eligible prediction dates rather than all archive dates.

## 6. Next Action

Before validation:

1. Update the draft split discipline to use eligible prediction dates.
2. Write a freeze manifest fixing:
   - archive URL and SHA;
   - eligible date range;
   - train / validation / test date boundaries;
   - \(N_f\);
   - model package, standardization, class weighting, and \(C\);
   - evaluation script hash.
3. Do not inspect model performance before the freeze commit.
