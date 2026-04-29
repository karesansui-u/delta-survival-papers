# Open Gates Execution Plan

Status: active program-execution memo after Backblaze v2 same-domain
observational support, the first C-MAPSS FD001 cross-domain loss-only primary,
Scania horizon-bridge no-support, Oxford Part 1 battery optional M-component no-support,
the controlled M-flow network primary no-support result,
the completed three-run Mixed-CSP true outside-group rerun set, and the
completed three-run q-coloring (Exp43c package) true outside-group rerun set. This is not a freeze
document, not validation evidence,
and not a new claim source.

Purpose:

Turn the remaining open gaps into a small number of explicit workstreams with a
clear execution order. The aim is to avoid two bad failure modes:

1. adding more anchors without closing the main theoretical and empirical
   objections;
2. drifting into endless same-domain refinement while the real gaps stay open.

The four current gaps are:

1. G4 non-CSP repair-flow / maintenance-flow empirical support;
2. cross-domain non-CSP support beyond the Backblaze drive-reliability branch;
3. G7 independent replication beyond the completed Mixed-CSP and Exp43c
   package-level outside rerun sets;
4. rival-framework stress testing, especially LDP / rate-function subsumption.

## 1. Current Starting Position

The program is not starting from zero.

Already closed or strengthened:

- Route A primary anchors: Mixed-CSP and q-coloring (Exp43c package);
- Route C observational anchors: Exp.40 / 41 / 42 and Route C companion II;
- G6-c iteration 1: minimal Foster-Lyapunov algebraic embedding;
- G4 v1 and G4 v2 algebraic non-CSP skeletons;
- Backblaze loss-only branch:
  - Q4 2025 v1 closed no-support;
  - Q3 2025 v2 same-domain calibrated support.

Still open:

- no repair-flow empirical primary;
- no cross-domain non-CSP empirical support beyond drive reliability;
- the requested true outside-group Mixed-CSP rerun set has returned cleanly:
  `3/3` completed, `3/3` clean success, `0` pending;
- the returned q-coloring (Exp43c package) true outside-group rerun set has returned cleanly:
  `3/3` completed, `3/3` clean success, `4000` rows in each returned run,
  `0` checked core mismatches in each returned run, `TIMEOUT = 0`,
  `MALFORMED = 0`, and the same qualitative support decision;
- no completed reader-facing rival-framework comparison.

New information:

- the first frozen cross-domain non-CSP public branch has now run on
  C-MAPSS FD001;
- it produced a weakening outcome, not a support result:
  `H1 = true`, `H2 = false`, `H3 = true`, `primary_support = false`.
- the three returned Mixed-CSP true outside-group reruns completed cleanly:
  each has `12000` primary rows, `0` checked core mismatches, all four support
  flags true, and no reported workaround.
- Exp44b Cardinality-SAT v1 has now completed calibration only:
  `4800/4800` rows across `96` cells, `0` timeouts, and `0` malformed rows.
  Its closeout returned `calibration_no_go` because `M3_threeway_low` failed
  the monotonicity gate. A row-level audit shows this was a small local
  reversal rather than execution failure, but no primary-window selection or
  freeze should be made from this v1 design.
- Oxford Path Dependent Part 1 has now completed its one-time held-out battery
  optional M-component primary and produced a no-support result:
  `primary RMSE = 0.23508673118782375` versus
  `B3 RMSE = 0.2296038662551124`, with `H1 = false`, `H2 = false`,
  `H3 = true`, and `primary_support = false`.
- The controlled M-flow network testbed has now completed its guarded
  final-candidate primary at
  `analysis/m_flow_network_testbed/primary_runs/final_candidate_v0/`.
  The primary setting was `Q=4`, `damage_intensity=0.34`, `T=8`, seed block
  `2000..2029`. The frozen-rule outcome is no optional M-component diagnostic support: the component readout
  improved over total-resource regret (`0.2204` vs `0.2372`) but did not beat
  the policy-prior baseline (`0.1506`). Sensitivity settings retained the same
  qualitative pattern.

## 2. Workstream A — G4 Repair-Flow Empirical Gap

