# Exp43c True Outside-Group Rerun 02: katsumasa1234

Status: returned outside-group rerun. Clean success with non-substantive
floating-point drift only. This is the second returned Exp43c true
outside-group rerun.

Date checked locally: 2026-04-28

## 1. Returned Bundle

Outside runner identifier:

```text
katsumasa1234
```

Original returned local paths:

```text
/Users/sunagawa/Downloads/external_outputs_2_katsumasa1234/
/Users/sunagawa/Downloads/実行環境メモ_テンプレート (2).md
```

Local archived evidence copy:

```text
analysis/exp43_qcoloring/replication_outputs/true_outside_02_katsumasa1234/
```

Returned artifacts:

```text
exp43c_primary_manifest_external.jsonl
exp43c_primary_results_external.jsonl
exp43c_primary_evaluation_external.json
実行環境メモ_テンプレート.md
```

This note records hashes and decision-relevant results. The local archived
evidence copy is under `replication_outputs/`, which is ignored by git.

## 2. Outside Environment

From the returned execution memo:

```text
OS: Ubuntu 22.04.5 LTS
Python version: 3.10.12
Python command: python3
shell: WSL
pip install -r requirements.txt: succeeded
workarounds: none
```

Dependency details reported:

```text
python-sat / pysat: 1.9.dev2
numpy: 2.2.6
scikit-learn: 1.7.2
scipy: 1.15.3
```

The runner reported:

```text
手順書どおりに最後まで実行できたか: できた
途中でエラーが出たか: 出なかった
回避策を使ったか: 使わなかった
```

The runner also reported that they could not identify the "raw baseline" field
name in the returned evaluation JSON. This is non-substantive: the frozen
evaluation JSON stores the relevant raw baselines under predictor names such as
`density_plus_n_q`, `avg_degree_plus_n_q`, and `raw_plus_n_q`.

## 3. Returned Artifact Hashes

| Artifact | Rows / size | sha256 |
|---|---:|---|
| `exp43c_primary_manifest_external.jsonl` | `4000` rows / `6330030` bytes | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results_external.jsonl` | `4000` rows / `8501009` bytes | `cb2e29c6a726eeb2a2fb4d184e46e797704a85d035b28c3f7ebc73fc0ef66b3e` |
| `exp43c_primary_evaluation_external.json` | `14815` bytes | `96adbcb0b4cbf645f9e8204951d95f58aa0a3fcff490f4d9489c470efda5510d` |
| returned environment memo | `1929` bytes | `01b0882e1de475c433c2c4e7f51ce05bc3c1b0af2900bcd36b4542d76979f858` |

The official reference hashes in the locked bundle note are:

| Artifact | Official sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

The returned manifest is byte-for-byte identical to the official manifest.
The returned results differ byte-for-byte from the official results, as
expected, because runtime counters, timestamps, and solver environment metadata
are regenerated on rerun.

## 4. Core Row-Level Check

Manifest comparison against:

```text
analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl
```

Result:

```text
external manifest rows = 4000
official manifest rows = 4000
byte-for-byte manifest match = true
semantic JSON row mismatches = 0
```

Primary results comparison against:

```text
analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl
```

Checked exact core fields:

```text
instance_id, instance_idx, instance_seed, instance_seed_int,
q, n, m, rho_fm, rho_fm_actual, edge_list_hash,
L, first_moment_log_count, cnf_clause_count, cnf_variable_count,
status, q_colorable, coloring_verified, timeout, error
```

Result:

```text
external result rows = 4000
official result rows = 4000
SAT = 2003
UNSAT = 1997
TIMEOUT = 0
error rows = 0
checked core mismatches = 0
```

Runtime counters, timestamps, and solver environment metadata were not required
to match.

## 5. Evaluation Check

Returned evaluation:

```text
total_records = 4000
solved_records = 4000
all timeout_summary cell timeout_count values = 0
all timeout_summary cell malformed_count values = 0
```

The returned evaluation hash is not byte-identical to the official reference
hash. The predictor set and qualitative decision are identical; checked metric
differences are floating-point representation drift only, with maximum checked
absolute drift about `4.6e-13`.

| Metric | Outside rerun | Official reference | Status |
|---|---:|---:|---|
| rows total | `4000` | `4000` | match |
| SAT | `2003` | `2003` | match |
| UNSAT | `1997` | `1997` | match |
| TIMEOUT | `0` | `0` | match |
| MALFORMED | `0` | `0` | match |
| `fm_plus_n` mean held-out log loss | `0.44018904108753776` | `0.4401890410875378` | floating drift only |
| `first_moment` mean held-out log loss | `0.44681385336268226` | `0.44681385336268226` | match |
| best primary raw baseline | `2.8040186173806823` | `2.8040186173807204` | floating drift only |
| `cnf_count_plus_n_q` mean held-out log loss | `7.700105445308579` | `7.700105445308683` | floating drift only |

Held-out q folds for `fm_plus_n`:

| held-out q | Outside `fm_plus_n` | Official `fm_plus_n` | Direction |
|---:|---:|---:|---|
| 3 | `0.5705277449330723` | `0.5705277449330725` | match within float drift |
| 4 | `0.32338831583926725` | `0.32338831583926725` | match |
| 5 | `0.4266510624902737` | `0.4266510624902738` | match within float drift |

Primary support checks:

```text
fm_plus_n = 0.44018904108753776
best primary raw baseline = 2.8040186173806823
cnf_count_plus_n_q = 7.700105445308579

fm_plus_n < best primary raw baseline: true
fm_plus_n <= cnf_count_plus_n_q: true
```

## 6. Interpretation

This returned run is a successful true outside-group rerun for the Exp43c
q-coloring package:

```text
successful outside-group reproduction
```

It supports the narrow G7 claim that the frozen Exp43c q-coloring package can
be executed outside the project environment and recover the qualitative support
decision with exact manifest identity, zero checked core-field mismatches, and
only non-substantive floating-point / runtime-metadata drift.

Together with the completed Mixed-CSP outside-group rerun set, this means Route
A now has returned outside-group support for two frozen packages:

1. Mixed-CSP: three returned clean successes;
2. Exp43c q-coloring: two returned clean successes at this point.

The cumulative Exp43c outside-return status is superseded by
`analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`.

This does not by itself close:

- observational-branch replication;
- non-CSP repair-flow support;
- the full universal-law credibility program.
