# Experiment 36: Two-Factor Matrix (δ × Context Length)

## Design

3 δ conditions × 3 context lengths × 3 models × 30 trials = 810 trials

| Factor | Levels |
|:--|:--|
| δ condition | `zero` (δ=0), `subtle` (δ₅, single inter-source disagreement), `structural` (δ₁, self-contradiction at 30% density) |
| Context length | 32K, 128K, 256K tokens |
| Models | GPT-4.1 Nano, GPT-4.1 Mini, Gemini 3.1 Flash-Lite Preview |

Task: three-digit addition (a + b + c) with variable definitions embedded in filler text.

## Files

### Scripts
- `exp36_context_delta_matrix.py` — Main experiment script (real-time API)
- `exp36_batch.py` — OpenAI Batch API variant (used for GPT-4.1 Mini)
- `exp36_batch_sequential_runner.py` — Sequential batch orchestrator
- `exp36_judge.py` — LLM-as-Judge post-hoc evaluation
- `exp36c_reassignment_test.py` — Exp.36c: template-family isolation test

### Data
- `exp36_{model}_trials.jsonl` — Raw trial data (270 trials per model)
- `exp36_{model}_judged.jsonl` — Judge evaluation results
- `exp36c_reassignment_test.jsonl` — Exp.36c results (90 trials: 3 families × 30)

### Documentation
- `exp36_design.md` — Experiment design and decision log

## Key Findings

1. **δ₅ (subtle) ≈ δ₀ (zero) for Nano** — wrong_val_adopted = 0/90
2. **δ₅ catastrophic for Mini** — 37% → 7% accuracy; wrong_val_adopted = 29/90
3. **Gemini δ₅ dilution** — sensitivity decreases with context length (57% → 90%)
4. **δ₁ causes 0% for OpenAI models** — Gemini's 40% at 32K is a template-mix artefact
5. **Two independent mechanisms in Gemini** (Exp.36c + probe):
   - Syntactic classification bypass: `a = a + 1` classified as assignment, not contradiction
   - Instruction-priority suppression: paradox/nullify detected but suppressed under calculator-only prompt

## Excluded Files

Batch API input files (~160MB total) are excluded. The trial JSONL files contain all necessary data for reproduction.
