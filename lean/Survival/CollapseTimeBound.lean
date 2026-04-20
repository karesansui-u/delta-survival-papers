import Mathlib.Tactic.Linarith
import Survival.MinimumRepairRate

/-!
Collapse Time Bound
崩壊時点境界の operational theorem

This module extracts a deterministic collapse-bound theorem from the signed
exponential kernel.

The basic logic is:

* if cumulative net action is large enough by time `n`,
* then feasible mass must have dropped below a prescribed fraction `θ`
  of its initial value.

Using the repair-budget inequality `cumulativeGain ≤ cumulativeCost`, this also
gives a sufficient collapse condition in terms of cumulative contraction loss
and available repair budget.
-/

namespace Survival.CollapseTimeBound

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.MinimumRepairRate

noncomputable section

variable {X : Type*}

/-- Collapse below the fraction `θ` at time `n`. -/
def CollapsedAtFraction (P : ProblemSpec X) (n : ℕ) (θ : ℝ) : Prop :=
  feasibleMass P n ≤ θ * feasibleMass P 0

/-- A lower bound on cumulative net action implies an upper bound on feasible
mass. -/
theorem feasibleMass_le_of_cumulativeNetAction_lower_bound
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P n)
    {a : ℝ} (ha : a ≤ cumulativeNetAction P n) :
    feasibleMass P n ≤ feasibleMass P 0 * Real.exp (-a) := by
  rw [feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n hpos]
  have hexp : Real.exp (-cumulativeNetAction P n) ≤ Real.exp (-a) := by
    exact Real.exp_le_exp_of_le (by linarith)
  exact mul_le_mul_of_nonneg_left hexp (le_of_lt (hpos.feasible_pos 0 (Nat.zero_le n)))

/-- If cumulative net action exceeds `-log θ`, collapse below `θ` has already
occurred by time `n`. -/
theorem collapsedAtFraction_of_cumulativeNetAction_lower_bound
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (ha : -Real.log θ ≤ cumulativeNetAction P n) :
    CollapsedAtFraction P n θ := by
  unfold CollapsedAtFraction
  calc
    feasibleMass P n ≤ feasibleMass P 0 * Real.exp (-(-Real.log θ)) :=
      feasibleMass_le_of_cumulativeNetAction_lower_bound P n hpos ha
    _ = feasibleMass P 0 * θ := by rw [neg_neg, Real.exp_log hθ]
    _ = θ * feasibleMass P 0 := by ring

/-- Since `cumulativeNetAction = cumulativeLoss - cumulativeGain` and repair is
budget-limited, a sufficiently large value of `cumulativeLoss - cumulativeCost`
forces collapse below the fraction `θ`. -/
theorem collapsedAtFraction_of_loss_minus_cost_lower_bound
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (ha : -Real.log θ ≤ cumulativeLoss P n - cumulativeCost B n) :
    CollapsedAtFraction P n θ := by
  have hgain : cumulativeGain P n ≤ cumulativeCost B n :=
    cumulativeGain_le_cumulativeCost B n
  have hnet :
      cumulativeLoss P n - cumulativeCost B n ≤ cumulativeNetAction P n := by
    rw [cumulativeNetAction_eq_cumulativeLoss_sub_cumulativeGain]
    linarith
  exact collapsedAtFraction_of_cumulativeNetAction_lower_bound P n hpos hθ (le_trans ha hnet)

end

end Survival.CollapseTimeBound
