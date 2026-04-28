# Exp43c True Outside-Group Rerun Final Report

Status: final package-level report for the three returned Exp43c true
outside-group reruns. All three returned runs completed cleanly.

Date finalized: 2026-04-28

## 1. Final Status

```text
returned outside-group reruns: 3
clean returned successes: 3
current status: 3/3 returned, 3/3 clean success
```

The returned runs are recorded in:

- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`

## 2. Final Result Table

| Runner | Environment | Workarounds | Primary rows | Core mismatches | Timeout / malformed | Status |
|---|---|---|---:|---:|---|---|
| `philia_channel` | Windows 11 Home 25H2, Python 3.12 | none | `4000` | `0` | `0 / 0` | clean success |
| `katsumasa1234` | Ubuntu 22.04.5 LTS via WSL, Python 3.10.12 | none | `4000` | `0` | `0 / 0` | clean success |
| `SCRAPRO` | Windows 11 Home, Python 3.12.7 | none | `4000` | `0` | `0 / 0` | clean success |

## 3. Returned Artifact Hashes

| Runner | Artifact | sha256 |
|---|---|---|
| `philia_channel` | `exp43c_primary_manifest_external.jsonl` | `ae3152a4469e451547cafeccf050a568c5e49adf63a719d3bd5edd36f9538407` |
| `philia_channel` | `exp43c_primary_results_external.jsonl` | `b2227b674bf65139fac8423ab5d1528412f95b72526da910f905eafaac9789b5` |
| `philia_channel` | `exp43c_primary_evaluation_external.json` | `e456e7e41dd1bb692e685dccd32f196747c4b2918c5e0504cfc643eeab6eb4ee` |
| `philia_channel` | returned environment memo | `b7a8912f77c75086e9bad957c93921aa4da36271dd802ef149a4b5aec54132d2` |
| `katsumasa1234` | `exp43c_primary_manifest_external.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `katsumasa1234` | `exp43c_primary_results_external.jsonl` | `cb2e29c6a726eeb2a2fb4d184e46e797704a85d035b28c3f7ebc73fc0ef66b3e` |
| `katsumasa1234` | `exp43c_primary_evaluation_external.json` | `96adbcb0b4cbf645f9e8204951d95f58aa0a3fcff490f4d9489c470efda5510d` |
| `katsumasa1234` | returned environment memo | `01b0882e1de475c433c2c4e7f51ce05bc3c1b0af2900bcd36b4542d76979f858` |
| `SCRAPRO` | `exp43c_primary_manifest_external.jsonl` | `ae3152a4469e451547cafeccf050a568c5e49adf63a719d3bd5edd36f9538407` |
| `SCRAPRO` | `exp43c_primary_results_external.jsonl` | `08c0f9a0adc02722ee0d611038ea69720ef8e610a6acd96ba5e29c22cf8441f3` |
| `SCRAPRO` | `exp43c_primary_evaluation_external.json` | `fc9d613523e38358a7452f4a0722f52021835556c92dca9dda871ffbeec90954` |
| `SCRAPRO` | returned environment memo | `2ea9f58331b7dafbd3180b7a2b6f7bf7fc4e268fd9c9cdf4cd964c5a26654a2d` |

The official locked-bundle reference hashes are:

| Artifact | Official sha256 |
|---|---|
| `exp43c_primary_manifest.jsonl` | `e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2` |
| `exp43c_primary_results.jsonl` | `37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b` |
| `exp43c_primary_evaluation.json` | `901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539` |

Windows-returned manifest files are not byte-identical to the official
manifest because of newline serialization, but their parsed JSON rows match
the official manifest exactly. Results and evaluation files are expected to
differ byte-for-byte because runtime metadata, solver environment fields, and
floating-point serialization are regenerated.

## 4. Quantitative Comparison

| Runner | Metric | Outside rerun | Official reference | Final judgment |
|---|---|---:|---:|---|
| `philia_channel` | rows total | `4000` | `4000` | match |
| `philia_channel` | SAT / UNSAT | `2003 / 1997` | `2003 / 1997` | match |
| `philia_channel` | `fm_plus_n` mean held-out log loss | `0.44018904108753776` | `0.4401890410875378` | floating drift only |
| `philia_channel` | best primary raw baseline | `2.804018617380672` | `2.8040186173807204` | floating drift only |
| `philia_channel` | `cnf_count_plus_n_q` mean held-out log loss | `7.700105445308579` | `7.700105445308683` | floating drift only |
| `katsumasa1234` | rows total | `4000` | `4000` | match |
| `katsumasa1234` | SAT / UNSAT | `2003 / 1997` | `2003 / 1997` | match |
| `katsumasa1234` | `fm_plus_n` mean held-out log loss | `0.44018904108753776` | `0.4401890410875378` | floating drift only |
| `katsumasa1234` | best primary raw baseline | `2.8040186173806823` | `2.8040186173807204` | floating drift only |
| `katsumasa1234` | `cnf_count_plus_n_q` mean held-out log loss | `7.700105445308579` | `7.700105445308683` | floating drift only |
| `SCRAPRO` | rows total | `4000` | `4000` | match |
| `SCRAPRO` | SAT / UNSAT | `2003 / 1997` | `2003 / 1997` | match |
| `SCRAPRO` | `fm_plus_n` mean held-out log loss | `0.44018904108753776` | `0.4401890410875378` | floating drift only |
| `SCRAPRO` | best primary raw baseline | `2.804018617380582` | `2.8040186173807204` | floating drift only |
| `SCRAPRO` | `cnf_count_plus_n_q` mean held-out log loss | `7.700105445308538` | `7.700105445308683` | floating drift only |

Support checks for all three completed runs:

```text
fm_plus_n < best primary raw baseline: true
fm_plus_n <= cnf_count_plus_n_q: true
TIMEOUT = 0
MALFORMED = 0
checked core mismatches = 0
```

## 5. Final Interpretation

The Exp43c true outside-group rerun workstream is complete at the current
three-return level. All three outside returns:

1. completed the frozen 4,000-row primary;
2. reported no workaround;
3. returned the required primary artifacts;
4. matched the official primary on checked row-level core fields;
5. reproduced the qualitative support decision.

The correct program wording is:

```text
Exp43c true outside-group rerun set completed: three outside executors
returned clean 4,000-row primary runs with zero checked core-field mismatches,
zero timeouts, zero malformed rows, and the same qualitative support decision.
```

This strengthens G7 for the Exp43c q-coloring package specifically. It does
not close the full replication program, because observational branch
replication, non-CSP repair-flow support, and independent theoretical review
remain separate workstreams.
