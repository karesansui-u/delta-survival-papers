# G4 Scania Component X Horizon-Bridge Preregistration Draft

Status: draft preregistration for a public stochastic reliability bridge.
Not frozen. Not validation evidence. Not repair-flow evidence.

Date opened: 2026-04-27

Upstream notes:

- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`
- `analysis/g4_scania_component_x_freeze_design_note.md`
- `analysis/g4_scania_component_x_bridge_package_draft.md`

## 1. Purpose

This draft defines the first Scania public branch as:

```text
public non-CSP stochastic reliability bridge on a large industrial fleet
dataset
```

The target claim is intentionally narrow:

```text
on the fixed public Scania Component X v3 release, a preregistered compressed
degradation-side coordinate should beat simple time/specification baselines on
held-out horizon labels and remain reasonably competitive with a wide raw
readout baseline
```

This branch does not test direct repair-flow support. It does not claim a
direct logged `r_t`.

## 2. Evidence Tier

If this branch later passes, it may be reported only as:

```text
public stochastic reliability bridge support on a version-fixed industrial
fleet dataset
```

It must not be reported as:

```text
repair-flow evidence;
direct empirical r_t support;
evidence stronger than Route A randomized primaries;
universal-law closure.
```

## 3. Fixed Public Identity

Dataset family:

```text
Scania Component X
Version 3
DOI: 10.5878/bnh5-ka77
```

Exact archive identity is already fixed in:

- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`

This draft assumes those exact files and hashes.

## 4. Unit, Time, And Held-Out Endpoint

Unit:

```text
vehicle_id
```

Time:

```text
time_step
```

Held-out endpoint:

```text
five-class horizon label on the last selected readout of each validation/test
vehicle
```

Fixed held-out grammar:

| class | meaning |
|---|---|
| `0` | more than `48` time steps before failure / repair |
| `1` | `48` to `24` |
| `2` | `24` to `12` |
| `3` | `12` to `6` |
| `4` | `6` to `0` |

This grammar is taken as fixed and ordered.

## 5. Training-Label Construction

Training labels are derived from `train_tte.csv` because the training readout
surface does not expose `class_label` directly.

For each training readout row:

```text
delta = length_of_study_time_step - time_step
```

Label rule:

1. if `in_study_repair = 1`, map `delta` into the same five class windows as
   the held-out sets;
2. if `in_study_repair = 0`, assign class `0` within the observed study
   horizon.

Important design note:

```text
This is the censored-as-class-0 rule.
```

It is a deliberate operational assumption for the first public bridge package.
It does not claim that censoring and true ">48" risk are identical in a general
survival-theoretic sense. It claims only that this is the fixed classification
surface for the present public branch.

Additional execution assumption:

```text
rows with in_study_repair = 1 are assumed to satisfy delta >= 0
```

The execution package should assert this rather than silently remap negative
values into the terminal class.

## 6. Observation Surface

Training surface:

```text
all training readout rows after deterministic label construction
```

Validation / test surface:

```text
one labeled last-readout row per vehicle from the official published files
```

This asymmetry is accepted because it is the public challenge structure itself.

Training rows are used exactly at row level after deterministic label
construction.

For this first public branch:

```text
no vehicle-balanced resampling;
no per-vehicle reweighting;
no downsampling.
```

## 7. Predictors

### 7.1 Static and exposure predictors

- `time_step`
- specification columns from `*_specifications.csv`

Specifications are treated as categorical and one-hot encoded using training
categories only.

### 7.2 Wide raw readout family

All operational readout columns except `vehicle_id` and `time_step` are treated
as numeric readout features.

### 7.3 Compressed structural family

Primary compressed coordinate:

```text
D_pc1
```

Construction:

1. standardize all readout features on training rows only;
2. fit one-component PCA on the standardized training readout matrix only;
3. compute `PC1` on train / validation / test using the frozen training
   transform only;
4. orient the score so that Pearson correlation with `time_step` on the
   training rows is nonnegative.

This is the preregistered low-dimensional degradation-side coordinate for the
first Scania public branch.

## 8. Baselines And Primary Model

`B0`: empirical training class-prior baseline.

`B1`: `time_step` only.

`B2`: `time_step + specifications`.

`B3`: wide raw readout baseline:

```text
time_step + specifications + all raw operational readout features
```

Primary model:

```text
time_step + specifications + D_pc1
```

## 9. Model Class

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

Frozen numeric preprocessing for these models:

```text
standardize numeric predictor columns using training-row mean and population
standard deviation only;
leave one-hot specification indicators as 0/1 columns;
do not apply vehicle-level balancing or sample weighting.
```

Why `class_weight = None`:

```text
the primary metric is multiclass log loss, so the first public branch prefers
native probability calibration over reweighting the loss surface
```

Minority sensitivity may still be visible in secondary metrics.

## 10. Split Roles

Train:

```text
fit only
```

Validation:

```text
pre-specified guardrail / calibration-diagnostic split only
```

Test:

```text
one-time held-out primary evaluation split
```

Critical restriction:

```text
no model family, feature family, hyperparameter, or censoring rule may be
changed after viewing validation or test metrics
```

## 11. Metrics

Primary metric:

```text
multiclass log loss on the held-out test labels
```

Secondary metrics:

- macro-F1
- balanced accuracy
- plain accuracy

Optional diagnostics only:

- ordered-distance cost
- confusion matrix

## 12. Decision Rules

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
No result permits a direct repair-flow or direct r_t claim.
```

## 13. Non-Claims

This draft does not claim:

1. the censored-as-class-0 rule is survival-theoretically unique;
2. `in_study_repair` is a direct pre-cutoff intervention flow;
3. the survival / TTE path is discarded;
4. a passing result would close the repair-flow gap;
5. a public bridge package is stronger than partner/local directly logged
   maintenance data.

## 14. Bottom Line

```text
The first Scania public bridge package should be frozen as a horizon-
classification bridge with censored-as-class-0 training labels, a compressed
D_pc1 primary coordinate, multiclass log loss primary evaluation, and a strong
wide-readout baseline.
```
