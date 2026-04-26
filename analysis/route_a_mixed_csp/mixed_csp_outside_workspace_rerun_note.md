# Mixed-CSP Outside-Workspace Rerun Note

Status: fresh-clone / outside-workspace rerun of the frozen Mixed-CSP primary
package. This is a real rerun in a separate workspace, but it is not an
independent rerun by an outside group.

Date: 2026-04-27

Upstream notes:

- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`

Purpose:

Rehearse the external Mixed-CSP handoff in a fresh clone, using separate output
paths and no official-artifact overwrites.

This note strengthens the operational credibility of the handoff package, but
it does not close G7 because the rerun was still performed by the same project
side.

Important boundary:

```text
The fresh-clone rehearsal itself was run from commit 514f168 before the later
382bd00 handoff-doc sync. The later published package documents the same
frozen Mixed-CSP code path with safer separate-output commands; it is not a
claim that commit 382bd00 itself was the clone source for this rehearsal.
```

## 1. Workspace Boundary

Fresh clone used:

```text
/tmp/dsp_mixed_external_20260427
```

Clone source commit:

```text
514f168d7e3478e984918f530d44772fe7c8620a
```

Output directory inside the clone:

```text
analysis/route_a_mixed_csp/external_outputs/
```

So this rerun was separated from:

- the main working tree;
- the checked-in official JSONL;
- the local `replication_outputs/` note path used by the internal Level 2 rerun.

## 2. Commands Run

Smoke dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_smoke_external.jsonl \
  smoke dry-run
```

Smoke execution:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_smoke_external.jsonl \
  smoke run --execute
```

Diagnostics:

```bash
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py regression
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 1000
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 80 --density 2.0
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 160 --density 2.0
```

Primary dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external.jsonl \
  primary dry-run
```

Primary execution:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external.jsonl \
  primary run --execute
```

Held-out analysis written to separate outputs:

```bash
python3 - <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, 'analysis/route_a_mixed_csp')
import analyze_mixed_csp as am
outdir = Path('analysis/route_a_mixed_csp/external_outputs')
am.RESULTS_JSON = outdir / 'mixed_csp_primary_external_results.json'
am.RESULTS_MD = outdir / 'mixed_csp_primary_external_summary.md'
print(am.analyze(outdir / 'mixed_csp_primary_external.jsonl'))
PY
```

## 3. External-Workspace Artifacts

| File | size bytes | sha256 |
|---|---:|---|
| `mixed_csp_smoke_external.jsonl` | `25031` | `3e29ce71c78f36e9613d997422343fccfc98be9f02a3cfbc43253eddd3edafc9` |
| `mixed_csp_primary_external.jsonl` | `15235673` | `5f7f5a60fe38947670c23325a0a39f129e522c14169144251fe1a010670b6830` |
| `mixed_csp_primary_external_results.json` | `41665` | `5092f3e16e6af981e16a3012258fc7aa31617f35022cf6b96ec9db8017836bce` |
| `mixed_csp_primary_external_summary.md` | `7276` | `77a2b72c51f5c5c4c3bd62d9d136db6dc6505067ab55ddb2deeac860ea1235c6` |

## 4. Rerun Result

Observed row count:

```text
12000
```

Held-out analysis:

| Metric | Outside-workspace rerun | Official target |
|---|---:|---:|
| rows total | `12000` | `12000` |
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

## 5. Comparison To The Official JSONL

Checked core fields:

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

Comparison result:

```text
0 mismatches
```

So the outside-workspace rerun reproduces the official primary rows exactly on
the checked core non-runtime fields.

## 6. Interpretation

This note establishes:

```text
the Mixed-CSP external handoff is operationally viable in a fresh clone using
separate outputs and still reproduces the official result exactly on the
checked core fields
```

That is stronger than an internal rerun in the main working tree and stronger
than a package note alone.

It still does not count as a true independent external replication, because:

```text
the rerun was still initiated from the project side rather than by an outside
group
```

So the correct updated position is:

- package note: complete
- outside-workspace rehearsal: complete
- independent outside rerun: still open
