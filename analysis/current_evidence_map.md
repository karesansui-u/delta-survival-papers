# Current Evidence Map

Status: after Exp43c q-coloring primary validation, G4 v2 repair-maintenance
integration, Backblaze loss-only primary completion, and the first C-MAPSS
FD001 cross-domain loss-only primary.

This note is a compact map of what each artifact currently supports. It is not
a new claim source; it is a navigation layer for the papers, Lean modules, and
preregistered experiments.

## 1. Core Theory Layer

| Layer | Artifact | Current strength | Supports | Does not support |
|---|---|---|---|---|
| Loss-only minimal form | Paper 1 / Paper 2 | Main theoretical core | Log-ratio / exponential representation under fixed structure and measure | Universal applicability without pre-fixed \(V,m\) |
| Structural balance law | `v2/3_構造持続の収支法則と崩壊傾向.md` | Central theory layer | \(a_t=\ell_t-g_t\), \(A_n=\sum a_t\), collapse / maintenance / recovery regimes | Universal-law declaration |
| Set-valued signed kernel | `v2/補論_構造持続の集合値力学的表現と符号付き指数核.md` | Formal supplement | Loss and repair as signed exponential action | Empirical validation |
| M operationalization | `v2/補論_構造持続における資源項Mの操作的定式化.md` | Operational mapping layer | How to measure or decompose support-side resources | Universal resource metric |
| Conditional law-side bridge | `analysis/non_csp_conditional_law_side_bridge.md` + `analysis/law_side_upgrade_gate.md` | Interpretation / bridge layer | Restricted non-CSP classes can be described as conditional law-side embeddings when \(m\), \(g_t\), and boundary conditions are all available | Non-CSP universal-law declaration |

## 2. Lean Formal Spine

| Gate | Artifact | Current strength | Supports | Deferred |
|---|---|---|---|---|
| M1 tendency | Existing Survival Lean theorems | Expectation-level mapping | Tendency-law schema under explicit hypotheses | Unconditional high-probability collapse |
| G6-c iteration 1 | `LyapunovBalanceEmbedding.lean` | Minimal algebraic embedding | \(A_n=Z_n-Z_0\), \(R_{t+1}=R_t e^{-a_t}\), queueing wrapper | Positive recurrence / geometric ergodicity theorem |
| G4 v2 iteration 1 | `RepairMaintenanceBalance.lean` | Minimal algebraic skeleton | \(D_n=D_0+\sum(d_t-g_t)\), margin, threshold crossing, repair dominance over damage-only | Optimal maintenance theorem, stochastic failure law |
| Bernoulli-CSP layer | `BernoulliCSP*`, `QColoring*`, `CardinalitySAT*` | Finite-horizon Route A formal interface | Bad-event exposure, MGF/Chernoff wrappers, family-level interfaces | Full threshold theorem or solver dynamics |

## 3. Route A Empirical Anchors

