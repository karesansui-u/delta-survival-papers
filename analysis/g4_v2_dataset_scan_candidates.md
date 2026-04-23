# G4 v2 Exploratory Dataset Scan Candidates

Status: exploratory scan notes. Not a dataset-ranking commit, not a freeze
document, not validation evidence.

Date: 2026-04-23

Purpose:

Record public dataset candidates for the G4 v2 repair / maintenance operational
pilot. This file only asks whether each dataset appears to contain enough schema
structure to define:

```text
unit, time, damage indicator, repair indicator, and future degradation / failure endpoint.
```

No model performance is inspected here. No candidate is selected for primary
validation by this note.

## 1. Current Shortlist

| ID | Candidate | Source | Provisional label | One-line reason |
|---|---|---|---|---|
| C1 | Microsoft Azure Predictive Maintenance | Kaggle mirror / Azure sample dataset | leakage-risk | Schema inspection found unit/time/damage/failure structure, but no direct proactive/reactive maintenance label; repair class would require failure-overlap inference |
| C2 | MetroPT-3 Air Production Unit | UCI / Scientific Data | unclear | Has compressor sensor time series, failure reports, and maintenance timestamps, but may lack repeated units |
| C3 | Backblaze Drive Stats | Backblaze public hard-drive test data | weak-g | Excellent unit-level SMART / failure data, but repair / preventive maintenance is not cleanly logged |
| C4 | NASA C-MAPSS turbofan degradation | NASA / PHM benchmark mirrors | weak-g | Strong unit-time degradation and RUL endpoint, but no repair / maintenance flow |
| C5 | Microsoft Fabric predictive maintenance tutorial dataset | Microsoft Learn / Azure Open Datasets example | weak-g | Has machine parameters and failure label, but appears row-based and lacks explicit repair flow |
| C6 | ServiceNow IT incident log | Kaggle mirror of incident management process log | unclear | Rich incident lifecycle and change-request fields, but stable unit and future failure endpoint are not confirmed |
| C7 | TravisTorrent / CI failure history | Travis CI / software engineering datasets | leakage-risk | Build failures and fixes may be reconstructible, but repair \(g_t\) would be derived and leakage risk is high |

Label note:

```text
promising = best schema fit for exploration, not best eventual validation
dataset. Labels are one of the canonical scan labels in
analysis/g4_v2_exploratory_dataset_scan.md; qualifiers belong in the reason
text, not in the label cell.
```

## 2. Candidate Details

### C1. Microsoft Azure Predictive Maintenance

Source:

- Kaggle mirror: <https://www.kaggle.com/datasets/arnabbiswas1/microsoft-azure-predictive-maintenance/data>
- Archived Azure template repo: <https://github.com/Azure/AI-PredictiveMaintenance>

Relevant fields from source description:

- `PdM_telemetry.csv`: hourly voltage, rotation, pressure, vibration for 100
  machines during 2015.
- `PdM_errors.csv`: non-fatal errors encountered during operation.
- `PdM_maint.csv`: component replacements / maintenance records.
- `PdM_failures.csv`: component replacements due to failure.
- `PdM_machines.csv`: model type and age.

Why it looked promising before schema inspection:

- unit: `machineID`;
- time: hourly timestamps;
- damage candidates: telemetry deviations, error counts, age, prior failures;
- repair candidates: maintenance / component replacement records;
- endpoint candidates: failure in a future horizon;
- activity baseline: error count / telemetry count / maintenance count;
- source separates maintenance and failure records at the file level.

Schema inspection result:

- See `analysis/g4_v2_c1_schema_inspection_note.md`.
- `PdM_maint.csv` has only `datetime`, `machineID`, and `comp`.
- It does not directly distinguish proactive / preventive replacement from
  reactive / failure-linked replacement.
- Inferring this split from overlap with `PdM_failures.csv` would couple the
  repair variable to the endpoint during feature construction.

