# G4 v2 Public Repair-Flow Rescan (2026-04-27)

Status: public-web rescan only. Not a ranking commit, not a freeze document,
and not validation evidence.

## 1. Purpose

The current repair-flow bottleneck is no longer notation alone. It is whether a
publicly accessible dataset can carry a directly logged compensation signal
\(g_t\) strongly enough for a real G4 v2 pilot.

This note rescans a small set of public-web candidates after the acquisition
brief and stochastic repair bridge note were written. The goal is narrower than
"find any maintenance dataset." The goal is to ask which public source is
strongest for one of three tiers:

1. repair-flow primary candidate;
2. public stochastic reliability bridge candidate;
3. weak-g / maintenance-boundary / loss-side control.

## 2. Screening Question

Each candidate is judged against three practical questions.

1. Does it support repeated units, time-stamped interventions, and a future
   endpoint?
2. Is the intervention signal direct enough to freeze a candidate \(g_t\)
   without outcome-coupled inference?
3. If not a full repair-flow primary, is it still strong enough for a public
   stochastic reliability bridge or maintenance-boundary bridge?

## 3. Current Public-Web Verdict

| Candidate | Public source | Strongest plausible tier now | Main blocker for full repair-flow primary | Next clean action |
|---|---|---|---|---|
| Scania Component X | Researchdata.se + Scientific Data | strongest public stochastic reliability bridge candidate | repair information is time-to-event / first-repair oriented, not yet a clean preventive/reactive logged \(g_t\) with post-intervention recovery semantics | create exact feasibility note for stochastic reliability bridge |
| Microsoft Azure Predictive Maintenance | Kaggle mirror + prior schema note | leakage-risk re-audit candidate | public schema still lacks a direct preventive/reactive field; repair class would still be inferred from failure overlap unless stronger documentation emerges | only revisit if documentation-based direct rule can be frozen |
| MetroPT-3 | UCI + Scientific Data + prior schema note | weak-g real operational control | effectively single-system and maintenance semantics live in sparse report metadata rather than a structured event table | keep as weak-g control, not primary |
| HSE filter dataset | Kaggle dataset page | maintenance-boundary / censored reliability candidate | preventive replacement exists, but the public description looks closer to preventive-to-predictive transition / censored RUL than to a direct repair-flow primary | inspect only if pursuing censored maintenance bridge, not direct \(g_t\) pilot |

## 4. Candidate Notes

### 4.1 Scania Component X

Primary sources:

- Researchdata.se dataset page: <https://researchdata.se/en/catalogue/dataset/2024-34/1>
- Scientific Data article: <https://www.nature.com/articles/s41597-025-04802-6>
- Dataset documentation PDF:
  <https://api.researchdata.se/dataset/2024-34/1/file/documentation?filePath=2024_IDA_challenge_v2.pdf>

Why it is strong:

- openly accessible under CC BY 4.0;
- explicit repeated unit: `vehicle_id`;
- explicit operation time: `time_step`;
- operational readouts, specifications, validation labels, and a repair/event
  file are all published;
- the documentation states that `train_tte.csv` includes repair records for
  each vehicle and records when Component X was repaired, if at all, during the
  study period;
- the dataset is designed for classification, survival analysis, and
  time-to-event settings.

Why it is not yet a clean public repair-flow primary:

- the exposed repair record is oriented toward first repair / time-to-event,
  not obviously toward repeated preventive vs reactive intervention classes;
- the current public documentation is stronger on repair occurrence timing than
  on direct post-intervention margin recovery semantics;
- a direct frozen \(g_t\) would still need a careful interpretation note.

Current verdict:

```text
Strongest current public stochastic reliability bridge candidate.
Not yet a clean public repair-flow primary candidate.
```

This is the best public-web route if the immediate goal is to move repair /
maintenance from near-bridge toward a public non-CSP stochastic bridge without
overclaiming direct empirical \(g_t\) support.

### 4.2 Microsoft Azure Predictive Maintenance

Public source:

- Kaggle dataset page:
  <https://www.kaggle.com/datasets/arnabbiswas1/microsoft-azure-predictive-maintenance>

