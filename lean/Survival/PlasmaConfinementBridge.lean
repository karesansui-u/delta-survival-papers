import Survival.ErgodicRateBridge

/-!
# Plasma Confinement Bridge — Fusion Energy Confinement Time

Reads plasma confinement as structural persistence: the confined
plasma state is maintained as long as energy confinement time τ_E
exceeds the loss rate. The Lawson criterion n·τ_E > threshold
is a structural persistence condition.
-/

namespace Survival.PlasmaConfinementBridge
open Survival.ErgodicRateBridge

noncomputable section

structure PlasmaModel where
  heatingRate : ℝ     -- recovery (external heating + fusion)
  lossRate : ℝ        -- consumption (radiation + transport)
  heating_pos : 0 < heatingRate
  loss_pos : 0 < lossRate

def netEnergyLoss (M : PlasmaModel) : ℝ := M.lossRate - M.heatingRate

theorem confined_persists (M : PlasmaModel)
    (h : M.heatingRate > M.lossRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netEnergyLoss M⟩ n :=
  persistence_of_nonpositive_rate ⟨netEnergyLoss M⟩
    (by unfold netEnergyLoss; linarith) n

theorem unconfined_collapses (M : PlasmaModel)
    (h : M.lossRate > M.heatingRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netEnergyLoss M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netEnergyLoss M⟩
    (by unfold netEnergyLoss; linarith)

theorem lawson_criterion (M : PlasmaModel)
    (h : M.heatingRate = M.lossRate) (n : ℕ) :
    constantRateRetention ⟨netEnergyLoss M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netEnergyLoss M⟩
    (by unfold netEnergyLoss; linarith) n

end
end Survival.PlasmaConfinementBridge
