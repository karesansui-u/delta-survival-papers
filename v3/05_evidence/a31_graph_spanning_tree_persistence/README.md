A31 Graph Spanning-Tree Persistence Smoke Harness
=================================================

Status: smoke tooling only; not frozen; not validation evidence.

This directory contains a generator/evaluator pair for the A31 graph
spanning-tree persistence package. The scripts are development/smoke tooling
unless their exact path, content hash, command, seeds, and output location are
pinned by a frozen manifest before outcome-bearing execution.

Files:

- `scripts/generate_smoke.py`: builds synthetic finite graphs, observed prefix
  deletion states, and future deletion trajectories.
- `scripts/evaluate_smoke.py`: evaluates the manifest-style comparison using
  graph-id grouped binomial log loss.
- `scripts/analyze_matched_residual_v1.py`: exploratory A31-v1 design smoke for
  matched residual value of `log_tau`; not validation evidence.
- `scripts/evaluate_matched_residual_v1.py`: support-bearing A31-v1 evaluator
  when pinned by a frozen manifest.
- `smoke_v0/`: local smoke outputs.

The smoke run is allowed to use a reduced grid for speed. Any support-bearing
run must first freeze the manifest, commit hash, generator/evaluator paths,
seed schedules, schemas, final graph cells, final horizon rule, and output
locations.

Current smoke harness notes:

- graph-id splits use a seed-random permutation within each
  `(n, e0, kappa, tau_stratum)` cell;
- split allocation is generic over cell size: validation and test receive
  `floor(0.2 * cell_size)` each, at least one graph id each, and train receives
  the remainder;
- spanning-tree counts use the Matrix-Tree theorem with an exact integer
  Bareiss determinant;
- `spanning_tree_count_sanity.json` records known-count checks for path, cycle,
  and complete graphs;
- `evaluate_smoke.py` checks that `labels_by_horizon.csv` and
  `future_paths.csv` agree on the fixed future trajectory count;
- `evaluate_smoke.py` also audits every horizon-level `z` count against
  `future_paths.csv`;
- final smoke models refit both scaler and logistic model on train +
  validation after selecting regularization on validation.

Smoke command used for `smoke_v0`:

```bash
python3 05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/smoke_v0

python3 05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a31_graph_spanning_tree_persistence/smoke_v0 \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/smoke_v0
```

The `smoke_v0` result is intentionally recorded as
`smoke_evaluated_not_evidence`.

Primary v0:

- freeze manifest: `freeze_manifest_v0.md`
- result summary: `primary_result_summary.md`
- output directory: `primary_v0/`
- decision: `no_support`
- reason: `B1_SP_bundle` improved over `B1` by 0.0588%, below the frozen 1%
  relative log-loss improvement threshold.

Matched residual v1:

- draft: `matched_residual_v1_draft.md`
- exploratory output: `matched_residual_smoke_v1/`
- freeze manifest: `freeze_manifest_matched_residual_v1.md`
- primary output: `primary_matched_residual_v1/`
- result summary: `primary_matched_residual_v1_result_summary.md`
- decision: `support`
- purpose: test whether `log_tau` has residual value inside graph-state groups
  matched on B1-style local robustness features.
- primary v1 key: `path_b05`.
- `strict`, `coarse_diam`, and `all` split summaries are diagnostics only.
- the primary support-bearing v1 run used an independent graph surface from
  `primary_v0` and passed the frozen held-out test matched-group gate.
- this is not a reversal of primary_v0; it is a narrower matched-residual
  support result for current `log_tau`.
