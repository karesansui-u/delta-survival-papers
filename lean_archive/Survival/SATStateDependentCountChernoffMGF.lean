import Mathlib.Probability.Moments.Basic
import Survival.SATStateDependentCountSupportClippedUpperBound

/-!
# SAT State-Dependent Count Chernoff MGF Bound

This module inserts the standard moment-generating-function Chernoff step into
the SAT count-tail stack.

The previous files reduced the actual non-flat SAT lower tail to the event

* `unsatCountPrefix < countThreshold`.

Here we prove, directly from mathlib's generic Chernoff inequality, that this
exact count tail is bounded by an MGF profile.  We also package a closed
Bernoulli-sum MGF candidate.  The remaining SAT-specific analytic task is then
localized to one statement: the MGF of the exposed unsatisfied-count process is
bounded by the Bernoulli-sum MGF.
-/

namespace Survival.SATStateDependentCountChernoffMGF

open MeasureTheory
open ProbabilityTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountSupportClippedUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Real-valued unsatisfied-clause count on the first `n` exposed clauses. -/
def unsatCountRV (N n : ℕ) : Trajectory N → ℝ :=
  fun τ => (unsatCountPrefix τ n : ℝ)

theorem aemeasurable_unsatCountRV
    (N n : ℕ) :
    AEMeasurable (unsatCountRV N n) (pathMeasure N) :=
  (measurable_from_top : Measurable (unsatCountRV N n)).aemeasurable

theorem unsatCountRV_mem_Icc
    (N n : ℕ) :
    ∀ᵐ τ ∂pathMeasure N, unsatCountRV N n τ ∈ Set.Icc 0 (n : ℝ) := by
  refine Filter.Eventually.of_forall ?_
  intro τ
  constructor
  · dsimp [unsatCountRV]
    positivity
  · dsimp [unsatCountRV]
    exact_mod_cast
      Survival.SATStateDependentCountSupportBound.unsatCountPrefix_le τ n

/-- The exponential moment of the unsatisfied-count prefix is finite. -/
theorem integrable_exp_mul_unsatCountRV
    (N n : ℕ) (t : ℝ) :
    Integrable
      (fun τ : Trajectory N => Real.exp (t * unsatCountRV N n τ))
      (pathMeasure N) := by
  exact
    ProbabilityTheory.integrable_exp_mul_of_mem_Icc
      (a := 0)
      (b := (n : ℝ))
      (t := t)
      (aemeasurable_unsatCountRV N n)
      (unsatCountRV_mem_Icc N n)

theorem countBelowThresholdEvent_subset_unsatCountRV_le
    (N n : ℕ) (r : ℝ) :
    countBelowThresholdEvent N n r ⊆
      {τ : Trajectory N | unsatCountRV N n τ ≤ countThreshold n r} := by
  intro τ hτ
  change (unsatCountPrefix τ n : ℝ) < countThreshold n r at hτ
  change (unsatCountPrefix τ n : ℝ) ≤ countThreshold n r
  exact le_of_lt hτ

/-- Generic Chernoff/MGF upper bound for the active-prefix SAT count tail. -/
theorem exactCountFailureBound_le_mgfChernoff
    (N : ℕ) {n : ℕ} (_hn : n ≤ N + 1) (r : ℝ) {t : ℝ} (ht : t ≤ 0) :
    exactCountFailureBound N n r ≤
      ENNReal.ofReal
        (Real.exp (-t * countThreshold n r) *
          ProbabilityTheory.mgf (unsatCountRV N n) (pathMeasure N) t) := by
  rw [exactCountFailureBound_eq_countBelowThresholdMeasure]
  let s : Set (Trajectory N) :=
    {τ | unsatCountRV N n τ ≤ countThreshold n r}
  have hsub : countBelowThresholdEvent N n r ⊆ s :=
    countBelowThresholdEvent_subset_unsatCountRV_le N n r
  have hmono :
      pathMeasure N (countBelowThresholdEvent N n r) ≤ pathMeasure N s :=
    measure_mono hsub
  have hmonoReal :
      Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) ≤
        Measure.real (pathMeasure N) s := by
    exact
      (ENNReal.toReal_le_toReal
        (measure_ne_top (pathMeasure N) _)
        (measure_ne_top (pathMeasure N) _)).2 hmono
  have hchernoff :
      Measure.real (pathMeasure N) s ≤
        Real.exp (-t * countThreshold n r) *
          ProbabilityTheory.mgf (unsatCountRV N n) (pathMeasure N) t := by
    simpa [s] using
      ProbabilityTheory.measure_le_le_exp_mul_mgf
        (μ := pathMeasure N)
        (X := unsatCountRV N n)
        (ε := countThreshold n r)
        (t := t)
        ht
        (integrable_exp_mul_unsatCountRV N n t)
  have hreal :
      Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) ≤
        Real.exp (-t * countThreshold n r) *
          ProbabilityTheory.mgf (unsatCountRV N n) (pathMeasure N) t :=
    hmonoReal.trans hchernoff
  rw [← ENNReal.ofReal_toReal (measure_ne_top (pathMeasure N) _)]
  exact ENNReal.ofReal_le_ofReal hreal

