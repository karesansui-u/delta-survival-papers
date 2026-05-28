import Survival.ErgodicRateBridge
/-!
# Plate Tectonics Bridge — Crustal Structure Maintenance
Plate tectonics as structural persistence: mantle convection
provides recovery (driving plate motion, recycling crust), while
cooling and subduction provide consumption. Continental crust
persists because recovery ≈ consumption over geological time.
-/
namespace Survival.TectonicsBridge
open Survival.ErgodicRateBridge
noncomputable section
structure TectonicModel where
  convectionRate : ℝ    -- recovery (mantle drives renewal)
  coolingRate : ℝ       -- consumption (radiative cooling)
  convection_pos : 0 < convectionRate
  cooling_pos : 0 < coolingRate

def tectonicBalance (M : TectonicModel) : ℝ := M.coolingRate - M.convectionRate

theorem active_tectonics (M : TectonicModel) (h : M.convectionRate > M.coolingRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨tectonicBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨tectonicBalance M⟩ (by unfold tectonicBalance; linarith) n

theorem dead_planet (M : TectonicModel) (h : M.coolingRate > M.convectionRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨tectonicBalance M⟩ n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨tectonicBalance M⟩ (by unfold tectonicBalance; linarith)
end
end Survival.TectonicsBridge
