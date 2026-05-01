A06/A19 Primary v1b Rate-0.625 CW3 Result Summary
=================================================

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v1b_rate625_cw3

manifest: 05_evidence/a06_a19_coding_channel_recovery/freeze_manifest_v1b_rate625_cw3.md

date: 2026-05-01 JST

decision: no_support


1. Scope
--------

This is an independently seeded successor package after the supported A06/A19
primary_v0 package and the invalid v1 rate-0.625 column-weight-4 generation
surface.

The support claim was restricted to the frozen synthetic sparse parity-check
surface:

- \(n\in\{32,40\}\);
- rate \(0.625\);
- column weight \(3\);
- \(q\in\{0.16,0.22,0.28,0.34\}\);
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
test code-balanced prevalence: 0.30340576171875
endpoint_degenerate: false
```

Governance:

```text
governance_summary: 05_evidence/a06_a19_coding_channel_recovery/primary_v1b_rate625_cw3/governance_summary.json
raw_evaluation_status: smoke_evaluated_not_evidence
governance_decision: no_support
```

The raw evaluator JSON keeps a generic harness status name. The no-support
decision is governed by the frozen manifest, this result summary, the
governance summary, `05_evidence/frozen_packages.tsv`, and
`05_evidence/no_support.tsv`.


3. Primary Result
-----------------

Primary comparison:

```text
B1_SP_scalar vs B1
```

Result:

```text
B1 test log loss:             0.5320604873602987
B1 + SP scalar test log loss: 0.5275253598451052
relative improvement:         0.008523706651650663
bootstrap positive rate:      1.0
```

The frozen support gate required at least 1 percent relative log-loss
improvement and at least 0.90 paired code-id bootstrap positive rate. The
direction was positive and the bootstrap gate passed, but the relative
improvement was 0.8524 percent, below the frozen 1 percent threshold. The
package is therefore no-support under the frozen rule.


4. Guardrails and Attribution
-----------------------------

Hazard guardrail:

```text
B1_hazard test log loss:             0.5284179008351072
B1_hazard + SP scalar test log loss: 0.5247277648132346
relative improvement:                0.006983366793669869
bootstrap positive rate:             0.998
```

Additional diagnostics:

```text
B1_SP_terms test log loss:   0.5284772314079209
B1_SP_bundle test log loss:  0.5281617651597034
```

These diagnostics were not support-bearing under the frozen manifest.


5. Interpretation
-----------------

This package does not support the A06/A19 rate-0.625 successor claim under the
frozen 1 percent primary gate. It is not evidence against the exact rank
accounting anchor and does not invalidate the supported primary_v0 package.

It records that, on this rate-0.625, column-weight-3 finite BEC surface, the
pre-fixed scalar dependency coordinate was directionally positive but below the
pre-fixed support threshold.
