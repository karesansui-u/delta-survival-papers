import Survival.BernoulliCSPPathCollapse
import Survival.NAESATClauseExposureProcess

/-!
# NAE-SAT Chernoff Collapse Bound

This module packages the generic Bernoulli-CSP path Chernoff theorem as a
domain-facing random `k`-NAE-SAT exposure statement.

The scope is finite-horizon iid bad-clause exposure under a fixed assignment.
It does not model solver-adaptive dynamics or dependence between generated
clauses.
-/

namespace Survival.NAESATChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.NAESATBernoulliTemplate
open Survival.NAESATClauseExposureProcess
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Random `k`-NAE-SAT Chernoff/KL count failure profile. -/
def countChernoffFailureBound (k : ℕ) (hk : 1 < k) :
    CountFailureProfile :=
  (naeSATParameters k hk).chernoffFailureBound

/-- Random `k`-NAE-SAT exact bad-count lower-tail failure profile. -/
def exactCountFailureBound (k : ℕ) (hk : 1 < k)
    (N n : ℕ) (r : ℝ) : ENNReal :=
  BernoulliCSPPathChernoff.exactCountFailureBound
    (naeSATParameters k hk) N n r

/-- Random `k`-NAE-SAT cumulative production observable induced by one-sided
bad-clause emission. -/
def cumulativeProduction (k : ℕ) (hk : 1 < k) (s₀ : ℝ)
    {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  BernoulliCSPPathChernoff.cumulativeProduction
    (naeSATParameters k hk) s₀ τ n

/-- Random `k`-NAE-SAT lower-tail event for the cumulative production
observable. -/
def cumulativeLowerTailEvent (k : ℕ) (hk : 1 < k)
    (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  BernoulliCSPPathChernoff.cumulativeLowerTailEvent
    (naeSATParameters k hk) s₀ N n r

/-- Random `k`-NAE-SAT cumulative-production process induced by one-sided
bad-clause emission. -/
def process (k : ℕ) (hk : 1 < k) (N : ℕ) (s₀ : ℝ) :=
  BernoulliCSPPathCollapse.process (naeSATParameters k hk) N s₀

/-- Interior KL/Chernoff count-tail bound for random `k`-NAE-SAT exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 1 < k) (N : ℕ) {n : ℕ}
    (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift k hk) :
    exactCountFailureBound k hk N n r ≤
      countChernoffFailureBound k hk n r := by
  exact
    BernoulliCSPPathChernoff.exactCountFailureBound_le_chernoffFailureBound_of_interior
      (naeSATParameters k hk) N hn hr (by simpa [naeSATDrift] using hlt)

/-- Interior KL/Chernoff lower-tail bound for the random `k`-NAE-SAT cumulative
production observable. -/
theorem cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 1 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift k hk) :
    pathMeasure k hk N (cumulativeLowerTailEvent k hk s₀ N n r) ≤
      countChernoffFailureBound k hk n r := by
  exact
    BernoulliCSPPathChernoff.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      (naeSATParameters k hk) N hn hr (by simpa [naeSATDrift] using hlt)

/-- Fixed-time threshold crossing for random `k`-NAE-SAT under the KL/Chernoff
failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 1 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift k hk)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (naeSATParameters k hk) s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      n θ
      (countChernoffFailureBound k hk n r) := by
  exact
    BernoulliCSPPathCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
      (naeSATParameters k hk) N hn hr (by simpa [naeSATDrift] using hlt) hmargin

/-- Fixed-time collapse for random `k`-NAE-SAT under the KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 1 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift k hk)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (naeSATParameters k hk) s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      n θ
      (countChernoffFailureBound k hk n r) := by
  exact
    BernoulliCSPPathCollapse.collapseWithChernoffBound_of_linearMargin
      (naeSATParameters k hk) N hn hr (by simpa [naeSATDrift] using hlt)
      hθ hmargin

/-- Terminal stopped-collapse for random `k`-NAE-SAT under the KL/Chernoff
failure profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 1 < k) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * naeSATDrift k hk)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (naeSATParameters k hk) s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      T θ
      (countChernoffFailureBound k hk T r) := by
  exact
    BernoulliCSPPathCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      (naeSATParameters k hk) N hT hr (by simpa [naeSATDrift] using hlt)
      hθ hmargin

/-- Earlier threshold crossing gives a high-probability hitting-time-before-
horizon bound for random `k`-NAE-SAT. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 1 < k) (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * naeSATDrift k hk)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (naeSATParameters k hk) s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      T θ
      (countChernoffFailureBound k hk j r) := by
  exact
    BernoulliCSPPathCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      (naeSATParameters k hk) N hjT hj hr (by simpa [naeSATDrift] using hlt)
      hmargin

/-- Named `k = 3` specialization of the random NAE-3-SAT cumulative lower-tail
KL/Chernoff bound. -/
theorem threeNAESAT_cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift 3 (by norm_num)) :
    pathMeasure 3 (by norm_num) N
        (cumulativeLowerTailEvent 3 (by norm_num) s₀ N n r) ≤
      countChernoffFailureBound 3 (by norm_num) n r :=
  cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    3 (by norm_num) N hn hr hlt

end

end Survival.NAESATChernoffCollapse
