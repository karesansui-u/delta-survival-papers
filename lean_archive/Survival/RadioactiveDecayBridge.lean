import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Radioactive Decay Bridge
N(t) = N₀ exp(-λt) IS S = M exp(-L) with L = λt.
-/
namespace Survival.RadioactiveDecayBridge
noncomputable section

def decayedPopulation (N₀ rate t : ℝ) : ℝ := N₀ * Real.exp (-rate * t)

theorem decay_pos (N₀ rate t : ℝ) (hN : 0 < N₀) :
    0 < decayedPopulation N₀ rate t := by
  unfold decayedPopulation; exact mul_pos hN (Real.exp_pos _)

theorem decay_le_initial (N₀ rate t : ℝ) (hN : 0 < N₀) (h : 0 ≤ rate * t) :
    decayedPopulation N₀ rate t ≤ N₀ := by
  unfold decayedPopulation
  calc N₀ * Real.exp (-rate * t)
      ≤ N₀ * Real.exp 0 := by
        exact mul_le_mul_of_nonneg_left
          (Real.exp_le_exp.mpr (by linarith)) (le_of_lt hN)
    _ = N₀ := by rw [Real.exp_zero, mul_one]

theorem consumption_rate (rate t : ℝ) :
    rate * t = rate * t := rfl

end
end Survival.RadioactiveDecayBridge
