import Survival.StochasticTotalProduction
import Survival.CoarseStochasticTotalProduction
import Survival.BoundedAzumaConstruction
import Survival.StoppingTimeHighProbabilityCollapse
import Survival.StoppingTimeCollapseEvent

/-!
Stochastic Total Production Azuma Interface

This module provides the missing interface between `StepModel`-based stochastic
total production and the generic bounded-increment Azuma machinery.

The goal is convenience:

* express bounded increments directly in terms of `stepTotalProductionRV`;
* express good-event lower bounds directly in terms of
  `cumulativeTotalProductionRV`;
* automatically convert these data into `BoundedIncrementAzumaData` for the
  associated stochastic process.

This lets the stopping-time collapse theorems be applied without manually
rewriting from the total-production vocabulary into the generic stochastic
process vocabulary.
-/

namespace Survival.StochasticTotalProductionAzuma

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction
open Survival.BoundedAzumaConstruction
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Bounded-increment Azuma witness stated directly in the `StepModel`
language of stochastic total production. -/
structure StepModelAzumaData
    (S : StepModel (μ := μ)) where
  incrementBound : ℕ → ℝ
  incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t
  boundedStepTotalProduction :
    ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t
  goodEvent : ℕ → ℝ → Set Ω
  measurable_goodEvent : ∀ n r, MeasurableSet (goodEvent n r)
  lower_bound_on_good :
    ∀ n r ω, ω ∈ goodEvent n r →
      S.toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
        cumulativeTotalProductionRV S n ω
  azuma_failure_bound :
    ∀ n r, μ ((goodEvent n r)ᶜ) ≤
      Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) n r

/-- Lower-tail Azuma witness in the `StepModel` language, parameterized by a
pre-chosen increment bound. This isolates the genuinely probabilistic input
from the bookkeeping around bounded increments. -/
structure StepModelLowerTailWitness
    (S : StepModel (μ := μ)) (incrementBound : ℕ → ℝ) where
  goodEvent : ℕ → ℝ → Set Ω
  measurable_goodEvent : ∀ n r, MeasurableSet (goodEvent n r)
  lower_bound_on_good :
    ∀ n r ω, ω ∈ goodEvent n r →
      S.toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
        cumulativeTotalProductionRV S n ω
  azuma_failure_bound :
    ∀ n r, μ ((goodEvent n r)ᶜ) ≤
      Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) n r

/-- Constructor from bounded increments plus a lower-tail witness. -/
def StepModelAzumaData.of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound) :
    StepModelAzumaData (μ := μ) S where
  incrementBound := incrementBound
  incrementBound_nonneg := incrementBound_nonneg
  boundedStepTotalProduction := boundedStepTotalProduction
  goodEvent := W.goodEvent
  measurable_goodEvent := W.measurable_goodEvent
  lower_bound_on_good := W.lower_bound_on_good
  azuma_failure_bound := W.azuma_failure_bound

/-- Automatic conversion from the total-production witness to the generic
bounded-increment Azuma witness. -/
def StepModelAzumaData.toBoundedIncrementAzumaData
    {S : StepModel (μ := μ)}
    (A : StepModelAzumaData (μ := μ) S) :
    BoundedIncrementAzumaData (μ := μ) S.toStochasticProcess where
  incrementBound := A.incrementBound
  incrementBound_nonneg := A.incrementBound_nonneg
  boundedIncrements := by
    intro t
    simpa [StepModel.toStochasticProcess, stepTotalProductionRV] using
      A.boundedStepTotalProduction t
  goodEvent := A.goodEvent
  measurable_goodEvent := A.measurable_goodEvent
  lower_bound_on_good := by
    intro n r ω hω
    simpa [StepModel.toStochasticProcess] using A.lower_bound_on_good n r ω hω
  azuma_failure_bound := A.azuma_failure_bound

/-- Step-model stopping-time high-probability collapse, now driven directly by
the total-production Azuma interface. -/
theorem stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
    {S : StepModel (μ := μ)}
    (A : StepModelAzumaData (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  exact
    stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
      (μ := μ) A.toBoundedIncrementAzumaData hθ hmargin

/-- Stopping-time high-probability collapse directly from bounded increments
plus a lower-tail witness. -/
theorem stoppedCollapseWithFailureBound_of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) N r) := by
  exact
    stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := μ)
      (StepModelAzumaData.of_boundedIncrements
        (μ := μ) incrementBound incrementBound_nonneg boundedStepTotalProduction W)
      hθ hmargin

/-- Direct hitting-time event version of the previous theorem. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
    {S : StepModel (μ := μ)}
    (A : StepModelAzumaData (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
      (μ := μ) A.toBoundedIncrementAzumaData hkN hmargin

/-- Direct hitting-time event version from bounded increments plus a lower-tail
witness. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := μ)
      (StepModelAzumaData.of_boundedIncrements
        (μ := μ) incrementBound incrementBound_nonneg boundedStepTotalProduction W)
      hkN hmargin

/-- Coarse-transfer wrapper using the total-production Azuma interface on the
coarse model. -/
theorem coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : Survival.CoarseStochasticTotalProduction.CoarseStochasticCompatibility
      (μ := μ) Smicro Scoarse)
    (Acoarse : StepModelAzumaData (μ := μ) Scoarse)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) N r) := by
  have hmargin_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative N - r := by
    rw [Survival.CoarseStochasticTotalProduction.expectedCumulative_eq hcomp N]
    exact hmargin_micro
  exact stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
    (μ := μ) Acoarse hθ hmargin_coarse

/-- Coarse-transfer wrapper for the direct hitting-time event version. -/
theorem coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : Survival.CoarseStochasticTotalProduction.CoarseStochasticCompatibility
      (μ := μ) Smicro Scoarse)
    (Acoarse : StepModelAzumaData (μ := μ) Scoarse)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) k r) := by
  have hmargin_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [Survival.CoarseStochasticTotalProduction.expectedCumulative_eq hcomp k]
    exact hmargin_micro
  exact hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
    (μ := μ) Acoarse hkN hmargin_coarse

end

end Survival.StochasticTotalProductionAzuma
