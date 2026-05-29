# Structural Persistence Theory: Representation Theorem, Second Law, and Formal Verification

**Akihito Sunagawa**

## Abstract

We present Structural Persistence Theory (SPT), a framework for measuring how viable structure is irreversibly lost. The theory rests on two conditions: (1) the viable set has positive measure, and (2) repair is never free. A representation theorem, derived from the Cauchy functional equation under normalization, additivity, continuity, and nonnegativity, forces the stage-loss function to be f(r) = −k log r. An impossibility theorem excludes all non-logarithmic alternatives. The persistence kernel m(V_n) = m(V_0) exp(−L_n) follows as a telescoping identity. With repair, the net loss b_t = d_t − r_t replaces stage loss, giving m(V_n) = m(V_0) exp(−B_n). The structural second law — that cumulative total production Σ_n is monotone nondecreasing — is proved as a necessary and sufficient characterization.

The formalization comprises 394 Lean 4 modules with zero sorry/admit/axiom. Conditional bridges to classical results — Shannon's uniqueness theorem, Jaynes' maximum entropy principle, Landauer's principle, the Crooks fluctuation theorem, and others — are constructed as accounting readouts under domain-specific witnesses. The theory's scope is characterized from both sides: every system satisfying the two conditions admits exactly one loss-measurement form, and every system violating either condition has a formally identified failure mode.

---

## 1. Introduction

### 1.1 The question

Structure can be lost even when resources remain. An organization may retain budget and personnel yet lose the ability to make coherent decisions. Software may retain computational resources yet become unmaintainable as dependency conflicts accumulate. A long-context language model may retain parameters yet lose logical consistency as unresolved contradictions build up.

In each case, what is lost is not the substrate but the set of states that can still sustain the structure. SPT formalizes this observation: structural loss is the shrinkage of the viable set, measured by a log-ratio scale that is uniquely forced by natural axioms.

### 1.2 Contributions

1. **Representation theorem**: Under normalization, additivity, continuity, and nonnegativity, the stage-loss function must be f(r) = −k log r. No other form is consistent (§3).

2. **Structural second law**: Cumulative total production Σ_n is monotone nondecreasing, proved as necessary and sufficient under two conditions: positive measure and non-free repair (§4).

3. **Formal verification**: 394 Lean 4 modules, zero sorry/admit/axiom, with conditional bridges to 60+ fields (§6).

### 1.3 What this paper does not claim

- SPT does not claim that all systems decay exponentially. The exponential form is a representation theorem for the viable-set measure, not an empirical law about any specific system.
- SPT does not replace domain-specific dynamics. It provides the accounting coordinates; the dynamics are supplied by each domain.
- The conditional bridges are not unconditional proofs of classical theorems. Each bridge requires domain-specific witnesses (choice of viable set V, measure m, and positivity verification).

### 1.4 What is not mathematically new

- The **representation theorem** is a standard consequence of the Cauchy functional equation (19th century). The application to viable-set ratios is the contribution, not the equation itself.
- The **persistence kernel** m(V_n) = m(V_0) exp(−L_n) is a **telescoping identity** — a definitional rewriting, not an empirical discovery.
- The **structural second law** (Σ monotone) is trivially true given the assumption of nonneg step production. The non-trivial content is in the **necessity theorems**: FreeRepairImpossibility shows that relaxing gain ≤ cost breaks monotonicity; ConverseSecondLaw shows the characterization is biconditional.
- In **loss-only mode** (no repair), SPT's cumulative net action coincides exactly with the **cumulative hazard** of survival analysis (Λ(t) = −log S(t)). The structural difference lies in the repair term: SPT's signed net action b_t = d_t − r_t can be negative (net recovery), which cumulative hazard cannot. This is proved in NonIdentityTheorem.
- Of the ~394 Lean modules, approximately 20 are **Tier A** (core-routed, with non-trivial conclusions). Approximately 160 are **Tier C** (vocabulary mappings, not theorems). The mathematical weight is concentrated in Tier A and the core.

## 2. Setup

### 2.1 Structural maintenance problem

Fix a system X. A **structural maintenance problem** Π = (X, G) consists of:

- A state space X
- A maintenance condition G that defines which states can sustain the structure
- The **viable set** V_G = {x ∈ X : x satisfies G} — following Aubin's viability theory (1991)
- A **measure** m on X, fixed before observation, that quantifies the "room remaining"

### 2.2 Viable-set dynamics

Constraints accumulate over time:

    V_0 ⊇ V_1 ⊇ ··· ⊇ V_n

Each step consists of **contraction** (constraints shrink V) followed by **repair** (recovery expands V):

    V_t^− = K_t(V_t)          [contraction stage]
    V_{t+1} = R_t(V_t^−)        [repair stage]

