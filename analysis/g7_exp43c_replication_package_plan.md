# G7 Exp43c Replication Package Plan

Status: replication-planning note. Not a new empirical result and not a new
freeze document.

Status update:

```text
Level 2 local fresh rerun is now complete.
See analysis/exp43_qcoloring/exp43c_level2_rerun_note.md.
External handoff package is now complete.
See analysis/exp43_qcoloring/exp43c_external_rerun_package.md.
Published-remote outside-workspace rerun is now also complete.
See analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md.
Sender-side true outside-group packet is now prepared.
See analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md and
analysis/exp43_qcoloring/handoff_exports/返信が来たらやること.md.
External independent rerun return remains open.
```

Purpose:

Define the second Route A independent-replication target after Mixed-CSP.
Exp43c is the right next package because it is:

- a real frozen Route A primary;
- outside the SAT/NAE syntax of Mixed-CSP;
- already separated cleanly from its exploration history;
- stricter than a same-domain observational rerun.

The replication claim is narrow:

```text
Can an independent rerun of the frozen Exp43c q-coloring primary recover the
same qualitative support decision and roughly the same held-out predictor
ordering under the threshold-local design?
```

## 1. Scope

The replication target is the frozen Exp43c package only, not:

- Exp43 pilot_v1 or pilot_v2;
- Exp43b calibration no-go;
- alternative q grids;
- a new threshold-local protocol revision;
- any post-hoc q=5 redesign.

The package to rerun is:

```text
fresh Exp43c preregistration -> calibration closeout -> freeze package ->
primary generation -> frozen evaluation script
```

## 2. Canonical Source Files

Primary source files:

- `analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md`
- `analysis/exp43_qcoloring/exp43c_calibration_closeout.md`
- `analysis/exp43_qcoloring/exp43c_freeze_package.md`
- `analysis/exp43_qcoloring/exp43c_primary_report.md`
- `analysis/exp43_qcoloring/config/exp43c_primary_config.json`
- `analysis/exp43_qcoloring/src/primary_manifest.py`
- `analysis/exp43_qcoloring/src/pilot_runner.py`
- `analysis/exp43_qcoloring/src/evaluate_primary.py`
- `analysis/exp43_qcoloring/src/generator.py`
- `analysis/exp43_qcoloring/src/cnf_encoder.py`
- `analysis/exp43_qcoloring/src/solver.py`
- `analysis/exp43_qcoloring/src/feature_extractor.py`

Primary raw artifacts referenced by the freeze package:

- `analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl`
- `analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl`
- `analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json`

The freeze package records the hashes of those generated artifacts.

## 3. What The Replicator Should Reproduce

Minimum qualitative reproduction:

1. primary manifest size `4000` rows;
2. zero malformed encodings in the primary;
3. zero timeouts in the official tractable design, or at least no runtime
   instability that changes the interpretation;
4. `fm_plus_n` better than the best preregistered primary raw baseline;
5. `first_moment` better than the best raw baseline;
6. `fm_plus_n` not worse than `cnf_count_plus_n_q`;
7. H1 fold direction passes for held-out q = 3, 4, 5.

Target reference values from the official primary:

| Metric | Official value |
|---|---:|
| records | `4000` |
| SAT | `2003` |
| UNSAT | `1997` |
| TIMEOUT | `0` |
| MALFORMED | `0` |
| `fm_plus_n` mean held-out log loss | `0.440189` |
| best primary raw baseline | `2.804019` |
| relative improvement | `84.3%` |
| `first_moment` mean held-out log loss | `0.446814` |
| `cnf_count_plus_n_q` mean held-out log loss | `7.700105` |

Held-out q fold targets:

| held-out q | `fm_plus_n` | best raw baseline | direction |
|---:|---:|---:|---|
| 3 | `0.570528` | `5.071990` | pass |
| 4 | `0.323388` | `2.901932` | pass |
| 5 | `0.426651` | `0.438133` | pass, narrow |

## 4. What May Vary

Allowed to vary across machines:

- wall-clock runtime;
- CPU / OS metadata;
- solver internal counters;
- timestamps;
- JSONL row ordering if content is equivalent.

Potentially acceptable small numeric variation:

