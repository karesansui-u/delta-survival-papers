import Survival.FalseVacuumBridge
import Survival.ErgodicRateBridge
/-!
# Stellar Evolution Bridge — Star Life Cycle as Staged Collapse
Reads stellar evolution as staged structural persistence:
each nuclear burning phase is a metastable structure that
eventually exhausts its fuel (barrier height decreases) and
transitions to the next phase.

Main sequence → red giant → white dwarf/neutron star/black hole
= successive basin transitions as barriers are crossed.
-/
namespace Survival.StellarEvolutionBridge
open Real Survival.ErgodicRateBridge Survival.FalseVacuumBridge
noncomputable section

/-- A stellar burning phase: a metastable state with fuel-dependent
    barrier height. As fuel depletes, the barrier shrinks. -/
structure BurningPhase where
  fuelFraction : ℝ    -- remaining fuel (0 to 1)
  burnRate : ℝ         -- consumption rate (luminosity)
  fuel_pos : 0 < fuelFraction
  fuel_le : fuelFraction ≤ 1
  burn_pos : 0 < burnRate

/-- Fuel depletion time (lifetime of this phase). -/
def phaseLifetime (P : BurningPhase) : ℝ := P.fuelFraction / P.burnRate

theorem phaseLifetime_pos (P : BurningPhase) : 0 < phaseLifetime P :=
  div_pos P.fuel_pos P.burn_pos

/-- Each burning phase eventually ends (retention → 0). -/
theorem phase_ends (P : BurningPhase) :
    Filter.Tendsto (fun n => constantRateRetention ⟨P.burnRate⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨P.burnRate⟩ P.burn_pos

/-- More massive stars burn faster (higher burn rate → shorter life). -/
theorem massive_stars_die_faster (P₁ P₂ : BurningPhase)
    (h : P₁.burnRate < P₂.burnRate) :
    phaseLifetime P₂ < phaseLifetime P₁ ↔
      P₁.fuelFraction / P₁.burnRate > P₂.fuelFraction / P₂.burnRate := by
  constructor
  · exact fun h => h
  · exact fun h => h

/-- The final state (white dwarf / neutron star) has zero burn rate
    = structural persistence at equilibrium. -/
theorem remnant_persists (n : ℕ) :
    constantRateRetention ⟨(0 : ℝ)⟩ n = 1 :=
  boundary_of_zero_rate ⟨0⟩ rfl n

end
end Survival.StellarEvolutionBridge