### 2.3 Stage loss and repair

The **stage loss** at step t:

    d_t = −log(m(V_t^−) / m(V_t))

The **repair amount** at step t:

    r_t = log(m(V_{t+1}) / m(V_t^−))

The **net loss**:

    b_t = d_t − r_t

These terms follow the terminology of loss/repair standard in information theory and reliability engineering. The v4 naming aligns with Aubin (viable set), Shannon (stage loss), and engineering (repair).

### 2.4 Cumulative quantities

Cumulative stage loss: L_n = Σ_{t<n} d_t

Cumulative net loss: B_n = Σ_{t<n} b_t

Effective resource: M_n, evolving as M_{n+1} = M_n + income_n − cost_n

### 2.5 Total production

Under a **repair budget** (repair gain ≤ repair cost at each step), total production is:

    Σ_n = B_n + C_n = L_n + slack_n

where C_n is cumulative repair cost and slack_n = C_n − (cumulative gain) ≥ 0.

## 3. The Representation Theorem

### 3.1 Axioms for stage loss

A **stage-loss functional** f : (0,1] → ℝ satisfying:

- **B2 (Normalization)**: f(1) = 0 — no shrinkage, no loss
- **B3 (Additivity)**: f(r₁ r₂) = f(r₁) + f(r₂) — sequential losses compose
- **B4 (Continuity)**: f is continuous — small changes, small losses
- **Nonnegativity**: f(r) ≥ 0 for r ∈ (0,1] — shrinkage is nonnegative loss

### 3.2 Uniqueness

**Theorem 1 (Representation).** Any stage-loss functional satisfying B2+B3+B4+nonnegativity must have:

    f(r) = −k log r,  k ≥ 0

*Proof sketch.* B3 is the Cauchy functional equation f(xy) = f(x) + f(y). Under B4 (continuity), the unique solution is f(r) = c · log r. B2 is automatic. Nonnegativity on (0,1] forces c ≤ 0, giving f(r) = −k log r with k ≥ 0. Lean: `RepresentationTheorem.loss_must_be_log`. □

*Note.* This is a classical result (Cauchy 1821, applied to entropy by Shannon 1948). The mathematical content is the application to viable-set ratios, not the equation itself.

**Corollary (Persistence kernel).** For any positive mass sequence:

    m(V_n) = m(V_0) · exp(−L_n)

where L_n = Σ l_i. At k = 1 (structural nats), S = M exp(−L). Lean: `TelescopingExp.measure_eq_initial_mul_exp_neg_cumulative_loss`.

### 3.3 Impossibility

**Theorem 2 (Impossibility).** No non-logarithmic function satisfies B2+B3+B4+nonnegativity.

- Linear a(1−r) violates B3
- Quadratic a(1−r)² violates B3
- Power ar^α (α ≠ 0) violates B3

Lean: `ImpossibilityTheorem.impossibility_of_non_log`.

### 3.4 Relation to Shannon

The representation theorem has the same mathematical skeleton as Shannon's uniqueness theorem for entropy (1948). Both derive from the Cauchy functional equation; both force a logarithmic form. The difference is in the domain: Shannon measures message uncertainty; SPT measures viable-set shrinkage. Lean: `RepresentationTheorem.shannon_analogy`.

SPT does not claim to be Shannon's theorem. It shares a common mathematical ancestor (the Cauchy equation) and records the correspondence (`NonIdentityTheorem`).

## 4. The Structural Second Law

### 4.1 Statement

**Theorem 3 (Structural Second Law).** Under:
1. Positive trajectory (m(V_t) > 0 for all t)
2. Repair budget (gain ≤ cost at each step)

cumulative total production Σ_n is monotone nondecreasing.

Lean: `StructuralSecondLaw.deterministic_second_law`.

*Note.* This inequality is trivially true given the assumption: nonneg terms sum to a monotone sequence. The non-trivial content is in Theorems 4-6 below, which show the characterization is biconditional and the resource constraint is necessary.

**Theorem 4 (Converse).** Σ_n monotone ⟺ stepTotalProduction ≥ 0 at every step.

Lean: `ConverseSecondLaw.second_law_iff_nonneg_steps`.

### 4.2 Three layers

| Layer | Statement | Lean module |
|-------|-----------|-------------|
| Deterministic | Σ_n pointwise monotone | `StructuralSecondLaw.deterministic_second_law` |
| Stochastic | E[Σ_n] monotone (a.s. nonneg increments) | `StructuralSecondLaw.stochastic_second_law` |
| Coarse-graining | Monotonicity transfers through admissible maps | `StructuralSecondLaw.coarse_second_law` |

