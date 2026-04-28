# Oxford Path Dependent Full-Archive Identity And RPT-Parser Plan

Status: pre-freeze identity / parser-count plan. Not a freeze manifest, not
validation evidence, and not feature extraction.

Date: 2026-04-28

## 1. Purpose

This plan fixes the next Oxford Path Dependent step before any M/SP feature
extraction or primary validation.

The next step is not:

```text
fit a model
choose features
inspect performance
claim support
```

The next step is:

```text
acquire selected public archives, record exact file identities, and emit
no-metric reference-test / diagnostic-test structural counts.
```

## 2. Current Local State

Already acquired and smoke-tested:

| Part | File | Bytes | SHA256 | Status |
|---|---|---:|---|---|
| Part 1 | `Guide_to_Datafiles.pdf` | `125508` | `7431d5a7f94881e19d209452ab44820f9a0ddec0424ae930cbc2f474dead493c` | acquired |
| Part 1 | `Guide_to_Datafiles.xlsx` | `21906` | `54f8fddb5d71e9c7179ac25d45b751b12f2b413573a7f190a8ffef95135a6aa7` | acquired |
| Part 1 | `Readme.txt` | `4641` | `59489534eaa5cddd2cef74b057855d2074bbef802d3aa12db6e082f9886dc59c` | acquired |
| Part 1 | `EIS.zip` | `190279` | `64d1fc94dcd3b2403d3f84b88666781a4f6153068e2ef4311d7cde97106a6d27` | zip / `.mat` smoke passed |
| Part 1 | `Group_2.zip` | `759769860` | `4641d6cfc8bc9535c8ec8fe69ed45d02447b2e3420816c0b66785f56687a61a6` | cycling/profile parser smoke passed |

The local data directory is git-ignored:

```text
analysis/g4_battery_m_profile/data/
```

## 3. Acquisition Scope

The full identity pass should use a tiered acquisition order.

### Tier A: complete Part 1 identity

Acquire the remaining Part 1 public files:

| File | Public size | Role |
|---|---:|---|
| `Group_1.zip` | `822.4MB` | cycling/profile group |
| `Group_3.zip` | `773.7MB` | cycling/profile group |
| `Group_4.zip` | `790.6MB` | cycling/profile group |
| `Half_Cell.zip` | `8.5MB` | auxiliary chemistry / non-primary reference |

Tier A is enough to answer whether Part 1 alone has clean parser structure, but
it may not be enough for a meaningful validation split.

### Tier B: Parts 1-3 validation-geometry identity

If Tier A passes, acquire the remaining group archives and small files for
Parts 2 and 3.

Part 2:

| File | Public size | Role |
|---|---:|---|
| `Guide_to_Datafiles_2.pdf` | `110.8KB` | guide |
| `Guide_to_Datafiles_2.xlsx` | `15.0KB` | guide |
| `Readme.txt` | `5.1KB` | readme |
| `EIS.zip` | `204.8KB` | EIS smoke / auxiliary |
| `Group_1.zip` | `379.2MB` | continuation group |
| `Group_2.zip` | `376.0MB` | continuation group |
| `Group_3.zip` | `366.4MB` | continuation group |
| `Group_4.zip` | `352.8MB` | continuation group |
| `Group_5.zip` | `1.2GB` | continuous cycling group |
| `Group_6.zip` | `202.0MB` | calendar-only group |

Part 3:

| File | Public size | Role |
|---|---:|---|
| `Guide_to_Datafiles_3.pdf` | `101.5KB` | guide |
| `Guide_to_Datafiles_3.xlsx` | `13.1KB` | guide |
| `Readme.txt` | `4.6KB` | readme |
| `EIS.zip` | `111.2KB` | EIS smoke / auxiliary |
| `Group_7.zip` | `521.8MB` | cycling/profile group |
| `Group_8.zip` | `550.6MB` | cycling/profile group |
| `Group_9.zip` | `531.7MB` | cycling/profile group |
| `Group_10.zip` | `858.6MB` | cycling/profile group |

Tier B is no longer required to decide the Part 1 T1-T6 gate. It remains the
natural expansion tier if Part 1 later proves too small, too noisy, or too weak
after the frozen train-smoke / primary sequence.

## 4. Commands

Manifest-only command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output analysis/g4_battery_m_profile/replication_outputs/oxford_full_manifest_identity.json \
  --manifest-only
```

Legacy bounded `.mat` structure command:

This was a pre-split parser smoke. After the fixed train/test split, this mode
must not be rerun as new evidence; the current script requires
`--allow-legacy-presplit-mat-smoke` for historical reproduction only.

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output analysis/g4_battery_m_profile/replication_outputs/oxford_full_mat_smoke.json \
  --inspect-mat \
  --allow-legacy-presplit-mat-smoke \
  --max-mat-files 64 \
  --max-mat-files-per-zip 2 \
  --max-mat-bytes 26214400
```

The bounded `.mat` smoke is only a parser check. The global cap must be high
enough to allow at least two inspected/skipped/error statuses for every present
zip in Parts 1-3. It must not be used to choose features or endpoints.

## 5. RPT / Diagnostic Parser Count Plan

After identity and bounded `.mat` smoke pass, the next parser may emit only
structural counts.

Allowed outputs:

