# Pre-registered Prediction: Knowledge Anchor vs Recency

Date: 2026-04-13
Registered BEFORE data collection.

## Question

ON > NC (metabolism with contradictions > no contradictions) was observed in Paper 3.
Is this because:
(a) Resolved contradiction PAIRS create richer retrieval anchors (anchor hypothesis)
(b) Metabolism merely refreshes record timestamps, improving retrieval recency (recency hypothesis)

## Design

4 conditions, all using same model and 30-turn dialogue:

| Condition | Contradictions | Metabolism | Fact Refresh |
|---|---|---|---|
| ON | Yes | Yes | Via metabolism |
| OFF | Yes | No | None |
| NC | No | No | None |
| NC+Refresh | No | No→Yes* | Periodic re-statement |

*NC+Refresh: No contradictions, but user periodically re-states original facts
at the same turns where contradictions would normally be injected.
Metabolism processes these re-statements, refreshing L3 record timestamps.

- Model: gemma4:e4b (Vast.ai for speed)
- 30 turns, benchmark at T15/T30
- n=3 per condition = 12 trials

## Predictions

### Recency hypothesis
NC+Refresh should match ON, because the advantage is purely from timestamp freshness.
- ON ≈ NC+Refresh >> NC ≥ OFF

### Anchor hypothesis
ON should still exceed NC+Refresh, because contradiction pairs provide richer semantic content.
- ON > NC+Refresh > NC ≥ OFF

## Success Criteria

| Observed | Verdict |
|---|---|
| ON - NC+Refresh < 5pt | Recency explains ON > NC |
| ON - NC+Refresh ≥ 15pt | Anchor effect is real |
| 5-15pt | Inconclusive |

## Measurement
Primary: fact_recall accuracy at T30 (this is where ON > NC was originally observed).
Secondary: overall accuracy at T30.
