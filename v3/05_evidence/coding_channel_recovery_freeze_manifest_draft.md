A06/A19 Coding-Channel Recovery Freeze Manifest Draft
=====================================================

Status: draft only; not frozen; not validation evidence.

domain_id: coding_channel_recovery

candidate_id: a06_a19_coding_channel_recovery


1. Purpose
----------

This draft defines a finite BEC / binary-linear-code candidate package for the
specification-fixed layer.

The key governance split is:

- exact rank accounting is the theorem-side anchor;
- oracle-free finite-block prediction is the empirical-support question.


2. Exact Accounting Anchor
--------------------------

For a fixed binary parity-check matrix \(H\) and an erasure set \(E\), define

\[
a(E)=|E|-\operatorname{rank}_{\mathbb F_2}(H_E).
\]

The compatible-codeword count is \(2^{a(E)}\), the distinguishability mass
shrinks by \(2^{-a(E)}\), and the exact loss is

\[
L_E=a(E)\log 2.
\]

This rank identity is not an empirical prediction win.


3. Primary Prediction Candidate
-------------------------------

Primary endpoint:

```text
finite-block BEC unique-recovery failure
```

For every code / erasure probability row, sample \(K\) independent BEC erasure
sets and aggregate the failure count as a binomial label.

Primary coordinate:

```text
log1p_H_dep_4 = log(1 + N_2 p^2 + N_3 p^3 + N_4 p^4)
```

where \(N_j\) counts dependent parity-check column subsets of size \(j\).

Primary comparison:

```text
B1_SP_scalar vs B1
```

Primary metric:

```text
code-id grouped binomial log loss
```


4. Baseline and Guardrails
--------------------------

B1 natural coding baseline:

```text
p
n
k
r = n-k
rate
capacity_margin = 1 - p - rate
parity_check_density
row_weight_mean / variance / min / max
column_weight_mean / variance / min / max
```

Hazard guardrail:

```text
B1_hazard = B1 + p^2 + p^3 + p^4
B1_hazard_SP_scalar = B1_hazard + log1p_H_dep_4
```

Attribution diagnostics:

```text
B1_SP_terms = B1 + N_2 p^2 + N_3 p^3 + N_4 p^4
B1_SP_bundle = B1 + terms + log1p_H_dep_4
```


5. Oracle Exclusions
--------------------

Forbidden primary features:

- final erased-column rank;
- final ambiguity dimension;
- exact finite-block failure probability;
- Monte Carlo failure-probability estimate as a model feature;
- realized erasure set for the label being predicted;
- \(N_j\) or dependency pressure inside B1.

Rank and ambiguity dimension may be used to compute labels and accounting
audits, but not as prediction features.


6. Draft Smoke Surface
----------------------

Suggested smoke surface:

```text
n-values:       24,32
rates:          0.50
column-weight:  3
q-values:       0.18,0.24,0.30,0.36
codes-per-cell: 40
samples:        128
dependency-order: 4
```

Smoke output is not validation evidence. It only checks feasibility,
nondegenerate endpoints, accounting audits, and whether the comparison surface
is well formed.


7. Support Rule Template
------------------------

A future frozen primary package may use:

1. `B1_SP_scalar` has lower held-out grouped binomial log loss than `B1`;
2. relative improvement is at least 1 percent;
3. paired code-id bootstrap positive rate is at least 90 percent;
4. endpoint prevalence is in \([0.02,0.98]\);
5. rank accounting audit passes;
6. label/sample audit passes;
7. split integrity audit passes.


8. Non-Claims
-------------

This package does not claim:

- Shannon-capacity theorem support;
- arbitrary-code support;
- non-BEC support;
- decoder-specific non-ML recovery support;
- exact failure-probability superiority;
- \(M\)-side validation;
- universal-law closure.
