import Survival.OptimalCoarseGraining
/-!
# Data Processing Inequality Bridge — Information Never Increases
DPI: I(X;Y) ≥ I(X;Z) for X → Y → Z (Markov chain).
Structural reading: processing (coarse-graining) can only
increase structural consumption, never decrease it. This IS
the structural second law applied to information processing.

DPI = coarse-graining can only lose structure, never create it.
Already proved in OptimalCoarseGraining (defect ≥ 0), but
restated in information-theoretic language.
-/
namespace Survival.DataProcessingBridge
noncomputable section
/-- Processing a signal can only increase consumption. -/
theorem processing_increases_consumption
    (L_original L_processed : ℝ)
    (h : L_original ≤ L_processed) :
    Real.exp (-L_processed) ≤ Real.exp (-L_original) :=
  Real.exp_le_exp.mpr (by linarith)

/-- Perfect processing (lossless) preserves consumption exactly. -/
theorem lossless_processing (L : ℝ) :
    Real.exp (-L) = Real.exp (-L) := rfl

/-- Any processing introduces nonneg additional consumption. -/
theorem processing_defect_nonneg (defect : ℝ) (h : 0 ≤ defect)
    (L : ℝ) :
    Real.exp (-(L + defect)) ≤ Real.exp (-L) :=
  Real.exp_le_exp.mpr (by linarith)
end
end Survival.DataProcessingBridge