Relevant already-frozen local note:

- `analysis/g4_v2_c1_schema_inspection_note.md`

Why it remains interesting:

- repeated units (`machineID`) and hourly timestamps;
- telemetry, error, maintenance, and failure tables exist separately;
- the public page still presents it as a predictive-maintenance style dataset,
  and the Kaggle summary states that failures are captured under a separate
  failures table that is a subset of maintenance.

Why it remains unsafe as a public repair-flow primary:

- the local schema inspection already showed that `PdM_maint.csv` contains only
  `datetime`, `machineID`, and `comp`;
- no direct preventive/reactive column exists in the exposed schema;
- unless a documentation-grounded direct repair-class rule exists outside the
  row overlap with failures, \(g_t\) would still be outcome-coupled.

Current verdict:

```text
Leakage-risk re-audit candidate only.
Do not promote without a direct documentation-based repair-class rule.
```

### 4.3 MetroPT-3

Primary sources:

- UCI page: <https://archive.ics.uci.edu/dataset/791/metropt%2B3%2B>
- Scientific Data article: <https://www.nature.com/articles/s41597-022-01877-3>

Relevant already-frozen local note:

- `analysis/g4_v2_c2_schema_inspection_note.md`

Why it still matters:

- real operational compressor data;
- strong time-series degradation / failure context;
- maintenance reports provide anomaly ground truth.

Why it remains weak for repair-flow primary:

- the Scientific Data article describes a single APU on an operating train;
- maintenance semantics come from company maintenance reports, not from a clean
  repeated-unit intervention table;
- this makes it a useful real operational weak-g or anomaly-control case, but
  not a clean direct-\(g_t\) primary.

Current verdict:

```text
Weak-g control, not a repair-flow primary.
```

### 4.4 HSE Filter Dataset

Public source:

- Kaggle dataset page:
  <https://www.kaggle.com/datasets/prognosticshse/preventive-to-predicitve-maintenance>

What the public description suggests:

- the dataset is about the transition from preventive maintenance to predictive
  maintenance for a replaceable part (a filter);
- training runs are recorded up to periodic replacement intervals;
- test runs are right-censored run-to-failure measurements with RUL ground
  truth.

Why it is interesting:

- it explicitly contains preventive replacement language;
- it looks naturally compatible with maintenance-boundary or censored
  reliability framing.

Why it is not yet a clean direct-\(g_t\) primary:

- the public description is stronger on censoring / RUL / replacement regime
  than on repeated-unit operational logs with directly observed intervention
  classes and future post-intervention state evolution;
- without stronger documentation, it reads more like a maintenance-boundary
  bridge than a full repair-flow pilot.

Current verdict:

```text
Interesting maintenance-boundary / censored reliability candidate.
Not yet a clean direct-\(g_t\) public primary.
```

## 5. What This Changes

This rescan changes the public-web landscape in a useful but limited way.

It does **not** show that a clean public repair-flow primary already exists.

It **does** show:

1. public-web data may still support a stronger non-CSP bridge than the paused
   C1/C2 repair-flow search suggested;
2. Scania Component X is the strongest current public candidate for a
   stochastic reliability bridge;
3. Azure PdM remains the only notable public repair-flow re-audit candidate,
   but only if a direct documentation-grounded repair-class rule can be fixed
   without failure-overlap inference;
4. HSE filter is more naturally a maintenance-boundary / censored-reliability
   candidate than a direct repair-flow primary.

## 6. Recommended Order

The clean next order is now:

1. create a Scania Component X exact feasibility note;
2. decide whether Scania should be opened as a public stochastic reliability
   bridge package;
3. keep Azure PdM in reserve only for documentation-based re-audit;
4. in parallel, continue partner / local acquisition for the stronger target:
   directly logged empirical \(g_t\).

## 7. Bottom Line

The best current reading is:

```text
Yes, public-web data can still move G4 v2 forward.
But the most promising public route is now a stochastic reliability bridge
(Scania), not an immediate full repair-flow primary.
```
