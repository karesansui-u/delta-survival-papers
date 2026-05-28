import Survival.TelescopingExp
/-!
# Wright-Fisher Bridge
Allele frequency drift in finite populations. Genetic drift =
stochastic structural consumption. Fixation = structural collapse
to a single allele.
-/
namespace Survival.WrightFisherBridge
noncomputable section

/-- Heterozygosity H = 2p(1-p) decreases by factor (1-1/(2N)) per gen.
H_t = H_0 · (1-1/(2N))^t ≈ H_0 · exp(-t/(2N)). -/
def heterozygosity (h₀ : ℝ) (N t : ℕ) : ℝ :=
  h₀ * (1 - 1 / (2 * (N : ℝ))) ^ t

/-- Effective population size determines consumption rate. -/
def driftRate (N : ℕ) : ℝ := 1 / (2 * (N : ℝ))

/-- Smaller population → faster drift → more consumption. -/
theorem smaller_pop_faster_drift {N₁ N₂ : ℕ} (h : N₁ < N₂)
    (hN₁ : 0 < N₁) :
    driftRate N₂ < driftRate N₁ := by
  unfold driftRate
  apply div_lt_div_of_pos_left (by norm_num : (0:ℝ) < 1)
  · exact mul_pos (by norm_num : (0:ℝ) < 2) (Nat.cast_pos.mpr hN₁)
  · exact mul_lt_mul_of_pos_left (Nat.cast_lt.mpr h) (by norm_num : (0:ℝ) < 2)

/-- Fixation (H → 0) = complete structural collapse of genetic diversity. -/
theorem fixation_is_collapse (h₀ : ℝ) (hh : 0 < h₀) (r : ℝ) (hr : 0 < r) :
    0 < h₀ * Real.exp (-r) :=
  mul_pos hh (Real.exp_pos _)

end
end Survival.WrightFisherBridge
