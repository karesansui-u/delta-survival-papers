Evidence Status Dashboard
=========================

status: reader_facing_evidence_index

date: 2026-05-18 JST

This dashboard is a reader-facing index over the current evidence ledgers. It
does not create new evidence, rescue failed runs, or change any support /
no-support / invalid-run decision.

The goal is simple: an external reviewer should be able to see, in one pass,
what is formally closed, what is empirically supported, what failed, what was
invalid, and what is only an engineering application.

Primary source ledgers:

```text
03_domains/registry.tsv
05_evidence/frozen_packages.tsv
05_evidence/no_support.tsv
05_evidence/outside_reruns.tsv
05_evidence/field_demonstrations.tsv
05_evidence/cross_domain_failure_lessons.md
05_evidence/nat_readout_audit.md
```


1. Reading Rules
----------------

Use the following status labels consistently.

| status | meaning | do not read as |
|---|---|---|
| formal_closed | theorem / identity / algebraic bridge is closed under stated assumptions | empirical support or universal law |
| supported | pre-fixed primary rule passed on the frozen surface | support outside that frozen scope |
| outside_rerun_success | independent rerunners reproduced the qualitative decision | proof that the whole program is replicated |
| no_support | frozen support rule failed | evidence that exact accounting anchors are meaningless |
| invalid_run | frozen prediction rule was not evaluated because the generation / algebraic surface failed | no-support |
| observational_support | lower-strength real-domain support under a frozen observational rule | specification-fixed theorem-side support |
| observational_anchor | useful empirical anchor | primary validation |
| field_demonstration | engineering / field use survived a practical workflow | frozen theory support |
| engineering_application | implementation confirms an architecture or control path | predictive support for the theory |
| candidate_or_silence | proposed, exploratory, or currently silent | evidence |

Engineering applications, including LLM input qualification and Hermes-style
memory qualification, are not counted as theory support unless a frozen support
rule, baseline, and holdout surface are declared before evaluation.


2. Formal And Existing-Theory Bridges
-------------------------------------

These rows describe what is closed by definitions, finite identities, Lean
theorems, or explicit bridges to existing theory. They are not empirical wins by
themselves.

| artifact / claim | layer | status | evidence | limitation |
|---|---|---|---|---|
| log-ratio uniqueness | formal core | formal_closed | `LogUniqueness` / Cauchy-style uniqueness route | fixes the allowed scale; does not prove any domain mapping |
| telescoping exponential kernel | formal core | formal_closed | finite-prefix log-ratio identity under fixed \(V,m\) | identity, not empirical exponential decay law |
| balance principle \(b_t=d_t-r_t\), \(B_n=\sum b_t\) | formal core | formal_closed | `StructuralPersistenceBalancePrinciple` wrapper over finite trajectory identities | pathwise accounting; no universal collapse theorem |
| repair / maintenance balance | non-CSP bridge | formal_closed | `RepairMaintenanceBalance` finite-prefix skeleton | not an optimal maintenance theorem |
| finite path ratio / local detailed balance bridge | existing-theory bridge | formal_closed | finite path-ratio / local-detailed-balance residual modules | not a physical fluctuation theorem |
| Foster-Lyapunov / queueing drift | existing-theory bridge | formal_closed as algebraic compatibility | `LyapunovBalanceEmbedding`, `FosterLyapunovSignBridge` | algebraic compatibility, not theorem-transfer; original Markov / irreducibility / petite-set / moment assumptions remain |
| stationary current / housekeeping guardrails | existing-theory bridge | formal_closed | finite-state stationary-current and housekeeping bridge modules | separates current / housekeeping terms from net structural change |

Reviewer note: the Foster-Lyapunov row should be read as "the notation and
sign convention are compatible with existing drift calculus", not as "the paper
re-proves positive recurrence or geometric ergodicity".


3. Current Strongest Specification-Fixed Supports
-------------------------------------------------

| domain | package | status | scope / result |
|---|---|---|---|
| finite CSP | Mixed-SAT / NAE-SAT primary | supported; outside rerun anchor | finite Bernoulli-CSP style package; drift-weighted coordinate beats raw-count baseline |
| finite CSP | q-coloring Exp43c | supported; outside rerun anchor | threshold-local q-coloring package; first-moment coordinate beats raw / density / encoding-size baselines |
| graph robustness | A31 matched residual v1 | supported successor | finite synthetic graphs; `log_tau` residual ordering value under matched graph groups |
| s-t reliability | A12 v0b kappa=2 | supported | finite synthetic s-t cut-spectrum reliability; kappa=2-only surface |
| s-t reliability | A12 v0c kappa=3 | supported | finite synthetic s-t cut-spectrum reliability; kappa=3-only surface |
| coding channel | A06/A19 primary v0 | supported | finite BEC sparse parity-check surface; low-order dependency pressure improves natural coding baseline |


4. Outside Reruns
-----------------

| package | status | result | boundary |
|---|---|---|---|
| Mixed-CSP primary | outside_rerun_success | 3/3 outside reruns reproduced the qualitative support decision | one frozen finite-CSP package, not whole-program replication |
| Exp43c q-coloring | outside_rerun_success | 3/3 outside reruns reproduced the qualitative support decision | one frozen q-coloring package, not arbitrary graph/CSP support |


