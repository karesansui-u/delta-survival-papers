# Reproduction Guide

This repository currently centers on the `v2` preprints (`1` through `4`),
their PDF builds, the supporting experiment code, and the Lean formalization.

Raw data, logs, and PDF mirrors are available at [osf.io/mdh7b](https://osf.io/mdh7b).

## Setup

Primary public repository:

```bash
git clone https://codeberg.org/delta-survival/papers.git delta-survival-paper
cd delta-survival-paper
pip install -r requirements.txt
```

## Current Preprints (v2)

Main manuscripts:

- `v2/1_構造持続の最小形式.md`
- `v2/2_構造持続の条件つき導出.md`
- `v2/3_構造持続と推論性能の劣化.md`
- `v2/4_構造持続と継続学習における破滅的忘却.md`

Built PDFs:

- `v2/pdf用/1_構造持続の最小形式.pdf`
- `v2/pdf用/2_構造持続の条件つき導出.pdf`
- `v2/pdf用/3_構造持続と推論性能の劣化.pdf`
- `v2/pdf用/4_構造持続と継続学習における破滅的忘却.pdf`

Current OSF mirrors:

- Paper 1: <https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1>
- Paper 2: <https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b>
- Paper 3: <https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec>
- Paper 4: <https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c>

## SAT Experiments (no API key needed)

Deterministic. Results should match exactly.

```bash
cd analysis/sat

# Main phase transition (Fig. 1)
python exp2_sat_transition.py

# XOR-SAT threshold prediction (5.19x ratio)
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
python exp35_delta_zero_control.py
```

### Exp. 36 — Two-factor matrix (δ x context length)

```bash
cd analysis/exp36
python exp36_context_delta_matrix.py
python exp36_judge.py
```

### Exp. 14–19 — Double-bind & N_eff

```bash
cd analysis/llm
python run_exp14_v4_precision.py
python run_exp16_cross_model.py
python run_exp18_neff_measurement.py
```

## Formal Verification (Lean 4)

Requires [Lean 4](https://leanprover.github.io/) and Mathlib.

```bash
cd lean
lake exe cache get
lake build
```

## OSF Layout

At the time of writing:

- `v2_preprints_2026-04-14/` contains the current `v2` PDF mirrors
- `paper1_survival_equation/` contains earlier paper-1-related materials
- `paper3_deltazero/` contains earlier DeltaZero / paper-3-related materials
- `supplementary/` contains additional files

## Notes

- LLM experiment results are stochastic; reproduced results should be statistically consistent, not bit-for-bit identical.
- Proprietary model APIs may change over time.
- Some older references inside the repository point to earlier versions or legacy artifact locations. For the current manuscripts, prefer `v2/` and the OSF links listed above.
- The STRING PPI dataset (`9606.protein.links.v12.0.txt`) must be downloaded separately from [string-db.org](https://string-db.org).
