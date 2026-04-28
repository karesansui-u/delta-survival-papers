# Oxford Path Dependent MCOS Converter Script Note

Status: historical converter-script draft note, superseded by the executed
training-only conversion and feature-smoke result note. The executed conversion
is still not frozen, not held-out validation evidence, and not a support claim.

Date: 2026-04-28

## 1. Script

Converter draft:

```text
analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m
```

Runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

Purpose:

```text
export Oxford Part 1 MATLAB table payloads for training cell IDs only
then run the Python converted-train manifest/header smoke check
```

The script was intended to unblock the earlier train-smoke result:

```text
train_smoke_blocked_mcos_table
```

## 2. No-Peek Boundary

Training cell IDs hard-coded for export:

```text
4, 8, 10, 14, 15, 18, 19, 20
```

Held-out test cell IDs hard-blocked:

```text
3, 9, 11, 12
```

The converter does not compute:

- endpoints;
- features;
- preprocessing statistics;
- predictions;
- metrics;
- support flags.

It only exports training tables and writes a conversion manifest.

The exported training CSVs can contain raw training-cell values because they
are converted payloads. The no-peek claim is narrower: no held-out values are
converted, and no endpoint values, feature values, predictions, metrics, or
support flags are emitted into checked-in notes or smoke JSON before freeze.

Boundary caveat:

```text
Earlier bounded parser-smoke runs predate the fixed train/test split and are
treated as schema-only grandfathered smoke. From the fixed split onward, this
converter must not export or open held-out test cells before final freeze.
```

## 3. Intended Output

Default output root:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke/
```

The output root is under `data/`, which is git-ignored.

Expected manifest:

```text
conversion_manifest.json
```

Manifest fields include source archive, source entry, group ID, cell ID,
diagnostic index, table variable name, column names, row count, column count,
output CSV path, and output SHA256.

## 4. Execution Status

Local execution status:

```text
not executed
```

Reason:

```text
MATLAB is not available in the current local environment.
```

Verification performed locally:

```text
static converter-script creation and compatibility hardening
Python py_compile for execution scaffolds
metadata-only rerun
raw train-smoke rerun showing MCOS block
converted-table train-smoke interface check on a synthetic /tmp training-only manifest
```

The synthetic interface check did not use Oxford converted values. It verified
only that the Python scaffold can reject/accept a training-only converted
manifest shape and inspect CSV headers without emitting endpoint values,
features, preprocessing statistics, predictions, metrics, or support flags.

## 5. Next Check

When MATLAB is available, run:

```bash
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

For a one-record MATLAB runtime sanity check before the full export:

```bash
MAX_RECORDS=1 \
OUTPUT_ROOT=analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke_one_record \
SMOKE_OUTPUT=analysis/g4_battery_m_profile/replication_outputs/oxford_part1_converted_train_smoke_one_record.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

That one-record check is expected to produce a partial-runtime-sanity status
and is not promotion-eligible. The full converted train-smoke gate requires all
training cell IDs and no `max_records` truncation.

This runs the MATLAB converter and then the Python converted-table train-smoke
interface:

```bash
python3 analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent/part1 \
  --output /tmp/oxford_part1_converted_train_smoke.json \
  --train-smoke \
  --converted-train-root analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke
```

The Python converted-table mode now validates the manifest, rejects held-out
cell IDs, verifies CSV headers and SHA256, and emits no endpoint values,
features, preprocessing statistics, predictions, metrics, or support flags.
Held-out test cell conversion remains blocked until the freeze manifest is
promoted to frozen.
