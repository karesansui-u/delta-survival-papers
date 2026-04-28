# DeltaLint Software Operational Benchmark Note

Status: positioning note for the DeltaLint bench track. This is not evidence,
not a validation result, and not a collapse-prediction claim.

Date: 2026-04-28

## 1. Role

DeltaLint bench is a software operational benchmark candidate for structural
persistence theory.

It should not be described as direct evidence of software collapse, structural
death, or long-horizon maintainability failure. Its narrower role is:

```text
Can a structural-contradiction coordinate detect distributed-contract
inconsistencies better than matched generic review?
```

This is an early-signal detection test, not a collapse endpoint test.

## 2. Software Structure Definition

For the DeltaLint bench track, software structure is:

```text
the distributed contract set that must remain mutually consistent across code,
configuration, documentation, runtime behavior, tests, APIs, and dependent
callers.
```

A structure is not a single file. It is a relation among surfaces.

Examples:

- API definition and callers;
- config field and runtime use;
- serializer and deserializer;
- documentation and implementation;
- default-value producer and default-value consumer;
- lifecycle producer and lifecycle consumer;
- guard condition and downstream assumption;
- security boundary and exposed runtime surface.

## 3. Structural Contradiction Definition

A structural contradiction is a disagreement between two or more surfaces that
share a contract, invariant, protocol, or documented promise.

It must satisfy:

1. the referenced surfaces exist at the frozen commit;
2. the surfaces share a contract or invariant;
3. the surfaces disagree in a way that can affect behavior, security,
   maintainability, or documented correctness;
4. the divergence is not clearly intentional or explicitly supported;
5. the claim can be made from frozen evidence, not model speculation.

This excludes style-only comments, isolated local bugs, pure performance
opinions, and generic best-practice advice.

## 4. Theoretical Mapping

DeltaLint bench maps to the L-side / Route C surface:

| Structural persistence term | Software bench interpretation |
|---|---|
| maintained structure | distributed contract set |
| structural consumption | local inconsistency pressure that reduces coherent future modification paths |
| repair | propagation, synchronization, rollback, refactor, test update, documentation update, or other consistency-restoring work |
| accumulated balance | remaining contract coherence / ability to continue safe modification |
| failure endpoint | bug, stale documentation, broken lifecycle, security boundary mismatch, or maintenance trap |

The benchmark does not directly observe the endpoint "software collapse".
Instead, it tests whether a theory-derived coordinate can find earlier
distributed-contract contradictions.

## 5. Planned Comparison

The primary comparison is:

```text
same item
same frozen context packet
same provider / exact model
same timeout and one-pass policy
generic_review
vs
structural_lens_no_prior
```

The primary endpoint after blinded validation is:

```text
incremental unique valid structural root causes
```

Raw candidate count is descriptive only. Provider-to-provider comparison is not
the primary claim.

## 6. Support Boundary

If the benchmark passes, the safe claim is:

```text
The structural-contradiction coordinate adds operational detection power for
distributed software contract inconsistencies over matched generic review.
```

It would not yet support:

- DeltaLint predicts long-term software collapse;
- structural contradiction count is a complete maintainability measure;
- software validates the full structural persistence balance law;
- product / skills workflow value independent of the no-prior lens.

## 7. Later Collapse-Prediction Track

A direct software-collapse test would require a different longitudinal design,
for example:

- modules with more structural contradictions later produce more bug fixes,
  rollbacks, regressions, incident links, or change-lead-time growth;
- fixing structural contradictions reduces recurrence or future repair cost;
- architectural boundary violations predict future maintenance slowdown;
- stale docs / config-runtime mismatch / lifecycle mismatch predict real
  incidents or accepted fixes.

That later track is valuable, but it should be separated from the current
DeltaLint detection benchmark.

## 8. Current Treatment

DeltaLint bench is therefore:

```text
software operational benchmark candidate
early-signal structural contradiction detection
Route C / L-side extension
not M-supplement validation
not direct collapse evidence
not yet support until blinded validation and unblinding are complete
```
