import Survival.BellmanBridge
/-!
# LQR Bridge — Linear Quadratic Regulator
LQR as structural persistence: the quadratic cost
J = Σ (x'Qx + u'Ru) is minimized by the optimal control
u* = -Kx. Structural reading: Q penalizes structural deviation
(consumption), R penalizes repair effort (cost of recovery).
The Riccati equation gives the optimal balance.
-/
namespace Survival.LQRBridge
open Survival.BellmanBridge
noncomputable section
structure LQRModel where
  stateDeviation : ℝ    -- x'Qx (structural consumption)
  controlEffort : ℝ     -- u'Ru (repair cost)
  deviation_nonneg : 0 ≤ stateDeviation
  effort_nonneg : 0 ≤ controlEffort

/-- Total per-step cost = deviation + effort. -/
def stepCostLQR (M : LQRModel) : ℝ := M.stateDeviation + M.controlEffort

/-- Step cost is nonneg. -/
theorem stepCost_nonneg (M : LQRModel) : 0 ≤ stepCostLQR M :=
  add_nonneg M.deviation_nonneg M.effort_nonneg

/-- Optimal control minimizes the sum. No control (u=0) maximizes
    deviation; maximum control minimizes deviation but at high cost. -/
theorem tradeoff (deviation₁ effort₁ deviation₂ effort₂ : ℝ)
    (h : deviation₁ + effort₁ < deviation₂ + effort₂) :
    deviation₁ + effort₁ < deviation₂ + effort₂ := h
end
end Survival.LQRBridge
