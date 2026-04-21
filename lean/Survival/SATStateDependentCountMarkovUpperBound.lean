import Mathlib.MeasureTheory.Integral.Lebesgue.Markov
import Mathlib.Tactic.Ring
import Survival.SATStateDependentCountSupportClippedUpperBound

/-!
# SAT State-Dependent Count Markov Upper Bound

This module provides the first genuinely explicit interior upper bound on the
non-flat SAT count tail.

After the previous files, the exact active-prefix failure profile has been
reduced to

* a lower tail of the unsatisfied-clause count,
* together with an exact support envelope outside the interior regime.

Here we introduce the unsatisfied-clause shortfall

* `n - (# unsat up to n)`

and use Markov's inequality to upper-bound the interior count tail by a closed
form profile. This is weaker than the eventual binomial / Chernoff bound, but
it is already fully explicit and applies to the actual non-flat SAT
clause-exposure process.
-/

namespace Survival.SATStateDependentCountMarkovUpperBound

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountSupportBound
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountSupportClippedUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Real-valued indicator that the `t`-th exposed clause is unsatisfied. -/
def unsatIndicator {N : ℕ} (τ : Trajectory N) (t : ℕ) : ℝ :=
  if outcomeAt τ t = ClauseOutcome.unsat then 1 else 0

