A12 Primary v0b Kappa-2 Result Summary
======================================

domain_id: st_cut_spectrum_reliability

package_id: a12_st_cut_spectrum_reliability_v0b_kappa2

manifest: 05_evidence/a12_st_cut_spectrum_reliability/freeze_manifest_v0b_kappa2.md

date: 2026-05-01 JST

decision: support


1. Scope
--------

This is a successor package after the invalid A12 primary_v0 generation
surface. It is not a rescue of primary_v0.

The support claim is restricted to the frozen \(\kappa=2\)-only two-cluster
synthetic graph family:

- \(n\in\{16,20\}\);
- edge-factor \(1.5\);
- \(\kappa=2\) only;
- \(q\in\{0.20,0.30,0.40,0.50\}\);
- 80 graphs, 320 graph / \(q\) rows;
- 256 independent failure samples per graph / \(q\) row.


2. Audits
---------

Generation:

```text
graph_count: 80
feature_row_count: 320
failure_sample_count: 81920
label_count: 320
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
test graph-balanced prevalence: 0.40960693359375
endpoint_degenerate: false
```

Governance:

```text
governance_summary: 05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2/governance_summary.json
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
B1 test log loss:             0.5627084187154574
B1 + SP scalar test log loss: 0.5533643558896937
relative improvement:         0.016605514534675368
bootstrap positive rate:      1.0
```

The frozen support gate required at least 1 percent relative log-loss
improvement and at least 0.90 paired graph-id bootstrap positive rate. The
gate passed.


4. Guardrails and Attribution
-----------------------------

Hazard guardrail:

```text
B1_hazard test log loss:             0.5544517981006696
B1_hazard + SP scalar test log loss: 0.5517535883129523
relative improvement:                0.004866446094972145
bootstrap positive rate:             1.0
```

The hazard guardrail does not fully absorb the SP signal, but the residual
improvement over \(B1_{\mathrm{hazard}}\) is below the primary 1 percent gate.
The supported claim should therefore be phrased as finite \(\kappa=2\)
low-order pressure support, with a caveat that nonlinear \(q,\kappa\) hazard
terms account for part of the gain.

Additional diagnostics:

```text
B1_SP_terms test log loss:   0.5542312099959157
B1_SP_bundle test log loss:  0.552247297544525
B2_guardrail test log loss:  0.5610378650997199
```

These diagnostics were not support-bearing under the frozen manifest.


5. Interpretation
-----------------

This package supports the A12 claim that a pre-fixed scalar low-order
cut-spectrum pressure coordinate adds incremental predictive value over the
natural graph baseline in a finite \(\kappa=2\) synthetic \(s\)-\(t\)
reliability surface.

It does not establish support for \(\kappa=3\), broader graph families,
real-world networks, exact reliability superiority, A31 spanning-tree
persistence, or \(M\)-side validation.

The predecessor A12 primary_v0 remains invalid-run, not no-support:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0_invalid_run_summary.md
```
