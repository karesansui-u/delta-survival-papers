# G4 v2 C2 Schema Inspection Note

Status: schema/head inspection only. Not a dataset-ranking commit, not a freeze
document, not validation evidence.

Date: 2026-04-23

Candidate:

```text
C2 MetroPT-3 Air Production Unit
```

Verdict:

```text
weak-g for G4 v2 repair-flow primary;
useful as a single-system degradation / loss-control case study.
```

## 1. Inspection Boundary

This note inspects only schema-level structure and file identity.

Allowed in this pass:

1. File availability.
2. File hashes.
3. Column names and head-level dtypes.
4. Whether repeated unit identifiers are present.
5. Whether maintenance / repair events are represented as directly usable
   time-stamped variables rather than inferred from future failures.

Not inspected in this pass:

1. Model performance.
2. Outcome-conditioned counts.
3. Failure-proximity statistics.
4. Any rule that infers repair usefulness from distance to failure.
5. Any aggregate statistic of the form "maintenance within H hours of failure".

The failure and maintenance dates below are read from the source description
table only. No time-series aggregation or overlap computation was performed.

## 2. Source Access

Official source:

- UCI Machine Learning Repository:
  <https://archive.ics.uci.edu/dataset/791/metropt%2B3%2B>
- Scientific Data article:
  <https://www.nature.com/articles/s41597-022-01877-3>

File source used for hashes and head inspection:

- Kaggle mirror:
  <https://www.kaggle.com/datasets/joebeachcapital/metropt-3-dataset>
- Dataset ref: `joebeachcapital/metropt-3-dataset`
- Dataset version number: `1`
- Download URL pattern:
  `https://www.kaggle.com/api/v1/datasets/download/joebeachcapital/metropt-3-dataset?datasetVersionNumber=1`

Downloaded archive:

```text
metropt.zip
sha256: 6d901b67a5d9420286deb80e53e439db52f8986f2f619503d06860eed2ebe761
size:   29,093,716 bytes
```

The UCI static archive was checked first, but full download was too slow for
this schema pass. The Kaggle mirror contains the same named data file and data
description PDF used for schema/head inspection.

## 3. File Identity And Schema

| File | sha256 | columns / contents |
|---|---:|---|
| `Data Description_Metro.pdf` | `b00fac0e8899854078309bef4adaa480d82ecf14dc81c5097c3646973e824127` | Source description, attribute list, failure report table |
| `MetroPT3(AirCompressor).csv` | `db30ccb4ea402e3c8bf2c99db06e288d4f2a772f6928f9dbe26a920d69793e24` | One time-series CSV with timestamp and 15 sensor/control fields |

Observed CSV header:

```text
<index>, timestamp, TP2, TP3, H1, DV_pressure, Reservoirs,
Oil_temperature, Motor_current, COMP, DV_eletric, Towers, MPG,
LPS, Pressure_switch, Oil_level, Caudal_impulses
```

Head-level dtypes:

```text
<index>: integer-like
timestamp: string timestamp
TP2, TP3, H1, DV_pressure, Reservoirs, Oil_temperature, Motor_current: numeric
COMP, DV_eletric, Towers, MPG, LPS, Pressure_switch, Oil_level, Caudal_impulses: numeric / binary-like
```

Head inspection confirmed the schema. No aggregate counts or
outcome-conditioned summaries were computed.

## 4. Source-Described Failure / Maintenance Metadata

The source description states that the time series is unlabeled, but failure
reports from the company are provided in a table.

Schema-level facts from that table:

1. Failure intervals are represented by start time, end time, failure type, and
   severity.
2. Report text includes maintenance timestamps for some failure rows, such as
   maintenance on `30Apr`, `8Jun`, and `16Jul`.
3. These maintenance events are not represented as a separate structured CSV
   table with a unit identifier, repair class, or preventive/reactive label.

This makes the maintenance semantics available only as sparse report metadata,
not as a directly modeled repair-flow table.

## 5. Minimum Inspection Questions

### Q1. Does C2 expose repeated unit identifiers?

No.

The observed CSV has no explicit unit column. The source description frames the
dataset as sensor readings from a compressor's Air Production Unit. Therefore
C2 is effectively a single-system time series, not a repeated-unit panel.

This is not fatal for a qualitative or loss-control case study, but it is weak
for the intended G4 v2 operational repair-flow primary.

### Q2. Does C2 expose maintenance / repair events directly?

Only weakly.

Maintenance timestamps appear in the source description's failure report table,
but not as a separate structured event table in the CSV. There is no direct
column such as:

```text
maintenance_type, repair_class, preventive, reactive, scheduled, unscheduled
```

Because the maintenance timestamps are embedded in failure report metadata,
using them as \(g_t\) would require careful manual event extraction and would
remain too sparse for a robust primary observational validation.

### Q3. Can a lagged window [t-W,t) be defined without using future failures?

Structurally yes.

The CSV has a `timestamp` column and sensor/control signals. A lagged feature
window can be defined from past telemetry and operating state without using
future failure intervals.

### Q4. Can failure or degradation in (t,t+H] be defined cleanly?

Structurally yes.

The source description provides failure intervals with start and end times. A
future failure endpoint could therefore be defined after freeze.

No failure-proximity statistics were computed in this schema pass.

### Q5. Is there enough directly observed maintenance before failures to make g_t meaningful?

Probably not for primary validation.

The inspection found only sparse maintenance timestamps in report metadata,
not a repeated maintenance event table. Determining whether they are numerous
or predictive enough would require outcome-coupled analysis, which is outside
schema inspection.

At the schema level, C2 does not provide the direct repair-flow structure needed
for a clean G4 v2 operational primary.

### Q6. Can generic activity baselines be defined from telemetry / operating-state coverage?

Structurally yes.

The CSV contains continuous sensor/control variables, including pressure,
temperature, current, and valve / state signals. These support generic
activity or operating-state baselines in a later frozen analysis.

That does not compensate for the weak repair-flow semantics.

## 6. Interpretation

C2 is stronger than C1 as a real operational time-series source, but weaker
than needed for G4 v2 repair-flow validation because:

1. it appears to be a single-system time series rather than a repeated-unit
   panel;
2. maintenance events are sparse report metadata rather than a direct event
   table;
3. preventive / scheduled repair semantics are not directly separable as a
   structured variable.

Therefore C2 should not be promoted as the primary G4 v2 repair-flow dataset.
It remains useful as a single-system degradation / anomaly / loss-control case
study.

## 7. Next Action

C1 and C2 both fail the repair-flow primary requirement, for different reasons:

```text
C1: repeated units exist, but repair class requires failure-overlap inference.
C2: real operational time series exists, but repeated units and repair-flow
    event structure are too weak.
```

Under the current exploration plan, G4 v2 should pause the repair-flow primary
search or downgrade to loss-only / weak-g controls rather than forcing a
repair-flow validation from unsuitable datasets.
