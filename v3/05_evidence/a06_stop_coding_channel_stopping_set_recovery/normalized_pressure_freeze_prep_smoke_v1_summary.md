A06-stop Normalized-Pressure Freeze-Prep Smoke v1 Summary
=========================================================

domain_id: coding_channel_stopping_set_recovery

package_id: a06_stop_normalized_pressure_freeze_prep_smoke_v1

status: freeze_prep_smoke_only_not_validation_evidence

date: 2026-05-01 JST


1. Scope
--------

This is a pre-freeze smoke run for the normalized-pressure A06-stop redesign.
It is not frozen validation evidence and must not be interpreted as support or
no-support.

Smoke surface:

```text
n-values:                24,32
rate:                    0.50
column-weight:           3
q-values:                0.18,0.24,0.30,0.36
codes-per-cell:          40
samples per code/q row:  128
stopping-order:          5
dependency-order:        4
```


2. Feasibility And Audits
-------------------------

Generation completed:

```text
codes:                   80
feature rows:            320
erasure samples:         40,960
label rows:              320
generation elapsed:      67.0s
```

Counter micro-benchmark:

```text
n=24 subset tests/code:  55,430
n=24 elapsed/code:       about 0.16-0.17s
n=32 subset tests/code:  242,792
n=32 elapsed/code:       about 0.72s
mean elapsed/code:       0.441s
```

Evaluation audits:

```text
split_integrity_audit:   passed
label/sample audit:      passed
train codes:             48
validation codes:        16
test codes:              16
test prevalence:         0.2703857421875
endpoint_degenerate:     false
```


3. Endpoint Diagnostics
-----------------------

Test prevalence by \(q\):

```text
q=0.18: 0.068359375
q=0.24: 0.16455078125
q=0.30: 0.31494140625
q=0.36: 0.53369140625
```

The endpoint is nondegenerate and remains useful across the candidate
\(q\)-grid.


4. Model Plumbing Diagnostics
-----------------------------

Primary smoke comparison for the normalized-pressure design:

```text
B1_degree test log loss:                       0.5220753205672559
B1_degree + normalized stop scalar log loss:   0.52062333265115
relative improvement:                          0.0027811847427077338
bootstrap positive rate:                       0.931
smoke_support_rule_would_pass:                 false
```

Guardrail diagnostics:

```text
hazard guardrail relative improvement:         0.0019965147542006364
hazard guardrail bootstrap positive:           0.871
rankdep guardrail relative improvement:        0.0006212783280745545
rankdep guardrail bootstrap positive:          0.754
clean_guardrails_would_pass:                   false
```

Other diagnostics:

```text
B0 test log loss:                              0.5246051344001523
B1_simple test log loss:                       0.5246013546952663
B1_degree_hazard test log loss:                0.5189082114279472
raw stop scalar diagnostic test log loss:      0.5194700791592872
raw stop terms diagnostic test log loss:       0.5190143229682518
normalized stop terms diagnostic test loss:    0.5207181562015438
```


5. Interpretation
-----------------

This freeze-prep smoke is operationally healthy: normalized stopping-pressure
features, all-stopping-set counting, peeling labels, rank-dependency guardrail
features, label/sample audits, split audits, endpoint diagnostics, and model
plumbing all executed.

The normalized scalar improves the degree-rich baseline directionally and has
bootstrap positive rate above 0.90. This is a design-level improvement over
the raw scalar in the narrow sense that it suppresses the raw subset-volume
effect. It is not a predictive-performance improvement over the raw scalar on
this smoke surface: the raw scalar diagnostic has lower test log loss than the
normalized scalar.

The normalized scalar values are also small on this surface, so the scalar may
be over-compressed. Future designs should consider order-wise normalized terms
or an alternative scale transformation, but those would require a separate
manifest before any outcome-bearing execution. In this smoke, the relative
improvement remains far below 1 percent, and the guardrails do not pass the
clean-support rule.

This does not constitute no-support because the run is not frozen validation
evidence. It suggests that normalized pressure remains a candidate design, but
the current scalar form is not strong enough to freeze immediately as a primary
package without further review.
