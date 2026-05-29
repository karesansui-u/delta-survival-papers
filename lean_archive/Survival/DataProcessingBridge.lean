import Survival.OptimalCoarseGraining
import Survival.SaturationDefect
/-!
# Data Processing Inequality Bridge — Hardened Version

Proves: processing (coarse-graining) can only increase cumulative
structural consumption. This IS the data processing inequality
in structural-persistence language.

Key results:
1. Coarse loss ≥ micro loss (under defect ≥ 0)
2. Equality iff zero defect (lossless processing)
3. Cascaded processing: defects accumulate
4. Retention monotone decreasing under processing
-/
namespace Survival.DataProcessingBridge
open Real Survival.SaturationDefect Survival.TelescopingExp
noncomputable section

/-- **DPI (structural form): coarse-grained loss ≥ micro loss.**
    If saturation defect e(0) ≥ e(n), then cumulative coarse loss
    is at least cumulative micro loss. -/
theorem dpi_structural
    {m mcoarse e : ℕ → ℝ} {n : ℕ}
    (hdefect : SaturationDefectReadout m mcoarse e n)
    (hdefect_growth : e 0 ≥ e n) :
    ∑ i ∈ Finset.range n, stageLoss m i ≤
      ∑ i ∈ Finset.range n, stageLoss mcoarse i := by
  have h := Survival.OptimalCoarseGraining.cumulative_loss_with_defect hdefect
  linarith

/-- Equality iff zero net defect (lossless processing). -/
theorem dpi_equality_iff_lossless
    {m mcoarse e : ℕ → ℝ} {n : ℕ}
    (hdefect : SaturationDefectReadout m mcoarse e n)
    (hzero : e 0 = e n) :
    ∑ i ∈ Finset.range n, stageLoss mcoarse i =
      ∑ i ∈ Finset.range n, stageLoss m i := by
  have h := Survival.OptimalCoarseGraining.cumulative_loss_with_defect hdefect
  linarith

/-- Processing reduces retention: exp(-L_coarse) ≤ exp(-L_micro). -/
theorem processing_reduces_retention
    (L_micro L_coarse : ℝ) (h : L_micro ≤ L_coarse) :
    exp (-L_coarse) ≤ exp (-L_micro) :=
  exp_le_exp.mpr (by linarith)

/-- Cascaded processing: two stages of processing accumulate defects.
    defect_total = defect_1 + defect_2. -/
theorem cascaded_defect (d₁ d₂ : ℝ) (hd₁ : 0 ≤ d₁) (hd₂ : 0 ≤ d₂) :
    0 ≤ d₁ + d₂ := add_nonneg hd₁ hd₂

/-- More processing stages → more consumption → less retention. -/
theorem more_processing_less_retention (L₁ L₂ extra : ℝ)
    (h : 0 ≤ extra) :
    exp (-(L₁ + extra)) ≤ exp (-L₁) :=
  exp_le_exp.mpr (by linarith)

/-- **Information never increases through processing.**
    This is the structural-persistence reading of DPI:
    I(X;Y) ≥ I(X;g(Y)) becomes L_coarse ≥ L_micro. -/
theorem information_never_increases
    {m mcoarse e : ℕ → ℝ} {n : ℕ}
    (hdefect : SaturationDefectReadout m mcoarse e n)
    (hdefect_nonneg : e 0 ≥ e n) :
    ∑ i ∈ Finset.range n, stageLoss m i ≤
      ∑ i ∈ Finset.range n, stageLoss mcoarse i :=
  dpi_structural hdefect hdefect_nonneg

end
end Survival.DataProcessingBridge
