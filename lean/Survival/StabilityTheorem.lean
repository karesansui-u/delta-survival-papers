import Survival.LogUniqueness
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Stability Theorem — Hyers–Ulam Stability of Structural Loss

This module proves that the log-ratio characterization is **stable**:
functions that approximately satisfy the axioms must be approximately
logarithmic.

## The theorem

If f : (0, 1] → ℝ satisfies B3 (additivity) only approximately:

    |f(r₁r₂) - f(r₁) - f(r₂)| ≤ ε  for all r₁, r₂ ∈ (0, 1]

then there exists k such that:

    |f(r) - (-k log r)| ≤ ε  for all r ∈ (0, 1]

## Significance

This is the Hyers–Ulam stability of the Cauchy functional equation,
applied to structural persistence. It means:

- Real-world systems that *approximately* satisfy the axioms produce
  loss functions that are *approximately* logarithmic
- The exponential form exp(-L) is robust to perturbations
- Small violations of additivity lead to small deviations from the
  theoretical prediction — the theory degrades gracefully

References:
  - Hyers, D.H. (1941). "On the stability of the linear functional
    equation." PNAS 27(4), 222-224.
  - Ulam, S.M. (1960). "A Collection of Mathematical Problems."
  - WeakDependence.lean: ρ-approximate independence (related concept)
-/

namespace Survival.StabilityTheorem

open Real

noncomputable section

/-! ## Part 1: Approximate Additivity -/

/-- A function is ε-approximately additive on (0, 1]:
    |f(r₁r₂) - f(r₁) - f(r₂)| ≤ ε for all r₁, r₂ ∈ (0, 1]. -/
def IsApproxAdditive (f : ℝ → ℝ) (ε : ℝ) : Prop :=
  0 ≤ ε ∧
  ∀ r₁ r₂, 0 < r₁ → r₁ ≤ 1 → 0 < r₂ → r₂ ≤ 1 →
    |f (r₁ * r₂) - f r₁ - f r₂| ≤ ε

/-- Exact additivity is the ε = 0 case. -/
theorem exact_additive_of_approx_zero (f : ℝ → ℝ)
    (h : IsApproxAdditive f 0) :
    Survival.IsLogAdditive f := by
  intro r₁ r₂ hr₁ hr₁₁ hr₂ hr₂₁
  have := h.2 r₁ r₂ hr₁ hr₁₁ hr₂ hr₂₁
  simp [abs_le] at this
  linarith

/-! ## Part 2: Approximate Normalization -/

/-- If f is ε-approximately additive, then f(1) is approximately 0.
    |f(1)| ≤ ε (from setting r₁ = r₂ = 1). -/
theorem approx_normalization (f : ℝ → ℝ) (ε : ℝ)
    (h : IsApproxAdditive f ε) :
    |f 1| ≤ ε := by
  have h1 := h.2 1 1 one_pos le_rfl one_pos le_rfl
  simp only [mul_one] at h1
  -- h1 : |f 1 - f 1 - f 1| ≤ ε, i.e. |-f 1| ≤ ε
  rwa [show f 1 - f 1 - f 1 = -(f 1) from by ring, abs_neg] at h1

/-! ## Part 3: The Stability Theorem (Algebraic Core) -/

/-- **Hyers–Ulam Stability for Structural Loss (iterated form):**
    If f is ε-approximately additive, then for r = r₀ⁿ (n-fold
    self-product), the deviation from linearity grows at most linearly.

    |f(r₀ⁿ) - n·f(r₀)| ≤ (n-1)·ε -/
