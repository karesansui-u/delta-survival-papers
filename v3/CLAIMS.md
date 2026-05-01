Claims and Non-Claims
=====================

This file is the public claim boundary for v3. When in doubt, use this file over informal
summaries.


1. Core Claims
--------------

1. In a pre-fixed structural maintenance problem, structural loss can be represented by
   shrinkage of the feasible region compatible with the target structural condition.
2. Under ratio dependence, normalization, additivity, and continuity, the structural
   consumption scale is forced to be logarithmic up to a unit convention.
3. With \(k=1\), cumulative structural consumption is measured in natural-log units
   (nats), and the minimal kernel is \(S = M e^{-L}\).
4. When recovery is represented on the same logarithmic scale, the balance kernel is
   \(S = M e^{-B}\), where \(B_n=\sum_{t<n}(d_t-r_t)\).
5. The same variables can be used as a common coordinate for theorem-side anchors,
   indicator-based prediction, and conditional embeddings, provided the observability layer
   is stated explicitly.

The familiar resource side is \(M\). The nontrivial addition of this theory is
not that resources matter, but that resource insufficiency is not the only way a
structure becomes unmaintainable. The theory separates the support-side quantity
\(M\) from the structural-compatibility shrinkage coordinates \(L\) and \(B\).

\(S\) is a structural persistence potential for the stated structural condition.
\(S=0\), or a pre-fixed threshold \(S\le S_c\), is a structural-maintenance
boundary. Its observational form may be collapse, functional failure, halt, phase
transition, or structural reorganization. The boundary can be reached through the
\(L\)- or \(B\)-side feasible-region route, the \(M=0\) resource-side route, or both.

In specification-fixed structural domains, the hardest theorem-side kernel is the
set-valued accounting kernel on pre-fixed \(V,m\). The \(S=Me^{-L}\) and
\(S=Me^{-B}\) formulas connect that kernel to the external resource-side term \(M\);
they should not be read as deriving \(M\) from the exponential kernel.


2. Empirical Value Claim
------------------------

The empirical value of the theory is usually not that an SP-only model replaces a strong
domain model. The central empirical test is often:

\[
\text{domain baseline}+\text{SP} > \text{domain baseline}
\]

under frozen, out-of-sample validation.

Here SP means structural persistence coordinate: structural consumption, recovery,
net consumption, alternative-path, or related coordinates derived from the theory.
The scalar resource-side term \(M\) may be recorded as an effective maintenance
surplus, but decomposed \(M\)-profiles are not part of the core law-side claim.

The law-side claim belongs first to specification-fixed structural domains. In
structurally inferred domains, SP features are inferred indicators for the law-side
\(L\) or \(B\) coordinates. An inferred indicator should be treated as a stronger
predictive instrument only when frozen validation shows incremental out-of-sample
value over the domain baseline; otherwise it remains candidate, no-support,
weak-axis failure, or silence.

The strongest current outside-rerun empirical footing is package-scoped and law-side:
two specification-fixed frozen packages, Mixed-CSP and q-coloring, each have
3/3 clean outside reruns with decision-relevant outputs reproduced. In addition,
finite non-CSP specification-fixed support is recorded for scoped A31, A12, and
A06/A19 packages. These non-CSP results are finite-surface support claims, not
outside-rerun-level closure and not arbitrary-network, arbitrary-code, Shannon-limit,
\(M\)-side, or structurally inferred-domain causal evidence.


3. Transfer Claim
-----------------

Cross-domain transfer is a hypothesis generator.

A successful design in one domain can be translated into a candidate intervention in
another domain. It does not transfer support. Support in the target domain requires the
target-domain mapping, indicators, baseline, metric, split, and decision rule to be
frozen before validation.


4. Software Contract-Coherence Boundary
---------------------------------------

Software contract-coherence diagnostics is a software-side operational track for
distributed-contract contradictions. DeltaLint is the current implementation /
workflow name, not the theory-level object. This track is not direct evidence of
software collapse.

Use two evidence layers:

1. Field demonstration / maintainer-acceptance evidence: public OSS PRs or
   issues that were selected, reproduced, patched, submitted, and accepted by
   external maintainers.
2. Controlled benchmark evidence: frozen same-scope comparisons in which a
   structural lens adds validated distributed-contract roots over matched
   generic review.

PR merge counts are not raw precision / recall and are not the primary benchmark
endpoint. They may be cited as operational field evidence when the selection and
human-workflow caveats are stated.


5. Non-Claims
-------------

The v3 program does not claim:

- all systems empirically decay exponentially;
- every domain has a unique natural \(V,m,d_t,r_t,M\);
- structurally inferred domains have the same evidential strength as specification-fixed
  domains;
- indicator success proves a universal law;
- no-support in one indicator attempt refutes the mathematical kernel;
- \(M\) is derived from the exponential kernel itself;
- cross-domain transfer imports support;
- DeltaLint merged PRs alone prove raw detector precision, long-term software
  collapse prediction, or M-side profile support.


6. Support Vocabulary
---------------------

Use these labels consistently:

| Label | Meaning |
|---|---|
| candidate | mapping or intervention proposed before frozen validation |
| frozen | mapping, indicators, baseline, metric, split, and decision rule fixed |
| weak support | frozen SP-only or compressed coordinate beats a simple baseline |
| incremental support | domain baseline + SP beats domain baseline out-of-sample |
| externally supported | an outside rerun, fresh archive, future surface, or independent runner reproduces the support decision |
| no-support | frozen test fails its pre-fixed support rule |
| weak-axis failure | SP feature mostly renames or duplicates the baseline |
| silence | the theory should not speak for this domain under current observability |


7. Resource / M-Side Boundary
-----------------------------

For resource-side work, \(M\) should be read as the familiar effective
maintenance amount: the support-side resource, slack, or usable capacity
available for maintaining the target structural condition at the relevant time.

Thus \(M\) is not the new mathematical core. It is the conventional resource /
slack side, made explicit so that it can be separated from the new structural
coordinates \(L\) and \(B\). The minimal meaning of \(M\) is simply the effective
amount that is usable for the pre-fixed maintenance problem. \(M=0\) is a
resource-side route to the structural-maintenance boundary and may appear as
functional failure or halt even when some feasible structural region remains.

| Label | Meaning |
|---|---|
| scalar-M readout | an effective resource/slack indicator recorded for the pre-fixed maintenance problem |
| M-component diagnostic | optional exploratory decomposition of \(M\); not a core claim and not law-side support |

Claims about component decompositions or which intervention should be chosen
first are outside the core \(M\)-side evidence vocabulary and should not be used
as the default evidential target for \(M\).
