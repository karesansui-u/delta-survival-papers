# G4 C-MAPSS FD001 Exact Subset / Archive Note

Status: metadata-only subset note. Not frozen. Not validation evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_cmapss_loss_only_feasibility_note.md`
- `analysis/open_gates_execution_plan.md`

Purpose:

Select the first exact C-MAPSS subset and canonical archive family for a later
cross-domain non-CSP loss-only preregistration.

This note does not inspect predictor performance, target difficulty, or model
comparison outcomes. It only fixes:

1. which benchmark bundle family to use first;
2. which subset inside that family to use first;
3. why that choice is the cleanest first loss-only anchor.

## 1. Canonical Archive Family

Chosen archive family:

```text
NASA C-MAPSS benchmark bundle conventionally distributed as CMAPSSData.zip
```

Canonical file family inside that bundle:

- `train_FD001.txt`
- `test_FD001.txt`
- `RUL_FD001.txt`
- `train_FD002.txt`
- `test_FD002.txt`
- `RUL_FD002.txt`
- `train_FD003.txt`
- `test_FD003.txt`
- `RUL_FD003.txt`
- `train_FD004.txt`
- `test_FD004.txt`
- `RUL_FD004.txt`

Source identity:

- NASA Open Data landing page:
  <https://data.nasa.gov/dataset/cmapss-jet-engine-simulated-data>

Why this archive family:

```text
it is the standard public benchmark representation of C-MAPSS and keeps the
future preregistration on a reproducible public path rather than an ad hoc
processed mirror
```

Archive hash is intentionally not recorded here because the exact local copy is
not yet frozen. The later freeze package must hash the acquired bundle before
any primary evaluation.

## 2. Exact First Subset

Chosen first subset:

```text
FD001
```

Subset files:

- `train_FD001.txt`
- `test_FD001.txt`
- `RUL_FD001.txt`

## 3. Why FD001 Goes First

FD001 is the cleanest first subset because it is the most conservative
starting point:

1. single operating-condition regime;
2. single fault-mode regime;
3. lower preprocessing freedom than mixed-condition / mixed-fault subsets;
4. cleaner first cross-domain anchor for a loss-only note than immediately
   jumping to heterogeneous subset mixtures.

The point is not that FD001 is the strongest benchmark. The point is:

```text
FD001 minimizes design freedom for the first C-MAPSS loss-only preregistration
```

That is the right priority at this stage of the program.

## 4. What This Choice Does And Does Not Mean

This choice means:

- the first C-MAPSS loss-only branch should start from FD001;
- any later move to FD002 / FD003 / FD004 should count as an explicit extension
  or separate preregistered follow-on;
- the first note can stay focused on one public degradation regime.

This choice does not mean:

- FD001 is the easiest subset in a theory-supporting sense;
- FD001 is guaranteed to pass a later preregistered primary;
- later heterogeneous subsets are unimportant.

## 5. Planned Structural Reading

The intended first structural reading for FD001 is:

| Benchmark field | Structural role |
|---|---|
| engine id | repeated unit |
| cycle | time index |
| sensor / setting trajectories | reduction-side / degradation covariates |
| RUL / run-to-failure target | future endpoint |
| repair events | absent, so \(r_t=0\) |

This keeps the branch explicitly loss-only.

## 6. Next Action

The next clean step is a later archive-feasibility pass on the exact FD001
bundle, recording:

1. local archive identity / hash;
2. exact row counts;
3. exact splitable target structure;
4. what target form the first frozen loss-only preregistration will use.

Only after that should a real C-MAPSS loss-only preregistration be drafted.