### Current state

The public-dataset search has already produced a meaningful negative result:

- C1 Azure PdM: leakage-risk;
- C2 MetroPT-3: weak-g;
- C3 Backblaze: loss-only only.

This means the current repair-flow gap is not "we have not looked yet". It is:

```text
Public reproducible datasets with repeated units, direct preventive/reactive
repair distinction, and clean future endpoint are scarce.
```

### Implication

Do not keep forcing the public-dataset scan into a pseudo-primary. The clean
branches are now:

1. private / partner / local operational dataset path;
2. loss-only public controls;
3. formal / algebraic G4 v2 progress without empirical overclaim.

### Next artifact

Create a one-page dataset-criteria memo for a repair-flow candidate. It should
state the minimum acceptable fields before any ranking or freeze:

- stable repeated unit;
- cutoff-safe timestamps;
- direct preventive / scheduled repair class, or another repair class defined
  before visible failure;
- future failure / degradation endpoint;
- activity baseline;
- reproducible reporting plan even if raw data are private.

This document should not rank actual datasets. It should define the gate any
future dataset must pass.

That gate now exists at:

- `analysis/g4_v2_repair_flow_candidate_criteria.md`

The next practical move is now narrower:

- `analysis/g4_v2_repair_flow_acquisition_brief.md`

This is the document to hand to a partner, internal data owner, or outside
collaborator before any dataset-specific freeze is even discussed.

That practical move now has a send-ready companion:

- `analysis/g4_v2_repair_flow_request_packet.md`

Use the brief as the gate definition and the request packet as the actual
partner / local-owner outreach artifact.

The public bridge route has also advanced one stage:

- `analysis/g4_scania_component_x_large_readout_acquisition_note.md`

This closed exact local acquisition of the three large readout CSV files and
moved the branch from archive-identity uncertainty into pre-freeze bridge
design.

That freeze-design stage now also has a dedicated note:

- `analysis/g4_scania_component_x_freeze_design_note.md`

This locks the held-out class grammar and chooses horizon-classification as the
operational primary path, leaving survival / TTE as the conceptual secondary
path.

The Scania public bridge route first moved through package-facing drafts:

- `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md`
- `analysis/g4_scania_component_x_horizon_bridge/freeze_manifest_draft.md`

These fixed the censored-as-class-0 rule, the baseline ladder, the compressed
`D_pc1` primary family, and the intended multiclass log-loss evaluation path
before the package was frozen and executed.

That gap is now partly closed by:

- `analysis/g4_scania_component_x_horizon_bridge/scripts/evaluate_scania_component_x_horizon_bridge.py`
- `analysis/g4_scania_component_x_horizon_bridge/validation_smoke_note.md`

The first Scania public bridge script now exists, `--metadata-only` passes,
and `--validation-smoke` passes without recording validation metrics or held-out
test-label distribution. The package was then frozen and evaluated once on the
held-out test surface. The first frozen Scania horizon-classification package
did not pass H1, though it did pass H2 against the wide raw-readout baseline,
so the current route is now a recorded public bridge no-support outcome rather
than an open pre-freeze branch.

There is now also a narrow public-web rescan layer:

- `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md`

Its current conclusion is intentionally limited:

```text
Scania Component X is the strongest public stochastic reliability bridge
candidate; Azure PdM is still only a leakage-risk re-audit candidate; public
web data still does not yet yield a clean repair-flow primary.
```

## 3. Workstream B — Cross-Domain Non-CSP Empirical Support

### Current state

Backblaze v2 is useful, but it is:

- loss-only;
- observational;
- same-domain second attempt.

So it improves G4, but it does not close the heterogeneous-domain non-CSP gap.

C-MAPSS FD001 has now also been run under a frozen loss-only package.

Outcome:

- the compressed `D_pc1` primary beat the simple baselines (`H1 = true`);
- the oriented degradation coefficient stayed directionally coherent
  (`H3 = true`);
- but the compressed coordinate remained weaker than the preregistered wide
  raw-sensor model (`H2 = false`).

