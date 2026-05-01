A31 Graph Spanning-Tree Persistence Primary Result v0
=====================================================

Status: no_support under the frozen primary rule.

Date executed: 2026-05-01 JST

manifest_id: a31_graph_spanning_tree_persistence_v0

domain_id: graph_spanning_tree_persistence

Freeze manifest:

```text
05_evidence/a31_graph_spanning_tree_persistence/freeze_manifest_v0.md
```

Freeze manifest SHA256:

```text
90bea871e7d69219fa6dff71d05f6ee326f361e68afa5fe75075fd77fa812c31
```

Raw evaluator status strings retain the development script wording
`smoke_evaluated_not_evidence`. Governance status for this output is determined
by the frozen manifest above: this is the frozen primary v0 run, and it is
no-support.


1. Frozen Surface
-----------------

Primary output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/primary_v0
```

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
bootstrap-replicates: 2000
bootstrap-seed:       91051
```

Generated surface:

```text
graphs:       360
states:       1065
future paths: 68160
label rows:   3195
```

Sanity / audit checks:

```text
spanning-tree count sanity: passed, 17 cases
label count audit:         passed, 3195 label rows / 1065 states
endpoint degenerate:       false
```


2. Horizon Selection
--------------------

The frozen rule chose the smallest nondegenerate calibration horizon.

| horizon fraction | calibration graph-balanced prevalence | nondegenerate |
|---:|---:|---|
| 0.05 | 0.02152054398148148 | false |
| 0.10 | 0.05999529803240741 | false |
| 0.15 | 0.12110279224537039 | true |

Chosen horizon:

```text
0.15
```

Test graph-balanced prevalence:

```text
0.12930410879629628
```


3. Primary Metrics
------------------

Primary metric: graph-id grouped binomial held-out test log loss.

| model | test log loss |
|---|---:|
| B0 | 0.3940797206133687 |
| B1 | 0.3761771702314387 |
| B1_logtau | 0.3759532428766473 |
| B1_L | 0.3761784215026037 |
| B1_SP_bundle | 0.37595605918619335 |
| B2_guardrail | 0.3753116426412072 |

Primary comparison:

```text
B1:            0.3761771702314387
B1_SP_bundle: 0.37595605918619335
relative improvement: 0.0005877843280848836
bootstrap positive rate: 0.9125
```


4. Support Decision
-------------------

Frozen primary rule:

1. \(B1\_SP\_bundle\) lower test log loss than \(B1\): passed.
2. Relative log-loss improvement at least 1 percent: failed.
3. Paired graph-id bootstrap positive rate at least 90 percent: passed.
4. Oracle-exclusion and label audits: passed.

Decision:

```text
no_support
```

Reason:

```text
B1_SP_bundle improves over B1 by only 0.0588 percent, below the frozen
1 percent improvement threshold.
```

This is not support for A31 incremental prediction value. It does preserve the
specification-fixed accounting anchor: \(\mathcal{T}(G_t)\), \(\tau(G_t)\),
\(L_t\), and the zero-mass collapse boundary remain exactly defined by finite
graph structure.


5. Interpretation Boundary
--------------------------

Primary v0 should be read as a boundary-setting result, not as a failure of the
exact anchor. A31 supplies a global redundancy coordinate: it counts how many
spanning-tree backbones remain in the current graph. The primary v0 endpoint,
however, was short-horizon future disconnection under edge deletion. That target
is often governed by local low-order cutsets, bridges, and min-cut proximity.

Accordingly, this result separates two roles:

- A31 remains an exact accounting anchor and global redundancy coordinate.
- Short-horizon disconnection probability is better treated as an A12-style
  cut-spectrum / reliability prediction problem.

The no-support decision therefore blocks the stronger claim that
\(\log\tau(G_t)+L_t\) is a generic incremental predictor of near-term collapse
over a natural graph baseline. It does not block using A31 as a
specification-fixed graph anchor.


6. Artifact Checksums
---------------------

```text
2c2c5a4ae7693f0ddb015284086fa9d18775f81bc75a28aa39b24545213e550c  generation_summary.json
b628626b6935a8f3459e0522cc73e7aff11aa37bdf7a35a870550fd7611295fd  evaluation_summary.json
2f4c5c83764cedea132c413c56942ff018e0bfd42307b8a25d351b370e1ff6c4  model_metrics.csv
e9cd9c9d16a842822357ed4158079599802e1e8d4b83858321c82f5f7d1c45a9  horizon_diagnostics.csv
00eb54616569e1a140299c412c0e88c034780c7282075836199bcb20a4fec1ac  spanning_tree_count_sanity.json
```


7. Non-Claims
-------------

This result does not support:

- A31 incremental empirical support under primary v0;
- \(L_t\) alone as a supported coordinate;
- real-world network robustness;
- A12 cut-spectrum reliability;
- \(M\)-side validation;
- universal-law closure.
