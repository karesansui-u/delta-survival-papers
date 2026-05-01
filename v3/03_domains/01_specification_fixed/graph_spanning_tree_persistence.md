Graph Spanning-Tree Persistence
===============================

domain_id: graph_spanning_tree_persistence

domain_name: Graph spanning-tree persistence

observability_layer: specification_fixed

status: no_support_primary_v0; supported_matched_residual_v1


1. Maintenance Target
---------------------

- Target structure: a finite undirected graph maintains connected spanning
  structure, read through the set of spanning trees.
- Failure / collapse boundary: the graph becomes disconnected, equivalently its
  spanning-tree count is zero.
- Observation unit: a finite graph \(G_t=(U,E_t)\) on a fixed vertex set \(U\),
  under a pre-fixed loss-only edge deletion process
  \(E_t\subseteq E_{t-1}\subseteq E_0\). Damage or failure means edge removal in
  this package; edge repair, edge addition, and weight changes require a
  separate recovery-aware package.
- Time horizon: frozen before validation.
- Initial condition: \(\tau(G_0)>0\).

This domain is intended as a pure \(L\)-side specification-fixed anchor. It is
not an \(M\)-component allocation test and does not use repair-resource claims.


2. Structural Coordinates
-------------------------

- \(\mathcal{T}(G_t)\): the set of spanning trees on the fixed vertex set \(U\)
  using only edges in \(E_t\). For the loss-only edge deletion process,
  \(\mathcal{T}(G_t)\subseteq\mathcal{T}(G_{t-1})\subseteq\mathcal{T}(G_0)\).
- \(m\): spanning-tree count \(\tau(G_t)\), computed by the Matrix-Tree theorem
  or an equivalent exact graph algorithm.
- \(d_t\): for positive spanning-tree counts before collapse,
  \[
  d_t=-\log\frac{\tau(G_t)}{\tau(G_{t-1})}.
  \]
  If \(\tau(G_t)=0\), the process has reached the absorbing collapse boundary;
  finite log updates stop at that boundary.
- \(r_t\): not primary. If edge repair or augmentation is introduced later, it
  must be modeled as a separate recovery-aware package with a frozen two-stage
  update.
- \(L\): cumulative spanning-tree mass loss before collapse,
  \[
  L_t=-\log\frac{\tau(G_t)}{\tau(G_0)}.
  \]
  At and after collapse, use the extended-real convention \(L_t=+\infty\).
- \(B\): not primary unless a later repair-aware update is frozen.
- \(M\)-side readout, if any: none.


3. Exact Accounting Anchor
--------------------------

The exact specification-fixed kernel is:

\[
\mathcal{T}(G_t)=\{\text{spanning trees on }U\text{ using edges in }E_t\},
\qquad
m(\mathcal{T}(G_t))=\tau(G_t),
\qquad
m(\mathcal{T}(G_t))=m(\mathcal{T}(G_0))e^{-L_t}.
\]

This is an accounting / theorem-side anchor, not a prediction win. If the full
current graph \(G_t\) is known, then \(\tau(G_t)=0\) exactly determines that the
graph is disconnected. Same-time connectivity classification from the observed
graph is therefore an oracle-style endpoint and should not be counted as
empirical support. The displayed accounting identity is finite while
\(\tau(G_t)>0\), and remains well-defined at the collapse boundary by the
extended-real convention \(L_t=+\infty\).


4. Prediction Surface
---------------------

Empirical support, if sought, must use a frozen prediction task that withholds
future damage or a held-out graph family. Acceptable targets include:

- preferred A31 primary: expected collapse time under a pre-fixed deletion
  process;
- preferred A31 primary: long-horizon global robustness ranking under the same
  pre-fixed damage process;
- secondary: retained spanning-tree mass after future deletions;
- stress-test / boundary target: probability of disconnection within \(h\)
  future deletion steps;
- held-out graph-family robustness under the same pre-fixed damage process.

The feature set may use only information available at the prediction time. It
must not include the future edge realization, exact future connectivity, exact
future reliability, or a Monte Carlo estimate of the target itself. Retained
future spanning-tree mass is useful as a secondary endpoint, but should not be
the first primary endpoint because it is close to the same accounting coordinate
under simple independent deletion processes. Short-horizon disconnection
probability is allowed as a boundary stress test, but it is often a better fit
for the A12 cut-spectrum reliability package.


