import Survival.SATStateDependentCountThreshold
import Survival.SATStateDependentCountTailUpperBound

/-!
# SAT State-Dependent Count Support Bound

This module isolates the exact support envelope of the SAT non-flat count tail.

After `SATStateDependentCountThreshold`, the exact failure profile is the
measure of

* `unsatCountPrefix < countThreshold`.

Before proving a genuinely binomial / Chernoff interior tail inequality, one can
already close the two extreme regimes exactly:

* if the threshold is nonpositive, the lower-tail event is empty, so failure is
  exactly `0`;
* if the threshold lies strictly above the maximal possible count `n`, the
  lower-tail event is all of `univ`, so failure is exactly `1`.

These theorems separate the SAT tail into a trivial support envelope and a
remaining interior regime where the real binomial / Chernoff analysis lives.
-/

namespace Survival.SATStateDependentCountSupportBound

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountTailUpperBound

noncomputable section

/-- The unsatisfied-clause count on a prefix never exceeds the prefix length. -/
theorem unsatCountPrefix_le {N : ℕ} (τ : Trajectory N) :
    ∀ n, unsatCountPrefix τ n ≤ n
  | 0 => by
      simp [unsatCountPrefix]
  | n + 1 => by
      by_cases h : outcomeAt τ n = ClauseOutcome.unsat
      · simpa [unsatCountPrefix, h] using Nat.succ_le_succ (unsatCountPrefix_le τ n)
      · exact
          le_trans
            (by simpa [unsatCountPrefix, h] using unsatCountPrefix_le τ n)
            (Nat.le_succ _)

/-- If the induced count threshold is nonpositive, the SAT lower-tail count
event is empty. -/
  theorem countBelowThresholdEvent_eq_empty_of_threshold_nonpos
    (N : ℕ) (n : ℕ) (r : ℝ)
    (hthr : countThreshold n r ≤ 0) :
    countBelowThresholdEvent N n r = ∅ := by
  apply Set.eq_empty_iff_forall_notMem.2
  intro τ hτ
  simp [countBelowThresholdEvent] at hτ
  have hcount : 0 ≤ (unsatCountPrefix τ n : ℝ) := by positivity
  linarith

/-- If the induced count threshold lies strictly above the maximal possible
prefix count `n`, the SAT lower-tail count event is all of `univ`. -/
theorem countBelowThresholdEvent_eq_univ_of_activeCount_lt_threshold
    (N : ℕ) (n : ℕ) (r : ℝ)
    (hthr : (n : ℝ) < countThreshold n r) :
    countBelowThresholdEvent N n r = Set.univ := by
  apply Set.eq_univ_of_forall
  intro τ
  simp [countBelowThresholdEvent]
  have hcount : (unsatCountPrefix τ n : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast unsatCountPrefix_le τ n
  linarith

/-- If the deviation budget dominates the active linear center, the count
threshold is nonpositive. -/
theorem countThreshold_nonpos_of_activeDrift_le
    (n : ℕ) {r : ℝ}
    (hr : (n : ℝ) * random3ClauseDrift ≤ r) :
    countThreshold n r ≤ 0 := by
  have hpos : 0 < unsatEmissionScale := unsatEmissionScale_pos
  unfold countThreshold
  have hnum : (n : ℝ) * random3ClauseDrift - r ≤ 0 := by
    linarith
  have hnum' : (n : ℝ) * random3ClauseDrift - r ≤ 0 * unsatEmissionScale := by
    simpa using hnum
  exact (div_le_iff₀ hpos).2 hnum'

/-- If the deviation budget is below the support floor `-7 n log (8 / 7)`, the
count threshold lies strictly above the maximal possible prefix count `n`. -/
theorem activeCount_lt_countThreshold_of_supportFloor_lt
    (n : ℕ) {r : ℝ}
    (hr : r < -(7 : ℝ) * (n : ℝ) * random3ClauseDrift) :
    (n : ℝ) < countThreshold n r := by
  have hpos : 0 < unsatEmissionScale := unsatEmissionScale_pos
  unfold countThreshold
  rw [lt_div_iff₀ hpos]
  have hineq :
      (n : ℝ) * unsatEmissionScale < (n : ℝ) * random3ClauseDrift - r := by
    have hr' : r < -((7 : ℝ) * (n : ℝ) * random3ClauseDrift) := by
      simpa [mul_assoc, mul_left_comm, mul_comm] using hr
    have : (8 : ℝ) * ((n : ℝ) * random3ClauseDrift) <
        (n : ℝ) * random3ClauseDrift - r := by
      linarith
    simpa [unsatEmissionScale, mul_assoc, mul_left_comm, mul_comm] using this
  simpa [mul_assoc, mul_left_comm, mul_comm] using hineq

/-- Therefore the count-based exact failure profile vanishes identically once
the deviation budget reaches the active linear center. -/
theorem exactCountFailureBound_eq_zero_of_activeDrift_le
    (N : ℕ) (n : ℕ) (r : ℝ)
    (hr : (n : ℝ) * random3ClauseDrift ≤ r) :
    exactCountFailureBound N n r = 0 := by
  rw [exactCountFailureBound_eq_countBelowThresholdMeasure]
  rw [countBelowThresholdEvent_eq_empty_of_threshold_nonpos N n r
    (countThreshold_nonpos_of_activeDrift_le n hr)]
  simp

/-- The corresponding active-prefix exact SAT failure profile also vanishes. -/
theorem exactFailureBound_eq_zero_of_activeDrift_le
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ)
    (hr : (n : ℝ) * random3ClauseDrift ≤ r) :
    exactFailureBound N s₀ n r = 0 := by
  rw [exactFailureBound_eq_countBelowThresholdMeasure N s₀ hn r]
  rw [countBelowThresholdEvent_eq_empty_of_threshold_nonpos N n r
    (countThreshold_nonpos_of_activeDrift_le n hr)]
  simp

