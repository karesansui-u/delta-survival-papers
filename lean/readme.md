# Survival Model — Formal Verification in Lean 4

Formal verification of the mathematical framework used in Papers 1 and 2.

- **11 modules**, `sorry = 0`, `axiom = 0`
- All proofs fully verified by the Lean 4 type checker

---

## What is verified

| Module | What it proves | Used in |
|--------|---------------|---------|
| `Basic.lean` | Survival equation: S > 0 iff all factors positive | Paper 1 |
| `Penalty.lean` | Penalty function behavior (subcritical/supercritical) | Paper 1 |
| `FullFormula.lean` | Full multiplicative formula properties | Paper 1 |
| `CauchyExponential.lean` | Cauchy functional equation: `e^{cd}` is the unique continuous solution | Papers 1 & 2 |
| `AxiomsToExp.lean` | 3 axioms (finite states, fractional elimination, independence) imply `e^{-d}` | Paper 1 |
| `SATFirstMoment.lean` | SAT first moment correspondence and decay rate ratio prediction | Papers 1 & 2 |
| `HillNumber.lean` | Hill number upper bound: N_eff <= N (Jensen's inequality) | Paper 1 |
| `ArrowOfTime.lean` | Survival selection theorem (H-theorem, 2-type) | Paper 1 |
| `ArrowOfTimeGeneral.lean` | H-theorem generalized | Paper 1 |
| `ArrowOfTimeNGeneral.lean` | H-theorem for n-type populations | Paper 1 |
| `SensitivityAnalysis.lean` | Error propagation bounds, multiplicative vs additive comparison | Paper 1 |

---

## Key results

### Cauchy functional equation (Paper 2, Section 2.2)

If constraints contribute independently to cost, i.e.,
`mu_c(d1 + d2) = mu_c(d1) * mu_c(d2) / A`,
then the unique continuous monotone solution is `mu_c(d) = A * e^{cd}`.

### Three axioms to exponential decay (Paper 1, Section 3)

1. Finite state space
2. Constraints eliminate fixed fractions of states
3. Independence across constraints

These three axioms uniquely determine `S = N_eff * e^{-d}`.

### SAT first moment (Papers 1 & 2)

The expected number of satisfying assignments `E[#SAT] = 2^n * (7/8)^m = exp(n ln 2 - d)` where `d = m * |ln(7/8)|`.

---

## Building

```bash
# Get Mathlib cache
lake exe cache get

# Build (verifies all proofs)
lake build
```

---

## Citation

```bibtex
@software{survival_lean,
  author = {Akihito Sunagawa},
  title = {Survival Model: Formal Verification in Lean 4},
  year = {2026},
  url = {https://codeberg.org/delta-survival/papers}
}
```

## License

Apache 2.0 (matching Mathlib)
