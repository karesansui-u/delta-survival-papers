# Exp44 Cardinality-SAT phase status

Status: exploration / pilot calibration, not validation.

Date: 2026-04-23

## 1. Phase classification

Exp44 is currently in the exploration phase. More precisely, it is in pilot
calibration:

| Phase | Meaning | Exp44 status |
|---|---|---|
| Exploration | Tune measurement setup, grid, timeout, encoding, and feasibility of the run | Current phase |
| Freeze | Commit preregistration, instance-manifest rules, feature schema, and analysis script | Not reached |
| Validation | Generate primary data and run the frozen analysis once | Not reached |

Smoke, runtime probe, pilot_v2, and pilot_v3 outputs are calibration data. They
are not primary data and must not be counted as validation evidence for the
theory.

## 2. What the calibration runs showed

The smoke run was infrastructure-clean:

```text
records: 45
SAT: 14
UNSAT: 31
TIMEOUT: 0
MALFORMED: 0
SAT assignment_verified: 14 / 14
```

The initial runtime probe showed that the original pilot grid was too expensive
near hard low-drift cells. This led to the precommitted smaller-n fallback:

```text
n in {60, 100}
```

Pilot_v2 was infrastructure-clean but did not pass the freeze gate:

```text
records: 2400
SAT: 809
UNSAT: 1591
TIMEOUT: 0
MALFORMED: 0
max runtime: 19.68 seconds
pilot_pass: false
monotone mixtures: 6 / 6
informative bands:
  M0_low:          {0.85}
  M1_low_med:      {0.85}
  M2_bal_low_med:  {0.85}
  M3_threeway_low: {0.70,0.85}
  M4_threeway_med: {0.70,0.85}
  M5_med_high:     {0.70,0.85}
```

Pilot_v3 used the precommitted fine-grid fallback. It was also
infrastructure-clean, but still did not pass the freeze gate:

```text
records: 3600
SAT: 1087
UNSAT: 2513
TIMEOUT: 0
MALFORMED: 0
max runtime: 11.63 seconds
pilot_pass: false
monotone mixtures: 6 / 6
informative bands:
  M0_low:          {0.90}
  M1_low_med:      {0.90}
  M2_bal_low_med:  {0.90}
  M3_threeway_low: {0.70,0.80,0.90}
  M4_threeway_med: {0.70,0.80,0.90}
  M5_med_high:     {0.70,0.80}
```

The final blocker is not solver failure, timeout, malformed encoding, or
non-monotonicity. It is calibration: the low-drift mixtures M0/M1/M2 have
transition regions that are too narrow for the current precommitted grid.

## 3. Boundary line

The current Exp44 grid must not be frozen as a primary validation design.

Allowed next steps:

- write a new Exp44b preregistration that explicitly treats smoke, runtime
  probe, pilot_v2, and pilot_v3 as calibration and fixes a new threshold-local
  grid before any primary data;
- return to Exp43b q-coloring with a new threshold-local preregistration;
- pause Route A empirical calibration and move to G4/G6 formal mapping work;
- continue exploratory calibration only if the result is clearly labeled as
  exploration and is not counted as validation evidence.

Not allowed:

- run primary Cardinality-SAT data from the current Exp44 grid;
- count smoke, runtime probe, pilot_v2, or pilot_v3 as theory-confirming
  primary evidence;
- tune the grid after seeing primary outcomes;
- claim universal-law support from Exp44 before a frozen validation run.

## 4. Freeze requirements before validation

Before any Exp44b primary run, the following must be committed and pushed or
otherwise timestamped:

1. frozen preregistration;
2. threshold-local grid selection rule;
3. seed policy / disjoint calibration-primary stream rule;
4. instance-manifest rules;
5. feature schema;
6. primary and secondary model specifications;
7. predictor rank-correlation / power-collapse diagnostic;
8. window-boundary buffer rule;
9. exclusion, timeout, and runtime-unstable rules;
10. analysis script;
11. statement that all Exp44 calibration outputs are exploration data only.

Only after these are fixed should primary data be generated.

## 5. Recommended interpretation

Exp44 has not failed as a theory test, because it has not entered validation.
It has shown that Cardinality-SAT feasibility experiments need a
threshold-local protocol rather than a broad rho grid.

The clean research move is:

```text
current Exp44 = exploration / pilot calibration
next = threshold-local protocol note, Exp44b only if newly preregistered,
       or G4/G6 formal mapping
```
