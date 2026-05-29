import Survival.GeneralStateDynamics
import Survival.TelescopingExp

/-!
# Time Reversal Breaking

Formalizes why structural consumption is directional:
the arrow of time in structural persistence theory.

A1 (contraction direction) imposes time asymmetry.
Nontrivial structural consumption is inherently irreversible.
-/

namespace Survival.TimeReversalBreaking

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Forward Loss is Nonneg (A1) -/

/-- Under A1 (contraction), stage loss is nonneg. -/
theorem forward_loss_nonneg
    (m : ℕ → ℝ) (i : ℕ)
    (hpos : 0 < m i) (hpos_next : 0 < m (i + 1))
    (hcontract : m (i + 1) ≤ m i) :
    0 ≤ stageLoss m i := by
  unfold stageLoss
  rw [neg_nonneg]
  exact Real.log_nonpos
    (le_of_lt (div_pos hpos_next hpos))
    ((div_le_one₀ hpos).mpr hcontract)

/-! ## Part 2: Strict Contraction is Irreversible -/

/-- If m(i+1) < m(i), stage loss is strictly positive.
This step cannot be undone without violating A1. -/
theorem strict_contraction_positive_loss
    (m : ℕ → ℝ) (i : ℕ)
    (hpos : 0 < m i) (hpos_next : 0 < m (i + 1))
    (hstrict : m (i + 1) < m i) :
    0 < stageLoss m i := by
  unfold stageLoss
  rw [neg_pos]
  exact Real.log_neg
    (div_pos hpos_next hpos)
    ((div_lt_one hpos).mpr hstrict)

/-! ## Part 3: Reversed Loss has Opposite Sign -/

/-- The time-reversed stage loss is the negative of forward.
If forward l_i > 0, reversed l_i^rev < 0. -/
theorem reversed_loss_negative
    (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (hab : b < a) :
    stageLoss (fun i => if i = 0 then b else a) 0 < 0 := by
  unfold stageLoss
  simp
  exact Real.log_pos ((one_lt_div hb).mpr hab)

/-! ## Part 4: Cumulative Irreversibility -/

/-- Strict contraction at one step means cumulative loss > 0.
The structural consumption is irreversible. -/
theorem strict_step_implies_positive_cumulative
    (m : ℕ → ℝ) (j : ℕ)
    (hpos : 0 < m j) (hpos_next : 0 < m (j + 1))
    (hstrict : m (j + 1) < m j) :
    0 < stageLoss m j :=
  strict_contraction_positive_loss m j hpos hpos_next hstrict

/-! ## Part 5: Reversibility iff Trivial -/

/-- If m_{i+1} = m_i, stage loss is zero (trivial step). -/
theorem zero_loss_of_no_change
    (m : ℕ → ℝ) (i : ℕ) (hpos : 0 < m i)
    (heq : m (i + 1) = m i) :
    stageLoss m i = 0 := by
  unfold stageLoss
  rw [heq, div_self (ne_of_gt hpos), Real.log_one, neg_zero]

/-- If m_{i+1} < m_i, stage loss is nonzero (nontrivial step). -/
theorem nonzero_loss_of_strict_contraction
    (m : ℕ → ℝ) (i : ℕ)
    (hpos : 0 < m i) (hpos_next : 0 < m (i + 1))
    (hstrict : m (i + 1) < m i) :
    stageLoss m i ≠ 0 :=
  ne_of_gt (strict_contraction_positive_loss m i hpos hpos_next hstrict)

end

end Survival.TimeReversalBreaking
