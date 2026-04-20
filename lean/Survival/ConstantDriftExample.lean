import Survival.ResourceBoundedConditionalAzuma

/-!
Constant-Drift Example

This module gives a minimal end-to-end concrete instance of the
resource-bounded conditional-Azuma stack.

The stochastic process itself is deterministic on the probability space:

* initial cumulative total production is the constant `s₀`;
* each one-step net action is `0`;
* each one-step repair cost is the constant `σ ≥ 0`.

Hence one-step total production is the constant drift `σ`, cumulative total
production is `s₀ + nσ`, the process is adapted to any filtration, and the
conditional drift is nonnegative for any filtration.

This is not meant to be the final probabilistic case study. Its role is to
show that the formal tower

  StepModel -> conditional drift -> ResourceBoundedStepModelAzuma
           -> high-probability collapse / hitting-time bounds

can be instantiated end-to-end on an actual probability space.
-/

open scoped ProbabilityTheory

namespace Survival.ConstantDriftExample

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.ConditionalMartingale
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.ResourceBoundedConditionalAzuma
open Survival.ResourceBoundedStochasticCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.BoundedAzumaConstruction
open Survival.AzumaHoeffding

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Deterministic constant-drift step model on a probability space. -/
def constantDriftStepModel (s₀ σ : ℝ) : StepModel (μ := μ) where
  initialRV := fun _ => s₀
  stepNetActionRV _ := fun _ => 0
  stepCostRV _ := fun _ => σ
  integrable_initial := integrable_const s₀
  integrable_stepNetAction := by
    intro _
    exact integrable_const 0
  integrable_stepCost := by
    intro _
    exact integrable_const σ

theorem stepTotalProductionRV_eq_const
    (s₀ σ : ℝ) (t : ℕ) :
    stepTotalProductionRV (μ := μ) (constantDriftStepModel (μ := μ) s₀ σ) t =
      fun _ => σ := by
  funext ω
  simp [stepTotalProductionRV, constantDriftStepModel]

theorem cumulativeTotalProductionRV_eq_const
    (s₀ σ : ℝ) :
    ∀ n,
      cumulativeTotalProductionRV (μ := μ)
          (constantDriftStepModel (μ := μ) s₀ σ) n =
        fun _ => s₀ + (n : ℝ) * σ
  | 0 => by
      funext ω
      simp [cumulativeTotalProductionRV, constantDriftStepModel]
  | n + 1 => by
      funext ω
      rw [cumulativeTotalProductionRV, cumulativeTotalProductionRV_eq_const s₀ σ n,
        stepTotalProductionRV_eq_const (μ := μ) s₀ σ n]
      simp [Nat.cast_add, Nat.cast_one]
      ring

theorem expectedCumulative_eq
    (s₀ σ : ℝ) (n : ℕ) :
    ((
      constantDriftStepModel (μ := μ) s₀ σ
    ).toStochasticProcess.toExpectedProcess.expectedCumulative n) =
      s₀ + (n : ℝ) * σ := by
  change
      ∫ ω, cumulativeTotalProductionRV (μ := μ)
        (constantDriftStepModel (μ := μ) s₀ σ) n ω ∂μ
        = s₀ + (n : ℝ) * σ
  rw [cumulativeTotalProductionRV_eq_const (μ := μ) s₀ σ n]
  exact Survival.ProbabilityConnection.expected_constant_eq
    (μ := μ) (s₀ + (n : ℝ) * σ)

theorem boundedStepTotalProduction
    {σ : ℝ} (hσ : 0 ≤ σ) :
    ∀ t, ∀ᵐ ω ∂μ,
      |stepTotalProductionRV (μ := μ) (constantDriftStepModel (μ := μ) s₀ σ) t ω| ≤ σ := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro ω
  rw [stepTotalProductionRV_eq_const (μ := μ) s₀ σ t]
  simp [abs_of_nonneg hσ]

theorem ae_nonnegative_stepTotalProduction
    {σ : ℝ} (hσ : 0 ≤ σ) :
    AENonnegativeStepTotalProduction
      (μ := μ) (constantDriftStepModel (μ := μ) s₀ σ) := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro ω
  rw [stepTotalProductionRV_eq_const (μ := μ) s₀ σ t]
  exact hσ

variable (ℱ : Filtration ℕ ‹MeasurableSpace Ω›)

