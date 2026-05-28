import Survival.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Rubber Elasticity Bridge — Entropic Elasticity

Reads entropy-driven elasticity as structural persistence: a
polymer's configurational entropy = log m(V) where V is the set
of accessible conformations. Stretching reduces V (fewer
configurations), increasing structural consumption.

Relaxed: m(V) = N_eff (many conformations)
Stretched: m(V) decreases → l = -log(m_stretched/m_relaxed) > 0
Elastic restoring force ∝ structural consumption rate
-/

namespace Survival.RubberElasticityBridge
open Real

noncomputable section

structure PolymerModel where
  relaxedConfigurations : ℝ  -- m(V) in relaxed state
  stretchedConfigurations : ℝ -- m(V) after stretching
  relaxed_pos : 0 < relaxedConfigurations
  stretched_pos : 0 < stretchedConfigurations
  stretched_le : stretchedConfigurations ≤ relaxedConfigurations

/-- Structural consumption from stretching. -/
def stretchingLoss (M : PolymerModel) : ℝ :=
  -log (M.stretchedConfigurations / M.relaxedConfigurations)

/-- Stretching loss is nonneg (fewer configurations = positive consumption). -/
theorem stretchingLoss_nonneg (M : PolymerModel) :
    0 ≤ stretchingLoss M := by
  unfold stretchingLoss
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos M.stretched_pos M.relaxed_pos))
    ((div_le_one₀ M.relaxed_pos).mpr M.stretched_le)

/-- Zero stretching = zero loss. -/
theorem no_stretch_no_loss (M : PolymerModel)
    (h : M.stretchedConfigurations = M.relaxedConfigurations) :
    stretchingLoss M = 0 := by
  unfold stretchingLoss
  rw [h, div_self (ne_of_gt M.relaxed_pos), log_one, neg_zero]

/-- The retention factor = fraction of configurations remaining. -/
theorem retention_eq_fraction (M : PolymerModel) :
    exp (-stretchingLoss M) =
      M.stretchedConfigurations / M.relaxedConfigurations := by
  unfold stretchingLoss
  rw [neg_neg, exp_log (div_pos M.stretched_pos M.relaxed_pos)]

end
end Survival.RubberElasticityBridge
