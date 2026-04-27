# G4 C-MAPSS FD001 Loss-Only Preregistration Draft

Status: draft preregistration for a cross-domain non-CSP loss-only benchmark
anchor. Not frozen. Not validation evidence. Not repair-flow evidence.

Date opened: 2026-04-27

Upstream notes:

- `analysis/g4_cmapss_loss_only_feasibility_note.md`
- `analysis/g4_cmapss_fd001_archive_note.md`
- `analysis/g4_cmapss_fd001_archive_feasibility_note.md`

## 1. Purpose

This draft defines the first C-MAPSS branch as:

```text
cross-domain non-CSP loss-only support on a public degradation benchmark
```

The target claim is intentionally narrow:

```text
on the fixed FD001 subset, a preregistered low-dimensional degradation
coordinate predicts a near-failure event better than simple exposure/settings
baselines and remains competitive with a wider raw-sensor baseline
```

This branch stays strictly loss-only:

```text
r_t = 0
```

It does not test recovery amount, preventive maintenance, operational \(M_{\mathrm{recovery}}\), or
G4 v2 repair / maintenance validation.

## 2. Evidence Tier

This draft is weaker than Route A randomized primaries and weaker than a live
operational maintenance log. If it passes, it may be reported only as:

```text
cross-domain non-CSP loss-only support on a public simulated degradation
benchmark
```

It must not be reported as:

```text
repair-flow evidence;
live maintenance-log support;
evidence equal in strength to Exp43c or Mixed-CSP;
universal-law closure.
```

## 3. Fixed Archive And Subset

Archive family:

```text
CMAPSSData.zip
```

Exact archive used for later freeze:

```text
sha256: 74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f
```

Fixed first subset:

```text
FD001
```

Subset files:

- `train_FD001.txt`
- `test_FD001.txt`
- `RUL_FD001.txt`

Observed structural counts:

| file | rows | units |
|---|---:|---:|
| `train_FD001.txt` | `20631` | `100` |
| `test_FD001.txt` | `13096` | `100` |
| `RUL_FD001.txt` | `100` | `100` targets |

## 4. Unit, Time, And Endpoint

Unit:

```text
engine id
```

Time:

```text
cycle
```

Primary endpoint path in this draft:

```text
binary near-failure event: RUL <= H cycles
```

Primary horizon:

```text
H = 50 cycles
```

Why this path goes first:

1. it keeps the branch aligned with the binary probabilistic metrics already
   used in other loss-only anchors;
2. it avoids opening an MAE/RMSE-specific modeling branch before the first
   C-MAPSS anchor is even tested;
3. it fixes a clean event question before any predictor inspection:
   "is this unit within 50 cycles of failure?"

Observed official test-block prevalence under this rule:

```text
33 positive units / 67 negative units
```

That count was used only to verify endpoint feasibility, not to inspect any
predictor performance.

## 5. Label Construction

Training labels:

For each row in `train_FD001.txt`, define:

\[
\text{RUL}_{u,t} = C_u^{\max} - t
\]

where \(C_u^{\max}\) is the final observed cycle for training unit \(u\).

Then set:

\[
Y_{u,t}^{(50)} = 1[\text{RUL}_{u,t} \le 50]
\]

Test labels:

For each official test unit \(u\), use the final observed row in
`test_FD001.txt` together with the provided `RUL_FD001.txt` value:

\[
Y_u^{(50)} = 1[\text{RUL}_u \le 50]
\]

This draft does not introduce any alternative horizon or threshold after
opening.

## 6. Predictors

### 6.1 Raw column families

FD001 row structure is treated as:

- column 1: unit id
- column 2: cycle
- columns 3-5: operating settings
- columns 6-26: sensor channels

The following sensor channels are structurally nonconstant in the exact
training subset and therefore eligible for modeling:

```text
sensor_2, sensor_3, sensor_4, sensor_6, sensor_7, sensor_8, sensor_9,
sensor_11, sensor_12, sensor_13, sensor_14, sensor_15, sensor_17,
sensor_20, sensor_21
```

The remaining six sensor channels are constant on FD001 and are excluded from
all models.

### 6.2 Low-dimensional degradation coordinate

The primary low-dimensional degradation coordinate is defined by:

1. standardize the 15 nonconstant sensor channels on training rows only;
2. fit one-component PCA on those standardized training rows only;
3. compute the first principal-component score for each row;
4. orient the score so that its Pearson correlation with `cycle` on the
   training rows is nonnegative.

