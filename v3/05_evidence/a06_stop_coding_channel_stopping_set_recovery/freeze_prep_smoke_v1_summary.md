A06-stop Freeze-Prep Smoke v1 Summary
=====================================

domain_id: coding_channel_stopping_set_recovery

package_id: a06_stop_freeze_prep_smoke_v1

status: freeze_prep_smoke_only_not_validation_evidence

date: 2026-05-01 JST


1. Scope
--------

This is a larger pre-freeze smoke run for the A06-stop stopping-set recovery
candidate. It is not frozen validation evidence and must not be interpreted as
support or no-support.

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
generation elapsed:      68.9s
```

Counter micro-benchmark:

```text
n=24 subset tests/code:  55,430
n=24 elapsed/code:       about 0.16-0.17s
n=32 subset tests/code:  242,792
n=32 elapsed/code:       about 0.73-0.75s
mean elapsed/code:       0.452s
```

Evaluation audits:

```text
split_integrity_audit:   passed
label/sample audit:      passed
train codes:             48
validation codes:        16
test codes:              16
test prevalence:         0.2410888671875
endpoint_degenerate:     false
```


3. Endpoint Diagnostics
-----------------------

Test prevalence by \(q\):

```text
q=0.18: 0.05615234375
q=0.24: 0.13525390625
q=0.30: 0.287109375
q=0.36: 0.48583984375
```

The endpoint is nondegenerate and has a useful range across the candidate
\(q\)-grid.


4. Model Plumbing Diagnostics
-----------------------------

Primary smoke comparison:

```text
B1 test log loss:                       0.4985912785057697
B1 + stop scalar test log loss:         0.4976963432791569
relative improvement:                   0.0017949275592922622
bootstrap positive rate:                0.769
smoke_support_rule_would_pass:          false
```

Guardrail diagnostics:

```text
hazard guardrail relative improvement:  0.00020863202011920496
hazard guardrail bootstrap positive:    0.578
rankdep guardrail relative improvement: 0.0012677426116176013
rankdep guardrail bootstrap positive:   0.835
clean_guardrails_would_pass:            false
```

Term-vector diagnostic:

```text
B1 + stop terms test log loss:          0.4986648605258638
```

The term-vector model is diagnostic only and is not support-bearing under the
draft design.


5. Interpretation
-----------------

This freeze-prep smoke is operationally healthy: all-stopping-set counting,
peeling labels, rank-dependency guardrail features, label/sample audits, split
audits, endpoint prevalence diagnostics, and model plumbing all executed.

The diagnostic predictive signal is weak on this surface. The scalar stopping
coordinate improves the B1 log loss only slightly, and both guardrail
diagnostics fall below the draft clean-support guardrail requirement.

This does not constitute no-support, because the run is not frozen validation
evidence. It does suggest that the current scalar \(H_{\mathrm{stop},5}\)
primary should not be frozen immediately without further design review.
