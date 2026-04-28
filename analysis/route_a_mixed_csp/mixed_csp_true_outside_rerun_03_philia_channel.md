# Mixed-CSP True Outside-Group Rerun 03: philia_channel

Status: returned outside-group rerun. Clean success. This is the third returned
run from the three requested Mixed-CSP outside-group reruns.

Date checked locally: 2026-04-28

## 1. Returned Bundle

Outside runner identifier:

```text
philia_channel
```

Original returned local path:

```text
/Users/sunagawa/Downloads/実行結果_フィリアちゃんねる/
```

Local archived evidence copy:

```text
analysis/route_a_mixed_csp/replication_outputs/true_outside_03_philia_channel/
```

Returned artifacts:

```text
mixed_csp_primary_external.jsonl
mixed_csp_primary_external_results.json
mixed_csp_primary_external_summary.md
実行環境メモ_テンプレート.md
```

This note records hashes and decision-relevant results. The local archived
evidence copy is under `replication_outputs/`, which is ignored by git.

## 2. Outside Environment

From the returned execution memo:

```text
OS: Windows 11 Home 25H2
Python version: 3.12
pip install -r requirements.txt: succeeded
workarounds: none
```

Dependency details reported:

```text
python-sat==1.9.dev2
scipy==1.17.1
numpy==2.4.4
```

The runner reported:

```text
手順書どおりに最後まで実行できたか: できた
途中でエラーが出たか: 出ていない
回避策を使ったか: -
```

## 3. Returned Artifact Hashes

| Artifact | Rows | sha256 |
|---|---:|---|
| `mixed_csp_primary_external.jsonl` | `12000` | `6d9ae2182c2c97786e627a34203cbe9c988a19c7cb01f8a6e312b5706a78b904` |
| `mixed_csp_primary_external_results.json` | n/a | `3b20ff0aa4ac380436ff7f3d8fb53df53ddce2ffc885652920a56127b39ac6e9` |
| `mixed_csp_primary_external_summary.md` | n/a | `08dd0d7f88532c002b8320a16039a78f25309fb517391f313d9b83650da46c12` |
| returned environment memo | n/a | `3c0884ab3c0a34bed621ed36c68b67ee1131141e5aada1a60a4a3d916ec79cfb` |

## 4. Core Row-Level Check

Compared against:

```text
analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl
```

Checked exact fields:

```text
instance_id, phase, n, m, density, mixture_id, counts, mixture,
cnf_clause_count, cnf_variable_count, instance_seed, instance_seed_int,
semantic_raw_count, sat_feasible, status, timeout, assignment_verified
```

Checked floating fields with absolute tolerance `1e-12`:

```text
L, first_moment_log_count
```

Result:

```text
external_rows = 12000
official_rows = 12000
status counts = succeeded: 12000
sat_feasible counts = true: 6753, false: 5247
core_mismatches = 0
float_mismatches = 0
```

Runtime counters, timestamps, and paths were not required to match.

## 5. Quantitative Summary

| Metric | Outside rerun | Official reference | Status |
|---|---:|---:|---|
| rows total | `12000` | `12000` | match |
| primary rows eligible | `12000` | `12000` | match |
| `L_plus_n` weighted log loss | `0.09701224545154154` | `0.09701224545154162` | floating drift only |
| `raw_plus_n` weighted log loss | `0.7524844242572775` | `0.7524844242572775` | match |
| `first_moment` weighted log loss | `0.14891645806196122` | `0.14891645806196216` | floating drift only |
| `cnf_count_plus_n` weighted log loss | `0.1010190630773089` | `0.10101906308115063` | floating drift only |
| relative improvement vs `raw_plus_n` | `0.8710774039644804` | `0.8710774039644803` | floating drift only |

The small numeric differences above do not change any model ordering or support
decision.

## 6. Support Flags

Returned `support` values:

```text
primary_supported: true
strong_support: true
theory_pure_support: true
encoding_guardrail_passed: true
```

Outside-runner one-line conclusion:

```text
4つの支持フラグがすべて true だったので再現した
```

## 7. Interpretation

This returned run is a clean true outside-group rerun success for the Mixed-CSP
package:

```text
successful outside-group reproduction
```

It supports the narrow G7 claim that the frozen Mixed-CSP primary can be
executed outside the project environment and recover the qualitative support
decision with row-level core agreement. This return also completes the three
requested Mixed-CSP outside-group rerun set at `3/3` clean successes.

It does not by itself close:

- Exp43c outside-group rerun;
- observational-branch replication;
- non-CSP repair-flow support;
- the full universal-law credibility program.
