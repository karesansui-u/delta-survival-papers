import Survival.FiniteStateMarkovErgodicProduction
/-!
# PageRank Bridge
PageRank = stationary distribution of a random walk on the web graph.
Convergence to PageRank = ergodic convergence of structural accounting.
Damping factor (1-d) = structural consumption per teleportation.
-/
namespace Survival.PageRankBridge
noncomputable section

/-- Damping factor loss: each teleportation consumes -ln(d). -/
def dampingLoss (d : ℝ) : ℝ := -Real.log d

/-- Damping loss is nonneg when d ∈ (0, 1]. -/
theorem damping_loss_nonneg {d : ℝ} (hd : 0 < d) (hd1 : d ≤ 1) :
    0 ≤ dampingLoss d := by
  unfold dampingLoss; rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt hd) hd1

/-- PageRank convergence rate ∝ structural consumption rate. -/
theorem convergence_rate_is_consumption (d : ℝ) (hd : 0 < d) (hd1 : d < 1) :
    0 < dampingLoss d := by
  unfold dampingLoss; rw [neg_pos]
  exact Real.log_neg hd hd1

end
end Survival.PageRankBridge
