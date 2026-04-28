# Oxford Path Dependent Part 1 Group 2 Parser Smoke Note

Status: local one-group cycling/profile parser-smoke note. Not validation
evidence, not a freeze manifest, and not a feature-selection result.

Date: 2026-04-28

## 1. Purpose

This note records the first local cycling/profile archive smoke for the Oxford
Path Dependent Battery branch. It verifies that one full group archive can be
acquired, hashed, opened as a zip, and minimally inspected as MATLAB files under
the bounded smoke rules.

No M/SP features, capacity endpoints, future labels, baseline comparisons, or
support flags were computed.

## 2. Source File Acquired

Source record:

```text
https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e
```

Public file:

```text
Group_2.zip
```

Public record size:

```text
724.6MB
```

Local path:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent/part1/Group_2.zip
```

Local file identity:

| File | Bytes | SHA256 |
|---|---:|---|
| `Group_2.zip` | `759769860` | `4641d6cfc8bc9535c8ec8fe69ed45d02447b2e3420816c0b66785f56687a61a6` |

The local data directory is git-ignored. Only this note and the smoke script are
checked in.

## 3. Manifest Smoke

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_manifest_smoke_part1_group2.json \
  --manifest-only
```

Observed summary:

```json
{
  "expected_files": 27,
  "limits": {
    "max_mat_bytes": 26214400,
    "max_mat_files": 3
  },
  "present_files": 5,
  "missing_files": 22,
  "records_with_errors": 0,
  "zip_files_present": 2
}
```

`Group_2.zip` manifest facts:

```json
{
  "zip_entries": 66,
  "zip_mat_entries": 66
}
```

The other present files are the previously acquired Part 1 guide/readme files
and `EIS.zip`.

## 4. Historical Bounded `.mat` Smoke

This smoke was run before the fixed train/test split. It is retained as a
historical schema-smoke record, not a current post-split evidence path. The
script now requires `--allow-legacy-presplit-mat-smoke` for historical
reproduction only.

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_mat_smoke_part1_group2.json \
  --inspect-mat \
  --allow-legacy-presplit-mat-smoke \
  --max-mat-files 3 \
  --max-mat-bytes 26214400
```

Observed inspected entries:

| Entry | Status | Uncompressed bytes | Max bytes | Top-level public keys | Top-level shape |
|---|---|---:|---:|---|---|
| `Group 2/TPG2 - Cell 3.mat` | `inspected` | `11149864` | `26214400` | `None` | `shape=(1,), dtype=[('s0', 'O'), ('s1', 'O'), ('s2', 'O'), ('arr', 'O')]` |
| `Group 2/TPG2 - Cell 4.mat` | `inspected` | `11341743` | `26214400` | `None` | `shape=(1,), dtype=[('s0', 'O'), ('s1', 'O'), ('s2', 'O'), ('arr', 'O')]` |
| `Group 2/TPG2 - Cell 8.mat` | `inspected` | `9235246` | `26214400` | `None` | `shape=(1,), dtype=[('s0', 'O'), ('s1', 'O'), ('s2', 'O'), ('arr', 'O')]` |

This confirms that the current Python smoke tool can open a real
cycling/profile group archive and load a bounded sample of `.mat` files.

Later split caveat:

```text
Cell 3 is now a held-out test cell in the fixed freeze-manifest draft. This
earlier bounded smoke predates the fixed split and is treated only as
schema-level grandfathered smoke: top-level keys/shapes were emitted, but no
endpoint values, features, preprocessing statistics, predictions, metrics, or
support flags were emitted.
```

## 5. Non-Claims

This note does not claim:

1. that Group 2 alone is sufficient for validation;
2. that Part 1 is sufficient for validation;
3. that M_buffer / M_recovery / M_reconfiguration features are extractable yet;
4. that any battery M/SP feature improves prediction;
5. that any protocol intervention ranking has been tested.

It claims only:

```text
Oxford Path Dependent Part 1 Group_2.zip passed a bounded local
cycling/profile archive parser smoke.
```

## 6. Historical Next Decision

This historical next step has been completed by the later freeze-design,
full-archive identity, RPT structure-count, freeze-manifest draft,
metadata/train-smoke, and MATLAB conversion-packet notes. At the time of this
smoke, the branch still needed a freeze-design decision note answering:

1. whether Oxford has enough independent held-out units for a meaningful
   primary;
2. whether to combine Parts 1-3 before freeze;
3. which endpoint and horizon can be fixed before outcome inspection;
4. whether the first validation target should be Oxford, NASA
   Randomized/Recommissioned, or a later hard-baseline MIT-Stanford/TRI test.
