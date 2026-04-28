# Oxford Path Dependent MCOS Converter Execution Note

Status: historical execution packet, superseded by the executed training-only
conversion and feature-smoke result note. The executed conversion is still not
frozen, not held-out validation evidence, and not a support claim.

Date: 2026-04-28

## 1. Purpose

This note records the handoff point that preceded the Oxford Part 1
training-cell MATLAB / MCOS conversion. It is retained as the pre-execution
packet; the current local execution result is recorded in
`oxford_path_dependent_training_conversion_and_feature_smoke_result_note.md`.

The converter and runner are:

```text
analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

The runner performs only:

```text
training-cell MATLAB table conversion
converted training manifest / CSV-header/SHA256 smoke check
```

It does not authorize a held-out primary run.

## 2. No-Peek Boundary

Training cell IDs:

```text
4, 8, 10, 14, 15, 18, 19, 20
```

Held-out test cell IDs:

```text
3, 9, 11, 12
```

The MATLAB converter hard-blocks held-out test cells in `train_smoke` mode.
The Python converted-table smoke check rejects any converted manifest that
contains held-out cell IDs.

The runner does not compute:

- endpoint values;
- features;
- preprocessing statistics;
- predictions;
- metrics;
- support flags.

The MATLAB converter writes raw training-cell tables under a git-ignored data
directory. Therefore, "does not compute / emit endpoint values" means endpoint
values are not selected, summarized, copied into checked-in notes, or emitted
in the smoke JSON. It does not mean the training-only converted CSVs are
value-free.

## 3. Runner Command

From the repository root, on a machine with MATLAB available:

```bash
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

Optional overrides:

```bash
ROOT=analysis/g4_battery_m_profile/data/oxford_path_dependent/part1 \
OUTPUT_ROOT=analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke \
SMOKE_OUTPUT=analysis/g4_battery_m_profile/replication_outputs/oxford_part1_converted_train_smoke.json \
MATLAB_BIN=matlab \
PYTHON_BIN=python3 \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

For a first MATLAB runtime sanity check, the runner can export only one
training record to a fresh output root:

```bash
MAX_RECORDS=1 \
OUTPUT_ROOT=analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke_one_record \
SMOKE_OUTPUT=analysis/g4_battery_m_profile/replication_outputs/oxford_part1_converted_train_smoke_one_record.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

This one-record command should report:

```text
converted_train_smoke_partial_runtime_sanity_checked
promotion_eligible = false
```

It is only a MATLAB runtime sanity check and cannot satisfy the full converted
train-smoke gate.

The default full training-conversion runner refuses to write into a non-empty
`OUTPUT_ROOT`. It writes to a staging directory first, validates the staging
manifest with Python, and then moves the staging output into the final
`OUTPUT_ROOT`.

## 4. Expected Output

Converted training tables are written under the git-ignored directory:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke/
```

The converted-smoke JSON is written under the git-ignored directory:

```text
analysis/g4_battery_m_profile/replication_outputs/oxford_part1_converted_train_smoke.json
```

Expected Python status:

```text
converted_train_smoke_manifest_checked
```

Required guardrail fields:

```text
manifest_guardrails_checked = true
missing_training_cell_ids = []
promotion_eligible = true
heldout_payload_opened = false
matlab_payload_opened = false
converted_training_tables_read = headers_and_sha256_file_bytes
metrics_emitted = false
primary_blocked = true
```

## 5. Local Execution Status

Local execution status:

```text
not executed
```

Reason:

```text
MATLAB is not available in the current local environment.
```

Local command check:

```text
matlab not found
```

## 6. Result Recording Template

After a MATLAB-enabled run, record only the following non-primary facts in this
note or a follow-up execution result note:

```text
runner command
MATLAB version
converter script SHA256
Python script SHA256
conversion_manifest.json SHA256
converted train-smoke JSON SHA256
converted train-smoke status
converted record_count
exported training cell IDs
heldout_payload_opened flag
metrics_emitted flag
primary_blocked flag
```

Do not copy table values, endpoint values, feature values, predictions, or
metrics into the checked-in note.

## 7. Promotion Rule

This branch may not be promoted from freeze-manifest draft to frozen until:

1. the MATLAB training-cell converter is executed successfully;
2. the converted train-smoke JSON reports `converted_train_smoke_manifest_checked`;
3. the converted manifest identity is recorded;
4. the header-only schema draft is recorded;
5. the exact endpoint and feature field paths are fixed from training schema
   plus public guide information only;
6. the training-feature smoke JSON reports `training_feature_smoke_passed`;
7. the converter SHA and Python script SHA are inserted into the freeze
   manifest;
8. the one-time primary command is inserted.

Held-out test cell conversion remains blocked until those conditions are met.