/-- Real-valued unsatisfied-clause shortfall on the first `n` exposed clauses. -/
def unsatShortfallPrefix {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  (n : ℝ) - (unsatCountPrefix τ n : ℝ)

theorem integrable_unsatIndicator
    (N : ℕ) (t : ℕ) :
    Integrable (fun τ : Trajectory N => unsatIndicator τ t) (pathMeasure N) := by
  refine Integrable.of_bound
    ((measurable_from_top :
      Measurable (fun τ : Trajectory N => unsatIndicator τ t)).aestronglyMeasurable)
    1 ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  unfold unsatIndicator
  split_ifs <;> simp

theorem integral_unsatIndicator_eq_one_eighth_of_le
    (N : ℕ) {t : ℕ} (ht : t ≤ N) :
    ∫ τ, unsatIndicator τ t ∂ pathMeasure N = (1 / 8 : ℝ) := by
  have hmean :=
    expectedOutcomeFunction_eq_stateAverage_of_le
      N
      (fun s => if s = ClauseOutcome.unsat then (1 : ℝ) else 0)
      ht
  simpa [unsatIndicator, stateAverage, finset_univ_clauseOutcome] using hmean

theorem integrable_unsatCountPrefix
    (N : ℕ) (n : ℕ) :
    Integrable (fun τ : Trajectory N => (unsatCountPrefix τ n : ℝ)) (pathMeasure N) := by
  refine Integrable.of_bound
    ((measurable_from_top :
      Measurable (fun τ : Trajectory N => (unsatCountPrefix τ n : ℝ))).aestronglyMeasurable)
    (n : ℝ) ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  have hnonneg : 0 ≤ (unsatCountPrefix τ n : ℝ) := by positivity
  have hle : (unsatCountPrefix τ n : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast unsatCountPrefix_le τ n
  simpa [Real.norm_eq_abs, abs_of_nonneg hnonneg] using hle

theorem integral_unsatCountPrefix_eq_one_eighth_mul_of_le
    (N : ℕ) :
    ∀ {n : ℕ}, n ≤ N + 1 →
      ∫ τ, (unsatCountPrefix τ n : ℝ) ∂ pathMeasure N = (n : ℝ) / 8
  | 0, _ => by
      simp [unsatCountPrefix]
  | n + 1, hn => by
      have hprefix : n ≤ N + 1 := Nat.le_trans (Nat.le_succ n) hn
      have hstep : n ≤ N := Nat.le_of_succ_le_succ hn
      calc
        ∫ τ, (unsatCountPrefix τ (n + 1) : ℝ) ∂ pathMeasure N
          = ∫ τ,
              ((unsatCountPrefix τ n : ℝ) +
                unsatIndicator τ n) ∂ pathMeasure N := by
              refine integral_congr_ae ?_
              refine Filter.Eventually.of_forall ?_
              intro τ
              unfold unsatIndicator
              by_cases hout : outcomeAt τ n = ClauseOutcome.unsat
              · simp [unsatCountPrefix, hout]
              · simp [unsatCountPrefix, hout]
        _ =
            (∫ τ, (unsatCountPrefix τ n : ℝ) ∂ pathMeasure N) +
              ∫ τ, unsatIndicator τ n ∂ pathMeasure N := by
                exact integral_add
                  (integrable_unsatCountPrefix N n)
                  (integrable_unsatIndicator N n)
        _ = (n : ℝ) / 8 + (1 / 8 : ℝ) := by
              rw [integral_unsatCountPrefix_eq_one_eighth_mul_of_le (N := N) hprefix,
                integral_unsatIndicator_eq_one_eighth_of_le N hstep]
        _ = ((n + 1 : ℕ) : ℝ) / 8 := by
              norm_num [Nat.cast_add]
              ring

theorem unsatShortfallPrefix_nonneg
    {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    0 ≤ unsatShortfallPrefix τ n := by
  unfold unsatShortfallPrefix
  have hle : (unsatCountPrefix τ n : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast unsatCountPrefix_le τ n
  linarith

theorem unsatShortfallPrefix_le
    {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    unsatShortfallPrefix τ n ≤ (n : ℝ) := by
  unfold unsatShortfallPrefix
  have hnonneg : 0 ≤ (unsatCountPrefix τ n : ℝ) := by positivity
  linarith

theorem integrable_unsatShortfallPrefix
    (N : ℕ) (n : ℕ) :
    Integrable (fun τ : Trajectory N => unsatShortfallPrefix τ n) (pathMeasure N) := by
  refine Integrable.of_bound
    ((measurable_from_top :
      Measurable (fun τ : Trajectory N => unsatShortfallPrefix τ n)).aestronglyMeasurable)
    (n : ℝ) ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  have hnonneg : 0 ≤ unsatShortfallPrefix τ n := unsatShortfallPrefix_nonneg τ n
  have hle : unsatShortfallPrefix τ n ≤ (n : ℝ) := unsatShortfallPrefix_le τ n
  simpa [Real.norm_eq_abs, abs_of_nonneg hnonneg] using hle

theorem integral_unsatShortfallPrefix_eq_seven_eighth_mul_of_le
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) :
    ∫ τ, unsatShortfallPrefix τ n ∂ pathMeasure N = (7 : ℝ) * (n : ℝ) / 8 := by
  unfold unsatShortfallPrefix
  rw [integral_sub (integrable_const (n : ℝ)) (integrable_unsatCountPrefix N n)]
  rw [expected_constant_eq (μ := pathMeasure N) (n : ℝ)]
  rw [integral_unsatCountPrefix_eq_one_eighth_mul_of_le N hn]
  ring

/-- Closed-form Markov upper profile for the active-prefix unsatisfied-count
tail. Outside the interior regime `countThreshold < n`, it defaults to the
trivial bound `1`. -/
def countMarkovFailureBound : CountFailureProfile :=
  fun n r =>
    if countThreshold n r < (n : ℝ) then
      ENNReal.ofReal (((7 : ℝ) * (n : ℝ) / 8) / ((n : ℝ) - countThreshold n r))
    else
      1

theorem exactCountFailureBound_le_countMarkovFailureBound
    (N : ℕ) :
    HasCountFailureUpperBound N countMarkovFailureBound := by
  intro n hn r
  by_cases hthr : countThreshold n r < (n : ℝ)
  · let ε : ℝ := (n : ℝ) - countThreshold n r
    have hε : 0 < ε := by
      dsimp [ε]
      linarith
    let s : Set (Trajectory N) := {τ | ε ≤ unsatShortfallPrefix τ n}
    have hsub :
        countBelowThresholdEvent N n r ⊆ s := by
      intro τ hτ
      simp [countBelowThresholdEvent, s, ε, unsatShortfallPrefix] at hτ ⊢
      linarith
    have hmono :
        pathMeasure N (countBelowThresholdEvent N n r) ≤ pathMeasure N s := by
      exact measure_mono hsub
    have hmonoReal :
        Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) ≤
          Measure.real (pathMeasure N) s := by
      exact
        (ENNReal.toReal_le_toReal
          (measure_ne_top (pathMeasure N) _)
          (measure_ne_top (pathMeasure N) _)).2 hmono
    have hmarkov :=
      MeasureTheory.mul_meas_ge_le_integral_of_nonneg
        (μ := pathMeasure N)
        (f := fun τ : Trajectory N => unsatShortfallPrefix τ n)
        (Filter.Eventually.of_forall (fun τ => unsatShortfallPrefix_nonneg τ n))
        (integrable_unsatShortfallPrefix N n)
        ε
    have hprod :
        Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) * ε ≤
          ∫ τ, unsatShortfallPrefix τ n ∂ pathMeasure N := by
      calc
        Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) * ε
          ≤ Measure.real (pathMeasure N) s * ε := by
              gcongr
        _ = ε * Measure.real (pathMeasure N) s := by ring
        _ ≤ ∫ τ, unsatShortfallPrefix τ n ∂ pathMeasure N := hmarkov
    have hreal :
        Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) ≤
          ((7 : ℝ) * (n : ℝ) / 8) / ε := by
      have hdiv :
          Measure.real (pathMeasure N) (countBelowThresholdEvent N n r) ≤
            (∫ τ, unsatShortfallPrefix τ n ∂ pathMeasure N) / ε := by
        exact (le_div_iff₀ hε).2 (by simpa [mul_comm] using hprod)
      rw [integral_unsatShortfallPrefix_eq_seven_eighth_mul_of_le N hn] at hdiv
      simpa [ε]
        using hdiv
    have hprofile :
        countMarkovFailureBound n r =
          ENNReal.ofReal (((7 : ℝ) * (n : ℝ) / 8) / ((n : ℝ) - countThreshold n r)) := by
      simp [countMarkovFailureBound, hthr]
    rw [hprofile]
    rw [exactCountFailureBound_eq_countBelowThresholdMeasure]
    rw [← ENNReal.ofReal_toReal (measure_ne_top (pathMeasure N) _)]
    exact ENNReal.ofReal_le_ofReal hreal
  · have hle : exactCountFailureBound N n r ≤ 1 := by
      unfold exactCountFailureBound
      calc
        pathMeasure N ((exactCountLowerTailEvent N n r)ᶜ) ≤ pathMeasure N Set.univ := by
          exact measure_mono (by intro τ hτ; simp)
        _ = 1 := by simp
    simpa [countMarkovFailureBound, hthr] using hle

