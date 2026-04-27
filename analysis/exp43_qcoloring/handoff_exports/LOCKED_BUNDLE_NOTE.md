# Exp43c Locked Bundle Note

Date: 2026-04-27

This folder contains the current distribution-facing Exp43c true outside-group
rerun bundle.

## Current Distribution-Facing Bundle

- file:
  `exp43c_true_outside_bundle_40517dfb4b61.zip`
- sha256:
  `9370031f6554a3da0f3dcb47dd4fb0e791749d0266de8120289f41c305efdc93`
- exported from commit short:
  `40517dfb4b61`
- exported from commit full:
  `40517dfb4b61af72722a55281998408aaf1cbbe4`
- approximate size:
  `1.1M`

## Sidecar Files

- `exp43c_true_outside_bundle_40517dfb4b61.zip.sha256`
- `exp43c_true_outside_bundle_40517dfb4b61.manifest.txt`

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
python3 analysis/exp43_qcoloring/src/primary_manifest.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl --check-only
python3 analysis/exp43_qcoloring/src/pilot_runner.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl dry-run
```

Both passed and reported:

```text
phase: exp43c_primary
planned instances: 4000
cells: 20
```

## Operational Rule

Do not rebuild, replace, or resend another Exp43c zip under this directory
without first creating a new commit-specific filename and updating this locked
bundle note.
