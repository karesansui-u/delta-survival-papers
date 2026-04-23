# Backblaze Loss-Only v2 Exploration Note

Status: exploration note only. Not a preregistration, not a freeze package,
not a dataset-ranking commit, and not validation evidence.

Date: 2026-04-23

## 1. Purpose

This note records what the program may legitimately learn from the closed
Backblaze Q4 2025 loss-only primary run, and what a clean Backblaze v2 should
look like if the same domain is retried on a new untouched archive.

It has two jobs:

1. backward-facing: fix the interpretation of the Q4 2025 no-support result;
2. forward-facing: sketch a v2 design without rescuing the closed primary.

This note does **not** reopen the Q4 2025 result. It does **not** authorize a
new run. It does **not** choose the next archive. Those steps require a fresh
preregistration and freeze package.

## 2. What Is Already Fixed

The following facts are closed and must not be renegotiated:

```text
Backblaze Q4 2025 primary status:
  closed, frozen, run once

Primary result:
  no support under the frozen primary metric

Primary report:
  analysis/backblaze_loss_only/primary_report.md
```

The program-level and run-level statements are both true:

| Level | Current statement |
|---|---|
| Program level | G4 non-CSP empirical remains exploratory overall |
| Run level | Backblaze Q4 2025 loss-only primary is closed and no-support |

This is not a contradiction. It is a difference in grain size.

## 3. What Q4 2025 Actually Showed

The frozen Q4 2025 run produced the following pattern:

| Quantity | Result |
|---|---:|
| best baseline log loss | `0.157102` (`B3_exposure`) |
| primary SMART log loss | `1.779176` |
| primary SMART AUC | `0.902456` |
| H2 sign consistency | failed |

The most important separation is:

```text
signal present, calibration poor
```

The Q4 2025 run therefore supports the following diagnostic reading:

- lagged SMART features carry strong failure-ranking signal;
- the frozen weighted streaming-logistic implementation produced poorly
  calibrated probabilities on the held-out test block;
- the primary loss-only support claim failed because the primary metric was log
  loss, not ranking quality.

This diagnostic is **not** a rescue of the primary result. It is exploration
input for possible v2 design.

## 4. Working Diagnosis For v2 Design

The current working diagnosis is:

```text
the dominant failure mode was calibration mismatch, not signal absence
```

More precisely:

- the test environment is ultra-imbalanced;
- the Q4 2025 frozen design used aggressive class weighting;
- the model family was a streaming L2-regularized logistic approximation;
- the resulting probabilities were too extreme on many negative rows;
- `smart_199_raw` also violated the frozen sign rule.

The key nuance is:

```text
rare events were the context, but class-weight choice was the direct driver
of the calibration mismatch
```

This distinction matters because it points v2 toward calibration repair rather
than away from the domain itself.

## 5. Boundary Line: What May Be Reused From Q4 2025

The v2 design may reuse **qualitative** lessons from Q4 2025. It may not
import performance-tuned values from Q4 2025 validation or test outcomes.

Allowed carry-over:

- the qualitative diagnosis that AUC and log loss separated sharply;
- the lesson that calibration should be treated as first-class design
  structure;
- the lesson that same-domain retry requires a new untouched archive;
- the observation that `smart_199_raw` deserves domain scrutiny before reuse.

Not allowed:

- reuse the Q4 2025 test block for new validation;
- fit a calibrator on Q4 2025 validation or test outputs and transfer its
  parameters into v2;
- choose v2 hyperparameters by reverse-engineering Q4 2025 validation or test
  scores;
- change the primary metric after the Q4 2025 no-support result;
- report Q4 2025 AUC as if it overturned the frozen log-loss decision.

Equivalent summary:

```text
Q4 2025 provides qualitative design lessons, not quantitative tuning values.
```

## 6. Recommended v2 Design Direction

The cleanest v2 direction is:

```text
same domain, new untouched archive, calibration-aware loss-only design
```

Recommended default design sketch:

1. keep the evidence tier fixed as loss-only observational support;
2. keep the primary endpoint calibration-sensitive rather than switching to a
   ranking-only metric;
