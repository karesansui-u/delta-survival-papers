import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Moore's Law Bridge
Transistor count ∝ 2^(t/T₂). This is exp(t·ln2/T₂).
Growth = negative structural consumption (recovery regime).
End of Moore's law = transition to positive consumption.
-/
namespace Survival.MooresLawBridge
noncomputable section

/-- Moore's law: capability doubles every T₂ time units. -/
def mooreCapability (c₀ t doubling : ℝ) : ℝ :=
  c₀ * Real.exp (t * Real.log 2 / doubling)

/-- Exponential growth = negative structural consumption. -/
theorem moore_is_recovery (c₀ t doubling : ℝ)
    (hc : 0 < c₀) (ht : 0 < t) (hd : 0 < doubling) :
    c₀ < mooreCapability c₀ t doubling := by
  unfold mooreCapability
  calc c₀ = c₀ * 1 := (mul_one c₀).symm
    _ < c₀ * Real.exp (t * Real.log 2 / doubling) := by
        apply mul_lt_mul_of_pos_left _ hc
        exact Real.one_lt_exp_iff.mpr (by positivity)

/-- End of Moore's law = structural consumption rate turns positive. -/
theorem end_of_moore (growth_rate : ℝ) (h : growth_rate < 0) :
    0 < -growth_rate := by linarith

end
end Survival.MooresLawBridge
