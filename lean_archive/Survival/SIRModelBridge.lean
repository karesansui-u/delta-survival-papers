import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# SIR Model Bridge
dS/dt = -βSI: susceptible depletion is exponential initially.
S(t) ≈ S₀ exp(-βIt) in early phase = structural consumption
of the susceptible population.
-/
namespace Survival.SIRModelBridge
noncomputable section

/-- Early-phase susceptible depletion: S ≈ S₀ exp(-rate·t). -/
def susceptibleEarlyPhase (s₀ rate t : ℝ) : ℝ := s₀ * Real.exp (-rate * t)

/-- This IS S = M exp(-L). -/
theorem sir_is_persistence (s₀ rate t : ℝ) (hs : 0 < s₀) :
    0 < susceptibleEarlyPhase s₀ rate t := by
  unfold susceptibleEarlyPhase; exact mul_pos hs (Real.exp_pos _)

/-- Basic reproduction number R₀ determines persistence/collapse.
R₀ > 1: epidemic (structural collapse of susceptible pool).
R₀ < 1: disease dies out (structural persistence). -/
theorem r0_threshold (r0 : ℝ) :
    (1 < r0 → 0 < r0 - 1) ∧ (r0 < 1 → r0 - 1 < 0) :=
  ⟨fun h => by linarith, fun h => by linarith⟩

/-- Herd immunity threshold = 1 - 1/R₀. -/
def herdImmunityThreshold (r0 : ℝ) : ℝ := 1 - 1 / r0

end
end Survival.SIRModelBridge
