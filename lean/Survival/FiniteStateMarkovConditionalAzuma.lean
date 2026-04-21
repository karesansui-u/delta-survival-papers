import Survival.FiniteStateMarkovCollapse
import Survival.ResourceBoundedConditionalAzuma
import Survival.AzumaHoeffding

/-!
# Finite-State Markov Conditional Azuma

This module specializes the conditional-Azuma interface to the actual
finite-horizon Markov path-space construction.

The intent is parallel to `FiniteStateMarkovCollapse`:

* the probability space is fixed to `pathMeasure M N`;
* bounded increments are supplied automatically from the finite-state emission
  bounds;
* one-step resource-boundedness is supplied automatically from
  statewise nonnegative total production;
* the user adds a filtration, adaptedness, conditional submartingale drift, and
  a lower-tail witness.

From these data we obtain the finite-state actual Markov-chain versions of:

* expected cumulative monotonicity;
* initial-margin high-probability stopped collapse;
* initial-margin high-probability hitting-time-before-horizon bounds.
-/

open scoped ProbabilityTheory

namespace Survival.FiniteStateMarkovConditionalAzuma

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovCollapse
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.ResourceBoundedConditionalAzuma
open Survival.ConditionalMartingale
open Survival.AzumaHoeffding
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Conditional-Azuma data specialized to the actual finite-horizon Markov path
space. Bounded increments and resource-boundedness are not user inputs here:
they are generated automatically from the finite-state emission bounds. -/
structure MarkovConditionalAzumaData
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) where
  filtration : Filtration ℕ (instMeasurableSpaceTrajectory N)
  adapted_cumulative :
    Adapted filtration (cumulativeTotalProductionRV (stepModel M N s₀ E))
  conditional_submartingale_drift :
    ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV (stepModel M N s₀ E))
      filtration
      (pathMeasure M N)
  lowerTailWitness :
    StepModelLowerTailWitness
      (μ := pathMeasure M N)
      (stepModel M N s₀ E)
      (incrementBound E)

/-- Automatic conversion from finite-state actual Markov conditional-drift data
to the generic resource-bounded conditional-Azuma interface. -/
def MarkovConditionalAzumaData.toStepModelConditionalAzumaData
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E) :
    StepModelConditionalAzumaData
      (μ := pathMeasure M N)
      (stepModel M N s₀ E) where
  filtration := A.filtration
  adapted_cumulative := A.adapted_cumulative
  conditional_submartingale_drift := A.conditional_submartingale_drift
  incrementBound := incrementBound E
  incrementBound_nonneg := incrementBound_nonneg E
  boundedStepTotalProduction := boundedStepTotalProduction M N s₀ E
  ae_nonnegative_stepTotalProduction :=
    FiniteStateMarkovRepairChain.ae_nonnegative_stepTotalProduction M N s₀ E
  lowerTailWitness := A.lowerTailWitness

/-- A concrete Azuma/Hoeffding concentration object on the actual finite-state
Markov path space automatically induces the corresponding lower-tail witness in
the `StepModel` language. -/
def lowerTailWitnessOfAzumaHoeffding
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (C :
      AzumaHoeffdingConcentration
        (μ := pathMeasure M N)
        (stepModel M N s₀ E).toStochasticProcess)
    (hvariance :
      C.varianceProxy =
        Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) :
    StepModelLowerTailWitness
      (μ := pathMeasure M N)
      (stepModel M N s₀ E)
      (incrementBound E) where
  goodEvent := C.toExpectationLowerConcentration.toLowerDeviationConcentration.goodEvent
  measurable_goodEvent :=
    C.toExpectationLowerConcentration.toLowerDeviationConcentration.measurable_goodEvent
  lower_bound_on_good := by
    intro n r ω hω
    simpa
        [StepModel.toStochasticProcess,
          C.toExpectationLowerConcentration.center_eq_expected] using
      C.toExpectationLowerConcentration.toLowerDeviationConcentration.lower_bound_on_good n r ω hω
  azuma_failure_bound := by
    intro n r
    have hfail :
        pathMeasure M N
            ((C.toExpectationLowerConcentration.toLowerDeviationConcentration.goodEvent n r)ᶜ) ≤
          C.toExpectationLowerConcentration.toLowerDeviationConcentration.failureBound n r :=
      C.toExpectationLowerConcentration.toLowerDeviationConcentration.failure_bound n r
    rw [C.failure_eq_azuma, hvariance] at hfail
    simpa using hfail

/-- Conditional-Azuma data on the actual finite-state Markov path space where
the lower-tail witness is not given separately, but instead is auto-generated
from a concrete Azuma/Hoeffding concentration object. -/
structure MarkovConditionalAzumaConcentrationData
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) where
  filtration : Filtration ℕ (instMeasurableSpaceTrajectory N)
  adapted_cumulative :
    Adapted filtration (cumulativeTotalProductionRV (stepModel M N s₀ E))
  conditional_submartingale_drift :
    ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV (stepModel M N s₀ E))
      filtration
      (pathMeasure M N)
  concentration :
    AzumaHoeffdingConcentration
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess
  variance_eq :
    concentration.varianceProxy =
      Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)

