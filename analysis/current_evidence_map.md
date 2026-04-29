# Current Evidence Map

Status: after Exp43c q-coloring primary validation, G4 v2 repair-maintenance
integration, Backblaze loss-only primary completion, the first C-MAPSS FD001
cross-domain loss-only primary, Scania horizon-bridge no-support, Oxford Part
1 battery M-profile no-support, the controlled M-flow network primary
no-support result, and completed three-run true outside-group rerun sets for
both Mixed-CSP and Exp43c q-coloring.

This note is a compact map of what each artifact currently supports. It is not
a new claim source; it is a navigation layer for the papers, Lean modules, and
preregistered experiments.

## 1. Core Theory Layer

| Layer | Artifact | Current strength | Supports | Does not support |
|---|---|---|---|---|
| Minimal structural kernel | Paper 1 + conditional-derivation supplement | Main theoretical core plus technical support | Log-ratio / exponential representation under fixed structure and measure | Universal applicability without pre-fixed \(V,m\) |
| Structural Persistence Balance | `v2/2_構造持続の収支原理.md` | Central theory layer | \(b_t=d_t-r_t\), \(B_n=\sum b_t\), collapse / maintenance / recovery regimes | Universal-law declaration |
| Set-valued signed kernel | `v2/補論_構造持続の集合値力学的表現と符号付き指数核.md` | Formal supplement | Loss and repair as signed exponential action | Empirical validation |
| M operationalization | `v2/補論_構造持続における資源項Mの操作的定式化.md` | Operational mapping layer | How to measure or decompose support-side resources | Universal resource metric |
| Proxy ecosystem protocol | `analysis/proxy_ecosystem_protocol.md` | Future empirical-governance design | How candidate proxies are discovered, frozen, upgraded, superseded, and recorded under public or controlled-access validation | Not evidence; does not upgrade existing mappings |
| Conditional law-side bridge | `analysis/non_csp_conditional_law_side_bridge.md` + `analysis/law_side_upgrade_gate.md` | Interpretation / bridge layer | Restricted non-CSP classes can be described as conditional law-side embeddings when \(m\), \(r_t\), and boundary conditions are all available | Non-CSP universal-law declaration |

## 2. Lean Formal Spine

| Gate | Artifact | Current strength | Supports | Deferred |
|---|---|---|---|---|
| M1 tendency | Existing Survival Lean theorems | Expectation-level mapping | Tendency-law schema under explicit hypotheses | Unconditional high-probability collapse |
| G6-c iteration 1 | `LyapunovBalanceEmbedding.lean` | Minimal algebraic embedding | \(B_n=Z_n-Z_0\), \(R_{t+1}=R_t e^{-b_t}\), queueing wrapper | Positive recurrence / geometric ergodicity theorem |
| G4 v2 iteration 1 | `RepairMaintenanceBalance.lean` | Minimal algebraic skeleton | \(D_n=D_0+\sum(d_t-r_t)\), margin, threshold crossing, repair dominance over damage-only | Optimal maintenance theorem, stochastic failure law |
| Bernoulli-CSP layer | `BernoulliCSP*`, `QColoring*`, `CardinalitySAT*` | Finite-horizon Route A formal interface | Bad-event exposure, MGF/Chernoff wrappers, family-level interfaces | Full threshold theorem or solver dynamics |

## 3. Route A Empirical Anchors

