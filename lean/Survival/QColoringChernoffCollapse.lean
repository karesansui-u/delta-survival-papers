import Survival.BernoulliCSPPathCollapse
import Survival.QColoringEdgeExposureProcess

/-!
# q-Coloring Chernoff Collapse Bound

This module packages the generic Bernoulli-CSP path Chernoff theorem as a
domain-facing statement for fixed-coloring `q`-coloring edge exposure.

The scope is finite-horizon iid Bernoulli bad-edge exposure.  Random graph
dependence, degree correlations, and coloring-algorithm dynamics are separate
layers.
-/

namespace Survival.QColoringChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.QColoringBernoulliTemplate
open Survival.QColoringEdgeExposureProcess
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- `q`-coloring Chernoff/KL count failure profile. -/
def countChernoffFailureBound (q : ℝ) (hq : 1 < q) :
    CountFailureProfile :=
  (qColoringParameters q hq).chernoffFailureBound

/-- Exact bad-count lower-tail failure profile for `q`-coloring exposure. -/
def exactCountFailureBound (q : ℝ) (hq : 1 < q)
    (N n : ℕ) (r : ℝ) : ENNReal :=
  BernoulliCSPPathChernoff.exactCountFailureBound
    (qColoringParameters q hq) N n r

/-- `q`-coloring cumulative production observable induced by one-sided bad-edge
emission. -/
def cumulativeProduction (q : ℝ) (hq : 1 < q) (s₀ : ℝ)
    {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  BernoulliCSPPathChernoff.cumulativeProduction
    (qColoringParameters q hq) s₀ τ n

/-- `q`-coloring lower-tail event for the cumulative production observable. -/
def cumulativeLowerTailEvent (q : ℝ) (hq : 1 < q)
    (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  BernoulliCSPPathChernoff.cumulativeLowerTailEvent
    (qColoringParameters q hq) s₀ N n r

/-- `q`-coloring cumulative-production process induced by one-sided bad-edge
emission. -/
def process (q : ℝ) (hq : 1 < q) (N : ℕ) (s₀ : ℝ) :=
  BernoulliCSPPathCollapse.process (qColoringParameters q hq) N s₀

/-- Interior KL/Chernoff count-tail bound for `q`-coloring exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (q : ℝ) (hq : 1 < q) (N : ℕ) {n : ℕ}
    (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * qColoringDrift q hq) :
    exactCountFailureBound q hq N n r ≤
      countChernoffFailureBound q hq n r := by
  exact
    BernoulliCSPPathChernoff.exactCountFailureBound_le_chernoffFailureBound_of_interior
      (qColoringParameters q hq) N hn hr (by simpa [qColoringDrift] using hlt)

/-- Interior KL/Chernoff lower-tail bound for the `q`-coloring cumulative
production observable. -/
theorem cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (q : ℝ) (hq : 1 < q) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * qColoringDrift q hq) :
    pathMeasure q hq N (cumulativeLowerTailEvent q hq s₀ N n r) ≤
      countChernoffFailureBound q hq n r := by
  exact
    BernoulliCSPPathChernoff.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      (qColoringParameters q hq) N hn hr (by simpa [qColoringDrift] using hlt)

/-- Fixed-time threshold crossing for `q`-coloring under the KL/Chernoff
failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (q : ℝ) (hq : 1 < q) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * qColoringDrift q hq)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (qColoringParameters q hq) s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure q hq N)
      (process q hq N s₀)
      n θ
      (countChernoffFailureBound q hq n r) := by
  exact
    BernoulliCSPPathCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
      (qColoringParameters q hq) N hn hr (by simpa [qColoringDrift] using hlt)
      hmargin

/-- Fixed-time collapse for `q`-coloring under the KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (q : ℝ) (hq : 1 < q) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * qColoringDrift q hq)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (qColoringParameters q hq) s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure q hq N)
      (process q hq N s₀)
      n θ
      (countChernoffFailureBound q hq n r) := by
  exact
    BernoulliCSPPathCollapse.collapseWithChernoffBound_of_linearMargin
      (qColoringParameters q hq) N hn hr (by simpa [qColoringDrift] using hlt)
      hθ hmargin

/-- Terminal stopped-collapse for `q`-coloring under the KL/Chernoff failure
profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (q : ℝ) (hq : 1 < q) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * qColoringDrift q hq)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (qColoringParameters q hq) s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure q hq N)
      (process q hq N s₀)
      T θ
      (countChernoffFailureBound q hq T r) := by
  exact
    BernoulliCSPPathCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      (qColoringParameters q hq) N hT hr (by simpa [qColoringDrift] using hlt)
      hθ hmargin

/-- Earlier threshold crossing gives a high-probability hitting-time-before-
horizon bound for `q`-coloring. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (q : ℝ) (hq : 1 < q) (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * qColoringDrift q hq)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (qColoringParameters q hq) s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure q hq N)
      (process q hq N s₀)
      T θ
      (countChernoffFailureBound q hq j r) := by
  exact
    BernoulliCSPPathCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      (qColoringParameters q hq) N hjT hj hr
      (by simpa [qColoringDrift] using hlt)
      hmargin

end

end Survival.QColoringChernoffCollapse
