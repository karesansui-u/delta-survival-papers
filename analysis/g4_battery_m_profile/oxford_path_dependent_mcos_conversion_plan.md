# Oxford Path Dependent MATLAB / MCOS Conversion Plan

Status: conversion plan plus converter-script draft. Converter not executed,
not frozen, not validation evidence, and not a support claim.

Date: 2026-04-28

## 1. Purpose

Oxford Path Dependent Part 1 passed metadata-only execution, but train-smoke is
blocked because the cycling payloads are MATLAB `table` objects stored as MCOS
objects. In the local Python environment, SciPy exposes the training payload as:

```text
MatlabOpaque
```

This plan defines the next no-peek conversion step before any primary run.

## 2. Current Block

Execution note:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_metadata_train_smoke_note.md
```

Script:

```text
analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py
```

Observed train-smoke block:

```text
Training payload is a MATLAB MCOS table exposed by scipy as MatlabOpaque;
concrete endpoint/features require a MATLAB-side or MCOS-aware conversion step.
```

The blocked train-smoke opened only this training payload:

```text
Group_2.zip / Group 2/TPG2 - Cell 4.mat
```

Held-out payloads were not opened by the metadata-only / train-smoke scaffold
after the fixed split was selected.

Pre-split caveat:

```text
Earlier bounded parser-smoke runs opened small `.mat` samples before the final
held-out split existed. Those runs emitted only top-level schema keys/shapes and
no endpoint values, features, predictions, metrics, or support flags.
```

## 3. No-Peek Conversion Boundary

Training cell IDs:

```text
4, 8, 10, 14, 15, 18, 19, 20
```

Held-out test cell IDs:

```text
3, 9, 11, 12
```

Allowed before final freeze:

```text
convert training cell IDs only
inspect training table schema
derive exact endpoint / feature field paths from training schema
run train-smoke on converted training tables
```

Forbidden before final freeze:

```text
convert held-out test cell IDs
open held-out MATLAB payload values
export held-out endpoints
export held-out features
fit preprocessing transforms using held-out payloads
emit held-out predictions or metrics
```

## 4. Converter Requirements

The converter draft now exists at:

```text
analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m
```

The training-conversion runner now exists at:

```text
analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

It is designed to:

1. require an explicit mode such as `train_smoke`;
2. hard-code or read the fixed training cell IDs only;
3. refuse to export cells `3`, `9`, `11`, or `12` in train-smoke mode;
4. unzip only the necessary Part 1 group archives to a temporary directory;
5. load `.mat` files with MATLAB;
6. verify that each loaded variable is a table;
7. write converted training tables under a git-ignored directory;
8. write a manifest with cell ID, group, diagnostic index, source archive,
   source entry, table variable name, column names, row count, and output hash;
9. avoid computing model metrics or support flags.

Suggested git-ignored output root:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke/
```

Expected MATLAB command from the repository root:

```matlab
addpath('analysis/g4_battery_m_profile/scripts');
export_oxford_part1_training_tables( ...
    'analysis/g4_battery_m_profile/data/oxford_path_dependent/part1', ...
    'analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke', ...
    'train_smoke');
```

Equivalent shell form, if MATLAB is installed:

```bash
bash analysis/g4_battery_m_profile/scripts/run_oxford_part1_training_conversion_smoke.sh
```

The runner derives the repository root from its own path, accepts `PYTHON_BIN`
and `MATLAB_BIN` overrides, writes to a staging output root first, and refuses
to write into a non-empty final `OUTPUT_ROOT`. It also supports a
`MAX_RECORDS=1` one-record MATLAB runtime sanity check before the full training
export.

Current local execution status:

```text
not executed; MATLAB is not available in the current local environment.
```

## 5. Minimal MATLAB Logic

The converter should use a pattern equivalent to:

```matlab
S = load(mat_path);
names = fieldnames(S);
assert(numel(names) == 1);
T = S.(names{1});
assert(istable(T));
writetable(T, output_csv_path);
```

The converter may write column names and row counts in the manifest. It should
not summarize endpoint values, feature distributions, or any held-out cell
payloads.

The converted CSV files themselves may contain raw training-cell values because
they are training-only payload exports under git-ignored `data/`. These files
are allowed for train-smoke development, but their values must not be copied
into checked-in notes or used to choose held-out endpoint / feature rules after
seeing validation metrics.

## 6. Train-Smoke After Conversion

After training-only conversion, the Python execution script can already accept:

```text
--converted-train-root analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke/
```

That option now exists in:

```text
analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py
```

Current converted-table behavior:

```text
validate conversion_manifest.json
reject held-out cell IDs
verify converted CSV headers and SHA256
emit column names / row counts only
emit no endpoint values, features, preprocessing statistics, predictions, or metrics
```

The next gates are:

1. read converted training tables only;
2. validate converted manifest guardrails and CSV headers/SHA256 without
   parsing values in `--converted-train-root` train-smoke;
3. draft candidate endpoint/feature columns from headers only, without CSV
   content hashes or training values;
4. human-finalize a `training_feature_smoke_schema_frozen` schema from the
   header draft, converted training schema, and public guide;
5. fit the model ladder on training rows only;
6. emit fit-success booleans, field names, and shape diagnostics;
7. emit no predictions, metrics, support flags, coefficients, or held-out
   values.

## 7. Promotion Back To Freeze

The Oxford freeze-manifest draft may be promoted to frozen only after:

1. the converter script path is fixed;
2. converter SHA256 is fixed;
3. converted training manifest identity is recorded;
4. `--train-smoke` passes on converted training tables;
5. header-only schema draft is recorded;
6. human-finalized feature schema is recorded;
7. `--training-feature-smoke` passes on converted training tables;
8. final endpoint field path is fixed;
9. final feature-column definitions are fixed;
10. final Python execution script SHA256 is fixed;
11. one-time primary command is inserted.

Only after those steps may held-out test cell IDs be converted and evaluated
once.

## 8. Demotion Rule

Oxford should be demoted to feasibility-only if:

1. MATLAB conversion cannot be made reproducible;
2. the table schema is inconsistent across training cells in a way that prevents
   one frozen endpoint rule;
3. endpoint extraction requires manual field choice after seeing held-out data;
4. no concrete pre-cutoff M/SP feature family can be extracted from training
   tables;
5. train-smoke cannot fit the frozen model ladder without changing the split or
   horizon.
