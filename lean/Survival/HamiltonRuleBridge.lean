import Survival.GameTheoryBridge
/-!
# Hamilton's Rule Bridge — Kin Selection as Structural Cooperation
Hamilton's rule: altruism evolves when rB > C, where r = relatedness,
B = benefit to recipient, C = cost to actor.

Structural reading: altruistic structural consumption (C) is
recovered through kin's structural persistence (rB). Net balance
b = C - rB. Altruism persists iff rB > C (net recovery).
-/
namespace Survival.HamiltonRuleBridge
open Survival.ErgodicRateBridge
noncomputable section
structure KinSelectionModel where
  relatedness : ℝ   -- r (genetic relatedness, 0 to 1)
  benefit : ℝ        -- B (benefit to recipient)
  cost : ℝ           -- C (cost to actor)
  r_nonneg : 0 ≤ relatedness
  r_le_one : relatedness ≤ 1
  benefit_pos : 0 < benefit
  cost_pos : 0 < cost

/-- Net structural consumption of altruism. -/
def altruismBalance (M : KinSelectionModel) : ℝ := M.cost - M.relatedness * M.benefit

/-- Hamilton's rule: altruism persists iff rB > C. -/
theorem altruism_persists (M : KinSelectionModel)
    (h : M.relatedness * M.benefit > M.cost) (n : ℕ) :
    1 ≤ constantRateRetention ⟨altruismBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨altruismBalance M⟩
    (by unfold altruismBalance; linarith) n

/-- Selfishness wins when rB < C. -/
theorem selfishness_wins (M : KinSelectionModel)
    (h : M.cost > M.relatedness * M.benefit) :
    Filter.Tendsto (fun n => constantRateRetention ⟨altruismBalance M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨altruismBalance M⟩
    (by unfold altruismBalance; linarith)
end
end Survival.HamiltonRuleBridge
