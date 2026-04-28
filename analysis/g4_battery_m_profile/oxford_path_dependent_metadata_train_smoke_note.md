# Oxford Path Dependent Part 1 Metadata And Train-Smoke Note

Status: historical metadata-only pass / raw train-smoke blocked note,
superseded by the executed MATLAB conversion and training-feature smoke result
note. Still not frozen, not held-out validation evidence, and not a support
claim.

Date: 2026-04-28

## 1. Purpose

This note records the first execution scaffold for the Oxford Path Dependent
Part 1 battery M-profile branch.

Script:

```text
analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py
```

The script implements:

```text
--metadata-only
--train-smoke
--training-feature-smoke
--allow-primary-run
```

The primary mode remains intentionally blocked because the freeze manifest is
still a draft and the held-out primary runner / output contract have not yet
been promoted. The blocked primary mode is fail-closed and exits nonzero until
the manifest is promoted.

## 2. Metadata-Only Command

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent/part1 \
  --output /tmp/oxford_part1_metadata_only.json \
  --metadata-only
```

Result:

```text
metadata_only_passed
```

Observed no-value facts:

| Quantity | Value |
|---|---:|
| Required file hashes match expected | `true` |
| Unmatched group entries | `0` |
| Unique cell IDs | `12` |
| H1 candidate rows total | `223` |
| H1 candidate rows train | `149` |
| H1 candidate rows test | `74` |
| Train cell IDs | `4, 8, 10, 14, 15, 18, 19, 20` |
| Held-out test cell IDs | `3, 9, 11, 12` |

Metadata-only did not open MATLAB payload values.

Public readme availability:

```json
{
  "capacity": true,
  "current": true,
  "temperature": true,
  "time": true,
  "voltage": true,
  "matlab_required_statement_present": true,
  "reference_test_statement_present": true
}
```

Interpretation:

```text
The public metadata supports the intended feature/endpoint family availability,
but the exact MATLAB table field path remains unresolved.
```

## 3. Train-Smoke Command

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent/part1 \
  --output /tmp/oxford_part1_train_smoke.json \
  --train-smoke \
  --max-train-payloads 1
```

Result:

```text
train_smoke_blocked_mcos_table
```

The script opened only one training-cell payload:

| Archive | Entry | Cell | Group | Index | Public keys | Type |
|---|---|---:|---:|---:|---|---|
| `Group_2.zip` | `Group 2/TPG2 - Cell 4.mat` | `4` | `2` | `0` | `None` | `MatlabOpaque` |

Held-out payload status:

```text
heldout_payload_opened = false
```

This status refers to the metadata-only / train-smoke scaffold execution after
the fixed split was selected. Earlier pre-split bounded parser-smoke runs did
open small `.mat` samples from some cells that are now held out, but emitted
only schema-level keys/shapes and no endpoint values, features, predictions,
metrics, or support flags.

Model status:

```text
model_fit_attempted = false
metrics_emitted = false
```

Blocked reason:

```text
Training payload is a MATLAB MCOS table exposed by scipy as MatlabOpaque;
concrete endpoint/features require a MATLAB-side or MCOS-aware conversion step.
```

## 4. Interpretation

This is not a validation failure and not a theory failure.

It means:

```text
At this historical gate, Oxford Part 1 was structurally feasible, but the
Python-only execution path could not extract the MATLAB table payload safely
enough for train-smoke.
```

That blocker was later resolved by the MATLAB training-only conversion path.
The branch should still remain below frozen status until the held-out primary
runner and output contract are implemented.

## 5. Guardrails Preserved

The current execution did not:

- open held-out cell payload values;
- emit endpoint values;
- emit features;
- emit preprocessing statistics;
- emit predictions;
- emit model metrics;
- emit support flags.

## 6. Next Required Step

The no-peek MATLAB / MCOS conversion plan, converter-script draft, and
training-conversion runner now exist. The next artifact should be a
MATLAB-environment execution result note after the runner is executed.

The Python scaffold now also has a converted-table train-smoke entry point:

```text
--converted-train-root
```

That mode is limited to manifest / CSV-header validation and still emits no
endpoint values, features, preprocessing statistics, predictions, metrics, or
support flags.

It must satisfy:

1. conversion may be tested first on training cell IDs only;
2. held-out cell IDs `3, 9, 11, 12` must not be converted or opened during
   train-smoke;
3. exported training files may contain only training-cell payloads;
4. the header-only schema draft must be recorded before schema finalization;
5. the exact endpoint and feature field paths must be human-finalized from
   training schema plus public guide information before any held-out conversion;
6. training-feature smoke must pass with that frozen schema;
7. primary remains blocked until the freeze manifest records the converter,
   execution script SHA, and one-time primary command.
