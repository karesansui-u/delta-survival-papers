# Structural Persistence Theory: A Formally Verified Universal Framework for Measuring Irreversible Loss

**Akihito Sunagawa**

## Abstract

We present Structural Persistence Theory (SPT), a mathematical framework for measuring how viable structure is irreversibly consumed over time. The theory rests on two conditions: (1) the viable region has positive measure, and (2) recovery is never free. From these alone, a representation theorem forces the loss function to take the form f(r) = −k log r, yielding the unique persistence kernel S = M exp(−L). An impossibility theorem excludes all non-logarithmic alternatives. The structural second law — that cumulative total production Σ is monotone nondecreasing — is proved as a necessary and sufficient characterization under these conditions.

The entire framework, comprising 342 Lean 4 modules with zero sorry/admit/axiom, has been machine-verified. The formalization includes: the representation and impossibility theorems; a generic cross-class theorem covering arbitrary structural maintenance problems; the three-layer structural second law (deterministic, stochastic, coarse-graining); and formal bridges to 60+ fields including thermodynamics, information theory, quantum mechanics, evolutionary biology, financial mathematics, control theory, and cosmology. Conditional bridges to classical results — including Shannon's uniqueness theorem, Jaynes' maximum entropy principle, Landauer's principle, and the Crooks fluctuation theorem — are formalized as accounting readouts of the same axiom system, under domain-specific witnesses.

The theory's scope is characterized from both sides: every system satisfying the two conditions admits exactly one accounting form, and every system violating either condition has a formally identified failure mode. No gap exists between applicability and inapplicability.

**Keywords:** structural persistence, representation theorem, formal verification, Lean 4, second law, log-ratio loss, universal framework

---

## 1. Introduction

Across physics, biology, economics, and engineering, the exponential function exp(−L) appears as a survival factor, retention probability, or decay rate. Typically, each field derives this form from domain-specific assumptions: the Boltzmann factor from statistical mechanics, Shannon entropy from communication axioms, survival functions from hazard rate models. These derivations appear independent.

We show they are not. A single axiom system — normalization, additivity, continuity, and nonnegativity of the loss function — uniquely forces the logarithmic form. Combined with two minimal physical conditions (positive measure and non-free recovery), this yields a universal persistence kernel S = M exp(−L) that subsumes all domain-specific instances as corollaries.

The contribution is threefold:

1. **Representation theorem**: The loss function −k log r is the unique function satisfying the axioms (§3). An impossibility theorem excludes all alternatives (§3.3).

2. **Structural second law**: Cumulative total production Σ is monotone nondecreasing, proved as a necessary and sufficient characterization (§4). This holds at three layers: deterministic, stochastic (expectation-level), and coarse-graining transfer (§4.2).

3. **Machine-verified formalization**: 342 Lean 4 modules, zero sorry/admit/axiom, covering the core theory and 60+ field connections (§6).

## 2. Setup

### 2.1 Structural maintenance problem

A **structural maintenance problem** consists of:
- A state space X
- A dynamics D = (contract, repair) where contract shrinks and repair expands the viable region
- A mass model m : Set X → ℝ with m(A) ≤ m(B) whenever A ⊆ B

The **feasible region** V^(n) evolves as:

    V^(n+1) = repair_n(contract_n(V^(n)))

### 2.2 Stage loss and cumulative loss

The **stage loss** at step i is:

    l_i = −log(m(V^(i+1)) / m(V^(i)))

The **cumulative loss** is L_n = Σ_{i=0}^{n-1} l_i.

### 2.3 Recovery and net consumption

With repair, the net consumption per step is:

    b_t = d_t − r_t

where d_t = −log(m(V_t^−) / m(V^(t))) is contraction loss and r_t = log(m(V^(t+1)) / m(V_t^−)) is recovery gain. The cumulative net consumption is B_n = Σ b_t.

### 2.4 Total production

Under a **repair budget** (gain ≤ cost at each step), total production is:

    Σ_n = B_n + C_n

where C_n is cumulative repair cost. This decomposes as Σ_n = L_n + slack_n, where slack ≥ 0.

## 3. The Representation Theorem

### 3.1 Axioms

A **persistence functional** consists of a loss function f : (0,1] → ℝ satisfying:

- **B2 (Normalization)**: f(1) = 0
- **B3 (Additivity)**: f(r₁ r₂) = f(r₁) + f(r₂) for all r₁, r₂ ∈ (0,1]
- **B4 (Continuity)**: f is continuous
- **Nonnegativity**: f(r) ≥ 0 for r ∈ (0,1]

### 3.2 Uniqueness

**Theorem 1 (Representation).** Any persistence functional must have loss function f(r) = −k log r for some k ≥ 0.

