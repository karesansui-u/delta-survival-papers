A31 Matched-Residual Replication Packet v1 Plan
===============================================

status: replication_packet_plan_not_evidence

date: 2026-05-01 JST

domain_id: graph_spanning_tree_persistence

package_id: a31_graph_spanning_tree_persistence_matched_residual_v1

This memo defines a rerun-ready packet plan for the supported A31
matched-residual v1 finite graph package. It does not create new evidence and
does not change the existing support / no-support decisions.

The purpose is to make A31 v1 easy to rerun while preserving the boundary
between:

- A31 primary_v0 no-support for the original incremental log-loss prediction
  task;
- A31 matched-residual v1 support for the narrower `log_tau` residual ordering
  question;
- A12 cut-spectrum reliability support, which is a separate domain package.


1. Current Evidence Record
--------------------------

Primary v1 support record:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1_result_summary.md
```

Frozen manifest:

```text
05_evidence/a31_graph_spanning_tree_persistence/freeze_manifest_matched_residual_v1.md
```

Primary v1 decision:

```text
decision: support
primary_key: path_b05
chosen_horizon_fraction: 0.15
test_matched_group_count: 47
test_matched_state_count: 380
test_mean_low_minus_high: 0.03880762411347518
test_bootstrap_positive_rate: 1.0
validation_mean_low_minus_high: 0.04826899509803921
```

Primary_v0 record:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_result_summary.md
decision: no_support
reason: B1_SP_bundle improved over B1 by 0.0588 percent, below the frozen
        1 percent relative log-loss improvement threshold.
```


2. Claim Boundary
-----------------

The supported A31 v1 claim is:

> Among current graph states matched on B1-style local robustness features,
> the lower-\(\log\tau(G_t)\) tail has higher future collapse probability than
> the higher-\(\log\tau(G_t)\) tail.

This is a matched-residual support claim for the current global redundancy
coordinate:

```text
log_tau(G_t)
```

The claim is intentionally narrow. It is not:

- support for A31 primary_v0;
- support for \(L_t\) alone;
- A12 cut-spectrum reliability support;
- same-time connectivity prediction from a fully observed graph;
- exact reliability superiority;
- real-world network robustness evidence;
- a new graph invariant;
- \(M\)-side validation.


3. Exact Anchor Versus Prediction Question
------------------------------------------

The exact specification-fixed A31 anchor is:

```text
V(G) = spanning trees of G
m(V) = tau(G)
collapse boundary: tau(G) = 0 iff G is disconnected
```

The matched-residual v1 package is not a same-time connectivity oracle. It
uses the current observed graph state \(G_t\), matches graph states on local
robustness features, and asks whether the lower-\(\log\tau(G_t)\) tail has
higher future collapse probability under the frozen future edge-deletion
process.

Therefore:

- exact spanning-tree accounting remains an anchor;
- primary_v0 no-support remains visible;
- v1 support is a successor question about residual ordering value;
- A12 remains the package for low-order \(s\)-\(t\) cut-spectrum reliability.


4. Frozen Surface
-----------------

The v1 primary surface is independent from A31 primary_v0. It uses a separate
output directory and independent generation / split / bootstrap seeds.

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
bootstrap-replicates: 2000
bootstrap-seed:       95051
```

Observed output counts from the original support-bearing run:

```text
graph_count:       1080
state_count:       3215
future_path_count: 205760
label_count:       9645
```

Rows are split by graph id / graph state structure using the frozen seeded
permutation within `(n, e0, kappa, tau_stratum)` cells, not by future
trajectory.


5. Primary Key And Endpoint
---------------------------

The only support-bearing matched-residual key is:

```text
path_b05
```

It matches states on:

```text
n
et
kappat
bridge_count
min_degree
diameter
avg_shortest_path_length_bucket_0.5
```

Other keys, including `strict`, `coarse_diam`, and `all`, are diagnostics only.

Primary endpoint:

```text
future disconnection within h deletion steps
```

Horizon selection:

- use train + validation labels only;
- use graph-balanced collapse prevalence only;
- choose the smallest candidate horizon with calibration prevalence in
  `[0.10,0.90]`;
- do not inspect matched effects, bootstrap results, or held-out test labels
  for horizon selection.

Expected selected horizon from the original run:

```text
chosen_horizon_fraction: 0.15
calibration_graph_balanced_prevalence: 0.12661253375771606
test_graph_balanced_prevalence: 0.12594039351851852
```


6. Script Hashes
----------------

Generator:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py
sha256: ad4686cf3c5e11b4f8e57fe1ff196fcb790acf942b28a4c94431503ed899c3d0
```

Evaluator:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_matched_residual_v1.py
sha256: 9e671697da48c906c78e6637371bfca75e684f02711001252bf3a9249b9f0507
```

Design-smoke analyzer, diagnostic only:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/analyze_matched_residual_v1.py
sha256: 129b1be64efb08e083ec3ff3a96af66c38bb26331b7be35b80dff922954b17b1
```

An outside rerun should verify these hashes or explicitly report hash drift
before execution.


7. Minimal Rerun Commands
-------------------------

A clean rerun should write to a new output directory and should not overwrite
the committed primary output.

