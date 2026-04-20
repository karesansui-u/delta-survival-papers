import Survival.ProbabilityConnection

/-!
Stochastic Total Production
stochastic total production を actual probability process として instantiate する

This module specializes `Survival.ProbabilityConnection` to the total-production
setting.

There are two layers:

* a genuinely stochastic layer, where one-step net action and one-step cost are
  random variables;
* a deterministic embedding layer, which realizes the already-formalized
  deterministic total production `Σ_n` as a constant stochastic process on any
  probability space.
-/

open MeasureTheory

namespace Survival.StochasticTotalProduction

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.ProbabilityConnection

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Stochastic step-data for total production:
random net action and random repair cost on a measure space. -/
structure StepModel where
  initialRV : Ω → ℝ
  stepNetActionRV : ℕ → Ω → ℝ
  stepCostRV : ℕ → Ω → ℝ
  integrable_initial : Integrable initialRV μ
  integrable_stepNetAction : ∀ t, Integrable (stepNetActionRV t) μ
  integrable_stepCost : ∀ t, Integrable (stepCostRV t) μ

/-- One-step stochastic total production increment. -/
def stepTotalProductionRV (S : StepModel (μ := μ)) (t : ℕ) : Ω → ℝ :=
  fun ω => S.stepNetActionRV t ω + S.stepCostRV t ω

/-- Cumulative stochastic total production built from the initial value and
one-step stochastic total production increments. -/
def cumulativeTotalProductionRV (S : StepModel (μ := μ)) : ℕ → Ω → ℝ
  | 0 => S.initialRV
  | t + 1 => fun ω => cumulativeTotalProductionRV S t ω + stepTotalProductionRV S t ω

theorem integrable_stepTotalProductionRV
    (S : StepModel (μ := μ)) (t : ℕ) :
    Integrable (stepTotalProductionRV S t) μ :=
  (S.integrable_stepNetAction t).add (S.integrable_stepCost t)

theorem integrable_cumulativeTotalProductionRV
    (S : StepModel (μ := μ)) :
    ∀ n, Integrable (cumulativeTotalProductionRV S n) μ
  | 0 => S.integrable_initial
  | t + 1 =>
      (integrable_cumulativeTotalProductionRV S t).add
        (integrable_stepTotalProductionRV S t)

theorem cumulativeTotalProductionRV_succ_ae
    (S : StepModel (μ := μ)) (t : ℕ) :
    cumulativeTotalProductionRV S (t + 1) =ᵐ[μ]
      fun ω => cumulativeTotalProductionRV S t ω + stepTotalProductionRV S t ω :=
  Filter.Eventually.of_forall (by intro ω; rfl)

/-- Convert stochastic total production step-data into the actual-probability
process interface from `ProbabilityConnection`. -/
def StepModel.toStochasticProcess
    (S : StepModel (μ := μ)) :
    StochasticTotalProductionProcess (μ := μ) where
  cumulativeRV := cumulativeTotalProductionRV S
  incrementRV := stepTotalProductionRV S
  integrable_cumulative := integrable_cumulativeTotalProductionRV S
  integrable_increment := integrable_stepTotalProductionRV S
  cumulative_succ_ae := cumulativeTotalProductionRV_succ_ae S

/-- Almost sure nonnegativity of stochastic one-step net action. -/
def AENonnegativeStepNetAction (S : StepModel (μ := μ)) : Prop :=
  ∀ t, 0 ≤ᵐ[μ] S.stepNetActionRV t

/-- Almost sure nonnegativity of stochastic one-step cost. -/
def AENonnegativeStepCost (S : StepModel (μ := μ)) : Prop :=
  ∀ t, 0 ≤ᵐ[μ] S.stepCostRV t

/-- Almost sure nonnegativity of stochastic one-step total production. -/
def AENonnegativeStepTotalProduction (S : StepModel (μ := μ)) : Prop :=
  ∀ t, 0 ≤ᵐ[μ] stepTotalProductionRV S t

