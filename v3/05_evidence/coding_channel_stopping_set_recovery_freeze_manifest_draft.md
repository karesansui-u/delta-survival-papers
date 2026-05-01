A06-stop Coding-Channel Stopping-Set Recovery Freeze Manifest Draft
===================================================================

Status: draft only; not frozen; not validation evidence.

Date drafted: 2026-05-01 JST

manifest_id: coding_channel_stopping_set_recovery_v0_draft

domain_id: coding_channel_stopping_set_recovery

Domain profile:

```text
03_domains/01_specification_fixed/coding_channel_stopping_set_recovery.md
```


1. Candidate Claim
------------------

Candidate primary claim:

> For finite random sparse binary linear codes under a fixed BEC erasure law
> and a fixed peeling decoder, \(B1+\log(1+H_{\mathrm{stop},5})\) predicts
> held-out finite-block failure to recover all erased codeword coordinates
> better than \(B1\) alone.

Claim strength if passed:

- finite synthetic support for a decoder-specific stopping-set coordinate;
- specification-fixed support for the BEC peeling-decoder recovery condition;
- not support for maximum-likelihood unique recovery;
- not support for arbitrary decoders;
- not non-BEC support;
- not Shannon-capacity theorem support;
- not exact finite-block failure-probability superiority;
- not \(M\)-side validation.


2. Structural Condition
-----------------------

Frozen structural condition \(G_{\mathrm{stop}}\):

```text
After BEC erasures, all erased transmitted codeword coordinates are recovered
by the fixed peeling / iterative decoder.
```

For a fixed parity-check matrix \(H\) and erasure set \(E\), define
\(S_\infty(H,E)\) as the residual erased set after BEC peeling terminates.
The endpoint is

\[
Y=1\{|S_\infty(H,E)|>0\}.
\]

The decoder-specific mass readout is

\[
\frac{m(V_E^{\mathrm{peel}})}{m(V_0^{\mathrm{peel}})}
=2^{-|S_\infty(H,E)|},
\qquad
L_{\mathrm{stop}}(H,E)=|S_\infty(H,E)|\log 2.
\]

This is not the A06/A19 rank ambiguity coordinate
\(a(E)\log 2\). Any support-bearing run must keep the two structural
conditions separate.


3. Draft Surface
----------------

Candidate v0 surface:

```text
n-values:                  24,32
rate:                      0.50
column-weight:             3
q-values:                  0.18,0.24,0.30,0.36
codes-per-cell:            120
erasure-samples per row:   256
stopping-order:            5
```

Rationale:

- rate 0.50 and column-weight 3 mirror the supported A06/A19 v0 surface,
  but the endpoint and coordinate are decoder-specific;
- order 5 is a first small stopping-set window, intended to remain
  enumeratable on the draft \(n\in\{24,32\}\) surface;
- code ids, not code / \(q\) rows, must define train / validation / test
  splits.

Before freezing, the implementation must report the estimated enumeration
cost for \(N_j^{\mathrm{stop}}\) through order 5. If this is too slow, the
surface or order window must be redesigned before any outcome-bearing run.


4. Candidate Primary Coordinate
-------------------------------

The candidate support-bearing SP coordinate is

\[
\log(1+H_{\mathrm{stop},5}(H,p)),
\qquad
H_{\mathrm{stop},5}(H,p)=\sum_{j=2}^{5}N_j^{\mathrm{stop}}(H)p^j.
\]

For v0, \(N_j^{\mathrm{stop}}(H)\) counts all stopping sets of size \(j\),
not only minimal stopping sets. This is a pre-fixed pressure proxy with
possible superset overcounting. It is not an exact union probability.

Term-vector variants may be diagnostic only:

```text
N_stop_2_p2
N_stop_3_p3
N_stop_4_p4
N_stop_5_p5
```

They cannot be promoted to primary after test results are known.


5. Candidate Baselines And Guardrails
-------------------------------------

Primary comparison:

```text
B1_SP_stop_scalar vs B1
```

B1 features:

```text
q
n
k
r = n-k
rate
capacity_margin = 1 - q - rate
column_weight
parity_check_density
check_degree_mean / variance / min / max
variable_degree_mean / variance / min / max
check_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
variable_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
```

Guardrails:

```text
B1_hazard = B1 + p^2 + p^3 + p^4 + p^5
B1_hazard_SP_stop_scalar = B1_hazard + log1p_H_stop_5
B1_rankdep = B1 + log1p_H_dep_4
B1_rankdep_SP_stop_scalar = B1_rankdep + log1p_H_stop_5
```

If the primary gate passes but the hazard guardrail or rank-dependency
guardrail absorbs the gain, the result must be reported with the appropriate
caveat and may not be stated as clean stopping-set support.

Guardrail absorption checks:

```text
B1_hazard_SP_stop_scalar vs B1_hazard
B1_rankdep_SP_stop_scalar vs B1_rankdep
```

Guardrail interpretation is frozen as follows:

- clean stopping-set support: the primary gate passes, and both guardrail
  comparisons remain directionally positive with paired code-id bootstrap
  positive rate at least 0.90;
- caveated stopping-set support: the primary gate passes, but at least one
  guardrail comparison has nonpositive improvement or bootstrap positive rate
  below 0.90;
- no-support: the primary gate fails, regardless of guardrail diagnostics.


6. Oracle Exclusions
--------------------

Forbidden primary features:

- realized erasure set for the target label;
- final peeling residual \(S_\infty(H,E)\);
- \(|S_\infty(H,E)|\) for the target label;
- exact peeling failure indicator;
- exact finite-block peeling failure probability;
- Monte Carlo peeling failure estimate as an input feature;
- stopping-set counts or stopping pressure inside B1;
- outcome-derived feature selection.

Allowed for label and audit only:

- realized erasure sets;
- recomputed peeling residual;
- exact stopping failure indicator.


7. Candidate Metric And Support Rule
------------------------------------

Primary metric:

```text
code-id grouped binomial log loss
```

Candidate support rule:

1. `B1_SP_stop_scalar` has lower code-id grouped binomial log loss than `B1`.
2. Relative log-loss improvement is at least 1 percent:
   \[
   \frac{\ell(B1)-\ell(B1\_SP\_stop\_scalar)}{\ell(B1)}\ge 0.01.
   \]
3. Paired code-id bootstrap positive rate is at least 90 percent.
4. Test endpoint is nondegenerate: code-balanced prevalence is in
   \([0.02,0.98]\).
5. Peeling label/sample audit passes.
6. Split integrity audit passes.

No-support:

- any primary support gate fails;
- frozen test endpoint degeneracy occurs.

Invalid-run:

- schema mismatch;
- peeling label/sample audit failure;
- split integrity failure;
- implementation error that invalidates generated labels;
- generation fails to produce the frozen code surface.


8. Work Required Before Freezing
--------------------------------

This draft is not executable evidence. Before freezing, the following must be
implemented and reviewed:

1. exact BEC peeling decoder and residual-core audit;
2. exact all-stopping-set counter through the frozen order window;
3. exact GF2 low-order dependency counter for the rank-dependency guardrail,
   either reused from A06/A19 with matching hash or reimplemented with separate
   sanity artifacts;
4. generator/evaluator smoke harness with progress logging;
5. sanity cases for simple matrices with known stopping sets and known
   low-order dependencies;
6. split audit, label/sample audit, and endpoint prevalence diagnostics;
7. script hashes and exact frozen commands.

Only after these items are reviewed should this draft be converted into a
frozen primary manifest.
