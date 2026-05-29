import Survival.SATStateDependentCountReduction

/-!
# SAT State-Dependent Count Threshold

This module normalizes the count-reduced SAT lower-tail event by dividing out
the positive emission scale `8 * log (8 / 7)`.

After `SATStateDependentCountReduction`, the exact active-prefix lower tail is
already known to depend only on the unsatisfied-clause count. Here we sharpen
that statement into the canonical threshold form

* `countThreshold ≤ unsatCountPrefix`

and equivalently its failure event

* `unsatCountPrefix < countThreshold`.

This is the exact shape needed for subsequent binomial / Chernoff tail bounds.
-/

namespace Survival.SATStateDependentCountThreshold

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentExactConcentration

noncomputable section

/-- The positive scale carried by one unsatisfied clause in the concrete
non-flat SAT emission. -/
def unsatEmissionScale : ℝ :=
  8 * random3ClauseDrift

theorem unsatEmissionScale_pos :
    0 < unsatEmissionScale := by
  unfold unsatEmissionScale
  exact mul_pos (by norm_num) random3ClauseDrift_pos

/-- Real threshold on the unsatisfied-clause count corresponding to the
lower-tail margin parameter `r`. -/
def countThreshold
    (n : ℕ) (r : ℝ) : ℝ :=
  ((n : ℝ) * random3ClauseDrift - r) / unsatEmissionScale

/-- Canonical threshold event: the unsatisfied-clause count on the prefix is at
least the induced real threshold. -/
def countThresholdEvent
    (N : ℕ) (n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  {τ | countThreshold n r ≤ (unsatCountPrefix τ n : ℝ)}

/-- Canonical lower-tail failure event: the prefix unsatisfied-clause count
falls below the induced real threshold. -/
def countBelowThresholdEvent
    (N : ℕ) (n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  {τ | (unsatCountPrefix τ n : ℝ) < countThreshold n r}

theorem exactCountLowerTailEvent_eq_countThresholdEvent
    (N : ℕ) (n : ℕ) (r : ℝ) :
    exactCountLowerTailEvent N n r = countThresholdEvent N n r := by
  ext τ
  constructor <;> intro hτ
  · change
      (n : ℝ) * random3ClauseDrift - r ≤
        (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift) at hτ
    have hpos : 0 < unsatEmissionScale := unsatEmissionScale_pos
    unfold countThresholdEvent countThreshold unsatEmissionScale
    have hτ' :
        (n : ℝ) * random3ClauseDrift - r ≤
          (unsatCountPrefix τ n : ℝ) * unsatEmissionScale := by
      simpa [unsatEmissionScale, mul_comm, mul_left_comm, mul_assoc] using hτ
    exact (div_le_iff₀ hpos).2 hτ'
  · change
      (n : ℝ) * random3ClauseDrift - r ≤
        (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift)
    have hpos : 0 < unsatEmissionScale := unsatEmissionScale_pos
    unfold countThresholdEvent countThreshold unsatEmissionScale at hτ
    have hτ' :
        (n : ℝ) * random3ClauseDrift - r ≤
          (unsatCountPrefix τ n : ℝ) * unsatEmissionScale := by
      exact (div_le_iff₀ hpos).1 hτ
    simpa [unsatEmissionScale, mul_comm, mul_left_comm, mul_assoc] using hτ'

theorem compl_countThresholdEvent_eq_countBelowThresholdEvent
    (N : ℕ) (n : ℕ) (r : ℝ) :
    (countThresholdEvent N n r)ᶜ = countBelowThresholdEvent N n r := by
  ext τ
  simp [countThresholdEvent, countBelowThresholdEvent]

/-- Therefore the count-based failure profile is the measure of the canonical
lower-tail threshold event. -/
theorem exactCountFailureBound_eq_countBelowThresholdMeasure
    (N : ℕ) (n : ℕ) (r : ℝ) :
    exactCountFailureBound N n r =
      pathMeasure N (countBelowThresholdEvent N n r) := by
  unfold exactCountFailureBound
  rw [exactCountLowerTailEvent_eq_countThresholdEvent]
  rw [compl_countThresholdEvent_eq_countBelowThresholdEvent]

/-- Active-prefix exact SAT failure profile can therefore be read as a lower
tail of the unsatisfied-clause count against the canonical threshold. -/
theorem exactFailureBound_eq_countBelowThresholdMeasure
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ) :
    exactFailureBound N s₀ n r =
      pathMeasure N (countBelowThresholdEvent N n r) := by
  rw [exactFailureBound_eq_exactCountFailureBound N s₀ hn r]
  exact exactCountFailureBound_eq_countBelowThresholdMeasure N n r

end

end Survival.SATStateDependentCountThreshold
