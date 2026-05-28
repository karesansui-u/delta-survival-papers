import Survival.FalseVacuumBridge

/-!
# Nuclear Stability Bridge — Nuclear Chart and Drip Lines

Reads nuclear stability as structural persistence: stable nuclei
have barrier height > 0 (metastable against decay). The nuclear
drip lines mark the boundary where the barrier vanishes.

Stable nucleus: high barrier → low tunneling rate → long-lived
Unstable nucleus: low barrier → high tunneling rate → short-lived
Beyond drip line: zero barrier → immediate decay
-/

namespace Survival.NuclearStabilityBridge
open Survival.FalseVacuumBridge

noncomputable section

/-- A nucleus modeled as a metastable structure with barrier
    determined by binding energy. -/
def stableNucleus (bindingEnergy : ℝ) (h : 0 < bindingEnergy) :
    MetastableStructure :=
  ⟨bindingEnergy, h⟩

/-- More tightly bound → more stable (lower tunneling rate). -/
theorem tighter_binding_more_stable
    (E₁ E₂ : ℝ) (h₁ : 0 < E₁) (h₂ : 0 < E₂) (hlt : E₁ < E₂) :
    tunnelingRate (stableNucleus E₂ h₂) <
      tunnelingRate (stableNucleus E₁ h₁) :=
  higher_barrier_more_stable ⟨E₁, h₁⟩ ⟨E₂, h₂⟩ hlt

/-- Every unstable nucleus eventually decays. -/
theorem unstable_decays (E : ℝ) (h : 0 < E) :
    Filter.Tendsto (fun n => retention (stableNucleus E h) n)
      Filter.atTop (nhds 0) :=
  false_vacuum_decays ⟨E, h⟩

end
end Survival.NuclearStabilityBridge
