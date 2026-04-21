import Survival.BernoulliCSPToSATBridge
import Survival.KSATChernoffCollapse

/-!
# k-SAT to SAT Chernoff Bridge

This module records that the random `k`-SAT Chernoff/collapse wrapper returns
to the existing random-3-SAT Chernoff/KL stack when `k = 3`.

The result is mostly bookkeeping, but it is important bookkeeping: the
horizontal `k`-SAT generalization should not silently fork the original
machine-checked SAT chain.
-/

namespace Survival.KSATToSATChernoffBridge

open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPToSATBridge
open Survival.KSATBernoulliTemplate
open Survival.KSATClauseExposureProcess
open Survival.KSATChernoffCollapse
open Survival.SATDriftLowerBound
open Survival.SATStateDependentCountChernoffMGF
open Survival.SATStateDependentCountChernoffUpperBound
open Survival.SATStateDependentCountChernoffKL
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Any proof of `0 < 3` gives the same random-3-SAT Bernoulli parameters. -/
theorem kSATParameters_three_eq_random3SATParameters
    (h3 : 0 < 3) :
    kSATParameters 3 h3 = random3SATParameters := by
  unfold kSATParameters kSATBadProb random3SATParameters
  norm_num

/-- The `k = 3` drift in the `k`-SAT wrapper is the original random-3-SAT
drift. -/
theorem kSAT3Drift_eq_random3ClauseDrift
    (h3 : 0 < 3) :
    kSATDrift 3 h3 = random3ClauseDrift := by
  unfold kSATDrift
  rw [kSATParameters_three_eq_random3SATParameters h3]
  exact random3SATParameters_drift_eq_random3ClauseDrift

/-- The `k = 3` bad-clause MGF is the original SAT unsatisfied-count MGF. -/
theorem kSAT3BadMGF_eq_bernoulliUnsatMGF
    (t : ℝ) :
    kSATBadMGF 3 t = bernoulliUnsatMGF t := by
  rw [threeSAT_kSATBadMGF_eq]
  norm_num [bernoulliUnsatMGF]

/-- The `k = 3` Chernoff/KL failure profile agrees with the existing SAT count
Chernoff profile. -/
theorem kSAT3_chernoffFailureBound_eq_countChernoffFailureBound
    (h3 : 0 < 3) (n : ℕ) (r : ℝ) :
    KSATChernoffCollapse.countChernoffFailureBound 3 h3 n r =
      countChernoffFailureBound n r := by
  unfold KSATChernoffCollapse.countChernoffFailureBound
  rw [kSATParameters_three_eq_random3SATParameters h3]
  exact random3SATParameters_chernoffFailureBound_eq_countChernoffFailureBound n r

/-- The `k = 3` optimized closed-MGF profile agrees with the existing SAT
optimized closed-MGF profile. -/
theorem kSAT3_optimizedClosedMGF_eq_countOptimizedClosedMGF
    (h3 : 0 < 3) (n : ℕ) (r : ℝ) :
    Survival.BernoulliCSPPathChernoff.countOptimizedClosedMGFChernoffFailureBound
        (kSATParameters 3 h3) n r =
      countOptimizedClosedMGFChernoffFailureBound n r := by
  unfold Survival.BernoulliCSPPathChernoff.countOptimizedClosedMGFChernoffFailureBound
    Survival.BernoulliCSPPathChernoff.countClosedMGFChernoffFailureBound
  rw [kSATParameters_three_eq_random3SATParameters h3]
  exact random3SATParameters_optimizedClosedMGFReal_eq_countOptimizedClosedMGF n r

/-- The `k = 3` cumulative lower-tail bound can be read with the existing SAT
Chernoff/KL failure profile. -/
theorem threeSAT_cumulativeLowerTailMeasure_le_existingChernoffFailureBound_of_interior
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N
        (KSATChernoffCollapse.cumulativeLowerTailEvent
          3 (by norm_num) s₀ N n r) ≤
      countChernoffFailureBound n r := by
  calc
    KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N
        (KSATChernoffCollapse.cumulativeLowerTailEvent
          3 (by norm_num) s₀ N n r)
        ≤ KSATChernoffCollapse.countChernoffFailureBound
            3 (by norm_num) n r := by
          exact
            KSATChernoffCollapse.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
              3 (by norm_num) N hn hr
              (by
                simpa [kSAT3Drift_eq_random3ClauseDrift (by norm_num)] using hlt)
    _ = countChernoffFailureBound n r := by
          exact
            kSAT3_chernoffFailureBound_eq_countChernoffFailureBound
              (by norm_num) n r

