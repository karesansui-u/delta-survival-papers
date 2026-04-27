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
  can the structural-balance vocabulary be attached to a public
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

The following three files must be fully acquired and hashed locally:

- `train_operational_readouts.csv`
- `validation_operational_readouts.csv`
- `test_operational_readouts.csv`

The exact full-file sha256 values must appear in a later exact-archive /
freeze-stage note.

### 5.2 Label grammar lock

The meaning of the held-out class labels must be fixed explicitly before any
preregistration:

- what each `class_label` value means;
- whether it is a window-to-repair label, a failure-risk label, or a combined
  event proximity label;
- whether the label grammar is compatible with the primary path or only the
  secondary path.

### 5.3 One primary path only

The frozen package must choose one primary path:

1. survival / TTE bridge, or
2. horizon-classification bridge.

The other path may remain secondary or deferred, but both cannot remain
co-primary.

### 5.4 Model and metric freeze

Before any validation run, the package must freeze:

- baseline family;
- feature family;
- model class;
- primary metric;
- any secondary metric;
- exact split usage and held-out policy.

## 6. Current Recommendation

At the draft stage, the strongest reading is:

```text
Primary conceptual path: survival / TTE bridge.
Secondary operational path: horizon classification bridge.
```

This preserves the strongest law-side story without pretending the held-out
classification labels are irrelevant.

## 7. Non-Claims

This draft does not claim:

1. Scania already closes the repair-flow empirical gap;
2. Scania already has a direct logged \(g_t\);
3. the survival / TTE path is already freeze-ready;
4. horizon classification is already chosen as primary;
5. a public bridge package is stronger than partner/local directly logged
   maintenance data.

## 8. Bottom Line

The clean current position is:

```text
Scania Component X is ready for a bridge-package draft.
It should be developed as a public stochastic reliability / TTE bridge, with
horizon-classification as the practical secondary path, and with full readout
hashes plus label-grammar lock as the next freeze prerequisites.
```
