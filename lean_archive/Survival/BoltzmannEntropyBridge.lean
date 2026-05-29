import Survival.TelescopingExp
/-!
# Boltzmann Entropy Bridge
S_Boltzmann = k ln W is the structural consumption in reverse:
L = -ln(W_n/W_0) = ln(W_0/W_n), so W_n = W_0 exp(-L).
-/
namespace Survival.BoltzmannEntropyBridge
noncomputable section

/-- Boltzmann entropy S = k ln W. -/
def boltzmannEntropy (k W : ℝ) : ℝ := k * Real.log W

/-- S is nonneg when W ≥ 1 and k > 0. -/
theorem boltzmannEntropy_nonneg {k W : ℝ} (hk : 0 < k) (hW : 1 ≤ W) :
    0 ≤ boltzmannEntropy k W := by
  unfold boltzmannEntropy; exact mul_nonneg (le_of_lt hk) (Real.log_nonneg hW)

/-- Structural consumption L = -ln(W_n/W_0) = S_0 - S_n (at k=1). -/
theorem consumption_is_entropy_decrease (W₀ Wₙ : ℝ) (h₀ : 0 < W₀) (hₙ : 0 < Wₙ) :
    -Real.log (Wₙ / W₀) = Real.log W₀ - Real.log Wₙ := by
  rw [Real.log_div (ne_of_gt hₙ) (ne_of_gt h₀)]; ring

/-- W_n = W_0 exp(-L) is the Boltzmann form of the persistence kernel. -/
theorem boltzmann_kernel (m : ℕ → ℝ) (n : ℕ) (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 * Real.exp (-∑ i ∈ Finset.range n, Survival.TelescopingExp.stageLoss m i) :=
  Survival.TelescopingExp.measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

end
end Survival.BoltzmannEntropyBridge
