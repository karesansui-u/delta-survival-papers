# G4 Battery M-Profile Branch

Status: Oxford Part 1 one-time held-out primary completed with a no-support
outcome for the frozen battery M/SP mapping. It is also a weak-axis audit:
the added M/SP coordinates were too close to ordinary battery state proxies to
serve as a strong independent `baseline + SP` test. Not causal intervention
evidence, not repair-flow evidence, and not a universal-law claim.

Date: 2026-04-28

Purpose:

Open a non-software, non-CSP physical degradation branch for the M-side
component decomposition:

```text
M_buffer / M_recovery / M_reconfiguration
```

The first target is not causal intervention ranking. The first clean target is
predictive:

```text
Does a frozen battery M/SP feature set improve out-of-sample prediction over a
strong battery-domain baseline?
```

After the Oxford Part 1 result, the battery branch should treat the maintained
structure as a future service-envelope rather than capacity alone:

```text
V_k = future operating paths that can still deliver the required service over
      horizon H without crossing capacity, voltage, temperature, or safety
      boundaries.
```

Capacity remains an important proxy, but not the structure itself. Future
battery v2 attempts should define margin, recovery, and reconfiguration
features against this service-envelope and should pass an SP-axis independence
gate before primary promotion.

If this passes on a real public battery dataset, then a later branch can ask a
harder question:

```text
Can the M-profile predict which operating protocol or mitigation family should
rank higher?
```

## Files

| File | Role |
|---|---|
| `battery_m_profile_validation_design.md` | Main branch design and validation logic |
| `candidate_dataset_ranking.md` | Public dataset ranking and first target recommendation |
| `oxford_path_dependent_feasibility_note.md` | Exact web-feasibility note for Oxford Path Dependent Parts 1-3 |
| `oxford_path_dependent_parser_smoke_plan.md` | Pre-freeze local archive/parser smoke plan |
| `oxford_path_dependent_part1_smallfile_smoke_note.md` | First local Part 1 guide/readme + EIS one-zip manifest-smoke note |
| `oxford_path_dependent_part1_group2_smoke_note.md` | First local Part 1 cycling/profile group parser-smoke note |
| `oxford_path_dependent_freeze_design_decision_note.md` | Pre-freeze decision note for whether Oxford can become a validation package |
| `oxford_path_dependent_full_archive_identity_plan.md` | Acquisition and no-metric RPT-parser count plan before any freeze |
| `oxford_path_dependent_part1_full_identity_note.md` | Complete local Part 1 file identity and bounded per-zip `.mat` smoke note |
| `oxford_path_dependent_part1_rpt_structure_count_note.md` | No-metric Part 1 RPT / diagnostic structure count and T1-T6 gate result |
| `oxford_path_dependent_freeze_manifest_draft.md` | Oxford Part 1 freeze-manifest draft for weak predictive validation |
| `oxford_path_dependent_metadata_train_smoke_note.md` | Metadata-only pass and train-smoke MCOS-table block note |
| `oxford_path_dependent_mcos_conversion_plan.md` | No-peek MATLAB / MCOS conversion plan for training cells first |
| `oxford_path_dependent_mcos_converter_script_note.md` | MATLAB converter-script draft and converted-table interface note, not locally executed |
| `oxford_path_dependent_mcos_converter_execution_note.md` | MATLAB execution packet note for training conversion |
| `oxford_path_dependent_training_feature_smoke_plan.md` | Next-gate plan for training-only endpoint/feature extraction and model fit smoke |
| `oxford_path_dependent_training_conversion_and_feature_smoke_result_note.md` | Training-only MATLAB conversion / schema draft / feature-smoke pass note |
| `oxford_path_dependent_primary_result_note.md` | One-time held-out primary no-support result note |
| `oxford_part1_training_feature_schema_frozen.json` | Human-finalized frozen feature schema used by the training smoke and one-time primary |
| `preregistration_draft.md` | Future freeze/preregistration skeleton |
| `scripts/inspect_oxford_path_dependent.py` | Manifest / `.mat` structure smoke script for Oxford Path Dependent |
| `scripts/inspect_oxford_rpt_structure.py` | No-metric RPT / diagnostic structure count script |
| `scripts/evaluate_oxford_part1_m_profile.py` | Oxford Part 1 metadata-only / train-smoke / training-feature-smoke / confirmed primary evaluator |
| `scripts/export_oxford_part1_training_tables.m` | MATLAB converter for `train_smoke` and frozen `heldout_primary` modes |
| `scripts/run_oxford_part1_training_conversion_smoke.sh` | MATLAB converter + Python converted-smoke runner |
| `scripts/draft_oxford_training_feature_schema.py` | Header-only training schema draft helper |
| `scripts/run_oxford_part1_training_schema_draft.sh` | Runner for header-only training schema draft |
| `scripts/run_oxford_part1_training_feature_smoke.sh` | Training-only endpoint/feature smoke runner after converted-smoke |
| `scripts/run_oxford_part1_primary.sh` | One-time held-out primary runner, guarded by `CONFIRM_FROZEN_PRIMARY=1` |
| `scripts/test_oxford_converted_manifest_guardrails.py` | Synthetic negative tests for converted-manifest no-peek guardrails |
| `scripts/test_oxford_training_schema_draft_contract.py` | Synthetic contract tests for header-only schema drafting |
| `scripts/test_oxford_training_feature_smoke_contract.py` | Synthetic contract tests for training-feature smoke |
| `scripts/test_oxford_primary_contract.py` | Synthetic contract tests for the one-time primary runner |

