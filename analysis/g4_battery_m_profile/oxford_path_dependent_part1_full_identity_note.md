# Oxford Path Dependent Part 1 Full Identity Note

Status: local Part 1 full-identity / bounded parser-smoke note. Not validation
evidence, not a freeze manifest, not feature extraction, and not a support
claim.

Date: 2026-04-28

## 1. Purpose

This note records completion of the Tier A acquisition from:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_full_archive_identity_plan.md
```

All public Part 1 files listed in the Oxford Research Archive record were
acquired locally, hashed, opened where applicable, and checked with bounded
`.mat` smoke. No capacity endpoints, labels, M/SP features, baselines, metrics,
or support flags were computed.

Source record:

```text
https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e
```

## 2. Manifest Command

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_manifest_smoke_part1_full.json \
  --manifest-only
```

Observed summary:

```json
{
  "expected_files": 27,
  "missing_files": 18,
  "present_files": 9,
  "records_with_errors": 0,
  "zip_files_present": 6
}
```

The remaining 18 missing files are expected because this note covers Part 1
only; Parts 2 and 3 have not yet been acquired.

## 3. Part 1 File Identities

| File | Bytes | SHA256 | Zip entries | `.mat` entries |
|---|---:|---|---:|---:|
| `Guide_to_Datafiles.pdf` | `125508` | `7431d5a7f94881e19d209452ab44820f9a0ddec0424ae930cbc2f474dead493c` |  |  |
| `Guide_to_Datafiles.xlsx` | `21906` | `54f8fddb5d71e9c7179ac25d45b751b12f2b413573a7f190a8ffef95135a6aa7` |  |  |
| `Half_Cell.zip` | `8926444` | `43682be83c416f12e046ba97ee7d45b3b311615e0ef4b93c243e3f3462ec4dcd` | `6` | `6` |
| `Group_1.zip` | `862297104` | `72425bb5bb4c205161bd6d688219cdb8db54bc069249aedee1bd06ae4d771c1d` | `65` | `65` |
| `Group_2.zip` | `759769860` | `4641d6cfc8bc9535c8ec8fe69ed45d02447b2e3420816c0b66785f56687a61a6` | `66` | `66` |
| `Group_3.zip` | `811325267` | `f4ee448f0e35ee41ee249382fb3cd6f7c0a2abb1b5774a32146a7c5f5d7e0159` | `56` | `56` |
| `Group_4.zip` | `829038308` | `57b2ebeb6775525aa2275905c8e1406c2be8c63f49ba0c5ef28019f18e8cf736` | `63` | `63` |
| `Readme.txt` | `4641` | `59489534eaa5cddd2cef74b057855d2074bbef802d3aa12db6e082f9886dc59c` |  |  |
| `EIS.zip` | `190279` | `64d1fc94dcd3b2403d3f84b88666781a4f6153068e2ef4311d7cde97106a6d27` | `119` | `117` |

## 4. Historical Bounded `.mat` Smoke

This smoke was run before the fixed train/test split. It is retained as a
historical schema-smoke record, not a current post-split evidence path. The
script now requires `--allow-legacy-presplit-mat-smoke` for historical
reproduction only.

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_mat_smoke_part1_full_perzip.json \
  --inspect-mat \
  --allow-legacy-presplit-mat-smoke \
  --max-mat-files 12 \
  --max-mat-files-per-zip 2 \
  --max-mat-bytes 26214400
```

Observed limits:

```json
{
  "max_mat_bytes": 26214400,
  "max_mat_files": 12,
  "max_mat_files_per_zip": 2
}
```

The Part 1 smoke emitted a SciPy warning while loading this archive family:

```text
MatReadWarning: Duplicate variable name "None" in stream - replacing previous
with new
```

The warning did not prevent bounded smoke completion, but it should be carried
forward into the later RPT-parser implementation.

Observed inspected entries:

| Status | Entry | Uncompressed bytes |
|---|---|---:|
| `inspected` | `Half Cell/CH_FC_POCV.mat` | `1977476` |
| `inspected` | `Half Cell/CH_HC_anode.mat` | `1324985` |
| `inspected` | `Group 1/TPG1 - Cell 15.mat` | `10525541` |
| `inspected` | `Group 1/TPG1 - Cell 20.mat` | `10495327` |
| `inspected` | `Group 2/TPG2 - Cell 3.mat` | `11149864` |
| `inspected` | `Group 2/TPG2 - Cell 4.mat` | `11341743` |
| `inspected` | `Group 3/TPG3 - Cell 10.mat` | `11992279` |
| `inspected` | `Group 3/TPG3 - Cell 11.mat` | `11966048` |
| `inspected` | `Group 4/TPG4 - Cell 12.mat` | `11276885` |
| `inspected` | `Group 4/TPG4 - Cell 18.mat` | `12177944` |
| `inspected` | `EIS/BoL/Group1_BoL_Cell15_SOC20.mat` | `1434` |
| `inspected` | `EIS/BoL/Group1_BoL_Cell15_SOC50.mat` | `1433` |

The smoke confirms that each Part 1 zip archive can be opened and that a
bounded sample of `.mat` files can be loaded. It does not inspect time-series
content for features or outcomes.

Later split caveat:

```text
Cells 3, 11, and 12 are now held-out test cells in the fixed freeze-manifest
draft. This earlier bounded smoke predates the fixed split and is treated only
as schema-level grandfathered smoke: top-level openability was checked, but no
endpoint values, features, preprocessing statistics, predictions, metrics, or
support flags were emitted.
```

## 5. Current Interpretation

Part 1 has now passed:

```text
full local file identity
zip openability
bounded per-zip .mat smoke
```

This does not satisfy the freeze-promotion thresholds by itself. The next
required information is still no-metric RPT / diagnostic structural counts:

- unique cells;
- reference-test / diagnostic-test indices per cell;
- candidate row counts under `H_count = 1`;
- feasible held-out fold counts;
- duplicate-cell reconciliation if Parts 2 and 3 are later added.

## 6. Next Step

This next step has now been completed in:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_part1_rpt_structure_count_note.md
```

The resulting no-metric count passed the pre-fixed T1-T5 count thresholds plus
the T6 public-metadata availability gate for writing a freeze-manifest draft,
with the conservative split choice falling back from protocol-group holdout to
held-out cell ID because repeated filename cell IDs occur across groups.

The next clean step is now:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md
```

That draft now exists. The next clean implementation step is the metadata-only
/ train-smoke execution script, still without held-out payload values or
metrics.

That execution scaffold, MATLAB converter-script draft, and
training-conversion runner were later executed on training cells only. The
branch then advanced to a fail-closed held-out primary runner and output
contract. The current next step is to accept the freeze manifest as frozen
before running the one-time primary command.
