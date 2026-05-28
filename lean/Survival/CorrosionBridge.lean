import Survival.ErgodicRateBridge
/-!
# Corrosion Bridge — Material Degradation Rate
Corrosion as structural consumption: the material's viable
configuration space shrinks as chemical attack proceeds.
Passivation = recovery (protective oxide layer).
Active corrosion = consumption > recovery → collapse.
-/
namespace Survival.CorrosionBridge
open Survival.ErgodicRateBridge
noncomputable section
structure CorrosionModel where
  attackRate : ℝ        -- consumption (chemical attack)
  passivationRate : ℝ   -- recovery (protective layer)
  attack_pos : 0 < attackRate
  passivation_nonneg : 0 ≤ passivationRate

def netCorrosion (M : CorrosionModel) : ℝ := M.attackRate - M.passivationRate

theorem passivated_persists (M : CorrosionModel) (h : M.passivationRate ≥ M.attackRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netCorrosion M⟩ n :=
  persistence_of_nonpositive_rate ⟨netCorrosion M⟩ (by unfold netCorrosion; linarith) n

theorem active_corrosion (M : CorrosionModel) (h : M.attackRate > M.passivationRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netCorrosion M⟩ n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netCorrosion M⟩ (by unfold netCorrosion; linarith)
end
end Survival.CorrosionBridge
