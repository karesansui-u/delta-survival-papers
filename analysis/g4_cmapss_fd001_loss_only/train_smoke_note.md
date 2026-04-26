# G4 C-MAPSS FD001 Train-Side Smoke Note

Status: pre-freeze train-side smoke note. Not frozen. Not validation evidence.
Not a held-out primary result.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_cmapss_fd001_loss_only_preregistration_draft.md`
- `analysis/g4_cmapss_fd001_loss_only/freeze_manifest_draft.md`
- `analysis/g4_cmapss_fd001_archive_feasibility_note.md`

Purpose:

Record that the first FD001 execution script now parses the exact archive,
constructs the frozen loss-only coordinate, and fits all preregistered train-
side models without touching held-out test performance metrics.

This note is an integration check only.

## 1. Archive Used

Local archive path during smoke:

```text
/tmp/CMAPSSData.zip
```

Observed sha256:

```text
74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f
```

This matches the exact archive feasibility note and the current freeze-manifest
draft.

## 2. Commands Run

Metadata-only parser check:

```bash
python3 analysis/g4_cmapss_fd001_loss_only/scripts/evaluate_cmapss_fd001_loss_only.py \
  --archive /tmp/CMAPSSData.zip \
  --output analysis/g4_cmapss_fd001_loss_only/data/cmapss_fd001_metadata.json \
  --metadata-only
```

Train-side smoke:

```bash
python3 analysis/g4_cmapss_fd001_loss_only/scripts/evaluate_cmapss_fd001_loss_only.py \
  --archive /tmp/CMAPSSData.zip \
  --output analysis/g4_cmapss_fd001_loss_only/data/cmapss_fd001_train_smoke.json \
  --train-smoke
```

## 3. Structural Results

Metadata-only output reproduced the expected exact-archive structure:

| field | observed |
|---|---:|
| `train_rows` | `20631` |
| `train_units` | `100` |
| `test_rows` | `13096` |
| `test_units` | `100` |
| `test_positive_units_h50` | `33` |
| `test_negative_units_h50` | `67` |

These agree with the exact archive feasibility note.

## 4. Train-Side Smoke Results

The smoke output recorded:

- all five train-side fits succeeded:
  - `B1`
  - `B2`
  - `B3`
  - `B4`
  - `primary`
- feature dimensions:
  - `B1 = 1`
  - `B2 = 3`
  - `B3 = 4`
  - `B4 = 19`
  - `primary = 5`
- oriented training correlation:
  - `corr(D_pc1, cycle) = 0.6775154516709757`

Observed training label counts under `H = 50`:

| field | observed |
|---|---:|
| positive rows | `5100` |
| negative rows | `15531` |
| training prevalence | `0.24720081430856478` |

These values are train-side only. They are not held-out evidence.

## 5. No-Peek Boundary

The train-smoke JSON explicitly records:

```json
{
  "held_out_test_metrics_recorded": false,
  "held_out_test_predictions_recorded": false
}
```

No log-loss, AUC, Brier, accuracy, or model-comparison result on held-out
FD001 test units is recorded in this note or used as evidence.

## 6. Interpretation

This smoke establishes only that:

```text
the exact FD001 archive parses cleanly, the frozen D_pc1 construction can be
built, and all preregistered train-side models fit successfully without any
held-out evaluation
```

It does not establish support, no-support, or any result on the held-out test
units.

## 7. Next Step

The next clean move is to:

1. fill the execution-script path and script hash into the freeze manifest;
2. freeze the FD001 loss-only package;
3. only then permit a single held-out primary run.
