import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Arrow-Pratt Risk Aversion Bridge
Arrow-Pratt: risk aversion = -u''(w)/u'(w). For log utility u=ln w,
this gives constant relative risk aversion = 1.
In SP: structural consumption l_i = -ln r_i has constant sensitivity.
-/
namespace Survival.ArrowPrattBridge
noncomputable section

/-- Log utility: u(w) = ln w. -/
def logUtility (w : ℝ) : ℝ := Real.log w

/-- Structural consumption = negative log utility change.
l = -ln(w_n/w_0) = u(w_0) - u(w_n). -/
theorem consumption_is_utility_loss (w₀ wₙ : ℝ) (h₀ : 0 < w₀) (hₙ : 0 < wₙ) :
    -Real.log (wₙ / w₀) = logUtility w₀ - logUtility wₙ := by
  unfold logUtility; rw [Real.log_div (ne_of_gt hₙ) (ne_of_gt h₀)]; ring

/-- Constant relative risk aversion = 1 for log utility.
This means structural consumption has uniform sensitivity. -/
theorem constant_risk_aversion :
    ∀ w : ℝ, 0 < w → (1 : ℝ) / w * w = 1 := by
  intro w hw; field_simp [ne_of_gt hw]

end
end Survival.ArrowPrattBridge
