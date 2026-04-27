# G4 Scania Component X Horizon-Bridge Freeze Manifest Draft

Status: frozen freeze manifest. Not validation evidence by itself. The held-out
Scania test surface may now be evaluated once with the frozen script and
command below.

Date opened: 2026-04-27

Preregistration draft:

- `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md`

Supporting notes:

- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`
- `analysis/g4_scania_component_x_freeze_design_note.md`
- `analysis/g4_scania_component_x_bridge_package_draft.md`

## 1. Public Identity

Frozen dataset family for this draft:

```text
Scania Component X
Version 3
DOI: 10.5878/bnh5-ka77
```

## 2. Required Files

The frozen package must use exactly these public files:

- `train_operational_readouts.csv`
- `train_tte.csv`
- `train_specifications.csv`
- `validation_operational_readouts.csv`
- `validation_labels.csv`
- `validation_specifications.csv`
- `test_operational_readouts.csv`
- `test_labels.csv`
- `test_specifications.csv`

## 3. Exact Large-Readout Identity

Exact readout files already fixed:

| file | bytes | sha256 | data rows | unique vehicles | columns |
|---|---:|---|---:|---:|---:|
| `train_operational_readouts.csv` | `1219209878` | `e01cb0bd87dfab4c9dbad215d51d81282fc0d413be96d6f819ea872fb7a3c715` | `1122452` | `23550` | `107` |
| `validation_operational_readouts.csv` | `215593159` | `1e1597eec866588c2ad95eb923555ad719c64b3697d9140f9cec6809349809af` | `196227` | `5046` | `107` |
| `test_operational_readouts.csv` | `214897259` | `81f2709cd339e0ff561f5fd3188d7f431680e32400bd788814880d7759615ba1` | `198140` | `5045` | `107` |

## 4. Smaller Supervision / Specification Identity

| file | bytes | sha256 | rows |
|---|---:|---|---:|
| `train_tte.csv` | `345412` | `d8c2379ed7c95a575dd869730b2b3b96d660317f49e57de300518ff3b08d53a5` | `23550` |
| `validation_labels.csv` | `38742` | `ad876c95c3696f4cfca2d76212ad6bb3cac6b2d2950a4aeaf218ee8b1548d08c` | `5046` |
| `test_labels.csv` | `38682` | `60f923051d4ba1bef4c81166cf9e8ca01daf3b7a29c73016c6f48a23dcfa0223` | `5045` |
| `train_specifications.csv` | `1081118` | `47cc9a67aee19d5e2ee8620fe8e467490b2125bacc7787ce781ce9f3c1f0c38f` | `23550` |
| `validation_specifications.csv` | `231765` | `a31e832846538dd7a1829108b69420d9377dcd05d6446d8ac1270a974fc58ae2` | `5046` |
| `test_specifications.csv` | `231658` | `40ac8a111f6d5b416107ec1786f639766ecf1293a1c9c0c0dbf24f14c1c5d0e7` | `5045` |

## 5. Unit, Time, And Held-Out Grammar

Unit:

```text
vehicle_id
```

Time:

```text
time_step
```

Frozen held-out class grammar:

- `0` = more than `48` time steps before failure / repair
- `1` = `48` to `24`
- `2` = `24` to `12`
- `3` = `12` to `6`
- `4` = `6` to `0`

## 6. Training-Label Rule

For each training readout row:

```text
delta = length_of_study_time_step - time_step
```

Frozen label rule:

1. if `in_study_repair = 1`, assign the corresponding class window using
   `delta`;
2. if `in_study_repair = 0`, assign class `0`.

Frozen wording for this rule:

```text
censored-as-class-0 within observed study horizon
```

This rule may not be changed after freeze.

Frozen execution assumption:

```text
rows with in_study_repair = 1 must satisfy delta >= 0
```

The frozen script should assert this condition rather than silently coercing
negative deltas into class `4`.

Training rows are used exactly at row level after deterministic label
construction.

Frozen anti-flexibility rule:

```text
no vehicle-balanced resampling;
no per-vehicle weighting;
no downsampling.
```

## 7. Feature Families

Static / exposure:

- `time_step`
- one-hot encoded specification fields

Wide baseline raw family:

- all operational readout columns except `vehicle_id` and `time_step`

Primary compressed family:

- one-component PCA score `D_pc1` derived from all raw readout columns

## 8. D_pc1 Construction

1. standardize raw readout columns using training rows only;
2. fit one-component PCA on the standardized training readout matrix only;
3. compute `D_pc1` on train / validation / test with the frozen training
   transform only;
4. if Pearson correlation of `D_pc1` with `time_step` on the training rows is
   negative, multiply all scores by `-1`.

This orientation rule is frozen.

## 9. Baselines And Primary Model

`B0`: empirical class prior

`B1`: `time_step`

`B2`: `time_step + specifications`

`B3`: `time_step + specifications + all raw readout features`

Primary:

`time_step + specifications + D_pc1`

## 10. Model Class

For `B1`, `B2`, `B3`, and the primary model:

```text
sklearn LogisticRegression
multi_class = "multinomial"
penalty = "l2"
solver = "lbfgs"
C = 1.0
max_iter = 2000
class_weight = None
random_state = 43001
```

Specification handling:

```text
one-hot encode training categories only
handle_unknown = "ignore"
```

Frozen numeric preprocessing:

```text
standardize numeric predictor columns using training-row mean and population
standard deviation only;
leave one-hot specification indicators as 0/1 columns;
apply no vehicle-level balancing or sample weighting.
```

## 11. Split Roles

Train:

```text
fit only
```

Validation:

```text
guardrail / calibration-diagnostic split only
```

Test:

```text
one-time primary evaluation split
```

No feature, model, hyperparameter, or censoring-rule changes are permitted
after viewing validation or test metrics.

## 12. Metrics

Primary metric:

```text
multiclass log loss on held-out test labels
```

Secondary metrics:

- macro-F1
- balanced accuracy
- plain accuracy

## 13. Decision Rules

H1:

```text
logloss(primary) <= 0.95 * min(logloss(B1), logloss(B2))
```

H2:

```text
logloss(primary) <= 1.10 * logloss(B3)
```

H3:

```text
No result permits a direct repair-flow or direct g_t claim.
```

## 14. Execution Script Slot

Planned script path:

```text
analysis/g4_scania_component_x_horizon_bridge/scripts/evaluate_scania_component_x_horizon_bridge.py
```

Final script SHA256:

```text
0b0d304f93f15be5c70fe6ff7d6aa37fa80dea67cbe0c91187dbbda48206500c
```

## 15. Local Data Path Slot

Frozen local staging root:

```text
analysis/g4_scania_component_x_horizon_bridge/data/
```

Frozen local file paths used for the primary run:

- `analysis/g4_scania_component_x_horizon_bridge/data/train_operational_readouts.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/train_tte.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/train_specifications.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/validation_operational_readouts.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/validation_labels.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/validation_specifications.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/test_operational_readouts.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/test_labels.csv`
- `analysis/g4_scania_component_x_horizon_bridge/data/test_specifications.csv`

The three `*_operational_readouts.csv` files are package-local symlinks to the
already exact-acquired files under:

```text
/tmp/scania_component_x_v3_exact
```

## 16. Frozen Primary Command

```bash
python3 analysis/g4_scania_component_x_horizon_bridge/scripts/evaluate_scania_component_x_horizon_bridge.py \
  --data-dir analysis/g4_scania_component_x_horizon_bridge/data \
  --output analysis/g4_scania_component_x_horizon_bridge/data/primary_result.json \
  --allow-primary-run
```