/-- MGF-based Chernoff profile, with the actual count MGF left visible. -/
def countMGFChernoffFailureBound
    (N : ℕ) (t : ℝ) : CountFailureProfile :=
  fun n r =>
    ENNReal.ofReal
      (Real.exp (-t * countThreshold n r) *
        ProbabilityTheory.mgf (unsatCountRV N n) (pathMeasure N) t)

theorem hasCountFailureUpperBound_countMGFChernoff
    (N : ℕ) {t : ℝ} (ht : t ≤ 0) :
    HasCountFailureUpperBound N (countMGFChernoffFailureBound N t) := by
  intro n hn r
  exact exactCountFailureBound_le_mgfChernoff N hn r ht

/-- One-step Bernoulli MGF for the unsatisfied-clause indicator. -/
def bernoulliUnsatMGF (t : ℝ) : ℝ :=
  (7 / 8 : ℝ) + (1 / 8 : ℝ) * Real.exp t

/-- Closed Bernoulli-sum MGF profile for the active-prefix count tail. -/
def countClosedMGFChernoffFailureBound
    (t : ℝ) : CountFailureProfile :=
  fun n r =>
    ENNReal.ofReal
      (Real.exp (-t * countThreshold n r) * bernoulliUnsatMGF t ^ n)

/-- The remaining SAT-specific MGF input: the count MGF is bounded by the
Bernoulli-sum MGF on the active prefix. -/
def HasBernoulliMGFUpperBound
    (N : ℕ) (t : ℝ) : Prop :=
  ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
    ProbabilityTheory.mgf (unsatCountRV N n) (pathMeasure N) t ≤
      bernoulliUnsatMGF t ^ n

theorem hasCountFailureUpperBound_closedMGFChernoff_of_mgf
    (N : ℕ) {t : ℝ}
    (ht : t ≤ 0)
    (hmgf : HasBernoulliMGFUpperBound N t) :
    HasCountFailureUpperBound N (countClosedMGFChernoffFailureBound t) := by
  intro n hn r
  calc
    exactCountFailureBound N n r
        ≤ countMGFChernoffFailureBound N t n r := by
          exact exactCountFailureBound_le_mgfChernoff N hn r ht
    _ ≤ countClosedMGFChernoffFailureBound t n r := by
          apply ENNReal.ofReal_le_ofReal
          apply mul_le_mul_of_nonneg_left
          · exact hmgf hn
          · exact (Real.exp_pos _).le

/-- Support-clipped closed MGF Chernoff profile. -/
def satSupportClippedClosedMGFChernoffFailureBound
    (t : ℝ) : CountFailureProfile :=
  supportClippedFailureBound (countClosedMGFChernoffFailureBound t)

theorem hasCountFailureUpperBound_supportClippedClosedMGFChernoff
    (N : ℕ) {t : ℝ}
    (ht : t ≤ 0)
    (hmgf : HasBernoulliMGFUpperBound N t) :
    HasCountFailureUpperBound N
      (satSupportClippedClosedMGFChernoffFailureBound t) :=
  hasCountFailureUpperBound_supportClipped
    (B := countClosedMGFChernoffFailureBound t)
    (hasCountFailureUpperBound_closedMGFChernoff_of_mgf N ht hmgf)

/-- Active-prefix threshold crossing under the support-clipped closed MGF
Chernoff profile. -/
theorem thresholdCrossingWithClosedMGFChernoffBound_of_activeLinearMargin
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hmgf : HasBernoulliMGFUpperBound N t)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedClosedMGFChernoffFailureBound t n r) := by
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedClosedMGFChernoffFailureBound t)
      (hB := hasCountFailureUpperBound_supportClippedClosedMGFChernoff N ht hmgf)
      hmargin

/-- Active-prefix stopped-collapse bound under the support-clipped closed MGF
Chernoff profile. -/
theorem stoppedCollapseWithClosedMGFChernoffBound_of_activeLinearMargin
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hmgf : HasBernoulliMGFUpperBound N t)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedClosedMGFChernoffFailureBound t T r) := by
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (B := satSupportClippedClosedMGFChernoffFailureBound t)
      (hB := hasCountFailureUpperBound_supportClippedClosedMGFChernoff N ht hmgf)
      hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound under the support-clipped
closed MGF Chernoff profile. -/
theorem hittingTimeBeforeHorizonWithClosedMGFChernoffBound_of_activeLinearMargin
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r t : ℝ}
    (ht : t ≤ 0)
    (hmgf : HasBernoulliMGFUpperBound N t)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedClosedMGFChernoffFailureBound t k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (B := satSupportClippedClosedMGFChernoffFailureBound t)
      (hB := hasCountFailureUpperBound_supportClippedClosedMGFChernoff N ht hmgf)
      hmargin

end

end Survival.SATStateDependentCountChernoffMGF
