# G4 C-MAPSS Loss-Only Feasibility Note

Status: feasibility note only. Not frozen. Not validation evidence. Not
repair-flow evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_v2_dataset_scan_candidates.md`
- `analysis/open_gates_execution_plan.md`

Purpose:

Evaluate whether NASA C-MAPSS is a clean next candidate for a cross-domain
non-CSP loss-only anchor. This note does not inspect model performance,
predictor rankings, threshold values, or any theory-support outcome. It only
asks whether the benchmark has enough public structure to support a later
frozen loss-only design.

## 1. Source Identity

Canonical source family:

- NASA Open Data landing page:
  <https://data.nasa.gov/dataset/cmapss-jet-engine-simulated-data>
- Common benchmark mirrors package the data as the standard `FD001`-`FD004`
  train / test / RUL files.

Benchmark character:

```text
simulated turbofan degradation benchmark, not a live maintenance log
```

That matters for evidence weight. A later successful primary on C-MAPSS would
count as a cross-domain non-CSP loss-only support tier, but not as repair-flow
support and not as a live operational-log replication of Backblaze.

## 2. Inspection Boundary

Allowed in this note:

1. public source identity and benchmark role;
2. unit / time / degradation / endpoint structure;
3. whether a later frozen split can be defined cleanly;
4. whether the dataset is loss-only or repair-flow.

Not inspected in this note:

1. predictor performance;
2. model comparisons;
3. subset-specific accuracy or RUL metrics;
4. any post-hoc feature selection;
5. any claim that C-MAPSS already supports the theory.

## 3. Structural Facts

At the benchmark-design level, C-MAPSS has the following clean structure:

| Field | Structural reading |
|---|---|
| repeated unit | engine |
| time index | flight cycle |
| loss / degradation side | operating settings and sensor trajectories over cycles |
| endpoint | run-to-failure in training; held-out test units with provided RUL targets |
| recovery amount | absent |

The benchmark is therefore naturally legible as:

```text
unit-level degradation over time with a future failure / remaining-life target
and no direct recovery amount r_t
```

This makes it a good fit for a loss-only anchor and a poor fit for a G4 v2
repair-flow pilot.

## 4. Why C-MAPSS Is Loss-Only, Not Repair-Flow

The central boundary is simple:

```text
C-MAPSS engines degrade; they are not maintained inside the benchmark.
```

There is no direct table or variable corresponding to:

- preventive maintenance;
- scheduled replacement;
- reactive repair;
- rollback / redundancy activation;
- any other explicit \(r_t\) event.

For a structural-persistence balance reading, the correct operational interpretation is:

\[
r_t = 0
\]

for the benchmarked trajectories.

So C-MAPSS can support:

```text
loss-only non-CSP degradation / endpoint prediction
```

and cannot support:

```text
repair-flow / maintenance-flow empirical validation
```

## 5. Feasibility For A Later Frozen Design

At the metadata-only level, C-MAPSS appears feasible for a later frozen
cross-domain loss-only study because it provides:

1. repeated units;
2. a clear monotone time axis;
3. dense degradation signals;
4. a standard future endpoint family;
5. public and reproducible benchmark access.

The clean later-freeze question is not "can we define \(r_t\)?" but:

```text
Can a preregistered loss-only coordinate outperform simple raw / exposure /
metadata baselines on a held-out turbofan degradation target?
```

That is exactly the right kind of question for a cross-domain non-CSP loss-only
anchor.

## 6. Evidence-Tier Caveat

C-MAPSS would broaden domain coverage beyond drive reliability, but it still
comes with an important caveat:

```text
benchmark simulation is not the same thing as a live operational log
```

Therefore, even a successful later primary should be reported as:

```text
cross-domain non-CSP loss-only support on a public degradation benchmark
```

not as:

```text
repair-flow support, live maintenance-log support, or universal-law closure
```

## 7. Feasibility Verdict

```text
Cross-domain non-CSP loss-only anchor: feasible
G4 v2 repair-flow primary candidate: not feasible
```

More explicitly:

- feasible because unit / time / degradation / endpoint structure is clean;
- not repair-flow because no direct recovery or maintenance events exist;
- useful because it adds a domain very different from drive reliability while
  staying honest about the loss-only boundary.

## 8. Next Action

If the program wants a next cross-domain non-CSP empirical move, the clean
sequence is:

1. choose the exact C-MAPSS archive / subset in a separate metadata-only note;
2. write a loss-only preregistration that fixes target, split, model class,
   and baseline family before any performance inspection;
3. keep the evidence tier explicitly below repair-flow and below Route A
   randomized primaries.

This note does not perform step 1 yet. It only records that C-MAPSS is a
legitimate next loss-only candidate and should not be mislabeled as a repair
dataset.
