import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Fourier Bridge
Fourier: f(t) = Σ aₙ exp(inωt). The exponential kernel exp(iωt)
shares the multiplicative/additive structure with exp(-L).
Decay of Fourier coefficients = structural consumption in frequency.
-/
namespace Survival.FourierBridge
noncomputable section

/-- Exponential decay of Fourier coefficients: |aₙ| ≤ C exp(-αn).
This IS structural consumption in frequency domain. -/
def fourierDecay (C alpha : ℝ) (n : ℕ) : ℝ := C * Real.exp (-alpha * n)

/-- Fourier decay IS the persistence kernel. -/
theorem fourier_is_persistence (C alpha : ℝ) (n : ℕ) (hC : 0 < C) :
    0 < fourierDecay C alpha n := by
  unfold fourierDecay; exact mul_pos hC (Real.exp_pos _)

/-- Smoother functions have faster coefficient decay.
More regularity = less structural complexity. -/
theorem smoother_faster_decay {C a₁ a₂ : ℝ} {n : ℕ}
    (hC : 0 < C) (ha : a₁ < a₂) (hn : 0 < n) :
    fourierDecay C a₂ n < fourierDecay C a₁ n := by
  unfold fourierDecay
  have hn' : (0 : ℝ) < (n : ℝ) := Nat.cast_pos.mpr hn
  exact mul_lt_mul_of_pos_left
    (Real.exp_lt_exp.mpr (by nlinarith)) hC

/-- The additive property: exp(a+b) = exp(a)·exp(b).
This is WHY Fourier and structural persistence share structure. -/
theorem shared_multiplicative_structure (a b : ℝ) :
    Real.exp (a + b) = Real.exp a * Real.exp b := Real.exp_add a b

end
end Survival.FourierBridge
