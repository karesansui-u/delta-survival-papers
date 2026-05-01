A31 Matched Residual Freeze Manifest v1
=======================================

Status: frozen protocol before primary execution; not validation evidence by
itself.

Date frozen: 2026-05-01 JST

manifest_id: a31_graph_spanning_tree_persistence_matched_residual_v1

domain_id: graph_spanning_tree_persistence

Repository HEAD at freeze:

```text
7247a3d693fb8d399358299fcbc9b678b21bedcb
```

Note: the A31-v1 files are newly staged-in-worktree material in this session.
For this freeze, the content SHA256 values below are authoritative for the
generator and evaluator used by the primary command.


1. Frozen Claim
---------------

Primary claim to evaluate:

> Among current graph states matched on B1-style local robustness features, the
> lower-\(\log\tau(G_t)\) tail has higher future collapse probability than the
> higher-\(\log\tau(G_t)\) tail.

Claim strength if passed:

- matched-residual support for A31 in this finite synthetic graph package only;
- support for current global redundancy \(\log\tau(G_t)\), not \(L_t\) alone;
- not a reversal of the A31 primary_v0 no-support decision;
- not A12 cut-spectrum reliability support;
- not real-world network evidence;
- not \(M\)-side validation.


2. Frozen Scripts
-----------------

Generator:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py
```

Generator SHA256:

```text
ad4686cf3c5e11b4f8e57fe1ff196fcb790acf942b28a4c94431503ed899c3d0
```

Evaluator:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_matched_residual_v1.py
```

Evaluator SHA256:

```text
9e671697da48c906c78e6637371bfca75e684f02711001252bf3a9249b9f0507
```

Design draft:

```text
05_evidence/a31_graph_spanning_tree_persistence/matched_residual_v1_draft.md
```

Design draft SHA256 at freeze:

```text
e2b94bbac625e3538f661dd58afee93f3c4235ef2f3490707617536821f0bb19
```


3. Frozen Surface
-----------------

The v1 primary surface is independent from A31 primary_v0. It uses different
generator and split seeds and writes to a separate output directory.

Primary grid:

```text
n-values:             24,32,40
edge-factors:         2,3
kappas:               2,3
candidate-count:      240
graphs-per-stratum:   30
prefix-fractions:     0,0.05,0.10
horizon-fractions:    0.05,0.10,0.15
future-trajectories:  64
generator-seed:       95031
split-seed:           95041
max-attempts:         1000
```

The graph generator is the same exact Matrix-Tree / Bareiss generator used for
A31 primary_v0, but with the independent seeds above.


4. Frozen Primary Key
---------------------

The only primary matched-residual key is `path_b05`:

```text
n
et
kappat
bridge_count
min_degree
diameter
avg_shortest_path_length_bucket_0.5
```

Other keys are not part of this primary v1 run.

Group-retention rule:

```text
minimum group size:       4 states
minimum log_tau spread:   0.5
low tail:                 bottom third by log_tau, at least one state
high tail:                top third by log_tau, at least one state
group effect:             mean(collapse_fraction_low) - mean(collapse_fraction_high)
```

A positive group effect means the lower-spanning-tree-mass tail collapsed more
often than the matched higher-spanning-tree-mass tail.


5. Frozen Endpoint And Horizon Rule
-----------------------------------

Primary endpoint:

```text
future disconnection within h deletion steps
```

Each prediction state has exactly \(K=64\) future deletion trajectories.

Before matched evaluation, the evaluator must audit:

- all state-level K values agree with `future_paths.csv`;
- every `labels_by_horizon.csv` count `z` equals the recomputed count from
  `future_paths.csv`.

Final horizon selection:

- use train + validation labels only;
- use graph-balanced collapse prevalence only;
- choose the smallest candidate horizon with calibration prevalence in
  \([0.10,0.90]\);
- do not inspect matched effects, bootstrap results, or test labels for horizon
  selection.

Frozen test-stage endpoint degeneracy:

- if graph-balanced test collapse prevalence is below 0.02 or above 0.98,
  report `no_support_endpoint_degeneracy`.


6. Frozen Support Rule
----------------------

Primary support is true only if all of the following hold:

1. Validation direction check: validation mean matched group effect is positive.
2. Held-out test matched group count is at least 30 under `path_b05`.
3. Held-out test mean matched group effect is at least 0.03.
4. A paired bootstrap over held-out test matched groups with 2,000 frozen-seed
   replicates assigns positive mean group effect in at least 90 percent of
   replicates.
5. Endpoint is nondegenerate and label audits pass.

Bootstrap:

```text
replicates: 2000
bootstrap-seed: 95051
```

No-support:

- any primary support gate fails;
- frozen test-stage endpoint degeneracy occurs.

Invalid-run:

- schema mismatch;
- label-count audit failure;
- K inconsistency;
- spanning-tree count sanity failure;
- implementation error that invalidates generated labels.


7. Frozen Commands
------------------

Primary output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1
```

Generation command:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1 \
  --n-values 24,32,40 \
  --edge-factors 2,3 \
  --kappas 2,3 \
  --candidate-count 240 \
  --graphs-per-stratum 30 \
  --prefix-fractions 0,0.05,0.10 \
  --horizon-fractions 0.05,0.10,0.15 \
  --future-trajectories 64 \
  --seed 95031 \
  --split-seed 95041 \
  --max-attempts 1000
```

Evaluation command:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_matched_residual_v1.py \
  --input-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1 \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1 \
  --min-group-size 4 \
  --min-logtau-spread 0.5 \
  --tail-fraction 0.3333333333333333 \
  --test-min-groups 30 \
  --effect-threshold 0.03 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 95051
```


8. Expected Artifacts
---------------------

Generation:

```text
graphs.csv
states.csv
future_paths.csv
labels_by_horizon.csv
spanning_tree_count_sanity.json
generation_summary.json
```

Evaluation:

```text
horizon_diagnostics.csv
matched_group_effects.csv
matched_residual_summary.csv
evaluation_summary.json
```


9. Non-Claims
-------------

This manifest does not claim:

- support before the frozen primary commands are executed;
- support for A31 primary_v0;
- support for \(L_t\) alone;
- support for A12 cut-spectrum reliability;
- real-world network robustness;
- a new graph invariant;
- same-time connectivity prediction;
- exact reliability superiority;
- \(M\)-side validation;
- universal-law closure.
