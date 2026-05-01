A06-stop v1 Normalized-Pressure Manifest Draft
==============================================

Status: draft only; not frozen; not validation evidence.

Date drafted: 2026-05-01 JST

manifest_id: a06_stop_v1_normalized_pressure_draft

domain_id: coding_channel_stopping_set_recovery

Predecessor design memo:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/redesign_memo_after_freeze_prep_smoke_v1.md
```


1. Candidate Claim
------------------

Candidate primary claim:

> For finite random sparse binary linear codes under a fixed BEC erasure law
> and a fixed peeling decoder, normalized all-stopping-set pressure adds
> predictive value for held-out peeling-decoder failure beyond a pre-fixed
> degree-rich baseline.

This is a new proxy design. It is not a rescue of the earlier
\(\log(1+H_{\mathrm{stop},5})\) scalar smoke result.


2. Structural Condition
-----------------------

The structural condition remains:

```text
After BEC erasures, all erased transmitted codeword coordinates are recovered
by the fixed peeling / iterative decoder.
```

For a fixed parity-check matrix \(H\) and erasure set \(E\), let
\(S_\infty(H,E)\) be the residual erased set after BEC peeling terminates.
The endpoint is

\[
Y=1\{|S_\infty(H,E)|>0\}.
\]


3. Candidate Primary Coordinate
-------------------------------

For v1, the candidate scalar coordinate is normalized all-stopping-set
pressure:

\[
\widetilde H_{\mathrm{stop},5}(H,p)
=
\sum_{j=2}^{5}
\frac{N_j^{\mathrm{stop}}(H)}{\binom{n}{j}}p^j.
\]

The support-bearing scalar is

\[
\log(1+\widetilde H_{\mathrm{stop},5}(H,p)).
\]

\(N_j^{\mathrm{stop}}(H)\) still counts all stopping sets of size \(j\), not
only minimal stopping sets. The normalization only reduces the raw subset
volume effect; it does not turn the coordinate into an exact union
probability.

Normalized term-vector diagnostics:

```text
N_stop_2_norm_q2
N_stop_3_norm_q3
N_stop_4_norm_q4
N_stop_5_norm_q5
```

These terms are diagnostic only unless a separate manifest promotes them
before outcome-bearing execution.

If the scalar form appears over-compressed in smoke diagnostics, an order-wise
term-vector package may be drafted later. Such a package must be treated as a
new pre-fixed design, not as a promotion of the present smoke result.


4. Candidate Baselines
----------------------

Two baseline tiers must be reported.

Simple baseline:

```text
B1_simple =
q
n
k
r = n-k
rate
capacity_margin = 1 - q - rate
parity_check_density
```

Degree-rich baseline:

```text
B1_degree =
B1_simple
column_weight
check_degree_mean / variance / min / max
variable_degree_mean / variance / min / max
check_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
variable_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
```

The proposed primary comparison is against the stronger tier:

```text
B1_degree_SP_norm_scalar vs B1_degree
```

The simple baseline comparison is diagnostic only.


5. Guardrails
-------------

Hazard guardrail:

```text
B1_degree_hazard = B1_degree + p^2 + p^3 + p^4 + p^5
B1_degree_hazard_SP_norm_scalar =
  B1_degree_hazard + log1p_H_stop_5_norm
```

Rank-dependency guardrail:

```text
B1_degree_rankdep = B1_degree + log1p_H_dep_4
B1_degree_rankdep_SP_norm_scalar =
  B1_degree_rankdep + log1p_H_stop_5_norm
```

Clean support requires the primary gate to pass and both guardrail comparisons
to remain directionally positive with paired code-id bootstrap positive rate
at least 0.90. If the primary gate passes but either guardrail comparison has
nonpositive improvement or bootstrap positive rate below 0.90, the result is
caveated support only.


6. Draft Surface
----------------

Freeze-prep candidate surface:

```text
n-values:                  24,32
rate:                      0.50
column-weight:             3
q-values:                  0.18,0.24,0.30,0.36
codes-per-cell:            40
erasure-samples per row:   128
stopping-order:            5
dependency-order:          4
```

This surface is suitable for smoke / freeze-prep diagnostics. A support-bearing
primary package requires a separate frozen manifest with script hashes, seeds,
commands, and the final surface fixed before execution.


7. No-Oracle Rule
-----------------

Forbidden primary features:

- realized erasure set for the target label;
- final peeling residual \(S_\infty(H,E)\);
- \(|S_\infty(H,E)|\) for the target label;
- exact peeling failure indicator;
- exact finite-block peeling failure probability;
- Monte Carlo peeling failure estimate as an input feature;
- stopping-set counts or stopping pressure inside any baseline tier;
- outcome-derived feature selection.


8. Candidate Support Rule
-------------------------

Candidate primary support is true only if all conditions hold on a future
frozen test set:

1. `B1_degree_SP_norm_scalar` has lower code-id grouped binomial log loss than
   `B1_degree`.
2. Relative log-loss improvement is at least 1 percent.
3. Paired code-id bootstrap positive rate is at least 90 percent.
4. Test endpoint is nondegenerate: code-balanced prevalence is in
   \([0.02,0.98]\).
5. Peeling label/sample audit passes.
6. Split integrity audit passes.
7. Clean / caveated status is assigned by the guardrail rule in Section 5.

This draft should be reviewed before any support-bearing primary execution.