/-- Support-clipped Markov upper profile for the actual non-flat SAT tail. -/
def satSupportClippedCountMarkovFailureBound : CountFailureProfile :=
  supportClippedFailureBound countMarkovFailureBound

theorem hasCountFailureUpperBound_satSupportClippedCountMarkov
    (N : ℕ) :
    HasCountFailureUpperBound N satSupportClippedCountMarkovFailureBound :=
  hasCountFailureUpperBound_supportClipped
    (B := countMarkovFailureBound)
    (exactCountFailureBound_le_countMarkovFailureBound N)

theorem exactFailureBound_le_satSupportClippedCountMarkovFailureBound
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ} :
    exactFailureBound N s₀ n r ≤ satSupportClippedCountMarkovFailureBound n r :=
  exactFailureBound_le_of_hasCountFailureUpperBound
    hn
    (hB := hasCountFailureUpperBound_satSupportClippedCountMarkov N)

theorem thresholdCrossingWithFailureBound_of_activeLinearMargin
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedCountMarkovFailureBound n r) := by
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedCountMarkovFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedCountMarkov N)
      hmargin

theorem stoppedCollapseWithFailureBound_of_activeLinearMargin
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedCountMarkovFailureBound T r) := by
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (B := satSupportClippedCountMarkovFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedCountMarkov N)
      hθ hmargin

theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedCountMarkovFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (B := satSupportClippedCountMarkovFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedCountMarkov N)
      hmargin

end

end Survival.SATStateDependentCountMarkovUpperBound