So C-MAPSS FD001 is informative, but it is not yet the cross-domain non-CSP
support anchor we would want for closing this gate.

A new battery physical-degradation design branch now exists at:

- `analysis/g4_battery_m_profile/README.md`
- `analysis/g4_battery_m_profile/battery_m_profile_validation_design.md`
- `analysis/g4_battery_m_profile/candidate_dataset_ranking.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_feasibility_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_parser_smoke_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_smallfile_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_group2_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_freeze_design_decision_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_full_archive_identity_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_full_identity_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_part1_rpt_structure_count_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_metadata_train_smoke_note.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_mcos_conversion_plan.md`
- `analysis/g4_battery_m_profile/oxford_path_dependent_mcos_converter_script_note.md`
- `analysis/g4_battery_m_profile/preregistration_draft.md`
- `analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py`
- `analysis/g4_battery_m_profile/scripts/inspect_oxford_rpt_structure.py`
- `analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py`
- `analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m`
- `analysis/g4_battery_m_profile/scripts/run_oxford_part1_primary.sh`
- `analysis/g4_battery_m_profile/scripts/test_oxford_primary_contract.py`
- `analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json`
- `analysis/g4_battery_m_profile/oxford_path_dependent_training_conversion_and_feature_smoke_result_note.md`

This branch is not validation evidence. It is a clean design path for testing
whether frozen battery M/SP features add out-of-sample predictive value over a
strong battery-domain baseline. The first proposed target is Oxford Path
Dependent feasibility, with NASA Randomized/Recommissioned as the second
candidate and MIT-Stanford/TRI as a later strong-baseline challenge.

The Oxford Path Dependent note gives a positive exact web-feasibility status
for Parts 1-3, but keeps the branch below support because the independent cell
count is modest and must be handled with no-leak split rules. The branch has
now moved through small-file acquisition, metadata/parser smoke, full Part 1
identity, bounded `.mat` smoke, and no-metric RPT / diagnostic structure counts
before any freeze.

The first Part 1 smoke acquired `Guide_to_Datafiles.pdf`,
`Guide_to_Datafiles.xlsx`, `Readme.txt`, and `EIS.zip`, recorded hashes, opened
the zip, inspected three `.mat` files, and fixed a pre-freeze parser ambiguity
around repeated file names. The historical next smoke target was one
cycling/profile group archive before any feature extraction.

That target has now passed for Part 1 `Group_2.zip`: the archive was acquired,
hashed, opened as a zip, and three bounded `.mat` files were inspected without
computing features or outcomes. The Oxford freeze-design decision note now also
exists. It keeps Oxford as the first battery candidate but blocks primary
validation until a freeze manifest, train-smoke package, and one-time primary
command are fixed without feature values or model metrics.

The full-archive identity / RPT-parser plan now also exists. It fixes the
acquisition tiers, sets `H_count = 1` reference-test step for parser counts, and
keeps the T1-T6 promotion thresholds pre-fixed before any feature extraction.
Tier A then completed for Part 1: all Part 1 public files were acquired,
hashed, opened where applicable, and checked with bounded per-zip `.mat` smoke.
Part 1 then passed the no-metric RPT / diagnostic structure-count gate: `12`
unique filename cell IDs, `4` retained groups, `223` H1 candidate rows, `12`
safe held-out cell-ID folds, T1-T5 count checks true, and T6 public-metadata
availability true. Because repeated cell IDs occur across groups, the
conservative split falls back from protocol-group holdout to held-out cell ID.
The Oxford Part 1 freeze-manifest draft now also exists. The first execution
scaffold passes metadata-only and blocks raw train-smoke safely on MATLAB MCOS
table payloads without post-split held-out payload access. The MATLAB training
conversion ran locally with MATLAB R2026a trial, producing `168`
training-table records. Python converted-smoke then passed exact expected-entry
and exclusive-CSV checks. Header-only schema draft found no direct capacity
column, so the training-feature smoke used `transition_aggregate_v1`:
`next_capacity_ah = max(Amphr)` at diagnostic index `k + 1`, with features from
diagnostic index `k` aggregates only. Training-feature smoke passed with `149`
transition rows and B0/B1/B2/B3/primary fit success, while still emitting no
held-out values, predictions, metrics, coefficients, or support flags. The
one-time held-out primary then ran on `74` held-out transition rows and closed
as a no-support outcome for this frozen Oxford battery M/SP mapping. Earlier
bounded parser-smoke reads are treated as schema-only grandfathered smoke.