### 4.3 Necessity of conditions

**Theorem 5 (Free Repair Impossibility).** If gain > cost at any step, Σ can decrease. The repair budget is necessary. Lean: `FreeRepairImpossibility.free_repair_implies_negative_production`.

**Theorem 6 (Minimal Axioms).** The two conditions are minimal and jointly sufficient. Lean: `MinimalAxiomTheorem.minimal_axioms_give_monotone_sigma`.

## 4b. Resource Dynamics (M-side)

The resource level M was previously treated as a static parameter. It is now dynamically tracked:

    M_{n+1} = M_n + income_n − cost_n

**Theorem 7 (Resource depletion).** If cumulative cost exceeds initial M plus cumulative income, M becomes negative. Lean: `ResourceDynamics.resource_depleted_when_cost_exceeds`.

**Theorem 8 (M-side second law).** Without external income, M is nonincreasing. Lean: `ResourceDynamics.closed_system_M_nonincreasing`.

**Theorem 9 (Dual collapse).** S = M · (m_n/m_0) collapses when EITHER M ≤ 0 (resource exhaustion) OR m_n = 0 (structural death). These are independent failure modes. Lean: `ResourceDynamics.M_collapse_kills_persistence`, `ResourceDynamics.persistence_requires_M_positive`.

This completes the S = M exp(−L) picture: both factors are now dynamically tracked, and the theory formally distinguishes L-side collapse (structural consumption exceeds repair) from M-side collapse (resources exhausted).

## 5. Complete Scope Closure

### 5.1 Applicable systems

Every system with m > 0 and gain ≤ cost admits the unique form S = M exp(−L). The two conditions are necessary and sufficient. The functional form is unique and the axiom system is minimal.

### 5.2 Inapplicable systems

| Condition violated | Failure mode | Lean proof |
|--------------------|-------------|------------|
| m = 0 | Log-ratio undefined | `ScopeBoundaryTheorem` |
| m < 0 | Physically meaningless | `CompleteScopeClosure` |
| gain > cost | Second law violated | `FreeRepairImpossibility` |
| Constant mass | L = 0 (theory trivial) | `ScopeBoundaryTheorem` |

No fifth category exists. Lean: `CompleteScopeClosure.classification_exhaustive`.

## 6. Lean 4 Formalization

### 6.1 Scale

- 394 modules, 3,500+ build jobs
- sorry = 0, admit = 0, axiom = 0
- Lean 4 v4.26.0 + Mathlib v4.26.0
- Repository: https://github.com/karesansui-u/persistence-lean

### 6.2 Architecture

The formalization is organized in layers:

| Layer | Modules | Content |
|-------|---------|---------|
| 0–4 | Core kernel | Telescoping, log-uniqueness, resource budget, dynamics |
| 5–6 | SAT/CSP | Finite-horizon Chernoff/KL bounds, 9 CSP specializations |
| 7–8 | Markov models | Foster-Lyapunov, finite-state Markov, repair chains |
| 9 | Route A skeletons | Serial reliability, BSC, fatigue, queue, etc. |
| 10–11 | Unification | CrossClassV0–V3, StructuralSecondLaw |
| Tier S | Meta-theorems | Representation, Impossibility |
| Tier S+ | Necessity | FreeRepair, MinimalAxiom, Separation, Converse |
| Tier S++ | Completeness | Stability, Duality, Invariance, CompleteScopeClosure |
| Tier S+++ | Validation | Falsifiability, NonIdentity, Constructive, TimeReversal |

### 6.3 Conditional bridges (honest tier classification)

The ~394 modules include cross-domain bridges at three tiers:

- **Tier A (~20 bridges)**: Invoke the SPT core (TelescopingExp, StructuralSecondLaw, or ImpossibilityTheorem) to derive domain conclusions that don't follow from single-step properties. Examples: GronwallBridge (discrete Gronwall inequality), CrooksCompleteTheorem (Jarzynski→Jensen chain), OptimalReviewSchedule (minimax via pigeonhole).
- **Tier B (~3 bridges)**: Algebraic correspondences with real content but no mechanical core invocation. Examples: ClausiusBridge, BoltzmannEntropyBridge, RuinTheoryBridge.
- **Tier C (~160 bridges)**: Vocabulary mappings that read domain quantities through SPT terminology. These are **not** theorems. Some contain lightweight algebra; others are naming conventions.

The mathematical weight is in Tier A and the core. Tier C exists for completeness but carries no proof weight.

## 7. Three Observability Layers

Following v4, the theory operates at three observability layers:

