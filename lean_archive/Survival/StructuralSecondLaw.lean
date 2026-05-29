import Survival.CrossClassUnificationV3
import Survival.CoarseStochasticTotalProduction

/-!
# Structural Second Law — Conditional Formulation

This module states and proves the **structural second law of persistence
accounting** in its conditional form:

> For any structural maintenance problem satisfying the four witness
> conditions of `StructuralMaintenanceClass`, the cumulative total
> production `Σ_n` is monotone nondecreasing.

This is the structural-persistence analogue of the thermodynamic second law:
structural entropy (measured by cumulative total production) does not decrease
under the stated conditions.

## Three layers

The second law is formulated at three layers of increasing generality:

1. **Deterministic layer**: `Σ_n` is pointwise monotone.
2. **Stochastic layer**: `E[Σ_n]` is monotone when one-step increments are
   a.s. nonnegative.
3. **Coarse-graining layer**: monotonicity transfers through admissible
   coarse-graining with uniform mass scaling and cost-invariant budgeting.

## What this file does NOT prove

* An unconditional second law (the conditions are load-bearing).
* Pathwise nondecrease in the stochastic layer (only expectation-level).
* Almost-sure convergence or ergodic theorems.
* Physical entropy production or Clausius inequality.

## Relationship to existing modules

* `ResourceBoundedDynamics`: proves the deterministic core.
* `StochasticTotalProduction`: proves the stochastic expectation core.
* `CrossClassUnificationV3`: provides the generic interface.
* This module **unifies** all three layers under the structural second law
  banner and adds the conditional formulation as named reader-facing theorems.
-/

namespace Survival.StructuralSecondLaw

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.TypicalNondecrease
open Survival.StochasticTotalProduction
open Survival.CrossClassUnificationV3
open Survival.CoarseGraining
open Survival.CoarseTotalProduction

noncomputable section

variable {X Y : Type*}

/-! ## Layer 1: Deterministic Structural Second Law -/

/-- **Structural Second Law (Deterministic).**

For any structural maintenance class, the cumulative total production `Σ_n`
is monotone nondecreasing.

This is the pointwise (deterministic, non-probabilistic) version of the
structural second law. It says: under resource-bounded dynamics where
repair is never free, the cumulative accounting quantity `Σ = B + C`
(net action plus resource cost) cannot decrease over time.

Interpretation: structural entropy, measured as total production, is
nondecreasing. Resources spent on repair always show up in the ledger. -/
theorem deterministic_second_law
    (C : StructuralMaintenanceClass X) :
    Monotone (cumulativeTotalProduction C.budget) :=
  (lawLikeProfile_of_class C).monotone_sigma

/-- The deterministic second law specialized to one-step increments:
each step adds nonneg total production. -/
theorem deterministic_second_law_step
    (C : StructuralMaintenanceClass X) (n : ℕ) :
    cumulativeTotalProduction C.budget n ≤
      cumulativeTotalProduction C.budget (n + 1) :=
  deterministic_second_law C (Nat.le_succ n)

/-- Structural loss is bounded above by total production (conservative bound).
This is a direct corollary: `L ≤ Σ` because `Σ = L + slack` and `slack ≥ 0`. -/
theorem loss_bounded_by_sigma
    (C : StructuralMaintenanceClass X) (n : ℕ) :
    cumulativeLoss C.problem n ≤
      cumulativeTotalProduction C.budget n :=
  (lawLikeProfile_of_class C).sigma_dominates_loss n

/-- Structural loss grows at most as fast as total production. -/
theorem loss_growth_bounded
    (C : StructuralMaintenanceClass X)
    (m n : ℕ) (hmn : m ≤ n) :
    cumulativeLoss C.problem m ≤
      cumulativeTotalProduction C.budget n :=
  le_trans (loss_bounded_by_sigma C m)
    (deterministic_second_law C hmn)

/-! ## Layer 2: Stochastic Structural Second Law -/

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : MeasureTheory.Measure Ω}
  [MeasureTheory.IsProbabilityMeasure μ]

