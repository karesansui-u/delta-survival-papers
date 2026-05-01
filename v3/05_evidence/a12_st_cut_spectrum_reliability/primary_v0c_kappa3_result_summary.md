A12 Primary v0c Kappa-3 Result Summary
======================================

domain_id: st_cut_spectrum_reliability

package_id: a12_st_cut_spectrum_reliability_v0c_kappa3

manifest: 05_evidence/a12_st_cut_spectrum_reliability/freeze_manifest_v0c_kappa3.md

date: 2026-05-01 JST

decision: support


1. Scope
--------

This is a separate \(\kappa=3\) successor package after:

- the invalid A12 primary_v0 generation surface;
- the supported \(\kappa=2\)-only v0b surface.

It uses a constructive two-cluster generator to make the \(\kappa=3\) surface
feasible before labels are generated.

The support claim is restricted to the frozen \(\kappa=3\)-only two-cluster
synthetic graph family:

- \(n\in\{16,20\}\);
- edge-factor \(2.0\);
- \(\kappa=3\) only;
- \(q\in\{0.20,0.30,0.40,0.50\}\);
- 80 graphs, 320 graph / \(q\) rows;
- 256 independent failure samples per graph / \(q\) row;
- exact low-order cutset enumeration with `max-cutset-subset-tests=900000`.


2. Audits
---------

Generation:

```text
graph_count: 80
feature_row_count: 320
failure_sample_count: 81920
label_count: 320
cluster_generator: constructive
cutset_count_sanity: passed
rejection_counts: {}
```

Evaluation:

```text
split_integrity_audit: passed
label_sample_audit: passed
test graphs: 16
train graphs: 48
validation graphs: 16
test graph-balanced prevalence: 0.18170166015625
endpoint_degenerate: false
```

Governance:

```text
governance_summary: 05_evidence/a12_st_cut_spectrum_reliability/primary_v0c_kappa3/governance_summary.json
raw_evaluation_status: smoke_evaluated_not_evidence
governance_decision: support
```

The raw evaluator JSON keeps a legacy harness status name. The support decision
is governed by the frozen manifest, this result summary, the governance summary,
and `05_evidence/frozen_packages.tsv`.


3. Primary Result
-----------------

Primary comparison:

```text
B1_SP_scalar vs B1
```

Result:

```text
B1 test log loss:             0.4423180021090647
B1 + SP scalar test log loss: 0.4330664624793408
relative improvement:         0.020916036845913213
bootstrap positive rate:      1.0
```

The frozen support gate required at least 1 percent relative log-loss
improvement and at least 0.90 paired graph-id bootstrap positive rate. The
gate passed.


4. Guardrails and Attribution
-----------------------------

Hazard guardrail:

```text
B1_hazard test log loss:             0.43094334078508734
B1_hazard + SP scalar test log loss: 0.4295577115905518
relative improvement:                0.003215339612885609
bootstrap positive rate:             0.9905
```

The hazard guardrail does not fully absorb the SP signal, but the residual
improvement over \(B1_{\mathrm{hazard}}\) is below the primary 1 percent gate.
The supported claim should therefore be phrased as finite \(\kappa=3\)
low-order pressure support, with a caveat that nonlinear \(q,\kappa\) hazard
terms account for part of the gain.

Additional diagnostics:

```text
B1_SP_terms test log loss:   0.4327559068324731
B1_SP_bundle test log loss:  0.43187337842384504
B2_guardrail test log loss:  0.44210928978869096
```

These diagnostics were not support-bearing under the frozen manifest.


5. Interpretation
-----------------

This package supports the A12 claim that a pre-fixed scalar low-order
cut-spectrum pressure coordinate adds incremental predictive value over the
natural graph baseline in a finite \(\kappa=3\) synthetic \(s\)-\(t\)
reliability surface.

Together with v0b, A12 now has two separate finite synthetic support surfaces:

- \(\kappa=2\): `primary_v0b_kappa2_result_summary.md`;
- \(\kappa=3\): this v0c package.

It does not establish support for arbitrary \(\kappa\), broader graph
families, real-world networks, exact reliability superiority, A31
spanning-tree persistence, or \(M\)-side validation.