/-- The `k = 3` threshold-crossing wrapper can be read with the existing SAT
Chernoff/KL failure profile. -/
theorem threeSAT_thresholdCrossingWithExistingChernoffBound_of_linearMargin
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift)
    (hmargin :
      -Real.log θ ≤
        Survival.BernoulliCSPPathChernoff.linearCenter random3SATParameters s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N)
      (KSATChernoffCollapse.process 3 (by norm_num) N s₀)
      n θ
      (countChernoffFailureBound n r) := by
  simpa [kSAT3_chernoffFailureBound_eq_countChernoffFailureBound (by norm_num)]
    using
      KSATChernoffCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
        3 (by norm_num) N hn hr
        (by simpa [kSAT3Drift_eq_random3ClauseDrift (by norm_num)] using hlt)
        (by
          simpa [kSATParameters_three_eq_random3SATParameters (by norm_num)]
            using hmargin)

/-- The `k = 3` collapse wrapper can be read with the existing SAT Chernoff/KL
failure profile. -/
theorem threeSAT_collapseWithExistingChernoffBound_of_linearMargin
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        Survival.BernoulliCSPPathChernoff.linearCenter random3SATParameters s₀ n - r) :
    CollapseWithFailureBound
      (μ := KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N)
      (KSATChernoffCollapse.process 3 (by norm_num) N s₀)
      n θ
      (countChernoffFailureBound n r) := by
  simpa [kSAT3_chernoffFailureBound_eq_countChernoffFailureBound (by norm_num)]
    using
      KSATChernoffCollapse.collapseWithChernoffBound_of_linearMargin
        3 (by norm_num) N hn hr
        (by simpa [kSAT3Drift_eq_random3ClauseDrift (by norm_num)] using hlt)
        hθ
        (by
          simpa [kSATParameters_three_eq_random3SATParameters (by norm_num)]
            using hmargin)

/-- The `k = 3` stopped-collapse wrapper can be read with the existing SAT
Chernoff/KL failure profile. -/
theorem threeSAT_stoppedCollapseWithExistingChernoffBound_of_linearMargin
    (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * random3ClauseDrift)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        Survival.BernoulliCSPPathChernoff.linearCenter random3SATParameters s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N)
      (KSATChernoffCollapse.process 3 (by norm_num) N s₀)
      T θ
      (countChernoffFailureBound T r) := by
  simpa [kSAT3_chernoffFailureBound_eq_countChernoffFailureBound (by norm_num)]
    using
      KSATChernoffCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
        3 (by norm_num) N hT hr
        (by simpa [kSAT3Drift_eq_random3ClauseDrift (by norm_num)] using hlt)
        hθ
        (by
          simpa [kSATParameters_three_eq_random3SATParameters (by norm_num)]
            using hmargin)

/-- The `k = 3` hitting-time wrapper can be read with the existing SAT
Chernoff/KL failure profile. -/
theorem threeSAT_hittingTimeBeforeHorizonWithExistingChernoffBound_of_linearMargin
    (N : ℕ) {j T : ℕ} (hjT : j < T) (hj : j ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * random3ClauseDrift)
    (hmargin :
      -Real.log θ ≤
        Survival.BernoulliCSPPathChernoff.linearCenter random3SATParameters s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := KSATClauseExposureProcess.pathMeasure 3 (by norm_num) N)
      (KSATChernoffCollapse.process 3 (by norm_num) N s₀)
      T θ
      (countChernoffFailureBound j r) := by
  simpa [kSAT3_chernoffFailureBound_eq_countChernoffFailureBound (by norm_num)]
    using
      KSATChernoffCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
        3 (by norm_num) N hjT hj hr
        (by simpa [kSAT3Drift_eq_random3ClauseDrift (by norm_num)] using hlt)
        (by
          simpa [kSATParameters_three_eq_random3SATParameters (by norm_num)]
            using hmargin)

end

end Survival.KSATToSATChernoffBridge
