# Oxford Path Dependent Part 1 Small-File Smoke Note

Status: local small-file and one-zip acquisition / manifest-smoke note. Not
validation evidence, not a freeze manifest, and not a feature-selection result.

Date: 2026-04-28

## 1. Purpose

This note records the first local smoke step for the Oxford Path Dependent
Battery branch. The small Part 1 guide/readme files and the small Part 1
`EIS.zip` archive were acquired. The large group archives were not downloaded,
and no degradation-feature extraction, capacity endpoint, baseline comparison,
or M/SP support flag was computed.

## 2. Source Files Acquired

Source record:

```text
https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e
```

Local directory:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent/part1/
```

The local data directory is git-ignored. Only this note and the smoke script are
checked in.

| File | Bytes | SHA256 |
|---|---:|---|
| `Guide_to_Datafiles.pdf` | `125508` | `7431d5a7f94881e19d209452ab44820f9a0ddec0424ae930cbc2f474dead493c` |
| `Guide_to_Datafiles.xlsx` | `21906` | `54f8fddb5d71e9c7179ac25d45b751b12f2b413573a7f190a8ffef95135a6aa7` |
| `Readme.txt` | `4641` | `59489534eaa5cddd2cef74b057855d2074bbef802d3aa12db6e082f9886dc59c` |
| `EIS.zip` | `190279` | `64d1fc94dcd3b2403d3f84b88666781a4f6153068e2ef4311d7cde97106a6d27` |

## 3. Smoke Command

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_manifest_smoke_part1_eis.json \
  --manifest-only
```

Observed summary:

```json
{
  "expected_files": 27,
  "present_files": 4,
  "missing_files": 23,
  "records_with_errors": 0,
  "zip_files_present": 1
}
```

This is the expected result for the current local state, because only the three
small Part 1 guide/readme files and `EIS.zip` were acquired.

`EIS.zip` manifest facts:

```json
{
  "zip_entries": 119,
  "zip_mat_entries": 117
}
```

Historical `.mat` structure smoke command:

This command was run before the fixed train/test split. It is not a current
post-split evidence path; the script now requires
`--allow-legacy-presplit-mat-smoke` for historical reproduction only.

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_mat_smoke_part1_eis.json \
  --inspect-mat \
  --allow-legacy-presplit-mat-smoke \
  --max-mat-files 3 \
  --max-mat-bytes 26214400
```

Observed `.mat` smoke:

```text
3 EIS .mat files inspected
all three statuses: inspected
top-level public key: None
shape: (1,)
dtype fields: s0, s1, s2, arr
```

This confirms that the local Python parser can open the zip and load a small
sample of MATLAB files. It does not yet parse cycling/profile archives.

## 4. Parser Correction From Smoke

The first smoke run revealed a useful pre-freeze parser issue: repeated file
names such as `Readme.txt` must not be assigned to Parts 2 or 3 merely because a
single Part 1 readme exists locally.

The manifest script was therefore tightened so that repeated expected names are
only matched in part-specific paths, unless the file name is unique across all
expected files.

This correction is part of the smoke result and reduces the risk of false
archive completeness before any freeze.

## 5. Current Interpretation

Historical state at the time of this note:

```text
Part 1 small-file acquisition: passed
Part 1 EIS one-zip parser smoke: passed
Part 1 large group archives: not acquired
Part 2 / Part 3 files: not acquired
cycling/profile .mat parser smoke: not yet run
feature extraction: not yet run
validation: not yet run
```

Oxford Path Dependent remains a positive feasibility candidate with a
small-sample warning. It is still not a frozen primary candidate, but the later
branch state has advanced through cycling/profile group smoke, full Part 1
identity, no-metric RPT structure counts, freeze-manifest draft,
metadata/train-smoke, MATLAB training conversion, schema draft, and
training-feature smoke.

## 6. Historical Next Step

The historical next step was to acquire one cycling/profile group archive if
local storage and runtime budget permitted. That step has now been completed,
and the training-conversion runner has since passed on training cells only.
The branch then advanced to a fail-closed held-out primary runner and output
contract. The current next step is to accept the freeze manifest as frozen
before running the one-time primary command.

Do not compute M/SP predictive features until a freeze-design note fixes the
unit, split, endpoint, horizon, baseline ladder, and feature families.