theorem conditional_submartingale_drift
    {s₀ σ : ℝ} (hσ : 0 ≤ σ) :
    Survival.ConditionalMartingale.ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV (μ := μ)
        (constantDriftStepModel (μ := μ) s₀ σ))
      ℱ μ := by
  intro n
  have hdiff :
      cumulativeTotalProductionRV (μ := μ)
          (constantDriftStepModel (μ := μ) s₀ σ) (n + 1)
        -
      cumulativeTotalProductionRV (μ := μ)
          (constantDriftStepModel (μ := μ) s₀ σ) n
        =
      (fun _ => σ) := by
    funext ω
    rw [cumulativeTotalProductionRV_eq_const (μ := μ) s₀ σ (n + 1),
      cumulativeTotalProductionRV_eq_const (μ := μ) s₀ σ n]
    simp [Nat.cast_add, Nat.cast_one]
    ring
  rw [hdiff, MeasureTheory.condExp_const (μ := μ) (ℱ.le n) σ]
  exact Filter.Eventually.of_forall (fun _ => hσ)

/-- Lower-tail witness for the constant-drift example.

For nonnegative deviation budgets, the good event is `univ` because the process
is deterministic and exactly equal to its expectation.
For negative deviation budgets, the good event is `∅`, and the Azuma/Hoeffding
failure profile has been saturated at `1`. -/
def lowerTailWitness
    {s₀ σ : ℝ} :
    StepModelLowerTailWitness
      (μ := μ)
      (constantDriftStepModel (μ := μ) s₀ σ)
      (fun _ => σ) where
  goodEvent _ r := if 0 ≤ r then Set.univ else ∅
  measurable_goodEvent _ r := by
    by_cases hr : 0 ≤ r <;> simp [hr]
  lower_bound_on_good n r ω hω := by
    by_cases hr : 0 ≤ r
    · rw [expectedCumulative_eq s₀ σ n,
        cumulativeTotalProductionRV_eq_const (μ := μ) s₀ σ n]
      linarith
    · simp [hr] at hω
  azuma_failure_bound n r := by
    by_cases hr : 0 ≤ r
    · simp [hr, azumaHoeffdingFailureBound]
    · have hlt : r < 0 := lt_of_not_ge hr
      have hfail :
          azumaHoeffdingFailureBound
            (varianceProxyOfBounds (fun _ => σ)) n r = 1 := by
        have hrate :
            azumaHoeffdingRate
              (varianceProxyOfBounds (fun _ => σ)) n r = 0 := by
          simp [azumaHoeffdingRate, hr]
        simp [azumaHoeffdingFailureBound,
          Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]
      rw [hfail]
      simp [hr]

/-- Full conditional-Azuma data for the constant-drift example. -/
def conditionalAzumaData
    {s₀ σ : ℝ} (hσ : 0 ≤ σ) :
    StepModelConditionalAzumaData
      (μ := μ)
      (constantDriftStepModel (μ := μ) s₀ σ) where
  filtration := ℱ
  adapted_cumulative := by
    intro n
    rw [cumulativeTotalProductionRV_eq_const (μ := μ) s₀ σ n]
    exact stronglyMeasurable_const
  conditional_submartingale_drift :=
    conditional_submartingale_drift (μ := μ) ℱ (s₀ := s₀) (σ := σ) hσ
  incrementBound := fun _ => σ
  incrementBound_nonneg := fun _ => hσ
  boundedStepTotalProduction := boundedStepTotalProduction (μ := μ) (s₀ := s₀) hσ
  ae_nonnegative_stepTotalProduction := ae_nonnegative_stepTotalProduction (μ := μ) (s₀ := s₀) hσ
  lowerTailWitness := lowerTailWitness (μ := μ) (s₀ := s₀) (σ := σ)

theorem constantDrift_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    [SigmaFiniteFiltration μ ℱ]
    {s₀ σ : ℝ} (hσ : 0 ≤ σ)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    StoppedCollapseWithFailureBound
      (μ := μ)
      (constantDriftStepModel (μ := μ) s₀ σ).toStochasticProcess N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => σ)) N r) := by
  have hmargin :
      -Real.log θ ≤
        ((
          constantDriftStepModel (μ := μ) s₀ σ
        ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq s₀ σ 0]
    simpa using hmargin₀
  exact
    ResourceBoundedConditionalAzuma.stoppedCollapseWithFailureBound_of_initialExpectedMargin
      (μ := μ)
      (A := conditionalAzumaData (μ := μ) (ℱ := ℱ) hσ)
      hθ hmargin

theorem constantDrift_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    [SigmaFiniteFiltration μ ℱ]
    {s₀ σ : ℝ} (hσ : 0 ≤ σ)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := μ)
      (constantDriftStepModel (μ := μ) s₀ σ).toStochasticProcess N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => σ)) k r) := by
  have hmargin :
      -Real.log θ ≤
        ((
          constantDriftStepModel (μ := μ) s₀ σ
        ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq s₀ σ 0]
    simpa using hmargin₀
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
      (μ := μ)
      (A := conditionalAzumaData (μ := μ) (ℱ := ℱ) hσ)
      hkN hmargin

end

end Survival.ConstantDriftExample
