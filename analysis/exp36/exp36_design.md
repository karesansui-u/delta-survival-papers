# Experiment 36: δ Intensity × Context Length Matrix

**Pre-registration document — frozen before data collection**

## 1. Research Questions

**RQ1**: Does the *intensity* of structural contradiction (δ) matter, or
does mere *presence* of any contradiction cause degradation?

**RQ2**: Does δ₅ (inter-source contradiction) produce the same degradation
pattern as δ₁ (self-referential contradiction)?

**RQ3**: At longer context lengths, does a single subtle contradiction
become easier or harder to detect?

## 2. Background

Exp.35 demonstrated that δ=0 preserves 100% accuracy up to 128K tokens
(for models with sufficient μ), while δ>0 (structural contradictions at
30% density) causes degradation. However, exp.35 tested δ as a binary
variable. The intermediate case — a single, subtle, factual contradiction
— was not tested.

Exp.14–16 (double-bind) showed a step-function phase transition at
δ_c ≈ 0.61–0.63 for *instructional* contradictions. Whether the same
threshold behavior occurs for *factual value* contradictions is unknown.

The δ taxonomy (ARCHITECTURE_V2.md §2.2) distinguishes five dimensions:
- δ₁: Self-contradiction (a = a + 1)
- δ₂: Feedback reversal
- δ₃: Protocol violation
- δ₄: Temporal inconsistency
- δ₅: Inter-source contradiction ("A secondary source reports a = 129")

Exp.35's "structural" condition tests δ₁. Exp.36's "subtle" condition
tests δ₅. These are qualitatively different dimensions.

## 3. Experimental Design

### 3.1 Independent Variables

| Factor | Levels | Description |
|--------|--------|-------------|
| δ condition | zero, subtle, structural | See §3.2 |
| Context length | 32K, 128K, 256K | Token count of full prompt |

### 3.2 δ Conditions

**zero**: No contradictions. Filler consists entirely of independent
factual sentences (same as exp.35 δ=0).

**subtle (δ₅)**: Filler is identical to "zero", except ONE sentence is
injected at the midpoint:

> "A secondary source reports {var} = {wrong_val}."

- Target variable: randomly chosen from {a, b, c}
- Wrong value: original ± {2, 3, 5, 7} (randomly chosen)
- Injection count: exactly 1
- Injection position: midpoint of filler block (fixed)
- Template pool: 5 inter-source reporting variants

**structural (δ₁)**: ~30% of filler sentences are replaced with
self-referential contradictions (same as exp.35):

> "The actual value of {var} in this context is defined as the
> solution to: {var} = {var} + 1."

### 3.3 Task

Same as exp.35: three-digit addition (a + b + c).
- 5 fixed target sets, cycled by trial_idx
- Variable definitions at prompt start, question at end
- System prompt: "You are a precise calculator. Give ONLY the final numerical answer."

### 3.4 Dependent Variables

| Metric | Source | Description |
|--------|--------|-------------|
| accuracy_strict | parse_answer | Last integer in response == expected |
| accuracy_judge | LLM-as-Judge | Separate model evaluates raw_response |
| recognition_rate | Judge | Model correctly identifies a, b, c values |
| wrong_val_adopted | Judge + strict | Model uses wrong_val from subtle injection |
| contradiction_detected | Judge | Model mentions contradictions |

### 3.5 Sample Size

30 trials per cell. Total: 3 δ × 3 contexts × 30 = 270 trials.

Wilson score 95% CI at p=1.0, n=30: [0.88, 1.00].
Wilson score 95% CI at p=0.5, n=30: [0.33, 0.67].
Sufficient to distinguish 100% from chance.

## 4. Models

### Phase 1 (this pre-registration)

| Model | Vendor | Context limit | Cost estimate |
|-------|--------|---------------|---------------|
| GPT-4.1 Nano | OpenAI | 1M | ~$3.70 |

### Future phases (contingent on Phase 1 results)

