# G4 Scania Component X Freeze Design Note

Status: freeze-design note only. Not frozen. Not validation evidence. Not
repair-flow evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`
- `analysis/g4_scania_component_x_bridge_package_draft.md`

## 1. Purpose

Move the Scania public bridge route from:

```text
archive identity closed, but pre-freeze design still open
```

to:

```text
label grammar fixed, primary path chosen, remaining work narrowed to model /
metric / feature freeze
```

This note still does not freeze an executable package. It fixes the design
direction.

## 2. Fixed Tier

Scania remains:

```text
public stochastic reliability / TTE bridge
```

and not:

```text
direct repair-flow empirical support
```

The current design does not reinterpret `in_study_repair` as direct pre-cutoff
`g_t`.

## 3. Label-Grammar Lock

Public documentation is explicit enough to lock the held-out label grammar.

For `validation_labels.csv` and `test_labels.csv`, the `class_label` values are
interpreted as ordered time windows before failure / repair for the last
selected readout of each vehicle:

| class | meaning |
|---|---|
| `0` | more than `48` time steps before failure / repair |
| `1` | `48` to `24` time steps before failure / repair |
| `2` | `24` to `12` time steps before failure / repair |
| `3` | `12` to `6` time steps before failure / repair |
| `4` | `6` to `0` time steps before failure / repair |

This note fixes that grammar as the public classification target.

## 4. Training-Label Construction Rule

The train split does not expose `class_label` directly in
`train_operational_readouts.csv`, so the training classes must be derived from
`train_tte.csv` using a deterministic rule.

Recommended construction:

1. join each training readout to its vehicle-level `train_tte.csv` record;
2. let
   `delta = length_of_study_time_step - time_step`;
3. if `in_study_repair = 1`, map `delta` into the same five class windows as
   the held-out sets;
4. if `in_study_repair = 0`, assign class `0` to the observed readouts in the
   study horizon.

This is the cleanest training-side analogue of the public held-out label
surface.

## 5. Primary Path Choice

This note chooses:

```text
primary operational path = horizon-classification bridge
```

and leaves:

```text
secondary conceptual path = survival / TTE bridge
```

Reasons:

1. the held-out validation/test labels are already published in explicit class
   form;
2. the classification path is easier to freeze and rerun cleanly;
3. the survival / TTE story remains important for interpretation, but it would
   require extra bridge design beyond the current public label surface;
4. this choice keeps Scania below repair-flow primary while still making it a
   real public non-CSP bridge package candidate.

## 6. Recommended Package Skeleton

Recommended unit of evaluation:

```text
one labeled readout per vehicle in validation/test
```

Recommended split policy:

- official train split = fit only;
- official validation split = design-stage guardrail / calibration set;
- official test split = one-time held-out primary evaluation.

Recommended baseline ladder:

- `B0`: empirical class-prior baseline;
- `B1`: specifications-only classifier;
- `B2`: wide raw readout + specifications baseline.

Recommended structural primary family:

```text
compressed degradation-side coordinate(s) derived on the train split only,
then evaluated against the held-out five-class horizon labels
```

This keeps the bridge package aligned with structural-persistence balance language while
still facing a strong wide-readout baseline.

## 7. Recommended Metrics

Recommended primary metric:

```text
multiclass log loss on the five-class held-out labels
```

Recommended secondary metrics:

- macro-F1;
- balanced accuracy;
- optional ordered-distance or cost-matrix score as a diagnostic only.

Reason:

Multiclass log loss is the cleanest preregistered bridge metric and is most
consistent with the rest of the program's held-out evaluation style.

## 8. What Still Remains Open

This note intentionally does not yet freeze:

1. the exact compressed feature family;
2. the exact model class;
3. regularization / hyperparameter values;
4. whether ordered-class diagnostics become formal secondary metrics.

Those belong in the later frozen bridge package, not here.

## 9. Bottom Line

```text
Scania has now moved to pre-freeze design stage.
Its held-out class grammar is fixed, the operational primary path is chosen as
horizon classification, and survival / TTE is retained as the conceptual
law-side secondary path.
```
