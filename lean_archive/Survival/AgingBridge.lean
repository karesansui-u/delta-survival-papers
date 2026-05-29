import Survival.ErgodicRateBridge
import Survival.DNAReplicationBridge
/-!
# Biological Aging Bridge — Senescence as Structural Consumption
Biological aging as structural persistence: cellular damage
accumulates (consumption), while repair mechanisms (DNA repair,
autophagy, stem cell renewal) provide recovery. Aging = the
regime where consumption gradually exceeds recovery.

Gompertz law: mortality rate ∝ exp(bt) → structural consumption
rate increases with age. This accelerates collapse.
-/
namespace Survival.AgingBridge
open Real Survival.ErgodicRateBridge
noncomputable section
structure AgingModel where
  baseDamageRate : ℝ     -- baseline consumption
  repairCapacity : ℝ     -- recovery capacity (decreases with age)
  base_pos : 0 < baseDamageRate
  repair_pos : 0 < repairCapacity

def youthfulBalance (M : AgingModel) : ℝ := M.baseDamageRate - M.repairCapacity

/-- Youth: repair > damage → structural persistence. -/
theorem youth_persists (M : AgingModel) (h : M.repairCapacity > M.baseDamageRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨youthfulBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨youthfulBalance M⟩ (by unfold youthfulBalance; linarith) n

/-- Senescence: damage > repair → structural collapse. -/
theorem senescence_collapses (M : AgingModel) (h : M.baseDamageRate > M.repairCapacity) :
    Filter.Tendsto (fun n => constantRateRetention ⟨youthfulBalance M⟩ n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨youthfulBalance M⟩ (by unfold youthfulBalance; linarith)

/-- Hayflick limit: when repair capacity = 0, collapse rate = base damage rate. -/
theorem hayflick_limit (M : AgingModel) (h : M.repairCapacity = 0) :
    youthfulBalance M = M.baseDamageRate := by
  unfold youthfulBalance; linarith
end
end Survival.AgingBridge
