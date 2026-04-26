# G4 C-MAPSS FD001 Loss-Only Freeze Manifest Draft

Status: frozen freeze manifest. Not validation evidence by itself. The held-out
FD001 test units may now be evaluated once with the frozen script and command
below.

Date opened: 2026-04-27

Preregistration draft:

- `analysis/g4_cmapss_fd001_loss_only_preregistration_draft.md`

Supporting notes:

- `analysis/g4_cmapss_loss_only_feasibility_note.md`
- `analysis/g4_cmapss_fd001_archive_note.md`
- `analysis/g4_cmapss_fd001_archive_feasibility_note.md`

## 1. Archive

Archive family:

```text
CMAPSSData.zip
```

Frozen archive SHA256:

```text
74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f
```

Frozen local archive path used for the primary run:

```text
analysis/g4_cmapss_fd001_loss_only/data/CMAPSSData.zip
```

Frozen subset:

```text
FD001
```

Required files inside the archive:

```text
train_FD001.txt
test_FD001.txt
RUL_FD001.txt
```

Structural counts already verified in the feasibility note:

| file | rows | units |
|---|---:|---:|
| `train_FD001.txt` | `20631` | `100` |
| `test_FD001.txt` | `13096` | `100` |
| `RUL_FD001.txt` | `100` | `100` targets |

## 2. Unit, Time, And Event Definition

Unit:

```text
engine id
```

Time:

```text
cycle
```

Primary endpoint:

```text
near-failure event with H = 50 cycles
```

Training labels:

```text
RUL_train = final_cycle_within_train_unit - cycle
Y_train = 1[RUL_train <= 50]
```

Test labels:

```text
use the final observed row of each test unit and
Y_test = 1[RUL_FD001 <= 50]
```

Observed held-out class balance under this rule:

```text
33 positive units / 67 negative units
```

## 3. Column Mapping

The parser must treat FD001 rows as:

- column 1: `unit_id`
- column 2: `cycle`
- columns 3-5: `setting_1`, `setting_2`, `setting_3`
- columns 6-26: `sensor_1` through `sensor_21`

No alternate parser or delimiter rule may be introduced after freeze.

## 4. Eligible Sensor Set

The following FD001 sensor channels are frozen as the nonconstant set:

```text
sensor_2, sensor_3, sensor_4, sensor_6, sensor_7, sensor_8, sensor_9,
sensor_11, sensor_12, sensor_13, sensor_14, sensor_15, sensor_17,
sensor_20, sensor_21
```

The following channels are frozen as excluded constants on FD001:

```text
sensor_1, sensor_5, sensor_10, sensor_16, sensor_18, sensor_19
```

No additional feature search is allowed after freeze.

## 5. Baselines And Primary Model

B0:

```text
constant training prevalence
```

B1:

```text
event_50 ~ cycle
```

B2:

```text
event_50 ~ setting_1 + setting_2 + setting_3
```

B3:

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3
```

B4:

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3 + 15 nonconstant sensors
```

Primary:

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3 + D_pc1
```

## 6. Low-Dimensional Coordinate Definition

Frozen degradation coordinate:

```text
D_pc1
```

Construction:

1. standardize the 15 nonconstant sensors using training-row mean and standard
   deviation only;
2. fit one-component PCA on the standardized training rows only;
3. compute the first principal-component score on train and test rows;
4. orient the score so that Pearson correlation with `cycle` on training rows
   is nonnegative.

Orientation rule:

```text
if corr(PC1, cycle) < 0 on training rows, multiply all PC1 scores by -1
```

This orientation rule must not be changed after freeze.

## 7. Model Class

For B1-B4 and Primary:

```text
sklearn LogisticRegression
penalty = "l2"
solver = "lbfgs"
C = 1.0
max_iter = 1000
class_weight = None
random_state = 43001
```

Standardization:

```text
fit on training rows only; apply the same transform to test rows
```

No calibration layer is included in this first FD001 branch.

## 8. Metrics

Primary metric:

```text
held-out log loss on the final test-unit rows
```

Secondary metrics:

- Brier score
- AUROC
- accuracy at 0.5

## 9. Hypothesis Decisions

H1:

```text
logloss(primary) <= 0.95 * min(logloss(B1), logloss(B2), logloss(B3))
```

H2:

```text
logloss(primary) <= 1.10 * logloss(B4)
```

H3:

```text
beta_Dpc1 >= 0
```

H4:

```text
No result permits any repair-flow claim.
```

## 10. Execution Script And Output Paths

Current execution script path:

```text
analysis/g4_cmapss_fd001_loss_only/scripts/evaluate_cmapss_fd001_loss_only.py
```

The later execution script must write to separate outputs under:

```text
analysis/g4_cmapss_fd001_loss_only/data/
```

Expected artifact names:

```text
cmapss_fd001_primary_results.json
cmapss_fd001_primary_report.md
```

Frozen execution script SHA256:

```text
25980fc025409a4d74fdc63247cc44e2f98fe44957830fa7e378eae14dd86cb1
```

Frozen primary command:

```bash
python3 analysis/g4_cmapss_fd001_loss_only/scripts/evaluate_cmapss_fd001_loss_only.py \
  --archive analysis/g4_cmapss_fd001_loss_only/data/CMAPSSData.zip \
  --output analysis/g4_cmapss_fd001_loss_only/data/cmapss_fd001_primary_results.json \
  --report-output analysis/g4_cmapss_fd001_loss_only/primary_report.md \
  --allow-primary-run
```

Frozen output schema:

```text
JSON machine-readable output at
analysis/g4_cmapss_fd001_loss_only/data/cmapss_fd001_primary_results.json

Markdown reader-facing report at
analysis/g4_cmapss_fd001_loss_only/primary_report.md
```

## 11. Remaining Freeze Items

No remaining freeze items.

## 12. Current Status

This manifest is now frozen. The current state is:

```text
archive fixed
subset fixed
event definition fixed
feature family fixed
PCA orientation rule fixed
model class fixed
metrics fixed
script path fixed
script hash fixed
primary command fixed
```

The no-peek parser / train-smoke step is now complete in:

```text
analysis/g4_cmapss_fd001_loss_only/train_smoke_note.md
```

That smoke step is now strictly train-only:

```text
metadata-only may inspect archive identity and structural held-out class
balance, but train-smoke does not load held-out test predictors or labels
```

The no-peek condition before freeze was:

```text
metadata-only was allowed to inspect archive identity and structural held-out
class balance;
train-smoke was strictly train-only and did not load held-out test predictors
or labels.
```

The next clean move is the single held-out primary run using the frozen command
above.