Call the oriented score:

\[
D_{\mathrm{pc1}}(u,t)
\]

This is a preregistered unsupervised degradation coordinate. It uses only the
reduction-side sensor structure and no outcome labels.

## 7. Baselines And Primary Model

Baseline B0: constant prevalence.

```text
predict a single probability equal to the training positive rate
```

Baseline B1: cycle only.

```text
event_50 ~ cycle
```

Baseline B2: settings only.

```text
event_50 ~ setting_1 + setting_2 + setting_3
```

Baseline B3: cycle + settings.

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3
```

Baseline B4: wide raw-sensor model.

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3 + 15 nonconstant sensors
```

Primary loss-only model:

```text
event_50 ~ cycle + setting_1 + setting_2 + setting_3 + D_pc1
```

## 8. Model Class

For B1-B4 and the primary model:

```text
sklearn LogisticRegression
penalty = l2
solver = lbfgs
C = 1.0
max_iter = 1000
class_weight = None
```

Standardization:

- fit feature standardization on training rows only;
- apply the same transform to the official test-unit rows.

No calibration stage is introduced in this first C-MAPSS draft. If calibration
is needed later, that must be added in a fresh redesign note rather than
quietly inserted at freeze time.

## 9. Split Rule

This first C-MAPSS draft preserves the official benchmark split:

```text
train_FD001.txt = training rows
test_FD001.txt + RUL_FD001.txt = held-out test units
```

There is no random row split and no post-hoc unit reshuffling.

This choice is intentionally conservative:

```text
the first C-MAPSS anchor should respect the canonical benchmark split rather
than opening extra split freedom
```

## 10. Primary Metric And Secondary Metrics

Primary metric:

```text
held-out log loss on the final test-unit rows
```

Secondary metrics:

- Brier score
- AUROC
- accuracy at 0.5

## 11. Hypotheses

### H1. Loss-only low-dimensional support

The primary model beats the best simple baseline among `{B1, B2, B3}` on
held-out log loss.

Decision rule:

```text
logloss(primary) <= 0.95 * min(logloss(B1), logloss(B2), logloss(B3))
```

### H2. Compression guardrail

The low-dimensional primary remains competitive with the wide raw-sensor model.

Decision rule:

```text
logloss(primary) <= 1.10 * logloss(B4)
```

This is not a claim that compression must beat every raw-sensor benchmark. It
is a guardrail against a structurally empty "support" result that wins only
against trivial baselines.

### H3. Direction consistency

The coefficient on the oriented degradation score `D_pc1` is nonnegative.

Decision rule:

```text
beta_Dpc1 >= 0
```

Because `D_pc1` is oriented to correlate nonnegatively with cycle, a negative
test-time coefficient would be directionally inconsistent with the intended
loss-only reading.

### H4. No repair-flow claim

No outcome in this draft permits a repair-flow interpretation.

## 12. Weakening Outcomes

| outcome | interpretation |
|---|---|
| primary beats B1-B3 but fails H2 | useful low-dimensional loss-only signal, but weaker than the wide raw-sensor model |
| primary passes H2 but fails H3 | predictive signal exists, but the oriented degradation reading is not clean |
| primary fails H1 but B4 is strong | FD001 may still contain predictive degradation structure without supporting the compressed loss-only coordinate |
| all models weak | no-support for this first FD001 loss-only design |

## 13. Freeze Checklist

Before any primary run, freeze must fix:

1. exact local archive path and hash;
2. exact parser for FD001 rows;
3. exact mapping from columns to settings / sensors;
4. exact list of the 15 nonconstant sensors;
5. exact PCA implementation and orientation rule;
6. exact logistic-regression script hash;
7. exact metric code path;
8. exact claim wording for a pass / fail report.

## 14. Non-Claims

This draft does not claim:

1. FD001 is a repair-flow dataset;
2. passing on FD001 would equal live operational-log evidence;
3. C-MAPSS alone closes the non-CSP gap;
4. the PCA coordinate is a universal physical degradation law;
5. failure on FD001 would falsify the structural persistence theory.

## 15. Current Status

This draft is not frozen. It fixes the loss-only path, archive, subset,
endpoint family, and model family tightly enough to support a later freeze, but
the actual execution script and hash are still open.
