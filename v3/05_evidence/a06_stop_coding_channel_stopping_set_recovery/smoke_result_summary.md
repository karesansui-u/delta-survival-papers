A06-stop Smoke v0 Result Summary
================================

domain_id: coding_channel_stopping_set_recovery

package_id: a06_stop_smoke_v0

status: smoke_only_not_validation_evidence

date: 2026-05-01 JST


1. Scope
--------

This is a pre-freeze smoke harness run for the A06-stop stopping-set recovery
candidate. It is not frozen validation evidence and must not be interpreted as
support or no-support.

Smoke surface:

```text
n-values:                24,32
rate:                    0.50
column-weight:           3
q-values:                0.18,0.24,0.30,0.36
codes-per-cell:          8
samples per code/q row:  64
stopping-order:          5
dependency-order:        4
```


2. Feasibility And Audits
-------------------------

Generation completed:

```text
codes:                   16
feature rows:            64
erasure samples:         4,096
label rows:              64
elapsed:                 13.7s
```

Counter micro-benchmark:

```text
n=24 subset tests/code:  55,430
n=24 elapsed/code:       about 0.16-0.17s
n=32 subset tests/code:  242,792
n=32 elapsed/code:       about 0.72-0.77s
mean elapsed/code:       0.459s
```

Evaluation audits:

```text
split_integrity_audit:   passed
label/sample audit:      passed
test prevalence:         0.265625
endpoint_degenerate:     false
```

The split is intentionally tiny for smoke:

```text
train codes:             12
validation codes:        2
test codes:              2
```

Therefore predictive metrics are only plumbing diagnostics.


3. Plumbing Metrics
-------------------

Primary smoke comparison:

```text
B1 test log loss:                  0.5169736974803354
B1 + stop scalar test log loss:    0.5142016072581437
relative improvement:              0.005362149439521841
bootstrap positive rate:           0.728
smoke_support_rule_would_pass:     false
```

Guardrail diagnostics:

```text
hazard guardrail relative improvement:   0.0017052056838425293
hazard guardrail bootstrap positive:     0.728
rankdep guardrail relative improvement:  0.0017915587594013842
rankdep guardrail bootstrap positive:    0.728
clean_guardrails_would_pass:             false
```

Term-vector diagnostic:

```text
B1_SP_stop_terms test log loss: 0.5090004599246412
```

This term-vector result is diagnostic only and is not support-bearing under
the draft design.


4. Interpretation
-----------------

The smoke harness works: all-stopping-set counting, BEC peeling labels,
rank-dependency guardrail features, label/sample audits, split audits,
endpoint prevalence diagnostics, and model plumbing all executed.

This run is too small to evaluate the candidate claim. It should be used only
to guide freeze-prep decisions about enumeration cost, endpoint prevalence,
feature schema, and guardrail implementation.
