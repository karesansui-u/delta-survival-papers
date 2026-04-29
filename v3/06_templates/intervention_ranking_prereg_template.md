Intervention-Ranking Preregistration Template
=============================================

prereg_id:

domain_id:

date_frozen:

frozen_by:


1. Purpose
----------

This template tests a strong downstream M-side claim:

> systems with different M-component profiles should require different first
> interventions, even under comparable \(L\), raw resource, and scalar \(M\).

Risk prediction or diagnosis can support the M-profile as a design coordinate.
Intervention ranking is a stronger claim: it asks whether that coordinate can
also forecast which maintenance action works best.


2. Units and Eligibility
------------------------

- unit of analysis:
- observation window:
- intervention window:
- outcome window:
- inclusion criteria:
- exclusion criteria:
- minimum number of eligible units:
- minimum number of observed interventions:


3. Frozen M-Profile and Deficit Rule
------------------------------------

- M-profile manifest:
- component normalization family:
- internal/external aggregation family:
- scalar aggregation family:

Define the deficit score for each component:

| Component | Deficit score | Eligible intervention family |
|---|---|---|
| \(M_{\mathrm{buffer}}\) |  | buffer / redundancy / margin |
| \(M_{\mathrm{recovery}}\) |  | rollback / repair workflow / runbook / replay |
| \(M_{\mathrm{reconfiguration}}\) |  | modularization / feature flag / migration tooling |

Predicted intervention ranking rule:

1.
2.
3.


4. Observed Intervention Effect
-------------------------------

- intervention records:
- intervention family coding:
- effect window:
- primary effect metric:
- adjustment variables:
- matching / weighting / stratification method:
- handling of multiple interventions:
- handling of missing or ambiguous interventions:

If randomized intervention assignment is unavailable, the support label is
observational. Do not claim causal support without an explicit identification
design.


5. Evaluation
-------------

- primary ranking metric: Kendall tau / Spearman rho / top-1 agreement / top-2 agreement
- M-ranking support threshold:
- uncertainty criterion:
- no-support threshold:
- minimum power / sample-size condition:
- tie handling:
- sensitivity checks:


6. Robustness
-------------

Strong support requires the intervention-ranking direction to remain stable
across the pre-frozen candidate families.

- \(\rho_i\) normalizations to test:
- \(A_j\) aggregation choices to test:
- \(\Phi\) aggregation choices to test:
- subgroup checks:
- archive / future-surface replication plan:


7. Support Labels
-----------------

Use these labels:

| Label | Criterion |
|---|---|
| M-profile support | M-profile improves held-out prediction, diagnosis, or persistence readout over domain baseline |
| M-ranking support | predicted intervention ranking agrees with observed intervention effectiveness above threshold |
| M-strong support | M-ranking support is robust across \(\rho_i\), \(A_j\), and \(\Phi\) families |
| M-replication support | M-profile or M-ranking support reproduces in a separate project, organization, archive, or outside run |
| no-support | ranking fails the frozen support rule |
| weak-axis failure | M-profile mostly duplicates baseline, scalar resource, degradation, age, or target leakage |
| silence | intervention logs or outcome observability are insufficient |


8. Non-Claims
-------------

- no claim that the observed intervention effect is causal unless identified;
- no claim that the same intervention order transfers to another domain;
- no claim that risk-prediction improvement validates intervention ranking;
- no post-hoc replacement of component signals, normalization, aggregation, or metric.
