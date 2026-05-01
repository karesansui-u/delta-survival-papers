A12 S-t Cut-Spectrum Reliability Smoke Result v0
================================================

Status: smoke_evaluated_not_evidence.

This smoke run checks plumbing only. It is not validation evidence and should
not be entered as support or no-support.


1. Smoke Surface
----------------

Output directory:

```text
05_evidence/a12_st_cut_spectrum_reliability/smoke_v0
```

Smoke grid:

```text
n-values:          12,14
edge-factors:      2.0
kappas:            2,3
q-values:          0.12,0.24,0.36
graphs-per-cell:   5
failure samples K: 32
max cutset subset tests: 250000
generator seed:    51203
split seed:        61213
```

Generated surface:

```text
graphs:          20
feature rows:    60
failure samples: 1920
label rows:      60
```

Audits:

```text
cutset count sanity: passed, 3 cases
cutset status:       exact for all retained graphs
label/sample audit:  passed, 60 label rows / 1920 samples
split audit:         passed, train 12 / validation 4 / test 4 graphs
endpoint degenerate: false
```


2. Smoke Metrics
----------------

Primary metric: graph-id grouped binomial held-out test log loss.

| model | test log loss |
|---|---:|
| B0 | 0.3092930830928012 |
| B1 | 0.2884250642051188 |
| B1_hazard | 0.2876333894074492 |
| B1_SP_scalar | 0.28745008601830335 |
| B1_SP_terms | 0.2889838740359232 |
| B1_SP_bundle | 0.28877862067038274 |
| B1_hazard_SP_scalar | 0.28736529795786503 |
| B2_guardrail | 0.28635450327285955 |

Smoke comparison:

```text
B1:            0.2884250642051188
B1_SP_scalar: 0.2874500860183033
relative improvement: 0.003380351806464881
bootstrap positive rate: 0.733
B1_hazard:    0.287633389407449
B1_hazard_SP_scalar: 0.28736529795786503
hazard guardrail relative improvement: 0.0009320595572587881
hazard guardrail bootstrap positive rate: 0.835
test graph-balanced prevalence: 0.057291666666666664
```

The smoke support rule would not pass for the pre-declared scalar primary.
This is healthy for a plumbing run: the pipeline is not automatically producing
support. The scalar primary is directionally better than B1 on this smoke
surface but does not reach the 1 percent improvement or 90 percent bootstrap
gate. The hazard guardrail also remains diagnostic only.

Prevalence diagnostics were written to:

```text
05_evidence/a12_st_cut_spectrum_reliability/smoke_v0/prevalence_by_q_split.csv
```


3. Non-Claims
-------------

This smoke result does not support:

- A12 incremental empirical support;
- exact reliability superiority;
- real-world network reliability;
- A31 spanning-tree support;
- \(M\)-side validation;
- universal-law closure.
