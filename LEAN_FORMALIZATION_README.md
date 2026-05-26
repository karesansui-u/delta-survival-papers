# Lean Formalization Note

This project includes a Lean 4 formalization of the mathematical core used
across the structural persistence papers and supplements.

## Current status

- Lean 4 modules are included in [`lean/`](lean/)
- current imported development size: `168 Survival modules`
- current verification status: no project-level `sorry`, `admit`, or declared
  `axiom` in the imported `Survival` target
- the formalization covers the core structural-persistence framework,
  finite-horizon SAT/CSP chains, repair/resource accounting, concentration
  wrappers, epistemic-control and evidence-packet bridges, and
  information-theoretic bridges
- the finite-horizon SAT/k-SAT chain is frozen as **SAT chain v1.0**
- the Bernoulli bad-event CSP layer is frozen as **Bernoulli CSP universality
  v1.2**

## What this means

The repository is not only a set of prose preprints. It also includes machine-checked formalization of the mathematical framework in Lean 4.

In practice, this means the main theoretical claims are accompanied by:

- preprints
- raw data and experiments
- implementation artifacts
- formal verification artifacts

The most important current upgrade is that the information-theoretic reading is
not only informal.  The Lean layer includes files connecting cumulative
structural loss to KL divergence, Bernoulli KL/Chernoff profiles, first/second
moment structure, finite channel reliability skeletons, and BEC-style finite
achievability/converse envelopes.

## Main entry points

- top-level import spine: [`lean/Survival.lean`](lean/Survival.lean)
- overview of the formalization: [`lean/README.md`](lean/README.md)
- paper-to-Lean theorem map: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md)
- information-theory bridge note:
  [`lean/INFORMATION_THEORY_CONNECTION.md`](lean/INFORMATION_THEORY_CONNECTION.md)
- Lean source directory: [`lean/`](lean/)

## Build

```bash
cd lean
lake exe cache get
lake build
```

## Why this file exists

This note exists mainly for public archive visitors (OSF / Zenodo / external readers) so they can quickly see that the project includes a Lean formalization layer, even if they do not browse the full repository structure first.
