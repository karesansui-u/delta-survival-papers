import Survival.FiniteStateMarkovFlatWitness
import Survival.FiniteStateMarkovCollapse
import Survival.FiniteStateMarkovConditionalAzuma
import Survival.FiniteStateMarkovDeterministicWitness

/-!
# Three-State Transition Example

This file gives a concrete finite-state actual Markov-chain example with:

* a 3-state deterministic transition matrix cycling through
  `failure -> idle -> repair -> failure`;
* a flat total-production emission, so the lower-tail witness is generated
  automatically;
* end-to-end stopped-collapse / hitting-time bounds on the actual path measure.

The probabilistic dynamics are therefore concrete, while the total-production
observable remains simple enough to expose the full collapse API transparently.
-/

namespace Survival.ThreeStateTransitionExample

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.FiniteStateMarkovConditionalAzuma
open Survival.FiniteStateMarkovDeterministicWitness
open Survival.ConditionalMartingale
open Survival.AzumaHoeffding
open Survival.StochasticTotalProduction
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Concrete 3-state transition matrix: a deterministic cycle on the three
repair/failure states. -/
def nextState : RepairState → RepairState
  | .failure => .idle
  | .idle => .repair
  | .repair => .failure

/-- Concrete finite-state Markov chain with deterministic initial state and
deterministic one-step transitions. -/
def cycleChain : ChainData where
  init := PMF.pure .failure
  step s := PMF.pure (nextState s)

/-- Concrete flat total-production emission. The split between net action and
repair cost depends on the state, but the total production is always `σ`. -/
def balancedFlatEmission (σ : ℝ) (hσ : 0 ≤ σ) : FlatTotalEmission where
  netActionOf
    | .failure => σ
    | .idle => 0
    | .repair => σ / 2
  costOf
    | .failure => 0
    | .idle => σ
    | .repair => σ / 2
  total_nonneg := by
    intro s
    cases s <;> nlinarith
  σ := σ
  total_eq := by
    intro s
    cases s <;> simp

/-- Concrete actual finite-horizon Markov step model used in this example. -/
def concreteStepModel (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ) :=
  flatStepModel cycleChain N s₀ (balancedFlatEmission σ hσ)

/-- The 3-state flat-emission example seen as an instance of the more general
deterministic-cumulative criterion. -/
def deterministicCumulativeData
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    DeterministicCumulativeData cycleChain N s₀ (balancedFlatEmission σ hσ).toEmission where
  center n := s₀ + (activeSteps N n : ℝ) * σ
  cumulative_eq_const := by
    intro n
    simpa [concreteStepModel] using
      (FiniteStateMarkovFlatWitness.cumulativeTotalProductionRV_eq_const
        cycleChain N s₀ (balancedFlatEmission σ hσ) n)

