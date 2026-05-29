import Mathlib.Data.Real.Sqrt
import Mathlib.Tactic.Linarith
import Survival.FiniteCSPFirstMomentCollapseBound

/-!
# Finite CSP Second-Moment Survival Bound

This module is the survival-side counterpart to
`Survival.FiniteCSPFirstMomentCollapseBound`.

It does not prove a sharp threshold and it does not analyze a particular SAT
ensemble.  It proves the finite PMF second-moment anchor:

* for a natural-valued feasible-count random variable `Z`,
  `E[Z]^2 <= E[Z^2] * Pr[Z > 0]`;
* hence, when `E[Z^2] > 0`,
  `E[Z]^2 / E[Z^2] <= Pr[Z > 0]`;
* if the second-moment ratio `E[Z^2] / E[Z]^2` is at most `C`, then
  `Pr[Z > 0] >= 1 / C`.

Thus first moment controls the collapse side, while a controlled
second-moment ratio controls the survival side.  The ratio condition is an
extra structural/concentration input; it is not implied by the loss coordinate
alone.
-/

open scoped BigOperators

namespace Survival.FiniteCSPSecondMomentSurvivalBound

open Survival.FiniteCSPFirstMomentCollapseBound

noncomputable section

variable {Ω : Type*} [Fintype Ω]

/-- Finite PMF second moment of a natural-valued feasible-count random
variable. -/
def countSecondMoment (P : PMF Ω) (Z : Ω → ℕ) : ℝ :=
  ∑ ω, (P ω).toReal * (Z ω : ℝ) ^ 2

/-- Second-moment ratio `E[Z^2] / E[Z]^2`.  This is the extra concentration
quantity needed for a survival-side lower bound. -/
def secondMomentRatio (P : PMF Ω) (Z : Ω → ℕ) : ℝ :=
  countSecondMoment P Z / (countExpectation P Z) ^ 2

private lemma countExpectation_eq_sqrt_weighted_indicator_sum
    (P : PMF Ω) (Z : Ω → ℕ) :
    countExpectation P Z =
      ∑ ω, (Real.sqrt (P ω).toReal * (Z ω : ℝ)) *
        (Real.sqrt (P ω).toReal *
          (if nonemptyEvent Z ω then (1 : ℝ) else 0)) := by
  classical
  unfold countExpectation nonemptyEvent
  symm
  refine Finset.sum_congr rfl ?_
  intro ω _
  by_cases h : 0 < Z ω
  · have hp : 0 ≤ (P ω).toReal := ENNReal.toReal_nonneg
    have hsqrt : Real.sqrt (P ω).toReal * Real.sqrt (P ω).toReal =
        (P ω).toReal := by
      rw [← sq, Real.sq_sqrt hp]
    calc
      (Real.sqrt (P ω).toReal * (Z ω : ℝ)) *
          (Real.sqrt (P ω).toReal * (if 0 < Z ω then (1 : ℝ) else 0))
          = (Real.sqrt (P ω).toReal * (Z ω : ℝ)) *
              (Real.sqrt (P ω).toReal * 1) := by simp [h]
      _ = (Real.sqrt (P ω).toReal * Real.sqrt (P ω).toReal) *
              (Z ω : ℝ) := by ring
      _ = (P ω).toReal * (Z ω : ℝ) := by rw [hsqrt]
  · have hz : Z ω = 0 := Nat.eq_zero_of_not_pos h
    simp [hz]

private lemma sqrt_weighted_count_sq_sum_eq_secondMoment
    (P : PMF Ω) (Z : Ω → ℕ) :
    (∑ ω, (Real.sqrt (P ω).toReal * (Z ω : ℝ)) ^ 2) =
      countSecondMoment P Z := by
  classical
  unfold countSecondMoment
  refine Finset.sum_congr rfl ?_
  intro ω _
  have hp : 0 ≤ (P ω).toReal := ENNReal.toReal_nonneg
  calc
    (Real.sqrt (P ω).toReal * (Z ω : ℝ)) ^ 2
        = (Real.sqrt (P ω).toReal) ^ 2 * (Z ω : ℝ) ^ 2 := by ring
    _ = (P ω).toReal * (Z ω : ℝ) ^ 2 := by rw [Real.sq_sqrt hp]

private lemma sqrt_weighted_indicator_sq_sum_eq_nonemptyProb
    (P : PMF Ω) (Z : Ω → ℕ) :
    (∑ ω, (Real.sqrt (P ω).toReal *
        (if nonemptyEvent Z ω then (1 : ℝ) else 0)) ^ 2) =
      eventProb P (nonemptyEvent Z) := by
  classical
  unfold eventProb
  refine Finset.sum_congr rfl ?_
  intro ω _
  have hp : 0 ≤ (P ω).toReal := ENNReal.toReal_nonneg
  by_cases h : nonemptyEvent Z ω
  · calc
      (Real.sqrt (P ω).toReal *
          (if nonemptyEvent Z ω then (1 : ℝ) else 0)) ^ 2
          = (Real.sqrt (P ω).toReal * 1) ^ 2 := by simp [h]
      _ = (Real.sqrt (P ω).toReal) ^ 2 := by ring
      _ = (P ω).toReal := by rw [Real.sq_sqrt hp]
      _ = (P ω).toReal * (if nonemptyEvent Z ω then (1 : ℝ) else 0) := by
            simp [h]
  · simp [h]