- unique cell identifiers;
- part / group / protocol membership per cell;
- number of `.mat` files per cell;
- number of reference-test / diagnostic-test entries per cell;
- whether capacity-like fields are present;
- whether current / voltage / time / temperature-like fields are present;
- candidate prediction-row counts under the pre-fixed horizon below;
- feasible held-out fold counts under the split rules below;
- duplicate-cell reconciliation between Parts 1 and 2.

Disallowed outputs:

- actual capacity values;
- capacity-change values;
- EOL labels;
- model metrics;
- baseline comparisons;
- learned feature importance;
- support flags;
- any choice of horizon or split based on performance.

## 6. Pre-Fixed Parser Horizon And Split Counts

The parser-count pass must use this pre-fixed horizon:

```text
H_count = 1 reference-test / diagnostic-test step
```

This means a candidate row exists for cell \(c\) at reference index \(k\) only
when \(k+1\) exists for the same cell under the same retained parser grammar.

The parser may also report availability for a secondary count-only horizon:

```text
H_count_secondary = 2 reference-test / diagnostic-test steps
```

The secondary count is for feasibility only and may not replace `H_count = 1`
after seeing counts unless a later freeze note explicitly demotes Oxford to an
exploratory / feasibility-only branch.

Split-count priority is fixed:

```text
1. held-out protocol group
2. held-out cells within protocol
3. no primary validation
```

No split may place the same physical cell on both sides of train/test.

## 7. Pre-Fixed Promotion Thresholds

Oxford may move from parser feasibility to a freeze manifest only if all of the
following thresholds are satisfied by no-metric counts:

```text
T1: at least 12 unique cells after duplicate-cell reconciliation;
T2: at least 4 retained protocol groups with at least 2 cells per retained group;
T3: at least 2 feasible held-out protocol-group folds, or at least 6 feasible
    held-out-cell folds if group-level holdout is impossible;
T4: at least 60 candidate prediction rows under H_count = 1;
T5: at least 5 candidate prediction rows in every held-out fold;
T6: public metadata indicates that all candidate M/SP feature families have
    pre-cutoff source fields or protocol metadata. This is an availability-only
    gate; concrete feature computability must still be proven by the later
    metadata-only / train-smoke script.
```

T6 no-metric family availability is fixed as:

```text
T6_buffer_available:
  at least one pre-cutoff capacity-margin or voltage-window-margin field exists.
T6_recovery_available:
  at least one pre-cutoff rest / calendar-aging / EIS / relaxation-like
  diagnostic marker exists before the prediction cutoff.
T6_reconfiguration_available:
  protocol group, cycling/calendar order, C-rate, or calendar-aging SoC metadata
  exists before the prediction cutoff.
T6_consumption_available:
  cycle count, elapsed time, throughput-like exposure, C-rate, or calendar-aging
  duration exists before the prediction cutoff.
```

The RPT-parser count may emit only booleans and field-family availability counts
for T6. It must not emit the measured values of those fields.

If any threshold fails, Oxford remains feasibility / parser infrastructure and
must not become the first primary validation package.

## 8. Planned Structural Parser Output

The next parser-count artifact should write a JSON object with at least:

```json
{
  "status": "pre-freeze no-metric structural counts",
  "h_count": 1,
  "h_count_secondary": 2,
  "unique_cells": null,
  "retained_protocol_groups": null,
  "cells_per_group": {},
  "candidate_rows_h1": null,
  "candidate_rows_h2": null,
  "heldout_group_folds": null,
  "heldout_cell_folds": null,
  "min_candidate_rows_per_fold_h1": null,
  "t6_family_availability": {
    "buffer_available": null,
    "recovery_available": null,
    "reconfiguration_available": null,
    "consumption_available": null,
    "precutoff_only": null
  },
  "duplicate_cell_reconciliation": {},
  "promotion_thresholds": {
    "T1_unique_cells_min": 12,
    "T2_groups_min": 4,
    "T2_cells_per_group_min": 2,
    "T3_group_folds_min": 2,
    "T3_cell_folds_min": 6,
    "T4_candidate_rows_h1_min": 60,
    "T5_min_rows_per_fold_h1": 5,
    "T6_required_families": [
      "buffer",
      "recovery",
      "reconfiguration",
      "consumption"
    ],
    "T6_precutoff_features_only": true
  },
  "promotion_allowed_for_freeze_manifest_draft": null,
  "promotion_caveat": "T6 is public-metadata availability only, not automated feature-computability validation."
}
```

The output must leave `promotion_allowed_for_freeze_manifest_draft` as a
threshold evaluation, not as an interpretive support claim.

## 9. Next Artifact

The planned Part 1 RPT / diagnostic structure count has now been implemented
and recorded in:

```text
analysis/g4_battery_m_profile/scripts/inspect_oxford_rpt_structure.py
analysis/g4_battery_m_profile/oxford_path_dependent_part1_rpt_structure_count_note.md
```

Part 1 satisfies the pre-fixed T1-T5 no-metric count thresholds and the T6
public-metadata availability gate under conservative duplicate-cell
reconciliation. The next artifact now exists:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md
```

That artifact remains below validation evidence. The metadata-only /
train-smoke execution script now also exists and records an MCOS-table block.
The no-peek MATLAB / MCOS conversion plan, converter-script draft, and
training-conversion runner now also exist. The next step is to execute the
runner in a MATLAB environment on training cells only; the one-time primary run
remains blocked until the draft is promoted to frozen with final
converter/script SHA and command.
