# Survival Model — Formal Verification in Lean 4

Formal verification of the mathematical framework used across the structural
persistence papers and supplements.

- **112 imported `Survival/*` modules**
- `sorry = 0`, `axiom = 0` for the imported development
- Top-level target: `Survival`
- SAT/k-SAT finite-horizon chain: frozen as **SAT chain v1.0**

For the SAT/k-SAT proof index, see
[`SAT_CHAIN_THEOREM_MAP.md`](SAT_CHAIN_THEOREM_MAP.md).

---

## Verified Layers

| Layer | Representative modules | What is verified |
|---|---|---|
| Minimal structural persistence core | `Basic`, `Penalty`, `FullFormula`, `TelescopingExp`, `GeneralStateDynamics` | Survival equations, telescoping exponential identities, signed exponential kernels |
| Axiomatic information-loss layer | `LogUniqueness`, `CauchyExponential`, `AxiomsToExp`, `WeakDependence`, `RobustSurvival`, `SignedWeakDependence` | Log-ratio uniqueness, independence-to-exponential derivation, weak/signed dependence bounds |
| Coarse-graining and representation stability | `CoarseGraining`, `ScaleInvariance`, `CoarseTotalProduction`, `CoarseStochasticTotalProduction`, `CoarseTypicalNondecrease` | Coarse representation compatibility and preservation of total-production style statements |
| Repair/resource budget layer | `MinimumRepairRate`, `ResourceBudget`, `TotalProduction`, `ResourceBoundedDynamics`, `ResourceBudgetToSigmaDrift`, `ResourceBoundedStochasticCollapse` | Repair lower bounds, resource-to-drift bridges, high-probability resource-bounded collapse |
| Martingale/concentration layer | `ConcentrationInterface`, `AzumaHoeffding`, `BoundedAzumaConstruction`, `ConditionalMartingale`, `MartingaleDrift` | Abstract concentration interfaces and Azuma-style collapse wrappers |
| Stopping-time collapse layer | `StoppingTimeCollapseEvent`, `StoppingTimeHighProbabilityCollapse`, `StoppingTimeSharpDecomposition`, `StoppingTimeCliffWarning` | Hitting-time, stopped-collapse, and sharp finite-horizon decompositions |
| Finite-state Markov microfoundations | `FiniteStateMarkovRepairChain`, `FiniteStateMarkovStationaryProduction`, `FiniteStateMarkovStationaryLongTimeConcentration`, `ThreeStateStateDependentExample` | Finite path measures, stationary mean production, long-time prefix concentration, concrete examples |
| SAT actual clause-exposure chain | `SATClauseExposureProcess`, `SATStateDependentClauseExposure`, `SATStateDependentCountMGFProduct`, `SATStateDependentCountChernoffKLAlgebra` | Actual path measure, non-flat outcome-dependent emission, derived MGF product, Chernoff/KL collapse |
| Bernoulli CSP / k-SAT / XOR-SAT / q-coloring template | `BernoulliCSPTemplate`, `BernoulliCSPPathMeasure`, `BernoulliCSPPathChernoff`, `BernoulliCSPPathCollapse`, `KSATBernoulliTemplate`, `KSATChernoffCollapse`, `XORSATBernoulliTemplate`, `XORSATChernoffCollapse`, `QColoringBernoulliTemplate`, `QColoringChernoffCollapse` | Reusable Bernoulli bad-event CSP template, k-SAT instance, fixed-assignment XOR-SAT and q-coloring exposure instances, and k=3 bridge to the SAT chain |
| SAT second-moment and information theory | `SATFirstMoment`, `SATSecondMoment`, `SecondMomentBound`, `PairCorrelation`, `AsymptoticExponent`, `KLDivergence`, `CorrelatedSecondMoment` | First/second moment SAT facts, overlap decomposition, KL identities, correlated sandwich bounds |
| Multi-attractor / phase-transition layer | `MultiAttractor`, `TransitionTheorem`, `FreeEnergy` | Basin survival, transition points, free-energy formulation |

---

## SAT Chain v1.0

The SAT/k-SAT branch is now treated as a frozen finite-horizon core:

```text
random SAT/k-SAT problem data
  -> actual finite path measure
  -> non-flat bad-outcome additive functional
  -> MGF product derived from path PMF
  -> Chernoff/KL lower-tail profile
  -> collapse / stopped-collapse / hitting-time bounds
```

The detailed claim-to-theorem index is in
[`SAT_CHAIN_THEOREM_MAP.md`](SAT_CHAIN_THEOREM_MAP.md).

Current scope boundaries:

- finite horizon, not infinite horizon;
- iid Bernoulli bad-event exposure, not adaptive clause selection;
- fixed-assignment exposure semantics, not XOR-SAT rank dynamics;
- high-probability finite-prefix bounds, not almost-sure ergodic theorems.

These are deliberate boundaries for v1.0, not hidden assumptions in the stated
finite-horizon theorem stack.

---

## Key Results

### Log-ratio uniqueness

Any ratio-space loss `f : (0,1] -> R>=0` satisfying the paper's additive and
continuity axioms is uniquely of the form `f(r) = -k * log r` for some `k >= 0`.
This is the formal A2 characterization layer.

### Signed exponential kernel

The general state-dynamics layer separates contraction and repair and proves
the signed exponential kernel for cumulative net action.

### Resource budget to drift

The resource-budget stack bridges contraction lower bounds to expected
total-production drift. This turns externally supplied positive drift into a
derived theorem once a domain-specific contraction lower bound is supplied.

### SAT/k-SAT Chernoff-KL collapse

For random 3-SAT and random k-SAT finite clause exposure, the development
derives actual path measures, non-flat emission, MGF products, KL/Chernoff
failure profiles, and operational collapse/hitting-time bounds.

### XOR-SAT horizontal expansion

The first horizontal expansion instantiates the same Bernoulli bad-event
template for fixed-assignment `k`-XOR-SAT exposure, where each random XOR
equation is bad with probability `1 / 2`.  This validates template reuse without
claiming full rank/nullity dynamics.

### q-Coloring horizontal expansion

The second horizontal expansion instantiates the same template for fixed-coloring
edge exposure in `q`-coloring.  Each exposed edge is bad with probability
`1 / q`, giving drift `log (q / (q - 1))` for `q > 1`.  This validates reuse on a
multi-valued CSP without claiming full random graph or coloring-algorithm
dynamics.

---

## Building

```bash
# Get Mathlib cache
lake exe cache get

# Build the full imported development
lake build Survival
```

Useful focused targets:

```bash
lake build Survival.SATStateDependentCountChernoffKLAlgebra
lake build Survival.BernoulliCSPPathCollapse
lake build Survival.KSATChernoffCollapse
lake build Survival.KSATToSATChernoffBridge
lake build Survival.XORSATChernoffCollapse
lake build Survival.QColoringChernoffCollapse
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