## Current Recommendation

The first branch should start with a battery dataset that has:

- repeated cells or packs;
- explicit time / cycle index;
- capacity or life endpoint;
- controlled operating protocol differences;
- enough metadata to define M/SP features before the primary run.

The strongest initial candidates are:

1. Oxford Path Dependent Battery Degradation Dataset;
2. NASA Randomized and Recommissioned Battery Dataset;
3. MIT-Stanford/TRI fast-charging battery cycle-life dataset.

The Oxford Path Dependent exact web-feasibility note is now open. Its current
status is positive feasibility with an explicit small-sample warning, not
validation evidence. Part 1 has now also passed the no-metric RPT / diagnostic
structure-count gate for writing a freeze-manifest draft. T6 is availability
only at this stage; concrete feature computability still belongs to the
metadata-only / train-smoke script.

The MATLAB training conversion, converted-smoke, header-only schema draft, and
training-feature smoke have now passed. The feature smoke uses
`transition_aggregate_v1` because the converted table headers do not expose a
direct capacity column; `next_capacity_ah` is derived from `max(Amphr)` at
diagnostic index `k + 1`, while features use diagnostic index `k` aggregates
only.

Recorded training-only result:

```text
converted record_count = 168
training transition rows = 149
B0/B1/B2/B3/primary fit-smoke = pass
heldout_payload_opened = false
metrics_emitted = false
support_flags_emitted = false
primary_blocked = true
```

The one-time held-out primary has now been run. It produced a no-support
outcome for this frozen Oxford Part 1 battery M/SP mapping:

```text
B3 RMSE = 0.2296038662551124
primary RMSE = 0.23508673118782375
H1_strong_incremental_support = false
H2_weak_incremental_support = false
H3_no_support = true
primary_support = false
```

This closes Oxford Part 1 as a public battery M-profile no-support outcome. It
does not refute the theoretical core and should not be rescued on the same
archive.

Historical / reproducibility helpers:

Draft header-only candidates with:

```bash
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_schema_draft.sh
```

The draft is a non-runnable template. The checked-in schema was
human-finalized into `training_feature_smoke_schema_frozen` using only the
header draft, converted training schema, and public guide information. The
training-feature smoke can be rerun with:

```bash
FEATURE_SCHEMA=analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_feature_smoke.sh
```

The converted-manifest guardrails can be checked without MATLAB by running:

```bash
python3 analysis/g4_battery_m_profile/scripts/test_oxford_converted_manifest_guardrails.py
```

The header-only schema drafting contract can be checked without MATLAB by
running:

```bash
python3 analysis/g4_battery_m_profile/scripts/test_oxford_training_schema_draft_contract.py
```

The training-feature smoke contract can be checked without MATLAB by running:

```bash
python3 analysis/g4_battery_m_profile/scripts/test_oxford_training_feature_smoke_contract.py
```

The primary runner contract can be checked without MATLAB by running:

```bash
python3 analysis/g4_battery_m_profile/scripts/test_oxford_primary_contract.py
```

Do not rerun the Oxford Part 1 primary as a new primary on the same archive.
Any future execution must be labeled as a rerun.

The checked-in result note is now used as a sentinel. The primary runner and
direct evaluator refuse another primary-labeled execution after the result note
exists unless rerun mode and rerun-labeled paths are explicitly supplied.

NASA Randomized/Recommissioned is a strong second candidate if exact archive
access and parsing are clean.
