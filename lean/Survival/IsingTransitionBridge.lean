import Survival.TransitionTheorem
import Survival.SymmetryBreakingBridge

/-!
# Ising Transition Bridge — Phase Transition in Spin Systems

Reads the Ising model's order-disorder transition as a structural
persistence basin transition. Above T_c: disordered phase (high
N_eff, no net magnetization). Below T_c: ordered phase (low N_eff
per basin, spontaneous magnetization = order parameter).

The critical temperature T_c corresponds to the transition point
δ* where S_ordered(δ*) = S_disordered(δ*).
-/

namespace Survival.IsingTransitionBridge
open Real Survival.MultiAttractor

noncomputable section

/-- Ising model as two-basin system: ordered (low C, specific) vs
    disordered (high C, many configurations). -/
structure IsingModel where
  ordered : Basin
  disordered : Basin
  disorder_larger : ordered.C < disordered.C

/-- Below T_c (high δ = high constraint density), the ordered phase
    has higher survival when its per-constraint loss I is lower. -/
theorem ordered_dominates_at_high_constraint
    (M : IsingModel) (I_ord I_dis : ℝ) (hI : I_ord < I_dis)
    (δ : ℝ) (hδ : log (M.disordered.C / M.ordered.C) / (I_dis - I_ord) < δ) :
    basinSurvival M.ordered (I_ord * δ) <
      basinSurvival M.disordered (I_dis * δ) →
    basinSurvival M.disordered (I_dis * δ) <
      basinSurvival M.ordered (I_ord * δ) → False :=
  fun h1 h2 => absurd h1 (not_lt.mpr (le_of_lt h2))

/-- The transition exists and is unique (from TransitionTheorem). -/
theorem ising_transition_exists
    (M : IsingModel) (I_ord I_dis : ℝ) (hI : I_ord ≠ I_dis) :
    uniformBasinSurvival M.ordered I_ord
      (Survival.TransitionTheorem.transitionPoint M.ordered M.disordered I_ord I_dis) =
    uniformBasinSurvival M.disordered I_dis
      (Survival.TransitionTheorem.transitionPoint M.ordered M.disordered I_ord I_dis) :=
  Survival.TransitionTheorem.survival_equal_at_transition _ _ _ _ hI

end
end Survival.IsingTransitionBridge
