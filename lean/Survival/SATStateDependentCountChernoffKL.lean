import Survival.SATStateDependentClosedMGFChernoff
import Survival.SATStateDependentCountChernoffUpperBound

/-!
# SAT State-Dependent Count Chernoff KL Layer

This module adds the optimization-facing layer after the self-contained closed
MGF Chernoff bound.

The preceding module proves that, for every fixed `t ≤ 0`, the actual non-flat
SAT clause-exposure process satisfies a closed MGF Chernoff tail bound.  Here we
make the lower-tail tilt depend on the induced count threshold ratio.  To keep
the bound total over all parameters, the tilt is clipped by `min 0`, so it is
always admissible for the lower-tail Chernoff inequality.

The file also records the remaining algebraic bridge to the textbook KL-rate
candidate: once the optimized MGF profile is shown to be dominated by the
relative-entropy candidate from `SATStateDependentCountChernoffUpperBound`, the
older KL/Chernoff wrapper is obtained automatically.
-/

namespace Survival.SATStateDependentCountChernoffKL

open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountSupportClippedUpperBound
open Survival.SATStateDependentCountChernoffMGF
open Survival.SATStateDependentClosedMGFChernoff
open Survival.SATStateDependentCountChernoffUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Standard Bernoulli lower-tail exponential tilt.  In the KL regime
`0 < q ≤ p < 1`, this is nonpositive and is the optimizer of the MGF Chernoff
bound. -/
def bernoulliLowerTailTilt (q p : ℝ) : ℝ :=
  Real.log ((q * (1 - p)) / (p * (1 - q)))

/-- SAT-specialized lower-tail tilt for unsatisfied-clause probability `1 / 8`.
-/
def satLowerTailTilt (q : ℝ) : ℝ :=
  bernoulliLowerTailTilt q (1 / 8 : ℝ)

/-- Total admissible tilt: if the formal lower-tail optimizer is positive, use
`0` instead.  This keeps the closed MGF Chernoff profile valid for every
threshold parameter. -/
def clippedSatLowerTailTilt (q : ℝ) : ℝ :=
  min 0 (satLowerTailTilt q)

theorem clippedSatLowerTailTilt_nonpos (q : ℝ) :
    clippedSatLowerTailTilt q ≤ 0 := by
  exact min_le_left 0 (satLowerTailTilt q)

theorem clippedSatLowerTailTilt_eq_of_nonpos
    {q : ℝ} (h : satLowerTailTilt q ≤ 0) :
    clippedSatLowerTailTilt q = satLowerTailTilt q := by
  exact min_eq_right h

/-- Count-threshold-dependent admissible Chernoff tilt. -/
def countOptimizingTilt (n : ℕ) (r : ℝ) : ℝ :=
  clippedSatLowerTailTilt (countThresholdRatio n r)

theorem countOptimizingTilt_nonpos (n : ℕ) (r : ℝ) :
    countOptimizingTilt n r ≤ 0 :=
  clippedSatLowerTailTilt_nonpos (countThresholdRatio n r)

theorem countOptimizingTilt_eq_unclipped_of_nonpos
    {n : ℕ} {r : ℝ}
    (h : satLowerTailTilt (countThresholdRatio n r) ≤ 0) :
    countOptimizingTilt n r = satLowerTailTilt (countThresholdRatio n r) := by
  exact clippedSatLowerTailTilt_eq_of_nonpos h

/-- Optimized closed-MGF Chernoff profile obtained by substituting the
threshold-dependent clipped lower-tail tilt. -/
def countOptimizedClosedMGFChernoffFailureBound : CountFailureProfile :=
  fun n r =>
    countClosedMGFChernoffFailureBound (countOptimizingTilt n r) n r

/-- The optimized closed-MGF profile is an actual count-tail upper bound for
the SAT clause-exposure process. -/
theorem hasCountFailureUpperBound_optimizedClosedMGF_pathPMF
    (N : ℕ) :
    HasCountFailureUpperBound N countOptimizedClosedMGFChernoffFailureBound := by
  intro n hn r
  exact
    exactCountFailureBound_le_closedMGFChernoff_pathPMF
      N hn r (ht := countOptimizingTilt_nonpos n r)

/-- Direct exact count-tail bound by the optimized closed-MGF profile. -/
theorem exactCountFailureBound_le_optimizedClosedMGF_pathPMF
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ) :
    exactCountFailureBound N n r ≤
      countOptimizedClosedMGFChernoffFailureBound n r :=
  hasCountFailureUpperBound_optimizedClosedMGF_pathPMF N hn r

