import Survival.BernoulliCSPPathCollapse
import Survival.ForbiddenPatternCSPExposureProcess

/-!
# Forbidden-Pattern CSP Chernoff Collapse Bound

This module packages the generic Bernoulli-CSP path Chernoff theorem as a
domain-facing statement for finite-alphabet forbidden-pattern exposure.
-/

namespace Survival.ForbiddenPatternCSPChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.ForbiddenPatternCSPTemplate
open Survival.ForbiddenPatternCSPExposureProcess
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Chernoff/KL count failure profile for forbidden-pattern exposure. -/
def countChernoffFailureBound
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    CountFailureProfile :=
  Parameters.chernoffFailureBound
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt)

/-- Exact bad-count lower-tail failure profile. -/
def exactCountFailureBound
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity)
    (N n : ℕ) (r : ℝ) : ENNReal :=
  BernoulliCSPPathChernoff.exactCountFailureBound
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N n r

/-- Cumulative production observable induced by one-sided bad-pattern emission. -/
def cumulativeProduction
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (s₀ : ℝ)
    {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  BernoulliCSPPathChernoff.cumulativeProduction
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) s₀ τ n

/-- Lower-tail event for the cumulative production observable. -/
def cumulativeLowerTailEvent
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity)
    (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  BernoulliCSPPathChernoff.cumulativeLowerTailEvent
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) s₀ N n r

/-- Cumulative-production process induced by one-sided bad-pattern emission. -/
def process
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity)
    (N : ℕ) (s₀ : ℝ) :=
  BernoulliCSPPathCollapse.process
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N s₀

/-- Interior KL/Chernoff count-tail bound for forbidden-pattern exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (n : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb) :
    exactCountFailureBound alphabet forbidden arity ha hf hforb N n r ≤
      countChernoffFailureBound alphabet forbidden arity ha hf hforb n r := by
  simpa [exactCountFailureBound, countChernoffFailureBound] using
    BernoulliCSPPathChernoff.exactCountFailureBound_le_chernoffFailureBound_of_interior
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hn hr (by simpa [forbiddenPatternDrift] using hlt)

/-- Interior KL/Chernoff lower-tail bound for the cumulative production
observable. -/
theorem cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (n : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb) :
    pathMeasure alphabet forbidden arity ha hf hforb N
        (cumulativeLowerTailEvent
          alphabet forbidden arity ha hf hforb s₀ N n r) ≤
      countChernoffFailureBound alphabet forbidden arity ha hf hforb n r := by
  simpa [
    ForbiddenPatternCSPExposureProcess.pathMeasure,
    cumulativeLowerTailEvent,
    countChernoffFailureBound,
  ] using
    BernoulliCSPPathChernoff.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hn hr (by simpa [forbiddenPatternDrift] using hlt)

/-- Fixed-time threshold crossing for forbidden-pattern exposure under the
KL/Chernoff failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (n : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
          s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure alphabet forbidden arity ha hf hforb N)
      (process alphabet forbidden arity ha hf hforb N s₀)
      n θ
      (countChernoffFailureBound alphabet forbidden arity ha hf hforb n r) := by
  simpa [
    ForbiddenPatternCSPExposureProcess.pathMeasure,
    process,
    countChernoffFailureBound,
  ] using
    BernoulliCSPPathCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hn hr (by simpa [forbiddenPatternDrift] using hlt) hmargin

/-- Fixed-time collapse for forbidden-pattern exposure under the KL/Chernoff
failure profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (n : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
          s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure alphabet forbidden arity ha hf hforb N)
      (process alphabet forbidden arity ha hf hforb N s₀)
      n θ
      (countChernoffFailureBound alphabet forbidden arity ha hf hforb n r) := by
  simpa [
    ForbiddenPatternCSPExposureProcess.pathMeasure,
    process,
    countChernoffFailureBound,
  ] using
    BernoulliCSPPathCollapse.collapseWithChernoffBound_of_linearMargin
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hn hr (by simpa [forbiddenPatternDrift] using hlt) hθ hmargin

/-- Terminal stopped-collapse for forbidden-pattern exposure under the
KL/Chernoff failure profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (T : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
          s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure alphabet forbidden arity ha hf hforb N)
      (process alphabet forbidden arity ha hf hforb N s₀)
      T θ
      (countChernoffFailureBound alphabet forbidden arity ha hf hforb T r) := by
  simpa [
    ForbiddenPatternCSPExposureProcess.pathMeasure,
    process,
    countChernoffFailureBound,
  ] using
    BernoulliCSPPathCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hT hr (by simpa [forbiddenPatternDrift] using hlt) hθ hmargin

/-- Earlier threshold crossing gives a high-probability hitting-time-before-
horizon bound for forbidden-pattern exposure. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity)
    (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (j : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
          s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure alphabet forbidden arity ha hf hforb N)
      (process alphabet forbidden arity ha hf hforb N s₀)
      T θ
      (countChernoffFailureBound alphabet forbidden arity ha hf hforb j r) := by
  simpa [
    ForbiddenPatternCSPExposureProcess.pathMeasure,
    process,
    countChernoffFailureBound,
  ] using
    BernoulliCSPPathCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      N hjT hj hr (by simpa [forbiddenPatternDrift] using hlt) hmargin

end

end Survival.ForbiddenPatternCSPChernoffCollapse
