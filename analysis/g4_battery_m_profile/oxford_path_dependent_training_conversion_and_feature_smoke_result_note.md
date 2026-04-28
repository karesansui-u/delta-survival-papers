# Oxford Path Dependent Training Conversion And Feature-Smoke Result Note

Status: training-only conversion / schema draft / feature-smoke pass. Not
frozen, not validation evidence, not held-out primary evidence, and not a
support claim.

Date: 2026-04-28

## 1. Executed Gates

Executed in order:

1. MATLAB training-cell conversion runner;
2. Python converted train-smoke guardrail check;
3. header-only schema draft;
4. human-finalized training-feature smoke schema;
5. training-only feature extraction and model-fit smoke.

Held-out test cell IDs remained blocked:

```text
3, 9, 11, 12
```

Training cell IDs converted:

```text
4, 8, 10, 14, 15, 18, 19, 20
```

## 2. MATLAB Conversion Result

Runner:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

MATLAB:

```text
/Applications/MATLAB_R2026a.app/bin/matlab
Trial License
```

Result:

```text
status = converted_train_smoke_manifest_checked
converted record_count = 168
expected_training_entry_count = 168
missing_training_cell_ids = []
unreferenced_csv_count = 0
heldout_payload_opened = false
metrics_emitted = false
support_flags_emitted = false
primary_blocked = true
promotion_eligible_converted_smoke = true
```

Implementation notes:

- `MAX_RECORDS=1` partial sanity passed first.
- MATLAB zip-entry extraction was switched to `/usr/bin/unzip -p` for the
  selected training entry only after MATLAB's Java byte-array bridge produced
  unreadable MAT payloads on macOS.
- MATLAB-side CSV SHA256 computation was switched to `/usr/bin/shasum -a 256`
  after the Java digest path disagreed with Python.
- The converter now selects the expected table variable name, e.g.
  `TPG4_Cell18`, because at least one training `.mat` payload contained an
  additional unrelated table.

## 3. Schema Draft Result

Header-only schema draft:

```text
status = training_feature_schema_header_draft
record_count = 168
metrics_emitted = false
support_flags_emitted = false
primary_blocked = true
```

Important finding:

```text
No direct capacity-like column exists in the converted table headers.
```

The converted tables expose time-series columns such as:

```text
Cyc, Step, TestTime, StepTime, Amphr, Watthr, Amps, Volts, Temp1
```

Therefore the feature-smoke schema uses transition-level aggregation rather
than direct raw-column prediction.

## 4. Training Feature-Smoke Result

Schema:

```text
analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json
```

Feature extraction:

```text
transition_aggregate_v1
```

Endpoint:

```text
next_capacity_ah
```

Endpoint construction:

```text
next_capacity_ah = max(Amphr) from diagnostic index k + 1
```

Feature construction:

```text
features use only diagnostic index k aggregates and fixed metadata
```

Feature-smoke result:

```text
status = training_feature_smoke_passed
transition rows = 149
heldout_payload_opened = false
metrics_emitted = false
support_flags_emitted = false
primary_blocked = true
promotion_eligible_for_freeze_manifest = false
```

Model-ladder fit smoke:

| Model | Row count | Input features | Transformed features | Fit |
|---|---:|---:|---:|---|
| `B0` | `149` | `0` | `0` | pass |
| `B1` | `149` | `1` | `1` | pass |
| `B2` | `149` | `2` | `2` | pass |
| `B3` | `149` | `12` | `12` | pass |
| `primary` | `149` | `15` | `15` | pass |

## 5. Recorded Training-Only Artifact Hashes

The script hashes below record the training-only execution state for this note.
A later freeze-promotion patch may change current script hashes to add the
held-out primary runner; those later hashes belong in the freeze manifest.

```text
export_oxford_part1_training_tables.m
sha256 = fcd33e717e3e877b0f62c3507c72602719ac5794bfbabb61335a295aeaba4d0a

evaluate_oxford_part1_m_profile.py
sha256 = e098ee7b14c00e3c90dd27edc5006fbebd94af7d2c8022fd83c77d9c96a9a204

conversion_manifest.json
sha256 = 735954d4410095f2aba732bc3af684ee286754a5baebe54779e0b34b3de58798

oxford_part1_converted_train_smoke.json
sha256 = 6e61b3bd24eb36c187a38f8a4f4320bdcc6077c89dd91fe78e137f3d377bde53

oxford_part1_training_schema_draft.json
sha256 = f497107023ae089499d85d4884dc3306b7fe1651eff385fe9b90caa20d926678

oxford_part1_training_feature_schema_frozen.json
sha256 = 1040bf57162398ea52a9ecb1d35d20c5cc87ba9d07351859e4d8496f9d5c2f06

oxford_part1_training_feature_smoke.json
sha256 = c6613cef1d78bc980f3e6b55ca92abc0da30a8ab301221d3dcb80228ecde1de5
```

## 6. Non-Claims

This note does not claim:

- held-out validation;
- primary support;
- weak support;
- no-support;
- battery intervention evidence;
- a repair-flow result;
- any metric improvement over baseline.

The next gate is operational: if the freeze manifest is accepted as frozen,
run the one-time held-out primary command. Until then, held-out conversion and
held-out evaluation remain unrun.
