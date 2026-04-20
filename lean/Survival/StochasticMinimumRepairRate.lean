import Survival.StochasticTotalProduction
import Survival.MinimumRepairRate

/-!
Stochastic Minimum Repair Rate
MinimumRepairRate の stochastic 版

This module adds the probability-space layer for repair-cost lower bounds.

What is proved:

* define stochastic cumulative repair cost from one-step stochastic costs;
* pathwise lower bounds imply lower bounds on expected cumulative cost;
* therefore pathwise minimum-repair constraints imply expected minimum-repair
  constraints;
* the deterministic minimum-repair theorem is recovered via the constant-process
  embedding.
-/

open MeasureTheory

namespace Survival.StochasticMinimumRepairRate

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.MinimumRepairRate
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Cumulative stochastic repair cost. -/
def cumulativeCostRV (S : StepModel (μ := μ)) : ℕ → Ω → ℝ
  | 0 => fun _ => 0
  | n + 1 => fun ω => cumulativeCostRV S n ω + S.stepCostRV n ω

theorem integrable_cumulativeCostRV
    [IsFiniteMeasure μ]
    (S : StepModel (μ := μ)) :
    ∀ n, Integrable (cumulativeCostRV S n) μ
  | 0 => by
      exact integrable_const 0
  | n + 1 => by
      exact (integrable_cumulativeCostRV S n).add (S.integrable_stepCost n)

/-- Expected cumulative repair cost. -/
def expectedCumulativeCost (S : StepModel (μ := μ)) (n : ℕ) : ℝ :=
  ∫ ω, cumulativeCostRV S n ω ∂μ

/-- Almost-everywhere compatibility of one-step stochastic costs. -/
def AECostCompatible (S₁ S₂ : StepModel (μ := μ)) : Prop :=
  ∀ t, S₂.stepCostRV t =ᵐ[μ] S₁.stepCostRV t

theorem cumulativeCostRV_ae_of_stepCost_ae
    {S₁ S₂ : StepModel (μ := μ)}
    (hcost : AECostCompatible (μ := μ) S₁ S₂) :
    ∀ n, cumulativeCostRV S₂ n =ᵐ[μ] cumulativeCostRV S₁ n
  | 0 => Filter.Eventually.of_forall (by intro ω; rfl)
  | n + 1 => by
      filter_upwards [cumulativeCostRV_ae_of_stepCost_ae hcost n, hcost n] with ω hcum hstep
      simp [cumulativeCostRV, hcum, hstep]

theorem expectedCumulativeCost_eq_of_stepCost_ae
    {S₁ S₂ : StepModel (μ := μ)}
    (hcost : AECostCompatible (μ := μ) S₁ S₂)
    (n : ℕ) :
    expectedCumulativeCost (μ := μ) S₂ n = expectedCumulativeCost (μ := μ) S₁ n := by
  unfold expectedCumulativeCost
  exact integral_congr_ae (cumulativeCostRV_ae_of_stepCost_ae hcost n)

section ProbabilitySpace

variable [IsProbabilityMeasure μ]

theorem expectedCumulativeCost_lower_bound_of_ae
    (S : StepModel (μ := μ)) (n : ℕ)
    {K : ℝ}
    (hK : ∀ᵐ ω ∂μ, K ≤ cumulativeCostRV S n ω) :
    K ≤ expectedCumulativeCost (μ := μ) S n := by
  have hconst : Integrable (fun _ : Ω => K) μ := integrable_const K
  have hcost : Integrable (cumulativeCostRV S n) μ := integrable_cumulativeCostRV S n
  calc
    K = ∫ _ : Ω, K ∂μ := by
      symm
      exact expected_constant_eq (μ := μ) K
    _ ≤ ∫ ω, cumulativeCostRV S n ω ∂μ := by
      exact integral_mono_ae hconst hcost hK
    _ = expectedCumulativeCost (μ := μ) S n := rfl