| Anchor | Phase | Result | Supports | Boundary |
|---|---|---|---|---|
| Mixed-CSP | Primary validated; requested outside-group rerun set complete | `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525; three returned outside-group reruns completed cleanly with `12000` rows each, `0` checked core mismatches, and all support flags true | Drift-weighted coordinate beats raw count on mixed SAT/NAE feasibility; the frozen package is now confirmed executable outside the project environment in three returned runs, including plain Windows runs | Still within Bernoulli-CSP family; this closes the requested Mixed-CSP rerun set but not non-CSP or observational replication |
| Mixed-CSP true outside-group rerun final | `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md` | Three returned outside-group reruns: `3/3` completed, `3/3` clean success, `0` pending | Records a returned WSL/Ubuntu run by `katsumasa1234`, a Windows 11 Home run by `SCRAPRO`, and a Windows 11 Home 25H2 run by `philia_channel`, each with `12000` primary rows, `0` checked core mismatches, and reproduced support flags | Final G7 layer for Mixed-CSP only; Exp43c is tracked separately and this does not close full-program replication |
| Exp43c q-coloring | Primary validated; three true outside-group rerun successes | `fm_plus_n` log loss 0.440189 < best primary raw baseline 2.804019; H1 direction passed for q=3/4/5; three returned outside-group reruns by `philia_channel`, `katsumasa1234`, and `SCRAPRO` each completed `4000` rows with `0` checked core mismatches, `TIMEOUT = 0`, `MALFORMED = 0`, and the same qualitative support decision; final package report at `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md` | SAT-looking syntax is not the only Route A surface; first-moment coordinate transfers across q; the frozen q-coloring package is now confirmed executable outside the project environment in three returned runs | Not a q-coloring threshold theorem; three Exp43c outside returns strengthen package-level G7 but do not close non-CSP or observational replication |
| Exp44 Cardinality-SAT | Exploration / calibration no-go | Infrastructure clean, but informative-band gate failed | Useful calibration history for threshold-local protocol | Not validation evidence |
| Exp44b Cardinality-SAT | Calibration-v1 no-go | Calibration-v1 completed `4800/4800` rows across `96` cells with `0` timeouts and `0` malformed rows, but closeout returned `calibration_no_go` because `M3_threeway_low` failed the monotonicity gate; row audit shows the failure was a small local reversal (`0.63 -> 0.66` pooled SAT rate) | Useful calibration history for heterogeneous cardinality constraints and for designing a future noise-aware gate | Not frozen, no primary data, not validation evidence; no primary should be generated from this v1 design |

## 4. Route C Observational Anchors

| Anchor | Phase | Supports | Boundary |
|---|---|---|---|
| Exp40 scope-as-repair | Preregistered primary support | Structure-aware coding beats quality-blind contradiction coding | Does not identify internal mechanism |
| Exp42 attribution-as-repair | Preregistered decomposition | Source attribution carries much of the repair signal | Model-internal causal mechanism not proven |
| Exp41 width | Preregistered width check | `scoped > structural` replicated across primary models | `subtle` / `structural` ordering is model-dependent |
| Route C companion II dependency-aware repair | Observational / designed comparison | External DAG replay and adapter separation expose different recovery modes | Not a universal continual-learning theorem |
| Software contract-coherence diagnostics | Field demonstration + internal calibration | Public OSS field demonstration with the DeltaLint implementation records 16 merged PRs across 12 repositories after human selection, reproduction, patching, and maintainer review. The 2026-04-29 Product-arm calibration records five frozen OSS items: Formbricks +0, Flask +1, httpx +2, Chi +4, Traefik +2; four of five items show positive Product-additive gain, with nine credited Product-additive `valid_structural` roots under the same-scope/additive rule | Not direct software-collapse evidence, not M-supplement validation, not raw precision / recall, and not outside replication of the bounded benchmark; OSS merge outcomes are field demonstration / maintainer-acceptance evidence and are affected by selection, patchability, PR strategy, and project culture |

## 5. G4 Non-CSP Anchors

| Anchor | Status | Role | Boundary |
|---|---|---|---|
| Queueing / Foster-Lyapunov | G4 v1 primary + G6-c bridge | Strongest non-CSP algebraic correspondence | Does not reprove positive recurrence |
| Serial reliability | G4 v1 loss-only control | Multiplicative survival / exponential kernel outside CSP | No explicit recovery amount |
| Constant-fraction decay | G4 v1 loss-only control | Exponential decay sanity anchor | No open-system recovery |
| Repair / maintenance balance | G4 v2 open-system anchor | Explicit non-CSP \(r_t\) as repair / maintenance flow | No optimal maintenance or stochastic reliability theorem |
| Repair-flow acquisition brief | `analysis/g4_v2_repair_flow_acquisition_brief.md` | Practical acquisition layer | What to request from private / partner / local data owners before freeze | Not a ranked dataset choice or validation result |
| Repair-flow request packet | `analysis/g4_v2_repair_flow_request_packet.md` | Send-ready acquisition layer | Converts the acquisition brief into a partner / local-owner request packet that asks first for schema, counts, and field names rather than raw rows | Not a dataset freeze, not a ranking result, and not evidence |
| Stochastic repair bridge note | `analysis/g4_v2_stochastic_repair_bridge_note.md` | Reader-facing theorem-side half-step | How repair / maintenance could move from finite-prefix identity toward stopping / hitting bridge language | Not yet a completed stochastic reliability theorem |
| Public repair-flow rescan (2026-04-27) | `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md` | Public-data triage layer | Scania Component X is the strongest current public stochastic reliability bridge candidate; Azure PdM remains leakage-risk unless a direct repair-class rule can be frozen; MetroPT-3 remains weak-g; HSE filter looks closer to maintenance-boundary / censored reliability than to a direct repair-flow primary | Not a freeze, not a validation result, not proof that a clean public repair-flow primary already exists |
| Scania Component X exact feasibility | `analysis/g4_scania_component_x_archive_feasibility_note.md` | Exact public bridge-feasibility layer | Pins version 3 / DOI `10.5878/bnh5-ka77`, confirms the 11-file public manifest, and keeps Scania at public stochastic reliability bridge candidate rather than repair-flow primary | Not a frozen bridge package and not direct \(r_t\) evidence |
| Scania large readout exact acquisition | `analysis/g4_scania_component_x_large_readout_acquisition_note.md` | Exact public archive-identity layer | Closes exact local acquisition of the three large operational-readout CSV files with bytes, sha256, row counts, and repeated-unit counts | Does not freeze label grammar, primary path, or model/metric design |
| Scania freeze design note | `analysis/g4_scania_component_x_freeze_design_note.md` | Public bridge pre-freeze layer | Locks the held-out five-class label grammar and chooses horizon-classification as the operational primary path while retaining survival/TTE as the conceptual secondary path | Does not yet freeze feature family, model, or metric implementation |
| Scania horizon-bridge prereg draft | `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md` | Public bridge preregistration layer | Freezes the censored-as-class-0 training-label rule, baseline ladder, `D_pc1` compressed primary family, and multiclass log-loss evaluation goal | Not yet a frozen script or executed package |
| Scania horizon-bridge freeze manifest draft | `analysis/g4_scania_component_x_horizon_bridge/freeze_manifest_draft.md` | Public bridge frozen package layer | Records the exact file identities, held-out class grammar, operational primary path, frozen script SHA, and one-time primary command | Frozen package; not validation evidence by itself |
| Scania horizon-bridge validation smoke | `analysis/g4_scania_component_x_horizon_bridge/validation_smoke_note.md` | Public bridge pre-freeze execution layer | Confirms that the Scania execution script exists, metadata-only identity passes, and validation-smoke fits `B1/B2/B3/primary` without recording validation metrics or test-label distribution | Pre-freeze execution evidence only; not held-out validation evidence |
| Scania horizon-bridge primary report | `analysis/g4_scania_component_x_horizon_bridge/primary_report.md` | Public bridge primary outcome | The first frozen Scania horizon-classification package failed H1, passed H2, and therefore produced a no-support result under the preregistered bridge rule | Not repair-flow evidence; not same-archive rescue target |
| Scania bridge package draft | `analysis/g4_scania_component_x_bridge_package_draft.md` | Historical public bridge-design layer | Captures the pre-freeze framing that positioned Scania as a public stochastic reliability / TTE bridge with horizon-classification as the operational primary path | Superseded by the frozen manifest, validation-smoke note, and primary report |
| Backblaze drive stats | G4 loss-only observational branch: v1 no-support, v2 support | Under frozen Q4 2025 v1 package, primary SMART model had high AUC (0.902456) but failed preregistered log-loss support (`1.779176` vs best baseline `0.157102`) and failed H2 due `smart_199_raw` sign. Under frozen Q3 2025 v2 package, the calibration-aware primary passed: calibrated log loss `0.007936` < best baseline `0.008801` (9.83% improvement), H2 passed on the five core SMART fields, and stage-1 AUC `0.882895` > best baseline `0.739014` | Same-domain second attempt only; not repair-flow evidence; does not erase the Q4 no-support result |
| C-MAPSS FD001 degradation | G4 cross-domain loss-only primary: weakening outcome | Under the frozen FD001 package, the low-dimensional `D_pc1` primary beat the best simple baseline (`0.241353` < `0.494974`, H1 pass, 51.24% improvement) and kept directional consistency (`beta_Dpc1 = 3.475025`, H3 pass), but it failed the wide-sensor compression guardrail because `B4` remained stronger (`0.182180`) | Simulated benchmark only; not repair-flow evidence; not full cross-domain primary support |
| Battery M-profile branch | `analysis/g4_battery_m_profile/` | Public battery primary no-support outcome + weak-axis audit | Oxford Path Dependent Part 1 progressed through exact identity, no-metric structure counts, MATLAB training conversion (`168` records), converted-smoke, header-only schema draft, `transition_aggregate_v1` training-feature smoke (`149` transition rows), and then a one-time held-out primary (`74` held-out rows). The frozen M/SP primary did not improve over `B3`: `primary RMSE = 0.23508673118782375` versus `B3 RMSE = 0.2296038662551124`; `H1 = false`, `H2 = false`, `H3 = true`, `primary_support = false` | No-support for this frozen Oxford battery M/SP mapping; additionally warns that the added M/SP axis was too close to ordinary battery state proxies. Not causal intervention-ranking evidence, not repair-flow evidence, not universal-law support, and not a same-archive rescue target |
| M-flow network testbed | `analysis/m_flow_network_testbed/` | Controlled mechanistic M-side primary no-support outcome | The guarded `final_candidate_v0` primary was executed once. In the primary setting, M-profile regret improved over total-resource regret (`0.2204` vs `0.2372`) but did not beat the policy-prior baseline (`0.1506`). Sensitivity settings showed the same qualitative pattern. Frozen-rule result: no M-primary support, with a secondary signal relative to total resource only | Not real-domain support and not a universal M-law. The result shows that simple M allocation carries some information beyond scalar budget in this testbed, but not enough to beat a strong policy-prior intervention baseline |

## 6. Open Gates

| Gate | Current status | Next clean move |
|---|---|---|
| G3 Route A width | Strengthened by Mixed-CSP + Exp43c, with outside-group returns now present for both frozen packages; Exp44b Cardinality-SAT v1 is now closed as calibration no-go | Independent review, or a fresh versioned Cardinality-SAT redesign; no Exp44b v1 primary |
| G4 non-CSP | G4 v1/v2 minimal skeletons closed; repair-flow public dataset search no longer looks empty but still lacks a clean primary; Backblaze loss-only branch contains one closed no-support attempt and one same-domain support pass; C-MAPSS FD001 has a frozen cross-domain loss-only primary with a weakening outcome (`H1/H3 pass`, `H2 fail`); queueing / Foster-Lyapunov has an explicit conditional law-side bridge memo; repair-flow has an acquisition brief, a send-ready request packet, and a stochastic bridge note; Scania is a frozen public bridge no-support result; Oxford Part 1 is now a frozen public battery M-profile no-support result; the M-flow network testbed is now a closed controlled-mechanistic no-support result; `analysis/mapping_attempt_ledger.md` records support, no-support, failed-candidate, weak-axis, and silence statuses in one place | Keep Backblaze, C-MAPSS, Scania, Oxford, and M-flow visible without rescue language. The main open gap remains a directly logged empirical \(r_t\), stronger cross-domain non-CSP support, and any attempt to widen the law-side bridge beyond the current restricted class. The current public-work path includes the repair-flow acquisition/request packet path, the Scania closed no-support bridge, the Oxford closed no-support battery M-profile outcome, the M-flow closed controlled-mechanistic outcome, and the mapping-attempt ledger as the negative-result memory |
| G5 prospective prediction | Supported by Exp40/41/42, Mixed-CSP, Exp43c | Another preregistered external-domain test |
| G6 existing-theory mapping | G6-c iteration 1 closed | Optional iteration 2: positive recurrence / geometric ergodicity |
| G7 independent replication | Route A now has outside-group returns for two frozen packages; broader G7 still open. Mixed-CSP has Level 1 audit replay, Level 2 local fresh rerun, an external handoff note, a pre-published fresh-clone rehearsal, a published-remote outside-workspace rerun, a sender-side send runbook, a final true outside-group handoff checklist, and a final outside-group report with `3/3` returned and `3/3` clean success. Exp43c now has a completed local fresh rerun, an external handoff note, a published-remote outside-workspace rerun, a final true outside-group handoff checklist, a locked sender-side zip packet / return-template layer, and a final outside-group report with `3/3` returned and `3/3` clean success | Public replication package starts with Mixed-CSP via `analysis/g7_mixed_csp_replication_package_plan.md`; `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`, `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md` record the three returned outside-group successes, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md` records the final requested-set state: `3/3 completed`, `3/3 clean success`, `0 pending`. Earlier layers remain recorded in `mixed_csp_audit_replay_note.md`, `mixed_csp_level2_rerun_note.md`, `mixed_csp_external_rerun_package.md`, `mixed_csp_outside_workspace_rerun_note.md`, `mixed_csp_published_remote_rerun_note.md`, `mixed_csp_true_outside_handoff_checklist.md`, and `mixed_csp_true_outside_send_runbook.md`. Exp43c now has a matching local rerun at `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`, an outside handoff boundary at `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`, a published-remote outside-workspace rerun at `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`, a final handoff checklist at `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`, send-ready materials at `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`, `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`, and `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`, locked bundle metadata at `analysis/exp43_qcoloring/handoff_exports/LOCKED_BUNDLE_NOTE.md`, returned run notes at `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`, `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`, and `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`, and final report at `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`. The package-level summary is `analysis/g7_route_a_true_outside_replication_summary.md`; the next clean move is independent review while keeping package-level reports scoped |

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

The program has a stable structural-persistence balance core, Lean-backed algebraic
embeddings, two validated Route A empirical anchors beyond the SAT-only core,
and disciplined Route C observational support. Mixed-CSP now also has a
completed three-run true outside-group rerun layer with three clean returned
successes and Exp43c has three clean returned outside-group reruns. Exp44b
Cardinality-SAT v1 is now calibration no-go, not evidence. On the non-CSP side
it now has one same-domain observational loss-only pass (Backblaze v2), one
cross-domain loss-only weakening outcome (C-MAPSS FD001), one public
stochastic-reliability bridge no-support result (Scania), one public battery
M-profile no-support result (Oxford Part 1), and one controlled-mechanistic
M-flow network no-support result. Repair-flow empirical support remains open.
The mapping-attempt ledger now separates candidate signals, validation
candidates, frozen support, no-support, weak-axis failures, and silence
decisions so that failed attempts constrain future designs instead of
disappearing into scattered notes. The proxy ecosystem protocol records the
future-facing rule that early proxies may be superseded by stronger
measurements, but only through versioned freezing and fresh / sealed /
outside validation rather than retroactive rescue.
The program remains a stronger universal-law candidate than before, but it is
not yet a universal law.
