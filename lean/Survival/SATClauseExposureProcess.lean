import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Survival.SATDriftLowerBound
import Survival.StochasticTotalProductionAzuma

/-!
# SAT Clause-Exposure Process

This module replaces the earlier constant-drift wrapper by an actual finite
path-space for random clause exposure.

The probability space is a finite trajectory of i.i.d. clause outcomes with
single-step law

* `sat` with probability `7 / 8`
* `unsat` with probability `1 / 8`.

The total-production observable attached to clause exposure is still the
first-moment information loss `log (8 / 7)` per exposed clause. Therefore the
cumulative process is pathwise deterministic even though the underlying
probability space is genuine.

This gives a direct SAT path-space wrapper into the existing collapse /
hitting-time API, without passing through `ConstantDriftExample`.
-/

open scoped ProbabilityTheory

namespace Survival.SATClauseExposureProcess

open MeasureTheory
open Survival.SATDriftLowerBound
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction
open Survival.MartingaleDrift

noncomputable section

/-- Clause outcome for one exposed random 3-clause under a fixed assignment. -/
inductive ClauseOutcome where
  | sat
  | unsat
  deriving DecidableEq, Fintype, Repr

/-- Finite trajectories of clause outcomes. -/
abbrev Trajectory (N : ℕ) := Fin (N + 1) → ClauseOutcome

instance instMeasurableSpaceTrajectory (N : ℕ) : MeasurableSpace (Trajectory N) := ⊤

instance instMeasurableSingletonClassTrajectory (N : ℕ) :
    MeasurableSingletonClass (Trajectory N) where
  measurableSet_singleton _ := by
    trivial

/-- Unsatisfied-clause probability for one random 3-SAT clause under a fixed
assignment. -/
def unsatProb : NNReal :=
  ⟨(1 / 8 : ℝ), by norm_num⟩

/-- One-step random 3-SAT clause-outcome law. -/
def clausePMF : PMF ClauseOutcome :=
  (PMF.bernoulli
      unsatProb
      (by
        change (1 / 8 : ℝ) ≤ 1
        norm_num)).map
    (fun b => if b then ClauseOutcome.unsat else ClauseOutcome.sat)

/-- Length-1 trajectory from a single clause outcome. -/
def singletonTraj (s : ClauseOutcome) : Trajectory 0 := fun _ => s

/-- Extend a clause-exposure trajectory by one final outcome. -/
def snoc {N : ℕ} (τ : Trajectory N) (s : ClauseOutcome) : Trajectory (N + 1)
  | ⟨i, _⟩ =>
      if h : i < N + 1 then
        τ ⟨i, h⟩
      else
        s

/-- Finite-horizon i.i.d. clause-exposure path PMF. -/
def pathPMF : ∀ N : ℕ, PMF (Trajectory N)
  | 0 => clausePMF.map singletonTraj
  | N + 1 =>
      (pathPMF N).bind fun τ =>
        clausePMF.map (snoc τ)

/-- The corresponding actual probability measure on clause-exposure paths. -/
def pathMeasure (N : ℕ) : Measure (Trajectory N) :=
  (pathPMF N).toMeasure

instance instIsProbabilityMeasurePathMeasure (N : ℕ) :
    IsProbabilityMeasure (pathMeasure N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Actual SAT clause-exposure stochastic total-production process. The
underlying space is genuine clause exposure, while the emitted per-clause
information loss is the deterministic first-moment quantity `log (8 / 7)`. -/
def stepModel (N : ℕ) (s₀ : ℝ) : StepModel (μ := pathMeasure N) where
  initialRV := fun _ => s₀
  stepNetActionRV _ := fun _ => 0
  stepCostRV _ := fun _ => random3ClauseDrift
  integrable_initial := integrable_const s₀
  integrable_stepNetAction := by
    intro _
    exact integrable_const 0
  integrable_stepCost := by
    intro _
    exact integrable_const random3ClauseDrift

theorem stepTotalProductionRV_eq_const
    (N : ℕ) (s₀ : ℝ) (t : ℕ) :
    stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀) t =
      fun _ => random3ClauseDrift := by
  funext τ
  simp [stepTotalProductionRV, stepModel]

theorem cumulativeTotalProductionRV_eq_const
    (N : ℕ) (s₀ : ℝ) :
    ∀ n,
      cumulativeTotalProductionRV (μ := pathMeasure N) (stepModel N s₀) n =
        fun _ => s₀ + (n : ℝ) * random3ClauseDrift
  | 0 => by
      funext τ
      simp [cumulativeTotalProductionRV, stepModel]
  | n + 1 => by
      funext τ
      rw [cumulativeTotalProductionRV, cumulativeTotalProductionRV_eq_const N s₀ n,
        stepTotalProductionRV_eq_const N s₀ n]
      simp [Nat.cast_add, Nat.cast_one]
      ring

