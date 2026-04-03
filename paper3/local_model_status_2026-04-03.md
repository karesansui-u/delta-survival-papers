# Local Model Status and Clean Ablation Plan

Date: 2026-04-03

This note is the canonical cleanup memo for the current DeltaZero evidence line.
It separates three different questions that were getting mixed together:

1. Does the metabolism effect exist on frontier models?
2. Are the local-model results currently trustworthy?
3. If local models underperform, is the problem the dialogue model, the metabolism / resolver LLM, or the benchmark judge?

## 1. What is already established

### Frontier models

- `Sonnet` is clean primary evidence.
  - Corrected Stage B mean T30: `ON 0.985 / OFF 0.659 / NC 0.993`
  - Source: `../delta-zero/data/experiments/stageb_sonnet/`
- `Gemini` is clean secondary evidence.
  - Corrected Stage B mean T30: `ON 0.933 / OFF 0.481 / NC 0.963`
  - Source: `../delta-zero/data/experiments/stageb_gemini/aggregate_summary_corrected.json`
- `GPT-4o` is supportive but noisier, and should remain a secondary line.

Interpretation:

- Frontier evidence now supports `ON ~= NC >> OFF`
- This means the full metabolism effect is real on at least two frontier families

### Sonnet as judge vs Sonnet as resolver

Two distinct effects exist:

- `Sonnet as judge`:
  - Used in post-hoc benchmark correction
  - Mostly removes keyword false positives
  - On `stageb_sonnet`, correction barely changes `ON` / `NC`, and only lowers `OFF` slightly
- `Sonnet as metabolism / resolver LLM`:
  - Shown in `deltazero_pipeline_test`
  - `direct_claude` T30: overall `0.778`, fact `0.867`
  - `direct_gemma` T30: overall `0.733`, fact `0.667`
  - This suggests the resolver / extractor path benefits from a stronger metabolism LLM

So the current evidence does **not** support the claim that the result is merely a `Sonnet judge` artifact.
There is a real `Sonnet in the metabolism path` effect as well.

## 2. What is not yet established

### Local model Stage B is not yet clean enough

The earlier `qwen3` and `deepseek` Stage B numbers were confounded by a config leak:

- `scripts/experiment_runner.py` instantiated `BenchmarkRunner` without the Stage B config path
- benchmark judging fell back to the default config
- the default config pointed at `judge_model: gemma3:latest`
- on AWS this often produced `404 model not found`
- benchmark scoring then fell back to keyword mode

That means the early local-model `rule_application` and `contradiction_detection` scores were not clean.

### Corrected local ON results are weak

After targeted T30 rejudging:

- `qwen3` ON T30 corrected:
  - overall `0.244`
  - fact `0.133`
  - rule `0.600`
  - contra `0.000`
  - Source: `../delta-zero/data/experiments/stageb_qwen3/trial_01_metabolism_on/benchmarks/benchmark_turn0030_corrected.json`
- `deepseek` ON T30 corrected:
  - overall `0.289`
  - fact `0.200`
  - rule `0.533`
  - contra `0.133`
  - Source: `../delta-zero/data/experiments/stageb_deepseek/trial_01_metabolism_on/benchmarks/benchmark_turn0030_corrected.json`

Interpretation:

- Local ON is currently weak even after correction
- But this still does **not** prove that metabolism fails on local models
- It only proves that the current local `ON` line is not strong enough to support the paper claim

## 3. Clean question to answer next

The next clean question is:

> If we hold the dialogue model fixed and replace only the metabolism LLM with Sonnet, does the local-model Stage B line improve?

This is the shortest path to separating:

- dialogue-model weakness
- metabolism / resolver weakness
- benchmark-judge artifacts

## 4. Clean ablation design

### Fixed

- Same dialogue model
- Same 30-turn Stage B protocol
- Same `standard` setup
- Same `F3` contradiction force for `ON` / `OFF`
- Same post-hoc corrected benchmark policy

### Varied

- `metabolism_llm = local model`
- `metabolism_llm = Sonnet`

### Compare

For each dialogue model:

- `ON`
- `OFF`
- `NC`

This yields two directly comparable experiment families:

- `qwen3 dialogue + local metabolism`
- `qwen3 dialogue + Sonnet metabolism`
- `deepseek dialogue + local metabolism`
- `deepseek dialogue + Sonnet metabolism`

## 5. New configs prepared for this ablation

### qwen3 dialogue, Sonnet metabolism

- Config:
  - `../delta-zero/config/deltazero_stageb_qwen3_sonnet_metabolism.yaml`
- Run script:
  - `../delta-zero/scripts/run_stageb_qwen3_sonnet_metabolism.sh`
- Output dir:
  - `../delta-zero/data/experiments/stageb_qwen3_sonnet_metabolism`

### deepseek dialogue, Sonnet metabolism

- Config:
  - `../delta-zero/config/deltazero_stageb_deepseek_sonnet_metabolism.yaml`
- Run script:
  - `../delta-zero/scripts/run_stageb_deepseek_sonnet_metabolism.sh`
- Output dir:
  - `../delta-zero/data/experiments/stageb_deepseek_sonnet_metabolism`

Implementation note:

- These runs use `Anthropic API` for the metabolism path, not `claude-cli`
- This is intentional so AWS runs only need `ANTHROPIC_API_KEY`

## 6. Practical reading rule from now on

Until the ablation above is complete:

- use `Sonnet` and `Gemini` as the main frontier evidence
- treat `GPT-4o` as secondary / corroborative
- treat current `qwen3` and `deepseek` results as provisional
- never interpret raw local-model `summary.json` alone as final evidence
- prefer corrected benchmark outputs and corrected aggregate summaries

## 7. Decision criterion

The local-model story becomes much clearer after this comparison:

- If `local dialogue + Sonnet metabolism` improves strongly over `local dialogue + local metabolism`, the bottleneck is mainly the metabolism / resolver path
- If it does not improve much, the dialogue model itself is likely the main bottleneck
- If both remain unstable but corrected judging changes the ranking materially, the benchmark policy still needs work
