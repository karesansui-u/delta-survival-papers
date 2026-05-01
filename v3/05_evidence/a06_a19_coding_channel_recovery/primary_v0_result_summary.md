A06/A19 Primary v0 Result Summary
=================================

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v0

manifest: 05_evidence/a06_a19_coding_channel_recovery/freeze_manifest_v0.md

date: 2026-05-01 JST

decision: support


1. Scope
--------

This is the first frozen primary package for the finite BEC / binary-linear-code
candidate. It is not a reinterpretation of the smoke run.

The support claim is restricted to the frozen synthetic sparse parity-check
surface:

- \(n\in\{24,32\}\);
- rate \(0.50\);
- column weight \(3\);
- \(q\in\{0.18,0.24,0.30,0.36\}\);
- 240 codes, 960 code / \(q\) rows;
- 256 independent erasure samples per code / \(q\) row.


2. Audits
---------

Generation:

```text
code_count: 240
feature_row_count: 960
erasure_sample_count: 245760
label_count: 960
dependency_count_method: exact_gf2_subset_rank_low_order
```

Evaluation:

```text
split_integrity_audit: passed
rank/sample audit: passed
test codes: 48
train codes: 144
validation codes: 48
test code-balanced prevalence: 0.15936279296875
endpoint_degenerate: false
```

Governance:

```text
governance_summary: 05_evidence/a06_a19_coding_channel_recovery/primary_v0/governance_summary.json
raw_evaluation_status: smoke_evaluated_not_evidence
governance_decision: support
```

The raw evaluator JSON keeps a generic harness status name. The support decision
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
B1 test log loss:             0.43822689815179555
B1 + SP scalar test log loss: 0.4289932917900723
relative improvement:         0.02107037792674442
bootstrap positive rate:      1.0
```

The frozen support gate required at least 1 percent relative log-loss
improvement and at least 0.90 paired code-id bootstrap positive rate. The gate
passed.


4. Guardrails and Attribution
-----------------------------

Hazard guardrail:

```text
B1_hazard test log loss:             0.4363397035431776
B1_hazard + SP scalar test log loss: 0.4280894618984881
relative improvement:                0.018907840789402438
bootstrap positive rate:             1.0
```

The SP signal remains positive after adding the \(p^2,p^3,p^4\) hazard
guardrail.

Additional diagnostics:

```text
B1_SP_terms test log loss:   0.42892328390826256
B1_SP_bundle test log loss:  0.4278541421079413
```

These diagnostics were not support-bearing under the frozen manifest.


5. Interpretation
-----------------

This package supports the A06/A19 claim that a pre-fixed scalar low-order
parity-check column-dependency pressure coordinate adds incremental predictive
value over the natural coding baseline in a finite synthetic BEC surface.

The exact rank identity

```text
a(E)=|E|-rank_GF2(H_E)
```

remains the specification-fixed accounting anchor. Rank and ambiguity are used
for label and accounting audits, not as prediction features.

This result does not establish Shannon-capacity theorem support,
arbitrary-code support, non-BEC support, decoder-specific non-ML recovery
support, exact failure-probability superiority, or \(M\)-side validation.
