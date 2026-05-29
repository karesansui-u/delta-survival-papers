import Survival.BernoulliCSPPathCollapse
import Survival.KSATClauseExposureProcess

/-!
# k-SAT Chernoff Collapse Bound

This module packages the generic Bernoulli-CSP path Chernoff theorem as a
domain-facing random `k`-SAT statement.

At this layer, a random `k`-SAT clause exposure is a one-sided Bernoulli CSP
with bad-clause probability `(1 / 2)^k`.  The generic cumulative-production
observable assigns the one-sided emission scale to falsified clauses and zero to
all other clauses.  The result is a high-probability lower-tail / collapse-style
bound with the KL/Chernoff profile inherited from `BernoulliCSPTemplate`.
-/

namespace Survival.KSATChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.KSATBernoulliTemplate
open Survival.KSATClauseExposureProcess
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Random `k`-SAT Chernoff/KL count failure profile. -/
def countChernoffFailureBound (k : ℕ) (hk : 0 < k) :
    CountFailureProfile :=
  (kSATParameters k hk).chernoffFailureBound

/-- Random `k`-SAT exact bad-count lower-tail failure profile. -/
def exactCountFailureBound (k : ℕ) (hk : 0 < k)
    (N n : ℕ) (r : ℝ) : ENNReal :=
  BernoulliCSPPathChernoff.exactCountFailureBound
    (kSATParameters k hk) N n r

/-- Random `k`-SAT cumulative production observable induced by one-sided bad
clause emission. -/
def cumulativeProduction (k : ℕ) (hk : 0 < k) (s₀ : ℝ)
    {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  BernoulliCSPPathChernoff.cumulativeProduction
    (kSATParameters k hk) s₀ τ n

/-- Random `k`-SAT lower-tail event for the cumulative production observable. -/
def cumulativeLowerTailEvent (k : ℕ) (hk : 0 < k)
    (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  BernoulliCSPPathChernoff.cumulativeLowerTailEvent
    (kSATParameters k hk) s₀ N n r

/-- Random `k`-SAT cumulative-production process induced by one-sided bad
clause emission. -/
def process (k : ℕ) (hk : 0 < k) (N : ℕ) (s₀ : ℝ) :=
  BernoulliCSPPathCollapse.process (kSATParameters k hk) N s₀

/-- Interior KL/Chernoff count-tail bound for random `k`-SAT clause exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 0 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift k hk) :
    exactCountFailureBound k hk N n r ≤
      countChernoffFailureBound k hk n r := by
  exact
    BernoulliCSPPathChernoff.exactCountFailureBound_le_chernoffFailureBound_of_interior
      (kSATParameters k hk) N hn hr (by simpa [kSATDrift] using hlt)

/-- Interior KL/Chernoff lower-tail bound for the random `k`-SAT cumulative
production observable. -/
theorem cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 0 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift k hk) :
    pathMeasure k hk N (cumulativeLowerTailEvent k hk s₀ N n r) ≤
      countChernoffFailureBound k hk n r := by
  exact
    BernoulliCSPPathChernoff.cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      (kSATParameters k hk) N hn hr (by simpa [kSATDrift] using hlt)

/-- The random `k`-SAT lower-tail event can be read as a bad-count threshold
event. -/
theorem cumulativeLowerTailEvent_eq_countBelowThresholdEvent
    (k : ℕ) (hk : 0 < k) (s₀ : ℝ) (N n : ℕ) (r : ℝ) :
    cumulativeLowerTailEvent k hk s₀ N n r =
      BernoulliCSPPathChernoff.countBelowThresholdEvent
        (kSATParameters k hk) N n r := by
  exact
    BernoulliCSPPathChernoff.cumulativeLowerTailEvent_eq_countBelowThresholdEvent
      (kSATParameters k hk) s₀ N n r

/-- Fixed-time threshold crossing for random `k`-SAT under the KL/Chernoff
failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 0 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift k hk)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (kSATParameters k hk) s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      n θ
      (countChernoffFailureBound k hk n r) := by
  exact
    BernoulliCSPPathCollapse.thresholdCrossingWithChernoffBound_of_linearMargin
      (kSATParameters k hk) N hn hr (by simpa [kSATDrift] using hlt) hmargin

/-- Fixed-time collapse for random `k`-SAT under the KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 0 < k) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift k hk)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (kSATParameters k hk) s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      n θ
      (countChernoffFailureBound k hk n r) := by
  exact
    BernoulliCSPPathCollapse.collapseWithChernoffBound_of_linearMargin
      (kSATParameters k hk) N hn hr (by simpa [kSATDrift] using hlt)
      hθ hmargin

/-- Terminal stopped-collapse for random `k`-SAT under the KL/Chernoff failure
profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 0 < k) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * kSATDrift k hk)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (kSATParameters k hk) s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      T θ
      (countChernoffFailureBound k hk T r) := by
  exact
    BernoulliCSPPathCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      (kSATParameters k hk) N hT hr (by simpa [kSATDrift] using hlt)
      hθ hmargin

/-- Earlier threshold crossing gives a high-probability hitting-time-before-
horizon bound for random `k`-SAT. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (k : ℕ) (hk : 0 < k) (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * kSATDrift k hk)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter (kSATParameters k hk) s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure k hk N)
      (process k hk N s₀)
      T θ
      (countChernoffFailureBound k hk j r) := by
  exact
    BernoulliCSPPathCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      (kSATParameters k hk) N hjT hj hr (by simpa [kSATDrift] using hlt)
      hmargin

/-- Named `k = 3` specialization of the random `k`-SAT cumulative lower-tail
KL/Chernoff bound. -/
theorem threeSAT_cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift 3 (by norm_num)) :
    pathMeasure 3 (by norm_num) N
        (cumulativeLowerTailEvent 3 (by norm_num) s₀ N n r) ≤
      countChernoffFailureBound 3 (by norm_num) n r :=
  cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
    3 (by norm_num) N hn hr hlt

end

end Survival.KSATChernoffCollapse
