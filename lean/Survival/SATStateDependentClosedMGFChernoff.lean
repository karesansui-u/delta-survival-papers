import Survival.SATStateDependentCountMGFProduct

/-!
# SAT State-Dependent Closed MGF Chernoff Bound

This module plugs the internally derived Bernoulli-product MGF witness into the
closed MGF Chernoff wrappers.

After `SATStateDependentCountMGFProduct`, the hypothesis
`HasBernoulliMGFUpperBound` is no longer external: it follows from the actual
recursive SAT clause-exposure path PMF.  Therefore the closed MGF Chernoff tail
profile, and the resulting threshold / collapse / hitting-time bounds, are
available for the non-flat SAT process with no additional probabilistic witness.
-/

namespace Survival.SATStateDependentClosedMGFChernoff

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountChernoffMGF
open Survival.SATStateDependentCountMGFProduct
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- The closed Bernoulli MGF Chernoff profile is an actual count-tail upper
bound for the SAT clause-exposure process.  The MGF witness is generated from
`pathPMF`, not assumed externally. -/
theorem hasCountFailureUpperBound_closedMGFChernoff_pathPMF
    (N : ℕ) {t : ℝ} (ht : t ≤ 0) :
    HasCountFailureUpperBound N (countClosedMGFChernoffFailureBound t) := by
  exact
    hasCountFailureUpperBound_closedMGFChernoff_of_mgf
      N ht (hasBernoulliMGFUpperBound_pathPMF N t)

/-- Direct exact count-tail bound by the closed Bernoulli MGF Chernoff profile. -/
theorem exactCountFailureBound_le_closedMGFChernoff_pathPMF
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ) {t : ℝ} (ht : t ≤ 0) :
    exactCountFailureBound N n r ≤ countClosedMGFChernoffFailureBound t n r := by
  exact hasCountFailureUpperBound_closedMGFChernoff_pathPMF N ht hn r

/-- The support-clipped closed MGF Chernoff profile is an unconditional SAT
count-tail upper bound. -/
theorem hasCountFailureUpperBound_supportClippedClosedMGFChernoff_pathPMF
    (N : ℕ) {t : ℝ} (ht : t ≤ 0) :
    HasCountFailureUpperBound N
      (satSupportClippedClosedMGFChernoffFailureBound t) := by
  exact
    hasCountFailureUpperBound_supportClippedClosedMGFChernoff
      N ht (hasBernoulliMGFUpperBound_pathPMF N t)

/-- Active-prefix exact SAT lower-tail failure is bounded by the support-clipped
closed MGF Chernoff profile. -/
theorem exactFailureBound_le_supportClippedClosedMGFChernoff_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ r t : ℝ} (ht : t ≤ 0) :
    exactFailureBound N s₀ n r ≤
      satSupportClippedClosedMGFChernoffFailureBound t n r := by
  exact
    exactFailureBound_le_of_hasCountFailureUpperBound
      hn
      (hB := hasCountFailureUpperBound_supportClippedClosedMGFChernoff_pathPMF
        N ht)

/-- Active-prefix threshold crossing under the support-clipped closed MGF
Chernoff profile, with the MGF witness supplied by `pathPMF`. -/
theorem thresholdCrossingWithClosedMGFChernoffBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedClosedMGFChernoffFailureBound t n r) := by
  exact
    thresholdCrossingWithClosedMGFChernoffBound_of_activeLinearMargin
      hn ht (hasBernoulliMGFUpperBound_pathPMF N t) hmargin

/-- Active-prefix collapse under the support-clipped closed MGF Chernoff
profile, with no external MGF hypothesis. -/
theorem collapseWithClosedMGFChernoffBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedClosedMGFChernoffFailureBound t n r) := by
  exact
    collapseWithFailureBound_of_thresholdCrossingWithFailureBound
      _ _ hθ
      (thresholdCrossingWithClosedMGFChernoffBound_pathPMF
        hn ht hmargin)

/-- Active-prefix stopped-collapse bound under the support-clipped closed MGF
Chernoff profile, with the MGF witness supplied by `pathPMF`. -/
theorem stoppedCollapseWithClosedMGFChernoffBound_pathPMF
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedClosedMGFChernoffFailureBound t T r) := by
  exact
    stoppedCollapseWithClosedMGFChernoffBound_of_activeLinearMargin
      hT ht (hasBernoulliMGFUpperBound_pathPMF N t) hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound under the support-clipped
closed MGF Chernoff profile, with no external MGF hypothesis. -/
theorem hittingTimeBeforeHorizonWithClosedMGFChernoffBound_pathPMF
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedClosedMGFChernoffFailureBound t k r) := by
  exact
    hittingTimeBeforeHorizonWithClosedMGFChernoffBound_of_activeLinearMargin
      hkT hk ht (hasBernoulliMGFUpperBound_pathPMF N t) hmargin

end

end Survival.SATStateDependentClosedMGFChernoff
