A06-stop Order-Wise Normalized-Terms Freeze-Prep Smoke v2 Summary
=================================================================

domain_id: coding_channel_stopping_set_recovery

package_id: a06_stop_orderwise_terms_freeze_prep_smoke_v2

status: freeze_prep_smoke_only_not_validation_evidence

date: 2026-05-01 JST


1. Scope
--------

This is a freeze-prep smoke run for the A06-stop v2 order-wise normalized-term
design. It is not frozen validation evidence and must not be interpreted as
support or no-support.

The primary smoke coordinate is the pre-fixed order-wise normalized stopping
bundle:

```text
N_stop_2_norm_q2
N_stop_3_norm_q3
N_stop_4_norm_q4
N_stop_5_norm_q5
```

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
generation elapsed:      70.2s
```

Counter micro-benchmark:

```text
n=24 subset tests/code:  55,430
n=24 elapsed/code:       about 0.17s
n=32 subset tests/code:  242,792
n=32 elapsed/code:       about 0.71-0.73s
mean elapsed/code:       0.445s
```

Evaluation audits:

```text
split_integrity_audit:   passed
label/sample audit:      passed
train codes:             48
validation codes:        16
test codes:              16
test prevalence:         0.2518310546875
endpoint_degenerate:     false
```


3. Endpoint Diagnostics
-----------------------

Test prevalence by \(q\):

```text
q=0.18: 0.056640625
q=0.24: 0.1396484375
q=0.30: 0.287109375
q=0.36: 0.52392578125
```

The endpoint is nondegenerate across the candidate \(q\)-grid.


4. Model And Guardrail Diagnostics
----------------------------------

Primary smoke comparison:

```text
B1_degree test log loss:                         0.5097949732191456
B1_degree + orderwise normalized terms loss:     0.5041867679825616
relative improvement:                            0.011000903365465725
bootstrap positive rate:                         0.999
primary_smoke_gate_would_pass:                   true
```

Guardrail diagnostics:

```text
B1_degree_hazard test log loss:                  0.505468640559161
B1_degree_hazard + orderwise terms loss:         0.5006903928832611
hazard relative improvement:                     0.00945310409487331
hazard bootstrap positive:                       1.0

B1_degree_rankdep test log loss:                 0.5033376799757282
B1_degree_rankdep + orderwise terms loss:        0.5020020300390309
rankdep relative improvement:                    0.0026535862301461963
rankdep bootstrap positive:                      0.804

clean_guardrails_would_pass:                     false
```

Other model diagnostics:

```text
B0 test log loss:                                0.5114732554225543
B1_simple test log loss:                         0.5114571675747601
B1_degree_hazard test log loss:                  0.505468640559161
raw stop scalar diagnostic test log loss:        0.5037622275289776
raw stop terms diagnostic test log loss:         0.5016588915740018
normalized scalar diagnostic test log loss:      0.5048884590225649
```


5. Interpretation
-----------------

This freeze-prep smoke is operationally healthy: all-stopping-set counting,
peeling labels, rank-dependency guardrail features, label/sample audits, split
audits, endpoint diagnostics, model fitting, and guardrail reporting all
executed.

The v2 order-wise normalized bundle is substantially stronger than the v1
normalized scalar on this smoke surface. The primary smoke comparison crosses
the 1 percent relative-improvement threshold and has bootstrap positive rate
above 0.90.

Raw stopping-pressure diagnostics still have lower test log loss than the
order-wise normalized bundle on this smoke surface. They remain non-primary
because the row-level diagnostic memo found strong entanglement with \(q\),
hazard, and rank-dependency pressure.

However, this is still smoke-only, not validation evidence. In addition, the
clean guardrail rule would not pass because the rank-dependency guardrail has
bootstrap positive rate 0.804, below the 0.90 clean-support threshold. The
appropriate reading is therefore:

```text
promising freeze-prep smoke;
not support;
not no-support;
clean-support risk remains concentrated in the rank-dependency guardrail.
```

If this design proceeds, the next step should not reinterpret this run as
evidence. The next step should be review of this smoke, followed by a separate
frozen manifest if the governance decision is to run a support-bearing
package.
