# Oxford Path Dependent Part 1 Battery M-Profile Freeze Manifest Draft

Status: freeze-manifest draft and one-time primary command record. The command
has now been executed once; the held-out result is recorded in
`oxford_path_dependent_primary_result_note.md`.

Date opened: 2026-04-28

Branch:

```text
G4 Battery M-Profile Predictive Validation
```

## 1. Boundary

This draft records the intended freeze package for Oxford Path Dependent Part 1
after the no-metric RPT / diagnostic structure-count gate passed.

It may be promoted to a frozen manifest only after:

1. the execution script exists;
2. the MATLAB training conversion and strict converted-manifest/header smoke
   pass for all training cell IDs;
3. the header-only schema draft is recorded without reading training values;
4. the endpoint and feature schema is human-finalized from public guide/schema
   metadata plus training schema only;
5. the training-only endpoint/feature extraction and model-fit smoke passes;
6. metadata-only and train-smoke modes run without held-out payload values,
   held-out endpoints, held-out features, preprocessing statistics,
   predictions, or metrics;
7. the final converter/script SHA256 and one-time primary command are inserted.

Until then, this document is not a primary-run authorization.

T6 caveat:

```text
T6 public-metadata availability has now been followed by training-only
feature-computability smoke. This is still not held-out validation.
```

## 2. Supporting Notes

- `analysis/g4_battery_m_profile/README.md`
- `analysis/g4_battery_m_profile/battery_m_profile_validation_design.md`
- `analysis/g4_battery_m_profile/candidate_dataset_ranking.md`
- `analysis/g4_battery_m_profile/preregistration_draft.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_feasibility_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_parser_smoke_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_smallfile_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_group2_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_freeze_design_decision_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_full_archive_identity_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_full_identity_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_rpt_structure_count_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_metadata_train_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_mcos_conversion_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_mcos_converter_script_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_mcos_converter_execution_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_training_feature_smoke_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_training_conversion_and_feature_smoke_result_note.md`
- `analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json`

## 3. Public Dataset Identity

Dataset:

```text
Oxford Path Dependent Battery Degradation Dataset
Part 1
DOI: 10.5287/bodleian:v0ervBv6p
```

Source record:

```text
https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e
```

## 4. Required Local Files

Frozen candidate scope:

```text
Part 1 only
```

Primary group archives:

| File | Bytes | SHA256 | Role |
|---|---:|---|---|
| `Group_1.zip` | `862297104` | `72425bb5bb4c205161bd6d688219cdb8db54bc069249aedee1bd06ae4d771c1d` | cycling/profile group |
| `Group_2.zip` | `759769860` | `4641d6cfc8bc9535c8ec8fe69ed45d02447b2e3420816c0b66785f56687a61a6` | cycling/profile group |
| `Group_3.zip` | `811325267` | `f4ee448f0e35ee41ee249382fb3cd6f7c0a2abb1b5774a32146a7c5f5d7e0159` | cycling/profile group |
| `Group_4.zip` | `829038308` | `57b2ebeb6775525aa2275905c8e1406c2be8c63f49ba0c5ef28019f18e8cf736` | cycling/profile group |

Required guide / metadata files:

| File | Bytes | SHA256 | Role |
|---|---:|---|---|
| `Guide_to_Datafiles.pdf` | `125508` | `7431d5a7f94881e19d209452ab44820f9a0ddec0424ae930cbc2f474dead493c` | public guide |
| `Guide_to_Datafiles.xlsx` | `21906` | `54f8fddb5d71e9c7179ac25d45b751b12f2b413573a7f190a8ffef95135a6aa7` | public guide |
| `Readme.txt` | `4641` | `59489534eaa5cddd2cef74b057855d2074bbef802d3aa12db6e082f9886dc59c` | public readme |

Auxiliary files:

| File | Bytes | SHA256 | Role |
|---|---:|---|---|
| `EIS.zip` | `190279` | `64d1fc94dcd3b2403d3f84b88666781a4f6153068e2ef4311d7cde97106a6d27` | optional pre-cutoff recovery-like diagnostic family |
| `Half_Cell.zip` | `8926444` | `43682be83c416f12e046ba97ee7d45b3b311615e0ef4b93c243e3f3462ec4dcd` | auxiliary chemistry reference; not primary by default |

