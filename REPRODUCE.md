# Reproduction Guide

All experiments can be reproduced from this repository.
Raw data and logs are available at [osf.io/mdh7b](https://osf.io/mdh7b).

## Setup

```bash
git clone https://github.com/karesansui/delta-survival-paper
cd delta-survival-paper
pip install -r requirements.txt
```

## SAT Experiments (no API key needed)

Deterministic. Results should match exactly.

```bash
cd analysis/sat

# Main phase transition (Fig. 1)
python exp2_sat_transition.py

# XOR-SAT threshold prediction (5.19× ratio)
python prediction_test.py

# Contradiction type comparison
python exp_sat_contradiction.py

# Bootstrap confidence intervals
python phase3_bootstrap_ci.py
```

## LLM Experiments (API key required)

Stochastic. Set one or more API keys:

```bash
export ANTHROPIC_API_KEY=...
export OPENAI_API_KEY=...
export GOOGLE_API_KEY=...
```

### Exp. 35 — Context rot is δ accumulation

```bash
cd analysis/exp35
python exp35_delta_zero_control.py   # δ=0 control (6 models)
```

### Exp. 36 — Two-factor matrix (δ × context length)

```bash
cd analysis/exp36
python exp36_context_delta_matrix.py  # 810 trials, 3 models
python exp36_judge.py                 # LLM-as-judge post-hoc
```

### Exp. 14–19 — Double-bind & N_eff

```bash
cd analysis/llm
python run_exp14_v4_precision.py   # δ dose-response
python run_exp16_cross_model.py    # cross-model collapse
python run_exp18_neff_measurement.py  # N_eff measurement
```

## Formal Verification (Lean 4)

Requires [Lean 4](https://leanprover.github.io/) and Mathlib.

```bash
cd lean
lake build   # builds all proofs; sorry=0, axiom=0
```

## Pre-computed Results

Raw trial data is available at [osf.io/mdh7b](https://osf.io/mdh7b)
under `paper1_survival_equation/`. You can run analysis scripts
directly on downloaded data without re-running API experiments.

## Notes

- LLM experiment results are stochastic; reproduced results will be
  statistically consistent but not bit-for-bit identical.
- Proprietary model APIs (Claude, GPT-4, Gemini) may change over time.
  Open-weight model experiments (Llama 3.1:8b) are fully reproducible.
- The STRING PPI dataset (`9606.protein.links.v12.0.txt`) must be
  downloaded from [string-db.org](https://string-db.org) separately.
