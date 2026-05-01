A06-stop Coding-Channel Stopping-Set Recovery
=============================================

domain_id: coding_channel_stopping_set_recovery

domain_name: Coding-channel stopping-set recovery / finite BEC iterative decoding

classification: specification_fixed

status: no_support_v2_orderwise_terms


1. Maintenance Target
---------------------

- Target structure: all erased transmitted codeword coordinates are recovered
  by a fixed peeling / iterative decoder after BEC erasures.
- Canonical finite testbed: a binary linear code with a fixed parity-check
  matrix \(H\), transmitted over a binary erasure channel (BEC), decoded by
  the standard BEC peeling decoder.
- Observation unit: a code \(H\), an erasure probability \(p\), and held-out
  erasure samples.
- Collapse / failure boundary: the erased coordinates contain a nonempty
  stopping set, equivalently the peeling decoder halts with a nonempty
  residual erased core.
- Initial condition: with no erasures, all transmitted coordinates are known
  and the decoder has no unresolved erased core.

This is a successor candidate to A06/A19, not a reinterpretation of its row
data. A06/A19 tests maximum-likelihood-style unique recovery through rank
accounting. A06-stop tests decoder-specific recovery under the BEC peeling
decoder. The two structural conditions are different.


2. Specification-Fixed Stopping Core
------------------------------------

Let \(H\) be a fixed parity-check matrix and let
\(E\subseteq\{1,\ldots,n\}\) be an erasure set. The BEC peeling decoder
iteratively removes an erased variable whenever it is the unique erased
neighbor of some check. Let

\[
S_\infty(H,E)
\]

be the residual erased set after this peeling process terminates. Then
\(S_\infty(H,E)\) is either empty or a stopping set: every check adjacent to
it has at least two neighbors inside it.

The decoder-specific collapse boundary is

\[
|S_\infty(H,E)|>0.
\]

This boundary is specification-fixed once \(H\), the BEC law, and the peeling
decoder are fixed. It is not the same as the rank boundary \(a(E)>0\). A
stopping-set failure may occur even when the erased columns still have full
rank and maximum-likelihood unique recovery would be possible.


3. Decoder-Specific Mass Readout
--------------------------------

For this candidate, the maintained object is algorithmic recoverability of
the erased codeword coordinates under the fixed peeling decoder. The shrinking
mass is the decoder-resolved coordinate-cell mass, not the set of compatible
codewords and not a separate projection onto systematic message coordinates.

One exact decoder-specific readout for a realized erasure set is

\[
\frac{m(V_E^{\mathrm{peel}})}{m(V_0^{\mathrm{peel}})}
=2^{-|S_\infty(H,E)|}.
\]

The corresponding loss coordinate is

\[
L_{\mathrm{stop}}(H,E)=|S_\infty(H,E)|\log 2.
\]

This is an algorithmic recovery loss coordinate. It should not be confused
with the information-theoretic ambiguity coordinate
\(a(E)\log 2\). The two coordinates answer different structural questions:
unique identifiability versus recovery by the fixed iterative decoder.


4. Low-Order Stopping-Set Pressure
----------------------------------

For a frozen order window \(r\), let \(N_j^{\mathrm{stop}}(H)\) be the number
of stopping sets of size \(j\) in \(H\). In the v0 candidate this means all
stopping sets of size \(j\), not only minimal stopping sets. This intentionally
allows superset overcounting: \(H_{\mathrm{stop},r}\) is a pre-fixed pressure
proxy, not an exact union probability and not a minimal-stopping-set theorem.
The initial scalar candidate pressure was

\[
H_{\mathrm{stop},r}(H,p)
=\sum_{j=2}^{r}N_j^{\mathrm{stop}}(H)p^j.
\]

The proposed v0 scalar coordinate was

\[
\log(1+H_{\mathrm{stop},5}(H,p)).
\]

This coordinate is code-level and pre-outcome. It does not use the realized
erasure set, the final residual stopping core, or the exact iterative-decoder
failure probability.

After freeze-prep diagnostics, the support-bearing v2 package used the
order-wise normalized bundle

\[
\left(
  \frac{N_2^{\mathrm{stop}}(H)}{\binom{n}{2}}p^2,\,
  \frac{N_3^{\mathrm{stop}}(H)}{\binom{n}{3}}p^3,\,
  \frac{N_4^{\mathrm{stop}}(H)}{\binom{n}{4}}p^4,\,
  \frac{N_5^{\mathrm{stop}}(H)}{\binom{n}{5}}p^5
\right)
\]

