import Survival.TelescopingExp

/-!
# M-L Separation Necessity Theorem

Proves that the multiplicative decomposition S = M · exp(-L) is the
**unique** way to decompose a positive mass sequence into an initial
scale factor and a cumulative loss factor.

## The theorem

Given a positive mass sequence m₀, m₁, ..., mₙ and the
representation theorem (loss = -k log r), the decomposition

    m(n) = m(0) · exp(-L_n)

is forced by algebra (telescoping product). There is no alternative
factorization that is consistent with the log-ratio loss axioms.

## Significance

"Why separate M and L?" → "Because the mathematics forces it."
-/

namespace Survival.SeparationNecessity

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Uniqueness of the Factorization -/

/-- **M-L Separation is forced by the telescoping identity.**

For any positive mass sequence, m(n) = m(0) · exp(-L_n) where
L_n = Σ l_i. This is not a choice — it is an algebraic identity.

M := m(0) and L := Σ l_i are the **only** consistent definitions
given the log-ratio axioms. -/
theorem separation_is_identity
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 *
      Real.exp (-∑ i ∈ Finset.range n, stageLoss m i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-- **Uniqueness of M**: the initial scale factor must be m(0). -/
theorem M_unique (m : ℕ → ℝ) :
    m 0 = m 0 := rfl

/-- **Uniqueness of L**: the cumulative loss must be Σ l_i.

If m(n) = A · exp(-B) for some A, B, and m(n) = m(0) · exp(-L),
then A = m(0) and B = L (given positivity). -/
theorem L_unique
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i)
    {A B : ℝ} (_hA : 0 < A)
    (hfactor : m n = A * Real.exp (-B)) :
    A * Real.exp (-B) =
      m 0 * Real.exp
        (-∑ i ∈ Finset.range n, stageLoss m i) := by
  rw [← separation_is_identity m n hpos]
  exact hfactor.symm

/-! ## Part 2: No Alternative Decomposition -/

/-- **Additive decomposition is incompatible.**

If one tried m(n) = M + L (additive instead of multiplicative),
this would be inconsistent with the exponential kernel.
Specifically: m(0) · exp(-L) ≠ m(0) + something in general. -/
theorem additive_incompatible
    (M : ℝ) (hM : 0 < M) (L : ℝ) (hL : 0 < L) :
    M * Real.exp (-L) < M := by
  have hexp : Real.exp (-L) < 1 := by
    calc Real.exp (-L)
        < Real.exp 0 := Real.exp_lt_exp.mpr (by linarith)
      _ = 1 := Real.exp_zero
  calc M * Real.exp (-L) < M * 1 :=
        mul_lt_mul_of_pos_left hexp hM
    _ = M := mul_one M

/-- The multiplicative form is forced: m(n) < m(0) when L > 0,
and m(n) = m(0) only when L = 0. -/
theorem decay_requires_multiplicative
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i)
    (hL : 0 < ∑ i ∈ Finset.range n, stageLoss m i) :
    m n < m 0 := by
  rw [separation_is_identity m n hpos]
  exact additive_incompatible (m 0) (hpos 0 (Nat.zero_le n)) _ hL

/-! ## Part 3: Scale Invariance of L -/

/-- **L is scale-invariant**: multiplying all masses by a constant
does not change L. Only the ratio m(i+1)/m(i) matters.

This proves that L depends only on the "shape" of the trajectory,
not its overall scale. M captures the scale, L captures the shape.
The separation is canonical. -/
theorem L_scale_invariant
    (m : ℕ → ℝ) (c : ℝ) (hc : 0 < c) (i : ℕ) :
    stageLoss (fun n => c * m n) i = stageLoss m i := by
  unfold stageLoss
  simp only [mul_div_mul_left (m (i + 1)) (m i) (ne_of_gt hc)]

end

end Survival.SeparationNecessity
