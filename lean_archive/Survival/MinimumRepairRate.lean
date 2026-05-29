import Mathlib.Tactic.Linarith
import Survival.TotalProduction

/-!
Minimum Repair Rate
最小修復率の operational theorem

This module extracts a first operational theorem from the signed-kernel and
resource-budget layers.

The key statement is:

* if one wants to retain at least a fraction `θ` of the initial feasible mass
  by time `n`,
* then the cumulative repair cost must be at least

  `cumulativeLoss + log θ`.

Equivalently, the average repair cost up to time `n` must exceed the same
quantity divided by `n`.

This is the first explicit "required metabolism" theorem in the Lean
development.
-/

namespace Survival.MinimumRepairRate

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction

noncomputable section

variable {X : Type*}

/-- The cumulative signed net action is cumulative loss minus cumulative gain. -/
theorem cumulativeNetAction_eq_cumulativeLoss_sub_cumulativeGain
    (P : ProblemSpec X) (n : ℕ) :
    cumulativeNetAction P n = cumulativeLoss P n - cumulativeGain P n := by
  unfold cumulativeNetAction cumulativeLoss cumulativeGain stepNetAction
  rw [Finset.sum_sub_distrib]

/-- To retain at least a factor `θ > 0` of the initial feasible mass by time
`n`, the cumulative repair cost must exceed `cumulativeLoss + log θ`. -/
theorem cumulativeCost_lower_bound_of_mass_retention
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    cumulativeLoss P n + Real.log θ ≤ cumulativeCost B n := by
  have h0 : 0 < feasibleMass P 0 := hpos.feasible_pos 0 (Nat.zero_le n)
  rw [feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n hpos] at hretain
  have hretain' :
      feasibleMass P 0 * θ ≤ feasibleMass P 0 * Real.exp (-cumulativeNetAction P n) := by
    simpa [mul_comm, mul_left_comm, mul_assoc] using hretain
  have htheta_exp : θ ≤ Real.exp (-cumulativeNetAction P n) := by
    exact le_of_mul_le_mul_left hretain' h0
  have hlog_exp : Real.log θ ≤ -cumulativeNetAction P n := by
    have hexp_le : Real.exp (Real.log θ) ≤ Real.exp (-cumulativeNetAction P n) := by
      simpa [Real.exp_log hθ] using htheta_exp
    rwa [Real.exp_le_exp] at hexp_le
  have hgain : cumulativeGain P n ≤ cumulativeCost B n :=
    cumulativeGain_le_cumulativeCost B n
  have haction :
      cumulativeNetAction P n = cumulativeLoss P n - cumulativeGain P n :=
    cumulativeNetAction_eq_cumulativeLoss_sub_cumulativeGain P n
  linarith

/-- Average repair-rate version of the previous theorem. -/
theorem averageCost_lower_bound_of_mass_retention
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hn : 0 < n)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    (cumulativeLoss P n + Real.log θ) / (n : ℝ) ≤
      cumulativeCost B n / (n : ℝ) := by
  have hbase :
      cumulativeLoss P n + Real.log θ ≤ cumulativeCost B n :=
    cumulativeCost_lower_bound_of_mass_retention B n hpos hθ hretain
  have hnR : 0 < (n : ℝ) := by
    exact_mod_cast hn
  exact (div_le_div_iff_of_pos_right hnR).2 hbase

end

end Survival.MinimumRepairRate
