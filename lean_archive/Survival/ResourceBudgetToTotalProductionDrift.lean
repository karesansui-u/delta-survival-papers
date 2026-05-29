import Mathlib.Tactic.Linarith
import Survival.ResourceBoundedDynamics

/-!
# Resource Budget to Total-Production Drift

This module isolates the small but important bridge from a lower bound on
contraction loss to a lower bound on total production.

The resource budget alone gives nonnegative repair slack:

  stepRepairSlack = stepCost - stepGain ≥ 0.

Therefore any domain-specific lower bound on `stepLoss` immediately lifts to
the same lower bound on `stepTotalProduction = stepLoss + stepRepairSlack`.

This is the generic place where domain-specific "typical contraction" facts can
be connected to the `Σ`-based law-of-tendency layer.
-/

open scoped BigOperators
open Finset

namespace Survival.ResourceBudgetToTotalProductionDrift

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics

noncomputable section

variable {X : Type*}

/-- Any lower bound on one-step contraction loss lifts to the same lower bound
on one-step total production under a repair budget. -/
theorem stepTotalProduction_lowerBound_of_stepLoss_lowerBound
    {P : ProblemSpec X} (B : RepairBudget P) {t : ℕ} {α : ℝ}
    (hloss : α ≤ stepLoss P t) :
    α ≤ stepTotalProduction B t := by
  rw [stepTotalProduction_eq_stepLoss_add_stepRepairSlack]
  have hslack : 0 ≤ stepRepairSlack B t := stepRepairSlack_nonneg B t
  linarith

/-- Uniform one-step lower bounds on contraction loss lift to a linear lower
bound on cumulative total production. -/
theorem cumulativeTotalProduction_lowerBound_of_stepLoss_lowerBound
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) {α : ℝ}
    (hloss : ∀ t ∈ Finset.range n, α ≤ stepLoss P t) :
    (n : ℝ) * α ≤ cumulativeTotalProduction B n := by
  rw [cumulativeTotalProduction_eq_cumulativeLoss_add_cumulativeRepairSlack]
  have hsum : (n : ℝ) * α ≤ cumulativeLoss P n := by
    unfold cumulativeLoss
    calc
      (n : ℝ) * α = ∑ t ∈ Finset.range n, α := by
        simp
      _ ≤ ∑ t ∈ Finset.range n, stepLoss P t := by
        refine Finset.sum_le_sum ?_
        intro t ht
        exact hloss t ht
  have hslack : 0 ≤ cumulativeRepairSlack B n := cumulativeRepairSlack_nonneg B n
  linarith

/-- If contraction loss is bounded below by a strictly positive constant at
every step, then cumulative total production has linear positive drift. -/
theorem cumulativeTotalProduction_linear_pos_drift
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) {α : ℝ}
    (hα : 0 < α)
    (hloss : ∀ t ∈ Finset.range n, α ≤ stepLoss P t) :
    0 < cumulativeTotalProduction B n + 1 := by
  have hlin :
      (n : ℝ) * α ≤ cumulativeTotalProduction B n :=
    cumulativeTotalProduction_lowerBound_of_stepLoss_lowerBound B n hloss
  have hnonneg : 0 ≤ (n : ℝ) * α := by positivity
  linarith

end

end Survival.ResourceBudgetToTotalProductionDrift
