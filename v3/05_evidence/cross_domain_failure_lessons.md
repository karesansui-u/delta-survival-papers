Cross-Domain Failure Lessons
============================

status: methodological_lesson_memo

date: 2026-05-01 JST

This memo records lessons from failed, invalid, or below-gate validation
attempts across the v3 evidence ledger. It is not validation evidence and does
not change any support / no-support / invalid-run decision.

The purpose is to make failures reusable: a failed package should narrow the
next design, not be silently forgotten or reinterpreted as support.


1. Source Packages
------------------

Primary sources:

```text
05_evidence/no_support.tsv
05_evidence/frozen_packages.tsv

05_evidence/a31_graph_spanning_tree_persistence/
  primary_result_summary.md

05_evidence/a12_st_cut_spectrum_reliability/
  primary_v0_invalid_run_summary.md

05_evidence/a06_a19_coding_channel_recovery/
  primary_v1_rate625_cw4_invalid_run_summary.md
  primary_v1b_rate625_cw3_result_summary.md

05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  primary_v2_orderwise_terms_result_summary.md

05_evidence/cross_domain_design_lessons_from_a06_stop.md

04_operations/54_failure_ledger.md

analysis/m_flow_network_testbed/primary_runs/final_candidate_v0/
  primary_result_summary.md

02_foundations/21_balance_details.md
v2/補論_構造持続の収支原理の詳細展開.md
v2/補論_有限CSPにおける構造持続の予測力.md
```


1.1 Policy Anchor
-----------------

This memo applies the failure-ledger discipline in
`04_operations/54_failure_ledger.md`: failed tests are preserved, not renamed
into support or tuned on the same archive.

The existing failure policy distinguishes:

- no-support;
- weak-axis failure;
- mapping failure;
- leakage risk;
- insufficient observability;
- silence.

The present memo also uses `invalid_run` for packages where the frozen
generation or algebraic surface failed before an outcome-bearing support rule
could be evaluated.


2. Failure Ledger
-----------------

| package | result | main lesson |
|---|---|---|
| A31 graph spanning-tree primary v0 | no_support | Exact global redundancy anchors do not automatically predict short-horizon local collapse. |
| A12 cut-spectrum primary v0 | invalid_run | A frozen generation surface can be infeasible before the coordinate is tested. |
| A06/A19 rate-0.625 column-weight-4 | invalid_run | Algebraic feasibility must be checked before freezing a generator. |
| A06/A19 rate-0.625 column-weight-3 | no_support | Directionally positive, below-gate successors should limit extrapolation without erasing earlier support. |
| A06-stop v2 order-wise terms | no_support | Decoder-specific signal can be directionally positive but absorbed by rank-dependency guardrails. |
| M-flow final candidate v0 | no_support | Beating a weak total-resource baseline is not enough if a stronger policy-prior baseline wins. |
| Backblaze Q4 2025 v1 | no_support | Ranking signal is not the same as frozen log-loss / calibration support. |
| Cardinality-SAT Exp44 history | no_support_or_draft_history | Clean solver/verifier/runtime paths do not make a surface validation-ready if the informative window is not stable. |


3. Invalid Run Is Not No-Support
--------------------------------

A12 v0 and A06/A19 v1 rate-0.625 column-weight-4 failed before any
support-bearing prediction comparison.

For A12 v0, the frozen two-cluster graph generator completed the
\(\kappa=2\) cell, then failed to produce enough eligible
\(\kappa=3\) graphs under the frozen attempt cap. This was a generation-surface
failure, not evidence against the low-order cut-spectrum coordinate.

For A06/A19 v1 rate-0.625 column-weight-4, the exact even column weight forced
every parity-check column into the even-parity subspace of
\(\mathbb F_2^r\). A full row-rank parity-check matrix was therefore impossible
under the frozen generator.

Reusable rule:

> Before freezing an outcome-bearing run, check structural feasibility of every
> cell without looking at labels. Algebraic impossibility and generator
> acceptance failure should be caught as preflight failures, not discovered
> after a frozen primary command starts.


4. Exact Anchor Is Not The Same As Prediction Support
-----------------------------------------------------

A31 v0 had a clean specification-fixed anchor:

\[
V(G)=\{\text{spanning trees of }G\},\quad m(V)=\tau(G),
\]

with collapse boundary \(\tau(G)=0\) iff the graph is disconnected.

The no-support result did not attack that anchor. It showed that the chosen
prediction endpoint, short-horizon future disconnection under edge deletion,
was better aligned with local cutsets, bridges, and min-cut proximity than with
the global spanning-tree mass bundle.

Reusable rule:

> A coordinate can be an excellent exact accounting anchor and still be the
> wrong primary predictor for a particular endpoint. Match the endpoint to the
> structural quantity before freezing support claims.


5. Strong Baselines Define The Claim
------------------------------------

The M-flow final candidate improved over a total-resource tie baseline, but it
did not beat the calibration-best policy-prior baseline. The correct decision
was no M-primary support.

This is useful because it proves the evaluator is not arranged to make the new
coordinate win whenever any weak comparator loses.

Reusable rule:

> Weak-baseline improvement is diagnostic. Support requires improvement over
> the strongest pre-fixed domain baseline appropriate to the claim.


6. Directional Positive Is Not Support
--------------------------------------

Several packages were directionally positive but failed the frozen support
gate:

- A31 v0 improved by 0.0588 percent, below the 1 percent gate.
- A06/A19 v1b improved by 0.8524 percent, below the 1 percent gate.
- A06-stop v2 improved by 0.6366 percent, below the 1 percent gate.

These results are not zero-signal results, but they are also not support. They
should be recorded as directional-positive no-support and used to design
successor surfaces.

Reusable rule:

> Keep three labels separate: positive direction, support-gate pass, and clean
> guardrail pass. A positive direction below a frozen gate is design
> information, not validation evidence.


7. Guardrail Absorption Is A Result
-----------------------------------

A06-stop v2 tested a decoder-specific stopping-set coordinate for BEC peeling
failure. The primary direction was positive, and the hazard guardrail remained
positive, but the rank-dependency guardrail did not pass the clean-support
bootstrap threshold.

This does not mean the stopping-set coordinate is useless. It means that, on
that frozen surface, much of the stopping-set signal overlaps with
rank-dependency structure.

Reusable rule:

> If a guardrail absorbs the gain, record what absorbed it. That absorption
> tells the next design what must be separated by construction.


8. Calibration Success Is Not Validation Evidence
-------------------------------------------------

Cardinality-SAT / Exp44 is recorded as calibration history rather than
validation support. The solver, verifier, and runtime path can be clean while
the surface remains not freeze-ready because the informative threshold window
is unstable or too narrow.

Backblaze v1 similarly showed high ranking signal but did not pass the frozen
log-loss support rule. Backblaze v2 later passed on a fresh untouched archive
with a separately frozen calibration-aware design, but that does not erase the
v1 no-support result.

Reusable rule:

> Calibration can choose windows, check power, and expose design problems. It
> cannot become validation evidence unless a new frozen primary package is
> assembled before outcome-bearing execution.

Stress extensions are especially prone to this failure mode. Cardinality-SAT
and exactly-one SAT are mathematically attractive because they create stronger
drift contrasts, but they also introduce saturation, encoding-size confounds,
and solver-representation dependence. This is why the current record treats
Cardinality-SAT as a proposed stress extension behind a review / calibration
gate, not as validation evidence.

Reusable rule:

> A stress extension can be theoretically useful and still be empirically
> unready. If the informative window is not stable, stop at calibration history
> and open a fresh preregistration before any primary claim.


9. Successor Runs Must Be New Packages
--------------------------------------

A12 v0 was invalid, then A12 v0b and v0c succeeded on separately frozen
\(\kappa=2\)-only and \(\kappa=3\)-only surfaces. A06/A19 v0 support was
followed by v1 invalid-run and v1b no-support on a different rate / column
weight surface.

Both examples are healthy. They preserve the old result and test a new claim.

Reusable rule:

> A successor package may be motivated by a failure, but it must not relabel
> failed rows. New surface, new manifest, new seeds / commands, and new
> decision rule come before the next support-bearing execution.


10. Failure Preflight Checklist
-------------------------------

Before freezing the next package, answer these questions explicitly.

1. Structural condition:
   What is the maintained condition \(G\), and does changing it require a new
   package?

2. Exact anchor:
   Which part is accounting / theorem-side, and which part is prediction?

3. Endpoint fit:
   Does the endpoint depend on the coordinate being tested, or on a different
   local / global / decoder-specific structure?

4. Feasibility:
   Can every frozen cell generate enough valid instances before labels are
   produced?

5. Algebra:
   Are there parity, rank, degree, conservation, or topology constraints that
   make a frozen surface impossible?

6. Baselines:
   What is the strongest domain baseline the claim must beat? Which weaker
   baselines are diagnostic only?

7. Guardrails:
   Which plausible absorbers must be tested: size, density, hazard, rank,
   degree, resource total, policy-prior, or calibration-best model?

8. Gates:
   What counts as support, no-support, caveated support, invalid-run, and
   directional-positive no-support?

9. Failure category:
   If the run fails, is it no-support, weak-axis failure, mapping failure,
   leakage risk, insufficient observability, silence, or invalid-run?

10. Calibration boundary:
   Which rows are calibration / smoke only, and how is promotion to evidence
   prevented?

11. Interpretation:
   If the run fails, what exactly is blocked, and what exact anchor or prior
   supported surface remains untouched?


11. Most Transferable Lessons
-----------------------------

The most reusable lessons across domains are:

1. Do not confuse a hard exact anchor with a predictive win.
2. Do not freeze a generator before checking structural feasibility.
3. Do not count improvement over a weak baseline as support when a stronger
   baseline is natural.
4. Do not erase failed attempts with later successful redesigns.
5. Do not treat calibration, smoke, ranking, or directional positivity as
   validation evidence.
6. Do preserve no-support results because they often identify the next
   confound to separate.
7. Do route stress extensions through calibration gates before treating them as
   primary validation candidates.

These lessons apply directly to future specification-fixed domains, and more
strongly still to structurally inferred domains where \(V\), \(m\), and the
readout map are less directly observable.
