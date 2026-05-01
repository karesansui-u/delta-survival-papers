Evidence Status Dashboard
=========================

status: evidence_index_snapshot

date: 2026-05-01 JST

This dashboard is a reader-facing index over the current evidence ledgers. It
does not create new evidence and does not change any support / no-support /
invalid-run decision.

Primary source ledgers:

```text
03_domains/registry.tsv
05_evidence/frozen_packages.tsv
05_evidence/no_support.tsv
05_evidence/outside_reruns.tsv
05_evidence/cross_domain_failure_lessons.md
```


1. Current Strongest Specification-Fixed Supports
-------------------------------------------------

| domain | package | status | scope |
|---|---|---|---|
| finite CSP | Mixed-SAT / NAE-SAT primary | supported; outside rerun anchor | finite Bernoulli-CSP style package; drift-weighted coordinate beats raw-count baseline |
| finite CSP | q-coloring Exp43c | supported; outside rerun anchor | threshold-local q-coloring package; first-moment coordinate beats raw / density / encoding-size baselines |
| graph robustness | A31 matched residual v1 | supported successor | finite synthetic graphs; current `log_tau` residual ordering value under matched graph groups |
| s-t reliability | A12 v0b kappa=2 | supported | finite synthetic s-t cut-spectrum reliability; kappa=2-only surface |
| s-t reliability | A12 v0c kappa=3 | supported | finite synthetic s-t cut-spectrum reliability; kappa=3-only surface |
| coding channel | A06/A19 primary v0 | supported | finite BEC sparse parity-check surface; low-order dependency pressure improves natural coding baseline |


2. Inference-Layer And Observational Anchors
--------------------------------------------

| domain | package | status | scope |
|---|---|---|---|
| Backblaze drive reliability | Q3 2025 v2 loss-only | same-domain observational support | fresh untouched archive; calibration-aware loss-only readout passed frozen same-domain rule |
| LLM reasoning | companion package | observational anchor | inference-layer reasoning degradation; not theorem-side evidence |
| continual learning | companion package | observational anchor | dependency-aware repair indicators improve selected readouts; not a general continual-learning law |
| software contract coherence | operational field / bounded benchmark layer | internal operational support | contract-coherence diagnostics; not direct software-collapse evidence |


3. Proposed Diagnostic Plans, Not Evidence
------------------------------------------

These records are design notes or future-package sketches. They do not change
support status.

| domain | plan | status | scope |
|---|---|---|---|
| LLM reasoning | structural-blind persistence | proposed_future_package | future endpoint for blind continuation vs calibrated stop under matched visible resources |


4. Exact Anchors And Coverage Bridges
-------------------------------------

These are useful anchors, but they should not be read as incremental
prediction support unless a separate frozen prediction package passes.

| domain | anchor | status | boundary |
|---|---|---|---|
| finite CSP first-moment collapse | pre-fixed \(L_n^{\mathrm{FM}}\) bounds non-emptiness | theorem-side operational anchor | one-sided Markov / first-moment bound; not a sharp threshold or empirical support |
| A31 graph spanning-tree persistence | \(V(G)=\) spanning trees, \(m(V)=\tau(G)\) | exact specification-fixed accounting anchor | primary_v0 prediction support failed; matched residual v1 is the supported successor |
| A06/A19 coding-channel recovery | rank-based BEC unique recovery accounting | exact specification-fixed accounting anchor plus supported v0 predictor | support is finite-surface v0 only; not arbitrary-code or Shannon-capacity support |
| A06-stop stopping-set recovery | exact BEC peeling failure / residual core anchor | exact decoder-specific anchor; v2 prediction no-support | not A06/A19 rank support and not arbitrary decoder support |
| Foster-Lyapunov / queueing | \(b_t\) as drift / service-arrival balance | existing-theory connection attribute | formal bridge, not a new positive-recurrence theorem |
| non-CSP classical anchors | serial reliability, constant-fraction decay, repair-maintenance balance | coverage / existing-theory connection attribute | does not close the non-CSP empirical gate |


5. No-Support And Invalid-Run Records
-------------------------------------

| package | status | what failed | what remains |
|---|---|---|---|
| M-flow final candidate v0 | no_support | optional M-profile did not beat calibration-best policy-prior baseline | secondary signal over total-resource baseline only |
| A31 primary v0 | no_support | spanning-tree bundle improved only 0.0588 percent, below 1 percent gate | exact spanning-tree accounting anchor remains; matched residual v1 later supported |
| A12 primary v0 | invalid_run | kappa=3 graph-generation surface infeasible under frozen cap | not evidence against cut-spectrum coordinate; v0b/v0c were separately frozen |
| A06/A19 v1 rate-0.625 cw4 | invalid_run | exact even column weight made full row-rank parity-check generation impossible | not evidence against dependency pressure |
| A06/A19 v1b rate-0.625 cw3 | no_support | directionally positive, 0.8524 percent improvement below 1 percent gate | v0 support remains; extrapolation to this surface is blocked |
| A06-stop v2 order-wise terms | no_support | directionally positive, 0.6366 percent below 1 percent gate; rankdep guardrail did not cleanly pass | exact peeling anchor remains; successor must separate rank and stopping-set structure |
| Backblaze Q4 2025 v1 | no_support | ranking signal did not pass frozen log-loss support rule | v2 fresh archive support does not erase this record |
| Cardinality-SAT Exp44 history | no_support_or_draft_history | informative window / calibration readiness failed | remains proposed stress extension, not validation evidence |


6. Governance Reading
---------------------

Use the following interpretation rules when citing these records.

1. `supported` means the pre-fixed primary rule passed on the frozen surface.
2. `observational_support` is lower than specification-fixed primary support.
3. `observational_anchor` is useful but not a primary validation claim.
4. `no_support` means the frozen support rule failed; it does not erase exact
   accounting anchors or other separately supported packages.
5. `invalid_run` means the prediction rule was not evaluated because the
   frozen generation / algebraic surface failed.
6. `exact anchor` means the specification-fixed accounting object is well
   defined; it is not automatically a predictive win.
7. A successor run must use a new manifest and must not relabel failed rows.


7. Current Evidence Shape
-------------------------

The current program has three strong pillars:

1. finite CSP / q-coloring specification-fixed support with outside reruns;
2. finite graph and coding-channel specification-fixed support beyond CSP;
3. explicit no-support / invalid-run records that constrain overclaiming.

The main open gaps are:

1. broader independent reruns for A12 / A31 / A06/A19-style non-CSP
   specification-fixed packages;
2. stronger real-domain support beyond same-domain observational Backblaze v2;
3. cleaner M-side validation where a resource-side readout beats strong
   policy-prior or domain baselines;
4. successor designs that separate known absorbers, such as rank dependency vs
   stopping-set pressure.
5. a frozen LLM structural-blind persistence package, if the proposed
   blind-continuation endpoint remains meaningful after existing-row audit.