### Recommended direction

The next non-CSP empirical move should not be another Backblaze redesign, and
it should not rescue C-MAPSS FD001 on the same archive. C-MAPSS is already
recorded as a weakening outcome.

The Oxford branch has now closed as:

```text
Oxford Path Dependent one-time held-out primary no-support.
```

Reason:

- distinct physical-degradation domain from drive reliability and turbofan
  simulation;
- repeated units;
- explicit time axis;
- capacity / degradation endpoints are available in principle;
- protocol order and periodicity are central to the dataset design;
- public and reproducible;
- optional M-component features can be frozen before any primary run.

NASA Randomized/Recommissioned remains the second feasibility candidate if we
want another public battery optional M-component attempt.
MIT-Stanford/TRI remains a later hard-baseline challenge.

### Next artifact

The clean next empirical operation is now:

```text
choose between NASA Randomized/Recommissioned battery feasibility or the
repair-flow acquisition path.
```

Do not rescue Oxford on the same archive. Keep Oxford as a no-support battery
optional M-component outcome and keep the current FD001 result as a weakening outcome,
not as a failed theory test and not as a hidden support result. Record the
Oxford lesson in the mapping-attempt ledger: the frozen primary was not only
no-support, but also a weak-axis warning because the added M/SP coordinates
were too close to ordinary battery state proxies. Future battery v2 work should
first define the maintained structure as future service-envelope / operation
path margin, then freeze an independent SP-axis gate before any primary run.

## 4. Workstream C — G7 Independent Replication

### Current state

The program now has real validated anchors, a Mixed-CSP external package, an
q-coloring (Exp43c package) external package, published-remote outside-workspace reruns for both
Route A packages, final handoff checklists for both, a completed three-run
Mixed-CSP outside-group rerun set, and a completed three-run q-coloring (Exp43c package)
outside-group rerun set. What remains open is independent review and
outside-group return depth beyond these package-level successes, not
project-side reproducibility.

### Principle

Do not begin with the hardest or most ambiguous replication target.

Start with the strongest, cleanest, most deterministic package first. The
current recommended order is:

1. Mixed-CSP primary package;
2. q-coloring (Exp43c package) primary package;
3. Backblaze v2 observational package.

Reason:

- Mixed-CSP is already a clean Route A primary with frozen predictors and a
  direct held-out metric;
- Exp43c is stronger on heterogeneous family transfer, but comes with a more
  elaborate threshold-local calibration history;
- Backblaze v2 is observational and same-domain second-attempt, so it should
  not be the first external replication representative.

### Next artifact

The plan and final handoff artifacts now exist, all three requested Mixed-CSP
returns have landed cleanly, and three Exp43c returns have also landed cleanly.
The next clean move is now a scoped post-return flow:

1. keep the Mixed-CSP final report scoped to that package;
2. keep the Exp43c outside-return reports scoped to that package;
3. use `analysis/g7_route_a_true_outside_replication_summary.md` as the
   package-level G7 summary;
4. move to independent review or the next external-facing workstream.

## 5. Workstream D — Rival-Framework Stress Test

### Current state

This is the most urgent theoretical risk, because it can weaken the program
without any new empirical failure.

The current order should be:

1. LDP / rate-function comparison;
2. cross-domain sign-convention table;
3. scope / silence catalog, if further sharpening is needed;
4. optional focused comparison to free-energy or contraction frameworks.

### Why this order

- LDP is the closest immediate challenge on the Route A side because
  first-moment, MGF, Chernoff, and KL language are already central there.
- Sign consistency is the fastest internal coherence test for the
  "unified language or just a glossary?" objection.
- Free-energy and contraction comparisons are real but less urgent until the
  LDP question is framed properly.

### Artifacts

