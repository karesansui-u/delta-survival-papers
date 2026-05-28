import Survival.FirstLawBridge
/-!
# Climate Radiative Forcing Bridge — Earth Energy Budget
Earth's climate as structural persistence: incoming solar radiation
= resource input, outgoing longwave = consumption. Greenhouse effect
= reduced consumption (trapping heat = structural recovery).
Radiative imbalance = net consumption rate.
-/
namespace Survival.ClimateRadiativeBridge
open Survival.FirstLawBridge
noncomputable section
structure ClimateModel where
  solarInput : ℝ        -- incoming solar (resource)
  outgoingRadiation : ℝ  -- outgoing longwave (consumption)
  solar_pos : 0 < solarInput
  outgoing_pos : 0 < outgoingRadiation

def radiativeImbalance (M : ClimateModel) : ℝ := M.solarInput - M.outgoingRadiation

theorem warming_when_positive (M : ClimateModel) (h : M.solarInput > M.outgoingRadiation) :
    0 < radiativeImbalance M := by unfold radiativeImbalance; linarith

theorem cooling_when_negative (M : ClimateModel) (h : M.outgoingRadiation > M.solarInput) :
    radiativeImbalance M < 0 := by unfold radiativeImbalance; linarith

theorem equilibrium_when_balanced (M : ClimateModel) (h : M.solarInput = M.outgoingRadiation) :
    radiativeImbalance M = 0 := by unfold radiativeImbalance; linarith
end
end Survival.ClimateRadiativeBridge
