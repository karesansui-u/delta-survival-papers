import Survival.FalseVacuumBridge
/-!
# Hodgkin-Huxley Bridge — Action Potential as Metastable Transition
The resting membrane potential is a metastable state. An action
potential is a structural transition: the membrane's ionic
configuration transitions from resting → depolarized → repolarized.
Same basin-transition structure as FalseVacuumBridge.
-/
namespace Survival.HodgkinHuxleyBridge
open Survival.FalseVacuumBridge
noncomputable section
structure ActionPotentialModel where
  restingBarrier : ℝ  -- threshold for depolarization
  barrier_pos : 0 < restingBarrier

def toMetastable (M : ActionPotentialModel) : MetastableStructure := ⟨M.restingBarrier, M.barrier_pos⟩

theorem resting_is_metastable (M : ActionPotentialModel) :
    0 < tunnelingRate (toMetastable M) ∧ tunnelingRate (toMetastable M) < 1 :=
  ⟨tunnelingRate_pos _, tunnelingRate_lt_one _⟩

theorem higher_threshold_more_stable (M₁ M₂ : ActionPotentialModel) (h : M₁.restingBarrier < M₂.restingBarrier) :
    tunnelingRate (toMetastable M₂) < tunnelingRate (toMetastable M₁) :=
  higher_barrier_more_stable _ _ h
end
end Survival.HodgkinHuxleyBridge
