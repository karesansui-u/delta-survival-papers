Claims and Non-Claims
=====================

This file is the public claim boundary for v3. If an informal summary, figure,
registry row, or domain note sounds stronger than this file, this file wins.


0. Claim-Package Rule
---------------------

Claims are package-scoped. A whole domain is not promoted as supported merely
because one package inside that domain has a formal anchor or a frozen support
result.

Every claim package should state, before validation or interpretation:

1. the maintenance problem: substrate or state space \(X\), target condition
   \(G\), the state/action/path targets being counted, feasible region \(V_G\),
   ruler \(m\), update or observation unit, time horizon, and boundary
   convention;
2. the observability classification: `specification_fixed` or `inference`
   (the registry label for the estimation layer);
3. any optional `existing-theory connection` attribute, with the exact drift,
   balance, rank, cutset, path-ratio, stopping-boundary, or stability quantity
   being connected;
4. the evidence state: candidate, frozen, support, no-support, silence, formal
   anchor, or another pre-declared ledger label.

There are two observability classifications. `specification_fixed` means
\(G,V_G,m\), the counted targets, the update rule, and the boundary can be fixed
from the domain specification. `inference` is the registry label for the
estimation layer: the true \(V_G,m,L,B\) are not directly counted, so frozen
observation or estimation indicators are tested instead.

Existing-theory connection is not a third observability layer. It is an
attribute of a specific claim package, and it only covers the named quantity or
conditional theorem that has actually been mapped.


1. Core Law-Side Claims
-----------------------

1. In a pre-fixed structural maintenance problem, structural loss is represented
   by shrinkage of the feasible region compatible with the target condition
   \(G\).
2. Under ratio dependence, normalization, additivity, and continuity, the
   structural consumption scale is logarithmic up to a unit convention.
3. With \(k=1\), cumulative structural consumption is measured in nats. The
   loss-only kernel is \(S = M e^{-L}\).
4. With recovery represented on the same logarithmic scale, the balance kernel
   is \(S = M e^{-B}\), where \(B_n=\sum_{t<n}(d_t-r_t)\).
5. \(L\) and \(B\) are structural-compatibility coordinates. \(M\) is the
   familiar effective maintenance surplus or usable resource side.

The nontrivial addition of the theory is not that resources matter. It is the
separation between the resource-side quantity \(M\) and the law-side shrinkage
coordinates \(L\) and \(B\). A system can approach a maintenance boundary
because the feasible structural region shrinks, because the effective resource
side reaches \(M=0\), or because both happen together.

\(S\) is a structural persistence potential for the stated maintenance problem.
It is not automatically a probability, a physical free energy, or a derivation
of \(M\). \(S=0\), or a pre-fixed threshold \(S\le S_c\), is a boundary
convention whose observational form may be collapse, functional failure, halt,
phase transition, or structural reorganization.


2. Theorem-Side Anchors
-----------------------

A theorem-side anchor shows that a pre-fixed coordinate closes mathematically
against an independently stated endpoint or boundary. It is not empirical
support by itself.

Current examples include finite CSP first-moment collapse, finite CSP
second-moment survival under a controlled second-moment ratio, finite BEC
linear-code erasure-rank unique recovery, finite row-budget converse, random
parity-check row-slack envelope, BEC erasure-count concentration bridge,
finite BEC capacity-style bound bundle, finite \(s\)-\(t\) cutset reliability
embedding, spanning-tree persistence accounting, stationary-current and
trajectory-ratio guardrails, and Foster-Lyapunov sign bridges. These anchors
strengthen the vocabulary and the boundary discipline. They do not replace
frozen prediction packages.

For finite BEC rank accounting, the compatible ambiguity grows as
\(2^{a(E)}\). The structural-loss coordinate is not defined on that growing
ambiguity mass. It is defined on retained distinguishable message-cell mass:
\[
\frac{m(V_E)}{m(V_0)}=2^{-a(E)},
\qquad
L_E=-\log\frac{m(V_E)}{m(V_0)}=a(E)\log 2.
\]

For finite \(s\)-\(t\) cutset reliability, the operational embedding includes
the union-bound skeleton
\[
\Pr(s\not\leftrightarrow t)\le \sum_j N_j q^j
\]
under a fixed independent edge-failure law. Low-order cut-spectrum coordinates
are frozen low-order cutset proxies, not exact reliability superiority.

For existing theories, v3 claims only the mapped part. For example, a rank
accounting bridge or finite capacity-style bound bundle does not prove Shannon
capacity, a second-moment survival anchor does not prove a sharp CSP threshold,
a path-ratio identity does not prove a physical fluctuation theorem, and a
Foster-Lyapunov sign bridge does not prove positive recurrence.


3. Empirical Support Claim
--------------------------