/-- Cauchy-Schwarz core of the finite second-moment method:
`E[Z]^2 <= E[Z^2] * Pr[Z > 0]`. -/
theorem countExpectation_sq_le_countSecondMoment_mul_nonemptyProbability
    (P : PMF Ω) (Z : Ω → ℕ) :
    (countExpectation P Z) ^ 2 ≤
      countSecondMoment P Z * eventProb P (nonemptyEvent Z) := by
  classical
  let f : Ω → ℝ := fun ω => Real.sqrt (P ω).toReal * (Z ω : ℝ)
  let g : Ω → ℝ := fun ω =>
    Real.sqrt (P ω).toReal * (if nonemptyEvent Z ω then (1 : ℝ) else 0)
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset Ω) f g
  have hfg :
      (∑ ω, f ω * g ω) = countExpectation P Z := by
    change
      (∑ ω, (Real.sqrt (P ω).toReal * (Z ω : ℝ)) *
        (Real.sqrt (P ω).toReal *
          (if nonemptyEvent Z ω then (1 : ℝ) else 0))) =
        countExpectation P Z
    exact (countExpectation_eq_sqrt_weighted_indicator_sum P Z).symm
  have hf2 : (∑ ω, f ω ^ 2) = countSecondMoment P Z := by
    change (∑ ω, (Real.sqrt (P ω).toReal * (Z ω : ℝ)) ^ 2) =
      countSecondMoment P Z
    exact sqrt_weighted_count_sq_sum_eq_secondMoment P Z
  have hg2 : (∑ ω, g ω ^ 2) = eventProb P (nonemptyEvent Z) := by
    change
      (∑ ω, (Real.sqrt (P ω).toReal *
        (if nonemptyEvent Z ω then (1 : ℝ) else 0)) ^ 2) =
        eventProb P (nonemptyEvent Z)
    exact sqrt_weighted_indicator_sq_sum_eq_nonemptyProb P Z
  simpa [hfg, hf2, hg2] using hcs

/-- Paley-Zygmund / second-moment survival anchor:
`E[Z]^2 / E[Z^2] <= Pr[Z > 0]`. -/
theorem secondMomentRatio_le_nonemptyProbability
    (P : PMF Ω) (Z : Ω → ℕ)
    (hSecond : 0 < countSecondMoment P Z) :
    (countExpectation P Z) ^ 2 / countSecondMoment P Z ≤
      eventProb P (nonemptyEvent Z) := by
  have hcore :=
    countExpectation_sq_le_countSecondMoment_mul_nonemptyProbability P Z
  rw [div_le_iff₀ hSecond]
  linarith [mul_comm (countSecondMoment P Z)
    (eventProb P (nonemptyEvent Z))]

/-- If the second-moment ratio is bounded by `C`, then survival probability is
at least `1 / C`. -/
theorem nonemptyProbability_ge_inv_of_secondMomentRatio_le
    (P : PMF Ω) (Z : Ω → ℕ) {C : ℝ}
    (hExpectation : 0 < countExpectation P Z)
    (hSecond : 0 < countSecondMoment P Z)
    (hC : 0 < C)
    (hRatio : secondMomentRatio P Z ≤ C) :
    1 / C ≤ eventProb P (nonemptyEvent Z) := by
  have hExpSq : 0 < (countExpectation P Z) ^ 2 := pow_pos hExpectation 2
  have hSecond_le : countSecondMoment P Z ≤ C * (countExpectation P Z) ^ 2 := by
    unfold secondMomentRatio at hRatio
    rw [div_le_iff₀ hExpSq] at hRatio
    linarith [mul_comm C ((countExpectation P Z) ^ 2)]
  have hInv_le_ratio :
      1 / C ≤ (countExpectation P Z) ^ 2 / countSecondMoment P Z := by
    calc
      1 / C = (countExpectation P Z) ^ 2 /
          (C * (countExpectation P Z) ^ 2) := by
            field_simp [ne_of_gt hC, ne_of_gt hExpSq]
      _ ≤ (countExpectation P Z) ^ 2 / countSecondMoment P Z := by
            exact div_le_div_of_nonneg_left (le_of_lt hExpSq)
              hSecond hSecond_le
  exact le_trans hInv_le_ratio
    (secondMomentRatio_le_nonemptyProbability P Z hSecond)

/-- Positive survival probability follows from a finite positive
second-moment ratio bound. -/
theorem nonemptyProbability_pos_of_secondMomentRatio_le
    (P : PMF Ω) (Z : Ω → ℕ) {C : ℝ}
    (hExpectation : 0 < countExpectation P Z)
    (hSecond : 0 < countSecondMoment P Z)
    (hC : 0 < C)
    (hRatio : secondMomentRatio P Z ≤ C) :
    0 < eventProb P (nonemptyEvent Z) :=
  lt_of_lt_of_le (one_div_pos.mpr hC)
    (nonemptyProbability_ge_inv_of_secondMomentRatio_le
      P Z hExpectation hSecond hC hRatio)

end

end Survival.FiniteCSPSecondMomentSurvivalBound