| Layer | Observability | Role |
|-------|--------------|------|
| **Specification-fixed** | V, m, boundary fixed by specification | Theorems, finite-time bounds, strong verification |
| **Conditional embedding** | Existing theory's drift/difference mapped to SPT variables | Formal bridges to Foster-Lyapunov, queueing, etc. |
| **Structural estimation** | V not directly countable; proxy indicators + pre-registered tests | Prediction, diagnosis, intervention candidates |

These are not three different theories. They are three observability levels of the same kernel S = M exp(−L). The difference is how much of V, m, d_t, r_t can be directly observed or specified.

## 8. Related Work

SPT relates to but is structurally distinct from:

- **Thermodynamics**: SPT allows B_n < 0 (net repair exceeds loss); Clausius entropy is nondecreasing in isolated systems. SPT models open systems with repair. (`NonIdentityTheorem`)
- **Information theory**: SPT measures viable-set shrinkage, not message uncertainty. Same functional form, different domain. (`NonIdentityTheorem`)
- **Survival analysis**: In loss-only mode (no repair, M = 1), SPT's cumulative net action **coincides exactly** with the cumulative hazard Λ(t) = −log S(t). The structural difference is the repair term: SPT's signed net action b_t = d_t − r_t can be negative (net recovery), breaking the monotonicity that cumulative hazard enforces by definition. The resource axis M provides a second independent coordinate. (`NonIdentityTheorem.loss_only_coincides_with_hazard`)
- **Viability theory (Aubin 1991)**: SPT adds an accounting layer to viability theory — measuring how much the viable kernel has shrunk, not just whether viable trajectories exist. (`ViabilityKernelBridge`)

## 9. Limitations

- **No dynamics**: SPT accounts for structural loss but does not supply dynamical equations.
- **G is external**: The choice of maintenance condition requires domain knowledge.
- **Finite horizon**: Core results are finite-horizon. Asymptotic extensions require additional assumptions.
- **Bridges are conditional**: Each domain bridge requires domain-specific witnesses.

## 10. Conclusion

Structural Persistence Theory provides a formally verified framework for measuring irreversible structural loss. Two conditions — positive measure and non-free repair — are necessary and sufficient. The representation theorem forces the unique form f(r) = −k log r. The impossibility theorem excludes alternatives. The complete scope closure characterizes applicability from both sides.

The breadth of conditional bridges — to thermodynamics, information theory, quantum mechanics, biology, economics, and beyond — follows from mathematical structure: the Cauchy functional equation admits only one continuous solution, and many domains satisfy the two conditions under appropriate witnesses. This breadth is not a claim of universality by fiat, but a consequence of the axioms being weak enough to apply broadly while still forcing a unique functional form.

The Lean 4 formalization with 394 modules and zero sorry/admit provides machine-checked confidence in the mathematical core. The domain bridges provide conditional correspondences, each requiring explicit witnesses, and each open to independent verification.

---

## References

1. Aubin, J.-P. (1991). *Viability Theory*. Birkhäuser.
2. Aubin, J.-P., Bayen, A.M., and Saint-Pierre, P. (2011). *Viability Theory: New Directions*. Springer.
3. Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27, 379–423.
4. Khinchin, A.Ya. (1957). *Mathematical Foundations of Information Theory*. Dover.
5. Crooks, G.E. (1999). Entropy production fluctuation theorem. *Physical Review E*, 60, 2721.
6. Jarzynski, C. (1997). Nonequilibrium equality for free energy differences. *Physical Review Letters*, 78, 2690.
7. Friston, K. (2010). The free-energy principle: a unified brain theory? *Nature Reviews Neuroscience*, 11, 127–138.
8. Landauer, R. (1961). Irreversibility and heat generation in the computing process. *IBM Journal of Research and Development*, 5, 183–191.
9. Fisher, R.A. (1930). *The Genetical Theory of Natural Selection*. Clarendon Press.

---

## Appendix: Repository

Lean formalization: https://github.com/karesansui-u/persistence-lean

Paper repository: https://github.com/karesansui-u/delta-survival-papers

Build: `lake build Persistence` (Lean 4 v4.26.0 + Mathlib v4.26.0)

394 modules. 3,500+ build jobs. sorry = 0. admit = 0. axiom = 0.

10. Boltzmann, L. (1877). Über die Beziehung zwischen dem zweiten Hauptsatze der mechanischen Wärmetheorie und der Wahrscheinlichkeitsrechnung. *Wiener Berichte*, 76, 373–435.
11. Doob, J.L. (1953). *Stochastic Processes*. Wiley.
12. Hyers, D.H. (1941). On the stability of the linear functional equation. *Proceedings of the National Academy of Sciences*, 27, 222–224.
13. Banach, S. (1922). Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales. *Fundamenta Mathematicae*, 3, 133–181.
