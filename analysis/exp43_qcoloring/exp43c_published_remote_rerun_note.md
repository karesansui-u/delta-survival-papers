# Exp43c Published-Remote Outside-Workspace Rerun Note

Status: published-remote / outside-workspace rerun of the frozen Exp43c
primary package. This is stronger than the local Level 2 rerun and stronger
than package-only handoff documentation, but it is still not an independent
rerun by an outside group.

Date: 2026-04-27

Upstream notes:

- `analysis/g7_exp43c_replication_package_plan.md`
- `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`
- `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`

Purpose:

Confirm that the published Exp43c package at the current pushed commit can be
cloned into a fresh workspace and rerun end-to-end using separate outputs,
while preserving the frozen manifest, primary result, and evaluation behavior.

Important boundary:

```text
This note records a published-remote rerun from a fresh clone of the public
project state at commit 96de727. It exercises the currently published Exp43c
package, not a local draft. It still does not count as true G7 independent
replication, because the rerun was initiated from the project side rather than
by an outside group.
```

## 1. Workspace Boundary

Fresh clone used:

```text
/tmp/dsp-published-rerun
```

Clone source commit:

```text
96de727c0aa04f8f31f8b6d3a1febade69b861c3
```

Output directory inside the clone:

```text
analysis/exp43_qcoloring/replication_outputs/
```

So this rerun was separated from:

- the main working tree;
- the checked-in official primary manifest / results / evaluation;
- the local rerun history recorded in `exp43c_level2_rerun_note.md`.

## 2. Commands Run

Output hygiene:

```bash
mkdir -p analysis/exp43_qcoloring/replication_outputs
printf '*\n!.gitignore\n' > analysis/exp43_qcoloring/replication_outputs/.gitignore
```

Manifest regeneration:

```bash
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

## 3. Published-Remote Artifacts

| File | size bytes | sha256 |
|---|---:|---|
| `exp43c_primary_manifest_external.jsonl` | `6330030` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results_external.jsonl` | `8336173` | `e0a713ac998e1e2c7366a873afb9ba8649d8f7cf48740a6770b409ca85840179` |
| `exp43c_primary_evaluation_external.json` | `14814` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

## 4. Primary Published-Remote Rerun Result

Observed rerun row count:

```text
4000
```

Observed solver outcome counts:

| quantity | value |
|---|---:|
| succeeded rows | `4000` |
| SAT | `2003` |
| UNSAT | `1997` |
| TIMEOUT | `0` |
| MALFORMED | `0` |

Held-out analysis:

| Metric | Published-remote rerun | Official target |
|---|---:|---:|
| records | `4000` | `4000` |
| `fm_plus_n` log loss | `0.4401890410875378` | `0.4401890410875378` |
| `first_moment` log loss | `0.44681385336268226` | `0.44681385336268226` |
| `density_plus_n_q` log loss | `2.8040186173807204` | `2.8040186173807204` |
| `avg_degree_plus_n_q` log loss | `2.8040186173807204` | `2.8040186173807204` |
| `raw_plus_n_q` log loss | `8.567223932316738` | `8.567223932316738` |
| `cnf_count_plus_n_q` log loss | `7.700105445308683` | `7.700105445308683` |

Held-out q fold targets:

| held-out q | `fm_plus_n` | official target |
|---:|---:|---:|
| 3 | `0.5705277449330725` | `0.5705277449330725` |
| 4 | `0.32338831583926725` | `0.32338831583926725` |
| 5 | `0.4266510624902738` | `0.4266510624902738` |

## 5. Exact Comparison To Official Artifacts

Manifest comparison:

```text
exact byte-for-byte match
```

The external manifest hash:

```text
e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
```

is identical to the official frozen manifest hash recorded in the freeze
package.

Evaluation comparison:

```text
exact byte-for-byte match
```

The external evaluation hash:

```text
901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
```

matches the official evaluation hash recorded in the primary report.

Result-row comparison on checked core fields:

- `instance_id`
- `q`
- `n`
- `rho_fm`
- `seed_digest`
- `edge_list_hash`
- `q_colorable`
- `status`
- `coloring_verified`

Result:

```text
0 mismatches
```

So the published-remote rerun reproduces the official primary row content
exactly on the checked core non-runtime fields.

## 6. Interpretation

This note establishes:

```text
the currently published Exp43c package can be cloned into a fresh workspace,
rerun with separate outputs, and still reproduce the official manifest,
official evaluation, and the checked core fields of the official primary rows
```

That is stronger than:

- a same-worktree rerun;
- a local Level 2 rerun note without published-remote confirmation;
- an external-package note without execution.

It still does not count as a true independent external replication, because:

```text
the rerun was still initiated from the project side rather than by an outside
group
```

So the correct updated position is:

- local Level 2 rerun: complete
- external handoff package: complete
- published-remote outside-workspace rerun: complete
- true outside-group rerun: still open
