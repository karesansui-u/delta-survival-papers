import Survival.BernoulliCSPPathCollapse

/-!
# Bernoulli Typical Sigma

Reader-facing wrappers for the Bernoulli-CSP total-production observable.

The existing Bernoulli path modules already prove the substantial facts:

* a one-sided cumulative production observable;
* its KL/Chernoff lower-tail bound;
* collapse and stopping-time wrappers derived from that lower tail.

This file gives those facts the `Σ`-oriented names used by the second-law-level
roadmap.  It is intentionally thin: it does not assert an unconditional
second-law theorem.  It says that, in the Bernoulli-CSP template, the cumulative
`Σ` observable has an interior Chernoff lower-tail certificate and monotone
expectation because its one-step emissions are nonnegative.
-/

namespace Survival.BernoulliTypicalSigma

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Reader-facing name for the Bernoulli-CSP cumulative total-production
observable `Σ_n`. -/
abbrev bernoulliSigma
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  cumulativeProduction P s₀ τ n

/-- Reader-facing name for the deterministic Bernoulli-CSP linear center. -/
abbrev bernoulliSigmaCenter (P : Parameters) (s₀ : ℝ) (n : ℕ) : ℝ :=
  linearCenter P s₀ n

/-- Reader-facing name for the lower-tail event
`Σ_n < center_n - r`. -/
abbrev bernoulliSigmaLowerTailEvent
    (P : Parameters) (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  cumulativeLowerTailEvent P s₀ N n r

/-- Reader-facing name for the Bernoulli-CSP stochastic `Σ` process. -/
abbrev bernoulliSigmaProcess
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    StochasticExpectedProcess (μ := pathMeasure P N) :=
  process P N s₀

/-- The Bernoulli-CSP `Σ` process increments by the one-sided bad-event
emission. -/
theorem bernoulliSigma_succ
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    bernoulliSigma P s₀ τ (n + 1) =
      bernoulliSigma P s₀ τ n + stepEmission P (outcomeAt τ n) := by
  exact cumulativeProduction_succ P s₀ τ n

/-- One-step Bernoulli-CSP `Σ` emissions are almost surely nonnegative. -/
theorem bernoulliSigma_ae_nonnegative_increment
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    AENonnegativeIncrement (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀) := by
  intro t
  exact Filter.Eventually.of_forall
    (fun τ => stepEmission_nonneg P (outcomeAt τ t))

/-- Therefore the expected Bernoulli-CSP `Σ` observable is monotone in the
finite-prefix horizon. -/
theorem bernoulliSigma_expectedCumulative_monotone
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    Monotone
      (bernoulliSigmaProcess P N s₀).toExpectedProcess.expectedCumulative := by
  exact
    expectedCumulative_monotone_of_ae_nonnegative_increment
      (bernoulliSigmaProcess P N s₀)
      (bernoulliSigma_ae_nonnegative_increment P N s₀)

/-- Interior KL/Chernoff lower-tail certificate for the Bernoulli-CSP `Σ`
observable.  This is the Phase-4 reader-facing name: it is a fixed finite-path
lower-tail bound, not an unconditional second law. -/
theorem bernoulliSigmaLowerTailMeasure_le_chernoffFailureBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    pathMeasure P N (bernoulliSigmaLowerTailEvent P s₀ N n r) ≤
      P.chernoffFailureBound n r := by
  exact
    cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      P N hn hr hlt

/-- Fixed-time threshold crossing for Bernoulli-CSP `Σ`, obtained by combining
the lower-tail certificate with a linear margin. -/
theorem bernoulliSigma_thresholdCrossingWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  exact
    thresholdCrossingWithChernoffBound_of_linearMargin
      P N hn hr hlt hmargin

/-- Fixed-time collapse wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_collapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  exact
    collapseWithChernoffBound_of_linearMargin
      P N hn hr hlt hθ hmargin

/-- Terminal stopped-collapse wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_stoppedCollapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      T θ
      (P.chernoffFailureBound T r) := by
  exact
    stoppedCollapseWithChernoffBound_of_linearMargin
      P N hT hr hlt hθ hmargin

/-- Hitting-time-before-horizon wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (k : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      T θ
      (P.chernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      P N hkT hk hr hlt hmargin

end

end Survival.BernoulliTypicalSigma