The frozen local data root slot is:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent/part1/
```

The data directory is git-ignored and must not be committed.

## 5. Parser-Count Gate Already Passed

The no-metric RPT / diagnostic structure count used only zip entry names and
public guide/readme metadata.

Observed Part 1 gate counts:

| Quantity | Count |
|---|---:|
| Unique filename cell IDs | `12` |
| Group-cell series | `14` |
| Retained protocol groups | `4` |
| Candidate rows under `H_count = 1` | `223` |
| Candidate rows under `H_count_secondary = 2` | `222` |
| Safe held-out protocol-group folds | `1` |
| Safe held-out cell-ID folds | `12` |
| Minimum H1 rows per safe cell-ID fold | `14` |

T1-T6 status:

```text
T1-T5 true by filename structure counts;
T6 true only as public-metadata availability assertion
```

Interpretation:

```text
Part 1 may advance to a freeze-manifest draft.
```

Non-interpretation:

```text
This is not validation evidence.
```

## 6. Unit, Time, Horizon, And Split

Unit:

```text
filename cell ID
```

Series:

```text
group-cell diagnostic series
```

Time index:

```text
diagnostic / reference-test filename index k
```

Primary horizon:

```text
H = 1 diagnostic / reference-test index step
```

Candidate prediction row:

```text
row exists for group-cell series (g, c) at index k only when index k + 1
exists for the same group-cell series.
```

Primary split:

```text
fixed held-out cell-ID split
```

Held-out test cell IDs:

```text
3, 9, 11, 12
```

Training cell IDs:

```text
4, 8, 10, 14, 15, 18, 19, 20
```

No-metric selection rule:

```text
choose the lowest non-duplicated filename cell ID from each retained protocol
group when possible, then sort the resulting held-out IDs.
```

This gives one held-out representative from each of the four protocol groups
without placing repeated filename cell IDs (`10`, `15`) in the held-out set.

Count-only row geometry under `H = 1`:

| Split | Cell IDs | H1 candidate rows |
|---|---|---:|
| train | `4, 8, 10, 14, 15, 18, 19, 20` | `149` |
| test | `3, 9, 11, 12` | `74` |

If the later endpoint parser reduces any retained test cell below the T5
row-count minimum, this draft must be demoted or rewritten before primary
evaluation.

Pre-split schema-smoke caveat:

```text
Before this fixed train/test split was selected, earlier bounded parser-smoke
runs opened small `.mat` samples, including some cells that are now in the test
set, but emitted only top-level keys/shapes and no endpoint values, features,
preprocessing statistics, predictions, metrics, or support flags.
```

Evidence contract for this branch:

```text
This is not an untouched-test-archive claim. It is a value/endpoint/feature/
metric no-peek claim. From this freeze-manifest draft onward, held-out test
payloads remain sealed until the final frozen primary command.
```

Conservative duplicate-cell rule:

```text
If a filename cell ID appears in more than one group, all rows for that cell ID
are held out together.
```

Known repeated filename cell IDs:

| Cell ID | Groups |
|---|---|
| `10` | `2`, `3` |
| `15` | `1`, `3` |

Protocol-group holdout is not the primary split because only `1` protocol group
is safe after the duplicate-cell leakage check.

## 7. Endpoint Slot

Primary endpoint class:

```text
future diagnostic capacity-like scalar at k + 1
```

The final frozen manifest must replace this slot with the exact guide/schema
field path used by the execution script.

Frozen training-feature smoke endpoint:

```text
next_capacity_ah
```

Frozen training-feature extraction:

```text
transition_aggregate_v1
```

Operational construction:

```text
next_capacity_ah = max(Amphr) from diagnostic index k + 1
features = diagnostic index k aggregates plus fixed group / diagnostic metadata
```

Reason:

```text
The converted table headers do not expose a direct capacity column.
```

Allowed endpoint rule:

```text
The endpoint may use only the guide-defined capacity / usable-capacity scalar
for the same group-cell series at diagnostic index k + 1.
```

Disallowed endpoint rules:

- choosing among multiple capacity-like fields after seeing model metrics;
- using post-cutoff rebound / recovery values to define the label;
- changing from future capacity to capacity drop after primary metrics are
  visible;
- using any held-out fold statistics to choose the endpoint.

If the metadata parser cannot identify exactly one suitable capacity-like
endpoint before feature extraction, this branch must remain feasibility-only or
be demoted to a new preregistration.

## 8. Feature Cutoff Rule

For a prediction row at diagnostic index \(k\):

```text
features may use only data at diagnostic indices <= k and public protocol
metadata known before k.
```

Forbidden:

```text
any value from diagnostic index k + 1 or later
```

Every preprocessing transform must be fit on the fixed training cell IDs only
and applied to the held-out test cell IDs.

The endpoint column must not appear in any model feature list. In particular,
the future diagnostic capacity-like scalar at \(k+1\) is a label only and
cannot be reused as an input feature for B1/B2/B3/primary.

## 9. Baseline Ladder

`B0`:

```text
training-fold mean endpoint
```

`B1`:

```text
diagnostic index k only
```

`B2`:

```text
diagnostic index k + protocol / group metadata available before k
```

`B3`:

```text
B2 + standard battery-domain degradation features available before k
```

Candidate B3 families:

- diagnostic index and protocol group metadata available before k;
- current diagnostic `max(Amphr)` at k;
- current diagnostic `max(Watthr)` at k;
- current diagnostic duration from `TestTime` at k;
- current diagnostic absolute-current summaries from `Amps` at k;
- current diagnostic voltage summaries from `Volts` at k;
- current diagnostic temperature summaries from `Temp1` at k.

Primary:

```text
B3 + frozen battery M/SP feature set
```

The primary model may not win by moving a standard battery predictor out of B3
and renaming it as an M/SP feature.

## 10. Candidate M/SP Feature Families

The final execution script must freeze concrete feature names before the
primary run. This draft freezes only the allowed family boundaries.

`M_buffer` candidate family:

- `m_buffer_capacity_ah`;
- `m_buffer_voltage_min`.

`M_recovery` candidate family:

- `m_recovery_voltage_tail_minus_min`.

`M_reconfiguration` candidate family:

- no additional primary-only feature in the current smoke schema;
- protocol / group metadata is kept in B2/B3 to avoid winning by rebranding a
  standard battery-domain predictor as M/SP.

`SP_balance` candidate family:

- fixed interactions between consumption-side exposure and M-side availability;
- fixed ratios or products defined before seeing held-out metrics.

All M/SP features must be computable at or before index k. No feature may use
capacity improvement from k to k + 1.

Frozen training-feature smoke schema:

```text
analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json
sha256 = 1040bf57162398ea52a9ecb1d35d20c5cc87ba9d07351859e4d8496f9d5c2f06
```

## 11. Model Class

Primary model family:

```text
sklearn Ridge regression
alpha = 1.0
fit_intercept = True
random_state = not applicable
```

Preprocessing:

```text
standardize numeric predictors using training-fold mean and population
standard deviation only;
one-hot encode categorical predictors using training-fold categories only;
handle unknown held-out categories as all-zero indicators;
apply no sample weighting and no fold rebalancing.
```

If the final endpoint is binary rather than continuous, this draft is invalid
and must be replaced by a new freeze manifest before any primary run.

## 12. Metrics

Primary metric:

```text
RMSE aggregated over all held-out rows from the fixed test cell IDs
```

Secondary metrics:

- MAE aggregated over all held-out rows;
- per-cell RMSE summary over the four held-out test cell IDs;
- train/test candidate-row count diagnostics.

No metric may be used to change endpoint, features, model class, horizon, or
split after freeze.

## 13. Decision Rules

H1 strong incremental support:

```text
RMSE(primary) <= 0.95 * RMSE(B3)
```

H2 weak incremental support:

```text
RMSE(primary) < RMSE(B3)
```

H3 no-support:

```text
RMSE(primary) >= RMSE(B3)
```

H4 non-claim guardrail:

```text
No result permits a causal intervention-ranking, direct repair-flow, or
universal-law claim.
```

Report interpretation:

| Outcome | Interpretation |
|---|---|
| H1 true | strong incremental predictive support on this frozen Oxford Part 1 package |
| H1 false and H2 true | weak incremental predictive support only |
| H3 true | no-support for this frozen battery M/SP mapping |
| endpoint / feature extraction not uniquely definable | silence / demotion before primary |

## 14. Execution Script Slot

Planned script path:

```text
analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py
```

Current scaffold status:

```text
metadata-only passes; raw train-smoke is blocked by MATLAB MCOS table payloads;
MATLAB training conversion passed; converted-table train-smoke passed;
header-only schema draft passed; transition-aggregate training-feature smoke
passed on Oxford training cells.
```

Converter draft:

```text
analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m
```

Training conversion runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

Training feature-smoke runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_schema_draft.sh
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_feature_smoke.sh
```

