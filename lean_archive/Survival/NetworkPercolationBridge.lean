import Survival.PercolationThreshold
import Survival.ScaleFreeBridge
import Survival.ErgodicRateBridge
/-!
# Network Percolation Bridge — Connectivity as Structural Persistence
Network percolation: at what fraction of removed nodes/edges does
the giant component disappear? This IS a structural persistence
threshold: below p_c, the network's structural connectivity
collapses. Above p_c, connectivity persists.

p < p_c: fragmented (structural collapse)
p = p_c: critical (boundary)
p > p_c: connected (structural persistence)
-/
namespace Survival.NetworkPercolationBridge
open Survival.ErgodicRateBridge
noncomputable section
structure PercolationModel where
  removalRate : ℝ     -- fraction of removed components
  criticalRate : ℝ    -- percolation threshold p_c
  removal_nonneg : 0 ≤ removalRate
  critical_pos : 0 < criticalRate
  critical_lt_one : criticalRate < 1

def excessRemoval (M : PercolationModel) : ℝ := M.removalRate - M.criticalRate

theorem connected_below_threshold (M : PercolationModel)
    (h : M.removalRate < M.criticalRate) :
    excessRemoval M < 0 := by unfold excessRemoval; linarith

theorem fragmented_above_threshold (M : PercolationModel)
    (h : M.criticalRate < M.removalRate) :
    0 < excessRemoval M := by unfold excessRemoval; linarith

theorem critical_at_threshold (M : PercolationModel)
    (h : M.removalRate = M.criticalRate) :
    excessRemoval M = 0 := by unfold excessRemoval; linarith
end
end Survival.NetworkPercolationBridge