theorem expectedAverageCost_lower_bound_of_ae
    (S : StepModel (μ := μ)) (n : ℕ)
    (hn : 0 < n)
    {K : ℝ}
    (hK : ∀ᵐ ω ∂μ, K ≤ cumulativeCostRV S n ω) :
    K / (n : ℝ) ≤ expectedCumulativeCost (μ := μ) S n / (n : ℝ) := by
  have hbase : K ≤ expectedCumulativeCost (μ := μ) S n :=
    expectedCumulativeCost_lower_bound_of_ae S n hK
  have hnR : 0 < (n : ℝ) := by
    exact_mod_cast hn
  exact (div_le_div_iff_of_pos_right hnR).2 hbase

theorem expectedCumulativeCost_lower_bound_of_pathwise_minimum_repair
    {X : Type*} {P : ProblemSpec X}
    (S : StepModel (μ := μ)) (n : ℕ)
    {θ : ℝ} (_hθ : 0 < θ)
    (hpath :
      ∀ᵐ ω ∂μ, cumulativeLoss P n + Real.log θ ≤ cumulativeCostRV S n ω) :
    cumulativeLoss P n + Real.log θ ≤ expectedCumulativeCost (μ := μ) S n :=
  expectedCumulativeCost_lower_bound_of_ae S n hpath

theorem expectedAverageCost_lower_bound_of_pathwise_minimum_repair
    {X : Type*} {P : ProblemSpec X}
    (S : StepModel (μ := μ)) (n : ℕ)
    (hn : 0 < n)
    {θ : ℝ} (_hθ : 0 < θ)
    (hpath :
      ∀ᵐ ω ∂μ, cumulativeLoss P n + Real.log θ ≤ cumulativeCostRV S n ω) :
    (cumulativeLoss P n + Real.log θ) / (n : ℝ) ≤
      expectedCumulativeCost (μ := μ) S n / (n : ℝ) :=
  expectedAverageCost_lower_bound_of_ae S n hn hpath

section DeterministicEmbedding

variable {X : Type*}
variable {P : ProblemSpec X}

theorem deterministic_cumulativeCostRV_eq_const
    (B : RepairBudget P) :
    ∀ n,
      cumulativeCostRV (deterministicStepModel (μ := μ) B) n =
        fun _ => cumulativeCost B n
  | 0 => by
      funext ω
      simp [cumulativeCostRV, cumulativeCost]
  | n + 1 => by
      funext ω
      rw [cumulativeCostRV, deterministic_cumulativeCostRV_eq_const B n]
      simp [cumulativeCost, deterministicStepModel, Finset.sum_range_succ]

theorem deterministic_expectedCumulativeCost_eq
    (B : RepairBudget P) (n : ℕ) :
    expectedCumulativeCost (μ := μ) (deterministicStepModel (μ := μ) B) n =
      cumulativeCost B n := by
  unfold expectedCumulativeCost
  rw [deterministic_cumulativeCostRV_eq_const (μ := μ) B n]
  exact expected_constant_eq (μ := μ) (cumulativeCost B n)

theorem deterministic_expectedCumulativeCost_lower_bound_of_mass_retention
    (B : RepairBudget P) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    cumulativeLoss P n + Real.log θ ≤
      expectedCumulativeCost (μ := μ) (deterministicStepModel (μ := μ) B) n := by
  rw [deterministic_expectedCumulativeCost_eq (μ := μ) B n]
  exact cumulativeCost_lower_bound_of_mass_retention B n hpos hθ hretain

theorem deterministic_expectedAverageCost_lower_bound_of_mass_retention
    (B : RepairBudget P) (n : ℕ)
    (hn : 0 < n)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    (cumulativeLoss P n + Real.log θ) / (n : ℝ) ≤
      expectedCumulativeCost (μ := μ) (deterministicStepModel (μ := μ) B) n / (n : ℝ) := by
  rw [deterministic_expectedCumulativeCost_eq (μ := μ) B n]
  exact averageCost_lower_bound_of_mass_retention B n hn hpos hθ hretain

end DeterministicEmbedding

end ProbabilitySpace

end

end Survival.StochasticMinimumRepairRate
