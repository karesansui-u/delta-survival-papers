import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Hardy-Weinberg Bridge
p² + 2pq + q² = 1 at equilibrium. Deviation from HW = structural
consumption. Selection pressure = consumption rate.
-/
namespace Survival.HardyWeinbergBridge
noncomputable section

/-- HW equilibrium: genotype frequencies from allele freq p. -/
def hwEquilibrium (p : ℝ) : ℝ × ℝ × ℝ :=
  (p ^ 2, 2 * p * (1 - p), (1 - p) ^ 2)

/-- Frequencies sum to 1 at equilibrium. -/
theorem hw_sum_one (p : ℝ) :
    let (aa, ab, bb) := hwEquilibrium p
    aa + ab + bb = 1 := by
  unfold hwEquilibrium; ring

/-- Deviation from equilibrium = structural consumption.
Measured as KL divergence from expected to observed. -/
theorem deviation_nonneg_of_undershoot (observed expected : ℝ)
    (ho : 0 < observed) (he : 0 < expected) (hle : observed ≤ expected) :
    0 ≤ -Real.log (observed / expected) := by
  rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt (div_pos ho he))
    ((div_le_one₀ he).mpr hle)

end
end Survival.HardyWeinbergBridge
