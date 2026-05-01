A06-stop v2 Order-Wise Normalized-Terms Manifest Draft
======================================================

Status: draft only; not frozen; not validation evidence.

Date drafted: 2026-05-01 JST

manifest_id: a06_stop_v2_orderwise_normalized_terms_draft

domain_id: coding_channel_stopping_set_recovery

Diagnostic predecessor:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  row_level_diagnostic_memo_after_normalized_pressure_smoke_v1.md
```


1. Governance
-------------

This is a successor draft, not a promotion of any existing smoke result.

The predecessor diagnostic memo showed that:

- raw stopping pressure is predictive but strongly entangled with \(q\),
  hazard, and rank-dependency pressure;
- normalized scalar pressure is cleaner as a design but appears
  over-compressed on the smoke surface;
- order-wise behavior is uneven, with \(j=2\) and \(j=4\) looking more
  promising than \(j=3\) and \(j=5\) in the diagnostic run.

The v2 primary design therefore fixes the full order-wise normalized vector
\(j=2,\ldots,5\) as a bundle. It does not select only \(j=2\) or \(j=4\) as the
primary coordinate. Order-specific effects are attribution diagnostics only.


2. Structural Condition
-----------------------

The structural condition is unchanged from the A06-stop profile:

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

This endpoint is decoder-specific. It is not the same structural condition as
full maximum-likelihood message recovery in the A06/A19 rank-dependency
package.


3. Primary Coordinate
---------------------

For each order \(j=2,\ldots,5\), let \(N_j^{\mathrm{stop}}(H)\) be the number
of all stopping sets of size \(j\), not only minimal stopping sets.

The v2 primary bundle is:

\[
\left(
  \frac{N_2^{\mathrm{stop}}(H)}{\binom{n}{2}}p^2,\,
  \frac{N_3^{\mathrm{stop}}(H)}{\binom{n}{3}}p^3,\,
  \frac{N_4^{\mathrm{stop}}(H)}{\binom{n}{4}}p^4,\,
  \frac{N_5^{\mathrm{stop}}(H)}{\binom{n}{5}}p^5
\right).
\]

Feature names:

```text
N_stop_2_norm_q2
N_stop_3_norm_q3
N_stop_4_norm_q4
N_stop_5_norm_q5
```

The scalar

\[
\log(1+\widetilde H_{\mathrm{stop},5})
\]

is diagnostic only in v2. It is not the primary support-bearing coordinate.


4. Baselines
------------

Simple baseline, reported only as a diagnostic:

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

Primary degree-rich baseline:

```text
B1_degree =
B1_simple
column_weight
check_degree_mean / variance / min / max
variable_degree_mean / variance / min / max
check_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
variable_degree_count_1 / count_2 / count_3 / count_4 / count_ge5
```

Primary comparison:

```text
B1_degree + orderwise_normalized_stop_terms
vs
B1_degree
```


5. Guardrails
-------------

Hazard guardrail:

```text
B1_degree_hazard =
  B1_degree + p^2 + p^3 + p^4 + p^5

B1_degree_hazard + orderwise_normalized_stop_terms
```

Rank-dependency guardrail:

```text
B1_degree_rankdep =
  B1_degree + log1p_H_dep_4

B1_degree_rankdep + orderwise_normalized_stop_terms
```

Clean support requires:

1. primary gate passes;
2. hazard guardrail remains directionally positive with paired code-id
   bootstrap positive rate at least 0.90;
3. rank-dependency guardrail remains directionally positive with paired code-id
   bootstrap positive rate at least 0.90.

If the primary gate passes but either guardrail has nonpositive improvement or
bootstrap positive rate below 0.90, the result is caveated support only. If
the primary gate fails, the result is no-support for this package.


6. Attribution Diagnostics
--------------------------

Attribution diagnostics must be reported, but cannot determine the primary
support decision:

- single-order additions \(j=2,3,4,5\) against \(B1_{\mathrm{degree}}\);
- single-order additions after the hazard guardrail;
- single-order additions after the rank-dependency guardrail;
- scalar normalized pressure as a diagnostic comparator;
- raw pressure scalar and raw pressure terms as diagnostic comparators.

The predecessor memo observed stronger diagnostic behavior for \(j=2\) and
\(j=4\). This observation motivates attribution reporting, not primary feature
selection.


7. Draft Surface
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

This draft surface is suitable for smoke / freeze-prep diagnostics. A
support-bearing primary package requires a separate frozen manifest with
script hashes, seeds, commands, final surface, and support rule fixed before
execution.


8. No-Oracle Rule
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


9. Candidate Support Rule
-------------------------

Candidate primary support is true only if all conditions hold on a future
frozen test set:

1. `B1_degree + orderwise_normalized_stop_terms` has lower code-id grouped
   binomial log loss than `B1_degree`.
2. Relative log-loss improvement of the primary comparison is at least
   1 percent.
3. Paired code-id bootstrap positive rate is at least 90 percent.
4. Test endpoint is nondegenerate: code-balanced prevalence is in
   \([0.02,0.98]\).
5. Peeling label/sample audit passes.
6. Split integrity audit passes.
7. Clean / caveated status is assigned by the guardrail rule in Section 5.

This draft should be reviewed before any support-bearing primary execution.
