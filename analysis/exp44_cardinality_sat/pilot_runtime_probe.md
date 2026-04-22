# Exp44 pilot runtime probe

Status: partial exploratory runtime probe, not a completed pilot and not
validation evidence.

Date: 2026-04-23

## 1. Context

The Exp44 pilot was started with `config/pilot_config.json`:

```text
n in {80, 120}
rho_fm in {0.70, 0.85, 1.00, 1.15}
mixtures = M0_low, M1_low_med, M2_bal_low_med,
           M3_threeway_low, M4_threeway_med, M5_med_high
instances_per_cell = 50
timeout = 120 seconds
```

The run was intentionally stopped before completion after the first substantial
runtime bottleneck appeared. This is exploration / pilot calibration. It is not
a primary result.

Raw JSONL data remain in `analysis/exp44_cardinality_sat/data/`, which is
gitignored.

## 2. Partial run summary

At interruption:

```text
records completed: 259 / 2400
SAT: 203
UNSAT: 56
TIMEOUT: 0
MALFORMED: 0
SAT assignment_verified: 203 / 203
max runtime: 95.51 seconds
```

Completed or partially completed cells:

| mixture | n | rho_fm | records | SAT | UNSAT | avg runtime | max runtime |
|---|---:|---:|---:|---:|---:|---:|---:|
| M0_low | 80 | 0.70 | 50 | 50 | 0 | 0.06s | 0.08s |
| M0_low | 80 | 0.85 | 50 | 50 | 0 | 0.09s | 0.36s |
| M0_low | 80 | 1.00 | 50 | 3 | 47 | 0.37s | 0.66s |
| M0_low | 120 | 0.70 | 50 | 50 | 0 | 0.07s | 0.09s |
| M0_low | 120 | 0.85 | 50 | 50 | 0 | 2.20s | 16.74s |
| M0_low | 120 | 1.00 | 9 | 0 | 9 | 66.82s | 95.51s |

## 3. Interpretation

The harness is still infrastructure-clean:

```text
0 timeout
0 malformed encoding
all SAT assignments verified semantically
```

The blocker is practical runtime concentration in the `M0_low` pure
at-least-one-4-SAT cell near the first-moment boundary at `n=120`.

This is not evidence against the Exp44 hypothesis. The run did not enter
validation and did not complete the pilot gate. It is calibration feedback that
the pilot design needs a runtime guard before freeze.

## 4. Consequence for the draft design

The original pilot criteria only included timeout-rate suspension. This probe
shows that a cell can be below the hard timeout while still making the pilot
impractically slow.

Therefore the preregistration draft should include a runtime guard before any
future pilot or freeze:

```text
If a pilot cell has median runtime > 30 seconds
or at least 20% of completed instances have runtime > 60 seconds,
then the pilot grid is considered runtime-unstable.
```

Recommended fallback for this specific pattern:

```text
reduce n grid from {80, 120} to {60, 100}
or exclude the pure M0_low cell from the primary mixture grid and retain it
only as a diagnostic reference.
```

The first option is more conservative because it preserves the mixture family.
The second option should be used only if `M0_low` remains a runtime bottleneck
at `n=100`.

## 5. Next step

Do not resume the current 2,400-instance pilot as-is.

Next recommended action:

```text
revise the Exp44 draft with an explicit runtime guard,
create a pilot_v2 config using n in {60, 100},
then run pilot_v2 as exploration.
```

Primary validation remains prohibited until the revised pilot passes and the
freeze checklist is completed.
