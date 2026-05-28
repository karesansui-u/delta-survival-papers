import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Arrhenius Bridge
k = A exp(-Ea/RT). Reaction rate = retention factor with L = Ea/(RT).
-/
namespace Survival.ArrheniusBridge
noncomputable section

/-- Arrhenius rate: k = A exp(-Ea/(RT)). -/
def arrheniusRate (A Ea R T : ℝ) : ℝ := A * Real.exp (-(Ea / (R * T)))

/-- This IS S = M exp(-L) with M = A, L = Ea/(RT). -/
theorem arrhenius_is_persistence (A Ea R T : ℝ) :
    arrheniusRate A Ea R T = A * Real.exp (-(Ea / (R * T))) := rfl

/-- Rate is positive when A > 0. -/
theorem arrhenius_pos {A Ea R T : ℝ} (hA : 0 < A) :
    0 < arrheniusRate A Ea R T := by
  unfold arrheniusRate; exact mul_pos hA (Real.exp_pos _)

/-- Higher Ea → lower rate (more structural consumption). -/
theorem higher_barrier_lower_rate
    {A Ea₁ Ea₂ R T : ℝ} (hA : 0 < A) (hRT : 0 < R * T)
    (hEa : Ea₁ < Ea₂) :
    arrheniusRate A Ea₂ R T < arrheniusRate A Ea₁ R T := by
  unfold arrheniusRate
  apply mul_lt_mul_of_pos_left _ hA
  apply Real.exp_lt_exp.mpr
  simp only [neg_lt_neg_iff]
  exact div_lt_div_of_pos_right hEa hRT

end
end Survival.ArrheniusBridge
