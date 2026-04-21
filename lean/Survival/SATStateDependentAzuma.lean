import Survival.SATStateDependentClauseExposure
import Survival.StochasticTotalProductionAzuma

/-!
# SAT State-Dependent Azuma Bridge

This module packages the actual non-flat SAT clause-exposure process into the
generic `StepModel` Azuma interface.

The concentration witness itself is still supplied externally. The role of this
file is to remove all SAT-specific bookkeeping:

* the probability space is fixed to the actual clause-exposure path measure;
* the observable is the non-flat emission `sat ↦ 0`, `unsat ↦ 8 * log (8 / 7)`;
* bounded increments are generated automatically from the emission bound;
* exact linear expected centers on the active prefix are exposed as ready-to-use
  wrappers for collapse and hitting-time bounds.
-/

namespace Survival.SATStateDependentAzuma

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

/-- Constant increment bound for the concrete non-flat SAT emission. -/
def incrementBound : ℕ → ℝ :=
  fun _ => emissionBound oneSidedUnsatEmission

theorem incrementBound_nonneg :
    ∀ t, 0 ≤ incrementBound t := by
  intro t
  unfold incrementBound emissionBound
  positivity

/-- SAT-specific Azuma data on the actual clause-exposure path space, once a
lower-tail witness has been supplied. -/
def stepModelAzumaData
    (N : ℕ) (s₀ : ℝ)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission)
        incrementBound) :
    StepModelAzumaData
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission) :=
  StepModelAzumaData.of_boundedIncrements
    (μ := pathMeasure N)
    incrementBound
    incrementBound_nonneg
    (boundedStepTotalProduction N s₀ oneSidedUnsatEmission)
    W

/-- Direct stopped-collapse wrapper for the actual non-flat SAT process, once a
SAT-specific lower-tail witness is available. -/
theorem stoppedCollapseWithFailureBound_of_expectedMargin
    {N : ℕ} {s₀ θ r : ℝ}
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission)
        incrementBound)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) N r) := by
  exact
    StochasticTotalProductionAzuma.stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := pathMeasure N)
      (stepModelAzumaData N s₀ W)
      hθ hmargin

/-- Direct hitting-time-before-horizon wrapper for the actual non-flat SAT
process, once a SAT-specific lower-tail witness is available. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    {N : ℕ} {k : ℕ} (hkN : k < N) {s₀ θ r : ℝ}
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission)
        incrementBound)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) k r) := by
  exact
    StochasticTotalProductionAzuma.hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := pathMeasure N)
      (stepModelAzumaData N s₀ W)
      hkN hmargin

/-- On the active prefix, the exact linear center can be fed directly into the
stopped-collapse API. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission)
        incrementBound)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) T r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative T - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hT]
    exact hmargin
  exact
    StochasticTotalProductionAzuma.stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := pathMeasure N)
      (S := stepModel N s₀ oneSidedUnsatEmission)
      (stepModelAzumaData N s₀ W)
      (N := T)
      hθ hmargin'

/-- Likewise for the direct hitting-time-before-horizon API on the active
prefix. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission)
        incrementBound)
    (hmargin :
      -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) k r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hk]
    exact hmargin
  exact
    StochasticTotalProductionAzuma.hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
      (μ := pathMeasure N)
      (S := stepModel N s₀ oneSidedUnsatEmission)
      (stepModelAzumaData N s₀ W)
      (N := T)
      hkT hmargin'

end

end Survival.SATStateDependentAzuma
