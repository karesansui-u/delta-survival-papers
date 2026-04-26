# Exp43c True Outside-Group Handoff Checklist

Status: final handoff checklist for a true outside-group rerun. This is not a
new empirical result and not validation evidence.

Date: 2026-04-27

Upstream package notes:

- `analysis/g7_exp43c_replication_package_plan.md`
- `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
- `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`

Purpose:

Provide the exact checklist to use when handing the frozen Exp43c package to
an outside replicator who is not operating from the project side.

## 1. Package Identity

Package to hand off:

```text
Exp43c frozen q-coloring primary package as documented at commit 21d9905, with
the published-remote code path already exercised from commit 96de727.
```

Important distinction:

```text
21d9905 is the current documentation state.
96de727 is the published-remote state already exercised in a fresh clone.
The outside-group rerun should use the current published bundle, but it should
be described as a replication of the frozen Exp43c package, not as a rerun of
an unpublished local state.
```

## 2. Before-Send Checklist

Before sending the package, verify all of the following:

1. `origin/main` and `codeberg/main` both point to the same published commit.
2. `analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl` exists and
   matches the published hash.
3. `analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl` exists and
   matches the published hash.
4. `analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json` exists and
   matches the published hash.
5. `analysis/exp43_qcoloring/exp43c_external_rerun_package.md` contains
   separate-output commands.
6. `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`
   confirms project-side published-remote reproducibility.
7. The package text still explicitly says:
   - already primary validated;
   - rerun is replication, not redesign;
   - observational branches sit below Exp43c in evidence tier.

## 3. Minimum Bundle To Send

Send the following files and nothing more unless requested:

1. `analysis/exp43_qcoloring/README.md`
2. `analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md`
3. `analysis/exp43_qcoloring/exp43c_calibration_closeout.md`
4. `analysis/exp43_qcoloring/exp43c_freeze_package.md`
5. `analysis/exp43_qcoloring/exp43c_primary_report.md`
6. `analysis/exp43_qcoloring/config/exp43c_primary_config.json`
7. `analysis/exp43_qcoloring/src/primary_manifest.py`
8. `analysis/exp43_qcoloring/src/pilot_runner.py`
9. `analysis/exp43_qcoloring/src/evaluate_primary.py`
10. `analysis/exp43_qcoloring/src/generator.py`
11. `analysis/exp43_qcoloring/src/cnf_encoder.py`
12. `analysis/exp43_qcoloring/src/solver.py`
13. `analysis/exp43_qcoloring/src/feature_extractor.py`
14. `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
15. `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`

Optional context only:

1. `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`
2. `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`

Do not send:

1. Exp43 / Exp43b exploration outputs;
2. unrelated observational branches;
3. local rerun outputs;
4. Backblaze / C-MAPSS branches.

## 4. Reference Hashes To Include In The Handoff

Official reference artifacts:

| File | sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

Published-remote project-side rerun artifacts:

| File | sha256 |
|---|---|
| `exp43c_primary_manifest_external.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results_external.jsonl` | `e0a713ac998e1e2c7366a873afb9ba8649d8f7cf48740a6770b409ca85840179` |
| `exp43c_primary_evaluation_external.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

## 5. Exact Outside-Group Request

Ask the outside group to do exactly this:

1. clone the published repository state;
2. create a separate output directory;
3. regenerate the manifest from the frozen config;
4. run the primary solver pipeline;
5. run the frozen evaluation script;
6. return:
   - output file hashes;
   - row counts and status counts;
   - held-out predictor summary;
   - any timeout / malformed notes;
   - any local workaround needed to complete the run.

## 6. Exact Return Bundle Requested From The Outside Group

Ask the outside group to return these artifacts:

1. rerun manifest JSONL
2. rerun primary results JSONL
3. rerun evaluation JSON
4. a short environment note including:
   - OS
   - Python version
   - PySAT / solver versions if available

## 7. Success Criterion

Count the outside-group rerun as successful if:

1. the frozen Exp43c package is followed without redesign;
2. `fm_plus_n` still beats the best preregistered primary raw baseline;
3. `first_moment` still beats the raw baselines;
4. `fm_plus_n` does not lose to `cnf_count_plus_n_q`;
5. held-out q = 3 / 4 / 5 still preserve the H1 direction;
6. no malformed-encoding or timeout pathology changes the interpretation.

Exact bitwise identity is welcome but not required.

## 8. What Should Not Be Treated As Failure

Do not classify the rerun as failed solely because of:

1. different timestamps;
2. runtime metadata differences;
3. small floating-point drift with unchanged ordering and unchanged
   qualitative decision;
4. the fact that q=5 remains narrow.

## 9. What Would Count As A Real Replication Failure

Escalate to a dedicated replication note if any of these happen:

1. `fm_plus_n` no longer beats the best raw baseline;
2. `first_moment` no longer beats the raw baselines;
3. `fm_plus_n` loses to `cnf_count_plus_n_q`;
4. repeated malformed encodings appear;
5. timeout instability removes a q from cross-q interpretation.

## 10. Final One-Line Handoff Language

Use this wording in the actual handoff:

```text
This package is a rerun of an already validated Exp43c frozen q-coloring
primary. It is a replication task, not a redesign task. Please use separate
outputs, do not overwrite the official artifacts, and report whether the
qualitative support decision is reproduced.
```
