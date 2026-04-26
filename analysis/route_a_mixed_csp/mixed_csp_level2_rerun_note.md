# Mixed-CSP Level 2 Fresh Rerun Note

Status: local fresh rerun of the frozen Mixed-CSP primary package. This is a
real rerun, but it is not yet an external independent replication.

Date: 2026-04-27

Upstream notes:

- `analysis/g7_mixed_csp_replication_package_plan.md`
- `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md`

Purpose:

Run the full frozen Mixed-CSP primary package from scratch using separate
replication outputs and compare the rerun to the official 2026-04-22 package
without modifying the checked-in official artifacts.

## 1. Separation From Official Artifacts

All fresh rerun outputs were written under:

```text
analysis/route_a_mixed_csp/replication_outputs/
```

This ensured that:

- the official JSONL remained untouched;
- the checked-in official JSON / summary remained untouched;
- fresh rerun artifacts could be compared to the official package side by side.

## 2. Commands Run

Smoke dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/replication_outputs/mixed_csp_smoke_rerun_2026-04-27.jsonl \
  smoke dry-run
```

Smoke execution:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/replication_outputs/mixed_csp_smoke_rerun_2026-04-27.jsonl \
  smoke run --execute
```

Regression diagnostic:

```bash
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py regression
```

Agreement diagnostics:

```bash
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 1000
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 80 --density 2.0
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 160 --density 2.0
```

Primary dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/replication_outputs/mixed_csp_primary_rerun_2026-04-27.jsonl \
  primary dry-run
```

Primary fresh rerun:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/replication_outputs/mixed_csp_primary_rerun_2026-04-27.jsonl \
  primary run --execute
```

Fresh analysis:

```bash
python3 - <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, 'analysis/route_a_mixed_csp')
import analyze_mixed_csp as am
outdir = Path('analysis/route_a_mixed_csp/replication_outputs')
am.RESULTS_JSON = outdir / 'mixed_csp_primary_rerun_2026-04-27_results.json'
am.RESULTS_MD = outdir / 'mixed_csp_primary_rerun_2026-04-27_summary.md'
am.analyze(outdir / 'mixed_csp_primary_rerun_2026-04-27.jsonl')
PY
```

## 3. Rerun Artifacts

| File | size bytes | sha256 |
|---|---:|---|
| `mixed_csp_smoke_rerun_2026-04-27.jsonl` | `25029` | `0c584dd96f69215ebdde4025f4c52d854b45d4b96f2ad0c8c01b3f1edafd9578` |
| `mixed_csp_primary_rerun_2026-04-27.jsonl` | `15235533` | `30ebe39b33c2a914de943cc0017896a62a61743ff6621c293e57f08c34e0c387` |
| `mixed_csp_primary_rerun_2026-04-27_results.json` | `41676` | `2bc0deff308416f46cf4a4e00a47d1b219cab68910d9125f9e76c26f2c59b850` |
| `mixed_csp_primary_rerun_2026-04-27_summary.md` | `7276` | `06d946a13c2e20835d53d88c6ad84157c8cd7676958b4c549eefb5d5b82af91f` |

## 4. Pre-Primary Checks

Smoke run:

- completed on the separate smoke output path;
- no special pathology observed.

Regression diagnostic:

```text
PASS: 2 archived malformed rows are valid under the fixed verifier.
```

Agreement diagnostics:

- default `--instances 1000`: no agreement failure;
- `n=80, density=2.0, instances=500`: no agreement failure;
- `n=160, density=2.0, instances=500`: no agreement failure.

These checks reproduced the expected pre-primary implementation sanity.

## 5. Primary Fresh Rerun Result

Observed rerun row count:

```text
12000
```

Observed solver outcome counts:

| quantity | value |
|---|---:|
| succeeded rows | `12000` |
| SAT | `6753` |
| UNSAT | `5247` |
| TIMEOUT | `0` |
| MALFORMED | `0` |

Fresh held-out analysis:

| Metric | Fresh rerun | Official target |
|---|---:|---:|
| rows total | `12000` | `12000` |
| eligible primary rows | `12000` | `12000` |
| `L_plus_n` log loss | `0.09701224545154162` | `0.09701224545154162` |
| `raw_plus_n` log loss | `0.7524844242572775` | `0.7524844242572775` |
| `first_moment` log loss | `0.14891645806196216` | `0.14891645806196216` |
| `cnf_count_plus_n` log loss | `0.10101906308115063` | `0.10101906308115063` |
| relative improvement vs `raw_plus_n` | `0.8710774039644803` | `0.8710774039644803` |

Support flags:

```json
{
  "primary_supported": true,
  "strong_support": true,
  "theory_pure_support": true,
  "encoding_guardrail_passed": true
}
```

## 6. Row-Level Comparison To The Official JSONL

A row-by-row comparison was run on the following core fields:

- `instance_id`
- `phase`
- `n`
- `density`
- `mixture_id`
- `m`
- `counts`
- `semantic_raw_count`
- `cnf_clause_count`
- `sat_feasible`
- `status`
- `assignment_verified`

Result:

```text
0 mismatches
```

So the fresh rerun is not merely qualitatively consistent. On the core
non-runtime fields, it reproduces the official primary row content exactly.

## 7. Interpretation

This local Level 2 rerun establishes:

```text
the frozen Mixed-CSP primary package reruns cleanly from scratch and reproduces
the official result exactly on the checked core fields
```

That is stronger than the Level 1 audit replay and is real reproducibility
progress.

It still does not close G7 by itself, because:

```text
this rerun was not performed by an external independent group
```

So the correct updated position is:

- Level 1 audit replay: complete
- Level 2 local fresh rerun: complete
- external independent replication: still open

## 8. Next Action

The next clean replication moves are:

1. package the Mixed-CSP rerun instructions and expected outputs for an outside
   replicator;
2. move to `analysis/g7_exp43c_replication_package_plan.md` as the next Route A
   replication target;
3. keep Backblaze-like observational branches below Route A in replication
   priority.
