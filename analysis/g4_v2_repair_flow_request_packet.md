# G4 v2 Repair-Flow Request Packet

Status: request packet only. Not a freeze document, not a ranking note, and not
validation evidence.

## 1. Purpose

This packet is the send-ready version of
`analysis/g4_v2_repair_flow_acquisition_brief.md`.

Its job is simple:

```text
ask a partner, collaborator, or internal data owner whether they have a
maintenance / repair log strong enough for a future G4 v2 repair-flow pilot
```

It is intentionally lighter than a preregistration. The first step is schema
and metadata screening only.

## 2. One-Paragraph Request

Suggested subject line:

```text
Schema-only question about maintenance / repair log feasibility
```

Use this short version when first contacting a data owner:

```text
We are looking for a repeated-unit maintenance or repair log where interventions
are timestamped, at least one preventive or scheduled repair class is labeled
before visible failure, a future failure or degradation endpoint exists, and
pre-intervention state plus a generic activity baseline are available. We do
not need raw data immediately. A schema summary, rough counts, and the field
names for unit, time, intervention, endpoint, and activity are enough for the
first screening step.
```

## 3. Longer Cover Note

Use this version if the recipient needs more context:

```text
We are screening candidate maintenance / repair datasets for a future
prediction study on structure maintenance and collapse risk. The first step is
not model training and not data transfer. We only need enough metadata to judge
whether the dataset contains stable repeated units, time-stamped interventions,
at least one preventive or scheduled repair class defined before visible
failure, a future failure or degradation endpoint, pre-intervention state
variables, and a generic activity baseline. If those conditions hold, the next
step would be a later frozen schema and evaluation plan. If they do not hold,
the dataset may still be useful as a weaker control, but we would not treat it
as a repair-flow primary candidate. Raw data are not needed at this stage.
```

## 4. Minimum Metadata Packet To Request

Ask for the following only.

### 4.1 Dataset identity

- dataset or project name
- owner / steward
- access restrictions
- time span
- unit granularity

### 4.2 Schema summary

- table names
- field names
- timestamp fields
- unit identifier fields
- intervention / repair fields
- endpoint fields
- activity / exposure fields

### 4.3 Structural counts

- number of units
- approximate number of intervention events
- approximate number of future endpoint events
- timestamp resolution
- whether preventive and reactive classes are directly labeled

### 4.4 Auditability

- whether hashes can later be recorded
- whether schema snapshots can be frozen
- whether execution logs can be archived
- whether a metadata-level audit trail is possible even if raw rows remain
  private

## 5. What Counts As A Good Candidate

The target structure is:

```text
repeated units + time-stamped intervention events + direct preventive or
scheduled class + future endpoint + pre-intervention state + activity baseline
```

Examples of repeated units:

- machines
- engines
- components
- service assets
- repositories or deployment assets

Examples of intervention classes:

- preventive maintenance
- scheduled replacement
- service action
- patch / rollback
- redundancy activation
- inspection with confirmed restoration

Examples of future endpoints:

- later failure
- outage
- degradation threshold crossing
- severe regression after the cutoff

## 6. Automatic No-Go Conditions

Do not advance the dataset toward preregistration if any of these holds.

1. repair class would have to be inferred from overlap with future failures
2. the only endpoint is the repair event itself
3. timestamps are too weak to define blackout-safe lag windows
4. no stable repeated unit exists
5. intervention records are only free-text notes with no stable event table

## 7. Return Format

Ask the data owner to reply with:

1. one-paragraph domain description
2. schema summary
3. unit / time / intervention / endpoint field names
4. whether preventive vs reactive exists directly
5. rough counts for units, interventions, and endpoints
6. privacy or sharing constraints
7. whether a later frozen audit trail is possible

This is enough to decide whether the candidate deserves a real feasibility note.
Raw rows are not needed for this first screening step.

## 8. Why This Packet Exists

The current program already has:

- queueing / Foster-Lyapunov as the strongest current law-side bridge;
- repair / maintenance as a near-bridge open-system anchor;
- public loss-only anchors below repair-flow status.

What it still lacks is a directly logged empirical \(g_t\) that can be frozen
before validation.

That is why this packet exists.