set_option linter.unusedSectionVars false in
/-- **Structural Second Law (Stochastic / Expectation-Level).**

For any stochastic total production process with almost surely nonnegative
one-step increments, the expected cumulative total production is monotone
nondecreasing.

This is the expectation-level version: it does not claim pathwise
monotonicity in the stochastic case, only that `E[Σ_n] ≤ E[Σ_{n+1}]`.

In the deterministic embedding, this reduces to Layer 1. -/
theorem stochastic_second_law
    (S : StepModel (μ := μ))
    (hStep : AENonnegativeStepTotalProduction (μ := μ) S) :
    Monotone
      S.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    S hStep

set_option linter.unusedSectionVars false in
/-- The stochastic second law follows from a.s. nonneg net action and
a.s. nonneg cost (sufficient condition for nonneg total production). -/
theorem stochastic_second_law_of_parts
    (S : StepModel (μ := μ))
    (hA : AENonnegativeStepNetAction (μ := μ) S)
    (hC : AENonnegativeStepCost (μ := μ) S) :
    Monotone
      S.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  stochastic_second_law S
    (ae_nonnegative_stepTotalProduction_of_parts S hA hC)

/-- Deterministic embedding: the stochastic second law applied to the
deterministic step model recovers the deterministic second law
(up to the expected-process wrapper). -/
theorem deterministic_embedding_second_law
    (C : StructuralMaintenanceClass X) :
    Monotone (deterministicExpectedCumulative
      (μ := μ) C.budget) := by
  exact deterministic_expectedCumulative_monotone
    (μ := μ) C.budget C.bounded

end

/-! ## Layer 3: Coarse-Graining Transfer -/

section CoarseGrainingTransfer

variable {X Y : Type*}

/-- **Structural Second Law (Coarse-Graining Transfer).**

Monotonicity of cumulative total production transfers through admissible
coarse-graining, provided uniform mass scaling and cost-invariant budgeting
hold between micro and macro levels.

This closes the third layer: the second law is not merely a micro-level
statement but survives representation changes. -/
theorem coarse_second_law
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    Monotone (cumulativeTotalProduction Bcoarse) :=
  coarse_cumulativeTotalProduction_monotone cg hs hB R

end CoarseGrainingTransfer

/-! ## Combined Statement -/

section CombinedStatement

variable {X : Type*}

/-- **Structural Second Law (Combined Statement).**

The cumulative total production `Σ_n` of any structural maintenance class
is monotone nondecreasing, and this monotonicity:

1. holds pointwise in the deterministic setting;
2. holds in expectation in the stochastic setting
   with a.s. nonneg increments;
3. transfers through admissible coarse-graining.

Furthermore, cumulative structural loss `L_n` is bounded above by `Σ_n`
at every time step.

This structure bundles the three layers into a single record for
reader-facing reference. -/
structure StructuralSecondLawStatement
    (C : StructuralMaintenanceClass X) : Prop where
  /-- Σ is monotone nondecreasing. -/
  monotone : Monotone (cumulativeTotalProduction C.budget)
  /-- Each step contributes nonnegatively. -/
  nonneg_step : ∀ t, 0 ≤ stepTotalProduction C.budget t
  /-- Structural loss is bounded by Σ. -/
  loss_bound :
    ∀ n, cumulativeLoss C.problem n ≤
      cumulativeTotalProduction C.budget n
  /-- Expected drift is nonnegative
  (bridge to stochastic layer). -/
  nonneg_drift :
    ExpectedNonnegativeDrift
      (deterministicExpectedTotalProduction C.budget)

/-- The structural second law holds for any structural maintenance class. -/
theorem structural_second_law
    (C : StructuralMaintenanceClass X) :
    StructuralSecondLawStatement C where
  monotone := deterministic_second_law C
  nonneg_step := C.nonneg_step
  loss_bound := loss_bounded_by_sigma C
  nonneg_drift := (lawLikeProfile_of_class C).nonneg_drift

end CombinedStatement

end Survival.StructuralSecondLaw
