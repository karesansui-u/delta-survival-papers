import Survival.MixingTimeBridge
/-!
# Spectral Theory Bridge — Eigenvalue Decomposition of Structural Dynamics
Reads spectral theory through structural persistence: the
eigenvalues of the structural transition operator determine the
mode decomposition of structural consumption. The largest
eigenvalue → slowest decay mode → dominant structural fate.

Spectral gap = MixingTimeBridge connection (already exists).
This adds: each eigenvalue λ_k corresponds to a structural
consumption mode with rate -log|λ_k|.
-/
namespace Survival.SpectralTheoryBridge
open Real Survival.MixingTimeBridge
noncomputable section

/-- A spectral mode: an eigenvalue and its structural consumption rate. -/
structure SpectralMode where
  eigenvalue : ℝ           -- |λ_k|
  eigenvalue_pos : 0 < eigenvalue
  eigenvalue_le_one : eigenvalue ≤ 1

/-- The consumption rate of a spectral mode = -log|λ|. -/
def modeConsumptionRate (M : SpectralMode) : ℝ := -log M.eigenvalue

/-- Mode consumption rate is nonneg (eigenvalue ≤ 1). -/
theorem modeRate_nonneg (M : SpectralMode) : 0 ≤ modeConsumptionRate M := by
  unfold modeConsumptionRate
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt M.eigenvalue_pos) M.eigenvalue_le_one

/-- Eigenvalue = 1 → zero consumption (invariant mode). -/
theorem invariant_mode (M : SpectralMode) (h : M.eigenvalue = 1) :
    modeConsumptionRate M = 0 := by
  unfold modeConsumptionRate; rw [h, log_one, neg_zero]

/-- Smaller eigenvalue → faster decay → higher consumption. -/
theorem smaller_eigenvalue_faster (M₁ M₂ : SpectralMode)
    (h : M₁.eigenvalue < M₂.eigenvalue) :
    modeConsumptionRate M₂ < modeConsumptionRate M₁ := by
  unfold modeConsumptionRate
  exact neg_lt_neg (log_lt_log M₁.eigenvalue_pos h)
end
end Survival.SpectralTheoryBridge
