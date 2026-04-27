# G4 Scania Component X Horizon-Bridge Primary Report

Status: primary validation completed under the frozen Scania public bridge
package. Primary support did not pass. This is a public stochastic reliability
bridge no-support result. It is not repair-flow evidence and it does not
support a direct empirical `g_t`.

Date run: 2026-04-27

Freeze commit:

```text
3d09c4d Freeze Scania horizon-bridge package
```

Evaluation script SHA256:

```text
0b0d304f93f15be5c70fe6ff7d6aa37fa80dea67cbe0c91187dbbda48206500c
```

Raw primary JSON:

```text
analysis/g4_scania_component_x_horizon_bridge/data/primary_result.json
sha256: 7c858830494e4f2ca697af57c9a9288ba55b9bd7abfc4575d30135264cc54a51
```

The raw JSON is intentionally kept under
`analysis/g4_scania_component_x_horizon_bridge/data/`, which is git-ignored.
This report records only the decision-relevant outcome.

## 1. Scope

This is the first frozen Scania public branch under the horizon-classification
operational path.

It tests whether the preregistered compressed degradation-side coordinate
`D_pc1`, combined with `time_step` and vehicle specifications, improves
held-out horizon-label prediction over the simple time/specification baselines
and remains within the preregistered guardrail against the wide raw-readout
baseline.

It does not test:

- repair flow \(g_t\);
- direct pre-cutoff intervention recovery;
- empirical maintenance-log support;
- universal-law closure;
- retroactive same-archive redesign after the frozen run.

## 2. Frozen Run

Public identity:

```text
Scania Component X
Version 3
DOI: 10.5878/bnh5-ka77
```

Frozen held-out class grammar:

- `0` = more than `48` time steps before failure / repair
- `1` = `48` to `24`
- `2` = `24` to `12`
- `3` = `12` to `6`
- `4` = `6` to `0`

Frozen training-label rule:

```text
censored-as-class-0 within observed study horizon
```

Frozen model family:

```text
sklearn LogisticRegression
multi_class = multinomial
penalty = l2
solver = lbfgs
C = 1.0
max_iter = 2000
class_weight = None
random_state = 43001
```

Frozen primary:

```text
time_step + specifications + D_pc1
```

Frozen wide baseline:

```text
time_step + specifications + all raw operational readout features
```

Observed primary-run structure:

```text
train rows: 1,122,452
train vehicles: 23,550
test rows: 5,045
test vehicles: 5,045
```

Held-out test class counts:

- `0`: `4903`
- `1`: `26`
- `2`: `15`
- `3`: `41`
- `4`: `60`

Observed train-side `D_pc1` orientation check:

```text
corr(D_pc1, time_step) = 0.8283997884816924
```

## 3. Primary Results

Primary metric:

```text
multiclass log loss on held-out test labels
```

| Model | Multiclass log loss | Macro-F1 | Balanced accuracy | Accuracy | Ordered-distance mean |
|---|---:|---:|---:|---:|---:|
| `B0` empirical class prior | `0.176285` | `0.197145` | `0.200000` | `0.971853` | `0.083053` |
| `B1` time_step | `0.181822` | `0.197145` | `0.200000` | `0.971853` | `0.083053` |
| `B2` time_step + specifications | `0.180285` | `0.197145` | `0.200000` | `0.971853` | `0.083053` |
| `B3` wide raw readout baseline | `0.328821` | `0.199558` | `0.203683` | `0.936571` | `0.161943` |
| `primary` time_step + specifications + `D_pc1` | `0.185276` | `0.197125` | `0.199959` | `0.971655` | `0.083251` |

Best simple baseline under H1:

```text
B2_time_step_plus_specifications, log loss = 0.1802851935
```

Primary model:

```text
time_step + specifications + D_pc1, log loss = 0.1852758195
```

H1 decision rule:

```text
logloss(primary) <= 0.95 * min(logloss(B1), logloss(B2))
```

Decision:

```text
H1 primary beats simple baselines: false
```

The H1 threshold was:

```text
0.1712709339
```

So the primary model did not beat the simple time/specification baselines. It
was `2.77%` worse than the best simple baseline on the primary metric.

Wide raw-readout guardrail reference:

```text
B3_wide_raw_readout, log loss = 0.3288205136
```

H2 decision rule:

```text
logloss(primary) <= 1.10 * logloss(B3)
```

Decision:

```text
H2 primary not much worse than wide baseline: true
```

The primary model was substantially better than the wide raw-readout baseline:

```text
(0.3288205136 - 0.1852758195) / 0.3288205136 = 43.65%
```

## 4. Overall Decision

Frozen decision output:

```text
H1_primary_beats_simple_baselines: false
H2_primary_not_much_worse_than_wide_baseline: true
H3_no_direct_repair_flow_claim: true
primary_support: false
```

Therefore:

```text
The first frozen Scania horizon-bridge package does not provide primary
support under its preregistered rule.
```

The clean reading is:

```text
the compressed D_pc1 branch stayed comfortably inside the wide-baseline
guardrail, but it did not improve on the simple time/specification baselines
on held-out horizon labels.
```

This is a no-support result, not a repair-flow result and not a same-archive
rescue target.

## 5. Interpretation Boundary

What this result supports:

- the Scania public branch can be frozen and executed cleanly under a strict
  no-peek workflow;
- the compressed `D_pc1` branch is materially more stable than the very wide
  raw-readout baseline under multiclass log loss;
- the public Scania route remains a genuine stochastic reliability bridge
  attempt rather than a direct repair-flow claim.

What this result does not support:

- public bridge support under the current horizon-classification package;
- direct repair-flow or direct `g_t` evidence;
- stronger evidence than the existing Route A randomized primaries;
- retroactive same-archive redesign after seeing the frozen result.

Descriptive note only:

```text
the empirical class-prior baseline B0 was the strongest log-loss model overall
on this frozen run
```

That fact was not the preregistered H1 comparator, but it does show that the
present Scania operationalization did not move the held-out bridge package away
from the archive's heavy class-0 skew strongly enough to count as support.

## 6. Bottom Line

```text
Scania Component X remains a useful public stochastic reliability bridge route,
but its first frozen horizon-classification package is a no-support outcome:
the compressed D_pc1 primary cleared the wide-baseline guardrail yet failed to
beat the simple time/specification baselines on held-out multiclass log loss.
```