theorem ae_nonnegative_stepTotalProduction_of_parts
    (S : StepModel (μ := μ))
    (hA : AENonnegativeStepNetAction (μ := μ) S)
    (hC : AENonnegativeStepCost (μ := μ) S) :
    AENonnegativeStepTotalProduction (μ := μ) S := by
  intro t
  filter_upwards [hA t, hC t] with ω hωA hωC
  dsimp [stepTotalProductionRV]
  exact add_nonneg hωA hωC

theorem expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (S : StepModel (μ := μ))
    (hStep : AENonnegativeStepTotalProduction (μ := μ) S) :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative := by
  exact expectedTotalProduction_monotone_of_ae_nonnegative_increment
    (S := S.toStochasticProcess) hStep

section DeterministicEmbedding

variable [IsProbabilityMeasure μ]
variable {X : Type*}
variable {P : ProblemSpec X}

/-- Deterministic total production data, viewed as a constant stochastic process
on any probability space. -/
def deterministicStepModel (B : RepairBudget P) : StepModel (μ := μ) where
  initialRV := fun _ => cumulativeTotalProduction B 0
  stepNetActionRV t := fun _ => stepNetAction P t
  stepCostRV t := fun _ => B.stepCost t
  integrable_initial := by exact integrable_const (cumulativeTotalProduction B 0)
  integrable_stepNetAction := by
    intro t
    exact integrable_const (stepNetAction P t)
  integrable_stepCost := by
    intro t
    exact integrable_const (B.stepCost t)

theorem deterministic_stepTotalProductionRV_eq_const
    (B : RepairBudget P) (t : ℕ) :
    stepTotalProductionRV (deterministicStepModel (μ := μ) B) t =
      fun _ => stepTotalProduction B t := by
  funext ω
  simp [stepTotalProductionRV, deterministicStepModel, stepTotalProduction]

theorem deterministic_cumulativeTotalProductionRV_eq_const
    (B : RepairBudget P) :
    ∀ n,
      cumulativeTotalProductionRV (deterministicStepModel (μ := μ) B) n =
        fun _ => cumulativeTotalProduction B n
  | 0 => by
      funext ω
      simp [cumulativeTotalProductionRV, deterministicStepModel]
  | t + 1 => by
      funext ω
      simp [cumulativeTotalProductionRV, deterministic_cumulativeTotalProductionRV_eq_const,
        deterministic_stepTotalProductionRV_eq_const, cumulativeTotalProduction_succ]

theorem deterministic_expectedCumulative_eq
    (B : RepairBudget P) (n : ℕ) :
    (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      cumulativeTotalProduction B n := by
  change
    ∫ ω, cumulativeTotalProductionRV (deterministicStepModel (μ := μ) B) n ω ∂μ =
      cumulativeTotalProduction B n
  rw [deterministic_cumulativeTotalProductionRV_eq_const (μ := μ) B n]
  exact expected_constant_eq (μ := μ) (cumulativeTotalProduction B n)

theorem deterministic_ae_nonnegative_stepTotalProduction
    (B : RepairBudget P) (R : BoundedTrajectory P B) :
    AENonnegativeStepTotalProduction (μ := μ) (deterministicStepModel (μ := μ) B) := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro ω
  rw [deterministic_stepTotalProductionRV_eq_const (μ := μ) B t]
  exact stepTotalProduction_nonneg B t (R.feasible_pos t) (R.contracted_pos t)

/-- Expected cumulative total production of the deterministic embedding. -/
def deterministicExpectedCumulative
    (B : RepairBudget P) : ℕ → ℝ :=
  (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedCumulative

theorem deterministic_expectedCumulative_monotone
    (B : RepairBudget P) (R : BoundedTrajectory P B) :
    Monotone (deterministicExpectedCumulative (μ := μ) B) := by
  exact expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (S := deterministicStepModel (μ := μ) B)
    (deterministic_ae_nonnegative_stepTotalProduction (μ := μ) B R)

end DeterministicEmbedding

end

end Survival.StochasticTotalProduction
