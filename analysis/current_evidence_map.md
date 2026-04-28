# Current Evidence Map

Status: after Exp43c q-coloring primary validation, G4 v2 repair-maintenance
integration, Backblaze loss-only primary completion, the first C-MAPSS FD001
cross-domain loss-only primary, Scania horizon-bridge no-support, and the
completed three-run Mixed-CSP true outside-group rerun set.

This note is a compact map of what each artifact currently supports. It is not
a new claim source; it is a navigation layer for the papers, Lean modules, and
preregistered experiments.

## 1. Core Theory Layer

| Layer | Artifact | Current strength | Supports | Does not support |
|---|---|---|---|---|
| Loss-only minimal form | Paper 1 / Paper 2 | Main theoretical core | Log-ratio / exponential representation under fixed structure and measure | Universal applicability without pre-fixed \(V,m\) |
| Structural Persistence Balance Principle | `v2/3_構造持続の収支原理.md` | Central theory layer | \(b_t=d_t-r_t\), \(B_n=\sum b_t\), collapse / maintenance / recovery regimes | Universal-law declaration |
| Set-valued signed kernel | `v2/補論_構造持続の集合値力学的表現と符号付き指数核.md` | Formal supplement | Loss and repair as signed exponential action | Empirical validation |
| M operationalization | `v2/補論_構造持続における資源項Mの操作的定式化.md` | Operational mapping layer | How to measure or decompose support-side resources | Universal resource metric |
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
| Mixed-CSP | Primary validated; requested outside-group rerun set complete | `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525; three returned outside-group reruns completed cleanly with `12000` rows each, `0` checked core mismatches, and all support flags true | Drift-weighted coordinate beats raw count on mixed SAT/NAE feasibility; the frozen package is now confirmed executable outside the project environment in three returned runs, including plain Windows runs | Still within Bernoulli-CSP family; this closes the requested Mixed-CSP rerun set but not Exp43c or non-CSP replication |
| Mixed-CSP true outside-group rerun final | `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md` | Three returned outside-group reruns: `3/3` completed, `3/3` clean success, `0` pending | Records a returned WSL/Ubuntu run by `katsumasa1234`, a Windows 11 Home run by `SCRAPRO`, and a Windows 11 Home 25H2 run by `philia_channel`, each with `12000` primary rows, `0` checked core mismatches, and reproduced support flags | Final G7 layer for Mixed-CSP only; not Exp43c replication and not full-program replication closure |
| Exp43c q-coloring | Primary validated | `fm_plus_n` log loss 0.440189 < best primary raw baseline 2.804019; H1 direction passed for q=3/4/5 | SAT-looking syntax is not the only Route A surface; first-moment coordinate transfers across q | Not a q-coloring threshold theorem |
| Exp44 Cardinality-SAT | Exploration / calibration no-go | Infrastructure clean, but informative-band gate failed | Useful calibration history for threshold-local protocol | Not validation evidence |

## 4. Route C Observational Anchors

| Anchor | Phase | Supports | Boundary |
|---|---|---|---|
| Exp40 scope-as-repair | Preregistered primary support | Structure-aware coding beats quality-blind contradiction coding | Does not identify internal mechanism |
| Exp42 attribution-as-repair | Preregistered decomposition | Source attribution carries much of the repair signal | Model-internal causal mechanism not proven |
| Exp41 width | Preregistered width check | `scoped > structural` replicated across primary models | `subtle` / `structural` ordering is model-dependent |
| Route C companion II dependency-aware repair | Observational / designed comparison | External DAG replay and adapter separation expose different recovery modes | Not a universal continual-learning theorem |

## 5. G4 Non-CSP Anchors

| Anchor | Status | Role | Boundary |
|---|---|---|---|
| Queueing / Foster-Lyapunov | G4 v1 primary + G6-c bridge | Strongest non-CSP algebraic correspondence | Does not reprove positive recurrence |
| Serial reliability | G4 v1 loss-only control | Multiplicative survival / exponential kernel outside CSP | No recovery amount |
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
| Battery M-profile branch | `analysis/g4_battery_m_profile/` | Design / exact web-feasibility / parser-smoke / freeze-draft layer only | Opens a non-software physical-degradation branch for testing whether frozen battery M/SP features add predictive value over strong battery-domain baselines; Oxford Path Dependent Parts 1-3 are recorded as a positive feasibility target with small-sample risk; Part 1 guide/readme + EIS smoke, `Group_2.zip` smoke, complete Part 1 identity, bounded per-zip `.mat` smoke, and no-metric RPT / diagnostic structure counts have now passed; Part 1 satisfies T1-T5 plus T6 public-metadata availability, the conservative split falls back to held-out cell ID because repeated filename cell IDs occur across groups, an Oxford Part 1 freeze-manifest draft exists, metadata-only passes, raw train-smoke is currently blocked by MATLAB MCOS table payloads without post-split held-out payload access, and a no-peek MATLAB / MCOS conversion plan, converter draft, execution runner, Python `--converted-train-root` interface, training-feature smoke runner, and synthetic guardrail/contract tests exist | Not frozen, not validation evidence, not intervention-ranking evidence; earlier bounded parser-smoke reads are schema-only grandfathered, so this is not an untouched-test-archive claim |

## 6. Open Gates

| Gate | Current status | Next clean move |
|---|---|---|
| G3 Route A width | Strengthened by Mixed-CSP + Exp43c | Independent replication, or optional Exp44b redesign under threshold-local protocol |
| G4 non-CSP | G4 v1/v2 minimal skeletons closed; repair-flow public dataset search no longer looks empty but still lacks a clean primary; Backblaze loss-only branch contains one closed no-support attempt and one same-domain support pass; C-MAPSS FD001 now has a frozen cross-domain loss-only primary with a weakening outcome (`H1/H3 pass`, `H2 fail`); queueing / Foster-Lyapunov now has an explicit conditional law-side bridge memo; repair-flow now has an acquisition brief, a send-ready request packet, and a stochastic bridge note; the public Scania route has progressed through feasibility, exact acquisition, freeze design, prereg/freeze, validation-smoke, and a frozen primary no-support result, with the earlier bridge-package draft now kept only as a historical design layer; battery M-profile now has a design-plus-feasibility branch, complete Oxford Part 1 identity, a no-metric T1-T5 count pass plus T6 public-metadata availability, a freeze-manifest draft, metadata-only pass, a raw train-smoke MCOS-table block, a no-peek conversion plan plus converter draft, a MATLAB execution runner, a Python converted-train manifest/header validation path, a training-feature smoke runner, and synthetic guardrail/contract tests | Keep both Backblaze outcomes and the C-MAPSS weakening outcome visible without rescue language. The main open gap remains a directly logged empirical \(r_t\), stronger cross-domain non-CSP support, and any attempt to widen the law-side bridge beyond the current restricted class. The current public-work path now includes `analysis/g4_v2_repair_flow_acquisition_brief.md` for gate definition, `analysis/g4_v2_repair_flow_request_packet.md` for partner/local outreach, `analysis/g4_v2_stochastic_repair_bridge_note.md` for theorem-side escalation, `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md` for public-web triage, `analysis/g4_scania_component_x_archive_feasibility_note.md` for exact public bridge feasibility, `analysis/g4_scania_component_x_large_readout_acquisition_note.md` for full readout hashes and counts, `analysis/g4_scania_component_x_freeze_design_note.md` for label grammar and primary-path choice, `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md` for the operational bridge prereg, `analysis/g4_scania_component_x_horizon_bridge/freeze_manifest_draft.md` for the frozen package record, `analysis/g4_scania_component_x_horizon_bridge/primary_report.md` for the closed public bridge no-support outcome, and `analysis/g4_battery_m_profile/` for the battery physical-degradation design branch plus Oxford Path Dependent web-feasibility / parser-smoke / freeze-draft layer, all explicitly below a completed repair-flow empirical bridge |
| G5 prospective prediction | Supported by Exp40/41/42, Mixed-CSP, Exp43c | Another preregistered external-domain test |
| G6 existing-theory mapping | G6-c iteration 1 closed | Optional iteration 2: positive recurrence / geometric ergodicity |
| G7 independent replication | Mixed-CSP requested outside-group set complete, broader G7 still open. Mixed-CSP has Level 1 audit replay, Level 2 local fresh rerun, an external handoff note, a pre-published fresh-clone rehearsal, a published-remote outside-workspace rerun, a sender-side send runbook, a final true outside-group handoff checklist, and a final outside-group report with `3/3` returned and `3/3` clean success. Exp43c now has a completed local fresh rerun, an external handoff note, a published-remote outside-workspace rerun, a final true outside-group handoff checklist, and a locked sender-side zip packet / return-template layer | Public replication package starts with Mixed-CSP via `analysis/g7_mixed_csp_replication_package_plan.md`; `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`, `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md` record the three returned outside-group successes, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md` records the final requested-set state: `3/3 completed`, `3/3 clean success`, `0 pending`. Earlier layers remain recorded in `mixed_csp_audit_replay_note.md`, `mixed_csp_level2_rerun_note.md`, `mixed_csp_external_rerun_package.md`, `mixed_csp_outside_workspace_rerun_note.md`, `mixed_csp_published_remote_rerun_note.md`, `mixed_csp_true_outside_handoff_checklist.md`, and `mixed_csp_true_outside_send_runbook.md`. Exp43c now has a matching local rerun at `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`, an outside handoff boundary at `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`, a published-remote outside-workspace rerun at `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`, a final handoff checklist at `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`, send-ready materials at `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`, `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`, and `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`, plus locked bundle metadata at `analysis/exp43_qcoloring/handoff_exports/LOCKED_BUNDLE_NOTE.md`. The next clean move is to send the Exp43c outside-group zip packet and keep Mixed-CSP final wording scoped to that package |

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
successes and no requested Mixed-CSP reruns pending. On the non-CSP side it now
has one same-domain
observational loss-only pass (Backblaze v2), one cross-domain loss-only
weakening outcome (C-MAPSS FD001), and one public stochastic-reliability bridge
no-support result (Scania), while repair-flow empirical support remains open.
The program remains a stronger universal-law candidate than before, but it is
not yet a universal law.
