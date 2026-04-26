# Exp43c Level 2 Fresh Rerun Note

Status: local fresh rerun of the frozen Exp43c primary package. This is a real
rerun, but it is not yet an external independent replication.

Date: 2026-04-27

Upstream notes:

- `analysis/g7_exp43c_replication_package_plan.md`
- `analysis/exp43_qcoloring/exp43c_freeze_package.md`

Purpose:

Run the full frozen Exp43c q-coloring primary package from scratch using
separate replication outputs and compare the rerun to the official 2026-04-23
package without modifying the checked-in official artifacts.

## 1. Separation From Official Artifacts

All fresh rerun outputs were written under:

```text
analysis/exp43_qcoloring/replication_outputs/
```

This ensured that:

- the official primary manifest remained untouched;
- the official primary results JSONL remained untouched;
- the official evaluation JSON remained untouched;
- the fresh rerun could be compared side by side with the frozen package.

## 2. Commands Run

Manifest regeneration:

```bash
python3 analysis/exp43_qcoloring/src/primary_manifest.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_manifest_rerun_2026-04-27.jsonl
```

Primary fresh rerun:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_rerun_2026-04-27.jsonl \
  run --execute
```

Frozen evaluation:

```bash
python3 analysis/exp43_qcoloring/src/evaluate_primary.py \
  analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_rerun_2026-04-27.jsonl \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_evaluation_rerun_2026-04-27.json
```

## 3. Rerun Artifacts

| File | size bytes | sha256 |
|---|---:|---|
| `exp43c_primary_manifest_rerun_2026-04-27.jsonl` | `6330030` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results_rerun_2026-04-27.jsonl` | `8367012` | `65f9fa8d346adb9434c96ea45f72f543340d22a0ece9440225b18d9bf4275be2` |
| `exp43c_primary_evaluation_rerun_2026-04-27.json` | `14814` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

## 4. Primary Fresh Rerun Result

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

Fresh held-out analysis:

| Metric | Fresh rerun | Official target |
|---|---:|---:|
| records | `4000` | `4000` |
| `fm_plus_n` log loss | `0.4401890410875378` | `0.4401890410875378` |
| `first_moment` log loss | `0.44681385336268226` | `0.44681385336268226` |
| `density_plus_n_q` log loss | `2.8040186173807204` | `2.8040186173807204` |
| `avg_degree_plus_n_q` log loss | `2.8040186173807204` | `2.8040186173807204` |
| `raw_plus_n_q` log loss | `8.567223932316738` | `8.567223932316738` |
| `cnf_count_plus_n_q` log loss | `7.700105445308683` | `7.700105445308683` |

## 5. Exact Comparison To Official Artifacts

Manifest comparison:

```text
exact byte-for-byte match
```

The rerun manifest hash:

```text
e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
```

is identical to the official frozen manifest hash recorded in the freeze
package.

Evaluation comparison:

```text
exact byte-for-byte match
```

The rerun evaluation hash:

```text
901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
```

matches the official evaluation hash recorded in the primary report.

Result-row comparison on checked core fields:

- `instance_id`
- `q`
- `n`
- `rho_fm`
- `m`
- `L`
- `first_moment_log_count`
- `cnf_clause_count`
- `q_colorable`
- `status`
- `coloring_verified`

Result:

```text
0 mismatches
```

So the rerun reproduces the official primary row content exactly on the checked
core non-runtime fields.

## 6. Interpretation

This local Level 2 rerun establishes:

```text
the frozen Exp43c primary package reruns cleanly from scratch and reproduces
the official result exactly on the checked core fields, with exact manifest
and evaluation matches
```

That is stronger than a plan-only replication note and real G7 progress.

It still does not close G7 by itself, because:

```text
this rerun was not performed by an external independent group
```

So the correct updated position is:

- Exp43c replication package plan: complete
- Level 2 local fresh rerun: complete
- external independent replication: still open

## 7. Next Action

The next clean replication moves are:

1. keep Mixed-CSP as the first external rerun handoff target;
2. package Exp43c for an outside replicator after Mixed-CSP handoff is stable;
3. keep observational branches such as Backblaze below Route A in replication
   priority.
