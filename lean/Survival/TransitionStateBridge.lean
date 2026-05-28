import Survival.FalseVacuumBridge
/-!
# Transition State Theory Bridge — Eyring Equation
Eyring: k = (kT/h)exp(-ΔG‡/RT). The activation barrier ΔG‡ is the
structural consumption required to reach the transition state.
Higher barrier → slower reaction → more stable reactants.
Same exp(-barrier) as FalseVacuumBridge.
-/
namespace Survival.TransitionStateBridge
open Real Survival.FalseVacuumBridge
noncomputable section
structure EyringModel where
  activationBarrier : ℝ  -- ΔG‡ / RT (dimensionless)
  barrier_pos : 0 < activationBarrier

def reactionRate (M : EyringModel) : ℝ := exp (-M.activationBarrier)
theorem rate_pos (M : EyringModel) : 0 < reactionRate M := exp_pos _
theorem rate_lt_one (M : EyringModel) : reactionRate M < 1 := by
  unfold reactionRate; rw [exp_lt_one_iff]; linarith [M.barrier_pos]
theorem higher_barrier_slower (M₁ M₂ : EyringModel) (h : M₁.activationBarrier < M₂.activationBarrier) :
    reactionRate M₂ < reactionRate M₁ := by
  unfold reactionRate; exact exp_lt_exp.mpr (by linarith)
end
end Survival.TransitionStateBridge