/-- Exact expected cumulative total production on the actual SAT clause-exposure
path space. -/
theorem expectedCumulative_eq
    (N : ℕ) (s₀ : ℝ) (n : ℕ) :
    (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (n : ℝ) * random3ClauseDrift := by
  change
    ∫ τ, cumulativeTotalProductionRV (μ := pathMeasure N) (stepModel N s₀) n τ ∂pathMeasure N =
      s₀ + (n : ℝ) * random3ClauseDrift
  rw [cumulativeTotalProductionRV_eq_const N s₀ n]
  exact expected_constant_eq (μ := pathMeasure N) (s₀ + (n : ℝ) * random3ClauseDrift)

/-- Exact one-step expected drift on the actual SAT clause-exposure path space. -/
theorem expectedIncrement_eq_random3ClauseDrift
    (N : ℕ) (s₀ : ℝ) (t : ℕ) :
    (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      random3ClauseDrift := by
  have hsucc := (stepModel N s₀).toStochasticProcess.toExpectedProcess.expected_succ t
  rw [expectedCumulative_eq N s₀ (t + 1)] at hsucc
  rw [expectedCumulative_eq N s₀ t] at hsucc
  norm_num at hsucc ⊢
  linarith

/-- Hence the actual SAT clause-exposure process is submartingale-like at the
expectation level. -/
theorem submartingaleLike_stepModel
    (N : ℕ) (s₀ : ℝ) :
    SubmartingaleLike (μ := pathMeasure N) (stepModel N s₀).toStochasticProcess := by
  intro t
  rw [expectedIncrement_eq_random3ClauseDrift N s₀ t]
  exact random3ClauseDrift_nonneg

/-- Bounded increments for the actual SAT clause-exposure process. -/
theorem boundedStepTotalProduction
    (N : ℕ) (s₀ : ℝ) :
    ∀ t, ∀ᵐ τ ∂pathMeasure N,
      |stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀) t τ| ≤ random3ClauseDrift := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  rw [stepTotalProductionRV_eq_const N s₀ t]
  simp [abs_of_nonneg random3ClauseDrift_nonneg]

/-- Lower-tail witness on the actual SAT clause-exposure path space. The
cumulative process is pathwise deterministic, so the good event is `univ` for
nonnegative deviation budgets. -/
def lowerTailWitness
    (N : ℕ) (s₀ : ℝ) :
    StepModelLowerTailWitness
      (μ := pathMeasure N)
      (stepModel N s₀)
      (fun _ => random3ClauseDrift) where
  goodEvent _ r := if 0 ≤ r then Set.univ else ∅
  measurable_goodEvent _ r := by
    by_cases hr : 0 ≤ r <;> simp [hr]
  lower_bound_on_good n r τ hτ := by
    by_cases hr : 0 ≤ r
    · rw [expectedCumulative_eq N s₀ n, cumulativeTotalProductionRV_eq_const N s₀ n]
      linarith
    · simp [hr] at hτ
  azuma_failure_bound n r := by
    by_cases hr : 0 ≤ r
    · simp [hr, azumaHoeffdingFailureBound]
    · have hrate :
          azumaHoeffdingRate
            (varianceProxyOfBounds (fun _ => random3ClauseDrift)) n r = 0 := by
        simp [azumaHoeffdingRate, hr]
      simp [hr, azumaHoeffdingFailureBound,
        Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]

/-- Direct terminal-margin stopped-collapse bound on the actual SAT
clause-exposure path space. -/
theorem stoppedCollapseWithFailureBound_of_expectedMargin
    {N : ℕ} {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) N r) := by
  exact
    StochasticTotalProductionAzuma.stoppedCollapseWithFailureBound_of_boundedIncrements
      (μ := pathMeasure N)
      (S := stepModel N s₀)
      (incrementBound := fun _ => random3ClauseDrift)
      (incrementBound_nonneg := fun _ => random3ClauseDrift_nonneg)
      (boundedStepTotalProduction := boundedStepTotalProduction N s₀)
      (W := lowerTailWitness N s₀)
      hθ hmargin

/-- Direct initial-margin stopped-collapse bound on the actual SAT
clause-exposure path space. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    {N : ℕ} {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) N r) := by
  have hmargin :
      -Real.log θ ≤
        (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedCumulative N - r := by
    rw [expectedCumulative_eq N s₀ N]
    have hnonneg : 0 ≤ (N : ℝ) * random3ClauseDrift := by
      exact mul_nonneg (by positivity) random3ClauseDrift_nonneg
    linarith
  exact stoppedCollapseWithFailureBound_of_expectedMargin hθ hmargin

/-- Direct terminal-margin hitting-time-before-horizon bound on the actual SAT
clause-exposure path space. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    {N : ℕ} {k : ℕ} (hkN : k < N) {s₀ θ r : ℝ}
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) k r) := by
  exact
    StochasticTotalProductionAzuma.hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrements
      (μ := pathMeasure N)
      (S := stepModel N s₀)
      (incrementBound := fun _ => random3ClauseDrift)
      (incrementBound_nonneg := fun _ => random3ClauseDrift_nonneg)
      (boundedStepTotalProduction := boundedStepTotalProduction N s₀)
      (W := lowerTailWitness N s₀)
      hkN hmargin

/-- Direct initial-margin hitting-time-before-horizon bound on the actual SAT
clause-exposure path space. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    {N : ℕ} {k : ℕ} (hkN : k < N) {s₀ θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) k r) := by
  have hmargin :
      -Real.log θ ≤
        (stepModel N s₀).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq N s₀ k]
    have hnonneg : 0 ≤ (k : ℝ) * random3ClauseDrift := by
      exact mul_nonneg (by positivity) random3ClauseDrift_nonneg
    linarith
  exact hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin hkN hmargin

end

end Survival.SATClauseExposureProcess
