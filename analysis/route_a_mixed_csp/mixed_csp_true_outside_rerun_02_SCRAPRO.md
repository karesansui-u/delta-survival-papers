# Mixed-CSP True Outside-Group Rerun 02: SCRAPRO

Status: returned outside-group rerun. Clean success. This is the second returned
run from the three requested Mixed-CSP outside-group reruns; one requested
rerun remains pending.

Date checked locally: 2026-04-27

## 1. Returned Bundle

Outside runner identifier:

```text
SCRAPRO
```

Returned local path:

```text
/Users/sunagawa/Downloads/submit_SCRAPRO/
```

Returned artifacts:

```text
mixed_csp_primary_external.jsonl
mixed_csp_primary_external_results.json
mixed_csp_primary_external_summary.md
実行環境メモ.md
```

This note records hashes and decision-relevant results only. The returned raw
outputs remain outside the tracked repository.

## 2. Outside Environment

From the returned execution memo:

```text
OS: Windows 11 Home
Python version: 3.12.7
pip install -r requirements.txt: Yes
workarounds: No
```

The runner reported:

```text
手順書どおりに最後まで実行できたか: Yes
途中でエラーが出たか: No
回避策を使ったか: No
```

The returned run is therefore especially useful as a plain Windows-side check:
it did not require WSL and did not report any workaround.

## 3. Returned Artifact Hashes

| Artifact | Rows | sha256 |
|---|---:|---|
| `mixed_csp_primary_external.jsonl` | `12000` | `03712669d80feb1fd59ad9eb1fe8df56fd79c73fb87f80f42610c0cd12a0e0c2` |
| `mixed_csp_primary_external_results.json` | n/a | `e4afe360d2fafbde31cb7fa074a72e4e702e10c98ba8cfafed4af6c34d88fa1a` |
| `mixed_csp_primary_external_summary.md` | n/a | `1d4bd5f08d0e30bd75229690b3bf5e02b88d8fd2b9d404b746934593d79c3a59` |
| returned environment memo | n/a | `279f6ad435460b2de3c3e210c14f207f4f9440fda68635a2fc011e2957437f32` |

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
| `raw_plus_n` weighted log loss | `0.7524844242572778` | `0.7524844242572775` | floating drift only |
| `first_moment` weighted log loss | `0.14891645806196113` | `0.14891645806196216` | floating drift only |
| `cnf_count_plus_n` weighted log loss | `0.10101906308115076` | `0.10101906308115063` | floating drift only |
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
decision with row-level core agreement. Because this run used Windows 11 Home
and Python 3.12.7 with no reported workaround, it also lowers the operational
risk that the bundle only works in WSL / Unix-like shells.

It does not by itself close:

- the remaining requested Mixed-CSP outside rerun;
- Exp43c outside-group rerun;
- observational-branch replication;
- non-CSP repair-flow support.
