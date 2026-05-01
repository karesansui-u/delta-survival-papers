A06-stop Row-Level Diagnostic Memo After Normalized-Pressure Smoke v1
====================================================================

domain_id: coding_channel_stopping_set_recovery

status: diagnostic_only_not_validation_evidence

date: 2026-05-01 JST


0. Governance Status
--------------------

This memo is diagnostic only. It analyzes existing freeze-prep smoke rows to
understand proxy behavior. It does not promote any feature to support-bearing
status. Any successor package must be separately manifested before
outcome-bearing execution.

Source run:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  normalized_pressure_freeze_prep_smoke_v1/
```

The source run is smoke-only. It is not support and not no-support.


1. Raw Scalar Identity
----------------------

The raw scalar remains stronger than the normalized scalar on this smoke
surface:

```text
B1_degree test log loss:                     0.5220753205672559
B1_degree + raw stop scalar test log loss:   0.5194700791592872
B1_degree + raw stop terms test log loss:    0.5190143229682518
B1_degree + normalized scalar test loss:     0.52062333265115
B1_degree + normalized terms test loss:      0.5207181562015438
```

However, the raw scalar is also strongly entangled with generic hazard and
rank-dependency structure. Across all feature rows:

```text
corr(log1p_H_stop_5, q):                       Pearson 0.7983, Spearman 0.8679
corr(log1p_H_stop_5, log1p_H_dep_4):            Pearson 0.6777, Spearman 0.7349
corr(log1p_H_stop_5, failure_fraction):         Pearson 0.8985, Spearman 0.9457
corr(log1p_H_stop_5, rank_failure_fraction):    Pearson 0.8881, Spearman 0.9216
```

On the held-out test rows the same pattern remains:

```text
corr(log1p_H_stop_5, q):                       Pearson 0.8174, Spearman 0.8821
corr(log1p_H_stop_5, log1p_H_dep_4):            Pearson 0.7445, Spearman 0.7852
corr(log1p_H_stop_5, failure_fraction):         Pearson 0.9091, Spearman 0.9450
corr(log1p_H_stop_5, rank_failure_fraction):    Pearson 0.8986, Spearman 0.9237
```

Linear absorption diagnostics also suggest that the raw scalar is largely
recoverable from existing coarse features:

```text
R2(log1p_H_stop_5 ~ B0):                 0.7379
R2(log1p_H_stop_5 ~ B1_degree):          0.8185
R2(log1p_H_stop_5 ~ B1_degree_hazard):   0.8440
R2(log1p_H_stop_5 ~ B1_degree_rankdep):  0.8621
```

Interpretation: raw all-stopping pressure is predictive on this smoke surface,
but a large part of that signal is consistent with volume / erasure-hazard /
rank-dependency pressure. It should not be treated as a clean stopping-set
specific coordinate without stronger guardrails.


2. Normalized Scalar Weakening
------------------------------

Normalization reduces the raw subset-volume effect, but it also weakens and
compresses the signal. Across all feature rows:

```text
corr(log1p_H_stop_5_norm, q):                    Pearson 0.4070, Spearman 0.3942
corr(log1p_H_stop_5_norm, n):                    Pearson -0.4608, Spearman -0.5066
corr(log1p_H_stop_5_norm, log1p_H_dep_4):         Pearson 0.7681, Spearman 0.8991
corr(log1p_H_stop_5_norm, failure_fraction):      Pearson 0.5740, Spearman 0.5979
corr(log1p_H_stop_5_norm, rank_failure_fraction): Pearson 0.7600, Spearman 0.7517
```

On the held-out test rows:

```text
corr(log1p_H_stop_5_norm, q):                    Pearson 0.4397, Spearman 0.4199
corr(log1p_H_stop_5_norm, n):                    Pearson -0.5382, Spearman -0.5853
corr(log1p_H_stop_5_norm, log1p_H_dep_4):         Pearson 0.7641, Spearman 0.8772
corr(log1p_H_stop_5_norm, failure_fraction):      Pearson 0.5608, Spearman 0.5792
corr(log1p_H_stop_5_norm, rank_failure_fraction): Pearson 0.7142, Spearman 0.7197
```

The normalized scalar is less dominated by \(q\), but it becomes more sensitive
to \(n\) and remains highly aligned with rank-dependency pressure.

Absorption diagnostics:

```text
R2(log1p_H_stop_5_norm ~ B0):                 0.3780
R2(log1p_H_stop_5_norm ~ B1_degree):          0.4379
R2(log1p_H_stop_5_norm ~ B1_degree_hazard):   0.4402
R2(log1p_H_stop_5_norm ~ B1_degree_rankdep):  0.7710
```

The normalized scalar values are also very small on this surface:

```text
test n=24, q=0.18 mean log1p_H_stop_5_norm:  0.0001701261
test n=24, q=0.36 mean log1p_H_stop_5_norm:  0.0007367889
test n=32, q=0.18 mean log1p_H_stop_5_norm:  0.0000427580
test n=32, q=0.36 mean log1p_H_stop_5_norm:  0.0001821274
```

Interpretation: normalized pressure is cleaner as a design, because it
suppresses raw subset-volume effects, but the present scalar form may be
over-compressed. It is not stronger than the raw scalar on predictive log loss
in this smoke.


3. Order-Wise Term Behavior
---------------------------

Order-wise diagnostics suggest that the scalar aggregate is hiding uneven
order behavior.

Against \(B1_{\mathrm{degree}}\), raw single-order additions:

```text
B1 + raw j=2:   relative improvement 0.003754
B1 + raw j=3:   relative improvement 0.000020
B1 + raw j=4:   relative improvement 0.003762
B1 + raw j=5:   relative improvement 0.001675
B1 + raw terms: relative improvement 0.005863
```

Against \(B1_{\mathrm{degree}}\), normalized single-order additions:

```text
B1 + norm j=2:   relative improvement 0.002710
B1 + norm j=3:   relative improvement -0.000200
B1 + norm j=4:   relative improvement 0.001563
B1 + norm j=5:   relative improvement 0.000234
B1 + norm terms: relative improvement 0.002600
```

The strongest single normalized term is \(j=2\), followed by \(j=4\). The
\(j=3\) term is negative in this smoke, and \(j=5\) is weak. This supports the
idea that a future term-vector design should be pre-fixed and order-aware,
rather than simply summing all normalized terms into one scalar.


4. Guardrail Residuals
----------------------

The hazard baseline itself is strong:

```text
B1_degree test log loss:         0.5220753205672559
B1_degree_hazard test log loss:  0.5189082114279472
relative improvement:            0.006066
```

Normalized scalar guardrails from the smoke summary:

```text
hazard guardrail relative improvement:   0.0019965147542006364
hazard guardrail bootstrap positive:     0.871
rankdep guardrail relative improvement:  0.0006212783280745545
rankdep guardrail bootstrap positive:    0.754
```

Order-wise normalized terms after guardrails:

```text
hazard + norm j=2:   relative improvement 0.002057
hazard + norm j=3:   relative improvement -0.000341
hazard + norm j=4:   relative improvement 0.000524
hazard + norm j=5:   relative improvement -0.000210