Main concerns:

- The dataset is synthetic / sample-like rather than a live operational log.
  If C1 later moves to freeze, the report must state that real operational-log
  replication remains required.
- Need inspect whether proactive vs reactive maintenance is directly labeled
  or must be inferred from overlap with failures.
- Maintenance and failures may partially overlap by construction, so blackout
  and reactive-repair separation are important.

Provisional label:

```text
leakage-risk
```

Completed schema inspection:

```text
C1 should not be promoted as a primary G4 v2 repair-flow dataset.
It may still be useful as a loss-only control or synthetic weak-repair schema
exercise.
```

### C2. MetroPT-3 Air Production Unit

Source:

- UCI page: <https://archive.ics.uci.edu/dataset/791/metropt%2B3%2B>
- Scientific Data article: <https://www.nature.com/articles/s41597-022-01877-3>

Source description:

- Sensors from a compressor Air Production Unit on metro vehicles.
- Readings include pressure, temperature, motor current, and air intake valves.
- UCI page lists failure periods and maintenance timestamps such as "Maintenance
  on 30Apr", "Maintenance on 8Jun", and "Maintenance on 16Jul".

Why promising:

- time: high-resolution sensor time series;
- damage candidates: compressor pressure, temperature, current, valve signals;
- endpoint candidates: air leak / high-stress failure intervals;
- repair candidates: maintenance timestamps in the failure / report metadata.

Main concerns:

- Unit structure may be weak if the dataset centers on one APU rather than many
  repeated units.
- Maintenance events may be few, making \(g_t\) difficult to estimate.
- Could be better as a single-system case study or exploratory visualization
  than as a primary predictive validation dataset.

Provisional label:

```text
unclear
```

Recommended next inspection:

```text
Inspect whether there are enough maintenance events and enough non-failure
intervals to define lagged repair features without leakage.
```

### C3. Backblaze Drive Stats

Source:

- Data page: <https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data>
- Recent reliability report context: <https://ir.backblaze.com/news/news-details/2026/Backblaze-Publishes-2025-Drive-Stats-Report/default.aspx>

Why useful:

- unit: drive serial number;
- time: daily drive records;
- damage candidates: SMART attributes, age, model, capacity, drive days;
- endpoint: drive failure;
- scale: very large and public.

Main concern:

- Repair / preventive maintenance is not cleanly logged. Failed drives leave the
  fleet, but replacement is not a per-drive preventive \(g_t\) signal.

Provisional label:

```text
weak-g
```

Recommended use:

```text
Good G4 loss-only or degradation-control dataset. Not the first choice for G4
v2 repair-flow validation.
```

### C4. NASA C-MAPSS Turbofan Degradation

Source:

- NASA / C-MAPSS benchmark mirrors are widely used; example Kaggle mirror:
  <https://www.kaggle.com/datasets/bishals098/nasa-turbofan-engine-degradation-simulation>

Why useful:

- unit: engine;
- time: flight cycle;
- damage candidates: sensor trajectories and operating settings;
- endpoint: RUL / run-to-failure.

Main concern:

- No repair / maintenance flow. Engines run to failure in the benchmark.

Provisional label:

```text
weak-g
```

Recommended use:

```text
Useful as a loss-only degradation sanity anchor, not as the G4 v2 open-system
repair-flow target.
```

### C5. Microsoft Fabric Predictive Maintenance Tutorial Dataset

Source:

- Microsoft Learn tutorial: <https://learn.microsoft.com/en-us/fabric/data-science/predictive-maintenance>

Source description:

- 10,000 rows with UID, product ID, air temperature, process temperature,
  rotational speed, torque, tool wear, and machine failure label.

Why useful:

- easy access;
- damage candidates: tool wear, process conditions, torque, temperature;
- endpoint: failure label.

Main concern:

- Row-based tutorial dataset, not repeated-unit maintenance log.
- No explicit repair / maintenance events.

