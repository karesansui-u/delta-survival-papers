import Survival.ResourceBoundedStochasticCollapse
import Survival.ConditionalMartingale

/-!
Resource-Bounded Conditional Azuma

This module removes another layer of manual plumbing.

It bundles:

* a stochastic total-production `StepModel`;
* a filtration and conditional submartingale drift for the cumulative process;
* bounded one-step total production;
* a lower-tail Azuma witness;
* almost-sure nonnegative one-step total production (resource-boundedness).

From these ingredients we automatically obtain:

* a `ResourceBoundedStepModelAzuma` object;
* conditional-drift-induced expected monotonicity;
* initial-margin high-probability stopped collapse bounds;
* initial-margin high-probability direct hitting-time bounds.
-/

open scoped ProbabilityTheory

namespace Survival.ResourceBoundedConditionalAzuma

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.ResourceBoundedStochasticCollapse
open Survival.ConditionalMartingale
open Survival.MartingaleDrift
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.BoundedAzumaConstruction

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Conditional-Azuma data for a resource-bounded stochastic total-production
step model. -/
structure StepModelConditionalAzumaData
    (S : StepModel (μ := μ)) where
  filtration : Filtration ℕ ‹MeasurableSpace Ω›
  adapted_cumulative : Adapted filtration (cumulativeTotalProductionRV S)
  conditional_submartingale_drift :
    ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV S) filtration μ
  incrementBound : ℕ → ℝ
  incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t
  boundedStepTotalProduction :
    ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t
  ae_nonnegative_stepTotalProduction :
    AENonnegativeStepTotalProduction (μ := μ) S
  lowerTailWitness :
    StepModelLowerTailWitness (μ := μ) S incrementBound

/-- The process built from the cumulative total-production trajectory has the
same expected cumulative quantity as the native `StepModel` interface. -/
theorem processAs_expectedCumulative_eq_stepModel
    (S : StepModel (μ := μ)) (n : ℕ) :
    (processAsStochasticExpectedProcess
      (μ := μ) (cumulativeTotalProductionRV S)
      (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedCumulative n =
      S.toStochasticProcess.toExpectedProcess.expectedCumulative n := by
  rfl

/-- The increment expectations computed via the conditional-martingale layer
agree with the native total-production step-model interface. -/
theorem processAs_expectedIncrement_eq_stepModel
    (S : StepModel (μ := μ)) (n : ℕ) :
    (processAsStochasticExpectedProcess
      (μ := μ) (cumulativeTotalProductionRV S)
      (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedIncrement n =
      S.toStochasticProcess.toExpectedProcess.expectedIncrement n := by
  have hsucc₁ :
      (processAsStochasticExpectedProcess
        (μ := μ) (cumulativeTotalProductionRV S)
        (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedCumulative (n + 1)
        =
      (processAsStochasticExpectedProcess
        (μ := μ) (cumulativeTotalProductionRV S)
        (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedCumulative n
        +
      (processAsStochasticExpectedProcess
        (μ := μ) (cumulativeTotalProductionRV S)
        (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedIncrement n :=
    (processAsStochasticExpectedProcess
      (μ := μ) (cumulativeTotalProductionRV S)
      (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expected_succ n
  have hsucc₂ :
      S.toStochasticProcess.toExpectedProcess.expectedCumulative (n + 1) =
        S.toStochasticProcess.toExpectedProcess.expectedCumulative n +
          S.toStochasticProcess.toExpectedProcess.expectedIncrement n :=
    S.toStochasticProcess.toExpectedProcess.expected_succ n
  have hcum :
      (processAsStochasticExpectedProcess
        (μ := μ) (cumulativeTotalProductionRV S)
        (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedCumulative n =
      S.toStochasticProcess.toExpectedProcess.expectedCumulative n :=
    processAs_expectedCumulative_eq_stepModel (μ := μ) S n
  have hcum_succ :
      (processAsStochasticExpectedProcess
        (μ := μ) (cumulativeTotalProductionRV S)
        (integrable_cumulativeTotalProductionRV S)).toExpectedProcess.expectedCumulative (n + 1) =
      S.toStochasticProcess.toExpectedProcess.expectedCumulative (n + 1) :=
    processAs_expectedCumulative_eq_stepModel (μ := μ) S (n + 1)
  linarith

/-- Conditional submartingale drift for the cumulative total-production process
induces a submartingale-like condition for the native `StepModel` interface. -/
theorem submartingaleLike_of_conditionalAzuma
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : StepModelConditionalAzumaData (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration] :
    SubmartingaleLike (μ := μ) S.toStochasticProcess := by
  have hproc :
      SubmartingaleLike
        (μ := μ)
        (processAsStochasticExpectedProcess
          (μ := μ) (cumulativeTotalProductionRV S)
          (integrable_cumulativeTotalProductionRV S)) :=
    submartingaleLike_of_conditionalIncrementSubmartingaleDrift
      (μ := μ) (ℱ := A.filtration)
      (f := cumulativeTotalProductionRV S)
      A.adapted_cumulative
      (integrable_cumulativeTotalProductionRV S)
      A.conditional_submartingale_drift
  intro n
  rw [← processAs_expectedIncrement_eq_stepModel (μ := μ) S n]
  exact hproc n

/-- Conversion from conditional-Azuma data to the resource-bounded Azuma
interface used by the stopping-time collapse layer. -/
def StepModelConditionalAzumaData.toResourceBoundedStepModelAzuma
    {S : StepModel (μ := μ)}
    (A : StepModelConditionalAzumaData (μ := μ) S) :
    ResourceBoundedStepModelAzuma (μ := μ) S :=
  ResourceBoundedStepModelAzuma.of_boundedIncrements
    (μ := μ)
    A.incrementBound
    A.incrementBound_nonneg
    A.boundedStepTotalProduction
    A.ae_nonnegative_stepTotalProduction
    A.lowerTailWitness

/-- Hence the expected cumulative total production is monotone. -/
theorem expectedCumulative_monotone_of_conditionalAzuma
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : StepModelConditionalAzumaData (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration] :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative := by
  exact expectedCumulative_monotone_of_submartingaleLike
    (μ := μ) S.toStochasticProcess
    (submartingaleLike_of_conditionalAzuma (μ := μ) A)

/-- Initial-margin stopped-collapse theorem obtained from conditional
submartingale drift plus the resource-bounded Azuma witness. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : StepModelConditionalAzumaData (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration]
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hmono := expectedCumulative_monotone_of_conditionalAzuma (μ := μ) A
  have h0N :
      S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative N :=
    hmono (Nat.zero_le N)
  have hmarginN :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r := by
    linarith
  exact
    ResourceBoundedStochasticCollapse.stoppedCollapseWithFailureBound_of_expectedMargin
      (μ := μ) A.toResourceBoundedStepModelAzuma hθ hmarginN

/-- Initial-margin direct hitting-time theorem obtained from conditional
submartingale drift plus the resource-bounded Azuma witness. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : StepModelConditionalAzumaData (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration]
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hmono := expectedCumulative_monotone_of_conditionalAzuma (μ := μ) A
  have h0k :
      S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative k :=
    hmono (Nat.zero_le k)
  have hmargink :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    linarith
  exact
    ResourceBoundedStochasticCollapse.hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      (μ := μ) A.toResourceBoundedStepModelAzuma hkN hmargink

end

end Survival.ResourceBoundedConditionalAzuma