| Anchor | Phase | Result | Supports | Boundary |
|---|---|---|---|---|
| Mixed-CSP | Primary validated | `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525 | Drift-weighted coordinate beats raw count on mixed SAT/NAE feasibility | Still within Bernoulli-CSP family |
| Exp43c q-coloring | Primary validated | `fm_plus_n` log loss 0.440189 < best primary raw baseline 2.804019; H1 direction passed for q=3/4/5 | SAT-looking syntax is not the only Route A surface; first-moment coordinate transfers across q | Not a q-coloring threshold theorem |
| Exp44 Cardinality-SAT | Exploration / calibration no-go | Infrastructure clean, but informative-band gate failed | Useful calibration history for threshold-local protocol | Not validation evidence |

## 4. Route C Observational Anchors

| Anchor | Phase | Supports | Boundary |
|---|---|---|---|
| Exp40 scope-as-repair | Preregistered primary support | Structure-aware coding beats quality-blind contradiction coding | Does not identify internal mechanism |
| Exp42 attribution-as-repair | Preregistered decomposition | Source attribution carries much of the repair signal | Model-internal causal mechanism not proven |
| Exp41 width | Preregistered width check | `scoped > structural` replicated across primary models | `subtle` / `structural` ordering is model-dependent |
| Route C companion II dependency-aware repair | Observational / designed comparison | External DAG replay and adapter separation expose different compensation modes | Not a universal continual-learning theorem |

## 5. G4 Non-CSP Anchors

| Anchor | Status | Role | Boundary |
|---|---|---|---|
| Queueing / Foster-Lyapunov | G4 v1 primary + G6-c bridge | Strongest non-CSP algebraic correspondence | Does not reprove positive recurrence |
| Serial reliability | G4 v1 loss-only control | Multiplicative survival / exponential kernel outside CSP | No repair flow |
| Constant-fraction decay | G4 v1 loss-only control | Exponential decay sanity anchor | No open-system compensation |
| Repair / maintenance balance | G4 v2 open-system anchor | Explicit non-CSP \(g_t\) as repair / maintenance flow | No optimal maintenance or stochastic reliability theorem |
| Repair-flow acquisition brief | `analysis/g4_v2_repair_flow_acquisition_brief.md` | Practical acquisition layer | What to request from private / partner / local data owners before freeze | Not a ranked dataset choice or validation result |
| Stochastic repair bridge note | `analysis/g4_v2_stochastic_repair_bridge_note.md` | Reader-facing theorem-side half-step | How repair / maintenance could move from finite-prefix identity toward stopping / hitting bridge language | Not yet a completed stochastic reliability theorem |
| Backblaze drive stats | G4 loss-only observational branch: v1 no-support, v2 support | Under frozen Q4 2025 v1 package, primary SMART model had high AUC (0.902456) but failed preregistered log-loss support (`1.779176` vs best baseline `0.157102`) and failed H2 due `smart_199_raw` sign. Under frozen Q3 2025 v2 package, the calibration-aware primary passed: calibrated log loss `0.007936` < best baseline `0.008801` (9.83% improvement), H2 passed on the five core SMART fields, and stage-1 AUC `0.882895` > best baseline `0.739014` | Same-domain second attempt only; not repair-flow evidence; does not erase the Q4 no-support result |
| C-MAPSS FD001 degradation | G4 cross-domain loss-only primary: weakening outcome | Under the frozen FD001 package, the low-dimensional `D_pc1` primary beat the best simple baseline (`0.241353` < `0.494974`, H1 pass, 51.24% improvement) and kept directional consistency (`beta_Dpc1 = 3.475025`, H3 pass), but it failed the wide-sensor compression guardrail because `B4` remained stronger (`0.182180`) | Simulated benchmark only; not repair-flow evidence; not full cross-domain primary support |

## 6. Open Gates

| Gate | Current status | Next clean move |
|---|---|---|
| G3 Route A width | Strengthened by Mixed-CSP + Exp43c | Independent replication, or optional Exp44b redesign under threshold-local protocol |
| G4 non-CSP | G4 v1/v2 minimal skeletons closed; repair-flow public dataset search paused; Backblaze loss-only branch contains one closed no-support attempt and one same-domain support pass; C-MAPSS FD001 now has a frozen cross-domain loss-only primary with a weakening outcome (`H1/H3 pass`, `H2 fail`); queueing / Foster-Lyapunov now has an explicit conditional law-side bridge memo; repair-flow now has both an acquisition brief and a stochastic bridge note as the next near-bridge escalation path | Keep both Backblaze outcomes and the C-MAPSS weakening outcome visible without rescue language. The main open gap remains a directly logged empirical \(g_t\), stronger cross-domain non-CSP support, and any attempt to widen the law-side bridge beyond the current restricted class. The current public-work path now includes `analysis/g4_v2_repair_flow_acquisition_brief.md` for data-side escalation and `analysis/g4_v2_stochastic_repair_bridge_note.md` for theorem-side escalation, both explicitly below a completed repair-flow empirical bridge |
| G5 prospective prediction | Supported by Exp40/41/42, Mixed-CSP, Exp43c | Another preregistered external-domain test |
| G6 existing-theory mapping | G6-c iteration 1 closed | Optional iteration 2: positive recurrence / geometric ergodicity |
| G7 independent replication | Open, but Mixed-CSP now has Level 1 audit replay, Level 2 local fresh rerun, an external handoff note, a pre-published fresh-clone rehearsal, a published-remote outside-workspace rerun, and a final true outside-group handoff checklist; Exp43c now has a completed local fresh rerun, an external handoff note, a published-remote outside-workspace rerun, and a final true outside-group handoff checklist | Public replication package starts with Mixed-CSP via `analysis/g7_mixed_csp_replication_package_plan.md`; `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md` records Level 1 artifact replay, `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md` records the separate-output fresh rerun, `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md` records the external handoff boundary, `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md` records the earlier fresh-clone rehearsal, `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md` records a rerun from a fresh clone of the published remote at commit `96de727`, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md` records the final outside-group checklist. Exp43c now has a matching local rerun at `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`, an outside handoff boundary at `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`, a published-remote outside-workspace rerun at `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`, and a final handoff checklist at `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`. The next clean move is now the actual outside-group send order summarized in `analysis/g7_true_outside_handoff_overview.md` |

## 7. Stress-Test / Falsification Layer

| Artifact | Role | Current status | Boundary |
|---|---|---|---|
| `analysis/falsification_and_rival_frameworks.md` + `analysis/ldp_rate_function_comparison.md` + `analysis/cross_domain_sign_convention_table.md` + `analysis/scope_silence_catalog.md` | Records how the program could still be overturned or weakened after several anchors succeed, especially by rival-framework subsumption, hidden sign inconsistency, or scope overreach into systems where the language should stay silent | Working stress-test layer | Not evidence for the theory |

Main stress-test routes:

- translation / sign inconsistency across anchors;
- translation that preserves notation but not nontrivial prediction or theorem
  content;
- scope overreach into systems where scalar loss-repair balance should be
  silent;
- subsumption by rival frameworks such as large deviation theory, free-energy
  / stochastic-thermodynamic frameworks, contraction analysis, or Lyapunov
  drift calculus;
- practical redundancy, where the language is correct but less useful than
  domain-native theories.

The most urgent theoretical risk is rival-framework subsumption, especially by
large-deviation / rate-function machinery on the Route A side. The current
defensive package is therefore: falsification memo -> LDP comparison note ->
cross-domain sign-convention table.

## 8. One-Line Current Position

The program has a stable structural-balance core, Lean-backed algebraic
embeddings, two validated Route A empirical anchors beyond the SAT-only core,
and disciplined Route C observational support. On the non-CSP side it now has
one same-domain observational loss-only pass (Backblaze v2) and one
cross-domain loss-only weakening outcome (C-MAPSS FD001), while repair-flow
empirical support remains open. The program remains a stronger universal-law
candidate than before, but it is not yet a universal law.
