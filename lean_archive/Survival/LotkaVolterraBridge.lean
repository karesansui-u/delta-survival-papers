import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Lotka-Volterra Bridge
Predator-prey: dx/dt = αx - βxy, dy/dt = δxy - γy.
The conserved quantity H = δx - γ ln x + βy - α ln y connects
to structural persistence: ln terms = structural accounting.
-/
namespace Survival.LotkaVolterraBridge
noncomputable section

/-- Lotka-Volterra conserved quantity. -/
def conservedQuantity (alpha beta gamma delta x y : ℝ) : ℝ :=
  delta * x - gamma * Real.log x + beta * y - alpha * Real.log y

/-- The log terms are structural consumption readings. -/
theorem log_terms_are_consumption (x : ℝ) (hx : 0 < x) (gamma : ℝ) :
    -gamma * Real.log x = gamma * (-Real.log x) := by ring

/-- Population decline = positive structural consumption. -/
theorem decline_is_consumption {x₀ x₁ : ℝ} (h₀ : 0 < x₀) (h₁ : 0 < x₁) (hdec : x₁ < x₀) :
    0 < Real.log x₀ - Real.log x₁ :=
  sub_pos.mpr (Real.log_lt_log h₁ hdec)

end
end Survival.LotkaVolterraBridge
