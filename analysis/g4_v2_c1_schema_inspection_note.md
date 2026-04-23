# G4 v2 C1 Schema Inspection Note

Status: schema/head inspection only. Not a dataset-ranking commit, not a freeze
document, not validation evidence.

Date: 2026-04-23

Candidate:

```text
C1 Microsoft Azure Predictive Maintenance
```

Verdict:

```text
leakage-risk for G4 v2 repair-flow primary;
weak-g as a synthetic / loss-only / schema exercise candidate.
```

## 1. Inspection Boundary

This note inspects only schema-level structure and file identity.

Allowed in this pass:

1. File availability.
2. File hashes.
3. Column names and head-level dtypes.
4. Whether a proactive / reactive maintenance label exists directly in
   `PdM_maint.csv`.
5. Whether maintenance and failure tables contain structurally joinable fields.

Not inspected in this pass:

1. Model performance.
2. Outcome-conditioned counts.
3. Maintenance / failure overlap rates.
4. Any rule that infers proactive maintenance from distance to failures.
5. Any aggregate statistic of the form "maintenance within H hours of failure".

This boundary is intentional. Inferring repair class from failure overlap would
already be feature engineering and would couple the repair variable to the
future-failure endpoint before freeze.

## 2. Source Access

Primary data source:

- Kaggle mirror:
  <https://www.kaggle.com/datasets/arnabbiswas1/microsoft-azure-predictive-maintenance/data>

Access method:

- Kaggle public dataset API.
- Dataset ref: `arnabbiswas1/microsoft-azure-predictive-maintenance`
- Dataset version number: `3`
- Download URL pattern:
  `https://www.kaggle.com/api/v1/datasets/download/arnabbiswas1/microsoft-azure-predictive-maintenance?datasetVersionNumber=3`

Downloaded archive:

```text
kaggle_download.zip
sha256: 7575444d4d605b1f7155ab937cf541243afe07fce1afba998bf4195e8e84e1eb
size:   32,497,141 bytes
```

Secondary source checked:

- Archived Azure template repo:
  <https://github.com/Azure/AI-PredictiveMaintenance>
- Cloned commit:
  `0e0abe204490b978c10346b9006501aaec426117`

The archived Azure repo contains notebook / binary artifacts but not the
`PdM_*.csv` files as plain tracked files. The schema inspection below therefore
uses the Kaggle mirror CSV files.

## 3. File Identity And Schema

| File | sha256 | size bytes | columns | head-level dtypes |
|---|---:|---:|---|---|
| `PdM_errors.csv` | `9c2a2a010ad77227e2bb0c94e7971bca78810790ddd1f28a8bee4f12c2f62370` | 129,077 | `datetime`, `machineID`, `errorID` | `str`, `int64`, `str` |
| `PdM_failures.csv` | `0c6c31a4fd52ef2df95ad7c44e8b0c8c32917bcef29ba5a1ba3ba45531ded3b7` | 24,336 | `datetime`, `machineID`, `failure` | `str`, `int64`, `str` |
| `PdM_machines.csv` | `5e8e1571c4999bf88abb7cae3925964c218d946fe851a9a100bb3d19330652bc` | 1,582 | `machineID`, `model`, `age` | `int64`, `str`, `int64` |
| `PdM_maint.csv` | `481ed4e155f609e6ca6130754d2c035453093902a507cce5b3f3e235995f1db6` | 104,903 | `datetime`, `machineID`, `comp` | `str`, `int64`, `str` |
| `PdM_telemetry.csv` | `d957f3c45bb83416b716600da8cffd72f4b6961db89867d9696ad19f7cb1bd4e` | 80,142,329 | `datetime`, `machineID`, `volt`, `rotate`, `pressure`, `vibration` | `str`, `int64`, `float64`, `float64`, `float64`, `float64` |

Head inspection confirmed that the values match these schemas. No aggregate
counts or outcome-conditioned summaries were computed.

## 4. Minimum Inspection Questions

### Q1. How many machines and timestamps exist?

Not computed in this schema pass.

The schema contains the necessary unit and time fields:

```text
unit: machineID
time: datetime
```

The candidate scan records the source description as a 100-machine hourly
telemetry dataset, but this note does not recompute exact machine or timestamp
counts.

### Q2. Does `PdM_maint.csv` distinguish proactive vs reactive replacement directly?

No.

Observed `PdM_maint.csv` columns:

```text
datetime, machineID, comp
```

There is no direct column such as:

```text
maintenance_type, proactive, reactive, scheduled, unscheduled, reason
```

Therefore proactive / reactive status is not directly available from
`PdM_maint.csv`.

### Q3. Can a lagged window [t-W,t) be defined without using future failures?

Structurally yes.

Telemetry, errors, maintenance, and machine metadata all expose `machineID`, and
the time-indexed event tables expose `datetime`. A lagged feature window could
therefore be defined from past telemetry / error / maintenance records without
using future failure labels.

This does not rescue the repair-flow primary issue, because the repair class
itself is not directly labeled.

### Q4. Can failure in (t,t+H] be defined cleanly?

Structurally yes.

`PdM_failures.csv` contains:

```text
datetime, machineID, failure
```

This is sufficient to define a future-failure endpoint after freeze.

No overlap statistics between `PdM_maint.csv` and `PdM_failures.csv` were
computed in this pass.

### Q5. Is there enough preventive maintenance before failures to make g_t meaningful?

Not assessable without outcome coupling.

Because `PdM_maint.csv` does not directly label preventive / reactive repair,
answering this question would require using overlap or distance to
`PdM_failures.csv`. That would be exactly the leakage-prone operation excluded
from schema inspection.

For this reason, C1 should not be promoted as a primary G4 v2 repair-flow
dataset under the current discipline.

### Q6. Can generic activity baselines be defined from errors / telemetry counts?

Structurally yes.

Potential activity sources:

```text
PdM_telemetry.csv: machineID, datetime, volt, rotate, pressure, vibration
PdM_errors.csv:    machineID, datetime, errorID
PdM_maint.csv:     machineID, datetime, comp
```

These fields are sufficient for generic activity baselines such as telemetry
coverage, error-event presence, and maintenance-event presence after freeze.

## 5. Interpretation

C1 is useful as a schema exercise and possibly as a loss-only or synthetic
weak-repair control. It is not clean enough for the intended G4 v2 operational
repair-flow primary because the key repair split is not directly observed.

The critical failure mode is:

```text
preventive / reactive repair status would have to be inferred from failure
overlap or failure proximity.
```

That inference would couple the compensation variable \(g_t\) to the endpoint.
It would therefore weaken the observational pilot exactly where the pilot needs
discipline most.

## 6. Next Action

Do not freeze C1 as the primary G4 v2 repair-flow dataset.

Proceed to C2 (`MetroPT-3 Air Production Unit`) schema inspection, using the
same exploration-only boundary:

1. schema / heads only;
2. no modeling;
3. no outcome-conditioned aggregate statistics;
4. direct repair / maintenance semantics must be checked before any freeze
   discussion.
