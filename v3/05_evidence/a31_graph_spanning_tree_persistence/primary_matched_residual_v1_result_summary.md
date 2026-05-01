A31 Matched-Residual Primary v1 Result Summary
==============================================

Date executed: 2026-05-01 JST

Package:

```text
a31_graph_spanning_tree_persistence_matched_residual_v1
```

Domain:

```text
graph_spanning_tree_persistence
```

Decision:

```text
support
```


1. Frozen Question
------------------

This successor package asks a matched-residual question:

> Among current graph states matched on B1-style local robustness features, does
> the lower-\(\log\tau(G_t)\) tail have higher future collapse probability than
> the higher-\(\log\tau(G_t)\) tail?

The only primary matching key is `path_b05`.

This is not a reversal of the A31 primary_v0 no-support decision. Primary_v0
tested incremental log-loss improvement for a predictive model. This v1 package
tests residual ordering of collapse risk within matched local-robustness groups.


2. Frozen Surface
-----------------

Output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1
```

The generator script is named `generate_smoke.py` because it began as the A31
smoke harness. In this run, its path, content hash, command, seeds, and output
directory were pinned by the frozen v1 manifest before execution, so the
support-bearing status comes from the frozen manifest and evaluator, not from
the historical script name.

Generation summary:

```text
graph_count: 1080
state_count: 3215
future_path_count: 205760
future_trajectories_per_state: 64
label_count: 9645
n_values: 24,32,40
edge_factors: 2,3
kappas: 2,3
prefix_fractions: 0,0.05,0.10
horizon_fractions: 0.05,0.10,0.15
generator_seed: 95031
split_seed: 95041
```

Audits:

```text
spanning_tree_count_sanity: passed, 17 known-count cases
label_count_audit: passed, 9645 label rows / 3215 states
endpoint_degenerate: false
```

The final horizon was selected from train + validation graph-balanced
prevalence only:

```text
chosen_horizon_fraction: 0.15
calibration_graph_balanced_prevalence: 0.12661253375771606
test_graph_balanced_prevalence: 0.12594039351851852
```


3. Primary Result
-----------------

Held-out test result under the pre-frozen `path_b05` key:

```text
test_matched_group_count: 47
test_matched_state_count: 380
test_mean_low_minus_high: 0.03880762411347518
test_median_low_minus_high: 0.0234375
test_positive_group_count: 35
test_positive_group_rate: 0.7446808510638298
test_bootstrap_positive_rate: 1.0
```

Validation direction check:

```text
validation_mean_low_minus_high: 0.04826899509803921
validation_positive_group_rate: 0.8235294117647058
validation_direction_pass: true
```

Frozen support gates:

```text
validation_direction_positive: pass
test_matched_group_count >= 30: pass
test_mean_effect >= 0.03: pass
test_bootstrap_positive_rate >= 0.90: pass
endpoint_nondegenerate_and_audits_pass: pass
```

Result:

```text
primary_support: true
decision: support
```


4. Interpretation
-----------------

This package provides finite synthetic matched-residual support for the A31
spanning-tree persistence coordinate:

```text
current global redundancy log_tau(G_t)
```

Within graph-state groups matched on local robustness features, lower
\(\log\tau(G_t)\) states had higher future collapse probability than higher
\(\log\tau(G_t)\) states under the frozen deletion process.

This support is intentionally narrow. It supports the residual value of
\(\log\tau(G_t)\) in this finite synthetic A31-v1 package. It does not support
\(L_t\) alone, does not turn primary_v0 into support, and does not establish
real-world network robustness evidence.


5. Non-Claims
-------------

This result does not claim:

- reversal of A31 primary_v0 no-support;
- support for \(L_t\) alone;
- support for A12 cut-spectrum reliability;
- same-time connectivity prediction from a fully observed graph;
- exact reliability superiority;
- real-world network evidence;
- \(M\)-side validation;
- universal-law closure outside this finite graph package.


6. Artifact Hashes
------------------

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
