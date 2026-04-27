# G4 v2 Repair-Flow Candidate Criteria

Status: gate-definition memo only. Not a dataset-ranking commit, not a freeze
document, and not validation evidence.

Date: 2026-04-27

Purpose:

Record the minimum criteria a future G4 v2 repair-flow dataset must satisfy
before it can even be ranked for freeze. This memo is a response to the current
public-scan pattern:

- C1 Azure PdM: repeated units exist, but repair class requires
  failure-overlap inference;
- C2 MetroPT-3: real operational time series exists, but repeated-unit and
  repair-event structure are too weak;
- C3 Backblaze: excellent loss-only panel, but no recovery amount.

So the problem is no longer "we have not looked yet". It is:

```text
clean public repair-flow datasets are structurally scarce
```

This memo defines the gate any future candidate must pass.

## 1. Phase Boundary

This memo does not:

1. rank actual datasets;
2. choose a primary dataset;
3. freeze a pilot;
4. claim support or no-support for the theory.

It only says what a later candidate must contain before a real ranking or
freeze is even allowed.

## 2. Hard Eligibility Gate

A candidate dataset must satisfy all of the following to qualify as a possible
G4 v2 repair-flow primary.

### Criterion 1. Stable repeated unit

There must be a repeated prediction unit such as:

- machine;
- engine;
- component;
- account / service asset;
- repository / project asset;
- other stable operational entity.

Single-system traces may still be useful as weak-g controls, but they are not
clean primary repair-flow candidates.

### Criterion 2. Cutoff-safe timestamps

The dataset must support a clean prediction cutoff \(t\) and a future horizon
\((t, t+H]\) without using future information in feature construction.

At minimum, the dataset needs:

- time-stamped past state / event records;
- a future failure / degradation endpoint;
- enough temporal resolution to define lagged windows.

### Criterion 3. Direct reduction-side observables

There must be plausible \(d_t\) / \(d_t\)-side variables such as:

- load;
- degradation;
- error count;
- stress indicator;
- backlog;
- anomaly score;
- damage proxy.

These do not need to be perfect causal measures, but they must be directly
observed rather than reconstructed from future outcomes.

### Criterion 4. Direct repair / recovery events

There must be directly observed candidate \(r_t\) events such as:

- maintenance;
- replacement;
- service;
- patch / rollback;
- redundancy activation;
- inspection plus confirmed restoration.

If \(r_t\) would have to be inferred from proximity to failure, the dataset
fails the primary gate.

### Criterion 5. Pre-failure repair-class distinction

At least one repair class must be identifiable before visible failure, for
example:

- preventive;
- scheduled;
- non-reactive replacement;
- another class defined independently of the outcome window.

The crucial rule is:

```text
repair class must be defined without consulting future failure labels
```

This is the central protection against leakage.

### Criterion 6. Future endpoint

There must be a later outcome that can serve as the prediction target, such as:

- future failure;
- future incident;
- future degradation crossing;
- future RUL threshold event.

If the only available "endpoint" is the repair event itself, the dataset is
not suitable for a repair-flow predictive validation.

### Criterion 7. Activity baseline

The dataset must support at least one generic exposure / activity baseline,
such as:

- telemetry coverage;
- event count;
- operating hours;
- logging intensity;
- prior intervention count;
- unit age or usage burden.

This is needed to separate recovery-aware signal from mere "high activity"
confounding.

### Criterion 8. Reproducible reporting path

The candidate must support one of:

1. public reproducible access; or
2. a private-data reporting plan with enough frozen metadata, hashes, schema,
   and execution logs that an outside reader can audit what was run.

Without this, the dataset may still be useful internally, but it is weak as a
program-level anchor.

## 3. Automatic Failure Modes

Any one of the following is enough to keep a dataset out of the primary
repair-flow lane:

1. repair class is inferred only from overlap with future failures;
2. no repeated unit exists;
3. no future endpoint exists;
4. all repair events are effectively the outcome itself;
5. timestamps are too weak to define blackout-safe windows;
6. repair events are only sparse free-text annotations with no stable event
   table.

These failure modes do not make a dataset useless. They only demote it to
another tier.

## 4. Tier Classification After The Gate

Once a dataset is screened, it should be placed into one of four tiers.

| Tier | Meaning |
|---|---|
| repair-flow primary candidate | passes all hard criteria above |
| weak-g control | has real operational structure but recovery amount is too sparse / reactive / single-system |
| loss-only control | has unit, time, degradation, endpoint, but effectively \(r_t=0\) |
| leakage-risk / ineligible | fails by inferred repair class, no endpoint, or no usable unit/time structure |

This tiering is deliberately conservative.

## 5. What Would Count As A Good Future Dataset

The best future G4 v2 repair-flow dataset would look like:

```text
repeated units + time-stamped degradation + direct preventive/scheduled repair
events + future failure endpoint + activity baseline + reproducible access
```

That could be:

- a maintenance fleet log;
- a service / incident platform with stable assets and non-reactive
  interventions;
- a local or partner operational dataset with frozen reporting discipline.

This memo does not say such a dataset already exists in public form.

## 6. Non-Claims

This memo does not claim:

1. public repair-flow support is impossible;
2. C1, C2, or C3 were mistakes to inspect;
3. loss-only anchors are enough for G4 v2 as a whole;
4. a private dataset would automatically be stronger than a public one;
5. a candidate that passes these criteria will necessarily support the theory.

It claims only:

```text
future G4 v2 repair-flow work should be judged against an explicit structural
gate rather than by ad hoc enthusiasm for whichever dataset happens to be
available.
```
