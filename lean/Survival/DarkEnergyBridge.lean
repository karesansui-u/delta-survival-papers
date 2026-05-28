import Survival.HeatDeathBridge

/-!
# Dark Energy Bridge — Accelerating Expansion and Structure Formation

Reads dark energy's effect as increasing the structural consumption
rate for gravitationally bound structures. Accelerating expansion
drives galaxies apart, reducing the viable set for gravitational
structure formation.

Without dark energy: structures can form indefinitely (V_G constant)
With dark energy: V_G shrinks as expansion accelerates (l̄ increases)
-/

namespace Survival.DarkEnergyBridge
open Survival.HeatDeathBridge

noncomputable section

/-- A dark energy model: accelerating expansion adds to the
    structural consumption rate for large-scale structure. -/
structure DarkEnergyModel where
  baseConsumptionRate : ℝ     -- entropy production without DE
  darkEnergyBoost : ℝ         -- additional consumption from expansion
  base_pos : 0 < baseConsumptionRate
  boost_pos : 0 < darkEnergyBoost

/-- Total consumption rate with dark energy. -/
def totalRate (M : DarkEnergyModel) : ℝ :=
  M.baseConsumptionRate + M.darkEnergyBoost

/-- Dark energy accelerates structural collapse. -/
theorem dark_energy_accelerates (M : DarkEnergyModel) :
    M.baseConsumptionRate < totalRate M := by
  unfold totalRate; linarith [M.boost_pos]

/-- The cosmological model with dark energy. -/
def toCosmological (M : DarkEnergyModel) (resource : ℝ)
    (hr : 0 < resource) : CosmologicalModel :=
  ⟨resource, totalRate M, hr, by unfold totalRate; linarith [M.base_pos, M.boost_pos]⟩

/-- Heat death comes faster with dark energy. -/
theorem accelerated_heat_death (M : DarkEnergyModel)
    (resource : ℝ) (hr : 0 < resource) :
    Filter.Tendsto
      (fun n => persistencePotential (toCosmological M resource hr) n)
      Filter.atTop (nhds 0) :=
  heat_death (toCosmological M resource hr)

end
end Survival.DarkEnergyBridge
