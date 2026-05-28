import Survival.ArrowPrattBridge
/-!
# Diminishing Marginal Utility Bridge
u(w) = ln w: marginal utility u'(w) = 1/w, decreasing in w.
In SP: the structural consumption of each additional unit
decreases with wealth. This IS log-ratio loss.
-/
namespace Survival.DiminishingMarginalUtilityBridge
noncomputable section

/-- Log utility marginal: u'(w) = 1/w, decreasing. -/
theorem marginal_decreasing {w₁ w₂ : ℝ} (h₁ : 0 < w₁) (_h₂ : 0 < w₂) (h : w₁ < w₂) :
    1 / w₂ < 1 / w₁ :=
  one_div_lt_one_div_of_lt h₁ h

/-- Equal ratio changes cause equal utility changes (log property).
Δu = ln(w+Δw) - ln(w) = ln(1 + Δw/w) depends only on ratio. -/
theorem equal_ratio_equal_utility (w delta : ℝ) (hw : 0 < w) (hd : 0 < delta) :
    Real.log ((w + delta) / w) = Real.log (1 + delta / w) := by
  congr 1; field_simp [ne_of_gt hw]

end
end Survival.DiminishingMarginalUtilityBridge
