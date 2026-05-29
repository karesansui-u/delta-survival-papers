import Survival.QuantumInformationBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Born Rule Bridge — Measurement Probability as Structural Projection
Born rule: P(outcome) = |⟨ψ|φ⟩|². Structural reading: measurement
projects the quantum state onto a subspace, reducing V_G. The
probability of outcome k = fraction of V_G that survives projection.
|⟨ψ|φ⟩|² = m(V_projected) / m(V_total) = R_i (retention ratio).
-/
namespace Survival.BornRuleBridge
open Real
noncomputable section
structure MeasurementModel where
  totalAmplitude : ℝ     -- |ψ|² = 1 (normalized)
  outcomeAmplitude : ℝ   -- |⟨ψ|φ_k⟩|²
  total_pos : 0 < totalAmplitude
  outcome_nonneg : 0 ≤ outcomeAmplitude
  outcome_le : outcomeAmplitude ≤ totalAmplitude

/-- Born probability = retention ratio from measurement. -/
def bornProbability (M : MeasurementModel) : ℝ := M.outcomeAmplitude / M.totalAmplitude

/-- Structural consumption from measurement. -/
def measurementConsumption (M : MeasurementModel) (hout : 0 < M.outcomeAmplitude) : ℝ :=
  -log (bornProbability M)

/-- Measurement consumption is nonneg (measurement reduces V_G). -/
theorem measurement_consumption_nonneg (M : MeasurementModel) (hout : 0 < M.outcomeAmplitude) :
    0 ≤ measurementConsumption M hout := by
  unfold measurementConsumption bornProbability
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos hout M.total_pos))
    ((div_le_one₀ M.total_pos).mpr M.outcome_le)

/-- Certain outcome (amplitude = total) → zero consumption. -/
theorem certain_outcome_zero_consumption (M : MeasurementModel)
    (h : M.outcomeAmplitude = M.totalAmplitude) (hout : 0 < M.outcomeAmplitude) :
    measurementConsumption M hout = 0 := by
  unfold measurementConsumption bornProbability
  rw [h, div_self (ne_of_gt M.total_pos), log_one, neg_zero]
end
end Survival.BornRuleBridge
