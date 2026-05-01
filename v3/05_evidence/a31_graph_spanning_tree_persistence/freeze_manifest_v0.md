A31 Graph Spanning-Tree Persistence Freeze Manifest v0
======================================================

Status: frozen protocol before primary execution; not validation evidence by
itself.

Date frozen: 2026-05-01 JST / 2026-04-30T16:51:41Z

manifest_id: a31_graph_spanning_tree_persistence_v0

domain_id: graph_spanning_tree_persistence

Repository HEAD at freeze:

```text
7247a3d693fb8d399358299fcbc9b678b21bedcb
```

Note: the A31 files are newly staged-in-worktree material in this session. For
this freeze, the content SHA256 values below are authoritative for the generator
and evaluator used by the primary command.


1. Frozen Claim
---------------

Primary claim to evaluate:

> Under a pre-fixed loss-only edge deletion process on finite synthetic graphs,
> the natural graph baseline plus the frozen spanning-tree persistence bundle
> improves held-out future collapse-probability prediction over the same natural
> graph baseline alone.

Claim strength if passed:

- incremental support for this finite synthetic graph package only;
- specification-fixed prediction support, not real-world network evidence;
- support for the pre-frozen SP bundle, not automatically for \(L_t\) alone;
- not a new graph invariant claim;
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
05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_smoke.py
```

Evaluator SHA256:

```text
47818deb80570490db56af0c44a6d30744ec20d1dd550030d1724e5f22659be4
```

Protocol draft parent:

```text
05_evidence/graph_spanning_tree_persistence_freeze_manifest_draft.md
```

Protocol draft SHA256 at freeze:

```text
aac22f718dc2d9e3d44d10368195710c2934aaf2cf5cf80b1544566bc40d3ead
```


3. Frozen Data Surface
----------------------

Synthetic finite, simple, undirected graphs only.

Primary grid:

```text
n-values:             24,32,40
edge-factors:         2,3
kappas:               2,3
candidate-count:      120
graphs-per-stratum:   10
prefix-fractions:     0,0.05,0.10
horizon-fractions:    0.05,0.10,0.15
future-trajectories:  64
generator-seed:       91031
split-seed:           91041
max-attempts:         800
```

Retained graph ids are selected as low / middle / high \(\log\tau(G_0)\) strata
inside each \((n,e_0,\kappa)\) cell, with 10 graph ids per stratum.

Split:

- seeded random permutation within each
  \((n,e_0,\kappa,\log\tau\text{-stratum})\) cell;
- validation count \(=\lfloor0.2N_{\mathrm{cell}}\rfloor\), at least 1;
- test count \(=\lfloor0.2N_{\mathrm{cell}}\rfloor\), at least 1;
- train receives the remainder.


4. Frozen Structural Coordinates
--------------------------------

The support-bearing generator must compute spanning-tree counts by the
Matrix-Tree theorem with an exact integer Bareiss determinant on the Laplacian
cofactor.

Required sanity artifact:

```text
spanning_tree_count_sanity.json
```

The sanity artifact must pass known-count checks for:

- path graphs, \(\tau(P_n)=1\);
- cycle graphs, \(\tau(C_n)=n\);
- complete graphs, \(\tau(K_n)=n^{n-2}\).

The v0 SP bundle is exactly:

```text
log_tau
L_t
```

No leave-one-edge sensitivity, cut-spectrum, low-order cutset, or other
spanning-tree-derived feature is allowed in the v0 primary comparison.


5. Frozen Baselines
-------------------

Simple baseline \(B0\):

```text
n, et, edge_density, deleted_edge_count, deleted_edge_fraction,
mean_degree, degree_variance
```

Natural graph baseline \(B1\):

```text
B0
min_degree, kappat, bridge_count, avg_shortest_path_length, diameter
```

Primary SP model:

```text
B1_SP_bundle = B1 + log_tau + L_t
```

Required attribution ablations:

```text
B1_logtau = B1 + log_tau
B1_L = B1 + L_t
B1_SP_bundle = B1 + log_tau + L_t
```

Wide guardrail:

```text
B2_guardrail = B1 + algebraic_connectivity + laplacian_spectral_radius
             + adjacency_spectral_gap + kirchhoff_index
             + betweenness_mean + betweenness_max + betweenness_std