*Proof.* B3 is the Cauchy functional equation f(xy) = f(x) + f(y) on (0,1]. Under B4 (continuity), the unique solution is f(r) = c · log r for some constant c. B2 gives f(1) = 0 (automatically satisfied). Nonnegativity on (0,1] forces c ≤ 0, so f(r) = −k log r with k = −c ≥ 0. □

**Corollary 1 (Persistence kernel).** For any positive mass sequence with the above axioms:

    m(V^(n)) = m(V^(0)) · exp(−k · Σ l_i)

At the unit convention k = 1, this is S = M exp(−L).

**Corollary 2 (Coefficient uniqueness).** The constant k is unique.

### 3.3 Impossibility

**Theorem 2 (Impossibility).** No non-logarithmic function satisfies B2 + B3 + B4 + nonnegativity simultaneously. In particular:

- Linear functions a(1−r) violate B3 (additivity)
- Quadratic functions a(1−r)² violate B3
- Power functions ar^α (α ≠ 0) violate B3

### 3.4 Shannon analogy

The representation theorem is the structural-persistence analogue of Shannon's uniqueness theorem for entropy (1948). Both derive from the Cauchy functional equation; both force a logarithmic form from minimal axioms. The key difference is the domain: Shannon measures message uncertainty, SPT measures viable-set shrinkage.

## 4. The Structural Second Law

### 4.1 Statement

**Theorem 3 (Structural Second Law).** For any structural maintenance class satisfying (1) positive masses and (2) gain ≤ cost:

    Σ_{n+1} ≥ Σ_n for all n

That is, cumulative total production is monotone nondecreasing.

**Theorem 4 (Converse).** Σ monotone nondecreasing ⟺ stepTotalProduction ≥ 0 at every step.

### 4.2 Three layers

The structural second law holds at three levels:

1. **Deterministic**: Σ_n is pointwise monotone (Theorem 3)
2. **Stochastic**: E[Σ_n] is monotone when one-step increments are a.s. nonneg
3. **Coarse-graining**: monotonicity transfers through admissible coarse-graining with uniform mass scaling and cost-invariant budgeting

### 4.3 Necessity of conditions

**Theorem 5 (Free Repair Impossibility).** If gain > cost is allowed at any step, there exist trajectories where Σ decreases. The resource constraint is necessary for the second law.

**Theorem 6 (Minimal Axioms).** The two conditions (positive mass, gain ≤ cost) are both necessary and jointly sufficient. No condition can be dropped.

## 5. Complete Scope Closure

The theory's applicability is characterized from both sides:

### 5.1 Applicable systems

Every system with m > 0 and gain ≤ cost admits the unique form S = M exp(−L). The axiom system is minimal, the form is unique, and the second law holds.

### 5.2 Inapplicable systems

| Condition violated | Failure mode | Formal proof |
|---|---|---|
| m = 0 (zero mass) | Log-ratio undefined | ScopeBoundaryTheorem |
| m < 0 (negative mass) | Physically meaningless | CompleteScopeClosure |
| gain > cost (free repair) | Second law violated | FreeRepairImpossibility |
| Constant mass | L = 0 (theory trivial) | ScopeBoundaryTheorem |
| Unbounded mass | Losses unbounded | CompleteScopeClosure |

No sixth category exists. Every system is classified.

## 6. Lean 4 Formalization

The formalization comprises 342 modules (3,488 build jobs) with:
- 0 `sorry` (unfinished proofs)
- 0 `admit` (assumed lemmas)
- 0 declared `axiom` beyond Lean/Mathlib foundations

### 6.1 Core modules

| Module | Content |
|---|---|
| RepresentationTheorem | B2+B3+B4+nonneg → f = −k log r |
| ImpossibilityTheorem | Non-log → axiom violation |
| StructuralSecondLaw | Three-layer Σ monotonicity |
| CrossClassUnificationV3 | Generic cross-class theorem |
| CompleteScopeClosure | Full inside/outside characterization |
| ConverseSecondLaw | Σ monotone ⟺ nonneg production |
| MinimalAxiomTheorem | 2 conditions are minimal and sufficient |

### 6.2 Conditional bridges to classical results

Each bridge formalizes the algebraic readout of the SPT kernel in a specific domain, under domain-specific witnesses. These are not unconditional proofs of the original theorems but conditional accounting correspondences.

| Bridge | Module |
|---|---|
| Shannon uniqueness | RepresentationTheorem (shannon_analogy) |
| Jaynes MaxEnt | JaynesMaxEntTheorem |
| Landauer principle | LandauerPrincipleBridge |
| Rao-Blackwell | RaoBlackwellTheorem |
| Shannon coding | ShannonCodingTheorem |
| Crooks-Jarzynski | CrooksCompleteTheorem |
| Birkhoff ergodic | BirkhoffErgodicBridge |
| Discrete Gronwall | GronwallBridge |
| Gibbs inequality | KLCompleteBridge |
| Fisher fundamental theorem | FisherFundamentalTheorem |

### 6.3 Field connections (60+)

