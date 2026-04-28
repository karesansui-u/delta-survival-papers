# G7 Mixed-CSP Replication Package Plan

Status: replication-planning note. This is not a new empirical result and not a
new freeze document.

Level 1 status update:

```text
Artifact-level audit replay is now complete.
See analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md.
Level 2 local fresh rerun is now also complete.
See analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md.
Fresh-clone outside-workspace rehearsal is now also complete.
See analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md.
Published-remote outside-workspace rerun is now also complete.
See analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md.
True outside-group requested set is now complete:
`analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`
records the first returned clean success,
`analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`
records the second returned clean success, and
`analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`
records the third returned clean success.
`analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md` records
the final requested-set state (`3/3` completed, `3/3` clean success, `0`
pending).
```

External package boundary notes:

- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md`

Purpose:

Define the first independent-replication target for the program. Mixed-CSP is
the recommended first G7 package because it is:

- already primary validated;
- fully preregistered;
- deterministic at the instance-generation layer;
- less interpretation-heavy than same-domain observational branches;
- simpler than threshold-local q-coloring calibration history.

This note is a runbook for what a clean external rerun should contain. It now
also has interim returned-run companions for the first two true outside-group
successes.

## 1. Scope

The replication target is the official Mixed-CSP primary, not:

- the aborted verifier attempt;
- the exact-one exploratory stress path;
- a modified model set;
- a new archive or new mixture family.

The replication claim is narrow:

```text
Can an independent rerun of the frozen Mixed-CSP primary recover the same
qualitative support decision and approximately the same held-out model ranking?
```

## 2. Canonical Source Files

Primary source files:

- `analysis/route_a_mixed_csp/mixed_csp_preregistration.md`
- `analysis/route_a_mixed_csp/run_mixed_csp.py`
- `analysis/route_a_mixed_csp/analyze_mixed_csp.py`
- `analysis/route_a_mixed_csp/mixed_csp_generator.py`
- `analysis/route_a_mixed_csp/mixed_csp_solvers.py`
- `analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py`
- `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`
- `analysis/route_a_mixed_csp/mixed_csp_results.json`
- `analysis/route_a_mixed_csp/README.md`

Reference raw primary artifact:

- `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`

Archived reference:

- OSF zip: <https://osf.io/download/69e826573b65e7b53bfd8b7e/>
- OSF manifest: <https://osf.io/download/69e8265a30357781bafd90d6/>

## 3. What The Replicator Should Reproduce

Minimum qualitative reproduction:

1. zero malformed encodings in the official primary path;
2. near-zero timeout pattern consistent with the official run;
3. held-out `L_plus_n` better than `raw_plus_n`;
4. `first_moment` better than `raw_plus_n`;
5. `L_plus_n` not worse than `cnf_count_plus_n`;
6. support flags:
   - `primary_supported = true`
   - `strong_support = true`
   - `theory_pure_support = true`
   - `encoding_guardrail_passed = true`

Target reference values from the official run:

| Metric | Official value |
|---|---:|
| rows total | `12000` |
| `L_plus_n` log loss | `0.0970` |
| `raw_plus_n` log loss | `0.7525` |
| `first_moment` log loss | `0.1489` |
| `cnf_count_plus_n` log loss | `0.1010` |
| relative improvement vs `raw_plus_n` | `0.8710774039644803` |

The replication standard is qualitative first, numeric second. Exact floating
identity is welcome but not required.

## 4. What May Vary

Allowed to vary across machines:

- wall-clock runtime;
- CPU / OS metadata;
- solver conflict / propagation counters;
- timestamps;
- incidental file paths;
- exact wall-clock ordering of append-safe writes.

Potentially acceptable small numeric variation:

- fitted logistic-regression coefficients;
- final log-loss values at very small tolerances if a solver / numeric-library
  version differs but all support flags and ordering stay the same.

Not allowed to vary:

- mixture grid;
- `n` grid;
- density grid;
- instances per cell;
- predictor set;
- leave-one-mixture-out split rule;
- primary / strong / theory-pure / encoding-guardrail decisions.

## 5. Recommended Replication Levels

### Level 1: Audit Replay

Goal:

```text
Confirm that the official artifacts are self-consistent and analyzable.
```

Actions:

1. inspect the preregistration and README;
2. verify the official JSONL / JSON / summary files exist and agree on row
   counts and support flags;
3. rerun only the analysis on the archived official primary JSONL.

Expected outcome:

The support flags and summary numbers match the checked-in reference artifacts.

### Level 2: Fresh Full Rerun

Goal:

```text
Regenerate the primary rows and recompute the official analysis from scratch.
```

Actions:

1. run smoke and encoding diagnostics;
2. run the primary generator / solver pipeline;
3. run the held-out analysis;
4. compare to the official reference.

This was the preferred first true replication target. As of the first returned
outside-group run, this target is no longer merely send-ready: it has one clean
outside-group success and two requested returns still pending.

## 6. Clean Execution Order

Recommended command order:

Install:

```bash
pip install -r requirements.txt
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

