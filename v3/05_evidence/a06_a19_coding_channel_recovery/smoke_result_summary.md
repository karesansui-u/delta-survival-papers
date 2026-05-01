A06/A19 Coding-Channel Recovery Smoke v0
========================================

Status: smoke only; not frozen; not validation evidence.

Run directory:

```text
05_evidence/a06_a19_coding_channel_recovery/smoke_v0
```

Smoke surface:

```text
n-values:       24,32
rate:           0.50
column-weight:  3
q-values:       0.18,0.24,0.30,0.36
codes-per-cell: 40
samples:        128 per code/q row
dependency-order: 4
```

Core governance split:

- exact rank accounting is the specification-fixed anchor;
- rank and ambiguity are used for label/accounting audit only;
- final rank, final ambiguity, realized erasure set, exact failure probability,
  and Monte Carlo failure estimates are not model features;
- the empirical question is whether a pre-fixed low-order dependency-pressure
  coordinate improves an oracle-free natural coding baseline.

Audits:

```text
split integrity:      passed
rank/sample audit:    passed
audited samples:      40,960
audited label rows:   320
K per code/q row:     128
test prevalence:      0.167969
endpoint degenerate:  false
```

Primary smoke comparison:

```text
B1 test log loss:             0.437817
B1 + SP scalar test log loss: 0.431482
relative improvement:         1.4469%
bootstrap positive rate:      0.950
smoke support rule pass:      true
```

Hazard guardrail:

```text
B1 hazard test log loss:             0.435385
B1 hazard + SP scalar test log loss: 0.429982
relative improvement:                1.2411%
bootstrap positive rate:             0.933
```

Interpretation:

This is a successful smoke run for the A06/A19 candidate surface. It shows that
the pipeline is nondegenerate, the rank accounting audit closes, and the
pre-fixed scalar dependency coordinate `log1p_H_dep_4` improves the natural
coding baseline on the smoke held-out split.

This is not evidence because the manifest was not frozen before this smoke
execution. A support-bearing package must pin the final surface, scripts,
hashes, seeds, commands, primary model, support gates, and output directory
before the outcome-bearing run.
