Claims and Non-Claims
=====================

This file is the public claim boundary for v3. When in doubt, use this file over informal
summaries.


1. Core Claims
--------------

1. In a pre-fixed structural maintenance problem, structural loss can be represented by
   shrinkage of the feasible region that preserves the target structure.
2. Under ratio dependence, normalization, additivity, and continuity, the structural
   consumption scale is forced to be logarithmic up to a unit convention.
3. With \(k=1\), cumulative structural consumption is measured in natural-log units
   (nats), and the minimal kernel is \(S = M e^{-L}\).
4. When recovery is represented on the same logarithmic scale, the balance kernel is
   \(S = M e^{-B}\), where \(B_n=\sum_{t<n}(d_t-r_t)\).
5. The same variables can be used as a common coordinate for theorem-side anchors,
   proxy-based prediction, and conditional embeddings, provided the observability layer
   is stated explicitly.


2. Empirical Value Claim
------------------------

The empirical value of the theory is usually not that an SP-only model replaces a strong
domain model. The central empirical test is often:

\[
\text{domain baseline}+\text{SP} > \text{domain baseline}
\]

under frozen, out-of-sample validation.

Here SP means structural persistence coordinate: structural consumption, recovery,
resource margin, alternative-path, or related coordinates derived from the theory.


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
- proxy success proves a universal law;
- no-support in one proxy attempt refutes the mathematical kernel;
- \(M\) is derived from the exponential kernel itself;
- cross-domain transfer imports support;
- DeltaLint merged PRs alone prove raw detector precision, long-term software
  collapse prediction, or M-side intervention-ranking support.


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


7. M-Side Validation
--------------------

For resource-side work, distinguish formal M-profile representation from empirical
validation.

Here \(M\) should be read as effective maintenance slack / capability: a
design coordinate for the amount, quality, placement, reachability, and timing
of support-side capacity. It is not, by itself, a law that directly chooses the
next intervention. Intervention ranking is a stronger downstream hypothesis.

| Label | Meaning |
|---|---|
| M-profile support | \(M\)-profile features improve held-out prediction or diagnosis over a domain baseline |
| M-ranking support | pre-frozen M-component deficits predict observed intervention-effect ranking above threshold |
| M-strong support | M-ranking support is robust across pre-frozen \(\rho_i\), \(A_j\), and \(\Phi\) candidate families |
| M-replication support | M-profile or M-ranking support reproduces in a separate project, organization, archive, or outside run |

Risk-prediction improvement alone does not validate intervention ranking.
Without intervention records and post-intervention outcomes, M-side evidence
remains profile-level support rather than ranking support.