The first two artifacts in this workstream now exist:

- `analysis/ldp_rate_function_comparison.md`
- `analysis/cross_domain_sign_convention_table.md`

## 6. Workstream E — Conditional Law-Side Bridge

### Current state

The program already had most of the raw ingredients for a non-CSP law-side
bridge:

- G6-c minimal Foster-Lyapunov embedding;
- G4 v1 queueing / reliability / decay anchors;
- G4 v2 repair-maintenance skeleton.

What it lacked was a reader-facing gate that says when a non-CSP domain is
allowed to count as more than an analogy.

That gate is now explicit:

- `analysis/law_side_upgrade_gate.md`
- `analysis/non_csp_conditional_law_side_bridge.md`

### Current claim

The safe current claim is:

```text
Non-CSP universality is still open. The strongest current bridge is
queueing / Foster-Lyapunov drift, which already supports a conditional
law-side bridge. Repair / maintenance remains the next near-bridge
open-system escalation path.
```

### Why this matters

This strengthens G4 / G6-c without pretending that Backblaze, C-MAPSS, or
Route C have already become law-side domains.

### Next artifact

If this bridge is later promoted into a paper-facing supplement section, keep
the same three conditions fixed:

1. natural pre-fixed \(m\);
2. observable recovery amount \(r_t\);
3. explicit collapse / hitting boundary under assumptions.

The next theorem-side half-step is now recorded at:

- `analysis/g4_v2_stochastic_repair_bridge_note.md`

This note does not close the stochastic reliability side, but it states the
reader-facing bridge target that would move repair / maintenance from
near-bridge toward a fuller law-side bridge.

## 7. Recommended Execution Order

Near-term order:

1. close the rival-framework layer enough that the program can state how it is
   not merely a relabeling;
2. keep the conditional law-side bridge fixed as the narrow non-CSP
   interpretation ceiling;
3. package one clean G7 replication target;
4. keep Exp44b v1 closed as calibration no-go; any Cardinality-SAT retry must
   be a fresh versioned design, not current validation evidence;
5. advance one cross-domain non-CSP empirical candidate without same-archive
   rescue;
6. only then reopen the harder repair-flow empirical path.

In other words:

```text
theory-defense -> law-side bridge -> replication package -> cross-domain non-CSP -> repair-flow data acquisition
```

This is cleaner than continuing same-domain tuning or adding more defensive
notes without a work order.

## 7. What Not To Do Next

Avoid the following near-term moves:

1. another retroactive Backblaze redesign;
2. treating Backblaze v2 as if it solved repair-flow empirical support;
3. forcing weak public maintenance logs into a primary validation role;
4. opening free-energy / contraction comparisons before the LDP note and sign
   table are in place;
5. starting independent replication with the most complicated observational
   branch.

## 8. Immediate Deliverables Status

The first concrete deliverables from this memo now exist:

1. `analysis/g4_cmapss_loss_only_feasibility_note.md`
2. `analysis/g4_v2_repair_flow_candidate_criteria.md`
3. `analysis/scope_silence_catalog.md`
4. `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md`

So the next concrete moves became:

1. exact C-MAPSS subset / archive note before any loss-only prereg;
2. Mixed-CSP Level 2 fresh rerun under the G7 workstream;
3. `analysis/g7_exp43c_replication_package_plan.md`;
4. future repair-flow data acquisition under the candidate-criteria gate.

Status update:

- item 1 now exists as `analysis/g4_cmapss_fd001_archive_note.md`;
- item 2 is now complete locally in
  `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`;
- item 3 now exists as `analysis/g7_exp43c_replication_package_plan.md`;
- exact archive feasibility now exists as
  `analysis/g4_cmapss_fd001_archive_feasibility_note.md`;
- external Mixed-CSP packaging now exists as
  `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`.
- Mixed-CSP fresh-clone rehearsal now exists as
  `analysis/route_a_mixed_csp/mixed_csp_outside_workspace_rerun_note.md`.
- Exp43c local rerun is now complete in
  `analysis/exp43_qcoloring/exp43c_level2_rerun_note.md`.
- Exp43c external handoff now exists as
  `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`.
