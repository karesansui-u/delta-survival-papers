# G4 C-MAPSS FD001 Exact Archive Feasibility Note

Status: exact-archive feasibility note. Not frozen. Not validation evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_cmapss_loss_only_feasibility_note.md`
- `analysis/g4_cmapss_fd001_archive_note.md`

Purpose:

Record one exact public archive acquisition for the first C-MAPSS loss-only
branch, together with the structural counts needed before any later
preregistration.

This note still does not inspect predictor performance or model comparison
outcomes.

## 1. Archive Source Used For Feasibility

Canonical benchmark family remains:

```text
NASA C-MAPSS benchmark bundle conventionally distributed as CMAPSSData.zip
```

Landing page:

- NASA Open Data:
  <https://data.nasa.gov/dataset/cmapss-jet-engine-simulated-data>

Exact downloadable mirror used for local feasibility:

- Zenodo record:
  <https://zenodo.org/records/15346912>
- file:
  `CMAPSSData.zip`

Reason for using the mirror at this step:

```text
the NASA landing page is the canonical identity, while the Zenodo mirror gives
a stable downloadable bundle that can be hashed locally before any future
freeze
```

## 2. Exact Archive Identity

Locally acquired archive:

```text
CMAPSSData.zip
```

Observed size:

```text
12425978 bytes
```

Observed sha256:

```text
74bef434a34db25c7bf72e668ea4cd52afe5f2cf8e44367c55a82bfd91a5a34f
```

Observed zip entries:

- `Damage Propagation Modeling.pdf`
- `readme.txt`
- `RUL_FD001.txt`
- `RUL_FD002.txt`
- `RUL_FD003.txt`
- `RUL_FD004.txt`
- `test_FD001.txt`
- `test_FD002.txt`
- `test_FD003.txt`
- `test_FD004.txt`
- `train_FD001.txt`
- `train_FD002.txt`
- `train_FD003.txt`
- `train_FD004.txt`

## 3. Exact FD001 Structural Counts

Selected first subset remains:

```text
FD001
```

Observed FD001 counts:

| file | rows | units | cycle min | cycle max |
|---|---:|---:|---:|---:|
| `train_FD001.txt` | `20631` | `100` | `1` | `362` |
| `test_FD001.txt` | `13096` | `100` | `1` | `303` |
| `RUL_FD001.txt` | `100` | `100` targets | `7` min RUL | `145` max RUL |

Observed column count per data row:

```text
26 columns
```

Interpretation:

- one repeated unit identifier;
- one cycle index;
- 24 remaining numeric fields for settings / sensors.

## 4. Why This Is Feasible For A Later Frozen Design

FD001 is now feasible not just in principle, but as an exact public bundle,
because the later design can already rely on:

1. fixed archive identity and hash;
2. fixed subset choice;
3. fixed unit counts in train and test;
4. a clean held-out target file with one RUL target per test unit;
5. a public benchmark bundle small enough to distribute reproducibly.

That is enough to move from "candidate" to:

```text
archive-ready loss-only branch for a later preregistration
```

## 5. Structural Reading For Later Prereg

The clean first reading remains:

| benchmark field | structural role |
|---|---|
| engine id | repeated unit |
| cycle | time index |
| settings / sensors | reduction-side covariates |
| provided RUL targets | future endpoint |
| repair events | absent, so \(r_t = 0\) |

This stays strictly below repair-flow evidence.

## 6. Later Prereg Path

The next clean C-MAPSS move should be a loss-only preregistration that fixes:

1. the exact archive hash above;
2. the exact subset FD001;
3. the exact endpoint family:
   - either RUL regression on held-out units, or
   - a preregistered binary event indicator derived from RUL;
4. the split rule:
   - preserve the official train/test unit split unless a stronger frozen unit
     split is explicitly justified in advance;
5. baseline family and model class before any performance inspection.

At this stage, the most conservative later path is:

```text
keep FD001 and the official train/test separation, then freeze one loss-only
endpoint form before touching any predictor comparison
```

## 7. Non-Claims

This note does not claim:

1. FD001 already supports the theory;
2. RUL regression is the only acceptable endpoint path;
3. C-MAPSS provides repair-flow evidence;
4. the Zenodo mirror changes the canonical benchmark identity.