3. add an explicit calibration stage inside the new archive design;
4. keep the test block untouched until the frozen primary run.

The most defensible primary technical fix is:

```text
Platt scaling or another precommitted calibration step
```

Reason:

- it directly targets the observed failure mode;
- it does not require retroactively redefining success as AUC-only;
- it preserves the distinction between ranking and probability calibration;
- it is a standard ML repair for exactly this kind of gap.

By contrast:

- removing class weights may help, but it is a less direct response and may
  trade calibration problems for recall collapse;
- changing the primary metric to AUC or AUPRC would look like goalpost shift;
- dropping one SMART variable alone does not address the main calibration
  failure.

Therefore the provisional design preference is:

```text
v2 should treat calibration repair as the primary design change.
```

## 7. smart_199 Handling Rule

`smart_199_raw` was the only SMART coefficient to violate the frozen H2 sign
rule in Q4 2025. This creates a legitimate v2 design question, but not a
post-hoc license to drop it for performance reasons.

If v2 excludes `smart_199_raw`, the exclusion must be justified as:

- a domain-grounded precommitment based on external documentation or accepted
  interpretation of UDMA CRC errors as interface / cable phenomena rather than
  direct drive-internal degradation; and
- a decision written before any v2 archive performance inspection.

Not allowed:

```text
exclude smart_199 because it made Q4 2025 H2 fail
```

Allowed framing:

```text
exclude smart_199 if external domain knowledge shows it is not part of the
same degradation semantics as the other SMART fields
```

If that external rationale is not available or not strong enough, the cleaner
default is to keep `smart_199_raw` and let H2 test it again.

## 8. New Archive Selection Protocol

Backblaze v2 must use a new untouched archive. The archive must be selected by
metadata-only criteria before any predictor performance inspection.

This note does not rank the archives yet. It fixes the selection protocol:

1. assemble a candidate list of untouched quarterly archives;
2. record only metadata-level facts for each candidate:
   - archive identity / URL;
   - date span;
   - schema compatibility;
   - required SMART field availability;
   - row count;
   - failure-row count floor for the intended horizon;
   - operational feasibility (download size / environment tractability);
3. rank candidates using only those metadata-level facts;
4. choose the first eligible candidate as the v2 primary archive;
5. commit that ranking before any v2 modeling or predictor-level inspection.

Suggested candidate pool order for later ranking:

1. the nearest forward untouched quarter after Q4 2025, if publicly available;
2. the nearest earlier untouched quarter with compatible schema;
3. the next earlier compatible quarter.

The exact candidate list must be written in a later archive-ranking note or
preregistration support note. This file only fixes the protocol.

## 9. Evidence-Tier Discipline

Even if Backblaze v2 passes, its evidential status must remain:

```text
loss-only observational support in the same domain, not repair-flow support
```

Additional caution:

```text
Backblaze v2 would be a second attempt in the same domain after one closed
no-support run
```

Therefore even a passing v2 should be reported conservatively:

- as support for a revised operational design in the Backblaze loss-only
  domain;
- not as retroactive proof that the v1 no-support result was irrelevant;
- not as a standalone universal non-CSP empirical victory;
- not as G4 v2 repair-flow completion.

## 10. Non-claims

This note does not claim:

1. that Q4 2025 was secretly supportive because AUC was high;
2. that the structural balance law was falsified by Q4 2025;
3. that Backblaze v2 will pass;
4. that Platt scaling is already chosen or frozen;
5. that `smart_199_raw` will be excluded;
6. that a specific new archive has already been selected;
7. that a same-domain second attempt has the same evidence weight as a
   first-pass success.

## 11. Clean Next Sequence

The next clean sequence is:

```text
1. Backblaze v2 exploration note (this file)
2. fresh session
3. archive-ranking note or prereg support note
4. Backblaze v2 preregistration draft
5. freeze on a new untouched archive
6. one new primary validation run
```

This note should be read as:

```text
Q4 2025 is closed.
Backblaze v2 is allowed.
Backblaze v2 must start from a new archive and a new freeze.
```