Held-out primary runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_primary.sh
```

Converter execution status:

```text
executed locally with MATLAB R2026a trial on training cells only
```

Required execution modes:

```text
--metadata-only
--train-smoke
--training-feature-smoke
--allow-primary-run  # fail-closed until this manifest is promoted
```

Mode boundaries:

| Mode | Allowed output |
|---|---|
| `--metadata-only` | file identity, parser counts, selected endpoint field name, fold counts; no MATLAB payload values |
| `--train-smoke` | training cell-ID payloads only, or training-only converted manifest / CSV-header/SHA256 validation via `--converted-train-root`; no held-out payload values, endpoints, features, preprocessing statistics, predictions, or metrics |
| `--training-feature-smoke` | converted training tables only; selected field paths, feature-column names, and fit-success/shape diagnostics only; no held-out values, predictions, metrics, support flags, coefficients, or preprocessing statistics |
| `--allow-primary-run` | fail-closed unless `--confirm-frozen-primary`, converted train/test roots, and frozen feature schema are supplied; emits one-time held-out metrics/support only in the frozen primary command |

Final script SHA256:

```text
evaluate_oxford_part1_m_profile.py
sha256 = 34f239de2452208ded58a10ca14c3a5862c18a0b2b1b7808ff273434f8915aea

export_oxford_part1_training_tables.m
sha256 = db793e04a5c04d79273959e411a3468e39fdd98f209b5ff0a0b15f7ab60c7210

