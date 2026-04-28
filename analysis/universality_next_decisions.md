# Universality Program — Next Decisions

Status: program memo after Exp.41, Mixed-CSP primary, Lean M1, Exp43c
q-coloring primary validation, completed three-run true outside-group rerun
sets for both Mixed-CSP and Exp43c q-coloring, and the admissible-maps /
hierarchical-invariants roadmap plus saturation-defect, exact compatibility,
defect-controlled compatibility, and Bernoulli \(\Sigma\) Lean wrappers.

## 1. Phase Assessment

The program has passed a real phase transition, but not an independent
replication / universal-law victory condition.

The core theory and the LLM scope-as-repair domain are now load-bearing:

- the Paper 1 + conditional-derivation formal core and the signed-kernel / set-valued dynamics layer
  are stable;
- Exp.40 showed that scope-aware coding beats a quality-blind contradiction
  baseline prospectively;
- Exp.42 decomposed the scoped effect and showed that the result is not well
  explained by explicit instruction-following alone;
- row-level Exp.42 analysis specified the main repair mechanism as
  attribution-as-repair;
- Exp.41 confirmed the preregistered `scoped > structural` width claim in
  both primary models, while also showing that `subtle` / `structural`
  ordering is model-dependent.
- the Mixed-CSP primary test showed that drift-weighted `L_plus_n` beats raw
  count + `n` for SAT/NAE feasibility out-of-sample;
- Exp43c q-coloring primary validation showed that frozen threshold-local
  `fm_plus_n` beats raw / density / CNF-size baselines out-of-sample across
  held-out q folds;
- Lean M1 showed that the expectation-level target theorem 4 / law-of-tendency
  schema is already formally accessible through existing theorems and only
  needs reader-facing mapping.
- The admissible-maps / hierarchical-invariants supplement now makes the
  hierarchical-invariants route more precise: iso maps preserve \(B_n\), positive
  gauge changes make \(B_n\) covariant, coarse-graining has a saturation-defect
  identity rather than unconditional DPI, and proxy domains fall to frozen
  validation. The execution roadmap for this route is now
  `analysis/second_law_level_roadmap.md`, with low-risk Lean wrappers in
  `Survival.SecondLawTotalProduction`, `Survival.AdmissibleMapInvariants`,
  `Survival.SaturationDefect`, `Survival.AdmissibleMapCompatibility`,
  `Survival.DefectControlledAdmissibleMap`, and
  `Survival.BernoulliTypicalSigma`. The first Bernoulli admissible-map v0
  wrapper now also lives in `Survival.BernoulliAdmissibleMapV0`; it packages
  endpoint identity, endpoint defect budget, and coarse monotonicity as
  sufficient readout-level conditions for the Phase-4 coarse \(\Sigma\)
  certificates. The Phase-5 ladder and exit criteria are now separated in
  `analysis/phase5_admissible_map_ladder.md`. Phase 6.1 is now staged in
  `analysis/phase6_foster_lyapunov_template.md`, which maps the Bernoulli-CSP
  \(\Sigma\) template to Foster-Lyapunov / queueing anchors without claiming
  recurrence, ergodicity, or an unconditional Lyapunov second law.

The accurate public characterization is:

```text
Core theory is consolidated. LLM scope repair, Route A Mixed-CSP feasibility,
and Route A q-coloring feasibility now have prospective support. The
expectation-level formal tendency schema is mapped to existing Lean theorems,
and the admissible-map / Sigma route toward a hierarchical-invariants
unification is now explicit.
Independent replication has completed three-run outside-group rerun sets for
both Mixed-CSP and Exp43c q-coloring; further heterogeneous
domain extensions remain open.
```

Avoid public wording such as "the theory is proven" or "universality is
established". The stronger claim should wait for independent review /
replication and, if needed, later theorem-wrapper polish.

## 2. Current Status by Track

