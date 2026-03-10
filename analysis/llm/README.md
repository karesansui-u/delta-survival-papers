# LLM Experiments (Paper 1)

Controlled manipulation of δ and μ in LLM reasoning tasks.

## Scripts

| Script | Paper Experiment | Description |
|---|---|---|
| `prompts.py` | All | Prompt definitions for Double Bind scenario |
| `strategy_classifier.py` | All | Response classification (comply/refuse/hedge) |
| `run_exp14_v4_precision.py` | Exp.14 | Fine-grained δ dose-response |
| `run_exp15_low_mu.py` | Exp.15 | Low margin (μ) condition |
| `run_exp16_cross_model.py` | Exp.16 | Cross-model collapse pattern |
| `run_exp18_neff_measurement.py` | Exp.18 | N_eff and cushion mechanism |
| `run_exp19_neff_coupling.py` | Exp.19 | N_eff × δ coupling |
| `run_exp19prime_v2_structural_test.py` | Exp.19' | Structural test (corrected) |

## Requirements

- Python 3.10+
- API keys for Claude / GPT / Gemini (depending on experiment)
- `openai`, `anthropic`, `google-generativeai` packages
