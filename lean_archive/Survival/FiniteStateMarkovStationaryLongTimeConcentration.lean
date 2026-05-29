import Survival.FiniteStateMarkovStationaryMeanCollapse
import Survival.FiniteStateMarkovErgodicProduction

/-!
# Finite-State Markov Stationary Long-Time Concentration

This module repackages the stationary-mean positive-drift collapse bounds into
a prefix-family form suited for long-time reading.

The idea is conservative:

* keep working with finite-horizon actual Markov path measures;
* choose a `PrefixFamily` whose active window always contains the prefix under
  study;
* evaluate the stationary-start exact center at the prefix time `n + 1`;
* feed that center directly into the finite-horizon collapse / hitting-time
  interface.

This gives a first long-time concentration layer without needing a full
infinite-horizon construction.
-/

namespace Survival.FiniteStateMarkovStationaryLongTimeConcentration

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.FiniteStateMarkovStationaryProduction
open Survival.FiniteStateMarkovErgodicProduction
open Survival.FiniteStateMarkovStationaryMeanCollapse
open Survival.FiniteStateMarkovCollapse
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

/-- Exact linear center at prefix time `n + 1`, rewritten through the
prefix-normalized stationary average. -/
theorem prefixLinearCenter_eq_mul_stationaryPrefixAverage
    (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission)
    (n : ℕ) :
    s₀ + ((n + 1 : ℕ) : ℝ) * stationaryMean S E =
      (((n + 1 : ℕ) : ℝ) * stationaryPrefixAverage s₀ H S E n) := by
  rw [stationaryPrefixAverage_eq_mean_add_correction]
  have hcast : (((n + 1 : ℕ) : ℝ)) = (n : ℝ) + 1 := by norm_num
  rw [hcast]
  have hden : ((n : ℝ) + 1) ≠ 0 := by positivity
  field_simp [hden]
  ring

/-- Long-time stopped-collapse bound along a prefix family, stated through the
prefix-normalized stationary average. -/
theorem stoppedCollapseWithFailureBound_of_stationaryPrefixAverage
    (M : ChainData) (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission)
    (W :
      ∀ n,
        StepModelLowerTailWitness
          (μ := pathMeasure M (H.horizon n))
          (stepModel M (H.horizon n) s₀ E)
          (incrementBound E))
    {n : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (((n + 1 : ℕ) : ℝ) * stationaryPrefixAverage s₀ H S E n) - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M (H.horizon n))
      (stepModel M (H.horizon n) s₀ E).toStochasticProcess (n + 1) θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) (n + 1) r) := by
  have hprefix : n + 1 ≤ H.horizon n + 1 := Nat.succ_le_succ (H.active n)
  have hmargin' :
      -Real.log θ ≤
        s₀ + ((n + 1 : ℕ) : ℝ) * stationaryMean S E - r := by
    rw [prefixLinearCenter_eq_mul_stationaryPrefixAverage]
    exact hmargin
  exact
    stoppedCollapseWithFailureBound_of_stationaryMean_of_le
      (M := M) (N := H.horizon n) (s₀ := s₀) (S := S) (E := E) (W n) hprefix hθ hmargin'

/-- Long-time direct hitting-time-before-horizon bound along a prefix family,
using the exact stationary-mean center on the prefix `0, ..., n`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_stationaryPrefixMean
    (M : ChainData) (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission)
    (W :
      ∀ n,
        StepModelLowerTailWitness
          (μ := pathMeasure M (H.horizon n))
          (stepModel M (H.horizon n) s₀ E)
          (incrementBound E))
    {n : ℕ} {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ s₀ + (n : ℝ) * stationaryMean S E - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M (H.horizon n))
      (stepModel M (H.horizon n) s₀ E).toStochasticProcess (n + 1) θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) n r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_stationaryMean_of_le
      (M := M) (N := H.horizon n) (s₀ := s₀) (S := S) (E := E) (W n)
      (Nat.lt_succ_self n) (Nat.le_trans (H.active n) (Nat.le_succ _)) hmargin

end

end Survival.FiniteStateMarkovStationaryLongTimeConcentration
