# G4 C-MAPSS FD001 Loss-Only Primary Report

Status: primary validation completed under the frozen FD001 package. Overall
primary support did not pass. This is a preregistered weakening outcome:
the compressed loss-only coordinate beat the simple baselines and preserved
directional consistency, but it failed the wide-sensor compression guardrail.
It is not repair-flow evidence.

Date run: 2026-04-27

Freeze commit:

```text
7bf58ed Freeze C-MAPSS FD001 loss-only primary package
```

Evaluation script SHA256:

```text
25980fc025409a4d74fdc63247cc44e2f98fe44957830fa7e378eae14dd86cb1
```

Raw primary JSON:

```text
analysis/g4_cmapss_fd001_loss_only/data/cmapss_fd001_primary_results.json
sha256: c2404d36dccb43a8a7c0aa851dec2538adcbd7ee5c93a4f4017d8830ff6aa3b6
```

The raw JSON is intentionally kept under
`analysis/g4_cmapss_fd001_loss_only/data/`, which is git-ignored. This report
records the decision-relevant results.

## 1. Scope

This is the first cross-domain non-CSP loss-only primary on the public
C-MAPSS FD001 degradation benchmark.

It tests whether a preregistered low-dimensional degradation coordinate
`D_pc1`, combined with `cycle` and operating settings, improves near-failure
classification over simple baselines and remains within the preregistered
compression guardrail against a wide raw-sensor model.

It does not test:

- repair flow \(g_t\);
- preventive maintenance;
- live operational maintenance logs;
- G4 v2 repair / maintenance validation;
- universal-law status;
- retroactive rescue of same-archive alternatives after the frozen run.

## 2. Frozen Run

Archive:

```text
CMAPSSData.zip
subset = FD001
sha256 = 74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f
```

Primary endpoint:

```text
near-failure event with H = 50 cycles
```

Train / test structure:

```text
train rows: 20631
train units: 100
test rows: 13096
test units: 100
test positives: 33
test negatives: 67
```

Frozen model family:

```text
sklearn LogisticRegression
penalty = l2
solver = lbfgs
C = 1.0
class_weight = None
max_iter = 1000
random_state = 43001
```

Frozen coordinate:

```text
D_pc1 = one-component PCA score on the 15 nonconstant FD001 sensors,
oriented so corr(D_pc1, cycle) >= 0 on training rows
```

Observed training correlation:

```text
corr(D_pc1, cycle) = 0.6775154516709757
```

No calibration layer was included in this first FD001 branch.

## 3. Primary Results

Primary metric:

```text
held-out log loss on the final test-unit rows
```

| Model | Log loss | AUROC | Brier | Accuracy @ 0.5 |
|---|---:|---:|---:|---:|
| `B0` constant prevalence | `0.651444` | `0.500000` | `0.227956` | `0.67` |
| `B1` cycle | `0.494974` | `0.811398` | `0.170713` | `0.71` |
| `B2` operating settings | `0.654744` | `0.342379` | `0.229177` | `0.67` |
| `B3` cycle + settings | `0.498139` | `0.806422` | `0.172084` | `0.71` |
| `B4` wide raw-sensor model | `0.182180` | `0.980100` | `0.057699` | `0.92` |
| `primary` `D_pc1 + cycle + settings` | `0.241353` | `0.955224` | `0.073310` | `0.89` |

Best simple baseline under H1:

```text
B1_cycle, log loss = 0.4949741973
```

Primary model:

```text
D_pc1 + cycle + settings, log loss = 0.2413534779
```

H1 decision rule:

```text
logloss(primary) <= 0.95 * min(logloss(B1), logloss(B2), logloss(B3))
```

Decision:

```text
H1 loss-only support: true
```

Relative improvement over the best simple baseline:

```text
51.24%
```

Wide raw-sensor guardrail reference:

```text
B4_wide_raw_sensor, log loss = 0.1821796370
```

H2 decision rule:

```text
logloss(primary) <= 1.10 * logloss(B4)
```

Observed gap:

```text
(0.2413534779 - 0.1821796370) / 0.1821796370 = 32.48%
```

Decision:

```text
H2 compression guardrail: false
```

So the compressed coordinate clearly beats the simple baselines, but it is
still materially weaker than the wide raw-sensor benchmark.

## 4. Direction Consistency

H3 required the coefficient on the oriented degradation score `D_pc1` to be
nonnegative.

Primary coefficients:

| feature | coefficient |
|---|---:|
| `cycle` | `0.688914` |
| `setting_1` | `-0.000675` |
| `setting_2` | `-0.005795` |
| `setting_3` | `0.000000` |
| `D_pc1` | `3.475025` |

Decision:

```text
H3 direction consistency: true
```

Because `D_pc1` was oriented so that its training correlation with `cycle` is
nonnegative, the positive `D_pc1` coefficient is consistent with the intended
loss-only reading.

## 5. Overall Decision

Frozen decision output:

```text
H1_loss_only_support: true
H2_compression_guardrail: false
H3_direction_consistency: true
H4_no_repair_flow_claim: true
primary_support: false
```

Therefore:

```text
C-MAPSS FD001 provides a useful low-dimensional loss-only signal, but it does
not pass the preregistered primary support rule because the compressed
coordinate is weaker than the wide raw-sensor model.
```

This is exactly the preregistered weakening outcome:

```text
primary beats B1-B3 but fails H2
```

It should be reported as a weakening result, not as cross-domain non-CSP
primary support.

## 6. Interpretation Boundary

What this result supports:

- the FD001 benchmark contains real loss-only degradation signal;
- the compressed `D_pc1` coordinate improves substantially over simple
  cycle / setting baselines;
- the oriented degradation reading is directionally coherent (`beta_Dpc1 > 0`).

What this result does not support:

- repair-flow \(g_t\) or maintenance evidence;
- live operational-log support;
- closure of the cross-domain non-CSP gap;
- evidence equal in strength to Route A randomized primaries or even the
  stronger Backblaze v2 observational pass.

The clean reading is:

```text
The first frozen cross-domain loss-only C-MAPSS run found a real compressed
degradation signal, but that signal remained weaker than the preregistered
wide raw-sensor benchmark.
```

That is informative progress, but it is not a support result.
