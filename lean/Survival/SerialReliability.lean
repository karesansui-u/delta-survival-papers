import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Serial Reliability Systems

This module formalizes the Route A core example A08: an independent serial
reliability block diagram.  If every component must work, total reliability is
the product of component reliabilities.  The structural-persistence loss is the
additive log loss

`L_n = sum_i -log p_i`,

so the serial reliability is exactly `exp (-L_n)`.

The point of the file is deliberately narrow: it records the non-CSP,
textbook-grade instance of B3-style independent additivity.
-/

open scoped BigOperators

namespace Survival.SerialReliability

noncomputable section

/-- A stream of component reliabilities for a serial system.  The first `n`
components form the finite prefix used by the theorems below. -/
structure System where
  p : ℕ → ℝ
  p_pos : ∀ i, 0 < p i
  p_le_one : ∀ i, p i ≤ 1

/-- Reliability of the first `n` components in a serial system. -/
def serialReliability (S : System) (n : ℕ) : ℝ :=
  ∏ i ∈ Finset.range n, S.p i

/-- One-component structural loss. -/
def componentLoss (S : System) (i : ℕ) : ℝ :=
  -Real.log (S.p i)

/-- Cumulative structural loss of the first `n` components. -/
def cumulativeLoss (S : System) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, componentLoss S i

/-- Empty serial prefix has reliability `1`. -/
@[simp] theorem serialReliability_zero (S : System) :
    serialReliability S 0 = 1 := by
  simp [serialReliability]

/-- Empty serial prefix has zero cumulative loss. -/
@[simp] theorem cumulativeLoss_zero (S : System) :
    cumulativeLoss S 0 = 0 := by
  simp [cumulativeLoss]

/-- Adding one more serial component multiplies reliability by that component's
reliability. -/
theorem serialReliability_succ (S : System) (n : ℕ) :
    serialReliability S (n + 1) = serialReliability S n * S.p n := by
  simp [serialReliability, Finset.prod_range_succ]

/-- Adding one more serial component adds its log loss. -/
theorem cumulativeLoss_succ (S : System) (n : ℕ) :
    cumulativeLoss S (n + 1) = cumulativeLoss S n + componentLoss S n := by
  unfold cumulativeLoss componentLoss
  rw [Finset.sum_range_succ]

/-- Component log loss is nonnegative for a reliability in `(0, 1]`. -/
theorem componentLoss_nonneg (S : System) (i : ℕ) :
    0 ≤ componentLoss S i := by
  unfold componentLoss
  have hlog : Real.log (S.p i) ≤ 0 :=
    Real.log_nonpos (le_of_lt (S.p_pos i)) (S.p_le_one i)
  linarith

/-- Cumulative serial-system loss is nonnegative. -/
theorem cumulativeLoss_nonneg (S : System) (n : ℕ) :
    0 ≤ cumulativeLoss S n := by
  unfold cumulativeLoss
  exact Finset.sum_nonneg fun i _ => componentLoss_nonneg S i

/-- Serial reliability is positive whenever every component reliability is
positive. -/
theorem serialReliability_pos (S : System) (n : ℕ) :
    0 < serialReliability S n := by
  unfold serialReliability
  exact Finset.prod_pos fun i _ => S.p_pos i

/-- The exponential of negative cumulative log loss equals the serial product
of component reliabilities. -/
theorem exp_neg_cumulativeLoss_eq_serialReliability (S : System) (n : ℕ) :
    Real.exp (-cumulativeLoss S n) = serialReliability S n := by
  unfold cumulativeLoss componentLoss serialReliability
  have hneg :
      -(∑ i ∈ Finset.range n, -Real.log (S.p i)) =
        ∑ i ∈ Finset.range n, Real.log (S.p i) := by
    simp
  rw [hneg, Real.exp_sum]
  refine Finset.prod_congr rfl ?_
  intro i _
  exact Real.exp_log (S.p_pos i)

/-- Serial reliability has the structural-persistence form `exp (-L_n)`. -/
theorem serialReliability_eq_exp_neg_cumulativeLoss (S : System) (n : ℕ) :
    serialReliability S n = Real.exp (-cumulativeLoss S n) := by
  rw [exp_neg_cumulativeLoss_eq_serialReliability]

/-- If cumulative loss has crossed the threshold `-log θ`, then serial
reliability is at most `θ`. -/
theorem serialReliability_le_threshold_of_cumulativeLoss_ge
    (S : System) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeLoss S n) :
    serialReliability S n ≤ θ := by
  rw [serialReliability_eq_exp_neg_cumulativeLoss]
  have hneg : -cumulativeLoss S n ≤ Real.log θ := by
    linarith
  calc
    Real.exp (-cumulativeLoss S n) ≤ Real.exp (Real.log θ) :=
      Real.exp_le_exp.mpr hneg
    _ = θ := Real.exp_log hθ

/-- Resource-adjusted serial reliability, matching the `M * exp (-L)` reading
used in the structural-persistence prose. -/
def resourceAdjustedReliability (resource : ℝ) (S : System) (n : ℕ) : ℝ :=
  resource * serialReliability S n

/-- Resource-adjusted serial reliability inherits the same exponential loss
factor. -/
theorem resourceAdjustedReliability_eq_resource_mul_exp_neg_cumulativeLoss
    (resource : ℝ) (S : System) (n : ℕ) :
    resourceAdjustedReliability resource S n =
      resource * Real.exp (-cumulativeLoss S n) := by
  simp [resourceAdjustedReliability, serialReliability_eq_exp_neg_cumulativeLoss]

end

end Survival.SerialReliability