5. No-Support And Invalid-Run Records
-------------------------------------

These records are not hidden or re-labeled. A successor run may support a new
claim, but it does not reverse the original failed decision.

| package | status | what failed | what remains |
|---|---|---|---|
| M-flow final candidate v0 | no_support | optional M-profile did not beat calibration-best policy-prior baseline | secondary signal over total-resource baseline only |
| A31 primary v0 | no_support | spanning-tree bundle improved only 0.0588 percent, below 1 percent gate | exact spanning-tree accounting anchor remains; matched residual v1 later supported as a separate claim |
| A12 primary v0 | invalid_run | kappa=3 graph-generation surface infeasible under frozen cap | not evidence against cut-spectrum coordinate; v0b/v0c were separately frozen |
| A06/A19 v1 rate-0.625 cw4 | invalid_run | exact even column weight made full row-rank parity-check generation impossible | not evidence against dependency pressure |
| A06/A19 v1b rate-0.625 cw3 | no_support | directionally positive, 0.8524 percent improvement below 1 percent gate | v0 support remains; extrapolation to this surface is blocked |
| A06-stop v2 order-wise terms | no_support | directionally positive, 0.6366 percent below 1 percent gate; rankdep guardrail did not cleanly pass | exact peeling anchor remains; successor must separate rank and stopping-set structure |
| Backblaze Q4 2025 v1 | no_support | ranking signal did not pass frozen log-loss support rule | v2 fresh archive support does not erase this record |
| Cardinality-SAT Exp44 history | no_support_or_draft_history | informative window / calibration readiness failed | proposed stress extension, not validation evidence |


6. Observational And Engineering Layers
---------------------------------------

These rows are useful, but their claim strength is lower than specification-fixed
primary support.

| domain | package | status | scope | boundary |
|---|---|---|---|---|
| Backblaze drive reliability | Q3 2025 v2 loss-only | observational_support | fresh untouched archive; calibration-aware loss-only readout passed frozen same-domain rule | same-domain observational support; not recovery evidence and not a replacement for Q4 v1 no-support |
| LLM reasoning | companion package | observational_anchor | inference-layer reasoning degradation | not theorem-side evidence |
| continual learning | companion package | observational_anchor | dependency-aware repair indicators improve selected readouts | not a general continual-learning law |
| software contract coherence | DeltaLint field demonstration | field_demonstration | public OSS PR / issue workflow with maintainer outcomes | not raw precision / recall, not direct software-collapse prediction |
| LLM input qualification / MemoryGit-style control | private fixture / implementation checks | engineering_application | route-state, permission, snapshot, and selected-readout controls | architecture evidence, not theory validation |
| Hermes-style memory qualification | private integration / design path | engineering_application | input qualification and promotion-gate memory control | product design evidence, not frozen theory support |


7. Exact Anchors And Coverage Bridges
-------------------------------------

These are useful anchors, but they should not be read as incremental prediction
support unless a separate frozen prediction package passes.

| domain | anchor | status | boundary |
|---|---|---|---|
| finite CSP first-moment collapse | pre-fixed \(L_n^{\mathrm{FM}}\) bounds non-emptiness | theorem-side operational anchor | one-sided Markov / first-moment bound; not a sharp threshold or empirical support |
| A31 graph spanning-tree persistence | \(V(G)=\) spanning trees, \(m(V)=\tau(G)\) | exact specification-fixed accounting anchor | primary_v0 prediction support failed; matched residual v1 is the supported successor |
| A06/A19 coding-channel recovery | rank-based BEC unique recovery accounting | exact specification-fixed accounting anchor plus supported v0 predictor | support is finite-surface v0 only; not arbitrary-code or Shannon-capacity support |
| A06-stop stopping-set recovery | exact BEC peeling failure / residual core anchor | exact decoder-specific anchor; v2 prediction no-support | not A06/A19 rank support and not arbitrary decoder support |
| Foster-Lyapunov / queueing | \(b_t\) as drift / service-arrival balance | existing-theory algebraic compatibility | not a new positive-recurrence theorem |
| non-CSP classical anchors | serial reliability, constant-fraction decay, repair-maintenance balance | coverage / existing-theory connection attribute | does not close the non-CSP empirical gate |


8. Current Evidence Shape
-------------------------

The current program has four strong pillars:

1. a formal accounting core with log-ratio, finite-prefix, and balance
   identities closed under stated assumptions;
2. finite CSP / q-coloring specification-fixed support with outside reruns;
3. finite graph, s-t reliability, and coding-channel specification-fixed support
   beyond the original CSP family;
4. explicit no-support / invalid-run records that constrain overclaiming.

The main open gaps are:

1. broader independent reruns for A12 / A31 / A06/A19-style non-CSP
   specification-fixed packages;
2. stronger real-domain support beyond same-domain observational Backblaze v2;
3. cleaner M-side validation where a resource-side readout beats strong
   policy-prior or domain baselines;
4. prospective tests that separate engineering applications from theory support;
5. a compact reviewer packet that links each public claim to the exact frozen
   package, formal theorem, no-support record, or engineering-only artifact.
