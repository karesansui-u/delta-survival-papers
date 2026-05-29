import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Binary Symmetric Channel Reliability Skeleton

This module formalizes the Route A bridge examples A06/A19 at the most basic
finite-prefix level.  It does not prove Shannon's coding theorem.  Instead, it
records the uncoded independent-channel skeleton:

`P(block success after n independent uses) = (1 - p)^n`.

With one-symbol loss `-log (1 - p)`, this is exactly

`(1 - p)^n = exp (-(n * -log (1 - p)))`.

The point is to make the information-transmission example sit next to the
other non-CSP Route A cores: serial reliability, constant-fraction decay,
branching-process expectation, and queue overload.
-/

namespace Survival.BinarySymmetricChannel

noncomputable section

/-- Binary symmetric channel data.  `errorRate` is the per-symbol flip
probability, assumed to lie in `[0, 1)`. -/
structure System where
  errorRate : ℝ
  error_nonneg : 0 ≤ errorRate
  error_lt_one : errorRate < 1

/-- Per-symbol probability of being transmitted without error. -/
def symbolSuccess (C : System) : ℝ :=
  1 - C.errorRate

/-- Probability that all `n` independent channel uses are error-free. -/
def blockSuccessProbability (C : System) (n : ℕ) : ℝ :=
  symbolSuccess C ^ n

/-- Probability of at least one symbol error in the uncoded block skeleton. -/
def blockFailureProbability (C : System) (n : ℕ) : ℝ :=
  1 - blockSuccessProbability C n

/-- One-symbol information-transmission loss. -/
def symbolLoss (C : System) : ℝ :=
  -Real.log (symbolSuccess C)

/-- Cumulative transmission loss after `n` independent channel uses. -/
def cumulativeLoss (C : System) (n : ℕ) : ℝ :=
  (n : ℝ) * symbolLoss C

/-- The per-symbol success probability is strictly positive. -/
theorem symbolSuccess_pos (C : System) :
    0 < symbolSuccess C := by
  unfold symbolSuccess
  linarith [C.error_lt_one]

/-- The per-symbol success probability is at most one. -/
theorem symbolSuccess_le_one (C : System) :
    symbolSuccess C ≤ 1 := by
  unfold symbolSuccess
  linarith [C.error_nonneg]

@[simp] theorem blockSuccessProbability_zero (C : System) :
    blockSuccessProbability C 0 = 1 := by
  simp [blockSuccessProbability]

@[simp] theorem blockFailureProbability_zero (C : System) :
    blockFailureProbability C 0 = 0 := by
  simp [blockFailureProbability]

@[simp] theorem cumulativeLoss_zero (C : System) :
    cumulativeLoss C 0 = 0 := by
  simp [cumulativeLoss]

/-- One more independent channel use multiplies block success by the
per-symbol success probability. -/
theorem blockSuccessProbability_succ (C : System) (n : ℕ) :
    blockSuccessProbability C (n + 1) =
      blockSuccessProbability C n * symbolSuccess C := by
  simp [blockSuccessProbability, pow_succ]

/-- One more independent channel use adds one symbol loss. -/
theorem cumulativeLoss_succ (C : System) (n : ℕ) :
    cumulativeLoss C (n + 1) = cumulativeLoss C n + symbolLoss C := by
  unfold cumulativeLoss
  norm_num
  ring

/-- Symbol loss is nonnegative because the success probability lies in
`(0, 1]`. -/
theorem symbolLoss_nonneg (C : System) :
    0 ≤ symbolLoss C := by
  unfold symbolLoss
  have hlog : Real.log (symbolSuccess C) ≤ 0 :=
    Real.log_nonpos (le_of_lt (symbolSuccess_pos C)) (symbolSuccess_le_one C)
  linarith

/-- Cumulative transmission loss is nonnegative. -/
theorem cumulativeLoss_nonneg (C : System) (n : ℕ) :
    0 ≤ cumulativeLoss C n := by
  unfold cumulativeLoss
  exact mul_nonneg (Nat.cast_nonneg n) (symbolLoss_nonneg C)

/-- Block success is positive. -/
theorem blockSuccessProbability_pos (C : System) (n : ℕ) :
    0 < blockSuccessProbability C n := by
  unfold blockSuccessProbability
  exact pow_pos (symbolSuccess_pos C) n

/-- Block success is at most one. -/
theorem blockSuccessProbability_le_one (C : System) (n : ℕ) :
    blockSuccessProbability C n ≤ 1 := by
  unfold blockSuccessProbability
  exact pow_le_one₀ (le_of_lt (symbolSuccess_pos C)) (symbolSuccess_le_one C)

/-- The exponential of negative cumulative loss equals block success. -/
theorem exp_neg_cumulativeLoss_eq_blockSuccessProbability
    (C : System) (n : ℕ) :
    Real.exp (-cumulativeLoss C n) = blockSuccessProbability C n := by
  unfold cumulativeLoss symbolLoss blockSuccessProbability symbolSuccess
  have hs : 0 < 1 - C.errorRate := by
    linarith [C.error_lt_one]
  have harg :
      -((n : ℝ) * -Real.log (1 - C.errorRate)) =
        (n : ℝ) * Real.log (1 - C.errorRate) := by
    ring
  rw [harg, ← Real.log_pow, Real.exp_log (pow_pos hs n)]

/-- Block success has the structural-persistence form `exp (-L_n)`. -/
theorem blockSuccessProbability_eq_exp_neg_cumulativeLoss
    (C : System) (n : ℕ) :
    blockSuccessProbability C n = Real.exp (-cumulativeLoss C n) := by
  rw [exp_neg_cumulativeLoss_eq_blockSuccessProbability]

/-- If cumulative loss has crossed `-log θ`, then uncoded block success is at
most `θ`. -/
theorem blockSuccessProbability_le_threshold_of_cumulativeLoss_ge
    (C : System) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeLoss C n) :
    blockSuccessProbability C n ≤ θ := by
  rw [blockSuccessProbability_eq_exp_neg_cumulativeLoss]
  have hneg : -cumulativeLoss C n ≤ Real.log θ := by
    linarith
  calc
    Real.exp (-cumulativeLoss C n) ≤ Real.exp (Real.log θ) :=
      Real.exp_le_exp.mpr hneg
    _ = θ := Real.exp_log hθ

/-- The same threshold crossing gives a lower bound on block failure. -/
theorem blockFailureProbability_ge_one_sub_threshold_of_cumulativeLoss_ge
    (C : System) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeLoss C n) :
    1 - θ ≤ blockFailureProbability C n := by
  unfold blockFailureProbability
  have hsucc :
      blockSuccessProbability C n ≤ θ :=
    blockSuccessProbability_le_threshold_of_cumulativeLoss_ge C n hθ hcross
  linarith

/-- Positive channel noise makes the per-symbol success probability strictly
less than one. -/
theorem symbolSuccess_lt_one_of_error_pos
    (C : System) (herror : 0 < C.errorRate) :
    symbolSuccess C < 1 := by
  unfold symbolSuccess
  linarith

/-- Positive channel noise creates positive one-symbol loss. -/
theorem symbolLoss_pos_of_error_pos
    (C : System) (herror : 0 < C.errorRate) :
    0 < symbolLoss C := by
  unfold symbolLoss
  have hlog :
      Real.log (symbolSuccess C) < 0 :=
    Real.log_neg (symbolSuccess_pos C)
      (symbolSuccess_lt_one_of_error_pos C herror)
  linarith

end

end Survival.BinarySymmetricChannel