/-- Auto-generate full Markov conditional-Azuma data once a concrete
Azuma/Hoeffding concentration object is available. -/
def MarkovConditionalAzumaConcentrationData.toMarkovConditionalAzumaData
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaConcentrationData M N s₀ E) :
    MarkovConditionalAzumaData M N s₀ E where
  filtration := A.filtration
  adapted_cumulative := A.adapted_cumulative
  conditional_submartingale_drift := A.conditional_submartingale_drift
  lowerTailWitness :=
    lowerTailWitnessOfAzumaHoeffding A.concentration A.variance_eq

/-- Conditional drift on the actual finite-state Markov path space induces
monotonicity of expected cumulative total production. -/
theorem expectedCumulative_monotone_of_conditionalAzuma
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration] :
    Monotone (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative :=
  ResourceBoundedConditionalAzuma.expectedCumulative_monotone_of_conditionalAzuma
    (μ := pathMeasure M N)
    A.toStepModelConditionalAzumaData

/-- A lower-tail witness on the actual finite-state Markov path space induces a
concrete Azuma/Hoeffding concentration object for the associated stochastic
total-production process. This is the generic finite-state version of the
previous 3-state concrete constructor. -/
def MarkovConditionalAzumaData.toAzumaHoeffdingConcentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E) :
    AzumaHoeffdingConcentration
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess where
  toExpectationLowerConcentration := {
    toLowerDeviationConcentration := {
      center := (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative
      goodEvent := A.lowerTailWitness.goodEvent
      measurable_goodEvent := A.lowerTailWitness.measurable_goodEvent
      lower_bound_on_good := by
        intro n r ω hω
        simpa [StepModel.toStochasticProcess] using
          A.lowerTailWitness.lower_bound_on_good n r ω hω
      failureBound := fun n r =>
        Survival.AzumaHoeffding.azumaHoeffdingFailureBound
          (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E))
          n r
      failure_bound := A.lowerTailWitness.azuma_failure_bound
    }
    center_eq_expected := rfl
  }
  varianceProxy :=
    Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)
  failure_eq_azuma := by
    intro n r
    rfl

/-- Therefore any finite-state Markov conditional-Azuma datum yields the
corresponding concentration datum automatically. -/
def MarkovConditionalAzumaData.toMarkovConditionalAzumaConcentrationData
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E) :
    MarkovConditionalAzumaConcentrationData M N s₀ E where
  filtration := A.filtration
  adapted_cumulative := A.adapted_cumulative
  conditional_submartingale_drift := A.conditional_submartingale_drift
  concentration := A.toAzumaHoeffdingConcentration
  variance_eq := by
    rfl

/-- If the lower-tail witness is auto-generated from a concrete Azuma/Hoeffding
concentration object, conditional drift still induces monotonicity of expected
cumulative total production on the actual finite-state Markov path space. -/
theorem expectedCumulative_monotone_of_concentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaConcentrationData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration] :
    Monotone (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_conditionalAzuma
    (A := A.toMarkovConditionalAzumaData)

/-- Initial-margin high-probability stopped collapse on the actual finite-state
Markov path space under conditional submartingale drift. -/
theorem markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) T r) :=
  ResourceBoundedConditionalAzuma.stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (μ := pathMeasure M N)
    A.toStepModelConditionalAzumaData
    hθ hmargin₀

/-- Initial-margin high-probability stopped collapse when the lower-tail
witness is auto-generated from a concrete Azuma/Hoeffding concentration
object on the actual finite-state Markov path space. -/
theorem markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin_concentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaConcentrationData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) T r) :=
  markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (A := A.toMarkovConditionalAzumaData)
    hθ hmargin₀

/-- Initial-margin direct hitting-time-before-horizon bound on the actual
finite-state Markov path space under conditional submartingale drift. -/
theorem markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) k r) :=
  ResourceBoundedConditionalAzuma.hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (μ := pathMeasure M N)
    A.toStepModelConditionalAzumaData
    hkT hmargin₀

/-- Initial-margin direct hitting-time-before-horizon bound when the
lower-tail witness is auto-generated from a concrete Azuma/Hoeffding
concentration object on the actual finite-state Markov path space. -/
theorem markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin_concentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaConcentrationData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) k r) :=
  markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (A := A.toMarkovConditionalAzumaData)
    hkT hmargin₀

/-- The same initial-margin stopped-collapse bound, read through the generic
finite-state concentration object auto-generated from the lower-tail witness. -/
theorem markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin_via_concentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) T r) :=
  markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin_concentration
    (A := A.toMarkovConditionalAzumaConcentrationData)
    hθ hmargin₀

/-- The same initial-margin hitting-time-before-horizon bound, read through the
generic finite-state concentration object auto-generated from the lower-tail
witness. -/
theorem markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin_via_concentration
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (A : MarkovConditionalAzumaData M N s₀ E)
    [SigmaFiniteFiltration (pathMeasure M N) A.filtration]
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        ((stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0) - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) k r) :=
  markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin_concentration
    (A := A.toMarkovConditionalAzumaConcentrationData)
    hkT hmargin₀

end

end Survival.FiniteStateMarkovConditionalAzuma