rankdep + norm j=2:  relative improvement 0.000549
rankdep + norm j=3:  relative improvement -0.000119
rankdep + norm j=4:  relative improvement 0.001132
rankdep + norm j=5:  relative improvement -0.000071
```

Interpretation: the residual stopping-set signal is not absent, but it is not
clean. The \(j=2\) term remains most visible after hazard, while \(j=4\)
remains more visible after rank-dependency. Neither pattern is strong enough
to justify immediate primary freezing.


5. Regime Notes
---------------

The endpoint remains useful across the \(q\)-grid:

```text
test q=0.18 prevalence: 0.068359375
test q=0.24 prevalence: 0.16455078125
test q=0.30 prevalence: 0.31494140625
test q=0.36 prevalence: 0.53369140625
```

The \(n=24\) and \(n=32\) normalized pressures differ substantially even after
normalization. For example, at \(q=0.36\):

```text
test n=24 mean log1p_H_stop_5_norm: 0.0007367889
test n=32 mean log1p_H_stop_5_norm: 0.0001821274
```

This suggests that the current normalization may over-penalize larger \(n\) or
that the generated sparse-code surface changes qualitatively with \(n\). Any
successor design should include explicit \(n\)-regime diagnostics and should
not assume that normalization has removed finite-size structure.


6. Design Conclusion
--------------------

The current evidence remains smoke-only. The conclusions are:

1. Do not freeze the normalized scalar primary yet.
2. Do not promote raw scalar performance to support; it is too entangled with
   \(q\), rank-dependency, and hazard-like structure.
3. Treat normalized pressure as a live candidate, but not in the present scalar
   form.
4. The most plausible successor is an order-wise normalized term-vector design,
   especially one that examines \(j=2\) and \(j=4\) behavior under hazard and
   rank-dependency guardrails.
5. Any successor must be a new manifest, not a promotion of this diagnostic
   smoke.

Recommended next candidate:

```text
A06-stop-v2-order-wise-normalized-terms
```

This candidate should be drafted only after review of this diagnostic memo.