```

The primary support comparison is \(B1\) versus \(B1\_SP\_bundle\).


6. Frozen Endpoint And Horizon Rule
-----------------------------------

Primary endpoint:

```text
future disconnection within h deletion steps
```

Each prediction state has exactly \(K=64\) future deletion trajectories.

Before model fitting, the evaluator must audit:

- all state-level K values agree with `future_paths.csv`;
- every `labels_by_horizon.csv` count `z` equals the recomputed count from
  `future_paths.csv`.

Final horizon selection:

- use train + validation labels only;
- use graph-balanced collapse prevalence only;
- do not inspect model performance;
- choose the smallest candidate horizon with calibration prevalence in
  \([0.10,0.90]\);
- if no candidate horizon is nondegenerate, report redesign-required before
  evaluation.

Frozen test-stage endpoint degeneracy:

- if graph-balanced test collapse prevalence is below 0.02 or above 0.98,
  report `no_support_endpoint_degeneracy`.


7. Frozen Model And Metric
--------------------------

Model class:

```text
L2-regularized logistic regression
solver = liblinear
C grid = 0.01,0.1,1,10
```

Selection / refit:

- select \(C\) by graph-id grouped validation binomial log loss;
- during validation selection, scaler is fit on train only;
- after selecting \(C\), refit scaler and model on train + validation;
- evaluate test once.

Primary metric:

```text
graph-id grouped binomial held-out test log loss
```

Training weights:

```text
w_{g,i,k} = 1 / (N_graphs * |I_g| * K_gi)
```

where \(K_{gi}\) is the audited future-path count for prediction state \(i\) of
graph \(g\).


8. Frozen Support Rule
----------------------

Primary support is true only if all of the following hold:

1. \(B1\_SP\_bundle\) has lower graph-id grouped held-out test log loss than
   \(B1\).
2. Relative log-loss improvement over \(B1\) is at least 1 percent.
3. A paired bootstrap over graph ids with 2,000 frozen-seed replicates assigns
   positive improvement \(B1 - B1\_SP\_bundle > 0\) in at least 90 percent of
   replicates.
4. Feature audit confirms no future edge realization, final connectivity,
   exact future reliability, or Monte Carlo target estimate is present in the
   feature table.

Bootstrap:

```text
replicates: 2000
bootstrap-seed: 91051
```

No-support:

- \(B1\_SP\_bundle\) fails the primary rule;
- frozen test-stage endpoint degeneracy occurs;
- any oracle-exclusion violation is found.

Invalid-run:

- schema mismatch;
- label-count audit failure;
- K inconsistency;
- spanning-tree count sanity failure;
- implementation error that invalidates generated labels.


9. Frozen Commands
------------------

Primary output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_v0
```

Generation command:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_v0 \
  --n-values 24,32,40 \
  --edge-factors 2,3 \
  --kappas 2,3 \
  --candidate-count 120 \
  --graphs-per-stratum 10 \
  --prefix-fractions 0,0.05,0.10 \
  --horizon-fractions 0.05,0.10,0.15 \
  --future-trajectories 64 \
  --seed 91031 \
  --split-seed 91041 \
  --max-attempts 800
```

Evaluation command:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_v0 \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/primary_v0 \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 91051
```


10. Expected Artifacts
----------------------

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
model_metrics.csv
evaluation_summary.json
```


11. Non-Claims
--------------

This manifest does not claim:

- support before the frozen primary commands are executed;
- real-world network robustness;
- a new graph invariant;
- same-time connectivity prediction;
- exact reliability superiority;
- \(M\)-side validation;
- support for \(L_t\) alone unless the \(B1+L_t\) ablation independently passes
  the same frozen support rule;
- support for A12 cut-spectrum reliability;
- universal-law closure.
