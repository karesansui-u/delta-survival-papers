# Lean Formalization Note

This project includes a Lean 4 formalization of the mathematical core used in Papers 1 and 2.

## Current status

- Lean 4 modules are included in [`lean/`](lean/)
- current imported development size: `116 Survival modules`
- current verification status: `sorry = 0`, `axiom = 0`
- the formalization covers the core structural-persistence framework and related mathematical components used in the main theory papers
- the finite-horizon SAT/k-SAT chain is frozen as **SAT chain v1.0**

## What this means

The repository is not only a set of prose preprints. It also includes machine-checked formalization of the mathematical framework in Lean 4.

In practice, this means the main theoretical claims are accompanied by:

- preprints
- raw data and experiments
- implementation artifacts
- formal verification artifacts

## Main entry points

- overview of the formalization: [`lean/readme.md`](lean/readme.md)
- SAT/k-SAT theorem map: [`lean/SAT_CHAIN_THEOREM_MAP.md`](lean/SAT_CHAIN_THEOREM_MAP.md)
- Bernoulli-CSP universality map: [`lean/BERNOULLI_CSP_UNIVERSALITY_MAP.md`](lean/BERNOULLI_CSP_UNIVERSALITY_MAP.md)
- Lean source directory: [`lean/`](lean/)

## Build

```bash
cd lean
lake exe cache get
lake build
```

## Why this file exists

This note exists mainly for public archive visitors (OSF / Zenodo / external readers) so they can quickly see that the project includes a Lean formalization layer, even if they do not browse the full repository structure first.