/-- Support-clipped optimized closed-MGF Chernoff profile. -/
def satSupportClippedOptimizedClosedMGFChernoffFailureBound : CountFailureProfile :=
  supportClippedFailureBound countOptimizedClosedMGFChernoffFailureBound

theorem hasCountFailureUpperBound_supportClippedOptimizedClosedMGF_pathPMF
    (N : ℕ) :
    HasCountFailureUpperBound N
      satSupportClippedOptimizedClosedMGFChernoffFailureBound :=
  hasCountFailureUpperBound_supportClipped
    (B := countOptimizedClosedMGFChernoffFailureBound)
    (hasCountFailureUpperBound_optimizedClosedMGF_pathPMF N)

/-- Active-prefix threshold crossing under the optimized closed-MGF Chernoff
profile. -/
theorem thresholdCrossingWithOptimizedClosedMGFBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedOptimizedClosedMGFChernoffFailureBound n r) := by
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedOptimizedClosedMGFChernoffFailureBound)
      (hB := hasCountFailureUpperBound_supportClippedOptimizedClosedMGF_pathPMF N)
      hmargin

/-- Active-prefix collapse under the optimized closed-MGF Chernoff profile. -/
theorem collapseWithOptimizedClosedMGFBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedOptimizedClosedMGFChernoffFailureBound n r) := by
  exact
    collapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedOptimizedClosedMGFChernoffFailureBound)
      (hB := hasCountFailureUpperBound_supportClippedOptimizedClosedMGF_pathPMF N)
      hθ hmargin

/-- Active-prefix stopped-collapse under the optimized closed-MGF Chernoff
profile. -/
theorem stoppedCollapseWithOptimizedClosedMGFBound_pathPMF
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedOptimizedClosedMGFChernoffFailureBound T r) := by
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (B := satSupportClippedOptimizedClosedMGFChernoffFailureBound)
      (hB := hasCountFailureUpperBound_supportClippedOptimizedClosedMGF_pathPMF N)
      hθ hmargin

/-- Active-prefix hitting-time-before-horizon under the optimized closed-MGF
Chernoff profile. -/
theorem hittingTimeBeforeHorizonWithOptimizedClosedMGFBound_pathPMF
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedOptimizedClosedMGFChernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (B := satSupportClippedOptimizedClosedMGFChernoffFailureBound)
      (hB := hasCountFailureUpperBound_supportClippedOptimizedClosedMGF_pathPMF N)
      hmargin

/-- The remaining purely algebraic KL-optimization bridge: the automatically
optimized MGF profile is dominated by the textbook KL candidate.  Once this
real-variable inequality is proved, the older `countChernoffFailureBound`
candidate becomes an unconditional SAT count-tail bound. -/
def HasOptimizedMGFToKLBound : Prop :=
  ∀ n r,
    countOptimizedClosedMGFChernoffFailureBound n r ≤
      countChernoffFailureBound n r

/-- If the optimized MGF profile is algebraically dominated by the KL candidate,
then the KL/Chernoff candidate from `SATStateDependentCountChernoffUpperBound`
is an unconditional count-tail upper bound. -/
theorem hasCountChernoffFailureUpperBound_of_optimizedMGFToKL
    (N : ℕ)
    (hKL : HasOptimizedMGFToKLBound) :
    HasCountChernoffFailureUpperBound N := by
  intro n hn r
  exact
    (exactCountFailureBound_le_optimizedClosedMGF_pathPMF N hn r).trans
      (hKL n r)

/-- Consequently, under the remaining algebraic KL bridge, the support-clipped
KL/Chernoff profile also gives the standard stopped-collapse bound. -/
theorem stoppedCollapseWithChernoffBound_of_optimizedMGFToKL
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasOptimizedMGFToKLBound)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (satProcess N s₀)
      T θ
      (satSupportClippedCountChernoffFailureBound T r) := by
  exact
    stoppedCollapseWithChernoffBound_of_activeLinearMargin
      hT (hasCountChernoffFailureUpperBound_of_optimizedMGFToKL N hKL)
      hθ hmargin

/-- Under the same algebraic KL bridge, the support-clipped KL/Chernoff profile
gives the standard hitting-time-before-horizon bound. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_optimizedMGFToKL
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasOptimizedMGFToKLBound)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (satProcess N s₀)
      T θ
      (satSupportClippedCountChernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithChernoffBound_of_activeLinearMargin
      hkT hk (hasCountChernoffFailureUpperBound_of_optimizedMGFToKL N hKL)
      hmargin

end

end Survival.SATStateDependentCountChernoffKL
