# Survival Model — Lean 4 Formal Verification

This directory is the machine-checked mathematical core behind the structural
persistence / survival papers.  It is not only a code appendix: it is the place
where the exponential survival kernel, finite-horizon collapse bounds, repair
and resource accounting, SAT/CSP examples, and information-theoretic bridges are
made explicit as Lean statements.

**Main point.**  The central quantity is not introduced as a metaphor.  In the
formal layer, cumulative structural loss `delta` is tied to log-ratio algebra,
KL divergence, Chernoff profiles, finite channel skeletons, and capacity-style
finite envelopes under stated assumptions.

Current machine-checked status:

- **177 direct top-level `Survival.*` imports in `Survival.lean`**
- **177 `Survival/*.lean` module files**
- Top-level build target: `Survival`
- No project-level `sorry`, `admit`, or declared `axiom` in the imported target
- SAT/k-SAT finite-horizon chain: frozen as **SAT chain v1.0**
- Bernoulli bad-event CSP layer: frozen as **Bernoulli CSP universality v1.2**

## Top-Level Import Spine

The top-level Lean entry file is [`Survival.lean`](Survival.lean).

Direct GitHub link:
[`lean/Survival.lean`](https://github.com/karesansui-u/delta-survival-papers/blob/main/lean/Survival.lean)

`Survival.lean` is the complete import spine for the current formal
development.  Building this target checks the full imported theorem stack,
rather than a single isolated file.  Its header summarizes the covered scope:

- survival-equation algebraic properties;
- hazard-rate monotonicity and penalty-function behavior;
- survival-selection / H-theorem style arrow-of-time statements;
- SAT first-moment correspondence and ratio prediction;
- Cauchy/log-ratio uniqueness of the exponential kernel;
- Hill-number and Jensen-style upper bounds;
- axioms-to-exponential derivation chains;
- error propagation and sensitivity bounds;
- multiplicative versus additive model comparisons;
- Paley-Zygmund / second-moment threshold lower bounds;
- SAT overlap decomposition and threshold bracketing;
- KL-divergence identities, Jensen gaps, and second-moment connections;
- weak-dependence and correlated-second-moment bounds;
- robust survival envelopes such as conservative `mu * exp(-delta * (1 + rho))`;
- epistemic-control bridge wrappers for LLM-style contradiction / repair
  control layers;
- finite channel and capacity-style skeletons;
- multi-attractor, transition, and free-energy modules.

Reader-facing theorem map: [`PAPER_MAPPING.md`](PAPER_MAPPING.md).  The
information-theory companion note is
[`INFORMATION_THEORY_CONNECTION.md`](INFORMATION_THEORY_CONNECTION.md).

---

## Theory Entry Points

This Lean directory formalizes the mathematical core of **Structural Persistence
Accounting**.  For the prose theory and public reading path, start here:

| Entry point | Role |
|---|---|
| [`../v3/01_theory/20_public_first_draft.md`](../v3/01_theory/20_public_first_draft.md) | Public first-draft paper: structural persistence accounting, specification-fixed anchors, and finite operational examples |
| [`../v3/01_theory/02_accounting_framework.md`](../v3/01_theory/02_accounting_framework.md) | Core accounting framework: maintainable regions, log-ratio accounting, repair-inclusive balance, and observability layers |
| [`../v3/01_theory/10_log_ratio_accounting.md`](../v3/01_theory/10_log_ratio_accounting.md) | Minimal log-ratio kernel behind `S = M e^{-L}` |
| [`../v3/01_theory/11_balance_accounting.md`](../v3/01_theory/11_balance_accounting.md) | Repair-inclusive balance principle behind `S = M e^{-B}` |
| [`../v3/01_theory/en/02_core_en.md`](../v3/01_theory/en/02_core_en.md) | English core overview |
| [`../README.md`](../README.md) | Repository-level public entry path |

The relationship is:

```text
Structural Persistence Accounting prose
  -> claim and boundary map
  -> Lean theorem map
  -> machine-checked finite theorem stack
```

The Lean layer is therefore best read as the formal spine for the
specification-fixed part of the accounting theory, not as a replacement for the
prose definitions, evidence ledgers, or empirical claim boundaries.

---

## What Is Proved Here?

The Lean development supports a finite, assumption-explicit theorem stack:

```text
local loss / repair / resource accounting
  -> telescoping exponential kernel
  -> finite path measures and drift/concentration statements
  -> SAT/CSP bad-event exposure models
  -> Chernoff/KL collapse and hitting-time bounds
  -> information-theoretic readings of delta
```

The development deliberately separates:

- algebraic identities from probabilistic assumptions;
- finite-horizon statements from asymptotic claims;
- CSP examples from non-CSP Route A examples;
- channel-skeleton analogies from full Shannon theorems.

That separation is part of the claim boundary.  The repository proves the
finite statements it imports; it does not hide infinite-horizon or universal-law
assumptions inside informal prose.

---

## Information-Theory Bridge

The Lean layer contains theorem files whose job is to connect `delta` to
information-theoretic quantities and finite channel-style envelopes.

| Information-theoretic theme | Lean entry points | What is formalized |
|---|---|---|
| KL divergence | `KLDivergence` | `D_KL(P_SAT || P_0) = delta` for independent constraints; `E[D_KL] >= delta` via Jensen-style algebra; the Jensen gap is connected to second-moment ratios |
| Bernoulli KL / Chernoff profiles | `BernoulliCSPTemplate`, `BernoulliCSPPathChernoff`, `SATStateDependentCountChernoffKLAlgebra` | Bernoulli relative entropy, lower-tail exponential tilts, optimized MGF identities, and KL-shaped finite collapse profiles |
| First/second moment bridge | `SATFirstMoment`, `SATSecondMoment`, `SecondMomentBound`, `PairCorrelation`, `CorrelatedSecondMoment` | Expected solution counts, pair-correlation decomposition, second-moment survival bounds, and correlated sandwich estimates |
| Channel reliability skeleton | `BinarySymmetricChannel` | Uncoded independent-channel identity: block success equals `exp (- cumulativeLoss)` |
| Linear-code erasure boundary | `LinearCodeErasureAccountingToy`, `LinearCodeBECRankBoundary`, `LinearCodeBECConcentrationBoundary`, `LinearCodeBECCapacityStyleBoundary` | Finite BEC-style achievability/converse envelopes using erasure counts, rank slack, and concentration-style ingredients |
| Capacity-style survival envelope | `FiniteCSPFirstMomentCollapseBound`, `FiniteCSPSecondMomentSurvivalBound`, BEC wrappers | Finite analogues of "below capacity survives / above capacity collapses" under explicit hypotheses |

Important boundary: `BinarySymmetricChannel` and
`LinearCodeBECCapacityStyleBoundary` do **not** claim to prove Shannon's coding
theorem.  They package finite skeletons and finite achievability/converse-style
ingredients so that the survival equation can be read next to standard
information-theoretic objects without overclaiming.

The most direct files to inspect are:

```text
Survival/KLDivergence.lean
Survival/BernoulliCSPTemplate.lean
Survival/SATStateDependentCountChernoffKLAlgebra.lean
Survival/BinarySymmetricChannel.lean
Survival/LinearCodeBECCapacityStyleBoundary.lean
```

---

## Verified Layers

| Layer | Representative modules | What is verified |
|---|---|---|
| Minimal structural persistence core | `Basic`, `Penalty`, `FullFormula`, `TelescopingExp`, `GeneralStateDynamics` | Survival equations, telescoping exponential identities, signed exponential kernels |
| Log-ratio and exponential uniqueness | `LogUniqueness`, `CauchyExponential`, `AxiomsToExp`, `WeakDependence`, `RobustSurvival`, `SignedWeakDependence` | Log-ratio uniqueness, independence-to-exponential derivation, weak/signed dependence bounds |
| Structural balance and repair | `StructuralPersistenceBalancePrinciple`, `RepairMaintenanceBalance`, `RepairMaintenanceTemplate`, `MinimumRepairRate`, `ResourceBudget`, `TotalProduction`, `ResourceBoundedDynamics` | Repair lower bounds, maintenance balance, resource-to-drift bridges, finite resource-bounded collapse |
| Epistemic / LLM control bridge | `EpistemicControlBridge`, `EpistemicControlComparison`, `EpistemicControlEvaluationContract`, `EpistemicBenchmarkProtocol`, `EvidencePacketBridge`, `LLMEpistemicControlToy`, `LLMMemoryUseConditionToy`, `SoftwareContractToyRepository`, `SoftwareEvidencePacketToy`, `DependencyClosureBudgetToy`, `LLMMemoryReasoningStrengtheningToy`, `EpistemicControlStack` | Abstract contradiction / repair control interface, coherent-mass net-action kernel wrapper, conditional baseline comparison under no-worse cumulative net action, evaluation-facing metric witness contract for that comparison premise, benchmark protocol validity contract for frozen task surfaces and readouts, conditional memory-filter and dependency-rewrite guard lemmas, structured evidence-packet provenance / eligibility / witness / repair guardrails, a finite LLM reasoning / memory / continual-update toy, explicit LLM memory use-condition guards, a finite toy repository-contract instantiation with concrete toy mass values, a toy software evidence-packet instantiation, finite dependency-closure / invalidation / repair-touched budget bounds, lifecycle memory guards, provenance trust ordering, minimal witness guards, composed repair-kernel wrappers, and a stack-level theorem entry point |
| Coarse representation stability | `AdmissibleMapInvariants`, `SaturationDefect`, `CoarseGraining`, `ScaleInvariance`, `CoarseTotalProduction`, `CoarseStochasticTotalProduction` | Coarse representation compatibility and preservation of total-production style statements |
| Martingale/concentration layer | `ConcentrationInterface`, `AzumaHoeffding`, `BoundedAzumaConstruction`, `ConditionalMartingale`, `MartingaleDrift` | Abstract concentration interfaces and Azuma-style collapse wrappers |
| Stopping-time collapse layer | `StoppingTimeCollapseEvent`, `StoppingTimeHighProbabilityCollapse`, `StoppingTimeSharpDecomposition`, `StoppingTimeCliffWarning` | Hitting-time, stopped-collapse, and sharp finite-horizon decompositions |
| Finite-state Markov microfoundations | `FiniteStateMarkovRepairChain`, `FiniteStateMarkovStationaryProduction`, `FiniteStateMarkovStationaryLongTimeConcentration`, `ThreeStateStateDependentExample` | Finite path measures, stationary mean production, long-time prefix concentration, concrete examples |
| SAT actual clause-exposure chain | `SATClauseExposureProcess`, `SATStateDependentClauseExposure`, `SATStateDependentCountMGFProduct`, `SATStateDependentCountChernoffKLAlgebra` | Actual path measure, non-flat outcome-dependent emission, derived MGF product, Chernoff/KL collapse |
| Bernoulli CSP universality template | `BernoulliCSPTemplate`, `BernoulliCSPPathMeasure`, `BernoulliCSPPathChernoff`, `BernoulliCSPPathCollapse`, `BernoulliCSPUniversality` | Reusable Bernoulli bad-event CSP template with finite collapse, stopped-collapse, and hitting-time wrappers |
| CSP specializations | `KSATChernoffCollapse`, `NAESATChernoffCollapse`, `XORSATChernoffCollapse`, `QColoringChernoffCollapse`, `ForbiddenPatternCSPChernoffCollapse`, `MultiForbiddenPatternCSP`, `HypergraphColoringChernoffCollapse`, `CardinalitySATChernoffCollapse`, `ThresholdCardinalitySATChernoffCollapse`, `ExactlyOneSATChernoffCollapse` | k-SAT, NAE-SAT, fixed-assignment XOR-SAT, q-coloring, forbidden-pattern, multi-forbidden, hypergraph-coloring, cardinality-SAT, threshold-cardinality-SAT, and exactly-one-SAT instantiations |
| Route A non-CSP skeletons | `SerialReliability`, `ConstantFractionDecay`, `BranchingProcessExtinction`, `QueueStability`, `BinarySymmetricChannel`, `FatigueDamage`, `ConsensusFaultThreshold`, `MemoryThrashing`, `BucklingThreshold`, `PercolationThreshold` | Finite-prefix examples of exponential survival, overload/capacity thresholds, and critical-parameter thresholds outside CSPs |
| SAT second-moment and information theory | `SATFirstMoment`, `SATSecondMoment`, `SecondMomentBound`, `PairCorrelation`, `AsymptoticExponent`, `KLDivergence`, `CorrelatedSecondMoment` | First/second moment SAT facts, overlap decomposition, KL identities, correlated sandwich bounds |
| Multi-attractor and phase-transition layer | `MultiAttractor`, `TransitionTheorem`, `FreeEnergy` | Basin survival, transition points, free-energy formulation |

---

## SAT / CSP Chain

The SAT/k-SAT branch is treated as a frozen finite-horizon core:

```text
random SAT/k-SAT problem data
  -> actual finite path measure
  -> non-flat bad-outcome additive functional
  -> MGF product derived from path PMF
  -> Chernoff/KL lower-tail profile
  -> collapse / stopped-collapse / hitting-time bounds
```

The Bernoulli-CSP layer then factors the common bad-event exposure algebra.  A
domain supplies a bad-event probability and witnesses that it lies in `(0,1)`;
the shared path measure, Chernoff/KL profile, collapse, stopped-collapse, and
hitting-time wrappers are reused.

Current scope boundaries:

- finite horizon, not infinite horizon;
- iid Bernoulli bad-event exposure, not adaptive clause selection;
- fixed-assignment or fixed-coloring exposure semantics, not full search
  dynamics;
- high-probability finite-prefix bounds, not almost-sure ergodic theorems.

These are deliberate v1.x boundaries, not hidden assumptions.

---

## Key Theorem Themes

### 1. Exponential survival is forced by log-ratio additivity

The log-uniqueness and Cauchy-exponential layers show that ratio-space loss with
the paper's additivity and continuity assumptions has the `-log` form, and that
accumulated independent loss has the exponential kernel.

Representative modules:

```text
Survival/LogUniqueness.lean
Survival/CauchyExponential.lean
Survival/AxiomsToExp.lean
Survival/TelescopingExp.lean
```

### 2. Repair and maintenance are explicit state dynamics

The structural-balance layer separates contraction, repair, maintenance, and
remaining margin.  It proves pathwise exponential-kernel wrappers and local
balance statements under explicit finite-prefix hypotheses.

Representative modules:

```text
Survival/StructuralPersistenceBalancePrinciple.lean
Survival/RepairMaintenanceBalance.lean
Survival/LyapunovBalanceEmbedding.lean
Survival/ResourceBudgetToSigmaDrift.lean
```

### 3. Collapse is finite, measurable, and stopped

The concentration and stopping-time files package finite-horizon drift,
Azuma-style concentration, stopped collapse, and hitting-time statements.  They
are written as reusable interfaces rather than one-off proofs.

Representative modules:

```text
Survival/ConcentrationInterface.lean
Survival/AzumaHoeffding.lean
Survival/StoppingTimeHighProbabilityCollapse.lean
Survival/StoppingTimeSharpDecomposition.lean
```

### 4. SAT and CSP examples instantiate the same finite template

The random SAT path is not treated as a flat independent product by assumption.
The path-measure files build the finite exposure semantics, derive the MGF
product, and then expose the Chernoff/KL collapse profile.

Representative modules:

```text
Survival/SATStateDependentClauseExposure.lean
Survival/SATStateDependentCountMGFProduct.lean
Survival/SATStateDependentCountChernoffKLAlgebra.lean
Survival/BernoulliCSPUniversality.lean
```

### 5. The information-theory bridge is formal, but bounded

`KLDivergence` proves the cleanest information-theoretic statement: in the
independent-constraint case, cumulative loss equals the KL divergence between
the satisfying-assignment distribution and the ambient uniform distribution.
For general correlated constraints, the development records the Jensen
inequality direction and links the gap to second-moment structure.

This is the intended public claim shape: strong enough to justify the
information-theoretic reading, bounded enough to avoid claiming a universal
capacity theorem.

---

## What This Does Not Claim

The Lean development is intentionally conservative.  It does not claim:

- a full Shannon coding theorem;
- a full random-k-SAT threshold theorem;
- full XOR-SAT rank dynamics for every specialization;
- adaptive search-process dynamics;
- an infinite-horizon ergodic theorem;
- a proof of LLM semantics, LLM performance, belief-revision correctness,
  continual-learning safety, memory safety, or product-level agent reliability;
- a universal law for every physical, biological, social, or computational
  system without domain-specific witnesses.

Instead, it provides a reusable finite theorem stack: once a domain supplies the
required path measure, bad-event probability, drift, repair, or concentration
witnesses, the structural-persistence wrappers apply.

---

## How To Read This Directory

For a fast tour:

1. Start with [`Survival.lean`](Survival.lean), the complete import spine.
2. Read [`PAPER_MAPPING.md`](PAPER_MAPPING.md) for paper claim -> theorem file
   mapping.
3. Read [`INFORMATION_THEORY_CONNECTION.md`](INFORMATION_THEORY_CONNECTION.md)
   for the mathematical motivation of the KL/channel/capacity-style bridge.
4. Inspect `Survival/KLDivergence.lean` and `Survival/BernoulliCSPTemplate.lean`
   to see the information-theoretic core in Lean.
5. Inspect `Survival/StructuralPersistenceBalancePrinciple.lean` for the
   reader-facing structural balance wrappers.

---

## Building

```bash
cd lean

# Get Mathlib cache
lake exe cache get

# Build the full imported development
lake build Survival
```

Useful focused targets:

```bash
lake build Survival.KLDivergence
lake build Survival.BernoulliCSPTemplate
lake build Survival.SATStateDependentCountChernoffKLAlgebra
lake build Survival.BernoulliCSPPathCollapse
lake build Survival.BernoulliCSPUniversality
lake build Survival.EpistemicControlBridge
lake build Survival.EpistemicControlComparison
lake build Survival.EpistemicControlEvaluationContract
lake build Survival.EpistemicBenchmarkProtocol
lake build Survival.EvidencePacketBridge
lake build Survival.LLMEpistemicControlToy
lake build Survival.LLMMemoryUseConditionToy
lake build Survival.DependencyClosureBudgetToy
lake build Survival.LLMMemoryReasoningStrengtheningToy
lake build Survival.SoftwareContractToyRepository
lake build Survival.SoftwareEvidencePacketToy
lake build Survival.EpistemicControlStack
lake build Survival.KSATChernoffCollapse
lake build Survival.XORSATChernoffCollapse
lake build Survival.QColoringChernoffCollapse
lake build Survival.NAESATChernoffCollapse
lake build Survival.ForbiddenPatternCSPChernoffCollapse
lake build Survival.MultiForbiddenPatternCSP
lake build Survival.HypergraphColoringChernoffCollapse
lake build Survival.CardinalitySATChernoffCollapse
lake build Survival.ThresholdCardinalitySATChernoffCollapse
lake build Survival.ExactlyOneSATChernoffCollapse
lake build Survival.BinarySymmetricChannel
lake build Survival.LinearCodeBECCapacityStyleBoundary
```

---

## Citation

```bibtex
@software{survival_lean,
  author = {Akihito Sunagawa},
  title = {Survival Model: Formal Verification in Lean 4},
  year = {2026},
  url = {https://github.com/karesansui-u/delta-survival-papers/tree/main/lean}
}
```

## License

Apache 2.0 (matching Mathlib)
