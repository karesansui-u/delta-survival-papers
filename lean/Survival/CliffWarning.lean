import Mathlib.Tactic.Linarith
import Survival.CollapseTimeBound

/-!
Cliff Warning
cliff の事前識別条件

This module formalizes a conservative early-warning condition for imminent
collapse.

The key quantity is the remaining safety margin

  remainingMargin = -log θ - cumulativeNetAction.

If this margin is already nonpositive, collapse below `θ` has already occurred.
If the remaining margin is no larger than a certified lower bound on the next
step net action, then collapse below `θ` will occur at the next step.

Using the repair-budget inequality `stepGain ≤ stepCost`, the lower bound
`stepLoss - stepCost ≤ stepNetAction` gives a concrete pre-identification
criterion.
-/

namespace Survival.CliffWarning

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.CollapseTimeBound

noncomputable section

variable {X : Type*}

/-- Collapse threshold corresponding to the retention fraction `θ`. -/
def collapseThreshold (θ : ℝ) : ℝ :=
  -Real.log θ

/-- Remaining safety margin before crossing the collapse threshold. -/
def remainingMargin (P : ProblemSpec X) (n : ℕ) (θ : ℝ) : ℝ :=
  collapseThreshold θ - cumulativeNetAction P n

/-- One-step recursion for cumulative net action. -/
theorem cumulativeNetAction_succ
    (P : ProblemSpec X) (n : ℕ) :
    cumulativeNetAction P (n + 1) =
      cumulativeNetAction P n + stepNetAction P n := by
  unfold cumulativeNetAction
  rw [Finset.sum_range_succ]

/-- If the remaining safety margin is already nonpositive, collapse has already
occurred. -/
theorem collapsedAtFraction_of_remainingMargin_nonpos
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hmargin : remainingMargin P n θ ≤ 0) :
    CollapsedAtFraction P n θ := by
  apply collapsedAtFraction_of_cumulativeNetAction_lower_bound P n hpos hθ
  unfold remainingMargin collapseThreshold at hmargin
  linarith

/-- Generic imminent-collapse criterion:
if the remaining safety margin is no larger than a certified lower bound `a`
for the next one-step net action, collapse occurs at the next step. -/
theorem imminentCollapse_of_stepNetAction_lower_bound
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P (n + 1))
    {θ : ℝ} (hθ : 0 < θ)
    {a : ℝ}
    (hmargin : remainingMargin P n θ ≤ a)
    (ha : a ≤ stepNetAction P n) :
    CollapsedAtFraction P (n + 1) θ := by
  apply collapsedAtFraction_of_cumulativeNetAction_lower_bound P (n + 1) hpos hθ
  rw [cumulativeNetAction_succ]
  unfold remainingMargin collapseThreshold at hmargin
  linarith

/-- Concrete cliff warning under a repair budget:
since `stepGain ≤ stepCost`, the lower bound `stepLoss - stepCost` is enough to
certify next-step collapse whenever it exceeds the remaining margin. -/
theorem imminentCollapse_of_loss_minus_cost_lower_bound
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hpos : PositiveTrajectory P (n + 1))
    {θ : ℝ} (hθ : 0 < θ)
    (hmargin : remainingMargin P n θ ≤ stepLoss P n - B.stepCost n) :
    CollapsedAtFraction P (n + 1) θ := by
  apply imminentCollapse_of_stepNetAction_lower_bound P n hpos hθ hmargin
  unfold stepNetAction
  linarith [B.gain_le_cost n]

end

end Survival.CliffWarning
