# Oxford Path Dependent Training Feature-Smoke Plan

Status: historical next-gate plan, superseded by the executed training-only
feature-smoke result note. The executed smoke is still not frozen, not
held-out validation evidence, and not a support claim.

Date: 2026-04-28

## 1. Purpose

This plan defined the second-stage smoke after the MATLAB / MCOS training-cell
conversion succeeded. It is retained as the pre-execution design record; the
current execution result is recorded in
`oxford_path_dependent_training_conversion_and_feature_smoke_result_note.md`.

The current converted-train smoke validates only:

```text
conversion manifest
CSV headers
SHA256 integrity
held-out cell rejection
```

It did not yet prove concrete endpoint extraction, feature extraction, or
model-ladder fit success when written. The later training-only feature smoke
passed under the frozen schema draft, but the freeze-manifest draft still must
not be promoted until the held-out primary runner and output contract are
implemented.

## 2. No-Peek Boundary

Allowed inputs:

- converted CSVs for training cell IDs `4, 8, 10, 14, 15, 18, 19, 20`;
- public guide/readme/schema metadata;
- fixed split, horizon, and baseline-family definitions from the freeze draft.

Forbidden inputs:

- held-out test cell IDs `3, 9, 11, 12`;
- held-out converted CSVs;
- held-out endpoint values;
- held-out feature values;
- held-out predictions;
- held-out metrics;
- support flags.

The smoke may inspect training values because feature extraction cannot be
tested without training data. It must not copy raw training rows, endpoint
values, or feature values into checked-in notes.

## 3. Required Outputs

The second-stage smoke should emit only:

```text
selected endpoint field path
selected feature field paths
row-count diagnostics
feature-column names
model-ladder fit-success booleans
preprocessing shape diagnostics
primary_blocked = true
metrics_emitted = false
support_flags_emitted = false
heldout_payload_opened = false
```

It should not emit:

```text
endpoint values
feature values
coefficients used for interpretation
training metrics
held-out predictions
held-out metrics
support flags
```

## 4. Execution Packet

Runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_feature_smoke.sh
```

The runner requires:

```text
FEATURE_SCHEMA=/path/to/training_feature_schema.json
```

Before the schema is written, draft header-only candidates from the converted
training manifest and CSV headers:

```bash
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_schema_draft.sh
```

This emits candidate column families and a non-runnable template. It reads no
training values and does not compute converted CSV content hashes.

Expected command shape:

```bash
FEATURE_SCHEMA=analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/training_feature_schema.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_feature_smoke.sh
```

The schema JSON must use:

```json
{
  "status": "training_feature_smoke_schema_frozen",
  "mode": "training_feature_smoke",
  "human_finalized": true,
  "train_cell_ids": [4, 8, 10, 14, 15, 18, 19, 20],
  "heldout_cell_ids": [3, 9, 11, 12],
  "endpoint_column": "TBD_FROM_TRAINING_SCHEMA",
  "model_features": {
    "B1": ["TBD"],
    "B2": ["TBD"],
    "B3": ["TBD"],
    "primary": ["TBD"]
  }
}
```

The smoke reads converted training values only to verify that the chosen
endpoint and feature columns can instantiate the frozen ladder. It emits fit
success and shape diagnostics only.

The endpoint column must be disjoint from every model feature list. A schema
that places the future label column inside B1/B2/B3/primary is rejected before
any fit is attempted.

Synthetic contract test:

```bash
python3 analysis/g4_battery_m_profile/scripts/test_oxford_training_schema_draft_contract.py
python3 analysis/g4_battery_m_profile/scripts/test_oxford_training_feature_smoke_contract.py
```

## 5. Minimum Fit Ladder

The smoke should instantiate the frozen model ladder on training rows only:

| Model | Smoke requirement |
|---|---|
| `B0` | endpoint column exists and training rows can be counted |
| `B1` | diagnostic index feature can be built |
| `B2` | protocol / group metadata can be encoded |
| `B3` | standard battery-domain pre-cutoff features can be built |
| `primary` | B3 + frozen M/SP feature columns can be built |

The smoke only verifies that each model can be fit without leakage or schema
failure. It does not compare model performance.

## 6. Promotion Rule

The freeze-manifest draft may be promoted only after:

1. MATLAB training conversion passes;
2. converted-train manifest/header smoke passes;
3. header-only schema draft is recorded;
4. endpoint and feature field paths are human-finalized;
5. this training-only feature-smoke passes;
6. converter SHA, Python script SHA, and primary command are inserted.

Only after those steps may held-out test cells be converted and evaluated once.
