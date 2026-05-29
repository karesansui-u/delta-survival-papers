import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Malthusian Population Bridge
N(t) = N₀ exp(rt). Growth (r>0) is negative consumption (L<0 = recovery).
Decline (r<0) is positive consumption (L>0 = decay).
-/
namespace Survival.MalthusianBridge
noncomputable section

/-- Malthusian population: N(t) = N₀ exp(rt). -/
def population (N₀ r t : ℝ) : ℝ := N₀ * Real.exp (r * t)

/-- Growth = negative structural consumption. -/
theorem growth_is_negative_consumption (N₀ r t : ℝ) :
    population N₀ r t = N₀ * Real.exp (-((-r) * t)) := by
  unfold population; congr 1; ring

/-- Population grows when r > 0 (recovery regime). -/
theorem growth_when_positive_rate (N₀ r t : ℝ) (hN : 0 < N₀) (hr : 0 < r) (ht : 0 < t) :
    N₀ < population N₀ r t := by
  unfold population
  calc N₀ = N₀ * 1 := (mul_one N₀).symm
    _ < N₀ * Real.exp (r * t) :=
      mul_lt_mul_of_pos_left (Real.one_lt_exp_iff.mpr (mul_pos hr ht)) hN

/-- Population declines when r < 0 (collapse regime). -/
theorem decline_when_negative_rate (N₀ r t : ℝ) (hN : 0 < N₀) (hr : r < 0) (ht : 0 < t) :
    population N₀ r t < N₀ := by
  unfold population
  calc N₀ * Real.exp (r * t) < N₀ * Real.exp 0 := by
        exact mul_lt_mul_of_pos_left
          (Real.exp_lt_exp.mpr (by nlinarith)) hN
    _ = N₀ := by rw [Real.exp_zero, mul_one]

end
end Survival.MalthusianBridge
