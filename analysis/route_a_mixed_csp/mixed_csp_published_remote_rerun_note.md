# Mixed-CSP Published-Remote Outside-Workspace Rerun Note

Status: published-remote / outside-workspace rerun of the frozen Mixed-CSP
primary package. This is stronger than a same-worktree rerun and stronger than
the earlier fresh-clone rehearsal, but it is still not an independent rerun by
an outside group.

Date: 2026-04-27

Upstream notes:

- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`
- `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md`

Purpose:

Confirm that the published project-side package at the current pushed commit
can be cloned into a fresh workspace and rerun end-to-end using the documented
separate-output commands, without touching the checked-in official artifacts.

Important boundary:

```text
This note records a published-remote rerun from a fresh clone of the public
project state at commit 96de727. It is stronger than the earlier 514f168
fresh-clone rehearsal, because it exercises the currently published package.
It still does not count as true G7 independent replication, because the rerun
was initiated from the project side rather than by an outside group.
```

## 1. Workspace Boundary

Fresh clone used:

```text
/tmp/dsp-published-rerun
```

Clone source commit:

```text
96de727c0aa04f8f31f8b6d3a1febade69b861c3
```

Output directory inside the clone:

```text
analysis/route_a_mixed_csp/external_outputs/
```

So this rerun was separated from:

- the main working tree;
- the checked-in official JSONL;
- the local `replication_outputs/` history used by earlier internal reruns.

## 2. Commands Run

Install / output hygiene:

```bash
mkdir -p analysis/route_a_mixed_csp/external_outputs
printf '*\n!.gitignore\n' > analysis/route_a_mixed_csp/external_outputs/.gitignore
```

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

## 3. Published-Remote Artifacts

| File | size bytes | sha256 |
|---|---:|---|
| `mixed_csp_smoke_external.jsonl` | `25031` | `3e29ce71c78f36e9613d997422343fccfc98be9f02a3cfbc43253eddd3edafc9` |
| `mixed_csp_primary_external.jsonl` | `15235082` | `c60603aa7e738785ae459dfc25c4cb9ca0da965dfc38cb9be13f1a871dd21817` |
| `mixed_csp_primary_external_results.json` | `41663` | `6fb2c5f9ba6bc1290656612bddcfcdb81bf4547c0308ca2fe0da63d9b74f4735` |
| `mixed_csp_primary_external_summary.md` | `7276` | `ef5d91b672b31975908be8abd549244e747bfedfdb684a998b239056dd13ee0d` |

## 4. Rerun Result

Observed row count:

```text
12000
```

Held-out analysis:

| Metric | Published-remote rerun | Official target |
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

So the published-remote rerun reproduces the official primary rows exactly on
the checked core non-runtime fields.

## 6. Interpretation

This note establishes:

```text
the currently published Mixed-CSP package can be cloned into a fresh workspace,
rerun with separate outputs, and still reproduce the official result exactly
on the checked core fields
```

That is stronger than:

- a same-worktree rerun;
- a package note without execution;
- the earlier 514f168 rehearsal that predated the later safe-command sync.

It still does not count as a true independent external replication, because:

```text
the rerun was still initiated from the project side rather than by an outside
group
```

So the correct updated position is:

- Level 1 audit replay: complete
- Level 2 local fresh rerun: complete
- published-remote outside-workspace rerun: complete
- true outside-group rerun: still open