run_oxford_part1_primary.sh
sha256 = 4093e81c8db9aeabec2c704dc85f87889cc7acee41f78432b3358b1112a57b1c
```

## 15. Output Paths

The execution script must write generated outputs under:

```text
analysis/g4_battery_m_profile/replication_outputs/
```

Expected output names:

```text
oxford_part1_metadata_only.json
oxford_part1_train_smoke.json
oxford_part1_converted_train_smoke.json
oxford_part1_training_schema_draft.json
oxford_part1_training_feature_smoke.json
oxford_part1_primary_results.json
oxford_part1_primary_report.md
```

Training-only output identities:

```text
conversion_manifest.json
sha256 = 735954d4410095f2aba732bc3af684ee286754a5baebe54779e0b34b3de58798

oxford_part1_converted_train_smoke.json
sha256 = 6e61b3bd24eb36c187a38f8a4f4320bdcc6077c89dd91fe78e137f3d377bde53

oxford_part1_training_schema_draft.json
sha256 = f497107023ae089499d85d4884dc3306b7fe1651eff385fe9b90caa20d926678

oxford_part1_training_feature_smoke.json
sha256 = c6613cef1d78bc980f3e6b55ca92abc0da30a8ab301221d3dcb80228ecde1de5
```

The `replication_outputs/` directory is git-ignored by default. Only summary
notes should be checked in unless a later replication package intentionally
freezes compact JSON outputs.

## 16. One-Time Primary Command Slot

Frozen primary command:

```bash
CONFIRM_FROZEN_PRIMARY=1 \
MATLAB_BIN=/Applications/MATLAB_R2026a.app/bin/matlab \
FEATURE_SCHEMA=analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_primary.sh
```

This command was the first held-out conversion/evaluation authorization and
has been run once for the current frozen Oxford Part 1 package. Later reruns,
if any, must be explicitly labeled as reruns.

## 17. Non-Claims

This draft does not claim:

1. Oxford supports the theory;
2. battery M/SP features improve prediction;
3. battery `M_recovery` is literal physical repair;
4. protocol metadata identifies a causal intervention ranking;
5. Part 1 establishes a universal M law;
6. a no-support result would refute the theoretical core.

The only claim currently allowed is:

```text
Oxford Path Dependent Part 1 has enough no-metric structure to write a
leakage-aware freeze-manifest draft.
```

## 18. Next Step

The no-peek MATLAB / MCOS conversion, converted-smoke, header-only schema
draft, and training-feature smoke have all passed on training cells only.

The held-out primary runner and output contract are implemented and covered by
synthetic contract tests. The one-time primary command above has now been run.
The next step is to use the result note as the evidence record.

Oxford Part 1 now has a held-out no-support status for this frozen battery
M/SP mapping.
