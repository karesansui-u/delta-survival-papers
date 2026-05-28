import Survival.ErgodicRateBridge
import Survival.FixedPointBridge

/-!
# Superconductivity Bridge — BCS Cooper Pair Condensation

Reads BCS superconductivity as structural persistence with net
recovery exceeding consumption below T_c. Cooper pair condensation
= recovery mechanism that stabilizes the superconducting order.

Above T_c: pair-breaking rate > pair-formation rate → b > 0 → collapse
Below T_c: pair-formation > pair-breaking → b < 0 → persistence
At T_c: b = 0 → structural equilibrium (fixed point)
-/

namespace Survival.SuperconductivityBridge
open Real Survival.ErgodicRateBridge

noncomputable section

structure BCSModel where
  pairFormationRate : ℝ  -- recovery r
  pairBreakingRate : ℝ   -- damage d
  formation_pos : 0 < pairFormationRate
  breaking_pos : 0 < pairBreakingRate

def netConsumption (M : BCSModel) : ℝ := M.pairBreakingRate - M.pairFormationRate

theorem superconducting_persists (M : BCSModel)
    (h : M.pairFormationRate > M.pairBreakingRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netConsumption M⟩ n :=
  persistence_of_nonpositive_rate ⟨netConsumption M⟩
    (by unfold netConsumption; linarith) n

theorem normal_collapses (M : BCSModel)
    (h : M.pairBreakingRate > M.pairFormationRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netConsumption M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netConsumption M⟩
    (by unfold netConsumption; linarith)

theorem critical_equilibrium (M : BCSModel)
    (h : M.pairFormationRate = M.pairBreakingRate) (n : ℕ) :
    constantRateRetention ⟨netConsumption M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netConsumption M⟩
    (by unfold netConsumption; linarith) n

end
end Survival.SuperconductivityBridge