| Model | Vendor | Cost estimate | Condition |
|-------|--------|---------------|-----------|
| Gemini 3.1 Flash-Lite | Google | ~$30 | If Phase 1 yields interpretable results |
| Claude Sonnet 4.6 | Anthropic | ~$25 | If cross-vendor replication needed |

## 5. Execution Plan

```
Step 0: dry-run          — Verify prompts, token counts, no API calls
Step 1: δ=0, 32K, n=5   — Confirm GPT-4.1 Nano can do the task ($0.02)
Step 2: δ=0, 32K, n=25  — Complete the cell
Step 3: subtle, 32K, n=30
Step 4: structural, 32K, n=30
Step 5: REVIEW 32K results — Go/no-go for 128K+
Step 6: All conditions, 128K
Step 7: All conditions, 256K
Step 8: LLM-as-Judge (all trials, ~$0.10)
```

Each step requires previous step's review before proceeding.

## 6. Pre-Registered Predictions

| Pattern | Interpretation | Prior probability |
|---------|---------------|-------------------|
| zero=100%, subtle=100%, structural<100% | δ₅ is harmless; only δ₁ degrades | Medium |
| zero=100%, subtle<100%, structural<100% | Both δ types cause degradation | Medium |
| zero=100%, subtle≈structural | Presence, not intensity, is what matters | Low |
| subtle worse at longer context | Information dilution hides contradictions | Low |
| subtle better at longer context | Dilution makes single contradiction negligible | Medium |

## 7. Improvements over exp.35

| Issue in exp.35 | Fix in exp.36 |
|-----------------|---------------|
| MAX_TOKENS=64 truncated Sonnet responses | MAX_TOKENS=512 |
| raw_response not saved (most models) | Saved for every trial (JSONL) |
| parse_answer false negatives | LLM-as-Judge as primary metric |
| API errors counted as incorrect | Errors excluded from accuracy, counted separately |
| Cell-level save (30 trials lost on crash) | Per-trial append (1 trial lost max) |
| No tokenizer drift tracking | API usage recorded per trial |
| δ was binary | 3 levels (zero / subtle / structural) |

## 8. Analysis Plan

### Primary analysis
- 3×3 accuracy table (δ × context length)
- Fisher exact test: subtle vs zero at each context length
- Fisher exact test: subtle vs structural at each context length

### Secondary analysis
- wrong_val_adopted rate for subtle condition
- Judge vs strict accuracy divergence (measurement artifact detection)
- Tokenizer drift (tiktoken estimate vs API-reported input tokens)

### Visualization
- Heatmap: accuracy by δ × context length
- Bar chart: strict vs judge accuracy comparison

## 9. Data Format

Trial records saved as JSONL (one JSON object per line):

```json
{
  "experiment": "exp36_context_delta_matrix",
  "version": "1.0.0",
  "model": "gpt-4.1-nano",
  "delta_level": "subtle",
  "context_length": 128000,
  "trial_idx": 7,
  "seed": 360042,
  "expected": 690,
  "answer": 692,
  "is_correct": false,
  "wrong_val_adopted": true,
  "raw_response": "692",
  "result_type": "succeeded",
  "tokens_estimate": 128432,
  "api_input_tokens": 127891,
  "api_output_tokens": 1,
  "injected_var": "a",
  "injected_original_val": 127,
  "injected_wrong_val": 129,
  "injected_position": 0.5,
  "wrong_sum": 692,
  "subtle_sentence": "A secondary source reports a = 129.",
  "timestamp": "2026-03-26T12:00:00"
}
```

## 10. Connection to Prior Work

- **Exp.35**: Binary δ (zero/structural). Exp.36 adds the intermediate "subtle" level.
- **Exp.14–16**: Step-function transition at δ_c ≈ 0.61 for instructional contradictions (δ₂-like). Exp.36 tests whether factual contradictions (δ₅) show similar threshold behavior.
- **DeltaZero**: 5-dimensional δ taxonomy. Exp.36 directly compares δ₁ (self-contradiction) vs δ₅ (inter-source contradiction).
- **Paper 1**: Results will be integrated as a new section extending the exp.35 findings.

---

*Pre-registered: 2026-03-26*
*Author: Sunagawa*
