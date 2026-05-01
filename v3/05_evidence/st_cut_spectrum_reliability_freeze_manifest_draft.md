S-t Cut-Spectrum Reliability Freeze Manifest Draft
==================================================

manifest_id: st_cut_spectrum_reliability_v0_draft

domain_id: st_cut_spectrum_reliability

status: draft_not_frozen

This draft defines a support-bearing package for A12-style \(s\)-\(t\)
reliability prediction. It is intentionally separate from A31. A31 remains the
spanning-tree exact accounting anchor; this package tests whether a frozen
low-order cut-spectrum coordinate improves disconnection-probability prediction
over a natural graph baseline.


1. Claim Under Test
-------------------

Primary claim:

```text
For finite undirected graphs under a pre-fixed independent edge-failure law,
B1 + frozen low-order s-t cut-spectrum pressure predicts held-out s-t
disconnection probability better than B1 alone.
```

This is an incremental prediction claim, not a new reliability theorem.


2. Exact Kernel
---------------

For each graph \(G=(U,E,s,t)\) and edge failure probability \(q\):

\[
V_G=\{\omega\in\{0,1\}^E:\ s\leftrightarrow t
      \text{ in the surviving-edge graph}\},
\]

\[
R_G(q)=m_q(V_G)=\Pr_q(s\leftrightarrow t),
\qquad
L_G(q)=-\log R_G(q).
\]

This exact kernel is a specification-fixed accounting anchor. Exact
\(R_G(q)\), exact failure probability, and Monte Carlo reliability estimates are
oracle-like features and are excluded from all primary baselines.


3. Primary Endpoint
-------------------

For each graph / terminal / \(q\) row, generate \(K\) held-out independent
failure states. The endpoint is

\[
Y_{G,q,k}=1\{s\not\leftrightarrow t
          \text{ after failure sample }k\}.
\]

The row-level label table stores

\[
z_{G,q}=\sum_{k=1}^K Y_{G,q,k}.
\]

Primary evaluation uses graph-id grouped binomial log loss:

\[
\ell(G,q)=
-\frac{1}{K}\left[
z_{G,q}\log p_{G,q}+(K-z_{G,q})\log(1-p_{G,q})
\right],
\]

then averages \(\ell(G,q)\) over \(q\) rows within graph id and averages those
graph-id means over test graph ids.


4. Frozen SP Coordinate
-----------------------

Let \(\kappa=\kappa(G;s,t)\) be the \(s\)-\(t\) edge connectivity. Let
\(N_j(G;s,t)\) be the number of minimal \(s\)-\(t\) cutsets of size \(j\).

Primary v0 SP coordinate:

\[
x_{\mathrm{SP}}=\log(1+H_{\mathrm{cut},2})
=\log(1+\sum_{j=\kappa}^{\kappa+2}N_jq^j).
\]

This scalar log-pressure is the only support-bearing SP coordinate in v0.

Attribution diagnostics:

\[
\left(
N_{\kappa}q^{\kappa},
N_{\kappa+1}q^{\kappa+1},
N_{\kappa+2}q^{\kappa+2}
\right).
\]

and scalar-plus-term-vector bundle diagnostics are mandatory but not
support-bearing.

No other SP features are primary v0 features. In particular, spanning-tree
count, \(\log\tau(G)\), exact reliability, realized failure edges, and Monte
Carlo target estimates are excluded. Attribution diagnostics explain which part
of the cut-spectrum coordinate carries the signal; they cannot be promoted to
primary after test results are known.


5. Minimal Cutset Enumeration
-----------------------------

The v0 enumeration rule should be exact for the registered graph sizes:

1. Compute \(\kappa\) by a standard exact \(s\)-\(t\) min-cut algorithm.
2. For \(j=\kappa,\kappa+1,\kappa+2\), enumerate all edge subsets of size \(j\).
3. Count a subset \(C\) when:
   - removing \(C\) disconnects \(s\) from \(t\);
   - every proper subset of \(C\) leaves \(s\) connected to \(t\).
4. Record audit columns:
   - `kappa`;
   - `N_kappa`;
   - `N_kappa_plus_1`;
   - `N_kappa_plus_2`;
   - enumeration wall-clock / timeout status;
   - count-integrity status.

If enumeration exceeds the pre-fixed subset-test cap, timeout, or graph-size
limit, the graph is discarded before split assignment. Discard rules must not
inspect outcomes. The final manifest must pin:

```text
max_subset_tests
timeout policy, if any
graph-size / edge-size limits
discard status labels
```

Every retained graph must record `cutset_count_status=exact`.


6. Candidate Synthetic Surface
------------------------------

The support-bearing v0 surface should be finite and small enough that low-order
cutset enumeration is exact.

Draft grid:

```text
n-values:           16,20,24
edge-factors:       1.5,2.0
kappas:             2,3 only
q-values:           0.12,0.20,0.30,0.40
candidate-count:    fixed before freeze
graphs-per-cell:    fixed before freeze, at least 10
failure-samples K:  fixed before freeze, recommended 128
generator-seed:     fixed before freeze
split-seed:         fixed before freeze
```

Graph generation must be independent of outcome labels. The current generator
family is a two-cluster synthetic family with a frozen \(s\)-\(t\) cut planted
between clusters. A v0 support claim on this generator must be bounded to that
finite synthetic family unless a separate multi-family or external-graph
package is frozen.

A graph is eligible if:

- it is simple, undirected, and connected;
- \(s\) and \(t\) are distinct and selected by a frozen terminal rule;
- intact \(s\)-\(t\) min-cut equals the requested \(\kappa\);
- low-order cutset enumeration completes under the frozen limit.

