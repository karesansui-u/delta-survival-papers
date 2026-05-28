import Survival.FixedPointBridge
/-!
# Hebbian Learning Bridge — "Fire Together, Wire Together"
Hebbian learning as structural recovery: correlated neural firing
strengthens synapses (recovery), while uncorrelated activity and
decay weaken them (consumption). The learned structure persists
when Hebbian recovery ≥ decay consumption.
-/
namespace Survival.HebbianBridge
open Survival.ErgodicRateBridge
noncomputable section
structure HebbianModel where
  strengtheningRate : ℝ  -- recovery (correlated firing)
  decayRate : ℝ          -- consumption (synaptic decay)
  strengthen_nonneg : 0 ≤ strengtheningRate
  decay_pos : 0 < decayRate

def synapticBalance (M : HebbianModel) : ℝ := M.decayRate - M.strengtheningRate

theorem learning_persists (M : HebbianModel) (h : M.strengtheningRate ≥ M.decayRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨synapticBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨synapticBalance M⟩ (by unfold synapticBalance; linarith) n

theorem forgetting_collapses (M : HebbianModel) (h : M.decayRate > M.strengtheningRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨synapticBalance M⟩ n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨synapticBalance M⟩ (by unfold synapticBalance; linarith)
end
end Survival.HebbianBridge
