import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Pharmacokinetics Bridge
C(t) = C₀ exp(-kt): drug concentration decay IS S = M exp(-L).
Elimination rate k = structural consumption rate.
Half-life t½ = ln 2 / k.
-/
namespace Survival.PharmacokineticsBridge
noncomputable section

def drugConcentration (c₀ k t : ℝ) : ℝ := c₀ * Real.exp (-k * t)

theorem drug_is_persistence (c₀ k t : ℝ) (hc : 0 < c₀) :
    0 < drugConcentration c₀ k t := by
  unfold drugConcentration; exact mul_pos hc (Real.exp_pos _)

theorem drug_decays {c₀ k t : ℝ} (hc : 0 < c₀) (hk : 0 < k) (ht : 0 < t) :
    drugConcentration c₀ k t < c₀ := by
  unfold drugConcentration
  calc c₀ * Real.exp (-k * t) < c₀ * Real.exp 0 := by
        exact mul_lt_mul_of_pos_left (Real.exp_lt_exp.mpr (by nlinarith)) hc
    _ = c₀ := by rw [Real.exp_zero, mul_one]

/-- Therapeutic window = structural viable region V_G. -/
theorem therapeutic_window (c_min c_max c : ℝ) :
    c_min ≤ c ∧ c ≤ c_max ↔ c ∈ Set.Icc c_min c_max :=
  Set.mem_Icc.symm

end
end Survival.PharmacokineticsBridge