Provisional label:

```text
weak-g
```

Recommended use:

```text
Not a G4 v2 primary candidate. Possibly useful only as a toy loss-only
classification control.
```

### C6. ServiceNow IT Incident Log

Source:

- Kaggle mirror: <https://www.kaggle.com/datasets/shamiulislamshifat/it-incident-log-dataset>

Source description:

- Event log of an incident management process from an anonymized ServiceNow
  instance.
- 141,712 events and 24,918 incidents.
- Fields include incident identifier, state, request-for-change identifier, and
  close code.

Why potentially useful:

- repair / resolution process may be observable through incident states,
  request-for-change, assignment, and close-code fields;
- time-stamped process events may support lagged features.

Main concerns:

- The incident itself may be the unit, not a stable system that can fail again.
- Endpoint may be resolution time rather than future degradation / failure.
- Repair can be almost identical to outcome resolution, creating leakage.

Provisional label:

```text
unclear
```

Recommended next inspection:

```text
Check whether there is a stable configuration item, service, or system field
that can act as repeated unit. Without such a unit, this is not suitable for
the G4 v2 pilot.
```

### C7. TravisTorrent / CI Failure History

Sources:

- Continuous defect prediction paper using TravisTorrent:
  <https://arxiv.org/abs/1703.04142>
- TravisTorrent is a common CI build-history source in software engineering
  research.

Why potentially useful:

- unit: repository, project, file, or build target;
- time: commit / build history;
- damage candidates: failing builds, churn, complexity, dependency changes;
- repair candidates: fixes, commits after failed builds, rollback-like changes;
- endpoint: future build failure / regression.

Main concerns:

- Repair \(g_t\) is derived from commit semantics, not directly logged.
- Leakage risk is high if "fix" is identified using later failure labels.
- Considerable extraction work is needed before any freeze design.

Provisional label:

```text
leakage-risk
```

Recommended use:

```text
Interesting later Route C / software operationalization candidate, but not the
first G4 v2 repair-maintenance dataset.
```

## 3. Inspection Order For Exploration Only

This is not a primary-dataset ranking. It is only a work-order for the next
schema inspection.

| Exploration status | Candidate | Reason |
|---|---|---|
| done | C1 Microsoft Azure Predictive Maintenance | Schema inspected; direct proactive/reactive repair label absent, so not primary G4 v2 repair-flow material |
| next | C2 MetroPT-3 | Has maintenance timestamps and failures, but repeated-unit structure may be weak |
| later | C3 Backblaze Drive Stats | Very strong loss-only control, weak repair |
| later | C4 NASA C-MAPSS | Standard degradation control, no repair |
| later | C6 ServiceNow incident log | May have repair/process information, but unit/endpoint unclear |
| later | C7 TravisTorrent / CI | Potential software route, high extraction and leakage risk |
| later | C5 Fabric tutorial dataset | Easy but likely too toy / weak-g |

## 4. Recommendation

The next concrete step should be:

```text
Inspect C2 MetroPT-3 schemas only.
```

Do not train models yet.

Minimum inspection questions for C2:

1. Does C2 expose repeated unit identifiers, or is it effectively a single
   asset time series?
2. Does C2 expose maintenance / repair events directly, and can preventive or
   scheduled maintenance be separated from failure-response events without
   using future failures?
3. Can a lagged window \([t-W,t)\) be defined without using future failures?
4. Can failure or degradation in \((t,t+H]\) be defined cleanly?
5. Is there enough directly observed maintenance before failures to make
   \(g_t\) meaningful?
6. Can generic activity baselines be defined from telemetry / operating-state
   coverage without outcome coupling?

C1 failed on repair separability at the schema level; see
`analysis/g4_v2_c1_schema_inspection_note.md`. If C2 also fails, G4 v2 should
pause or downgrade to loss-only controls rather than forcing a repair-flow
validation.