The formalization includes conditional bridges to: thermodynamics (zeroth through third law readouts), quantum mechanics (uncertainty, Pauli, Bell, CPT), statistical mechanics (Boltzmann, Crooks, Jarzynski, Ising, fluctuation-dissipation), information theory (Shannon, Rényi, Huffman, channel capacity), probability (martingale convergence, large deviations, ergodic theory, CLT, exchangeability), control theory (HJB, PID, Pontryagin, Euler-Lagrange), evolutionary biology (Fisher, Hardy-Weinberg, Wright-Fisher), ecology (Lotka-Volterra, ecosystem resilience), molecular biology (Michaelis-Menten, DNA replication), pharmacokinetics, financial mathematics (Black-Scholes, Kelly, Arrow-Pratt), social science (Nash, Arrow impossibility, Dunbar, organizational decay), computer science (PageRank, RSA, MCMC, softmax, Kolmogorov complexity, Gödel), materials science (creep, corrosion, fatigue), geoscience (plate tectonics, climate), neuroscience (Hebbian, Hodgkin-Huxley, FEP, IIT), and cosmology (nucleosynthesis, CMB, stellar evolution, large-scale structure, holographic principle, heat death).

## 7. Related Work

SPT relates to but is distinct from:

- **Thermodynamics**: SPT allows B_n < 0 (net recovery); Clausius entropy never decreases in isolated systems. SPT explicitly models open systems with repair.
- **Information theory**: SPT measures viable-set shrinkage, not message uncertainty. The functional form is the same (forced by the same Cauchy equation), but the domain and interpretation differ.
- **Survival analysis**: SPT tracks set-valued dynamics with repair; survival analysis tracks individual event times. SPT's S = M exp(−L) can exceed 1.
- **Viability theory (Aubin)**: SPT does not replace viability theory but adds an accounting layer — measuring how much the viability kernel has shrunk, not just whether viable trajectories exist.

## 8. Discussion

### 8.1 Why the scope is so broad

The two conditions (m > 0, gain ≤ cost) amount to "something exists" and "there is no perpetual motion." These hold for essentially all physical, biological, economic, and computational systems. The representation theorem then forces the unique functional form. This is why conditional bridges to 60+ fields can be constructed: not because the theory was designed for each domain, but because the mathematical structure is forced by conditions that these domains share. Each bridge is conditional on domain-specific witnesses (choice of G, m, and positivity verification).

### 8.2 Limitations

- **No dynamics**: SPT provides accounting, not dynamical equations. "Why does this system consume at rate λ?" is answered by domain-specific physics, not by SPT.
- **G is external**: The choice of maintenance condition G (what counts as "the structure") requires domain knowledge.
- **Finite horizon**: Core results are finite-horizon. Asymptotic extensions (Doob convergence, ergodic theory) require additional assumptions.

### 8.3 The structural second law as a meta-principle

The structural second law (Σ ≥ 0 with equality iff reversible) parallels the thermodynamic second law but is more general: it applies to any system with positive measure and non-free recovery, regardless of whether the system is physical.

## 9. Conclusion

Structural Persistence Theory provides a formally verified, axiomatically grounded, scope-complete framework for measuring irreversible structural loss. The representation theorem ensures uniqueness; the impossibility theorem excludes alternatives; the complete scope closure characterizes applicability from both sides; and the Lean 4 formalization with 342 modules and zero sorry/admit provides machine-checked confidence.

Conditional bridges to classical results from thermodynamics, information theory, probability, and beyond are constructed as accounting readouts of the same two-condition axiom system. The breadth of these connections is not by design but by mathematical structure: the Cauchy functional equation admits only one continuous solution, and many domains satisfy the two conditions under appropriate domain-specific witnesses.

---

## References

1. Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27, 379–423.
2. Khinchin, A.Ya. (1957). *Mathematical Foundations of Information Theory*. Dover.
3. Aubin, J.-P. (1991). *Viability Theory*. Birkhäuser.
4. Crooks, G.E. (1999). Entropy production fluctuation theorem. *Physical Review E*, 60, 2721.
5. Jarzynski, C. (1997). Nonequilibrium equality for free energy differences. *Physical Review Letters*, 78, 2690.
6. Friston, K. (2010). The free-energy principle: a unified brain theory? *Nature Reviews Neuroscience*, 11, 127–138.
7. Fisher, R.A. (1930). *The Genetical Theory of Natural Selection*. Clarendon Press.
8. Landauer, R. (1961). Irreversibility and heat generation in the computing process. *IBM Journal of Research and Development*, 5, 183–191.

---

## Appendix A: Lean Module Index

The complete formalization is available at:
https://github.com/karesansui-u/delta-survival-papers/tree/main/lean

Build: `lake build Survival` (requires Lean 4 + Mathlib v4.26.0)

342 modules. 3,488 build jobs. sorry = 0. admit = 0. axiom = 0.