as the primary coordinate. This bundle also remains pre-outcome and
code-level.


5. Prediction Surface
---------------------

The clean prediction endpoint is finite-block BEC peeling-decoder failure:

\[
Y_{H,p,s}=1\{|S_\infty(H,E_s)|>0\},
\]

where \(E_s\) is a held-out erasure sample from the BEC with probability \(p\).
Evaluation may aggregate \(K\) samples per code / \(p\) row as a binomial
label, with code-id grouped binomial log loss.

Acceptable primary targets:

- finite-block peeling-decoder failure probability under BEC erasures;
- binary held-out peeling failure under sampled erasure sets;
- matched-code ranking when the endpoint remains BEC peeling failure.

Secondary targets:

- maximum-likelihood unique recovery;
- non-BEC decoding failure;
- soft reliability or ambiguity-size prediction;
- decoder variants other than the frozen peeling decoder.

Secondary targets require separately frozen packages.


6. Baselines, Guardrails, And Oracle Exclusions
-----------------------------------------------

Initial scalar comparison:

\[
B1+\log(1+H_{\mathrm{stop},5})
\quad\text{vs}\quad
B1.
\]

Recommended \(B1\) baseline:

- \(n,k,n-k\), rate \(R=k/n\);
- erasure probability \(p\);
- capacity margin \(1-p-R\);
- parity-check density;
- check-degree and variable-degree summaries;
- check-degree histogram counts for small degrees;
- variable-degree histogram counts for small degrees.

The frozen v2 primary comparison was:

\[
B1_{\mathrm{degree}}+\text{orderwise normalized stopping terms}
\quad\text{vs}\quad
B1_{\mathrm{degree}}.
\]

Guardrails:

\[
B1_{\mathrm{hazard}}=B1+p^2+p^3+p^4+p^5.
\]

\[
B1_{\mathrm{hazard+stop}}=B1_{\mathrm{hazard}}+\log(1+H_{\mathrm{stop},5}).
\]

\[
B1_{\mathrm{rankdep}}=B1+\log(1+H_{\mathrm{dep},4}).
\]

\[
B1_{\mathrm{rankdep+stop}}=B1_{\mathrm{rankdep}}+\log(1+H_{\mathrm{stop},5}).
\]

The first guardrail checks whether the stopping-set coordinate is merely a
nonlinear \(p\)-hazard transform by comparing \(B1_{\mathrm{hazard+stop}}\)
against \(B1_{\mathrm{hazard}}\). The second checks whether the result is
absorbed by the rank-dependency coordinate from A06/A19 by comparing
\(B1_{\mathrm{rankdep+stop}}\) against \(B1_{\mathrm{rankdep}}\).

Clean stopping-set support requires the primary gate to pass and both
guardrail comparisons to remain directionally positive with paired bootstrap
positive rate at least 0.90. If the primary gate passes but either guardrail
comparison has nonpositive improvement or bootstrap positive rate below 0.90,
the result is only caveated support, not clean stopping-set support.

Forbidden primary features:

- realized erasure set for the target label;
- final peeling residual core \(S_\infty(H,E)\);
- exact peeling failure indicator;
- exact finite-block peeling failure probability;
- Monte Carlo failure-probability estimate as an input feature;
- \(N_j^{\mathrm{stop}}(H)\) or \(H_{\mathrm{stop},r}\) inside the baseline.


7. Validation Status
--------------------

The first support-bearing package is:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  freeze_manifest_v2_orderwise_terms.md
```

Result:

```text
decision: no_support
summary:
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  primary_v2_orderwise_terms_result_summary.md
```

The frozen v2 order-wise normalized stopping-set bundle was directionally
positive but did not pass the primary 1 percent log-loss improvement gate:

```text
B1_degree test log loss:                         0.5158353988587047
B1_degree + orderwise normalized terms loss:     0.5125517028275622
relative improvement:                            0.0063657826477354264
bootstrap positive rate:                         0.9925
```

The hazard guardrail remained positive, but the rank-dependency guardrail did
not meet the clean-support bootstrap threshold. This no-support result limits
the current predictive claim for the v2 order-wise stopping-set coordinate on
the frozen finite BEC peeling-decoder surface. It is not evidence against the
exact decoder-specific stopping-set / peeling accounting anchor.
