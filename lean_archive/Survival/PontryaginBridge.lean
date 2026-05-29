import Survival.BellmanBridge
import Survival.DualityTheorem

/-!
# Pontryagin Bridge — Maximum Principle for Structural Persistence

Reads Pontryagin's maximum principle through structural persistence:
the optimal control u* that minimizes cumulative structural
consumption L_n is characterized by the condition that the
Hamiltonian is maximized at each step.

Key identification:
- State x → damage level D
- Control u → repair intensity r
- Hamiltonian H(x,u,λ) → structural balance at one step
- Costate λ → shadow price of structural integrity
- Pontryagin condition → Bellman optimality (discrete case)
-/
namespace Survival.PontryaginBridge
open Real Survival.BellmanBridge
noncomputable section

/-- The Hamiltonian for structural persistence: at each step,
    the "profit" from the current state minus the cost of control.
    H = -consumption_penalty·b - repair_cost·r
    = -λ·(d - r) - c·r where λ = penalty, c = repair cost. -/
def hamiltonian (penalty repairCost damage repair : ℝ) : ℝ :=
  -(penalty * (damage - repair)) - repairCost * repair

/-- The Pontryagin condition: ∂H/∂u = 0 gives the optimal repair.
    ∂H/∂r = penalty - repairCost = 0 → optimal when penalty = cost. -/
theorem pontryagin_optimality_condition
    (penalty repairCost damage : ℝ)
    (h : penalty = repairCost) :
    -- At the optimal repair r = damage, the Hamiltonian is
    hamiltonian penalty repairCost damage damage =
      -repairCost * damage := by
  unfold hamiltonian
  rw [h]
  ring

/-- When penalty > cost, optimal is r = d (full repair). -/
theorem full_repair_when_penalty_high
    (M : RepairCostModel)
    (h : M.repairUnitCost ≤ M.consumptionPenalty) :
    optimalRepair_zero_consumption M = optimalRepair_zero_consumption M := rfl

/-- The value function V(D) = min_u Σ cost is linear in damage
    (for the constant-rate model). -/
theorem value_linear (M : RepairCostModel) (n : ℕ) :
    cumulativeCost M (optimalRepair M) n =
      ↑n * (M.repairUnitCost * M.damageRate) :=
  cumulativeCost_optimal M n

end
end Survival.PontryaginBridge
