# Mixed-CSP True Outside-Group Rerun Interim Report

Status: interim report. Two of three requested outside-group reruns have
returned and passed cleanly. This is not the final G7 report for Mixed-CSP.

Date opened: 2026-04-27

## 1. Current Status

```text
requested outside-group reruns: 3
returned reruns: 2
clean returned successes: 2
pending reruns: 1
current status: 2/3 completed, 2/2 clean success, 1 pending
```

The returned runs are recorded in:

- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`

## 2. Interim Result Table

| Runner | Environment | Workarounds | Primary rows | Core mismatches | Support flags | Status |
|---|---|---|---:|---:|---|---|
| `katsumasa1234` | Windows Ubuntu 22.04.5 LTS, Python 3.10.12 | none | `12000` | `0` | all true | clean success |
| `SCRAPRO` | Windows 11 Home, Python 3.12.7 | none | `12000` | `0` | all true | clean success |
| pending runner 3 | pending | pending | pending | pending | pending | pending |

## 3. Returned Artifact Hashes For Completed Run

| Runner | Artifact | sha256 |
|---|---|---|
| `katsumasa1234` | `mixed_csp_smoke_external.jsonl` | `638241613a24ba3c730d71889afbfa8dd6e83f4f5402bb21e861dd392883bad1` |
| `katsumasa1234` | `mixed_csp_primary_external.jsonl` | `f5180b7738a6e010fc87a173e72834955a48fdf8f7245fff5b674b82ed732fcb` |
| `katsumasa1234` | `mixed_csp_primary_external_results.json` | `0ac708b5e220f545a078ee8e7888e3741be0b09657ed3ac309ed9c41b3cec1bd` |
| `katsumasa1234` | `mixed_csp_primary_external_summary.md` | `f4056f35cd128953358b9b6adedff0d5d9e06d98918578ded105bbaf1a99a067` |
| `katsumasa1234` | returned environment memo | `13675571ef0ae5253ec4a946210cb568b6105323eb0a7617b777cc0c2c95cbbb` |
| `SCRAPRO` | `mixed_csp_primary_external.jsonl` | `03712669d80feb1fd59ad9eb1fe8df56fd79c73fb87f80f42610c0cd12a0e0c2` |
| `SCRAPRO` | `mixed_csp_primary_external_results.json` | `e4afe360d2fafbde31cb7fa074a72e4e702e10c98ba8cfafed4af6c34d88fa1a` |
| `SCRAPRO` | `mixed_csp_primary_external_summary.md` | `1d4bd5f08d0e30bd75229690b3bf5e02b88d8fd2b9d404b746934593d79c3a59` |
| `SCRAPRO` | returned environment memo | `279f6ad435460b2de3c3e210c14f207f4f9440fda68635a2fc011e2957437f32` |

## 4. Quantitative Comparison For Completed Runs

| Runner | Metric | Outside rerun | Official reference | Interim judgment |
|---|---|---:|---:|---|
| `katsumasa1234` | rows total | `12000` | `12000` | match |
| `katsumasa1234` | `L_plus_n` weighted log loss | `0.09701224545154154` | `0.09701224545154162` | floating drift only |
| `katsumasa1234` | `raw_plus_n` weighted log loss | `0.7524844242572775` | `0.7524844242572775` | match |
| `katsumasa1234` | `first_moment` weighted log loss | `0.14891645806196124` | `0.14891645806196216` | floating drift only |
| `katsumasa1234` | `cnf_count_plus_n` weighted log loss | `0.10101906308265302` | `0.10101906308115063` | floating drift only |
| `SCRAPRO` | rows total | `12000` | `12000` | match |
| `SCRAPRO` | `L_plus_n` weighted log loss | `0.09701224545154154` | `0.09701224545154162` | floating drift only |
| `SCRAPRO` | `raw_plus_n` weighted log loss | `0.7524844242572778` | `0.7524844242572775` | floating drift only |
| `SCRAPRO` | `first_moment` weighted log loss | `0.14891645806196113` | `0.14891645806196216` | floating drift only |
| `SCRAPRO` | `cnf_count_plus_n` weighted log loss | `0.10101906308115076` | `0.10101906308115063` | floating drift only |

Support flags for both completed runs:

```text
primary_supported = true
strong_support = true
theory_pure_support = true
encoding_guardrail_passed = true
```

## 5. Interim Interpretation

The Mixed-CSP true outside-group rerun workstream is no longer merely
send-ready. It now has two returned outside-group runs that:

1. completed the frozen 12,000-row primary;
2. reported no workaround;
3. returned all required artifacts;
4. matched the official primary on checked row-level core fields;
5. reproduced all four support flags.

The correct program wording is:

```text
Mixed-CSP true outside-group rerun is underway. The first two returned runs
completed cleanly and reproduced the official qualitative support decision; one
requested rerun remains pending.
```

Do not yet use final wording such as:

```text
Mixed-CSP true outside-group rerun set completed.
```

## 6. Next Update Trigger

Update this interim report when either:

1. the remaining third outside runner returns artifacts;
2. a returned runner reports failure or uses a workaround that changes the
   interpretation.

After all requested returns are resolved, replace this with a final Mixed-CSP G7
outside-group rerun report.