| Track | Phase | Current state | Next decisive signal |
|---|---|---|---|
| Core theory | Consolidation | Stable theorem vocabulary and Lean anchors | Only wording / mapping refinements |
| LLM domain | Verification | Exp.40 + Exp.42 support scope-as-repair and attribution-as-repair; Exp.41 width passed | Model-dependent failure-mode follow-up only if needed |
| Route A / CSP | Mixed-CSP validated; local fresh rerun, pre-published fresh-clone rehearsal, published-remote outside-workspace rerun, external handoff package completed, and three true outside-group reruns returned cleanly; Exp43c q-coloring primary validated, locally rerun, externally packaged, rerun from the published remote, sender-side zip packet prepared, and three true outside-group reruns returned cleanly; Exp44 calibration inconclusive; Exp44b v1 calibration no-go | Mixed-CSP official primary passed: `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525, and the package has now also been rerun locally from scratch with exact reproduction on the checked core fields (`analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`). An earlier fresh-clone outside-workspace rehearsal at the same frozen code path is recorded in `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md`, the external handoff boundary is recorded in `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`, and a fresh clone of the actually published remote has now also been rerun cleanly at `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`. The three true outside-group returns are recorded in `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`, `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`, and `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`: each has `12000` primary rows, `0` checked core mismatches, all support flags true, and no reported workaround. The final requested-set status is `3/3` completed, `3/3` clean success, `0` pending in `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`. Exp43c q-coloring primary passed under frozen threshold-local package: `fm_plus_n` log loss 0.440189 < best primary raw baseline 2.804019, with H1 direction passing for q=3/4/5 and q=5 narrow. That package has now also been rerun locally from scratch with exact manifest and evaluation matches plus zero checked core-field mismatches (`analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`), has an outside handoff boundary at `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`, has now also been rerun from a fresh clone of the published remote at `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`, has sender-side materials at `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md` and `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`, and now has three returned outside-group successes at `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`, `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`, and `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`, each with `4000` rows, `0` checked core mismatches, `TIMEOUT = 0`, `MALFORMED = 0`, and the same qualitative support decision. The Exp43c final report is `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`, and a two-package summary is recorded at `analysis/g7_route_a_true_outside_replication_summary.md`. Exp44 smoke/pilot_v2/pilot_v3 are infrastructure-clean but pilot_v3 still failed the informative-band gate for M0/M1/M2. Exp44b calibration v1 completed `4800/4800` rows with `0` timeouts and `0` malformed rows, but closeout returned `calibration_no_go` because `M3_threeway_low` failed the monotonicity gate. Exp44b is not frozen, has no primary data, and is not validation evidence | Independent review, fresh versioned Cardinality-SAT redesign if desired, or G4/G6 non-CSP continuation |
| G4 / non-CSP | G4 v1 closed; G4 v2 minimal skeleton implemented and supplement-integrated; Backblaze loss-only observational branch now has one no-support result and one same-domain calibrated support pass; C-MAPSS FD001 now has a frozen cross-domain loss-only weakening outcome; Scania public bridge now has a frozen no-support result | Queueing / Foster-Lyapunov is the primary G4 v1 anchor; serial reliability and constant-fraction decay are loss-only controls. G4 v2 is scoped toward repair / maintenance reliability-fatigue balance, where \(r_t\) is explicit in a non-CSP open-system model. Public repair-flow dataset search found C1 Azure PdM leakage-risk and C2 MetroPT-3 weak-g, so repair-flow primary remains paused. A public-web rescan now clarifies that Scania Component X is the strongest current public stochastic reliability bridge candidate, Azure PdM remains only a leakage-risk re-audit candidate, and the HSE filter dataset looks closer to maintenance-boundary / censored reliability than to a direct repair-flow primary. An exact Scania feasibility note fixed the current public identity at version 3 / DOI `10.5878/bnh5-ka77`, a large-readout exact-acquisition note fixed the three public operational-readout CSV identities, a freeze-design note locked the held-out class grammar and chose horizon-classification as the operational primary path, and the Scania branch then progressed through preregistration draft, frozen manifest, execution script, and no-peek validation smoke before one-time held-out evaluation. The resulting frozen Scania package did not pass H1, did pass H2, and therefore closed as a public stochastic reliability bridge no-support result rather than repair-flow evidence. The private / partner route now also has a send-ready request packet at `analysis/g4_v2_repair_flow_request_packet.md`, so the acquisition path is no longer just a criteria memo. Backblaze Q4 2025 loss-only primary was frozen and run; primary SMART model failed log-loss support (`1.779176` vs best baseline `0.157102`) and H2 sign consistency due `smart_199_raw`. Backblaze Q3 2025 v2 then ran under a separately frozen calibration-aware package and passed: calibrated primary log loss `0.007936` < best baseline `0.008801` (9.83% improvement), H2 passed on the five core SMART fields, and stage-1 AUC `0.882895` > best baseline `0.739014`. This counts only as same-domain observational loss-only support and does not erase the Q4 no-support result. C-MAPSS FD001 then ran under a frozen cross-domain loss-only package and produced the preregistered weakening outcome: primary `D_pc1 + cycle + settings` log loss `0.241353` < best simple baseline `0.494974` (H1 pass, 51.24% improvement) and `beta_Dpc1 = 3.475025` (H3 pass), but wide raw-sensor `B4 = 0.182180` remained stronger, so H2 failed and `primary_support = false`. This does not count as repair-flow evidence or as full cross-domain non-CSP support. The relevant notes now include `analysis/g4_cmapss_loss_only_feasibility_note.md`, `analysis/g4_cmapss_fd001_archive_note.md`, `analysis/g4_cmapss_fd001_archive_feasibility_note.md`, `analysis/g4_cmapss_fd001_loss_only_preregistration_draft.md`, `analysis/g4_cmapss_fd001_loss_only/freeze_manifest_draft.md`, `analysis/g4_cmapss_fd001_loss_only/train_smoke_note.md`, `analysis/g4_cmapss_fd001_loss_only/primary_report.md`, `analysis/g4_v2_repair_flow_candidate_criteria.md`, `analysis/g4_v2_repair_flow_acquisition_brief.md`, `analysis/g4_v2_repair_flow_request_packet.md`, `analysis/g4_v2_stochastic_repair_bridge_note.md`, `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md`, `analysis/g4_scania_component_x_archive_feasibility_note.md`, `analysis/g4_scania_component_x_large_readout_acquisition_note.md`, `analysis/g4_scania_component_x_freeze_design_note.md`, `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md`, `analysis/g4_scania_component_x_horizon_bridge/freeze_manifest_draft.md`, `analysis/g4_scania_component_x_horizon_bridge/validation_smoke_note.md`, `analysis/g4_scania_component_x_horizon_bridge/primary_report.md`, `analysis/g4_scania_component_x_horizon_bridge/scripts/evaluate_scania_component_x_horizon_bridge.py`, and `analysis/g4_scania_component_x_bridge_package_draft.md` | Preserve the Scania no-support result without same-archive rescue language, just as with Backblaze Q4 and C-MAPSS. The remaining non-CSP empirical gap is now best described as repair-flow support plus stronger cross-domain support, not as a reason for retroactive redesign on frozen public runs. Current execution order is recorded in `analysis/open_gates_execution_plan.md` |
| Formal tendency / rival-framework stress test | M1 completed; admissible-map supplement added; Phase 2 wrappers added; saturation-defect, exact compatibility, defect-controlled compatibility, Bernoulli \(\Sigma\) wrappers, Bernoulli admissible-map v0 wrapper, Phase-5 ladder note added, and Phase-6.1 Foster-Lyapunov / queueing template staged; G6-c iteration 1 closed; falsification stress-test layer expanded | Expectation-level target theorem 4 formally accessible via existing theorems; reader-facing wrappers now exist in `Survival.SecondLawTotalProduction`, `Survival.AdmissibleMapInvariants`, `Survival.SaturationDefect`, `Survival.AdmissibleMapCompatibility`, `Survival.DefectControlledAdmissibleMap`, `Survival.BernoulliTypicalSigma`, and `Survival.BernoulliAdmissibleMapV0`. The defect-controlled wrapper closes the readout-level cancellation of contracted-intermediate defects in signed action. The Bernoulli \(\Sigma\) wrapper gives the one-sided iid bad-event \(\Sigma\) observable, adjacent-step nondecrease, expected monotonicity, finite-path interior Chernoff lower-tail certificate, the corresponding good-event lower-bound and fixed-time typical-growth certificates, endpoint-defect coarse-transfer certificates, and collapse/stopped-collapse aliases without claiming an unconditional second law. `Survival.BernoulliAdmissibleMapV0` packages endpoint identity, endpoint defect budget, and coarse monotonicity as sufficient conditions for those coarse certificates; it is not a full admissible-map characterization. `analysis/phase5_admissible_map_ladder.md` records the ladder from exact readout through v0 sufficient readout to set-level and necessary/sufficient open targets, so Phase 5 can be used as a Phase-6 template without overclaiming full closure. `analysis/phase6_foster_lyapunov_template.md` now stages Foster-Lyapunov / queueing as the second limited class template by mapping existing `LyapunovBalanceEmbedding`, `QueueStability`, `ResourceBoundedConditionalAzuma`, `SecondLawTotalProduction`, and `CoarseTypicalNondecrease` anchors into the same \(\Sigma\) / drift / concentration / coarse-transfer grammar. `analysis/second_law_level_roadmap.md` now separates the route into admissible maps, \(\Sigma\) / total production, typical nondecrease, limited-class universality, and eventual cross-class unification. `analysis/falsification_and_rival_frameworks.md` records the main ways the program could still be weakened, especially rival-framework subsumption by LDP / free-energy / contraction-style frameworks. Concrete defenses now include `analysis/ldp_rate_function_comparison.md`, `analysis/cross_domain_sign_convention_table.md`, and `analysis/scope_silence_catalog.md` | If useful, add a thin Foster-Lyapunov template wrapper next; otherwise proceed to Repair-Maintenance as the next class template, while keeping set-level defect-controlled admissible-map instantiation open |
| External reception | Underway, with Route A two-package outside returns | OSF is available; Mixed-CSP and Exp43c now both have local fresh reruns plus published-remote outside-workspace reruns. Mixed-CSP now has three returned true outside-group rerun successes (`analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`, `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`, `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`) and a final report (`analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`) with `3/3` completed, `3/3` clean success, `0` pending. Mixed-CSP also has a sender-side runbook at `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_runbook.md`. Exp43c has a locked sender-side zip packet and return template via `analysis/exp43_qcoloring/handoff_exports/LOCKED_BUNDLE_NOTE.md`, `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`, and `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`, plus three returned true outside-group successes at `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`, `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`, and `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`. The two-package outside-return summary is `analysis/g7_route_a_true_outside_replication_summary.md`. | Independent review |

## 3. Resolved Gates And Next Options

### Gate 1: Mixed-CSP Feasibility Test

Purpose:

```text
Show that drift-weighted L is a better feasibility coordinate than raw count
outside the LLM arithmetic setting.
```

Primary success:

```text
L_plus_n held-out log loss < raw_plus_n held-out log loss
```

Status:

```text
Passed: 0.0970 < 0.7525 on the official 12,000-row primary run.
```

Strong support:

```text
L_plus_n improves held-out log loss by at least 10%
and does not lose to cnf_count_plus_n.
```

Theory-pure support:

```text
first_moment = n log 2 - L beats raw_plus_n.
```

Status:

```text
Passed: first_moment log loss 0.1489 < raw_plus_n 0.7525.
Encoding guardrail also passed: L_plus_n 0.0970 <= cnf_count_plus_n 0.1010.
```

Interpretation:
  Route A gains an empirical universality-class anchor. The claim is still not
  "same coefficient everywhere"; it is that the pre-specified structural loss
  coordinate carries predictive information beyond unweighted baselines.

### Gate 2: Exp.41 Width Check

Purpose:

```text
Show that Exp.40 scoped > structural is not gpt-4.1-mini-specific.
```

Status:

```text
Passed: scoped > structural in both primary new models.
```

Interpretation:
  Route C companion I becomes substantially more defensible as a model-width claim.
  The invariant is scoped protection, not a fixed subtle/structural ordering.

Unexpected secondary finding:
  `gemini-3.1-flash-lite-preview` inverted the preregistered secondary
  `subtle >= structural` direction (`subtle = 0.40`, `structural = 0.47`).
  Row-level inspection shows Gemini took the injected wrong value on 14/18
  subtle failures but on 0/16 structural failures. This does not affect the
  primary decision, because `scoped > structural` passed on both primary
  models, but it should remain recorded as evidence that self-referential
  paradox resistance and alternate-source uptake are model-dependent.

### Gate 3: Formal Target Theorem 4

Purpose:

```text
Upgrade balance-principle language to reusable tendency theorem language.
```

M1 output:

```text
lean/UNIVERSALITY_GAP_MAP.md
```

Status:

```text
Passed at expectation level via M1 mapping.
```

M1 conclusion:

```text
Target theorem 4 is formally accessible at the expectation level through
existing Lean theorems. M2-B thin wrappers have now been added for the
\(\Sigma\) / total-production component and the readout-level Iso/Gauge layer.
```

Interpretation:
  Formal law-strength improves independently of the empirical program. The
  remaining caution is schema separation: high-probability stopped-collapse
  requires explicit concentration / margin assumptions and should not be folded
  into the expectation-level theorem.

## 4. Recommended Next Order

Short horizon:

1. Keep the M1 conclusion and the admissible-map / second-law-level roadmap
   synchronized across the supplement / README / program memo.
2. Keep the \(\Sigma\) / total-production theorem map pointed at
   `Survival.SecondLawTotalProduction`, so readers can see Component 2 is
   already Lean-backed.
3. Treat `Survival.AdmissibleMapInvariants` as the completed low-risk Iso /
   positive-gauge wrapper layer, `Survival.SaturationDefect` as the narrow
   readout-level plus minimal set-level saturation-defect spec, and
   `Survival.DefectControlledAdmissibleMap` as the completed two-stage readout
   cancellation layer. The next Lean-side target is set-level instantiation of
   that defect-controlled algebra, not more wrapper aliases or unconditional
   DPI.
4. Keep M resource operationalization as a supplement-level mapping layer, not
   as the next main-theory paper.
5. Review and polish the structural persistence balance principle / 構造持続の収支原理 draft as the next
   core-theory candidate. §1-8 now exist at
   `v2/2_構造持続の収支原理.md`; current control memo:
   `analysis/structural_persistence_balance_principle_draft_plan.md`.
6. Keep `analysis/falsification_and_rival_frameworks.md`,
   `analysis/ldp_rate_function_comparison.md`, and
   `analysis/cross_domain_sign_convention_table.md` visible as the
   stress-test layer for overclaim, sign inconsistency, silent-system scope,
   and rival-framework subsumption.
7. Keep the new non-CSP law-side framing narrow and explicit:
   `analysis/law_side_upgrade_gate.md` defines when a domain may count as a
   conditional law-side bridge, and
   `analysis/non_csp_conditional_law_side_bridge.md` applies that gate to
   queueing / Foster-Lyapunov, reliability controls, and repair-maintenance.
8. Use `analysis/open_gates_execution_plan.md` to keep the remaining work
   ordered: rival-framework defense -> conditional law-side bridge -> G7
   replication package -> cross-domain non-CSP anchor -> repair-flow data
   acquisition.
9. For the rival-framework layer, the first defensive quartet now exists:
   falsification memo -> LDP note -> sign table -> scope/silence catalog.
10. For G7, Mixed-CSP now has both a completed Level 1 replay note
   (`analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md`) and a
   completed Level 2 local rerun note
   (`analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`).
11. Mixed-CSP also now has a fresh-clone outside-workspace rehearsal note at
   `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md`
   and a published-remote outside-workspace rerun note at
   `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`.
12. The external handoff boundary for Mixed-CSP is now
    `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`.
13. Mixed-CSP now also has a final outside-group handoff checklist at
    `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`.
14. A short coordination note for the send order now exists at
    `analysis/g7_true_outside_handoff_overview.md`, and the sender-side
    runbook now exists at
    `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_runbook.md`.
15. Exp43c now has both a package-plan note, a completed local fresh rerun
    note at `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`, and an
    outside handoff note at
    `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`.
16. Exp43c now also has a published-remote outside-workspace rerun note at
    `analysis/exp43_qcoloring/exp43c_published_remote_rerun_note.md`.
17. Exp43c now also has a final outside-group handoff checklist at
    `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`.
18. Exp43c now also has sender-side true outside-group materials at
    `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`,
    `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`, and
    `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`.
19. Exp43c now also has three returned true outside-group reruns at
    `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`,
    `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`, and
    `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`.
20. Treat q-coloring and Cardinality-SAT as optional Route A width extensions,
   not as required gates.
21. For G4 v2, use `analysis/g4_v2_exploratory_dataset_scan.md` as the immediate
   operational track. The task is to inspect candidate maintenance / repair
   datasets for schema feasibility only. Do not treat this scan as validation,
   and do not generate maintenance-log primary evidence before a dataset, split,
   feature schema, and evaluation script are frozen.
22. For repair-flow escalation, separate the next move into two layers:
    `analysis/g4_v2_repair_flow_acquisition_brief.md` for the practical
    dataset request, and `analysis/g4_v2_stochastic_repair_bridge_note.md`
    for the theorem-side half-step from near-bridge to stochastic bridge
    target.
23. For the current cross-domain non-CSP public branch, treat
    `analysis/g4_cmapss_loss_only_feasibility_note.md` as the candidate logic,
    `analysis/g4_cmapss_fd001_archive_note.md` as the exact-subset choice,
    `analysis/g4_cmapss_fd001_archive_feasibility_note.md` as the exact public
    archive acquisition, `analysis/g4_cmapss_fd001_loss_only_preregistration_draft.md`
    as the prereg path, `analysis/g4_cmapss_fd001_loss_only/freeze_manifest_draft.md`
    as the frozen package, `analysis/g4_cmapss_fd001_loss_only/train_smoke_note.md`
    as the no-peek parser / train-fit check, and
    `analysis/g4_cmapss_fd001_loss_only/primary_report.md` as the weakening
    outcome report. Keep the entire branch explicitly below repair-flow
    evidence and below Route A randomized primaries.

Rationale:

- Mixed-CSP and Exp.41 are now complete and passed.
- Lean M1 is now complete, and the low-risk M2-B wrappers are now implemented.
- The remaining work is no longer a hidden core-definition gate; it is
  saturation-defect specification, structural persistence balance principle
  review / freeze, G4 v2 exploratory dataset scanning, width extension, and
  external replication.

Estimated timelines, assuming no unexpected gates:

| Step | Estimate |
|---|---:|
| M1 propagation to public docs | 30-60 min |
| M2-B wrapper layer | completed |
| Saturation-defect / compatibility Lean spec | readout-level and minimal set-level instantiation implemented; exact compatibility and two-stage defect-cancellation wrappers implemented |
| M operationalization supplement cleanup | 30-60 min |
| Structural Persistence Balance Principle §1-8 review pass | 1 focused session |
| G4 v2 exploratory maintenance-log dataset scan | 1 focused session |
| Optional fresh Cardinality-SAT redesign review | 1 focused session |

Route A extension discipline is recorded separately in
[`route_a_extension_map.md`](route_a_extension_map.md). In short, Mixed-CSP
has now passed; q-coloring and Cardinality-SAT are safe post-Mixed-CSP
extensions, but Cardinality-SAT is currently only Exp44 calibration history
plus an Exp44b v1 calibration no-go. XOR-SAT, LDPC decoder performance, SAT chain v2.0, and bootstrap
percolation should not be promoted as primary Route A empirical anchors.

Exp43 q-coloring is now resolved through the Exp43c fresh threshold-local
successor. The early Exp43 / Exp43b pilots remain exploration history only.
Exp43c passed calibration, was frozen in
`analysis/exp43_qcoloring/exp43c_freeze_package.md`, and then passed primary
validation. Report:
`analysis/exp43_qcoloring/exp43c_primary_report.md`.

Key Exp43c result:

```text
fm_plus_n mean held-out log loss = 0.440189
best preregistered primary raw baseline = 2.804019
relative improvement = 84.3%
TIMEOUT = 0, MALFORMED = 0
```

H1 direction passed for every held-out q fold, but q=5 was narrow. Use this as
Route A width support beyond SAT syntax, not as universal-law proof.

Exp44 Cardinality-SAT now has a draft preregistration and harness at
`analysis/exp44_cardinality_sat/`. It is a draft-only Route A width-extension
design using heterogeneous cardinality constraints. The smoke run passed at
infrastructure level; see `analysis/exp44_cardinality_sat/smoke_summary.md`.
A partial runtime probe found a hard `M0_low, n=120, rho=1.00` cell; see
`analysis/exp44_cardinality_sat/pilot_runtime_probe.md`. Pilot_v2 with
`n={60,100}` completed cleanly but did not pass the informative-band gate; see
`analysis/exp44_cardinality_sat/pilot_v2_summary.md`. Pilot_v3 fine-grid also
completed cleanly but did not pass the informative-band gate for M0/M1/M2; see
`analysis/exp44_cardinality_sat/pilot_v3_summary.md`. No Exp44 primary data
should be generated from the current design.

Exp44b Cardinality-SAT now exists as a fresh threshold-local calibration
attempt at `analysis/exp44b_cardinality_sat/`. Calibration v1 completed
`4800/4800` rows across `96` cells with `0` timeouts and `0` malformed rows,
but the closeout returned `calibration_no_go` because `M3_threeway_low` failed
the monotonicity gate. A row-level audit shows a small local reversal rather
than execution failure, so this is retryable only as a future versioned
redesign with a noise-aware gate. This is not a freeze, not a primary run, and
not validation evidence. No primary should be generated from this Exp44b v1
design.

## 5. Public Wording

Recommended:

```text
The core framework is consolidated. LLM scope repair, model-width replication,
and Mixed-CSP feasibility now support structure-aware coordinates over
quality-blind / raw baselines. Lean M1 maps the expectation-level tendency
schema to existing verified theorems. This supports a Level 2 universality
candidate, while independent replication remains necessary before any universal
law declaration.
```

Avoid:

```text
Universality is established.
The theory is proven.
The remaining work is only examples.
```

## 6. Decision Table

| Result pattern | Interpretation | Next action |
|---|---|---|
| Exp41 passed, Mixed-CSP passed, M1 mapping-only sufficient | Verification phase across LLM + Route A + formal expectation-level tendency | integrate into universality paper / update program status |
| Optional M2-B wrapper added | Reader-facing theorem names improve | cite wrappers in supplement; no new empirical claim |
| Exp43c q-coloring passed | Route A width expands beyond SAT syntax | Route A extension map and finite-CSP supplement updated; keep q=5 narrowness explicit in public wording |
| independent replication arrives | Social proof strengthens | consider stronger universality wording |
