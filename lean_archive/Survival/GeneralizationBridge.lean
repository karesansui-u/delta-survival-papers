import Survival.ErgodicRateBridge
import Survival.LargeDeviationBridge

/-!
# Generalization Bridge — Neural Network Overfitting as Structural Collapse

Reads ML generalization through structural persistence:
overfitting = structural collapse of generalization capability.

Key identification:
- Generalization gap = structural consumption rate l̄
- Training = recovery (fitting useful patterns)
- Overfitting = consumption (fitting noise, losing generalizability)
- Regularization = repair mechanism (keeps V_G large)
- Early stopping = stopping before L accumulates too much
-/
namespace Survival.GeneralizationBridge
open Survival.ErgodicRateBridge
noncomputable section

structure MLModel where
  overfitRate : ℝ      -- consumption (fitting noise)
  learnRate : ℝ         -- recovery (fitting signal)
  overfit_nonneg : 0 ≤ overfitRate
  learn_nonneg : 0 ≤ learnRate

def generalizationLoss (M : MLModel) : ℝ := M.overfitRate - M.learnRate

/-- Underfitting regime: learning > overfitting → generalization improves. -/
theorem underfitting_improves (M : MLModel)
    (h : M.learnRate > M.overfitRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨generalizationLoss M⟩ n :=
  persistence_of_nonpositive_rate ⟨generalizationLoss M⟩
    (by unfold generalizationLoss; linarith) n

/-- Overfitting regime: overfitting > learning → generalization collapses. -/
theorem overfitting_collapses (M : MLModel)
    (h : M.overfitRate > M.learnRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨generalizationLoss M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨generalizationLoss M⟩
    (by unfold generalizationLoss; linarith)

/-- Optimal stopping: at the point where learning = overfitting. -/
theorem optimal_stopping (M : MLModel)
    (h : M.overfitRate = M.learnRate) (n : ℕ) :
    constantRateRetention ⟨generalizationLoss M⟩ n = 1 :=
  boundary_of_zero_rate ⟨generalizationLoss M⟩
    (by unfold generalizationLoss; linarith) n

end
end Survival.GeneralizationBridge