Splits are by graph id, not by graph / \(q\) row. Within each
\((n,\text{edge-factor},\kappa)\) cell, use a seed-random permutation and assign
train / validation / test in a fixed ratio, recommended 60 / 20 / 20. The split
must not use cut-spectrum values, labels, or model performance.


7. Baselines
------------

B0 simple baseline:

- \(q\);
- \(n\);
- \(m\);
- density;
- average degree.

B1 natural graph baseline:

- all B0 features;
- terminal degrees \(\deg(s)\), \(\deg(t)\);
- degree variance;
- \(s\)-\(t\) min-cut \(\kappa\);
- shortest \(s\)-\(t\) path length;
- edge count on one shortest path;
- bridge count;

B1 must not include \(N_j\), cut-spectrum pressure, exact reliability, failure
sample summaries, \(s\)-\(t\)-separating bridge count, or spanning-tree count.
The v0 surface is restricted to \(\kappa\in\{2,3\}\). If a later successor
package allows \(\kappa=1\), first-order bridge information must be handled as
SP-side or redesign material, not silently placed in B1.

B1 + SP:

- B1 plus the primary v0 scalar log-pressure in Section 4.

B1 hazard guardrail:

- all B1 features;
- \(q^{\kappa}\);
- \(q^{\kappa+1}\);
- \(q^{\kappa+2}\).

This guardrail checks whether the primary SP result is only a nonlinear
\(q,\kappa\) hazard transform. It does not include cutset counts.

B1 hazard + SP:

- B1 hazard plus \(\log(1+H_{\mathrm{cut},2})\).

B2 guardrail:

- B1 plus pre-fixed wider graph invariants, such as effective resistance,
  algebraic connectivity, selected spectral summaries, and betweenness
  summaries.

B2 is diagnostic unless the final manifest explicitly promotes it.


8. Model and Fitting Discipline
-------------------------------

Recommended v0 model class:

- logistic regression for binary-expanded training rows or binomial GLM with
  equivalent weights;
- numeric feature standardization fit only on train during model selection;
- final refit on train + validation after model and hyperparameters are fixed;
- test evaluated once.

Hyperparameter grid, solver, maximum iterations, and random seeds must be
written into the frozen manifest before running the support-bearing package.


9. Horizon / Prevalence Discipline
----------------------------------

This independent edge-failure surface has no sequential horizon. Endpoint
prevalence is controlled only by the pre-fixed \(q\)-grid and graph-generation
surface.

Calibration data may be used to mark the run redesign-required if all candidate
\(q\) values are endpoint-degenerate. It must not be used to choose a \(q\)-value
where SP performs best. The primary surface should evaluate all frozen
\(q\)-values unless the frozen manifest states a prevalence-only exclusion rule.

The evaluator must write q-by-split prevalence diagnostics. These diagnostics
are audits, not selection knobs. If the frozen test split is endpoint-degenerate
overall, the result is `no_support_endpoint_degeneracy`.


10. Support Rule
----------------

Primary support is obtained only if all conditions hold on the frozen test set:

1. \(B1+SP\) has lower graph-id grouped binomial log loss than \(B1\).
2. Relative log-loss improvement is at least 1 percent:
   \[
   \frac{\ell(B1)-\ell(B1+SP)}{\ell(B1)}\ge 0.01.
   \]
3. Paired graph-id bootstrap positive rate is at least 90 percent.
4. Label count audit passes:
   \(z_{G,q}\) equals the recomputed number of disconnected failure samples for
   every graph / \(q\) row.
5. Oracle-exclusion audit passes.
6. Split-by-graph audit passes.
7. Cutset enumeration audit passes for every retained graph.

The hazard guardrail is diagnostic. If \(B1+SP\) passes but
\(B1_{\mathrm{hazard}}+SP\) does not improve over \(B1_{\mathrm{hazard}}\), the
result should be reported as primary support with a hazard-absorption caveat,
not as clean cutset-count support.

Primary result summaries must display:

- \(B1\) vs \(B1+SP\);
- \(B1_{\mathrm{hazard}}\) vs \(B1_{\mathrm{hazard}}+SP\);
- whether the interpretation is clean cutset-count support or hazard-absorbed
  low-order pressure support.

Failure on any primary support gate gives no-support, not rescue.


11. Required Artifacts
----------------------

The frozen package must write:

- final freeze manifest with SHA256 hashes;
- generator script and evaluator script hashes;
- graph table;
- cut-spectrum table;
- failure sample table or auditable compressed equivalent;
- labels table;
- split table;
- feature manifest;
- model metrics;
- bootstrap diagnostics;
- label audit report;
- oracle-exclusion audit report;
- split and prevalence audit report;
- cutset enumeration audit report;
- primary result summary.


12. Failure And Successor-Package Discipline
--------------------------------------------

A failed v0 package does not exhaust A12. It only says that this frozen surface,
primary scalar SP coordinate, baseline, model class, and support gate did not
support the claim.

After a no-support v0 result, later tests are allowed only if they are opened as
new successor packages before outcome-bearing execution. Acceptable successor
axes include:

- a disjoint graph-family surface;
- a pre-reserved seed block not used in v0;
- an external graph archive;
- a different endpoint, such as ranking rather than log-loss, if declared
  before labels are generated;
- a larger graph regime with a separately frozen enumeration cap and audit.

The failed v0 rows may be used for design diagnosis, but not relabeled as
support. Any successor package must keep the v0 no-support record in the
ledger.


13. Non-Claims
--------------

This package must not claim:

- exact reliability superiority;
- a new graph-theoretic theorem;
- real-world infrastructure reliability;
- all-terminal reliability;
- A31 spanning-tree support;
- \(M\)-side validation;
- universal-law closure.
