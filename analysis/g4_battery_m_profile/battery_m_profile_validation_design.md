# Battery M-Profile Predictive Validation Design

Status: design note only. Not frozen. Not validation evidence.

Date: 2026-04-28

## 1. Purpose

This branch tests whether the M-side component decomposition has predictive
value in a non-software, non-CSP physical degradation domain.

The first validation target should be predictive, not causal:

```text
domain baseline + battery M/SP features > domain baseline
```

The branch should not begin with an intervention-ranking claim. Intervention
ranking is a later, harder target after the M profile is shown to have
incremental out-of-sample predictive value.

## 2. Why Battery Data

Battery degradation is a good Route C / non-CSP branch because it has:

- repeated units: cells or packs;
- a natural time index: cycle number, test time, or usage segment;
- a natural maintained structure: usable capacity / safe energy delivery;
- a natural degradation endpoint: capacity fade, EOL, RUL, or future capacity
  drop;
- controlled operating protocols: charge rate, discharge profile, rest /
  calendar aging, temperature, load changes, recommissioning / second-life
  assembly in some archives.

This makes battery data stronger than many public repair-flow datasets, where
direct intervention logs are often absent or leakage-prone.

## 3. Theory Mapping

### Maintained structure

The maintained structure \(F\) is:

```text
the cell or pack remains capable of delivering usable capacity under the
specified operating protocol.
```

For the first branch, this should be operationalized as one of:

- future capacity after a fixed horizon;
- future capacity drop over a fixed horizon;
- cycles-to-threshold / RUL;
- binary EOL-before-horizon.

### Structural consumption side

The consumption / loss-side features describe how much the battery is being
structurally stressed.

Candidate features:

- cycle count or elapsed test time;
- cumulative throughput;
- average / peak C-rate;
- depth-of-discharge or voltage-window severity;
- temperature exposure;
- impedance increase;
- early capacity fade slope;
- voltage-curve deformation features.

These are not yet M features. They are the battery-domain analog of \(L\) /
\(\hat L\) / degradation-side coordinates.

### M-side features

The battery M-side should be defined cautiously. Unlike software, a battery
does not usually have discrete repair events. Therefore the first branch should
interpret M as operational maintenance capacity or mitigation structure, not
literal repair.

| M component | Battery reading | Candidate signals |
|---|---|---|
| \(M_{\mathrm{buffer}}\) | remaining margin before unacceptable degradation | initial capacity margin, voltage margin, temperature margin, EOL distance, lower stress headroom |
| \(M_{\mathrm{recovery}}\) | reversible relaxation / restoration-like response | voltage relaxation after rest, capacity rebound after rest/diagnostic cycle, impedance relaxation proxies |
| \(M_{\mathrm{reconfiguration}}\) | protocol or usage-structure change preserving the target function | change in load protocol, calendar/cyclic order, fast/slow charge switch, second-life/recommissioned pack structure |

The branch should explicitly avoid saying that \(M_{\mathrm{recovery}}\)
means a repaired electrochemical structure unless the dataset directly supports
that interpretation. The safer wording is:

```text
recovery-like reversible response or relaxation signal
```

## 4. Primary Predictive Question

The primary question:

```text
After freezing a battery M/SP feature set, does adding those features to a
strong battery-domain baseline improve out-of-sample prediction of future
capacity / EOL / RUL?
```

This is a prediction test, not a universal-law test and not an intervention
ranking test.

## 5. Baseline Ladder

The baseline ladder should be fixed before primary evaluation.

Suggested minimum ladder:

| Model | Feature family | Role |
|---|---|---|
| B0 | train-set mean / class prior | trivial baseline |
| B1 | cycle index / elapsed time only | age baseline |
| B2 | age + protocol metadata | domain baseline |
| B3 | age + protocol metadata + standard battery degradation features | strong domain baseline |
| Primary | B3 + frozen M/SP features | incremental structural-persistence test |

For datasets where standard voltage-curve features are the known strong
domain baseline, B3 must include those features. The primary model should not
win merely by reintroducing domain-native predictors under new names.

## 6. Candidate Endpoints

The best endpoint depends on the dataset.

