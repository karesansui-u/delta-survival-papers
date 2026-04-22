# Exp43 q-coloring phase status

Status: exploration / pilot calibration, not validation.

Date: 2026-04-22

## 1. Phase classification

Exp43 is currently in the exploration phase. More precisely, it is in pilot
calibration:

| Phase | Meaning | Exp43 status |
|---|---|---|
| Exploration | Tune measurement setup, grid, timeout, and feasibility of the run | Current phase |
| Freeze | Commit preregistration, instance-manifest rules, feature schema, and analysis script | Not reached |
| Validation | Generate primary data and run the frozen analysis once | Not reached |

Pilot_v1 and pilot_v2 are exploration data. They are not primary data and must
not be counted as validation evidence for the theory.

## 2. What pilot_v1/v2 showed

Pilot_v1 was infrastructure-clean but did not pass the freeze gate:

```text
records: 900
SAT: 493
UNSAT: 403
TIMEOUT: 4
MALFORMED: 0
pilot_pass: false
inconclusive_by_30pct_rule: false
```

The pilot_v1 issue was a combination of band placement and one suspended cell.
The selected fallback was recorded in `pilot_v1_addendum.md` before pilot_v2.

Pilot_v2 improved tractability but still did not pass the freeze gate:

```text
records: 1800
SAT: 955
UNSAT: 844
TIMEOUT: 1
MALFORMED: 0
pilot_pass: false
inconclusive_by_30pct_rule: false
informative bands:
  q=3: {0.60,0.70,0.80}
  q=4: {0.80}
  q=5: {0.80}
```

The pilot_v2 blocker is not solver failure. It is calibration: q=4 and q=5
have transition regions that are too narrow for the current precommitted grid.

## 3. Boundary line

The current Exp43 grid must not be frozen as a primary validation design.

Allowed next steps:

- write a new Exp43b preregistration that explicitly treats pilot_v1/v2 as
  calibration and fixes q-specific fine grids before any primary data;
- mark the current Exp43 calibration attempt inconclusive and pivot to another
  Route A width experiment, such as Cardinality-SAT / Exp44;
- continue exploratory calibration only if the result is clearly labeled as
  exploration and is not counted as validation evidence.

Not allowed:

- run primary q-coloring data from the current grid;
- count pilot_v1/v2 as theory-confirming primary evidence;
- tune the grid after seeing primary outcomes;
- claim universal-law support from Exp43 before a frozen validation run.

## 4. Freeze requirements before validation

Before any Exp43 or Exp43b primary run, the following must be committed and
pushed or otherwise timestamped:

1. frozen preregistration;
2. grid and instance-generation rules;
3. seed policy / instance manifest rules;
4. feature schema;
5. primary and secondary model specifications;
6. exclusion and timeout rules;
7. analysis script;
8. statement that pilot_v1/v2 were exploration data only.

Only after these are fixed should primary data be generated.

## 5. Recommended interpretation

Exp43 has not failed as a theory test, because it has not entered validation.
It has shown that the first q-coloring validation design was under-calibrated
for q=4 and q=5. This is useful exploration feedback, not negative primary
evidence.

The clean research move is:

```text
current Exp43 = exploration / pilot calibration
next = Exp43b fine-grid preregistration or Exp44 Cardinality-SAT
```
