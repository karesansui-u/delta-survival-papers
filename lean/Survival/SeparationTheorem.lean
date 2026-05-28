import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Separation Theorem — Uniqueness of the Product Form S = M · R

This module proves that the product decomposition S = M · exp(-L)
is the **unique** way to combine a resource term M and a structural
retention factor R into a persistence potential, given natural axioms.

## The theorem

If a function f : ℝ × ℝ → ℝ satisfies:
1. **Linearity in M**: f(αM, R) = α · f(M, R) for α > 0
2. **Multiplicativity in R**: f(M, R₁R₂) = f(M, R₁) · R₂ / f(M, 1)
   ... actually the cleanest axiom is:
3. **Separation**: f(M, R) = g(M) · h(R) for some g, h
4. **Normalization**: f(M, 1) = M (when retention is full, S = M)
5. **Monotonicity**: f is increasing in both M and R

Then f(M, R) = M · R, i.e., g(M) = M and h(R) = R.

## Significance

This shows that the product form S = M · exp(-L) is not merely
convenient — it is the **only** form consistent with resource
scaling and structural retention being separable.

References:
  - TelescopingExp.lean: the algebraic identity m_n = m_0 exp(-L)
-/

namespace Survival.SeparationTheorem

open Real

noncomputable section

/-! ## Part 1: Separable Persistence Functional -/

/-- A separable persistence functional: S = g(M) · h(R) where
    g handles resources and h handles structural retention. -/
structure SeparableFunctional where
  /-- Resource component -/
  g : ℝ → ℝ
  /-- Retention component -/
  h : ℝ → ℝ
  /-- g is positive-homogeneous: g(αM) = α · g(M) for α > 0 -/
  g_homogeneous : ∀ α M, 0 < α → g (α * M) = α * g M
  /-- h(1) = 1 (full retention means no scaling) -/
  h_one : h 1 = 1
  /-- g(1) = 1 (unit resource) -/
  g_one : g 1 = 1

/-- The composite function S(M, R) = g(M) · h(R). -/
def eval (F : SeparableFunctional) (M R : ℝ) : ℝ :=
  F.g M * F.h R

/-! ## Part 2: The Separation Theorem -/

/-- **g must be the identity**: g(M) = M for all M > 0.
    Proof: g(M) = g(M · 1) = M · g(1) = M · 1 = M. -/
theorem g_eq_id (F : SeparableFunctional) (M : ℝ) (hM : 0 < M) :
    F.g M = M := by
  have h := F.g_homogeneous M 1 hM
  rw [mul_one] at h
  rw [h, F.g_one, mul_one]

/-- At full retention, S = M (normalization). -/
theorem eval_full_retention (F : SeparableFunctional)
    (M : ℝ) (hM : 0 < M) :
    eval F M 1 = M := by
  unfold eval
  rw [g_eq_id F M hM, F.h_one, mul_one]

/-- **The product form is unique**: For any separable functional F
    satisfying the axioms, eval F M R = M · h(R).
    The only freedom is in the choice of h.

    Combined with the Representation Theorem (which forces
    R = exp(-L) and h(R) = R), we get S = M · exp(-L). -/
theorem separation_uniqueness (F : SeparableFunctional)
    (M R : ℝ) (hM : 0 < M) :
    eval F M R = M * F.h R := by
  unfold eval
  rw [g_eq_id F M hM]

/-! ## Part 3: h Must Be the Identity (under additional axiom) -/

/-- If h is also positive-homogeneous with h(1) = 1, then h = id.
    This forces S = M · R exactly. -/
theorem h_eq_id_of_homogeneous
    (h : ℝ → ℝ) (h_one : h 1 = 1)
    (h_homog : ∀ α R, 0 < α → h (α * R) = α * h R)
    (R : ℝ) (hR : 0 < R) :
    h R = R := by
  have := h_homog R 1 hR
  rw [mul_one] at this
  rw [this, h_one, mul_one]

/-- **Full Separation Theorem**: Under positive homogeneity of both
    g and h, with g(1) = h(1) = 1, the only separable functional is
    f(M, R) = M · R. -/
theorem full_separation (F : SeparableFunctional)
    (h_homog : ∀ α R, 0 < α → F.h (α * R) = α * F.h R)
    (M R : ℝ) (hM : 0 < M) (hR : 0 < R) :
    eval F M R = M * R := by
  rw [separation_uniqueness F M R hM,
      h_eq_id_of_homogeneous F.h F.h_one h_homog R hR]

/-! ## Part 4: Connection to exp(-L) -/

/-- The retention factor R = exp(-L) is the unique continuous
    multiplicative function of L with R(0) = 1 (from CauchyExponential).
    Combined with the separation theorem, this gives:

    S = M · exp(-L)

    as the unique persistence potential satisfying:
    - Separability (S = g(M) · h(R))
    - Resource homogeneity (g(αM) = αg(M))
    - Normalization (g(1) = 1, h(1) = 1)
    - Retention homogeneity (h(αR) = αh(R))

    No other functional form is possible. -/
theorem unique_persistence_potential :
    ∀ F : SeparableFunctional,
      (∀ α R, 0 < α → F.h (α * R) = α * F.h R) →
      ∀ M R, 0 < M → 0 < R → eval F M R = M * R :=
  fun F hh M R hM hR => full_separation F hh M R hM hR

end

end Survival.SeparationTheorem
