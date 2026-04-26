# Open Gates Execution Plan

Status: active program-execution memo after Backblaze v2 same-domain
observational support. This is not a freeze document, not validation evidence,
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
3. G7 independent replication;
4. rival-framework stress testing, especially LDP / rate-function subsumption.

## 1. Current Starting Position

The program is not starting from zero.

Already closed or strengthened:

- Route A primary anchors: Mixed-CSP and Exp43c q-coloring;
- Route C observational anchors: Exp.40 / 41 / 42 and Paper 4;
- G6-c iteration 1: minimal Foster-Lyapunov algebraic embedding;
- G4 v1 and G4 v2 algebraic non-CSP skeletons;
- Backblaze loss-only branch:
  - Q4 2025 v1 closed no-support;
  - Q3 2025 v2 same-domain calibrated support.

Still open:

- no repair-flow empirical primary;
- no cross-domain non-CSP empirical support beyond drive reliability;
- no external independent replication package;
- no completed reader-facing rival-framework comparison.

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

## 3. Workstream B — Cross-Domain Non-CSP Empirical Support

### Current state

Backblaze v2 is useful, but it is:

- loss-only;
- observational;
- same-domain second attempt.

So it improves G4, but it does not close the heterogeneous-domain non-CSP gap.

### Recommended direction

The next non-CSP empirical move should not be another Backblaze redesign.
Instead, add one clean cross-domain loss-only anchor and keep it explicitly
below repair-flow evidence.

The best current candidate is:

```text
C-MAPSS turbofan degradation as a non-CSP loss-only control / anchor.
```

Reason:

- distinct domain from drive reliability;
- repeated units;
- explicit time axis;
- strong degradation signals;
- public and reproducible;
- no temptation to overclaim repair flow, because \(g_t=0\) is obvious.

MetroPT-3 remains useful as a single-system weak-g control, but it is weaker as
a cross-domain primary anchor because unit repetition is limited.

### Next artifact

Create a C-MAPSS feasibility note using the same discipline as the Backblaze
schema / feasibility notes:

- archive / source identity;
- unit / time / degradation / endpoint structure;
- what can be frozen later;
- why it is loss-only and not repair-flow.

## 4. Workstream C — G7 Independent Replication

### Current state

The program now has real validated anchors, but still no external replication
package.

### Principle

Do not begin with the hardest or most ambiguous replication target.

Start with the strongest, cleanest, most deterministic package first. The
current recommended order is:

1. Mixed-CSP primary package;
2. Exp43c q-coloring primary package;
3. Backblaze v2 observational package.

Reason:

- Mixed-CSP is already a clean Route A primary with frozen predictors and a
  direct held-out metric;
- Exp43c is stronger on heterogeneous family transfer, but comes with a more
  elaborate threshold-local calibration history;
- Backblaze v2 is observational and same-domain second-attempt, so it should
  not be the first external replication representative.

### Next artifact

Create a replication-package plan note for Mixed-CSP. Minimum contents:

- exact frozen commit / prereg path;
- scripts to run;
- expected input artifacts;
- expected summary outputs;
- what counts as a successful rerun;
- what is allowed to vary across machines;
- what does not count as replication failure.

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

## 6. Recommended Execution Order

Near-term order:

1. close the rival-framework layer enough that the program can state how it is
   not merely a relabeling;
2. package one clean G7 replication target;
3. add one cross-domain non-CSP loss-only anchor candidate;
4. only then reopen the harder repair-flow empirical path.

In other words:

```text
theory-defense -> replication package -> cross-domain non-CSP -> repair-flow data acquisition
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

So the next concrete moves become:

1. exact C-MAPSS subset / archive note before any loss-only prereg;
2. Mixed-CSP Level 2 fresh rerun under the G7 workstream;
3. `analysis/g7_exp43c_replication_package_plan.md`;
4. future repair-flow data acquisition under the candidate-criteria gate.

Status update:

- item 1 now exists as `analysis/g4_cmapss_fd001_archive_note.md`;
- item 2 is now complete locally in
  `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`;
- item 3 now exists as `analysis/g7_exp43c_replication_package_plan.md`.

So the next concrete order becomes:

1. C-MAPSS exact-archive feasibility / later prereg path;
2. external Mixed-CSP rerun packaging;
3. Exp43c rerun execution when desired;
4. future repair-flow data acquisition under the candidate-criteria gate.

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
