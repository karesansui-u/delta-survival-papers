# Exp43c External Rerun Package Note

Status: external-replication packaging note. Not a new empirical result and
not validation evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g7_exp43c_replication_package_plan.md`
- `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`
- `analysis/exp43_qcoloring/exp43c_freeze_package.md`

Purpose:

Define the exact external rerun package shape for Exp43c after the local fresh
rerun is complete.

This note is about what to hand to an outside replicator. It does not change
the frozen Exp43c design.

## 1. Current Replication Status

Exp43c now has:

1. official frozen primary package;
2. local fresh rerun complete;
3. exact manifest match to the official package;
4. exact evaluation-JSON match to the official package;
5. external independent rerun still open.

So the next clean G7 move is:

```text
package Exp43c so an outside replicator can rerun the frozen threshold-local
primary without touching official artifacts
```

## 2. Package Boundary

The external rerun package should contain only the files required to:

1. understand the frozen design;
2. regenerate the manifest;
3. run the primary solver pipeline;
4. evaluate the rerun against the official reference.

It should not contain:

- Exp43 or Exp43b exploration outputs;
- unrelated observational branches;
- Backblaze artifacts;
- local rerun outputs from `replication_outputs/`.

## 3. Minimum File Bundle

Recommended external bundle contents:

| File | Role |
|---|---|
| `analysis/exp43_qcoloring/README.md` | human entry point |
| `analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md` | frozen design source |
| `analysis/exp43_qcoloring/exp43c_calibration_closeout.md` | calibration closeout |
| `analysis/exp43_qcoloring/exp43c_freeze_package.md` | frozen package |
| `analysis/exp43_qcoloring/exp43c_primary_report.md` | official report |
| `analysis/exp43_qcoloring/config/exp43c_primary_config.json` | frozen grid |
| `analysis/exp43_qcoloring/src/primary_manifest.py` | manifest generation |
| `analysis/exp43_qcoloring/src/pilot_runner.py` | solver runner |
| `analysis/exp43_qcoloring/src/evaluate_primary.py` | frozen evaluator |
| `analysis/exp43_qcoloring/src/generator.py` | deterministic generation |
| `analysis/exp43_qcoloring/src/cnf_encoder.py` | CNF encoder |
| `analysis/exp43_qcoloring/src/solver.py` | PySAT solver wrapper |
| `analysis/exp43_qcoloring/src/feature_extractor.py` | frozen feature schema |

Optional but useful:

| File | Role |
|---|---|
| `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md` | local rerun history |

## 4. Reference Artifact Hashes

Official reference artifacts:

| File | sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

These give the outside replicator a fixed target before any fresh rerun.

## 5. External Quickstart

Recommended external rerun order:

Manifest regeneration:

```bash
mkdir -p analysis/exp43_qcoloring/replication_outputs
printf '*\n!.gitignore\n' > analysis/exp43_qcoloring/replication_outputs/.gitignore

python3 analysis/exp43_qcoloring/src/primary_manifest.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_manifest_external.jsonl
```

Primary rerun:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_external.jsonl \
  run --execute
```

Frozen evaluation:

```bash
python3 analysis/exp43_qcoloring/src/evaluate_primary.py \
  analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_external.jsonl \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_evaluation_external.json
```

## 6. Success Criterion To Hand Off

The external rerun should be judged primarily on:

1. `fm_plus_n` still beating the best preregistered raw baseline;
2. `first_moment` still beating the raw baselines;
3. `fm_plus_n` not losing to `cnf_count_plus_n_q`;
4. zero malformed encodings;
5. no timeout pathology large enough to remove a q from the interpretation;
6. held-out q = 3 / 4 / 5 still preserving the H1 direction.

Exact floating identity is welcome, but qualitative reproduction is the
required threshold.

## 7. What The Package Should Explicitly Say

The handoff should state all three of these:

```text
Exp43c is already primary validated.
The external rerun is a replication exercise, not a new threshold-local
redesign.
Observational branches such as Backblaze sit below Exp43c in evidence tier.
```

That keeps the tier boundary clean.

## 8. Relation To Other Replication Targets

The intended outside rerun order remains:

```text
Mixed-CSP external rerun first -> Exp43c external rerun second ->
observational branches later
```

So this package is the next Route A handoff after Mixed-CSP, not a replacement
for it.
