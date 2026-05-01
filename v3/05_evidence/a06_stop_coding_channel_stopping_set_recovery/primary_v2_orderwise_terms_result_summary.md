A06-stop Primary v2 Order-Wise Normalized-Terms Result Summary
==============================================================

domain_id: coding_channel_stopping_set_recovery

package_id: a06_stop_coding_channel_stopping_set_recovery_v2_orderwise_terms

manifest: 05_evidence/a06_stop_coding_channel_stopping_set_recovery/freeze_manifest_v2_orderwise_terms.md

date: 2026-05-01 JST

decision: no_support


1. Scope
--------

This is the frozen support-bearing primary run for the A06-stop v2
order-wise normalized stopping-set package. It is separate from the
freeze-prep smoke rows and uses the frozen manifest commands, seeds, script
hashes, and decision rule.

The support claim was restricted to the frozen synthetic sparse parity-check
surface:

- \(n\in\{24,32\}\);
- rate \(0.50\);
- column weight \(3\);
- \(q\in\{0.18,0.24,0.30,0.36\}\);
- 160 codes, 640 code / \(q\) rows;
- 256 independent erasure samples per code / \(q\) row;
- stopping-set order \(5\);
- dependency guardrail order \(4\).


2. Audits
---------

Generation:

```text
code_count: 160
feature_row_count: 640
erasure_sample_count: 163,840
label_count: 640
stopping_count_method: exact_all_subset_scan
dependency_count_method: exact_gf2_subset_rank_low_order
```

Evaluation:

```text
split_integrity_audit: passed
label/sample audit: passed
test codes: 32
train codes: 96
validation codes: 32
test code-balanced prevalence: 0.257049560546875
endpoint_degenerate: false
```

Governance:

```text
governance_summary:
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  primary_v2_orderwise_terms/governance_summary.json

raw_evaluation_status: smoke_evaluated_not_evidence
governance_decision: no_support
```

The raw evaluator JSON keeps a generic harness status name. The official
no-support decision is governed by the frozen manifest, this result summary,
the governance summary, `05_evidence/frozen_packages.tsv`, and
`05_evidence/no_support.tsv`.


3. Primary Result
-----------------

Primary comparison:

```text
B1_degree_SP_stop_orderwise_norm_terms
vs
B1_degree
```

Result:

```text
B1_degree test log loss:                         0.5158353988587047
B1_degree + orderwise normalized terms loss:     0.5125517028275622
relative improvement:                            0.0063657826477354264
bootstrap positive rate:                         0.9925
```

The frozen primary gate required at least 1 percent relative log-loss
improvement and at least 0.90 paired code-id bootstrap positive rate. The
direction was positive and the bootstrap gate passed, but the relative
improvement was 0.6366 percent, below the frozen 1 percent threshold. The
primary gate therefore failed, and the package is no-support under the frozen
rule.


4. Guardrails and Diagnostics
-----------------------------

Hazard guardrail:

```text
B1_degree_hazard test log loss:                  0.5128134401813285
B1_degree_hazard + orderwise terms loss:         0.5100997311049749
relative improvement:                            0.005291805681602346
bootstrap positive rate:                         0.9895
hazard_guardrail_pass:                           true
```

Rank-dependency guardrail:

```text
B1_degree_rankdep test log loss:                 0.5120536241012925
B1_degree_rankdep + orderwise terms loss:        0.5113647815872366
relative improvement:                            0.0013452546405952437
bootstrap positive rate:                         0.83
rankdep_guardrail_pass:                          false
```

Raw stopping-pressure diagnostics:

```text
raw stop scalar diagnostic test log loss:        0.5121257665973473
raw stop terms diagnostic test log loss:         0.510771838593711
normalized scalar diagnostic test log loss:      0.5127735731329822
```

These diagnostics were not support-bearing under the frozen manifest.


5. Interpretation
-----------------

This package does not support the A06-stop v2 order-wise normalized
stopping-set claim under the frozen 1 percent primary gate. The result is
directionally positive, and the hazard guardrail remains positive, but the
primary improvement is below the pre-fixed threshold. The rank-dependency
guardrail also does not meet the clean-support bootstrap threshold.

This is not evidence against the exact peeling / stopping-set accounting
anchor. It records that, on this finite synthetic BEC iterative-decoding
surface, the pre-fixed order-wise normalized stopping-set bundle did not add
enough incremental predictive value beyond the degree-rich baseline to pass
the frozen support rule.