Encoding diagnostics:

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

The directory creation step is intentionally placed before smoke dry-run,
because `run_mixed_csp.py` appends directly to the requested JSONL path and
does not create missing parent directories on behalf of the caller.

## 7. Success Criterion For G7

For the purpose of program-level G7 progress, a replication should count as
successful if:

1. the official frozen design is followed without post-hoc redesign;
2. the fresh rerun reproduces the primary qualitative decision:
   `L_plus_n < raw_plus_n`;
3. the strong-support and theory-pure guardrails still pass;
4. no new encoding or timeout pathology appears that invalidates the original
   interpretation.

This criterion is intentionally stronger than "the script runs", but weaker
than "bitwise identical outputs".

## 8. What Does Not Count As Failure

The following should not automatically be classified as replication failure:

- slightly different runtime metadata;
- slightly different floating-point fit values with unchanged model ordering
  and unchanged support flags;
- different JSONL row ordering if the content is otherwise equivalent;
- absence of the exact-one stress extension, because it is not part of the
  primary validated package.

## 9. What Would Count As a Real Replication Problem

The following would be serious:

1. `L_plus_n` no longer beating `raw_plus_n`;
2. `first_moment` no longer beating `raw_plus_n`;
3. encoding guardrail failing;
4. recurrent malformed-encoding findings that undermine the fixed verifier;
5. timeout or solver-pathology rates high enough to change the interpretation.

Those outcomes would justify a dedicated replication report, not silent
dismissal.

## 10. Relation To Other Replication Targets

Mixed-CSP should go first.

After that:

1. Exp43c q-coloring replication is the next Route A target;
2. Backblaze v2 is a later observational replication target;
3. Exp44 should not enter G7 until it becomes a real validation package.

This preserves evidence-tier order:

```text
deterministic Route A primary -> harder Route A threshold-local primary ->
observational same-domain branch
```

## 11. Interim True Outside-Group Status

Current outside-group rerun status:

```text
requested outside-group reruns: 3
returned reruns: 2
clean returned successes: 2
pending reruns: 1
```

Returned runs:

- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`

Final report:

- `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`

The first returned run used a WSL/Ubuntu environment. The second returned run
used Windows 11 Home without WSL. The third returned run used Windows 11 Home
25H2. All three reported no workaround, returned the requested primary
artifacts, completed `12000` primary rows, reproduced all four support flags,
and matched the official primary on checked row-level core fields with `0`
mismatches.

The correct current wording is:

```text
Mixed-CSP true outside-group rerun set completed: three requested outside
executors returned clean 12,000-row primary runs with zero checked core-field
mismatches and all support flags true.
```

## 12. Non-Claims

This note does not claim:

1. G7 is already closed;
2. Mixed-CSP alone is enough for independent replication of the whole program;
3. exact numeric identity is required for a successful rerun;
4. observational anchors should be treated identically to Route A primaries.

It claims only:

```text
Mixed-CSP was the cleanest first external replication package and has now opened
G7 with two clean returned outside-group runs, while the requested return set and
Exp43c outside-group rerun remain open.
```
