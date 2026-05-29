import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Chebyshev Inequality Bridge — Variance Bounds Structural Deviation
P(|X - μ| ≥ kσ) ≤ 1/k². Structural reading: the probability that
structural consumption deviates from its mean by more than kσ is
bounded by 1/k². This controls the "atypicality" of structural fate.
-/
namespace Survival.ChebyshevBridge
noncomputable section
/-- Chebyshev bound: P(deviation ≥ kσ) ≤ 1/k². -/
def chebyshevBound (k : ℝ) : ℝ := 1 / k ^ 2

theorem chebyshev_pos (k : ℝ) (hk : 0 < k) : 0 < chebyshevBound k := by
  unfold chebyshevBound; positivity

theorem chebyshev_le_one (k : ℝ) (hk : 1 ≤ k) : chebyshevBound k ≤ 1 := by
  unfold chebyshevBound
  rw [div_le_one₀ (by positivity)]
  nlinarith [sq_nonneg (k - 1)]

/-- Larger k → tighter bound → deviations are rarer. -/
theorem larger_k_tighter (k₁ k₂ : ℝ) (h₁ : 0 < k₁) (h : k₁ < k₂) :
    chebyshevBound k₂ < chebyshevBound k₁ := by
  unfold chebyshevBound
  exact div_lt_div_of_pos_left one_pos (by positivity)
    (sq_lt_sq' (by linarith) h)
end
end Survival.ChebyshevBridge
