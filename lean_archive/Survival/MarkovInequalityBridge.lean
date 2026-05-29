import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Markov Inequality Bridge — Most Basic Probability Bound
P(X ≥ a) ≤ E[X]/a for nonneg X. Structural reading: the probability
that structural consumption exceeds threshold a is bounded by the
mean consumption divided by a. The simplest structural prediction.
-/
namespace Survival.MarkovInequalityBridge
noncomputable section
/-- Markov bound: P(X ≥ a) ≤ μ/a. -/
def markovBound (mean threshold : ℝ) : ℝ := mean / threshold

theorem markov_nonneg (μ a : ℝ) (hμ : 0 ≤ μ) (ha : 0 < a) :
    0 ≤ markovBound μ a := div_nonneg hμ (le_of_lt ha)

theorem markov_le_one (μ a : ℝ) (hμ : 0 ≤ μ) (ha : 0 < a) (h : μ ≤ a) :
    markovBound μ a ≤ 1 := by
  unfold markovBound; exact (div_le_one₀ ha).mpr h

/-- Higher threshold → lower bound (less likely to exceed). -/
theorem higher_threshold_lower_bound (μ a₁ a₂ : ℝ) (hμ : 0 < μ)
    (ha₁ : 0 < a₁) (h : a₁ < a₂) :
    markovBound μ a₂ < markovBound μ a₁ := by
  unfold markovBound; exact div_lt_div_of_pos_left hμ ha₁ h
end
end Survival.MarkovInequalityBridge
