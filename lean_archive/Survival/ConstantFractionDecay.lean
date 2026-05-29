import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Constant-Fraction Decay

This module packages the common Route A core behind radioactive decay,
Beer--Lambert attenuation, first-order reaction kinetics, and one-compartment
pharmacokinetic decay.

At each step a fixed fraction `q` of the viable mass remains, with
`0 < q <= 1`.  The remaining fraction after `n` steps is `q^n`, while the
per-step structural loss is `-log q`.  Thus

`q^n = exp (-(n * -log q))`.

This is the discrete finite-prefix skeleton of the textbook exponential decay
examples in the domain table.
-/

namespace Survival.ConstantFractionDecay

noncomputable section

/-- A fixed-fraction decay law.  The parameter `q` is the per-step retained
fraction. -/
structure System where
  q : ℝ
  q_pos : 0 < q
  q_le_one : q ≤ 1

/-- Remaining fraction after `n` equal decay steps. -/
def remainingFraction (S : System) (n : ℕ) : ℝ :=
  S.q ^ n

/-- One-step log-ratio loss. -/
def stepLoss (S : System) : ℝ :=
  -Real.log S.q

/-- Cumulative loss after `n` equal decay steps. -/
def cumulativeLoss (S : System) (n : ℕ) : ℝ :=
  (n : ℝ) * stepLoss S

@[simp] theorem remainingFraction_zero (S : System) :
    remainingFraction S 0 = 1 := by
  simp [remainingFraction]

@[simp] theorem cumulativeLoss_zero (S : System) :
    cumulativeLoss S 0 = 0 := by
  simp [cumulativeLoss]

/-- One more decay step multiplies the remaining fraction by `q`. -/
theorem remainingFraction_succ (S : System) (n : ℕ) :
    remainingFraction S (n + 1) = remainingFraction S n * S.q := by
  simp [remainingFraction, pow_succ]

/-- One more decay step adds one copy of the step loss. -/
theorem cumulativeLoss_succ (S : System) (n : ℕ) :
    cumulativeLoss S (n + 1) = cumulativeLoss S n + stepLoss S := by
  unfold cumulativeLoss
  norm_num
  ring

/-- The one-step log-ratio loss is nonnegative whenever `q <= 1`. -/
theorem stepLoss_nonneg (S : System) :
    0 ≤ stepLoss S := by
  unfold stepLoss
  have hlog : Real.log S.q ≤ 0 :=
    Real.log_nonpos (le_of_lt S.q_pos) S.q_le_one
  linarith

/-- Cumulative loss is nonnegative. -/
theorem cumulativeLoss_nonneg (S : System) (n : ℕ) :
    0 ≤ cumulativeLoss S n := by
  unfold cumulativeLoss
  exact mul_nonneg (Nat.cast_nonneg n) (stepLoss_nonneg S)

/-- Remaining fraction is positive. -/
theorem remainingFraction_pos (S : System) (n : ℕ) :
    0 < remainingFraction S n := by
  unfold remainingFraction
  exact pow_pos S.q_pos n

/-- The retained fraction is at most `1`. -/
theorem remainingFraction_le_one (S : System) (n : ℕ) :
    remainingFraction S n ≤ 1 := by
  unfold remainingFraction
  exact pow_le_one₀ (le_of_lt S.q_pos) S.q_le_one

/-- The exponential of negative cumulative loss equals the retained fraction. -/
theorem exp_neg_cumulativeLoss_eq_remainingFraction (S : System) (n : ℕ) :
    Real.exp (-cumulativeLoss S n) = remainingFraction S n := by
  unfold cumulativeLoss stepLoss remainingFraction
  have harg : -((n : ℝ) * -Real.log S.q) = (n : ℝ) * Real.log S.q := by
    ring
  rw [harg, ← Real.log_pow, Real.exp_log (pow_pos S.q_pos n)]

/-- The retained fraction has the structural-persistence form `exp (-L_n)`. -/
theorem remainingFraction_eq_exp_neg_cumulativeLoss (S : System) (n : ℕ) :
    remainingFraction S n = Real.exp (-cumulativeLoss S n) := by
  rw [exp_neg_cumulativeLoss_eq_remainingFraction]

/-- Initial mass times the retained fraction. -/
def remainingMass (S : System) (initialMass : ℝ) (n : ℕ) : ℝ :=
  initialMass * remainingFraction S n

/-- Remaining mass inherits the exponential decay form. -/
theorem remainingMass_eq_initial_mul_exp_neg_cumulativeLoss
    (S : System) (initialMass : ℝ) (n : ℕ) :
    remainingMass S initialMass n =
      initialMass * Real.exp (-cumulativeLoss S n) := by
  simp [remainingMass, remainingFraction_eq_exp_neg_cumulativeLoss]

/-- If cumulative loss crosses `-log θ`, the remaining fraction is at most
`θ`. -/
theorem remainingFraction_le_threshold_of_cumulativeLoss_ge
    (S : System) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeLoss S n) :
    remainingFraction S n ≤ θ := by
  rw [remainingFraction_eq_exp_neg_cumulativeLoss]
  have hneg : -cumulativeLoss S n ≤ Real.log θ := by
    linarith
  calc
    Real.exp (-cumulativeLoss S n) ≤ Real.exp (Real.log θ) :=
      Real.exp_le_exp.mpr hneg
    _ = θ := Real.exp_log hθ

end

end Survival.ConstantFractionDecay