- C-MAPSS loss-only prereg draft now exists as
  `analysis/g4_cmapss_fd001_loss_only_preregistration_draft.md`.
- C-MAPSS freeze-manifest draft now exists as
  `analysis/g4_cmapss_fd001_loss_only/freeze_manifest_draft.md`.
- C-MAPSS no-peek train-side smoke now exists as
  `analysis/g4_cmapss_fd001_loss_only/train_smoke_note.md`.
- C-MAPSS frozen primary report now exists as
  `analysis/g4_cmapss_fd001_loss_only/primary_report.md` and records the
  weakening outcome `H1/H3 pass, H2 fail`.
- a public-web repair-flow rescan now exists as
  `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md` and currently
  points to Scania Component X as the strongest public stochastic reliability
  bridge candidate.
- an exact Scania feasibility note now exists as
  `analysis/g4_scania_component_x_archive_feasibility_note.md` and fixes the
  current public identity at version 3 / DOI `10.5878/bnh5-ka77`, while
  keeping the tier below repair-flow primary.
- a Scania bridge-package draft now exists as
  `analysis/g4_scania_component_x_bridge_package_draft.md`, but it is now a
  historical design layer: the live branch has already advanced through
  freeze, validation-smoke, and a frozen primary no-support report under
  `analysis/g4_scania_component_x_horizon_bridge/primary_report.md`.
- the first returned Mixed-CSP true outside-group rerun is now recorded in
  `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`;
- the second returned Mixed-CSP true outside-group rerun is now recorded in
  `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`;
  both returned runs completed `12000` rows with `0` checked core mismatches,
  all support flags true, and no reported workaround.
- the Mixed-CSP true outside-group rerun set now has a final report at
  `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`, with
  status `3/3` completed, `3/3` clean success, `0` pending.
- the Exp43c true outside-group sender-side packet now exists via
  `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`,
  `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`,
  `analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md`, and
  `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`.
- the locked Exp43c distribution bundle metadata now exists at
  `analysis/exp43_qcoloring/handoff_exports/LOCKED_BUNDLE_NOTE.md`.
- three returned Exp43c true outside-group reruns are now recorded in
  `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`,
  `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`,
  and
  `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`;
  each completed `4000` rows with `0` checked core mismatches, `TIMEOUT = 0`,
  `MALFORMED = 0`, and the same qualitative support decision.
- the Exp43c true outside-group rerun set now has a final report at
  `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`.
- the Route A package-level outside-return summary now exists at
  `analysis/g7_route_a_true_outside_replication_summary.md`.
- Exp44b Cardinality-SAT v1 now exists as a completed calibration no-go at
  `analysis/exp44b_cardinality_sat/`. Calibration-v1 completed `4800/4800`
  rows across `96` cells with `0` timeouts and `0` malformed rows, but closeout
  returned `calibration_no_go` because `M3_threeway_low` failed the
  monotonicity gate. This is not a freeze, not a primary run, and not
  validation evidence.

So the next concrete order becomes:

1. keep the two Route A outside-return sets scoped to package-level G7;
2. open a fresh versioned Cardinality-SAT redesign if Route A width is
   reopened; do not run primary from Exp44b v1;
3. keep the M-flow controlled primary as closed no-support unless a future
   versioned redesign is frozen before any new outcomes;
4. choose the next non-CSP empirical branch: NASA Randomized/Recommissioned
   battery feasibility or future repair-flow data acquisition under the
   candidate-criteria gate;
5. keep Oxford Part 1 as a closed no-support battery optional M-component outcome without
   same-archive rescue.

This keeps the program moving on the actual open gaps rather than adding more
same-type evidence to already-strong tracks.

## 9. Non-Claims

This memo does not claim:

1. repair-flow empirical support is impossible;
2. Backblaze v2 is enough for G4 as a whole;
3. LDP already defeats the program;
4. independent replication is optional;
5. cross-domain non-CSP support must be loss-only forever.

It claims only:

```text
The remaining work is now ordered enough that the program can advance by
closing specific open gates rather than by adding more loosely related notes.
```
