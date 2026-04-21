# Survival Model — Formal Verification in Lean 4

Formal verification of the mathematical framework used across the structural
persistence papers and supplements.

- **126 imported `Survival/*` modules**
- `sorry = 0`, `axiom = 0` for the imported development
- Top-level target: `Survival`
- SAT/k-SAT finite-horizon chain: frozen as **SAT chain v1.0**

For the SAT/k-SAT proof index, see
[`SAT_CHAIN_THEOREM_MAP.md`](SAT_CHAIN_THEOREM_MAP.md).
For the cross-domain Bernoulli-CSP template index, see
[`BERNOULLI_CSP_UNIVERSALITY_MAP.md`](BERNOULLI_CSP_UNIVERSALITY_MAP.md).

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
| Bernoulli CSP universality template | `BernoulliCSPTemplate`, `BernoulliCSPPathMeasure`, `BernoulliCSPPathChernoff`, `BernoulliCSPPathCollapse`, `BernoulliCSPUniversality`, `KSATChernoffCollapse`, `NAESATChernoffCollapse`, `XORSATChernoffCollapse`, `QColoringChernoffCollapse`, `ForbiddenPatternCSPChernoffCollapse`, `MultiForbiddenPatternCSP`, `HypergraphColoringChernoffCollapse`, `CardinalitySATChernoffCollapse`, `ThresholdCardinalitySATChernoffCollapse`, `ExactlyOneSATChernoffCollapse` | Reusable Bernoulli bad-event CSP template, k-SAT / NAE-SAT instances, fixed-assignment XOR-SAT, q-coloring, generic forbidden-pattern exposure, multi-forbidden-pattern witnesses, hypergraph-coloring, cardinality-SAT, threshold-cardinality-SAT, and exactly-one-SAT specializations, and a common universality interface |
| Route A non-CSP core examples | `SerialReliability`, `ConstantFractionDecay` | Serial reliability block diagrams, constant-fraction decay, additive log loss, and `R = exp (-L)` threshold crossing |
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

### NAE-SAT horizontal expansion

The next Boolean-CSP expansion instantiates the template for fixed-assignment
`k`-NAE-SAT exposure.  A random signed NAE clause is bad with probability
`(1 / 2)^(k - 1)` for `k >= 2`, giving the `k=3` drift `log (4 / 3)`.

### Generic forbidden-pattern CSP expansion

The finite-alphabet forbidden-pattern layer abstracts any iid local-constraint
exposure with bad probability `forbidden / alphabet^arity`.  Its drift is
`log (alphabet^arity / (alphabet^arity - forbidden))`, under the interior
condition `0 < forbidden < alphabet^arity`.

`MultiForbiddenPatternCSP` adds the reusable witness bridge: a domain supplies
`alphabet`, `arity`, `forbiddenCount`, and the proof
`0 < forbiddenCount < alphabet^arity`; the existing path measure,
Chernoff/KL profile, collapse, stopped-collapse, and hitting-time wrappers are
then generated from that witness.

`ExactlyOneSATChernoffCollapse` demonstrates the witness bridge on a new CSP:
for a fixed assignment and random signed `k`-clause, exactly-one-SAT forbids
`2^k - k` local truth patterns, giving bad probability `(2^k - k) / 2^k` and
drift `log (2^k / k)`.

`CardinalitySATChernoffCollapse` lifts that example to the exactly-`r`-of-`k`
family: the allowed local patterns are `choose k r`, the bad probability is
`(2^k - choose k r) / 2^k`, and the drift is `log (2^k / choose k r)`.
The universality wrapper records exactly-one-SAT as the `r = 1` specialization.

`ThresholdCardinalitySATChernoffCollapse` further adds at-most-`r` and
at-least-`r` cardinality constraints.  The allowed local patterns are partial
binomial sums, and the drift is `log (2^k / allowed)`.  The same witness bridge
then generates the path measure, Chernoff/KL profile, and operational wrappers.

### Hypergraph-coloring specialization

The hypergraph-coloring layer specializes forbidden-pattern exposure to fixed
`q`-coloring of `k`-uniform hyperedges.  The bad event is a monochromatic
hyperedge, so there are `q` forbidden local patterns among `q^k` patterns and
the drift is `log (q^k / (q^k - q))` for `q > 1` and `k > 1`.

Together these instances are frozen as **Bernoulli CSP universality v1.2**:
finite-horizon, iid bad-event exposure with fixed assignment/coloring semantics,
Chernoff-KL failure profiles, and operational collapse / hitting-time wrappers.

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
lake build Survival.NAESATChernoffCollapse
lake build Survival.ForbiddenPatternCSPChernoffCollapse
lake build Survival.MultiForbiddenPatternCSP
lake build Survival.HypergraphColoringChernoffCollapse
lake build Survival.CardinalitySATChernoffCollapse
lake build Survival.ThresholdCardinalitySATChernoffCollapse
lake build Survival.ExactlyOneSATChernoffCollapse
lake build Survival.BernoulliCSPUniversality
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
