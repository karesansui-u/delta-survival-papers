# Mixed-CSP True Outside-Group Rerun 01: katsumasa1234

Status: returned outside-group rerun. Clean success. This is one returned run
from the three requested Mixed-CSP outside-group reruns; two requested reruns
remain pending.

Date checked locally: 2026-04-27

## 1. Returned Bundle

Outside runner identifier:

```text
katsumasa1234
```

Returned local paths:

```text
/Users/sunagawa/Downloads/external_outputs_katsumasa1234/
/Users/sunagawa/Downloads/実行環境メモ_テンプレート_katsumasa1234.md
```

Bundle identity reported for the zip route:

```text
mixed_csp_true_outside_bundle_df41b0fa7208.zip
exported_from_commit_short: df41b0fa7208
exported_from_commit_full: df41b0fa7208fdf8d8aacc50d51b341b4d22e197
```

This note records hashes and decision-relevant results only. The returned raw
outputs remain outside the tracked repository.

## 2. Outside Environment

From the returned execution memo:

```text
OS: Windows Ubuntu 22.04.5 LTS
Python version: Python 3.10.12
pip install -r requirements.txt: succeeded
workarounds: none
```

Dependency details reported:

```text
python_sat-1.9.dev2-cp310-cp310-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl
numpy-2.2.6-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
scipy-1.15.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
```

The runner reported:

```text
手順書どおりに最後まで実行できたか: できた
途中でエラーが出たか: 出なかった
回避策を使ったか: 使わなかった
```

## 3. Returned Artifact Hashes

| Artifact | Rows | sha256 |
|---|---:|---|
| `mixed_csp_smoke_external.jsonl` | `20` | `638241613a24ba3c730d71889afbfa8dd6e83f4f5402bb21e861dd392883bad1` |
| `mixed_csp_primary_external.jsonl` | `12000` | `f5180b7738a6e010fc87a173e72834955a48fdf8f7245fff5b674b82ed732fcb` |
| `mixed_csp_primary_external_results.json` | n/a | `0ac708b5e220f545a078ee8e7888e3741be0b09657ed3ac309ed9c41b3cec1bd` |
| `mixed_csp_primary_external_summary.md` | n/a | `f4056f35cd128953358b9b6adedff0d5d9e06d98918578ded105bbaf1a99a067` |
| returned environment memo | n/a | `13675571ef0ae5253ec4a946210cb568b6105323eb0a7617b777cc0c2c95cbbb` |

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
core_mismatches = 0
```

Runtime counters, timestamps, and paths were not required to match.

## 5. Quantitative Summary

| Metric | Outside rerun | Official reference | Status |
|---|---:|---:|---|
| rows total | `12000` | `12000` | match |
| primary rows eligible | `12000` | `12000` | match |
| `L_plus_n` weighted log loss | `0.09701224545154154` | `0.09701224545154162` | floating drift only |
| `raw_plus_n` weighted log loss | `0.7524844242572775` | `0.7524844242572775` | match |
| `first_moment` weighted log loss | `0.14891645806196124` | `0.14891645806196216` | floating drift only |
| `cnf_count_plus_n` weighted log loss | `0.10101906308265302` | `0.10101906308115063` | floating drift only |
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
decision with row-level core agreement.

It does not by itself close:

- the remaining two requested Mixed-CSP outside reruns;
- Exp43c outside-group rerun;
- observational-branch replication;
- non-CSP repair-flow support.
