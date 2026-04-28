# Exp43c True Outside-Group Rerun 01: philia_channel

Status: returned outside-group rerun. Clean success with minor non-substantive
environment / floating-point drift. This is the first returned Exp43c
true outside-group rerun.

Date checked locally: 2026-04-28

## 1. Returned Bundle

Outside runner identifier:

```text
philia_channel
```

Original returned local path:

```text
/Users/sunagawa/Downloads/実行結果_exp43c_フィリアちゃんねる/
```

Local archived evidence copy:

```text
analysis/exp43_qcoloring/replication_outputs/true_outside_01_philia_channel/
```

Returned artifacts:

```text
exp43c_primary_manifest_external.jsonl
exp43c_primary_results_external.jsonl
exp43c_primary_evaluation_external.json
実行環境メモ_テンプレート.md
```

This note records hashes and decision-relevant results. The local archived
evidence copy is under `replication_outputs/`, which is ignored by git.

## 2. Outside Environment

From the returned execution memo:

```text
OS: Windows 11 Home 25H2
Python version: 3.12
Python command: python
shell: cmd
virtual environment: yes
pip install -r requirements.txt: succeeded
workarounds: none
```

Dependency details reported:

```text
python-sat / pysat: 1.9.dev2
numpy: 2.4.4
scikit-learn: 1.8.0
scipy: 1.17.1
```

The runner reported:

```text
手順書どおりに最後まで実行できたか: はい
途中でエラーが出たか: いいえ
回避策を使ったか: いいえ
```

The runner also reported a scikit-learn 1.8 `FutureWarning` about `penalty`
deprecation. This is a non-fatal warning and does not affect the current
support decision. It should be treated as future maintenance work for the
runner script before scikit-learn 1.10.

## 3. Returned Artifact Hashes

| Artifact | Rows / size | sha256 |
|---|---:|---|
| `exp43c_primary_manifest_external.jsonl` | `4000` rows / `6334030` bytes | `ae3152a4469e451547cafeccf050a568c5e49adf63a719d3bd5edd36f9538407` |
| `exp43c_primary_results_external.jsonl` | `4000` rows / `8530201` bytes | `b2227b674bf65139fac8423ab5d1528412f95b72526da910f905eafaac9789b5` |
| `exp43c_primary_evaluation_external.json` | `15397` bytes | `e456e7e41dd1bb692e685dccd32f196747c4b2918c5e0504cfc643eeab6eb4ee` |
| returned environment memo | `1748` bytes | `b7a8912f77c75086e9bad957c93921aa4da36271dd802ef149a4b5aec54132d2` |

The official reference hashes in the locked bundle note are:

| Artifact | Official sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

The returned manifest differs byte-for-byte from the official manifest, but
the JSON row content matches exactly. The byte difference is consistent with
Windows newline serialization. The returned results differ byte-for-byte, as
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
timeout_summary total timeout_count = 0
timeout_summary total malformed_count = 0
```

The returned evaluation hash is not byte-identical to the official reference
hash. The predictor set and qualitative decision are identical; checked metric
differences are floating-point representation drift only, with maximum checked
absolute drift about `1.1e-13`.

| Metric | Outside rerun | Official reference | Status |
|---|---:|---:|---|
| rows total | `4000` | `4000` | match |
| SAT | `2003` | `2003` | match |
| UNSAT | `1997` | `1997` | match |
| TIMEOUT | `0` | `0` | match |
| MALFORMED | `0` | `0` | match |
| `fm_plus_n` mean held-out log loss | `0.44018904108753776` | `0.4401890410875378` | floating drift only |
| `first_moment` mean held-out log loss | `0.44681385336268226` | `0.44681385336268226` | match |
| best primary raw baseline | `2.804018617380672` | `2.8040186173807204` | floating drift only |
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
best primary raw baseline = 2.804018617380672
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
decision with exact manifest semantics, zero checked core-field mismatches, and
only non-substantive floating-point / serialization drift.

Together with the completed Mixed-CSP outside-group rerun set, this means Route
A now has returned outside-group support for two frozen packages:

1. Mixed-CSP: three returned clean successes;
2. Exp43c q-coloring: one returned clean success.

This does not by itself close:

- additional Exp43c outside-group reruns, if requested;
- observational-branch replication;
- non-CSP repair-flow support;
- the full universal-law credibility program.
