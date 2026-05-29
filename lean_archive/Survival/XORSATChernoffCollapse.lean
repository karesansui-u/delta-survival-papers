import Survival.BernoulliCSPPathCollapse
import Survival.XORSATClauseExposureProcess

/-!
# XOR-SAT Chernoff Collapse Bound

This module packages the generic Bernoulli-CSP path Chernoff theorem as a
domain-facing statement for fixed-assignment random `k`-XOR-SAT exposure.

The scope is deliberately finite-horizon and iid Bernoulli bad-event exposure.
Full XOR-SAT rank/nullity dynamics are a different layer.
-/

namespace Survival.XORSATChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.XORSATBernoulliTemplate
open Survival.XORSATClauseExposureProcess
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Random `k`-XOR-SAT Chernoff/KL count failure profile. -/
def countChernoffFailureBound (k : ℕ) :
    CountFailureProfile :=
  (xorSATParameters k).chernoffFailureBound

/-- Random `k`-XOR-SAT exact bad-count lower-tail failure profile. -/
def exactCountFailureBound (k : ℕ)
    (N n : ℕ) (r : ℝ) : ENNReal :=
  BernoulliCSPPathChernoff.exactCountFailureBound
    (xorSATParameters k) N n r

/-- Random `k`-XOR-SAT cumulative production observable induced by one-sided bad
equation emission. -/
def cumulativeProduction (k : ℕ) (s₀ : ℝ)
    {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  BernoulliCSPPathChernoff.cumulativeProduction
    (xorSATParameters k) s₀ τ n

/-- Random `k`-XOR-SAT lower-tail event for the cumulative production
observable. -/
def cumulativeLowerTailEvent (k : ℕ)
    (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  BernoulliCSPPathChernoff.cumulativeLowerTailEvent
    (xorSATParameters k) s₀ N n r

/-- Random `k`-XOR-SAT cumulative-production process induced by one-sided bad
equation emission. -/
def process (k : ℕ) (N : ℕ) (s₀ : ℝ) :=
  BernoulliCSPPathCollapse.process (xorSATParameters k) N s₀

/-- Interior KL/Chernoff count-tail bound for random `k`-XOR-SAT exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (k : ℕ) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * xorSATDrift k) :
    exactCountFailureBound k N n r ≤
      countChernoffFailureBound k n r := by
  exact
    BernoulliCSPPathChernoff.exactCountFailureBound_le_chernoffFailureBound_of_interior
      (xorSATParameters k) N hn hr (by simpa [xorSATDrift] using hlt)

/-- Interior KL/Chernoff lower-tail bound for the random `k`-XOR-SAT cumulative
production observable. -/
theorem cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (k : ℕ) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * xorSATDrift k) :
    pathMeasure k N (cumulativeLowerTailEvent k s₀ N n r) ≤
      countChernoffFailureBound k n r := by
  exact
    BernoulliCSPPathChernoff.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      (xorSATParameters k) N hn hr (by simpa [xorSATDrift] using hlt)

/-- Fixed-time threshold crossing for random `k`-XOR-SAT under the KL/Chernoff
failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (k : ℕ) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * xorSATDrift k)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (xorSATParameters k) s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure k N)
      (process k N s₀)
      n θ
      (countChernoffFailureBound k n r) := by
  exact
    BernoulliCSPPathCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
      (xorSATParameters k) N hn hr (by simpa [xorSATDrift] using hlt) hmargin

/-- Fixed-time collapse for random `k`-XOR-SAT under the KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (k : ℕ) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * xorSATDrift k)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (xorSATParameters k) s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure k N)
      (process k N s₀)
      n θ
      (countChernoffFailureBound k n r) := by
  exact
    BernoulliCSPPathCollapse.collapseWithChernoffBound_of_linearMargin
      (xorSATParameters k) N hn hr (by simpa [xorSATDrift] using hlt)
      hθ hmargin

/-- Terminal stopped-collapse for random `k`-XOR-SAT under the KL/Chernoff
failure profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (k : ℕ) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * xorSATDrift k)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (xorSATParameters k) s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure k N)
      (process k N s₀)
      T θ
      (countChernoffFailureBound k T r) := by
  exact
    BernoulliCSPPathCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      (xorSATParameters k) N hT hr (by simpa [xorSATDrift] using hlt)
      hθ hmargin

/-- Earlier threshold crossing gives a high-probability hitting-time-before-
horizon bound for random `k`-XOR-SAT. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (k : ℕ) (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * xorSATDrift k)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (xorSATParameters k) s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure k N)
      (process k N s₀)
      T θ
      (countChernoffFailureBound k j r) := by
  exact
    BernoulliCSPPathCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      (xorSATParameters k) N hjT hj hr (by simpa [xorSATDrift] using hlt)
      hmargin

end

end Survival.XORSATChernoffCollapse
