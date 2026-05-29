import Survival.ErgodicRateBridge
/-!
# Forgetting Curve Bridge — Ebbinghaus R(t) = exp(-t/τ)
Ebbinghaus's forgetting curve R(t) = exp(-t/S) where S is memory
strength. This IS the structural persistence kernel S = M exp(-L)
with L = t/S. Memory rehearsal = recovery r_t that resets L.
-/
namespace Survival.ForgettingCurveBridge
open Real Survival.ErgodicRateBridge
noncomputable section
structure MemoryModel where
  decayRate : ℝ   -- 1/S (inverse memory strength)
  decay_pos : 0 < decayRate

def memoryRetention (M : MemoryModel) (n : ℕ) : ℝ :=
  constantRateRetention ⟨M.decayRate⟩ n

theorem memory_decays (M : MemoryModel) :
    Filter.Tendsto (fun n => memoryRetention M n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨M.decayRate⟩ M.decay_pos

theorem stronger_memory_slower_decay (M₁ M₂ : MemoryModel)
    (h : M₁.decayRate < M₂.decayRate) (n : ℕ) (hn : 0 < n) :
    memoryRetention M₂ n < memoryRetention M₁ n := by
  unfold memoryRetention constantRateRetention ConstantRateModel.cumulative
  apply exp_lt_exp.mpr
  have : (0 : ℝ) < ↑n := Nat.cast_pos.mpr hn
  nlinarith
end
end Survival.ForgettingCurveBridge