5. Baselines
------------

- simple baseline: deleted-edge count, remaining-edge count, edge density,
  mean degree, graph size.
- domain baseline: simple baseline plus natural graph robustness quantities
  such as minimum degree, edge connectivity / min-cut, bridge count, and
  path-length summaries. This baseline should not include spanning-tree counts,
  spanning-tree sensitivities, low-order cutset counts, or cut-spectrum losses.
- domain baseline + SP: the same domain baseline plus a frozen spanning-tree
  persistence coordinate such as \(L_t\), \(\log\tau(G_t)\), or deletion
  sensitivity of \(\log\tau\). Deletion sensitivity must be computed from the
  current graph using a pre-fixed edge-risk distribution or an all-edge
  leave-one-out rule, not from the realized future deletion path. Low-order
  cutset counts and cut-spectrum losses belong to the separate A12
  cut-spectrum reliability package, not to the A31 primary coordinate.
- wide baseline, if any: richer graph-invariant baseline such as algebraic
  connectivity, spectral gap, effective-resistance summaries, betweenness
  summaries, and other pre-approved graph features. This should be treated as a
  guardrail / diagnostic unless explicitly frozen as the primary comparator.

Do not use exact reliability, future-state connectivity, or Monte Carlo
reliability estimates as primary baseline features. Those are too close to the
target and turn the prediction task into an oracle calculation.


6. Validation Status
--------------------

- candidate / frozen / supported / no-support / silence: no-support for
  primary_v0 incremental prediction; matched-residual support for primary_v1;
  exact accounting anchor remains valid.
- frozen manifest: primary v0 at
  `../../05_evidence/a31_graph_spanning_tree_persistence/freeze_manifest_v0.md`.
- frozen manifest: matched-residual primary v1 at
  `../../05_evidence/a31_graph_spanning_tree_persistence/freeze_manifest_matched_residual_v1.md`.
- smoke harness: `../../05_evidence/a31_graph_spanning_tree_persistence/`;
  smoke outputs are not evidence.
- evidence record, primary v0:
  `../../05_evidence/a31_graph_spanning_tree_persistence/primary_result_summary.md`.
- evidence record, matched-residual primary v1:
  `../../05_evidence/a31_graph_spanning_tree_persistence/primary_matched_residual_v1_result_summary.md`.

Frozen primary v0 result:

1. The exact Matrix-Tree / Bareiss accounting checks passed.
2. Future-label count audit passed.
3. Endpoint was nondegenerate.
4. \(B1+SP_{\mathrm{bundle}}\) slightly improved over \(B1\), but the relative
   test log-loss improvement was only 0.0588 percent, below the frozen 1 percent
   threshold.
5. Therefore primary_v0 is no-support for incremental prediction value.

Frozen matched-residual primary v1 result:

- A31 matched-residual v1 asked whether \(\log\tau(G_t)\) has residual value
  inside graph-state groups matched on B1-style local robustness features.
- The v1 primary matching key was `path_b05`; other explored keys were
  diagnostic only.
- Held-out test matched groups: 47.
- Held-out test mean low-minus-high collapse fraction: 0.03880762411347518.
- Bootstrap positive rate over held-out test matched groups: 1.0.
- Therefore primary_v1 is support for the matched-residual value of current
  \(\log\tau(G_t)\) in this finite synthetic package.
- This does not reverse the primary_v0 no-support decision and does not claim
  support for \(L_t\) alone.


7. Claims
---------

This domain supports:

- a specification-fixed accounting anchor for the structural persistence kernel,
  because \(\mathcal{T}(G_t)\), \(m\), \(L\), and the zero-mass collapse boundary
  are fixed by finite graph structure;
- finite synthetic matched-residual support that current
  \(\log\tau(G_t)\) has residual collapse-risk ordering value inside groups
  matched on B1-style local robustness features.

This domain does not support:

- a new graph invariant claim;
- empirical support for primary_v0 incremental log-loss improvement;
- support for \(L_t\) alone;
- same-time connectivity prediction from the fully observed graph;
- exact reliability or Monte Carlo reliability as a fair primary baseline;
- A12 cut-spectrum / reliability prediction support;
- \(M\)-side component diagnostic validation;
- universal-law closure outside the registered finite graph setting.
