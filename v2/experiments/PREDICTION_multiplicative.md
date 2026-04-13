# Pre-registered Prediction: Multiplicative Interaction Test

Date: 2026-04-13
Registered BEFORE data collection.

## Design

2×2 factorial: context pressure (μ) × structural contradiction (δ)

| | δ=0 (矛盾なし) | δ>0 (構造的矛盾1件) |
|---|---|---|
| μ十分 (KV=0) | Cell A | Cell B |
| μ圧迫 (KV=1000) | Cell C | Cell D |

- Model: Claude Sonnet (via claude -p)
- Task: Multi-step arithmetic (a × b - c + 7)
- n=20 per cell = 80 trials total
- Temperature: 1.0 (model default)
- δ: Self-referential paradox embedded in context
- μ pressure: 1000 irrelevant key-value pairs in context

## Predictions

### Additive model (baseline)
Each factor causes independent degradation. Combined effect ≤ sum of individual effects.
- Cell A (baseline): ~90-100%
- Cell B (δ alone): ~90-100% (paradox alone is non-lethal when μ is sufficient)
- Cell C (μ alone): ~80-90% (context pressure alone causes mild degradation)
- Cell D (combined): ≥ 70% (sum of individual drops)

### Multiplicative model (structural persistence)
S = (μ/μ_c) × e^{-δ}. When both factors are present, their effects MULTIPLY.
- Cell A: ~100%
- Cell B: ~100% (μ sufficient → paradox absorbed)
- Cell C: ~80-90% (μ reduced but δ=0 → e^0=1)
- Cell D: **≤ 20%** (μ reduced AND δ>0 → product crosses threshold)

## Success Criteria

| Observed | Verdict |
|---|---|
| D ≤ 30% AND (A - D) > (A - B) + (A - C) | Multiplicative wins |
| D ≥ 70% | Additive holds |
| 30-70% | Inconclusive |

## Key prediction
The interaction term (A + D - B - C) should be NEGATIVE and large (< -40pt).
Additive model predicts interaction ≈ 0.
