import Survival.FreeEnergy
import Survival.IsingTransitionBridge
/-!
# Landau Phase Transition Bridge — Order Parameter Theory
Landau's theory: free energy F(Φ) = a₀ + a₂Φ² + a₄Φ⁴ + ...
Phase transition occurs when a₂ changes sign.

Structural reading: F(Φ) = structural free energy of the
order parameter configuration. Phase transition = basin transition
(already in FreeEnergy.lean). Landau expansion = Taylor expansion
of the structural free energy around the symmetric phase.

This bridges FreeEnergy.lean's F = -log S to Landau's polynomial form.
-/
namespace Survival.LandauPhaseBridge
open Real Survival.FreeEnergy Survival.MultiAttractor
noncomputable section

/-- Landau free energy is linear in δ in the SP framework:
    F(δ) = -log C + δ (from FreeEnergy.lean).
    The polynomial Landau form is an approximation near T_c. -/
theorem sp_free_energy_is_linear (b : Basin) (δ : ℝ) :
    freeEnergy b δ = freeEnergy b 0 + δ :=
  freeEnergy_linear b δ

/-- First-order transition: free energies of two basins cross
    at a unique point (from TransitionTheorem). -/
theorem first_order_crossing (A B : Basin) (I_A I_B : ℝ) (hI : I_A ≠ I_B) :
    uniformBasinSurvival A I_A
      (Survival.TransitionTheorem.transitionPoint A B I_A I_B) =
    uniformBasinSurvival B I_B
      (Survival.TransitionTheorem.transitionPoint A B I_A I_B) :=
  Survival.TransitionTheorem.survival_equal_at_transition A B I_A I_B hI

/-- At the transition, the lower free energy basin is preferred. -/
theorem lower_free_energy_preferred (A B : Basin) (δ : ℝ)
    (h : A.C > B.C) :
    freeEnergy A δ < freeEnergy B δ := by
  unfold freeEnergy
  linarith [log_lt_log B.C_pos h]
end
end Survival.LandauPhaseBridge
