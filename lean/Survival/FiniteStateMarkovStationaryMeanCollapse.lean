import Survival.FiniteStateMarkovCollapse
import Survival.FiniteStateMarkovFlatWitness
import Survival.FiniteStateMarkovMeanBridge
import Survival.StochasticTotalProductionAzuma

/-!
# Finite-State Markov Stationary Mean Collapse

This module lifts the flat-emission positive-drift collapse bounds to general
state-dependent emissions, provided the finite-state Markov chain is started in
stationarity.

The key input is the exact expectation bridge from
`FiniteStateMarkovMeanBridge`:

* on the actual finite-horizon Markov path space,
  `E[Σ_n] = s₀ + activeSteps(N,n) * stationaryMean` under stationary start;
* inside the active window, this becomes the exact linear center
  `E[Σ_n] = s₀ + n * stationaryMean`.

These exact centers can then be fed directly into the existing actual-Markov
collapse / hitting-time API from `FiniteStateMarkovCollapse`.
-/

namespace Survival.FiniteStateMarkovStationaryMeanCollapse

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.FiniteStateMarkovStationaryProduction
open Survival.FiniteStateMarkovMeanBridge
open Survival.FiniteStateMarkovCollapse
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

/-- High-probability stopped-collapse bound from the exact stationary-mean
expected center on the actual finite-state Markov path space. -/
theorem stoppedCollapseWithFailureBound_of_activeStationaryMean
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ s₀ + (activeSteps N T : ℝ) * stationaryMean S E - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) T r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative T - r := by
    rw [expectedCumulative_eq_active_stationaryMean M N s₀ S E T]
    exact hmargin
  exact
    markov_stoppedCollapseWithFailureBound_of_expectedMargin
      (M := M) (N := N) (s₀ := s₀) (E := E) W hθ hmargin'

/-- Inside the active window, the previous theorem can be read using the exact
linear stationary center `s₀ + T * stationaryMean`. -/
theorem stoppedCollapseWithFailureBound_of_stationaryMean_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {T : ℕ} (hT : T ≤ N + 1)
    {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * stationaryMean S E - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) T r) := by
  have hactive : activeSteps N T = T := by
    unfold activeSteps
    exact Nat.min_eq_left hT
  apply stoppedCollapseWithFailureBound_of_activeStationaryMean
    (M := M) (N := N) (s₀ := s₀) (S := S) (E := E) W hθ
  simpa [hactive] using hmargin

/-- Direct hitting-time-before-horizon bound from the exact stationary-mean
expected center on the actual finite-state Markov path space. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeStationaryMean
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ s₀ + (activeSteps N k : ℝ) * stationaryMean S E - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) k r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq_active_stationaryMean M N s₀ S E k]
    exact hmargin
  exact
    markov_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      (M := M) (N := N) (s₀ := s₀) (E := E) W hkT hmargin'

/-- Inside the active window, the previous theorem can be read using the exact
linear stationary center `s₀ + k * stationaryMean`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_stationaryMean_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * stationaryMean S E - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) k r) := by
  have hactive : activeSteps N k = k := by
    unfold activeSteps
    exact Nat.min_eq_left hk
  apply hittingTimeBeforeHorizonWithFailureBound_of_activeStationaryMean
    (M := M) (N := N) (s₀ := s₀) (S := S) (E := E) W hkT
  simpa [hactive] using hmargin

end

end Survival.FiniteStateMarkovStationaryMeanCollapse
