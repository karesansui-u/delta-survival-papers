import Survival.ErgodicRateBridge
/-!
# Le Chatelier Bridge — Chemical Equilibrium Perturbation
Perturbation of chemical equilibrium shifts the system to oppose
the change. Structural reading: disturbing V_G triggers recovery
r_t that partially compensates the consumption d_t, restoring
balance. Le Chatelier = negative feedback in structural accounting.
-/
namespace Survival.LeChatelierBridge
open Survival.ErgodicRateBridge
noncomputable section
structure ChemicalEquilibriumModel where
  perturbation : ℝ   -- consumption from external disturbance
  feedback : ℝ        -- recovery from Le Chatelier response
  pert_pos : 0 < perturbation
  feedback_pos : 0 < feedback
  partial_compensation : feedback < perturbation  -- never fully compensates

def netShift (M : ChemicalEquilibriumModel) : ℝ := M.perturbation - M.feedback

theorem net_shift_pos (M : ChemicalEquilibriumModel) : 0 < netShift M := by
  unfold netShift; linarith [M.partial_compensation]

theorem feedback_reduces_consumption (M : ChemicalEquilibriumModel) :
    netShift M < M.perturbation := by
  unfold netShift; linarith [M.feedback_pos]
end
end Survival.LeChatelierBridge
