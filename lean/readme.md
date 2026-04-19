# Survival Model — Formal Verification in Lean 4

Formal verification of the mathematical framework used in Papers 1 and 2.

- **20 modules**, `sorry = 0`, `axiom = 0`
- All proofs fully verified by the Lean 4 type checker

---

## What is verified

| Module | What it proves | Used in |
|--------|---------------|---------|
| `Basic.lean` | Survival equation: S > 0 iff all factors positive | Paper 1 |
| `Penalty.lean` | Penalty function behavior (subcritical/supercritical) | Paper 1 |
| `FullFormula.lean` | Full multiplicative formula properties | Paper 1 |
| `CauchyExponential.lean` | Cauchy functional equation: `e^{cd}` is the unique continuous solution | Papers 1 & 2 |
| `LogUniqueness.lean` | Log-ratio uniqueness: B1–B4 on ratio-space loss `f: (0,1] → ℝ≥0` imply `f(r) = -k·log r` | Paper 1 §3 (A2 characterization) |
| `AxiomsToExp.lean` | 3 axioms (finite states, fractional elimination, independence) imply `e^{-d}` | Paper 1 |
| `SATFirstMoment.lean` | SAT first moment correspondence and decay rate ratio prediction | Papers 1 & 2 |
| `HillNumber.lean` | Hill number upper bound: N_eff <= N (Jensen's inequality) | Paper 1 |
| `ArrowOfTime.lean` | Survival selection theorem (H-theorem, 2-type) | Paper 1 |
| `ArrowOfTimeGeneral.lean` | H-theorem generalized | Paper 1 |
| `ArrowOfTimeNGeneral.lean` | H-theorem for n-type populations | Paper 1 |
| `SensitivityAnalysis.lean` | Error propagation bounds, multiplicative vs additive comparison | Paper 1 |
| `SecondMomentBound.lean` | Paley–Zygmund inequality and second moment method for SAT threshold lower bound | Paper 1 |
| `PairCorrelation.lean` | Pair correlation function g(β) = 3/4 + (1/8)(1-β)³ for random 3-SAT | Paper 1 |
| `SATSecondMoment.lean` | SAT second moment overlap decomposition and threshold bracketing | Paper 1 |
| `AsymptoticExponent.lean` | Asymptotic exponent φ(β, α) and gap analysis between 1st/2nd moment thresholds | Paper 1 |
| `KLDivergence.lean` | δ = D_KL identity, Jensen inequality direction, gap-R₂ connection, structural capacity | Paper 1 |
| `WeakDependence.lean` | ρ-bracket `exp(-δ(1±ρ))` around joint survival; collapse to independence at ρ=0 | Paper 1 (A3 relaxation) |
| `CorrelatedSecondMoment.lean` | Meshwise `2^n·(3/4)^m ≤ E[X²] ≤ 2^n·(7/8)^m` without clause independence; Paley–Zygmund reuse | Paper 1 |
| `RobustSurvival.lean` | `μ·exp(-δ(1+ρ))` robust potential; δ interval from bounded pass-through rates | Paper 1 |

---

## Key results

### Cauchy functional equation (Paper 2, Section 2.2)

If constraints contribute independently to cost, i.e.,
`mu_c(d1 + d2) = mu_c(d1) * mu_c(d2) / A`,
then the unique continuous monotone solution is `mu_c(d) = A * e^{cd}`.

### Log-ratio uniqueness (Paper 1 §3, A2 characterization)

Any ratio-space loss `f : (0,1] → ℝ≥0` satisfying
  (B2) `f(1) = 0`,
  (B3) `f(r₁·r₂) = f(r₁) + f(r₂)`,
  (B4) continuity,
  (B5) `f(r) ≥ 0`,
is uniquely of the form `f(r) = -k · log r` for some `k ≥ 0`. This elevates
A2 of Paper 2 from a definition to a theorem, following the Shannon/Hartley
axiomatic characterization lineage. Proof reduces to the Cauchy additive
equation via the substitution `g(t) = f(exp(-t))` with odd extension.
Independent of A3 (probabilistic independence), so this module stands
alongside `AxiomsToExp.lean` rather than depending on it.

### Three axioms to exponential decay (Paper 1, Section 3)

1. Finite state space
2. Constraints eliminate fixed fractions of states
3. Independence across constraints

These three axioms uniquely determine `S = N_eff * e^{-d}`.

### SAT first moment (Papers 1 & 2)

The expected number of satisfying assignments `E[#SAT] = 2^n * (7/8)^m = exp(n ln 2 - d)` where `d = m * |ln(7/8)|`.

### Second moment method and pair correlation (Paper 1)

The Paley–Zygmund inequality gives threshold lower bound:
`Pr[X > 0] >= E[X]^2 / E[X^2]`.

The pair correlation function `g(β) = 3/4 + (1/8)(1-β)³` satisfies `g(1/2)/(7/8)² = 1`
(typical overlap is neutral). The truncated second moment explains 74% of the gap
between the first-moment bound (α ≈ 5.19) and the true threshold (α ≈ 4.27).

### KL divergence and structural capacity (Paper 1)

`δ = D_KL(P_SAT || P_0)` for independent constraints (identity, not approximation).
Structural capacity theorem: `δ ≤ C_struct ⟺ survival`, isomorphic to Shannon's `R ≤ C`.

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
