# Oxford Path Dependent Part 1 Primary Result Note

Status: one-time held-out primary completed. The frozen Oxford Part 1 battery
M/SP mapping produced a no-support result. This is not causal intervention
evidence, not repair-flow evidence, and not a universal-law claim.

Date: 2026-04-28

## 1. Frozen Command

The held-out primary was run once with:

```bash
CONFIRM_FROZEN_PRIMARY=1 \
MATLAB_BIN=/Applications/MATLAB_R2026a.app/bin/matlab \
FEATURE_SCHEMA=analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json \
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_primary.sh
```

The runner first converted held-out cells under the frozen split, then ran the
Python primary evaluation from converted training and held-out tables.

## 2. Guardrails

```text
status = primary_run_completed
heldout_payload_opened = true
metrics_emitted = true
support_flags_emitted = true
feature_extraction = transition_aggregate_v1
endpoint = next_capacity_ah
feature_schema_sha256 = 1040bf57162398ea52a9ecb1d35d20c5cc87ba9d07351859e4d8496f9d5c2f06
```

Converted held-out manifest:

```text
record_count = 82
exported_heldout_cell_ids = 3, 9, 11, 12
manifest_guardrails_checked = true
```

Model rows:

```text
train_transition_rows = 149
heldout_transition_rows = 74
heldout_rows_by_cell = {3: 18, 9: 23, 11: 17, 12: 16}
```

## 3. Primary Metrics

Primary metric: held-out RMSE for `next_capacity_ah`.

| Model | RMSE | MAE | Train rows | Test rows |
|---|---:|---:|---:|---:|
| `B0` | `0.22947947811763053` | `0.19244801403779396` | `149` | `74` |
| `B1` | `0.19677068999198952` | `0.17571237596467276` | `149` | `74` |
| `B2` | `0.20114104284396125` | `0.17293480925253552` | `149` | `74` |
| `B3` | `0.2296038662551124` | `0.18992400044551408` | `149` | `74` |
| `primary` | `0.23508673118782375` | `0.19559660122005243` | `149` | `74` |

The frozen comparison was `primary` versus `B3`. The primary RMSE is higher
than `B3`, so the frozen M/SP feature extension does not improve the strong
battery-domain baseline on this Oxford Part 1 package.

## 4. Support Flags

```text
H1_strong_incremental_support = false
H2_weak_incremental_support = false
H3_no_support = true
primary_support = false
strong_threshold_rmse = 0.21812367294235677
```

Interpretation:

```text
Oxford Path Dependent Part 1 is a closed no-support result for this frozen
battery M/SP mapping.
```

## 5. Recorded Output Hashes

Generated outputs are intentionally gitignored. Their identities are recorded
here for auditability.

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/heldout_primary/conversion_manifest.json
sha256 = a571201361bde71b512d0365dfa58ec9f715ff193fbda17a11bc965d1cf55a99

analysis/g4_battery_m_profile/replication_outputs/oxford_part1_primary_results.json
sha256 = 3441129145908006a1ae8e60b6523bd6fc41b6d5eb22d69dd075ec71ff8b4258

analysis/g4_battery_m_profile/replication_outputs/oxford_part1_primary_report.md
sha256 = 80e721cf2238b439a585a48b6790550c42f70996a99ee004c5ddb63e057c6470
```

## 6. Non-Claims

This result does not claim:

- battery M/SP support;
- causal intervention ranking;
- literal physical repair-flow measurement;
- universal-law support;
- theory failure;
- a same-archive rescue target.

The correct status is:

```text
frozen public battery M-profile primary no-support outcome
```
