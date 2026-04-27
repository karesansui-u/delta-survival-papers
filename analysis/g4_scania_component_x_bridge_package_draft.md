# G4 Scania Component X Bridge Package Draft

Status: bridge-package draft only. Not frozen. Not validation evidence. Not
repair-flow evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md`
- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_v2_stochastic_repair_bridge_note.md`

## 1. Purpose

This draft records how Scania Component X would be opened if the program chooses
to turn it into a public non-CSP bridge package.

The target is narrow:

```text
public stochastic reliability / time-to-event bridge
```

The target is not:

```text
direct repair-flow empirical support
```

## 2. Fixed Tier And Identity

Current exact public identity:

```text
Scania Component X
Version 3
DOI: 10.5878/bnh5-ka77
```

Current safe tier:

```text
public stochastic reliability bridge candidate
```

This tier is below:

- Route A randomized primaries;
- true repair-flow empirical bridge;
- any claim that a direct logged \(g_t\) has already been frozen.

## 3. Structural Reading

The current public structure is best read as:

| element | role |
|---|---|
| `vehicle_id` | repeated unit |
| `time_step` | time axis |
| `*_operational_readouts.csv` | degradation / load-side history |
| `*_specifications.csv` | static unit metadata |
| `train_tte.csv` | event-time / repair endpoint table |
| `validation_labels.csv`, `test_labels.csv` | held-out horizon-style labels |

Critical boundary:

```text
in_study_repair is currently treated as endpoint/event semantics, not as a
direct pre-cutoff compensation-flow variable g_t.
```

That is why this branch is a stochastic reliability bridge and not a repair-flow
primary.

## 4. Provisional Package Design

The package should be thought of in two layers.

### 4.1 Primary conceptual path: survival / TTE bridge

This is the law-side-nearest reading.

Conceptual mapping:

- damage-side covariates: operational readouts and static specs;
- unit / time: `vehicle_id`, `time_step`;
- event process: replacement / repair time in `train_tte.csv`;
- bridge question:
  can the structural-persistence balance vocabulary be attached to a public
  time-to-event / stochastic reliability prediction task?

Why this is the preferred conceptual path:

1. it is closest to the current queueing / Foster-Lyapunov law-side bridge;
2. it uses the dataset's strongest public semantics: event-time / replacement
   timing;
3. it stays safely below any claim of direct empirical \(g_t\).

### 4.2 Secondary operational path: horizon classification bridge

This is the easier held-out operational path.

Conceptual mapping:

- use `validation_labels.csv` and `test_labels.csv` as the bridge endpoint;
- use the partial readout histories and specifications as predictors;
- ask whether a frozen degradation-side coordinate beats simple baselines on
  the published held-out labels.

Why it is secondary:

1. it is operationally easier than a full survival bridge;
2. but it is one step farther from the reader-facing stochastic reliability
   story than the TTE reading.

## 5. Freeze Prerequisites

No Scania bridge freeze should occur until all of the following are completed.

### 5.1 Exact large-file acquisition

This gate is now closed by:

- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`

That note records exact bytes, full-file sha256 values, line counts, and unique
`vehicle_id` counts for:

- `train_operational_readouts.csv`
- `validation_operational_readouts.csv`
- `test_operational_readouts.csv`

### 5.2 Label grammar lock

This gate is now closed by:

- `analysis/g4_scania_component_x_freeze_design_note.md`

That note fixes the held-out `class_label` grammar as an ordered five-class
time-window target:

- `0` = more than `48` time steps before failure / repair;
- `1` = `48` to `24`;
- `2` = `24` to `12`;
- `3` = `12` to `6`;
- `4` = `6` to `0`.

### 5.3 One primary path only

This gate is now closed by:

- `analysis/g4_scania_component_x_freeze_design_note.md`

Current chosen direction:

```text
primary operational path = horizon-classification bridge
secondary conceptual path = survival / TTE bridge
```

### 5.4 Model and metric freeze

Before any validation run, the package must freeze:

- baseline family;
- feature family;
- model class;
- primary metric;
- any secondary metric;
- exact split usage and held-out policy.

## 6. Current Recommendation

At the current design stage, the strongest reading is:

```text
Primary operational path: horizon classification bridge.
Secondary conceptual path: survival / TTE bridge.
```

This preserves the strongest law-side story while choosing the public held-out
classification route as the operational primary.

## 7. Non-Claims

This draft does not claim:

1. Scania already closes the repair-flow empirical gap;
2. Scania already has a direct logged \(g_t\);
3. the survival / TTE path is already freeze-ready as an executable package;
4. the remaining model / metric / split details are already frozen;
5. a public bridge package is stronger than partner/local directly logged
   maintenance data.

## 8. Bottom Line

The clean current position is:

```text
Scania Component X is ready for a bridge-package draft.
It should be developed operationally as a horizon-classification bridge, while
survival / TTE remains the conceptual law-side secondary path. Full readout
hashes and held-out label grammar are now fixed; the remaining pre-freeze work
is model / metric / split freeze design.
```
