# Data Access Guide

This file exists so that external LLMs and reviewers can find all data without searching.

## Quick summary (read this first)

- **Prompts** (exact text used in experiments): [`analysis/llm/prompts.py`](analysis/llm/prompts.py)
- **Experiment scripts**: [`analysis/`](analysis/)
- **Result summaries** (small JSON, GitHub-readable): [`data/summaries/`](data/summaries/)
- **Raw trial data** (turn-by-turn logs, benchmarks): [`data/raw/`](data/raw/) — all on GitHub

---

## Raw data on GitHub — data/raw/

All files are directly fetchable via GitHub raw URLs (no redirect, no auth).

### Paper 1 — Exp.35 (δ=0 control, 6 models)

| File | GitHub raw URL |
|------|---------------|
| Prompts (all experiments) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/llm/prompts.py |
| Control trials (all models) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_delta_zero_control_trials.json |
| Llama 3.1:8b trials | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_llama8b_trials.json |
| Sonnet batch trials | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_sonnet_batch/sonnet_trials.json |

### Paper 1 — Exp.36 (810 trials, 3 models × δ × context length)

| File | GitHub raw URL |
|------|---------------|
| GPT-4.1-nano trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-nano_trials.jsonl |
| GPT-4.1-mini trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-mini_trials.jsonl |
| GPT-4.1-nano judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gpt-4_1-nano_judged.jsonl |
| GPT-4.1-mini judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gpt-4_1-mini_judged.jsonl |
| Gemini trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gemini-3_1-flash-lite-preview_trials.jsonl |
| Gemini judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gemini-3_1-flash-lite-preview_judged.jsonl |
| Reassignment test (Gemini δ₁) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36c_reassignment_test.jsonl |

### Paper 3 — Experiment 3: Three-condition (gemma3:27b, n=3, 180 turns each)

Trials 2–4 are the three replicates reported in the paper (Table 3).

| Condition | Trial | turn_logs | summary | benchmarks |
|-----------|-------|-----------|---------|------------|
| Metabolism ON | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_metabolism_on/benchmarks/benchmark_turn0180.json) |
| Metabolism ON | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_03_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_03_metabolism_on/benchmarks/benchmark_turn0180.json) |
| Metabolism ON | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_metabolism_on/benchmarks/benchmark_turn0180.json) |
| No contradiction (δ=0) | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_no_contradiction/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_no_contradiction/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_no_contradiction/benchmarks/benchmark_turn0180.json) |
| No contradiction (δ=0) | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_no_contradiction/summary.json) | — |
| No contradiction (δ=0) | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_no_contradiction/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_no_contradiction/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_no_contradiction/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_metabolism_off/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_03_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_03_metabolism_off/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_metabolism_off/benchmarks/benchmark_turn0180.json) |

### Paper 3 — Experiment 1: Cross-model sign test (8 models, 11 pairs)

| Model | Trials | Location |
|-------|--------|----------|
| gemma3:27b (T1–T4) | ON/OFF | [data/raw/deltazero_gemma27b/](data/raw/deltazero_gemma27b/) |
| gemma3:27b (T1, old code) | ON/OFF | [data/raw/deltazero_gemma/](data/raw/deltazero_gemma/) |
| gemma3:12b (T1, T4) | ON/OFF/NC | [data/raw/deltazero_gemma12/](data/raw/deltazero_gemma12/) |
| llama3.1:8b (T1–T4) | ON/OFF/NC | [data/raw/deltazero_llama31/](data/raw/deltazero_llama31/) |
| mistral-nemo:12b (T1–T4) | ON/OFF/NC | [data/raw/deltazero_mistral/](data/raw/deltazero_mistral/) |
| deepseek-r1:14b (T1–T2) | ON/OFF | [data/raw/deltazero_deepseek/](data/raw/deltazero_deepseek/) |
| qwen2.5:14b (T1) | ON/OFF | [data/raw/deltazero_qwen25/](data/raw/deltazero_qwen25/) |
| phi4 (excluded) | ON/OFF | [data/raw/deltazero_phi4/](data/raw/deltazero_phi4/) |

### Paper 3 — Experiment 2: Controlled ablation (mistral-nemo:12b)

Covered by `deltazero_gemma` (old code) and `deltazero_mistral` (new code) above.

### Paper 3 — Capability–vulnerability paradox (delta_c factor analysis)

| File | Description |
|------|-------------|
| [delta_c/](data/raw/delta_c/) | GPT-4o, GPT-4o-mini, Haiku — T1×F1/F2/F3 |
| [delta_c/phase1/](data/raw/delta_c/phase1/) | Sonnet — T1–T3×F1/F2/F3 |

### Paper 3 — Frontier model replication (Exp35-R)

| Model | Location |
|-------|----------|
| Sonnet 4.6 | [data/raw/exp35_claude/](data/raw/exp35_claude/) |
| Gemini 3.1 Flash Lite | [data/raw/exp35_gemini/](data/raw/exp35_gemini/) |
| GPT-4o | [data/raw/exp35_gpt4o/](data/raw/exp35_gpt4o/) |

### Paper 3 — delta-prune defense test (n=1)

[data/raw/delta_prune_defense/](data/raw/delta_prune_defense/) — A_no_prune.json, B_reverse_prune.json, summary.json

### Paper 3 — Fact recall direct control (GPT-4o non-retention)

[data/raw/fact_recall_direct/](data/raw/fact_recall_direct/) — summary.json

### Paper 3 — Frontier full-pipeline controlled replication (Sonnet 4.6, n=3)

[paper3/frontier_full_pipeline_pilot.md](paper3/frontier_full_pipeline_pilot.md) — summarized three-condition controlled replication (`ON / OFF / NC`), aggregate statistics, and workspace raw-log locations

---

## OSF backup — osf.io/mdh7b

Large files and additional supplements are also archived at OSF.
Direct download links (no redirect):

| File | Direct download |
|------|----------------|
| GPT-4.1-nano trials (270 trials) | https://osf.io/download/69cc2cdc8ae788fce7460979/ |
| GPT-4.1-mini trials (270 trials) | https://osf.io/download/69cc2ce88ae788fce7460978/ |
| Gemini trials (270 trials) | https://osf.io/download/69cc2cead9fd2082f051e161/ |

---

## Key statistics (for quick verification)

**Paper 3 — Three-condition (gemma3:27b, n=3, 180 turns each):**
- Metabolism ON: 73.3% ± 6.7
- No contradictions (δ=0): 56.7% ± 5.8
- Metabolism OFF: 21.1% ± 5.1
- KW p=0.027; all pairwise MW p=0.05 (minimum achievable for n=3)

**Paper 3 — Sign test (8 models, 11 trial pairs):**
- 9 wins for ON / 1 for OFF / 1 TIE
- p = 0.0107 (one-sided sign test, n=10 non-tied)
- Conservative by-model: 6/7 models, p = 0.0625
- Largest effect: +42.2pp (mistral-nemo:12b T2)

**Paper 1 — Exp.36 (δ × context length):**
- 810 trials (270 per model: GPT-4.1-nano, GPT-4.1-mini, Gemini Flash Lite)
- Design: 3-digit addition task, δ ∈ {zero, subtle, structural} × L ∈ {short, medium, long}

**Paper 1 — Multi-attractor prediction:**
- P(correct) = 1/(1 + K/L), K = 19.5 ± 3.4 (thousands of tokens)
- Confirmed at 5 context lengths (32K–512K), MAE 2%
- Prediction derived from 3 data points; 2 out-of-sample predictions within 1%
