# G4 C3 Backblaze Loss-Only Schema Inspection Note

Status: schema-only inspection for a loss-only / weak-g control branch. Not a
dataset-ranking commit, not a freeze document, not validation evidence.

Date: 2026-04-23

Candidate:

```text
C3 Backblaze Drive Stats
```

Tier boundary:

```text
C3 is loss-only / weak-g only.
It is not repair-flow \(g_t\) evidence.
It does not complete or rescue the paused G4 v2 repair-flow primary search.
```

Verdict:

```text
promising as a non-CSP loss-only empirical anchor;
not eligible as repair-flow / maintenance evidence.
```

## 1. Inspection Boundary

This note inspects only schema-level structure.

Allowed in this pass:

1. Public schema files.
2. Column names.
3. File hashes for schema artifacts.
4. Whether unit / time / degradation / endpoint fields exist.
5. Whether any direct repair / preventive maintenance signal exists.

Not inspected in this pass:

1. Model performance.
2. Failure rates.
3. SMART attribute distributions.
4. Drive-age or survival curves.
5. Any analysis of predictors against future failures.

## 2. Source Access

Primary source:

- Backblaze Drive Stats data page:
  <https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data>

Schema files inspected:

- Current schema:
  <https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/Drive_Stats_Schema_Current.csv>
- Historical schema listing:
  <https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/Drive_Stats_Schema_2018_Onward.csv>

Hashes:

| File | sha256 | size bytes | note |
|---|---:|---:|---|
| `Drive_Stats_Schema_Current.csv` | `365cf50ad5ebfc3e20d0959337d9877ce9539e0432955bda836b7482cd0f5358` | 3,531 | Current schema, last updated Q2 2024 |
| `Drive_Stats_Schema_2018_Onward.csv` | `0ac0c6abcad39c22e590dd8a6ece897a8bb899e4618e67d5e78c0ced30282c37` | 70,262 | Quarter-level schema listing |

Recent quarterly archive checked by HEAD only:

```text
data_Q4_2025.zip
Content-Length: 1,157,851,346 bytes
```

The quarterly data archive is too large for this schema-only pass and was not
downloaded.

## 3. Observed Schema

The current schema includes the following core fields:

```text
date
serial_number
model
capacity_bytes
failure
datacenter
cluster_id
vault_id
pod_id
pod_slot_num
is_legacy_format
smart_*_normalized
smart_*_raw
```

This is sufficient to identify a drive-day panel with repeated units.

## 4. Minimum Inspection Questions

### Q1. Does C3 expose repeated unit identifiers and time?

Yes.

The schema contains:

```text
unit: serial_number
time: date
```

This is stronger repeated-unit structure than C1 and C2.

### Q2. Does C3 expose degradation / damage indicators without future failure labels?

Yes.

The schema includes SMART attributes in normalized and raw forms:

```text
smart_*_normalized
smart_*_raw
```

These can serve as damage / degradation indicators in a later frozen analysis.
This note does not inspect their distributions or predictive power.

### Q3. Can failure in (t,t+H] be defined cleanly?

Structurally yes.

The schema contains:

```text
failure
```

Combined with `serial_number` and `date`, this can define a future failure
endpoint after freeze.

### Q4. Is there any direct repair / preventive maintenance signal?

No.

The current schema does not expose direct maintenance, repair, replacement, or
preventive intervention fields. Failed drives leave the observed drive panel,
but replacement is not a per-drive preventive \(g_t\) event.

Therefore C3 is strictly loss-only / weak-g for the present program.

### Q5. Can generic activity baselines be defined without outcome coupling?

Structurally yes.

Potential non-outcome baseline fields include:

```text
model
capacity_bytes
datacenter
cluster_id
vault_id
pod_id
pod_slot_num
is_legacy_format
```

Operational exposure can also be represented by the presence of repeated
drive-day observations. This note does not compute exposure counts.

## 5. Interpretation

C3 is the cleanest public non-CSP operational dataset in the current shortlist
for a loss-only empirical anchor:

```text
damage / degradation indicators -> future failure endpoint
```

It should not be used to claim repair-flow or compensation-flow evidence.

If developed further, C3 can support a separate loss-only branch:

```text
G4 loss-only industrial reliability anchor
```

It cannot complete:

```text
G4 v2 repair / maintenance operational pilot
```

## 6. Next Action

If the program wants a non-CSP empirical anchor soon, the clean next move is to
draft a separate loss-only Backblaze preregistration.

That preregistration should explicitly state:

1. It is not a repair-flow \(g_t\) study.
2. It tests only loss/degradation-to-failure prediction in a repeated-unit
   industrial panel.
3. It should be reported below Exp43c in evidence strength, because Backblaze is
   observational rather than randomized from frozen generation rules.
4. Repair-flow G4 v2 remains paused until a dataset with direct repair /
   preventive maintenance semantics is found.