theorem expectedCumulative_eq
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ) (n : ℕ) :
    (concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (activeSteps N n : ℝ) * σ :=
  FiniteStateMarkovDeterministicWitness.expectedCumulative_eq
    (deterministicCumulativeData N s₀ σ hσ) n

/-- The deterministic center has nonnegative increments when `σ ≥ 0`. -/
theorem deterministic_center_nonneg_step
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    ∀ n,
      0 ≤
        (deterministicCumulativeData N s₀ σ hσ).center (n + 1)
          - (deterministicCumulativeData N s₀ σ hσ).center n := by
  intro n
  simp [deterministicCumulativeData, activeSteps_succ]
  by_cases hn : n ≤ N
  · simp [hn]
    nlinarith
  · simp [hn]

/-- The cumulative process in the 3-state concrete chain is deterministic, so
it is adapted to any filtration on the finite-horizon path space. -/
theorem adapted_cumulative
    (N : ℕ) (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    Adapted ℱ (cumulativeTotalProductionRV (concreteStepModel N s₀ σ hσ)) := by
  exact
    FiniteStateMarkovDeterministicWitness.adapted_cumulative
      (deterministicCumulativeData N s₀ σ hσ) ℱ

/-- Conditional submartingale drift for the deterministic cumulative total
production process induced by the concrete 3-state chain. -/
theorem conditional_submartingale_drift
    (N : ℕ) (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV (concreteStepModel N s₀ σ hσ))
      ℱ
      (pathMeasure cycleChain N) := by
  exact
    FiniteStateMarkovDeterministicWitness.conditional_submartingale_drift
      (deterministicCumulativeData N s₀ σ hσ)
      ℱ
      (deterministic_center_nonneg_step N s₀ σ hσ)

/-- The conditional-Azuma data for the 3-state chain are obtained by viewing it
as a deterministic-cumulative finite-state Markov example. -/
def conditionalAzumaData
    (N : ℕ) (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    MarkovConditionalAzumaData cycleChain N s₀ (balancedFlatEmission σ hσ).toEmission :=
  FiniteStateMarkovDeterministicWitness.toMarkovConditionalAzumaData
    (deterministicCumulativeData N s₀ σ hσ)
    ℱ
    (deterministic_center_nonneg_step N s₀ σ hσ)

/-- Concrete Azuma/Hoeffding concentration object on the 3-state actual
finite-horizon Markov chain. -/
def concentration
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    AzumaHoeffdingConcentration
      (μ := pathMeasure cycleChain N)
      (concreteStepModel N s₀ σ hσ).toStochasticProcess where
  toExpectationLowerConcentration := {
    toLowerDeviationConcentration := {
      center := (concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative
      goodEvent := fun _ r => if 0 ≤ r then Set.univ else ∅
      measurable_goodEvent := by
        intro n r
        by_cases hr : 0 ≤ r <;> simp [hr]
      lower_bound_on_good := by
        intro n r ω hω
        by_cases hr : 0 ≤ r
        · simpa [concreteStepModel] using
            (FiniteStateMarkovFlatWitness.lowerTailWitness
              cycleChain N s₀ (balancedFlatEmission σ hσ)).lower_bound_on_good
              n r ω hω
        · simp [hr] at hω
      failureBound := fun n r =>
        azumaHoeffdingFailureBound
          (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
            (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission))
          n r
      failure_bound := by
        intro n r
        by_cases hr : 0 ≤ r
        · simp [hr]
        · have hfail :
            azumaHoeffdingFailureBound
              (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
                (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission))
              n r = 1 := by
            have hrate :
                azumaHoeffdingRate
                  (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
                    (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission))
                  n r = 0 := by
              simp [azumaHoeffdingRate, hr]
            simp [azumaHoeffdingFailureBound,
              Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]
          rw [hfail]
          simp [hr]
    }
    center_eq_expected := rfl
  }
  varianceProxy := Survival.BoundedAzumaConstruction.varianceProxyOfBounds
    (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission)
  failure_eq_azuma := by
    intro n r
    rfl

/-- Full concrete conditional-Azuma concentration data for the 3-state actual
Markov chain. -/
def conditionalAzumaConcentrationData
    (N : ℕ) (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (s₀ σ : ℝ) (hσ : 0 ≤ σ) :
    MarkovConditionalAzumaConcentrationData cycleChain N s₀ (balancedFlatEmission σ hσ).toEmission :=
  (conditionalAzumaData N ℱ s₀ σ hσ).toMarkovConditionalAzumaConcentrationData

/-- End-to-end stopped-collapse bound on the concrete 3-state chain via the
concrete Azuma/Hoeffding concentration object and conditional Azuma layer. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin_concentration
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    [SigmaFiniteFiltration (pathMeasure cycleChain N) ℱ]
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure cycleChain N)
      (concreteStepModel N s₀ σ hσ).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission))
        T r) := by
  have hmargin :
      -Real.log θ ≤
        ((concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq N s₀ σ hσ 0]
    simp [activeSteps]
    linarith
  exact
    FiniteStateMarkovConditionalAzuma.markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin_concentration
      (A := conditionalAzumaConcentrationData N ℱ s₀ σ hσ)
      hθ hmargin

/-- End-to-end direct hitting-time-before-horizon bound on the concrete 3-state
chain via the concrete Azuma/Hoeffding concentration object and conditional
Azuma layer. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin_concentration
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    [SigmaFiniteFiltration (pathMeasure cycleChain N) ℱ]
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure cycleChain N)
      (concreteStepModel N s₀ σ hσ).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          (FiniteStateMarkovCollapse.incrementBound (balancedFlatEmission σ hσ).toEmission))
        k r) := by
  have hmargin :
      -Real.log θ ≤
        ((concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq N s₀ σ hσ 0]
    simp [activeSteps]
    linarith
  exact
    FiniteStateMarkovConditionalAzuma.markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin_concentration
      (A := conditionalAzumaConcentrationData N ℱ s₀ σ hσ)
      hkT hmargin

/-- End-to-end stopped-collapse bound on the concrete 3-state chain, using the
automatically generated flat-emission lower-tail witness. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ)
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure cycleChain N)
      (concreteStepModel N s₀ σ hσ).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |σ|))
        T r) := by
  have hmargin :
      -Real.log θ ≤
        ((concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq N s₀ σ hσ 0]
    simp [activeSteps]
    linarith
  exact
    FiniteStateMarkovFlatWitness.stoppedCollapseWithFailureBound_of_initialExpectedMargin
      cycleChain N s₀ (balancedFlatEmission σ hσ)
      hθ hmargin

/-- End-to-end direct hitting-time-before-horizon bound on the concrete 3-state
chain. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (N : ℕ) (s₀ σ : ℝ) (hσ : 0 ≤ σ)
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure cycleChain N)
      (concreteStepModel N s₀ σ hσ).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |σ|))
        k r) := by
  have hmargin :
      -Real.log θ ≤
        ((concreteStepModel N s₀ σ hσ).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r := by
    rw [expectedCumulative_eq N s₀ σ hσ 0]
    simp [activeSteps]
    linarith
  exact
    FiniteStateMarkovFlatWitness.hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
      cycleChain N s₀ (balancedFlatEmission σ hσ)
      hkT hmargin

end

end Survival.ThreeStateTransitionExample
