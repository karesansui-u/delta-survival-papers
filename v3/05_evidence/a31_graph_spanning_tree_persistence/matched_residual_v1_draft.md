A31 Matched Residual v1 Draft
=============================

Status: draft / exploratory design; not frozen; not validation evidence.

Date opened: 2026-05-01 JST

manifest_id: a31_graph_spanning_tree_persistence_matched_residual_v1

domain_id: graph_spanning_tree_persistence


1. Purpose
----------

Primary v0 tested whether a natural graph baseline plus the spanning-tree
persistence bundle improved short-horizon future disconnection prediction over
the same baseline. It did not pass the frozen 1 percent improvement gate.

The main lesson was not that the spanning-tree accounting anchor failed. The
lesson was that short-horizon disconnection is heavily controlled by local
cut-like quantities already present in \(B1\), especially bridge count,
current edge connectivity, path length, and diameter.

This v1 draft therefore asks a narrower residual question:

> Among current graph states that are matched on natural local robustness
> features, does higher \(\log\tau(G_t)\) still correspond to lower future
> collapse risk or better robustness?

This is not a rescue of primary_v0. It is a successor question motivated by the
primary_v0 no-support result.


2. Structural Coordinate
------------------------

The A31 specification-fixed coordinate remains unchanged:

\[
  \mathcal{T}(G_t)=
  \{T\subseteq E_t:T\text{ is a spanning tree on the fixed vertex set }U\},
  \qquad
  m(\mathcal{T}(G_t))=\tau(G_t).
\]

The residual coordinate tested in v1 is:

\[
  x_t=\log\tau(G_t).
\]

\(L_t=-\log(\tau(G_t)/\tau(G_0))\) may be recorded, but the v1 residual claim is
primarily about current global redundancy \(\log\tau(G_t)\), not past loss
history.


3. Matched Residual Surface
---------------------------

Before any support-bearing run, define a frozen matching key from current graph
features only. The v1 primary key is fixed as `path_b05`:

```text
n
et
kappat
bridge_count
min_degree
diameter
avg_shortest_path_length_bucket_0.5
```

where `avg_shortest_path_length_bucket_0.5` is the average shortest path length
rounded to the nearest 0.5.

Other matching keys, including `strict` and `coarse_diam`, are diagnostic only.
They cannot be promoted to primary after inspecting exploratory or validation
outcomes.

Within each matched key, retain only groups satisfying frozen minimum support
conditions, for example:

```text
minimum group size:       4 states
minimum log_tau spread:   0.5
```

Within each retained group, compare the low-\(\log\tau\) and high-\(\log\tau\)
tails. Candidate exploratory rule:

```text
low tail:  bottom third by log_tau, at least one state
high tail: top third by log_tau, at least one state
group effect = mean(collapse_fraction_low) - mean(collapse_fraction_high)
```

A positive group effect means that the lower-spanning-tree-mass states collapse
more often than the matched higher-spanning-tree-mass states.


4. Candidate Endpoints
----------------------

Candidate v1 primary endpoints:

- future disconnection probability within a pre-frozen horizon, evaluated only
  after B1-style matching;
- expected collapse time or long-horizon robustness ranking, if the generator
  is extended beyond the primary_v0 binary horizon labels.

The first v1 smoke uses the existing primary_v0 row surface only as exploratory
design data. It cannot be counted as validation evidence because the v1 question
was formulated after seeing primary_v0.

Any support-bearing v1 run must use an independent graph surface from
primary_v0, with separate seeds and newly frozen commands. The primary_v0 rows
may only be used to calibrate the existence of a feasible matched-residual
surface and to design structural-only gates.


5. Candidate Support Rule
-------------------------

A support-bearing v1 package must use newly frozen generation and evaluation
commands. It must not relabel primary_v0 as support.

Candidate support gates before final freeze:

1. The pre-frozen `path_b05` primary key yields at least 30 matched groups in
   the held-out test split.
2. The mean matched group effect is positive and at least a pre-frozen effect
   threshold.
3. A paired bootstrap over matched groups assigns positive mean group effect in
   at least 90 percent of bootstrap replicates.
4. A direction check holds in the validation split before test evaluation.
5. The result is not driven by any future edge realization, final connectivity,
   exact future reliability, or Monte Carlo target estimate used as a feature.

The final effect-size threshold must be frozen before outcome-bearing labels are
generated. The exploratory smoke below is only for checking that the matched
surface exists and that the analysis pipeline works.

The primary v1 surface should be sized from structural-only calibration before
freeze. If the structural calibration cannot plausibly yield at least 30
held-out `path_b05` matched groups under the frozen split rule, the package
should be marked redesign-required before outcome-bearing labels are generated.


6. Exploratory Smoke
--------------------

Exploratory script:

```text
05_evidence/a31_graph_spanning_tree_persistence/scripts/analyze_matched_residual_v1.py
```

Exploratory output directory:

```text
05_evidence/a31_graph_spanning_tree_persistence/matched_residual_smoke_v1
```

Expected outputs:

```text
matched_group_effects.csv
matched_residual_summary.json
```

Interpretation discipline:

- positive exploratory results may motivate a frozen v1 package;
- negative exploratory results should be recorded as design feedback;
- no exploratory result may be entered into `frozen_packages.tsv` as support;
- `all` split summaries are surface diagnostics only and must not be used as a
  support claim;
- validation summaries may be used only for a pre-declared direction check;
- held-out test summaries are the only split-level summaries eligible for a v1
  primary support decision.


7. Non-Claims
-------------

This draft does not claim:

- support for A31-v1;
- reversal of the primary_v0 no-support decision;
- support for \(L_t\) alone;
- support for A12 cut-spectrum reliability;
- real-world network robustness;
- a new graph invariant;
- \(M\)-side validation;
- universal-law closure outside the finite graph setting.
