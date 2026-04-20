import Survival.CoarseStochasticTotalProduction
import Survival.StochasticMinimumRepairRate

/-!
Coarse Minimum Repair Rate
MinimumRepairRate の coarse 版

This module lifts the minimum-repair-rate operational theorem to the
coarse-grained setting.

There are two layers:

* deterministic coarse transfer using admissible coarse-graining, uniform mass
  scaling, and cost-invariant budgeting;
* stochastic coarse transfer using the probability-space compatibility
  interface from `CoarseStochasticTotalProduction`.
-/

namespace Survival.CoarseMinimumRepairRate

open Survival.GeneralStateDynamics
open Survival.CoarseGraining
open Survival.ResourceBudget
open Survival.CoarseTotalProduction
open Survival.MinimumRepairRate
open Survival.CoarseStochasticTotalProduction
open Survival.StochasticTotalProduction
open Survival.StochasticMinimumRepairRate

noncomputable section

variable {X Y : Type*}

theorem cumulativeLoss_preserved
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    (n : ℕ)
    (hpos : PositiveTrajectory P n) :
    cumulativeLoss Q n = cumulativeLoss P n := by
  unfold cumulativeLoss
  refine Finset.sum_congr rfl ?_
  intro t ht
  have ht_lt : t < n := Finset.mem_range.mp ht
  exact stepLoss_preserved cg hs t (hpos.feasible_pos t (Nat.le_of_lt ht_lt))

theorem coarse_cumulativeCost_lower_bound_of_mass_retention_from_micro
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    cumulativeLoss Q n + Real.log θ ≤ cumulativeCost Bcoarse n := by
  have hmicro :
      cumulativeLoss P n + Real.log θ ≤ cumulativeCost Bmicro n :=
    cumulativeCost_lower_bound_of_mass_retention Bmicro n hpos hθ hretain
  rw [cumulativeLoss_preserved cg hs n hpos, cumulativeCost_preserved hB n]
  exact hmicro

theorem coarse_averageCost_lower_bound_of_mass_retention_from_micro
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (n : ℕ)
    (hn : 0 < n)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    (cumulativeLoss Q n + Real.log θ) / (n : ℝ) ≤ cumulativeCost Bcoarse n / (n : ℝ) := by
  have hmicro :
      (cumulativeLoss P n + Real.log θ) / (n : ℝ) ≤ cumulativeCost Bmicro n / (n : ℝ) :=
    averageCost_lower_bound_of_mass_retention Bmicro n hn hpos hθ hretain
  rw [cumulativeLoss_preserved cg hs n hpos, cumulativeCost_preserved hB n]
  exact hmicro

section ProbabilitySpace

open MeasureTheory

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

omit [IsProbabilityMeasure μ] in
theorem coarse_expectedCumulativeCost_eq
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (n : ℕ) :
    expectedCumulativeCost (μ := μ) Scoarse n =
      expectedCumulativeCost (μ := μ) Smicro n := by
  exact expectedCumulativeCost_eq_of_stepCost_ae (μ := μ) (fun t => hcomp.stepCost_ae t) n

omit [IsProbabilityMeasure μ] in
theorem coarse_expectedCumulativeCost_lower_bound_of_micro
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (n : ℕ) {K : ℝ}
    (hmicro : K ≤ expectedCumulativeCost (μ := μ) Smicro n) :
    K ≤ expectedCumulativeCost (μ := μ) Scoarse n := by
  rw [coarse_expectedCumulativeCost_eq hcomp n]
  exact hmicro

theorem coarse_expectedCumulativeCost_lower_bound_of_micro_pathwise
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (n : ℕ) {K : ℝ}
    (hpath : ∀ᵐ ω ∂μ, K ≤ cumulativeCostRV Smicro n ω) :
    K ≤ expectedCumulativeCost (μ := μ) Scoarse n := by
  apply coarse_expectedCumulativeCost_lower_bound_of_micro hcomp n
  exact expectedCumulativeCost_lower_bound_of_ae (μ := μ) Smicro n hpath

end ProbabilitySpace

end

end Survival.CoarseMinimumRepairRate