The usual empirical value claim is not that an SP-only model replaces a strong
domain model. The central frozen test is:

\[
\text{domain baseline}+\text{SP} > \text{domain baseline}
\]

on unused data, a future surface, a fresh archive, or an outside rerun, under a
pre-fixed metric and decision rule.

Here SP means a structural persistence coordinate: structural consumption,
recovery, net consumption, alternative-path, cut-spectrum, dependency-pressure,
contract-coherence, or a related coordinate derived from the theory.

In `specification_fixed` packages, support can bear on the law-side coordinate
because \(V_G,m\), the update rule, and the boundary are fixed by construction.
In estimation-layer (`inference`) packages, support is weaker: it shows that a
frozen indicator adds predictive value beyond the domain baseline. It does not
prove that the indicator is the true \(L\), \(B\), or mechanism.

The strongest current outside-rerun empirical footing is package-scoped:
Mixed-CSP and q-coloring each have 3/3 clean outside reruns with
decision-relevant outputs reproduced. Finite non-CSP support is also recorded
for scoped finite \(s\)-\(t\) cutset reliability and finite BEC linear-code
packages, with spanning-tree persistence recorded as an exact endpoint-accounting
anchor plus separate scoped prediction results. These are finite-surface support
claims, not arbitrary-network, arbitrary-code, Shannon-limit, real-world causal,
\(M\)-side, or universal-law evidence.


4. Transfer Claim
-----------------

Cross-domain transfer is a hypothesis generator.

A successful design in one package can suggest a candidate mapping,
intervention, or indicator in another package. It does not transfer support.
Support in the target package requires the target mapping, indicator, baseline,
metric, split, and decision rule to be frozen before validation.


5. Software Contract-Coherence Boundary
---------------------------------------

Software contract-coherence diagnostics is an estimation-layer (`inference`)
operational track for distributed-contract contradictions. DeltaLint is the current
implementation and workflow name, not the theory-level object. This track is
not direct evidence of software collapse.

Use two evidence forms:

1. field demonstration / maintainer-acceptance evidence: public OSS PRs or
   issues selected, reproduced, patched, submitted, and accepted by external
   maintainers;
2. controlled benchmark evidence: frozen same-scope comparisons in which a
   structural lens adds validated distributed-contract roots over matched
   generic review.

PR merge counts are not raw precision / recall and are not the primary
benchmark endpoint. They may be cited as operational field evidence only when
the selection and human-workflow caveats are stated.


6. Resource / M-Side Boundary
-----------------------------

For resource-side work, \(M\) should be read as the effective maintenance
amount: the resource-side slack, capacity, budget, attention, time, or other
usable resource available for maintaining the target condition \(G\).

The minimal meaning of \(M\) is scalar. Optional component decompositions of
\(M\) are diagnostics, not core law-side claims. \(M=0\) is a resource-side
route to the maintenance boundary and may appear as functional failure or halt
even when some feasible structural region remains.

| Label | Meaning |
|---|---|
| scalar-M readout | effective resource or slack indicator for the pre-fixed maintenance problem |
| M-component diagnostic | optional exploratory decomposition of \(M\); not a core claim and not law-side support |

Claims about component decompositions or which intervention should be chosen
first are outside the default \(M\)-side evidence vocabulary.


7. Non-Claims
-------------

The v3 program does not claim:

- all systems empirically decay exponentially;
- every domain has a unique natural \(G,V_G,m,d_t,r_t,M\);
- package-level support promotes a whole domain;
- theorem-side anchors are empirical support;
- estimation-layer support has the same evidential strength as
  specification-fixed support;
- indicator success proves a universal law or mechanism;
- no-support in one frozen package refutes the mathematical kernel;
- \(M\) is derived from the exponential kernel itself;
- cross-domain transfer imports support;
- existing-theory connection means the whole existing theory has been
  re-proved;
- DeltaLint merged PRs alone prove raw detector precision, long-term software
  collapse prediction, or M-side profile support.


8. Support Vocabulary
---------------------

Use these labels consistently:

| Label | Meaning |
|---|---|
| candidate | mapping, indicator, theorem-side bridge, or intervention proposed before frozen validation |
| formal anchor | theorem-side or Lean-side accounting result; not empirical support by itself |
| frozen | mapping, indicators, baseline, metric, split, and decision rule fixed |
| support | frozen package passes its pre-fixed support rule |
| weak support | frozen SP-only or compressed coordinate beats a simple baseline |
| incremental support | domain baseline + SP beats domain baseline out-of-sample |
| externally supported | outside rerun, fresh archive, future surface, or independent runner reproduces the support decision |
| no-support | frozen test fails its pre-fixed support rule |
| weak-axis failure | SP feature mostly renames or duplicates the baseline |
| silence | the theory should not speak for this package under current observability |
