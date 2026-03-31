# Data Access Guide

This file exists so that external LLMs and reviewers can find all data without searching.

## Quick summary (read this first)

- **Prompts** (exact text used in experiments): [`analysis/llm/prompts.py`](analysis/llm/prompts.py)
- **Experiment scripts**: [`analysis/`](analysis/)
- **Result summaries** (small JSON, GitHub-readable): [`data/summaries/`](data/summaries/)
- **Raw trial data** (large files, OSF): see links below

---

## Raw data on OSF — osf.io/mdh7b

OSF folders are collapsed by default. Use these direct links:

### Paper 1 — Exp.36 (810 trials, 3 models × δ × context length)

| File | Direct download |
|------|----------------|
| GPT-4.1-nano trials (270 trials) | https://osf.io/download/69cc2cdc8ae788fce7460979/ |
| GPT-4.1-mini trials (270 trials) | https://osf.io/download/69cc2ce88ae788fce7460978/ |
| GPT-4.1-nano judged | https://osf.io/download/69cc2cd2a69c2ea5f2b17a45/ |
| GPT-4.1-mini judged | https://osf.io/download/69cc2cdb8ae788fce7460977/ |
| Gemini trials (270 trials) | https://osf.io/download/69cc2cead9fd2082f051e161/ |

### Paper 1 — Exp.35 (δ=0 control, 6 models)

| File | Direct download |
|------|----------------|
| Prompts (all experiments) | https://osf.io/download/69cc2b706af436c831744c42/ |
| Llama 3.1:8b trials | https://osf.io/download/69cc2ad1fedfb5839e51e5ff/ |
| Sonnet batch trials | https://osf.io/download/69cc2abe6af436c831744c3e/ |

### Paper 3 — DeltaZero (metabolism ON/OFF, llama3.1)

| File | Direct download |
|------|----------------|
| trial_02 ON turn_logs.json (180 turns) | https://osf.io/download/69cc2be98cafab72d7460d3b/ |
| trial_01 OFF turn_logs.json (180 turns) | https://osf.io/download/69cc2b25fedfb5839e51e659/ |
| experiment_runner.py | https://osf.io/download/7wa8s/ |
| trial_01 ON summary | https://osf.io/download/69c9e009217286e65b73fa96/ |
| trial_01 OFF summary | https://osf.io/download/69c9e009217286e65b73fa93/ |

### Full OSF structure

```
osf.io/mdh7b/files/
├── paper1_survival_equation/
│   ├── analysis/sat/         SAT phase transition scripts
│   ├── analysis/llm/         LLM experiment scripts + prompts.py + Exp.35 data
│   ├── analysis/exp36/       810 trials JSONL (3 models)
│   └── lean/                 Lean 4 formal proofs (sorry=0)
├── paper3_deltazero/
│   ├── data/deltazero_llama31/  turn-by-turn logs (metabolism ON/OFF/NC)
│   └── scripts/                 experiment_runner.py, analysis.py
└── supplementary/
    ├── llm_experiments/      Exp.14–34 raw data
    └── domain_validation/    BGP, species, corporate, startup, etc.
```

---

## GitHub-readable files (direct fetch, no redirect)

External LLMs: fetch these URLs directly — no OSF redirect, no auth needed.

| File | GitHub raw URL |
|------|---------------|
| **Prompts** (all experiments) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/llm/prompts.py |
| **Exp.36 GPT-4.1-mini trials** (270 trials JSONL) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-mini_trials.jsonl |
| **Exp.36 GPT-4.1-nano trials** (270 trials JSONL) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-nano_trials.jsonl |
| **Exp.36 Gemini trials** (270 trials JSONL) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gemini-3_1-flash-lite-preview_trials.jsonl |
| **DeltaZero turn_logs ON** (trial_02, 180 turns) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/deltazero_llama31/trial_02_metabolism_on_turn_logs.json |
| **DeltaZero turn_logs OFF** (trial_01, 180 turns) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/deltazero_llama31/trial_01_metabolism_off_turn_logs.json |
| **Exp.35 results** | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/summaries/exp35_control_results.json |
| **DeltaZero summary ON** | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/summaries/deltazero_llama31_trial_01_metabolism_on_summary.json |
| **DeltaZero summary OFF** | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/summaries/deltazero_llama31_trial_01_metabolism_off_summary.json |

---

## Key statistics (for quick verification)

**Paper 3 — Sign test (metabolism ON vs OFF, 8 models):**
- 9 wins for ON / 1 for OFF / 1 TIE
- p = 0.0107 (one-sided sign test, n=11 pairs)
- Largest effect: +42.2pp (mistral-nemo:12b)

**Paper 3 — Three-condition (gemma3:27b, n=3, 180 turns each):**
- Metabolism ON: 73.3% ± 6.7
- No contradictions (δ=0): 56.7% ± 5.8  
- Metabolism OFF: 21.1% ± 5.1
- ON vs OFF: p < 0.001, Cohen's d = 8.80

**Paper 1 — Exp.36 (δ × context length):**
- 810 trials (270 per model: GPT-4.1-nano, GPT-4.1-mini, Gemini Flash Lite)
- Design: 3-digit addition task, δ ∈ {zero, subtle, structural} × L ∈ {short, medium, long}
