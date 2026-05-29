import Survival.BernoulliCSPPathChernoff
import Survival.StoppingTimeCollapseEvent

/-!
# Bernoulli CSP Path Collapse

This module turns the generic Bernoulli-CSP path Chernoff lower-tail bound into
the existing operational collapse / stopping-time API.

The stochastic process used here is the natural one-sided cumulative production:
`bad` outcomes emit `badEmissionScale`, while `good` outcomes emit zero.  The
previous module proves that this process' lower tail is bounded by the
KL/Chernoff profile.  Here we take the complement of that lower-tail event as
the good event and obtain threshold crossing, collapse, stopped collapse, and
hitting-time-before-horizon bounds.
-/

namespace Survival.BernoulliCSPPathCollapse

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- One-step one-sided Bernoulli-CSP emission: bad outcomes carry the emission
scale, good outcomes carry zero. -/
def stepEmission (P : Parameters) (s : Outcome) : ℝ :=
  if s = Outcome.bad then P.badEmissionScale else 0

theorem stepEmission_nonneg (P : Parameters) (s : Outcome) :
    0 ≤ stepEmission P s := by
  unfold stepEmission
  split_ifs
  · exact P.badEmissionScale_pos.le
  · simp

theorem stepEmission_bound (P : Parameters) (s : Outcome) :
    |stepEmission P s| ≤ P.badEmissionScale := by
  have hnonneg := stepEmission_nonneg P s
  rw [abs_of_nonneg hnonneg]
  unfold stepEmission
  split_ifs
  · rfl
  · exact P.badEmissionScale_pos.le

theorem badCountPrefix_succ
    {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    badCountPrefix τ (n + 1) =
      badCountPrefix τ n + if outcomeAt τ n = Outcome.bad then 1 else 0 := rfl

theorem cumulativeProduction_succ
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    cumulativeProduction P s₀ τ (n + 1) =
      cumulativeProduction P s₀ τ n + stepEmission P (outcomeAt τ n) := by
  unfold cumulativeProduction
  rw [badCountPrefix_succ]
  unfold stepEmission
  by_cases hbad : outcomeAt τ n = Outcome.bad
  · simp [hbad, Nat.cast_add]
    ring_nf
  · simp [hbad]

theorem integrable_stepEmission
    (P : Parameters) (N t : ℕ) :
    Integrable
      (fun τ : Trajectory N => stepEmission P (outcomeAt τ t))
      (pathMeasure P N) := by
  refine Integrable.of_bound
    ((measurable_from_top :
      Measurable (fun τ : Trajectory N => stepEmission P (outcomeAt τ t))).aestronglyMeasurable)
    P.badEmissionScale ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  simpa [Real.norm_eq_abs] using stepEmission_bound P (outcomeAt τ t)

theorem integrable_cumulativeProduction
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ) :
    Integrable
      (fun τ : Trajectory N => cumulativeProduction P s₀ τ n)
      (pathMeasure P N) := by
  refine Integrable.of_bound
    ((measurable_from_top :
      Measurable (fun τ : Trajectory N => cumulativeProduction P s₀ τ n)).aestronglyMeasurable)
    (|s₀| + (n : ℝ) * P.badEmissionScale) ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  have hcount : (badCountPrefix τ n : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast BernoulliCSPPathChernoff.badCountPrefix_le τ n
  have hmul :
      |(badCountPrefix τ n : ℝ) * P.badEmissionScale| ≤
        (n : ℝ) * P.badEmissionScale := by
    rw [abs_of_nonneg (mul_nonneg (by positivity) P.badEmissionScale_pos.le)]
    exact mul_le_mul_of_nonneg_right hcount P.badEmissionScale_pos.le
  calc
    ‖cumulativeProduction P s₀ τ n‖
        = |s₀ + (badCountPrefix τ n : ℝ) * P.badEmissionScale| := by
            simp [Real.norm_eq_abs, cumulativeProduction]
    _ ≤ |s₀| + |(badCountPrefix τ n : ℝ) * P.badEmissionScale| :=
            abs_add_le _ _
    _ ≤ |s₀| + (n : ℝ) * P.badEmissionScale := by
            exact add_le_add le_rfl hmul

/-- The generic Bernoulli-CSP cumulative-production process on the actual path
measure. -/
def process (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    StochasticExpectedProcess (μ := pathMeasure P N) where
  cumulativeRV n := fun τ => cumulativeProduction P s₀ τ n
  incrementRV t := fun τ => stepEmission P (outcomeAt τ t)
  integrable_cumulative := integrable_cumulativeProduction P N s₀
  integrable_increment := integrable_stepEmission P N
  cumulative_succ_ae := by
    intro t
    exact Filter.Eventually.of_forall
      (fun τ => cumulativeProduction_succ P s₀ τ t)

/-- Fixed-time threshold crossing under the generic Bernoulli-CSP KL/Chernoff
failure profile. -/
theorem thresholdCrossingWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ linearCenter P s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  let badEvent := cumulativeLowerTailEvent P s₀ N n r
  let goodEvent : Set (Trajectory N) := badEventᶜ
  refine ⟨goodEvent, ?_, ?_⟩
  · constructor
    · change MeasurableSet (cumulativeLowerTailEvent P s₀ N n r)ᶜ
      trivial
    · simpa [goodEvent, badEvent] using
        cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
          P N hn hr hlt
  · intro τ hτ
    dsimp [goodEvent, badEvent, cumulativeLowerTailEvent] at hτ
    have hlower :
        linearCenter P s₀ n - r ≤ cumulativeProduction P s₀ τ n :=
      not_lt.mp hτ
    change -Real.log θ ≤ cumulativeProduction P s₀ τ n
    exact le_trans hmargin hlower

/-- Fixed-time collapse under the generic Bernoulli-CSP KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ linearCenter P s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  exact
    collapseWithFailureBound_of_thresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      n hθ
      (thresholdCrossingWithChernoffBound_of_linearMargin
        P N hn hr hlt hmargin)

/-- Terminal stopped-collapse under the generic Bernoulli-CSP KL/Chernoff
failure profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ linearCenter P s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      T θ
      (P.chernoffFailureBound T r) := by
  exact
    stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      hθ
      (thresholdCrossingWithChernoffBound_of_linearMargin
        P N hT hr hlt hmargin)

/-- Earlier threshold crossing yields a high-probability bound for
`collapseHittingTime < T`. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (k : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ linearCenter P s₀ k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      T θ
      (P.chernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (process P N s₀)
      hkT
      (thresholdCrossingWithChernoffBound_of_linearMargin
        P N hk hr hlt hmargin)

end

end Survival.BernoulliCSPPathCollapse
