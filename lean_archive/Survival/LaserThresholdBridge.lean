import Survival.ErgodicRateBridge

/-!
# Laser Threshold Bridge — Coherence Maintenance

Reads laser operation as structural persistence of coherent photon
states. Below threshold: spontaneous emission dominates (consumption
> recovery), coherence collapses. Above threshold: stimulated
emission dominates (recovery > consumption), coherence persists.
-/

namespace Survival.LaserThresholdBridge
open Survival.ErgodicRateBridge

noncomputable section

structure LaserModel where
  stimulatedRate : ℝ   -- recovery (coherent amplification)
  spontaneousRate : ℝ  -- consumption (decoherence)
  cavityLoss : ℝ       -- additional consumption
  stimulated_nonneg : 0 ≤ stimulatedRate
  spontaneous_pos : 0 < spontaneousRate
  loss_pos : 0 < cavityLoss

def netCoherenceLoss (M : LaserModel) : ℝ :=
  M.spontaneousRate + M.cavityLoss - M.stimulatedRate

theorem below_threshold_decoherence (M : LaserModel)
    (h : M.stimulatedRate < M.spontaneousRate + M.cavityLoss) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netCoherenceLoss M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netCoherenceLoss M⟩
    (by unfold netCoherenceLoss; linarith)

theorem above_threshold_coherence (M : LaserModel)
    (h : M.spontaneousRate + M.cavityLoss < M.stimulatedRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netCoherenceLoss M⟩ n :=
  persistence_of_nonpositive_rate ⟨netCoherenceLoss M⟩
    (by unfold netCoherenceLoss; linarith) n

theorem at_threshold (M : LaserModel)
    (h : M.stimulatedRate = M.spontaneousRate + M.cavityLoss) (n : ℕ) :
    constantRateRetention ⟨netCoherenceLoss M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netCoherenceLoss M⟩
    (by unfold netCoherenceLoss; linarith) n

end
end Survival.LaserThresholdBridge
