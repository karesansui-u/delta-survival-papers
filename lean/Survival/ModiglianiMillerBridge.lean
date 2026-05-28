import Survival.SeparationTheorem
/-!
# Modigliani-Miller Bridge — Capital Structure Irrelevance
MM theorem: in perfect markets, firm value is independent of
capital structure (debt vs equity). Structural reading: the
structural persistence S = M exp(-L) depends on M (total
resources) and L (structural consumption), not on how M is
decomposed (debt vs equity). This is the Separation Theorem
applied to corporate finance.
-/
namespace Survival.ModiglianiMillerBridge
noncomputable section
/-- A firm's capital structure: debt + equity = total. -/
structure CapitalStructure where
  debt : ℝ
  equity : ℝ
  debt_nonneg : 0 ≤ debt
  equity_nonneg : 0 ≤ equity

def totalCapital (C : CapitalStructure) : ℝ := C.debt + C.equity

/-- MM irrelevance: firm value depends on total capital, not split. -/
theorem mm_irrelevance (C₁ C₂ : CapitalStructure)
    (h : totalCapital C₁ = totalCapital C₂) (L : ℝ) :
    totalCapital C₁ * Real.exp (-L) = totalCapital C₂ * Real.exp (-L) := by
  rw [h]

/-- Restructuring (changing debt/equity ratio) doesn't change S. -/
theorem restructuring_preserves_value (d₁ e₁ d₂ e₂ : ℝ)
    (h : d₁ + e₁ = d₂ + e₂) (L : ℝ) :
    (d₁ + e₁) * Real.exp (-L) = (d₂ + e₂) * Real.exp (-L) := by
  rw [h]
end
end Survival.ModiglianiMillerBridge