| Endpoint | Use when | Metric |
|---|---|---|
| future capacity after horizon \(H\) | per-cycle capacity measurements exist | RMSE / MAE |
| future capacity drop over horizon \(H\) | capacity trajectory is stable enough | RMSE / MAE |
| EOL-before-horizon | enough cells cross threshold | log loss / AUC as secondary |
| cycle life / RUL | full run-to-failure available | log-cycle-life RMSE or MAE |

The first branch should prefer continuous future capacity or log-cycle-life
prediction over a rare binary endpoint unless the dataset has enough failures.

## 7. Split Discipline

The branch must split by cell or pack, not by rows or cycles.

Allowed split:

```text
train cells / calibration cells / held-out test cells
```

Disallowed split:

```text
cycles from the same cell appear in both train and test
```

If the dataset has too few cells for a stable held-out split, the branch should
be classified as feasibility or weak validation, not primary support.

## 8. Success Criteria

The primary support rule should be strict but not unrealistic.

Suggested primary rule for regression:

```text
primary_metric(B3 + M/SP) <= 0.95 * primary_metric(B3)
```

where smaller is better.

Suggested support tiers:

| Tier | Rule |
|---|---|
| strong support | primary improves B3 by at least 5% and improvement is stable across held-out protocol/cell groups |
| weak support | primary improves B3 by 1-5% without violating direction / leakage guardrails |
| no-support | primary does not improve B3 |
| silence | dataset cannot define M/SP features before outcome inspection, or split is too small/leaky |

## 9. Intervention Ranking Is Later

The later intervention-ranking branch would ask:

```text
Given a frozen M profile, can we predict which protocol family should improve
future degradation most?
```

Battery-specific examples:

- high stress but strong relaxation response: rest / relaxation-aware protocol
  may outrank simple capacity-margin expansion;
- low buffer margin but otherwise stable protocol: stress reduction /
  narrower operating window may outrank rest scheduling;
- strong path dependence: protocol-order redesign may outrank equal total
  throughput reduction.

This should not be the first primary validation because it is closer to causal
or protocol-design evidence.

## 10. Simulation Layer

PyBaMM can be used before real-data freeze to test pipeline mechanics:

- generate controlled degradation trajectories;
- vary protocol, C-rate, temperature, rest, and degradation assumptions;
- check whether the M/SP feature extraction code behaves as expected;
- produce synthetic sanity tests where the ground-truth bottleneck is known.

But simulation support is not empirical support. It should be labeled:

```text
mechanistic sanity / pipeline validation
```

not:

```text
real battery evidence
```

## 11. Non-Claims

This branch does not claim:

1. batteries are Route A systems;
2. battery \(M_{\mathrm{recovery}}\) is literal repair;
3. PyBaMM simulation is empirical validation;
4. protocol metadata alone proves intervention ranking;
5. the first dataset that works establishes a universal M law;
6. no-support would refute the theory core.

No-support would mean:

```text
the frozen battery M/SP mapping did not add predictive value on that dataset.
```

Silence would mean:

```text
the dataset did not allow a clean M/SP mapping or non-leaky held-out test.
```

## 12. Current Concrete Move

The original next move was to open an exact feasibility note for Oxford Path
Dependent or NASA Randomized/Recommissioned. That step has now advanced for
Oxford through feasibility, Part 1 identity, parser/RPT structure counts,
freeze-manifest draft, metadata/train-smoke, and a MATLAB conversion packet.

The current next move is:

```text
run the Oxford Part 1 training-conversion runner in a MATLAB environment,
then use the converted training schema plus public guide information to fix
endpoint and feature field paths before any held-out conversion.
```

If Oxford fails this conversion / schema-fix stage, NASA Randomized/
Recommissioned remains the second exact-feasibility candidate. Any replacement
feasibility note should record:

- exact archive URL / DOI;
- file list and hashes if downloaded;
- cell / pack counts;
- available protocol metadata;
- capacity / EOL endpoint availability;
- whether cell-level held-out validation is possible;
- whether M_buffer / M_recovery / M_reconfiguration can be defined before
  primary outcome inspection.
