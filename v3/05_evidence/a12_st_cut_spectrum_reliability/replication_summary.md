A12 S-t Cut-Spectrum Reliability Replication Summary
====================================================

domain_id: st_cut_spectrum_reliability

date: 2026-05-01 JST

status: two_surface_finite_synthetic_support


1. Package Decisions
--------------------

| package | surface | decision | primary relative improvement | bootstrap positive |
|---|---|---:|---:|---:|
| primary_v0 | mixed \(\kappa=2,3\), random generator, thin \(m=24\) \(\kappa=3\) cell | invalid_run | n/a | n/a |
| primary_v0b_kappa2 | \(\kappa=2\), edge-factor 1.5, random generator | support | 0.016605514534675368 | 1.0 |
| primary_v0c_kappa3 | \(\kappa=3\), edge-factor 2.0, constructive generator | support | 0.020916036845913213 | 1.0 |


2. Interpretation
-----------------

The original v0 package did not reach prediction evaluation because one frozen
generation cell was infeasible. It is recorded as an invalid run, not
no-support.

The two successor packages show finite synthetic support for the same A12
primary coordinate,

\[
\log(1+H_{\mathrm{cut},2}),
\]

on two separate \(s\)-\(t\) reliability surfaces:

- \(\kappa=2\), using the original random two-cluster generator;
- \(\kappa=3\), using a constructive two-cluster generator that makes the
  \(\kappa=3\) surface feasible before labels are generated.

Both packages used graph-id grouped binomial log loss, graph-id splits,
label/sample audits, split-integrity audits, exact low-order cutset
enumeration, and the same frozen primary support rule.

Machine-readable governance summaries are stored with each supported primary
output:

- `primary_v0b_kappa2/governance_summary.json`;
- `primary_v0c_kappa3/governance_summary.json`.

The raw evaluator JSON files retain the legacy harness status name
`smoke_evaluated_not_evidence`; the package decisions are governed by the
frozen manifests, result summaries, governance summaries, and
`05_evidence/frozen_packages.tsv`.


3. Caveats
----------

These results support a finite synthetic A12 cut-spectrum coordinate. They do
not establish:

- arbitrary-\(\kappa\) support;
- real-world network reliability support;
- exact reliability superiority;
- all-terminal reliability support;
- A31 spanning-tree persistence support;
- \(M\)-side validation;
- universal-law closure.

In both supported successor packages, the hazard guardrail indicates that
nonlinear \(q,\kappa\) pressure terms account for part of the gain. The clean
claim is therefore finite low-order pressure support, not an unrestricted
claim that cutset counts dominate every classical reliability feature.