Recommended output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/rerun_matched_residual_v1_local
```

Generation:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/generate_smoke.py \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/rerun_matched_residual_v1_local \
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

Evaluation:

```bash
python3 -B 05_evidence/a31_graph_spanning_tree_persistence/scripts/evaluate_matched_residual_v1.py \
  --input-dir 05_evidence/a31_graph_spanning_tree_persistence/rerun_matched_residual_v1_local \
  --output-dir 05_evidence/a31_graph_spanning_tree_persistence/rerun_matched_residual_v1_local \
  --min-group-size 4 \
  --min-logtau-spread 0.5 \
  --tail-fraction 0.3333333333333333 \
  --test-min-groups 30 \
  --effect-threshold 0.03 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 95051
```


8. Expected Output Schema
-------------------------

The rerun output directory should contain:

```text
graphs.csv
states.csv
future_paths.csv
labels_by_horizon.csv
spanning_tree_count_sanity.json
generation_summary.json
horizon_diagnostics.csv
matched_group_effects.csv
matched_residual_summary.csv
evaluation_summary.json
```

The original primary output also has row-level artifacts:

```text
primary_matched_residual_v1 size: 16M
graphs.csv rows including header: 1081
states.csv rows including header: 3216
future_paths.csv rows including header: 205761
labels_by_horizon.csv rows including header: 9646
matched_group_effects.csv rows including header: 373
```


9. Expected Decision Checks
---------------------------

The rerun should reproduce the support decision if:

- spanning-tree count sanity passes;
- label count audit passes;
- every state has exactly \(K=64\) future trajectories;
- endpoint is nondegenerate;
- validation mean matched group effect is positive;
- held-out test matched group count is at least 30 under `path_b05`;
- held-out test mean low-minus-high effect is at least 0.03;
- paired bootstrap over held-out test matched groups is positive in at least
  90 percent of 2,000 replicates.

Expected numeric values from the original run:

```text
chosen_horizon_fraction:       0.15
test_matched_group_count:      47
test_matched_state_count:      380
test_mean_low_minus_high:      0.03880762411347518
test_median_low_minus_high:    0.0234375
test_positive_group_rate:      0.7446808510638298
test_bootstrap_positive_rate:  1.0
validation_mean_low_minus_high: 0.04826899509803921
validation_positive_group_rate: 0.8235294117647058
```

Exact numeric equality is expected when the same scripts, seeds, and runtime
behavior are used. If a different runtime produces small numeric drift, the
support decision, audit status, and matched-group gate status are the primary
comparison.


10. Artifact Hashes
-------------------

Original committed primary hashes:

```text
freeze_manifest_matched_residual_v1.md:
b349cc6a5b9cb5f57e01bfa346a52ed594355e8014700984d594323ee1d339e1

generation_summary.json:
97d282e2f151a703e1fc7e8a95bc71789b814248f9824ac707dedbbac4df987f

evaluation_summary.json:
6e9e4ec8f40dd146d7c125e6948673ca1fff327300e9bc38483ee1aaa652947a

matched_residual_summary.csv:
ffb29d57e7b649840c4fbf181bead7fba86587d94b915fd804b09dabfd96dbc0

horizon_diagnostics.csv:
22fba2ac58115fd304286886b4e5bac1bb48ad171401e4722989fc54ca978deb
```


11. Artifact Handling
---------------------

For future outside reruns, follow:

```text
04_operations/55_artifact_storage_policy.md
```

Recommended handling:

- keep manifest, result summary, script hashes, evaluation summary, and small
  diagnostics in Git;
- bundle large row-level artifacts such as `future_paths.csv` when needed;
- record bundle SHA256, byte size, included file list, and row counts;
- do not delete A31 primary_v0 no-support records from successor packages.


12. Rerun Outcome Categories
----------------------------

Use these categories for a rerun report:

```text
clean_reproduction:
  audits pass and support decision matches with no material numeric drift

decision_reproduction_with_numeric_drift:
  audits pass and support decision matches, but floating-point or runtime
  details produce small metric drift

schema_or_audit_failure:
  generated files exist, but schema, spanning-tree sanity, label-count, or K
  audit fails

generation_failure:
  the frozen graph surface cannot be regenerated

decision_mismatch:
  audits pass, but the support decision does not match
```

A decision mismatch should trigger a dedicated replication-failure note rather
than post-hoc retuning.


13. Outside-Rerun Packet Checklist
----------------------------------

Before sending this package outside, prepare:

1. this replication plan;
2. `freeze_manifest_matched_residual_v1.md`;
3. `primary_matched_residual_v1_result_summary.md`;
4. generator and evaluator scripts;
5. dependency / Python environment note;
6. expected output schema;
7. expected support decision;
8. artifact bundle policy;
9. mismatch reporting template;
10. a short note that primary_v0 remains no-support.


14. Non-Claims
--------------

This replication packet plan does not claim:

- a new support result;
- that outside reproduction has already happened;
- that primary_v0 has been rescued;
- that `strict`, `coarse_diam`, or `all` diagnostics are support-bearing;
- that exact spanning-tree accounting alone is prediction support;
- that A31 support transfers automatically to A12 or to real-world networks.