- logistic-regression coefficients;
- floating-point log-loss values at small tolerances if library versions differ,
  provided the model ordering and support flags are unchanged.

Not allowed to vary:

- selected q/n units:
  - q=3, n=80
  - q=4, n=80
  - q=5, n=60
- rho windows:
  - q=3: `0.76,0.78,0.80,0.82,0.84,0.86,0.88`
  - q=4: `0.78,0.80,0.82,0.84,0.86,0.88,0.90`
  - q=5: `0.76,0.78,0.80,0.82,0.84,0.86`
- instances per cell: `200`
- timeout policy: `120 sec`
- predictor family and decision rules;
- leave-one-q-out split.

## 5. Recommended Replication Levels

### Level 1: Audit Replay

Goal:

```text
Confirm that the freeze package, report, and generated artifacts are
self-consistent.
```

Actions:

1. inspect phase-status and freeze package;
2. verify manifest / results / evaluation file existence and hashes if raw
   artifacts are available;
3. verify that report numbers match the frozen evaluation JSON.

### Level 2: Fresh Full Rerun

Goal:

```text
Regenerate the Exp43c manifest, primary rows, and held-out evaluation from
scratch under the frozen package.
```

Actions:

1. regenerate the manifest from the frozen config;
2. run the primary solver pipeline on the frozen grid;
3. run the frozen evaluation script;
4. compare outcomes to the official report.

This target is now complete locally and remains the next clean outside
Route A rerun after Mixed-CSP. The sender-side zip packet is now prepared; the
open step is actual outside execution and return.

## 6. Clean Execution Order

Recommended command order:

Manifest regeneration:

```bash
python3 analysis/exp43_qcoloring/src/primary_manifest.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_manifest_external.jsonl
```

Primary rerun:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_external.jsonl \
  run --execute
```

Frozen evaluation:

```bash
python3 analysis/exp43_qcoloring/src/evaluate_primary.py \
  analysis/exp43_qcoloring/replication_outputs/exp43c_primary_results_external.jsonl \
  --output analysis/exp43_qcoloring/replication_outputs/exp43c_primary_evaluation_external.json
```

Recommended hygiene:

```bash
mkdir -p analysis/exp43_qcoloring/replication_outputs
printf '*\n!.gitignore\n' > analysis/exp43_qcoloring/replication_outputs/.gitignore
```

## 7. Success Criterion For G7

For program-level G7 progress, an Exp43c replication should count as successful
if:

1. the frozen Exp43c package is followed without redesign;
2. `fm_plus_n` still beats the best preregistered primary raw baseline;
3. the strong-support and encoding-guardrail directions still pass;
4. no new runtime or encoding pathology changes the interpretation;
5. held-out q = 3 / 4 / 5 still preserve the H1 direction.

This criterion is intentionally stronger than "the script runs", but weaker
than exact floating identity.

## 8. What Does Not Count As Failure

The following should not automatically count as replication failure:

- slightly different wall-clock metadata;
- small floating-point drift with unchanged model ordering;
- minor JSON ordering changes;
- the fact that q=5 remains narrow.

The narrow q=5 fold is part of the official result and should be preserved as a
qualified success, not treated as an unexpected defect.

## 9. What Would Count As A Real Replication Problem

Serious replication problems would include:

1. `fm_plus_n` no longer beating the best raw baseline;
2. `first_moment` no longer beating the raw baselines;
3. `fm_plus_n` losing to `cnf_count_plus_n_q`;
4. recurrent malformed encodings in the frozen grid;
5. timeout / runtime instability large enough to remove a q from cross-q
   interpretation.

Those would justify a dedicated replication report rather than quiet dismissal.

## 10. Relation To Other Replication Targets

The intended Route A replication order remains:

1. Mixed-CSP Level 1 -> Level 2;
2. Exp43c q-coloring;
3. observational branches such as Backblaze v2.

This preserves evidence-tier order:

```text
deterministic mixed-family primary -> threshold-local Route A primary ->
observational same-domain branch
```

## 11. Non-Claims

This note does not claim:

1. Exp43c replication is already complete;
2. threshold-local q-coloring alone is enough for G7 closure;
3. exact numeric identity is required;
4. Backblaze-style observational reruns should be treated the same as Route A
   primaries.
