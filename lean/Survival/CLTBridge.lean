import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Central Limit Theorem Bridge
CLT: normalized sums → Gaussian. Log-normal: ln X ~ Normal.
The Gaussian density exp(-x²/2) IS a structural retention factor
with quadratic consumption L = x²/2.
-/
namespace Survival.CLTBridge
noncomputable section

/-- Gaussian density kernel: exp(-x²/(2σ²)). -/
def gaussianKernel (x sigma : ℝ) : ℝ := Real.exp (-(x ^ 2 / (2 * sigma ^ 2)))

/-- Gaussian kernel is positive. -/
theorem gaussian_pos (x sigma : ℝ) : 0 < gaussianKernel x sigma := Real.exp_pos _

/-- Gaussian kernel ≤ 1 (peak at x = 0). -/
theorem gaussian_le_one (x sigma : ℝ) (hs : 0 < sigma) :
    gaussianKernel x sigma ≤ 1 := by
  unfold gaussianKernel
  have h1 : 0 ≤ x ^ 2 := sq_nonneg x
  have h2 : 0 < 2 * sigma ^ 2 := by positivity
  calc Real.exp (-(x ^ 2 / (2 * sigma ^ 2)))
      ≤ Real.exp 0 := Real.exp_le_exp.mpr (by
        rw [neg_le_iff_add_nonneg, zero_add]
        exact div_nonneg h1 (le_of_lt h2))
    _ = 1 := Real.exp_zero

/-- The Gaussian IS S = M exp(-L) with L = x²/(2σ²). -/
theorem gaussian_is_retention (x sigma : ℝ) :
    gaussianKernel x sigma = Real.exp (-(x ^ 2 / (2 * sigma ^ 2))) := rfl

/-- Log-normal: ln X ~ Normal means X = exp(μ + σZ).
This IS structural persistence with stochastic consumption. -/
theorem lognormal_is_exp_consumption (mu sigma z : ℝ) :
    Real.exp (mu + sigma * z) = Real.exp mu * Real.exp (sigma * z) :=
  Real.exp_add mu (sigma * z)

end
end Survival.CLTBridge
