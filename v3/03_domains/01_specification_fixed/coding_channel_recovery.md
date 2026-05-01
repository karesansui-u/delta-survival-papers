A06/A19 Coding-Channel Recovery
================================

domain_id: coding_channel_recovery

domain_name: Coding-channel recovery / finite BEC linear-code reliability

classification: specification_fixed

status: supported_v0; invalid_run_v1_rate625_cw4; no_support_v1b_rate625_cw3


1. Maintenance Target
---------------------

- Target structure: a transmitted finite message remains uniquely recoverable
  after channel erasures.
- Canonical finite testbed: a binary linear \([n,k]\) code with a fixed
  parity-check matrix \(H\), transmitted over a binary erasure channel (BEC).
- Observation unit: a code \(H\), an erasure probability \(p\), and held-out
  erasure samples.
- Collapse / failure boundary: the erased coordinates contain a nonzero
  codeword support, equivalently the erased columns of \(H\) are rank-deficient.
- Initial condition: with no erasures, the transmitted codeword is uniquely
  recoverable.

This domain is the coding-theoretic counterpart of A12. A12 reads graph
cutsets under edge failures. A06/A19 reads column-dependency pressure under
channel erasures.


2. Exact Accounting Anchor
--------------------------

Let \(H\in\mathbb F_2^{(n-k)\times n}\) be a fixed parity-check matrix and let
\(E\subseteq\{1,\ldots,n\}\) be an erasure set. The erased coordinates must
satisfy a linear system whose coefficient matrix is the erased-column submatrix
\(H_E\). The ambiguity dimension is

\[
a(E)=|E|-\operatorname{rank}_{\mathbb F_2}(H_E).
\]

The number of compatible codewords is \(2^{a(E)}\). Equivalently, the number
of distinguishable message cells has been reduced by the factor

\[
2^{-a(E)}.
\]

To align this domain with the Core set-valued kernel, \(V_E\) is not the
set of compatible codewords. Compatible codewords expand under erasure. The
shrinking object is the distinguishable message-cell mass. With \(V_0\) the
initial fully distinguishable message-cell mass, the specification-fixed
readout is

\[
\frac{m(V_E)}{m(V_0)} = 2^{-a(E)}.
\]

Thus the exact loss coordinate is

\[
L_E = a(E)\log 2.
\]

Unique recovery holds exactly when \(a(E)=0\). This exact rank accounting is a
specification-fixed anchor, not a prediction win. In a prediction-support
package, the final erasure-set rank, final ambiguity dimension, exact recovery
indicator, and exact finite-block failure probability must not be used as
model features.

Lean module `Survival.LinearCodeErasureAccountingToy` records the finite
accounting skeleton for this anchor. It fixes only an erasure-count /
erased-column-rank profile, defines \(a(E)=|E|-\operatorname{rank}(H_E)\),
the compatible multiplicity \(2^{a(E)}\), the retained distinguishable
message-cell ratio \(2^{-a(E)}\), and proves that the exact loss is
\(a(E)\log 2\). This is not a formalization of the empirical
\(\log(1+H_{\mathrm{dep},r})\) proxy and not a proof of prediction support.

Lean module `Survival.LinearCodeBECRankBoundary` records the finite deterministic
row-budget converse: if the erasure count exceeds the parity-check row count
\(r\), then \(H_E\) cannot have full column rank, \(a(E)>0\), exact loss is
positive, and unique recovery is impossible. This is an arbitrary fixed-code
linear-algebra boundary. It is not a random-code achievability theorem and not a
Shannon-capacity proof.

Lean module `Survival.LinearCodeRandomParityCheckFullRank` records the next
random-ensemble algebraic envelope: if the full-rank failure probability for an
\(r\times e\) random binary submatrix is bounded by \(2^e/2^r\), then row slack
\(e+s\le r\) implies failure probability at most \(2^{-s}\), equivalently
success probability at least \(1-2^{-s}\). This is not the exact random-matrix
full-rank product formula and not a BEC erasure-count concentration theorem.

Lean module `Survival.LinearCodeBECConcentrationBoundary` records the finite
event-level bridge from BEC erasure-count concentration to recovery failure. If
the tail event \(|E|+s>r\) has probability at most \(\delta\), and rank failure
on the row-slack side is bounded by \(2^{-s}\), then total unique-recovery
failure is bounded by \(\delta+2^{-s}\). Conversely, if \(|E|>r\) has
probability at least \(1-\delta\), then unique-recovery failure is at least
\(1-\delta\). This module assumes the erasure-count concentration envelope; it
does not prove the binomial Chernoff bound.