/-- Below the support floor `-7 n log (8 / 7)`, the count-based exact failure
profile is identically `1`. -/
theorem exactCountFailureBound_eq_one_of_supportFloor_lt
    (N : ℕ) (n : ℕ) (r : ℝ)
    (hr : r < -(7 : ℝ) * (n : ℝ) * random3ClauseDrift) :
    exactCountFailureBound N n r = 1 := by
  rw [exactCountFailureBound_eq_countBelowThresholdMeasure]
  rw [countBelowThresholdEvent_eq_univ_of_activeCount_lt_threshold N n r
    (activeCount_lt_countThreshold_of_supportFloor_lt n hr)]
  simp

/-- The corresponding active-prefix exact SAT failure profile is also `1` below
the support floor. -/
theorem exactFailureBound_eq_one_of_supportFloor_lt
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ)
    (hr : r < -(7 : ℝ) * (n : ℝ) * random3ClauseDrift) :
    exactFailureBound N s₀ n r = 1 := by
  rw [exactFailureBound_eq_countBelowThresholdMeasure N s₀ hn r]
  rw [countBelowThresholdEvent_eq_univ_of_activeCount_lt_threshold N n r
    (activeCount_lt_countThreshold_of_supportFloor_lt n hr)]
  simp

/-- A first explicit closed-form upper profile for the count-based SAT tail:
it is exactly `0` once the deviation budget reaches the active linear center,
and otherwise defaults to the trivial bound `1`. -/
def countSupportFailureBound : CountFailureProfile :=
  fun n r => if (n : ℝ) * random3ClauseDrift ≤ r then 0 else 1

/-- The support envelope is already enough to provide a closed-form upper bound
for the count-based exact SAT failure profile. -/
theorem hasCountFailureUpperBound_countSupport
    (N : ℕ) :
    HasCountFailureUpperBound N countSupportFailureBound := by
  intro n hn r
  by_cases hr : (n : ℝ) * random3ClauseDrift ≤ r
  · rw [exactCountFailureBound_eq_zero_of_activeDrift_le N n r hr]
    simp [countSupportFailureBound, hr]
  · have hle : exactCountFailureBound N n r ≤ 1 := by
      unfold exactCountFailureBound
      calc
        pathMeasure N ((exactCountLowerTailEvent N n r)ᶜ) ≤ pathMeasure N Set.univ := by
          exact measure_mono (by intro τ hτ; simp)
        _ = 1 := by simp
    simpa [countSupportFailureBound, hr] using hle

end

end Survival.SATStateDependentCountSupportBound
