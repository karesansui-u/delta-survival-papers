Scania Component X Optional M-Component Candidate
=================================================

domain_id: scania_component_x_m_profile

domain_name: Scania Component X optional M-component predictive-maintenance candidate

observability_layer: inference

status: candidate


1. Maintenance Target
---------------------

- Target structure: Component X remains within an operationally maintained state before repair, failure, or service event.
- Failure / collapse boundary: repair, failure, or time-to-event endpoint, fixed before validation.
- Observation unit: anonymized truck / component trajectory.
- Time horizon: frozen before validation.


2. Structural Coordinates
-------------------------

- \(V\): operational states compatible with continued Component X function.
- \(m\): not directly counted; represented through frozen operational and specification observation / estimation indicators.
- \(d_t\): degradation or risk accumulation from time-series counters / histograms.
- \(r_t\): repair or maintenance event readout if it can be coded without endpoint leakage.
- \(L\): loss-only degradation coordinate.
- \(B\): recovery-aware coordinate when a pre-fixed repair signal is valid.
- \(M\)-side readout, if any: scalar effective maintenance surplus \(M\), optionally decomposed into buffer / recovery / reconfiguration indicator candidates from specifications, repair records, and operational history.


3. Why This Candidate Exists
----------------------------

This is a public-data preparatory candidate for optional M-component diagnostic validation. It is weaker
than software / SaaS operational logs for M-component diagnostic support, but stronger
than loss-only datasets when repair records and specifications are usable without
post-hoc leakage.

External source notes:

- Scientific Data describes the dataset as real-world multivariate time series data for an anonymized SCANIA engine component, including operational data, repair records, and specifications.
- The researchdata.se catalogue describes the same dataset as suited for classification, regression, survival analysis, and anomaly detection in predictive maintenance.

Source links:

- https://www.nature.com/articles/s41597-025-04802-6
- https://researchdata.se/catalogue/dataset/2024-34/1


4. Baselines
------------

- simple baseline: age / usage / time / generic degradation features.
- domain baseline: standard predictive-maintenance model.
- domain baseline + SP: domain baseline plus frozen L/B coordinates and, optionally, scalar \(M\) or M-component readouts.
- wide baseline, if any: pre-approved domain model with all non-leaky covariates.


5. Validation Status
--------------------

- current status: candidate.
- strongest realistic first test: optional M-component diagnostic support through held-out risk prediction.
- full M-component diagnostic support may not be available from this public archive.
- M-component diagnostic manifest: use `../../06_templates/m_profile_validation_manifest_template.md`.


6. Claims
---------

This domain may support:

- optional M-component diagnostic support if recovery-aware or component readouts improve held-out prediction beyond a domain baseline;
- weak evidence for operational M-component extraction if repair records are usable without leakage.

This domain does not support:

- causal claims about repairs without an identification design;
- theorem-side evidence;
- a universal \(M\)-law.