3. Low-Order Dependency Coordinate
----------------------------------

For a frozen order window \(r\), let \(N_j(H)\) be the number of column subsets
of size \(j\) whose columns are linearly dependent over \(\mathbb F_2\). The
low-order dependency pressure is

\[
H_{\mathrm{dep},r}(H,p)=
\sum_{j=2}^{r} N_j(H)p^j.
\]

The candidate scalar SP coordinate for the first package is

\[
\log(1+H_{\mathrm{dep},4}(H,p)).
\]

This coordinate is intentionally not the final erasure-set rank. It is a
pre-fixed code-level pressure proxy for small ambiguity-causing structures
under a BEC.


4. Prediction Surface
---------------------

The clean prediction endpoint is finite-block BEC decoding failure:

\[
Y_{H,p,s}=1\{a(E_s)>0\},
\]

where \(E_s\) is a held-out erasure sample from the BEC with probability \(p\).
Evaluation may aggregate \(K\) samples per code / \(p\) row as a binomial
label, with code-id grouped binomial log loss.

Acceptable primary targets:

- finite-block unique-recovery failure probability under BEC erasures;
- binary held-out unique-recovery failure under sampled erasure sets;
- matched-code ranking when the endpoint remains BEC recovery failure.

Secondary targets:

- iterative decoder failure;
- non-BEC channel decoding failure;
- finite-length calibration under a specific decoder.

Secondary targets require a separately frozen package.


5. Baselines and Oracle Exclusions
----------------------------------

Primary comparison:

\[
B1+\log(1+H_{\mathrm{dep},4})
\quad\text{vs}\quad
B1.
\]

Recommended \(B1\) baseline:

- \(n,k,n-k\), rate \(R=k/n\);
- erasure probability \(p\);
- capacity margin \(1-p-R\);
- parity-check density;
- row-weight and column-weight summaries.

Guardrail:

\[
B1_{\mathrm{hazard}} = B1 + p^2 + p^3 + p^4.
\]

This checks whether a scalar result is merely a nonlinear \(p\)-hazard
transform rather than dependency-count information.

Forbidden primary features:

- final erased-column rank;
- final ambiguity dimension;
- exact finite-block failure probability;
- Monte Carlo failure-probability estimate as an input feature;
- realized erasure set for the target label;
- \(N_j(H)\) or \(H_{\mathrm{dep},r}\) inside the baseline.


6. Validation Status
--------------------

The first frozen primary package passed:

```text
05_evidence/a06_a19_coding_channel_recovery/primary_v0_result_summary.md
```

Frozen primary_v0 result:

```text
B1 test log loss:             0.43822689815179555
B1 + SP scalar test log loss: 0.4289932917900723
relative improvement:         0.02107037792674442
bootstrap positive rate:      1.0
decision:                     support
```

The package established that:

1. exact rank accounting closes for generated samples;
2. final-rank oracle features are excluded from prediction features;
3. the pipeline can compare a natural coding baseline against the pre-fixed
   low-order dependency coordinate;
4. on the frozen finite BEC sparse parity-check surface, the pre-fixed scalar
   dependency coordinate improves the natural coding baseline under the frozen
   support rule.

This is finite synthetic coding-channel support. It is not Shannon-capacity
theorem support, arbitrary-code support, non-BEC support, exact
failure-probability superiority, or \(M\)-side validation.


Successor packages:

```text
v1_rate625_cw4: invalid_run_generation_infeasible
v1b_rate625_cw3: no_support
```

The rate-0.625 / column-weight-4 successor surface was invalid before outcome
evaluation. With a fixed even column weight, every parity-check column lies in
the even-parity subspace of \(\mathbb F_2^r\), so the generator could not
produce full row-rank parity-check matrices. This is recorded as an invalid
generation surface, not no-support for the dependency-pressure coordinate.

The independently seeded rate-0.625 / column-weight-3 successor package ran
to completion. The scalar dependency coordinate was directionally positive,
but the relative log-loss improvement was 0.8524 percent, below the frozen
1 percent support gate:

```text
B1 test log loss:             0.5320604873602987
B1 + SP scalar test log loss: 0.5275253598451052
relative improvement:         0.008523706651650663
bootstrap positive rate:      1.0
decision:                     no_support
```

This successor result limits the immediate scope of the v0 support. It does
not invalidate the exact rank-accounting anchor, and it does not erase the
supported v0 surface.
