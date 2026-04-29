# DeltaLint Software Operational Benchmark Note

Status: positioning, field-demonstration, and internal-calibration note for the
DeltaLint bench track. This includes maintainer-acceptance field evidence and a
bounded internal benchmark, but it is not a raw precision / recall estimate, not
outside replication of the benchmark, and not a collapse-prediction claim.

Date: 2026-04-29

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

The primary endpoint after bounded validation is:

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

The first internal Product-arm calibration now supplies a bounded version of
this claim: five frozen OSS items, four items with positive Product-additive
gain, one item with no Product-specific additive gain, and nine credited
Product-additive `valid_structural` roots under the same-scope/additive rule.

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

## 8. Field Demonstration Layer

Before the bounded benchmark track, DeltaLint was used as an operational
workflow in public OSS. In mid-March 2026, over roughly two weeks, the workflow
produced 39 submitted PRs and 26 reported issues. Sixteen PRs across twelve
public repositories were merged, including projects under Microsoft, Facebook,
Bytedance, Sentry, coder, and tRPC. Fourteen of the current sixteen primary
merged PRs were submitted during a roughly 69-hour window from 2026-03-15 to
2026-03-18, about 4.9 hours per PR on average.

This is not a no-cut detector evaluation. It mixes candidate selection,
maintainer culture, issue priority, patchability, PR strategy, Claude Code
assistance, and human reproduction / communication. It should therefore not be
used as a raw precision / recall result, a tool-superiority benchmark, or a
software-collapse prediction.

Its narrower value is field demonstration / maintainer-acceptance evidence:
the workflow generated distributed-contract contradiction candidates that could
be reproduced, patched, submitted, and accepted by maintainers under existing
project review standards.

Representative merged PRs:

| Repository | Merged PR(s) | Structural contradiction captured |
|---|---|---|
| `microsoft/playwright` | `#39744` | `quality: 0` was treated as falsy and diverged from upstream `quality ?? 80` default semantics |
| `microsoft/fluentui` | `#35877` | slot `onChange` was overwritten instead of merged, violating sibling component contract |
| `facebook/lexical` | `#8235` | `getWritable()` return value was ignored, breaking the immutability protocol |
| `bytedance/deer-flow` | `#1161`, `#1162`, `#1163` | Makefile target names, process termination, and help text diverged |
| `promptfoo/promptfoo` | `#8163`, `#8165`, `#8182` | valid boundary values such as `0`, `null`, and `"0"` were treated as unspecified |
| `getsentry/sentry` | `#110504` | `datetime.replace()` return value was discarded, so the UTC assumption was not applied |
| `coder/code-server` | `#7709` | login UI exposed a config-file path unnecessarily |
| `trpc/trpc` | `#7262` | streaming-batch error handling for calls after the first reused the first call context |
| `D4Vinci/Scrapling` | `#201` | retry preparation destructively changed request kwargs and lost the HTTP method |
| `abhigyanpatwari/GitNexus` | `#350` | documented relation type was absent from the allowlist and silently dropped |
| `openclaw/openclaw` | `#47488` | webhook mode did not propagate into the runtime snapshot, invalidating stale checks |
| `labstack/echo` | `#2925` | rate-limiter default documentation remained stale after implementation change |

Additional field outcomes include two issue-induced merged fixes, four security
vulnerability reports, one rejected PR, and a third-place result at AGI Lab
Hackathon 2026 at GMO Yours. These are descriptive operational outcomes, not
primary endpoints for the benchmark.

## 9. Current Treatment

The internal Product-arm calibration through 2026-04-29 is:

| item | Product-additive validated roots | treatment |
|---|---:|---|
| Formbricks | 0 | valid root, but no Product-specific additive gain over same-scope generic |
| Flask | 1 | positive internal additive calibration |
| httpx | 2 | positive internal additive calibration with partial static/test caveat |
| Chi | 4 | positive internal additive calibration against completed Go static/test and prompt-pair baselines |
| Traefik | 2 | positive internal additive calibration over same-scope generic; frontend static baseline open |

Aggregate:

```text
items_total: 5
items_with_product_additive_gain: 4
items_without_product_additive_gain: 1
credited_product_additive_roots_total: 9
```

DeltaLint bench is therefore:

```text
field demonstration / maintainer-acceptance evidence
initial internal software operational support
early-signal structural contradiction detection
Route C / L-side extension
not M-supplement validation
not direct collapse evidence
not raw precision / recall
not outside replication of the bounded benchmark
```
