# Exp43c Locked Bundle Note

Date: 2026-04-27

This folder contains the current distribution-facing Exp43c true outside-group
rerun bundle.

## Current Distribution-Facing Bundle

- file:
  `exp43c_true_outside_bundle_1f05ff13211a.zip`
- sha256:
  `a294a1e9aa6c639fe20412c98c412a5d2d858761513b4c48b8c37108a4b67570`
- exported from commit short:
  `1f05ff13211a`
- exported from commit full:
  `1f05ff13211acddf5246c758c1411197933f31e1`
- approximate size:
  `1.1M`

## Sidecar Files

- `exp43c_true_outside_bundle_1f05ff13211a.zip.sha256`
- `exp43c_true_outside_bundle_1f05ff13211a.manifest.txt`

## Included Official Reference Artifacts

The bundle includes the official Exp43c reference artifacts because
`analysis/exp43_qcoloring/data/` is gitignored and cannot be assumed present in
a fresh public clone.

Reference hashes:

| File | sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

## Local Verification

The generated zip was unpacked under `/tmp` and checked with:

```text
python3 --version
python3 -c "from pathlib import Path; Path('analysis/exp43_qcoloring/external_outputs').mkdir(parents=True, exist_ok=True)"
python3 analysis/exp43_qcoloring/src/primary_manifest.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl --check-only
python3 analysis/exp43_qcoloring/src/pilot_runner.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl dry-run
python3 analysis/exp43_qcoloring/src/primary_manifest.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl
python3 analysis/exp43_qcoloring/src/evaluate_primary.py analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_evaluation_from_reference_check.json
```

The preflight commands passed and reported:

```text
phase: exp43c_primary
planned instances: 4000
cells: 20
```

The generated manifest hash matched the official manifest hash exactly:

```text
e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
```

The evaluator run against the included official result JSONL reproduced the
official evaluation JSON hash exactly:

```text
901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
```

After the command-surface correction, the generated zip was also unpacked under
`/tmp` and exercised through the full 4000-instance solver rerun with:

```text
python3 analysis/exp43_qcoloring/src/pilot_runner.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl run --execute
python3 analysis/exp43_qcoloring/src/evaluate_primary.py analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_evaluation_external.json
```

The full local bundle rerun completed with:

```text
manifest rows: 4000
result rows: 4000
SAT: 2003
UNSAT: 1997
core-field mismatches against official results: 0
```

The generated external manifest and evaluation matched the official reference
hashes exactly:

```text
manifest sha256: e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
evaluation sha256: 901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
```

The generated external result JSONL hash differed from the official result
JSONL hash because runtime-sensitive fields are regenerated on rerun, but the
checked core fields matched row-by-row:

```text
external result sha256: 13844494a3e4fdf9bb858b8aa9011fff1658cb20dd2f8702ed08bdf177edc7f2
official result sha256: 37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b
checked fields: instance_id, q, n, rho_fm, seed_digest, edge_list_hash, q_colorable, status, coloring_verified
```

This hardened bundle keeps `手順書.md` as the primary receiver entry point,
keeps `RUN_INSTRUCTIONS_JA.md` only as an ASCII filename copy, explicitly tells
recipients to run each command as one line, and supports plain Windows
`cmd` / PowerShell through `py -3` when `python` is not Python 3. WSL is not
required if `py -3` points to Python 3.10 or later.

## Operational Rule

Do not rebuild, replace, or resend another Exp43c zip under this directory
without first creating a new commit-specific filename and updating this locked
bundle note.
