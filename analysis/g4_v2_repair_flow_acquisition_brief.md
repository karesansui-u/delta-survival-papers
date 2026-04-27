# G4 v2 Repair-Flow Acquisition Brief

Status: acquisition brief only. Not a ranking note, not a freeze document, and
not validation evidence.

## 1. Purpose

The current G4 v2 bottleneck is no longer theoretical notation. It is data
acquisition.

The next useful dataset is not simply “maintenance-like data.” It must support
an operationally meaningful compensation flow \(g_t\) that can be frozen
before validation.

This brief is the one-page practical packet to hand to a partner, external
collaborator, or internal data owner when asking:

```text
Do you have a repair / maintenance log that is structurally strong enough for
G4 v2?
```

## 2. What We Need

A dataset is worth deeper discussion only if it plausibly contains all of the
following.

1. repeated units
   - machine, engine, component, service asset, repository asset, or another
     stable operational entity
2. timestamped intervention records
   - maintenance, replacement, service, patch, rollback, redundancy
     activation, inspection with confirmed restoration
3. preventive or scheduled repair class
   - at least one class defined before visible failure, not inferred from the
     future outcome
4. future endpoint
   - later failure, outage, degradation crossing, or other clearly defined
     future target
5. pre-intervention state variables
   - load, age, degradation, error count, stress indicator, backlog, anomaly
     score, or another damage-side observable
6. activity baseline
   - usage, event count, logging intensity, operating hours, or another
     exposure-like quantity

If any of these are missing, the dataset may still be useful as a weak-g or
loss-only control, but it is not a clean repair-flow primary candidate.

## 3. Minimum Metadata To Request Before Any Freeze

Before asking for raw rows, ask for these frozen metadata items.

### 3.1 Dataset identity

- dataset name or internal project identifier
- owner / steward
- access restrictions
- time span
- unit granularity

### 3.2 Schema summary

- table names
- field names
- timestamp fields
- unit identifier fields
- intervention / repair fields
- endpoint fields
- activity / exposure fields

### 3.3 Structural counts

- number of units
- approximate number of intervention events
- approximate number of future endpoint events
- timestamp resolution
- whether preventive and reactive classes are directly labeled

### 3.4 Reporting / auditability

- whether hashes can be recorded
- whether schema snapshots can be frozen
- whether execution logs can be archived
- whether an outside reader could audit the run at metadata level even if raw
  rows stay private

## 4. Non-Negotiable Exclusion Rules

Do not proceed toward preregistration if any of the following is true.

1. repair class would have to be inferred from overlap with future failures
2. the only endpoint is the repair event itself
3. timestamps are too weak to define blackout-safe lag windows
4. no stable repeated unit exists
5. intervention records are only free-text notes with no stable event table

These are not minor inconveniences. They are structural blockers.

## 5. What “Observable \(g_t\)” Means Here

For G4 v2, an observable compensation flow is stronger than “some repair-ish
column exists.”

The preferred situation is:

```text
unit i, at time u, received intervention class c, recorded before horizon
evaluation, under a schema that distinguishes preventive / scheduled action
from reactive response.
```

That is strong enough to freeze a candidate \(g_t\) definition later.

The weak situation is:

```text
we know failures happened and we can guess maintenance probably occurred
nearby.
```

That is not strong enough.

## 6. Requested Return Packet From A Potential Data Partner

Ask the data owner for a short response packet with:

1. one-paragraph domain description
2. schema summary
3. unit / time / intervention / endpoint field names
4. whether preventive vs reactive exists directly
5. rough counts for units, intervention events, and endpoint events
6. statement of any privacy or sharing constraints
7. statement of whether a later frozen audit trail is possible

This is enough to decide whether the candidate advances to a real freeze note.

## 7. What Happens Next If The Packet Looks Good

If a candidate passes this brief, the order is:

1. schema-feasibility note
2. dataset-specific prereg draft
3. frozen metadata / feature schema / split / evaluation script
4. one held-out primary run

Do not skip directly from “promising partner dataset” to validation.

## 8. One-Paragraph Ask Template

Use this wording when first contacting a partner or internal owner:

```text
We are looking for a repeated-unit maintenance or repair log where interventions
are timestamped, at least one preventive/scheduled repair class is labeled
before visible failure, a future failure or degradation endpoint exists, and
pre-intervention state plus a generic activity baseline are available. We do
not need raw data immediately. A schema summary, rough counts, and the field
names for unit, time, intervention, endpoint, and activity are enough for the
first screening step.
```

## 9. Why This Matters

The current program already has:

- a conditional law-side bridge at queueing / Foster-Lyapunov;
- a near-bridge repair / maintenance skeleton;
- loss-only observational anchors below repair-flow status.

What would change the picture is a dataset where \(g_t\) is not just a symbol
or a proxy, but a direct logged intervention variable that can be frozen before
validation.

That is the role of this brief.