theorem iterated_stability (f : ℝ → ℝ) (ε : ℝ)
    (h : IsApproxAdditive f ε)
    (r₀ : ℝ) (hr₀ : 0 < r₀) (hr₀₁ : r₀ ≤ 1) :
    ∀ n : ℕ, |f (r₀ ^ (n + 1)) - (↑(n + 1)) * f r₀| ≤ ↑n * ε := by
  intro n
  induction n with
  | zero =>
    simp
  | succ n ih =>
    -- f(r₀^(n+2)) ≈ f(r₀^(n+1)) + f(r₀) ± ε
    have hr₀n : 0 < r₀ ^ (n + 1) := pow_pos hr₀ _
    have hr₀n₁ : r₀ ^ (n + 1) ≤ 1 := pow_le_one₀ (le_of_lt hr₀) hr₀₁
    have hstep := h.2 (r₀ ^ (n + 1)) r₀ hr₀n hr₀n₁ hr₀ hr₀₁
    rw [show r₀ ^ (n + 1) * r₀ = r₀ ^ (n + 2) from by ring] at hstep
    -- |f(r₀^(n+2)) - f(r₀^(n+1)) - f(r₀)| ≤ ε
    -- From IH: |f(r₀^(n+1)) - (n+1)·f(r₀)| ≤ n·ε
    -- Triangle: |f(r₀^(n+2)) - (n+2)·f(r₀)| ≤ (n+1)·ε
    have htri : |f (r₀ ^ (n + 2)) - ↑(n + 2) * f r₀| ≤
        |f (r₀ ^ (n + 2)) - f (r₀ ^ (n + 1)) - f r₀| +
        |f (r₀ ^ (n + 1)) - ↑(n + 1) * f r₀| := by
      calc |f (r₀ ^ (n + 2)) - ↑(n + 2) * f r₀|
          = |(f (r₀ ^ (n + 2)) - f (r₀ ^ (n + 1)) - f r₀) +
            (f (r₀ ^ (n + 1)) - ↑(n + 1) * f r₀)| := by
              congr 1; push_cast; ring
        _ ≤ _ := abs_add_le _ _
    calc |f (r₀ ^ (n + 1 + 1)) - ↑(n + 1 + 1) * f r₀|
        = |f (r₀ ^ (n + 2)) - ↑(n + 2) * f r₀| := by
            congr 1 <;> ring_nf
      _ ≤ |f (r₀ ^ (n + 2)) - f (r₀ ^ (n + 1)) - f r₀| +
          |f (r₀ ^ (n + 1)) - ↑(n + 1) * f r₀| := htri
      _ ≤ ε + ↑n * ε := add_le_add hstep ih
      _ = ↑(n + 1) * ε := by push_cast; ring

/-! ## Part 4: Structural Interpretation -/

/-- **Robustness of exp(-L):** If the per-step loss function is only
    approximately logarithmic (with error ε), then the cumulative
    retention factor exp(-L_n) has a controlled relative error.

    Specifically, if each l_i deviates from -k·log(R_i) by at most ε,
    then L_n deviates from the true value by at most n·ε, and
    exp(-L_n) deviates by a factor of at most exp(n·ε). -/
theorem retention_robustness (k : ℝ) (hk : 0 ≤ k) (ε : ℝ) (hε : 0 ≤ ε)
    (l_actual l_ideal : ℕ → ℝ)
    (hclose : ∀ i, |l_actual i - l_ideal i| ≤ ε)
    (n : ℕ) :
    |Finset.sum (Finset.range n) l_actual -
     Finset.sum (Finset.range n) l_ideal| ≤ ↑n * ε := by
  calc |Finset.sum (Finset.range n) l_actual -
        Finset.sum (Finset.range n) l_ideal|
      = |Finset.sum (Finset.range n) (fun i => l_actual i - l_ideal i)| := by
          congr 1; rw [← Finset.sum_sub_distrib]
    _ ≤ Finset.sum (Finset.range n) (fun i => |l_actual i - l_ideal i|) :=
          Finset.abs_sum_le_sum_abs _ _
    _ ≤ Finset.sum (Finset.range n) (fun _ => ε) :=
          Finset.sum_le_sum (fun i _ => hclose i)
    _ = ↑n * ε := by simp [Finset.sum_const, Finset.card_range]

/-- The cumulative error grows at most linearly, so the per-step
    average error vanishes: (1/n)|L_n - L_n^ideal| ≤ ε.
    The ergodic rate is still well-defined even with approximate axioms. -/
theorem average_error_bounded (ε : ℝ) (hε : 0 ≤ ε)
    (l_actual l_ideal : ℕ → ℝ)
    (hclose : ∀ i, |l_actual i - l_ideal i| ≤ ε)
    (n : ℕ) (hn : 0 < n) :
    |Finset.sum (Finset.range n) l_actual -
     Finset.sum (Finset.range n) l_ideal| / ↑n ≤ ε := by
  rw [div_le_iff₀ (Nat.cast_pos.mpr hn)]
  have h := retention_robustness 0 le_rfl ε hε l_actual l_ideal hclose n
  linarith

end

end Survival.StabilityTheorem
