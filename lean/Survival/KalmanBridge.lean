import Survival.BayesianBridge
/-!
# Kalman Filter Bridge — Optimal State Estimation
Kalman filter as structural persistence of state knowledge:
prediction step = structural consumption (uncertainty grows),
update step = structural recovery (measurement reduces uncertainty).
Kalman gain = optimal balance between prediction and measurement.

Structural reading: P_{k|k} = (I - K_k H) P_{k|k-1}
= retention ratio after measurement update.
-/
namespace Survival.KalmanBridge
open Real
noncomputable section
structure KalmanModel where
  predictionUncertainty : ℝ  -- P_{k|k-1} (grows = consumption)
  measurementPrecision : ℝ   -- 1/R (higher = more recovery)
  pred_pos : 0 < predictionUncertainty
  meas_pos : 0 < measurementPrecision

/-- Kalman gain: optimal weighting between prediction and measurement.
    K = P / (P + R) = prediction uncertainty / total uncertainty. -/
def kalmanGain (M : KalmanModel) : ℝ :=
  M.predictionUncertainty / (M.predictionUncertainty + 1 / M.measurementPrecision)

/-- Updated uncertainty < predicted uncertainty (measurement helps). -/
def updatedUncertainty (M : KalmanModel) : ℝ :=
  (1 - kalmanGain M) * M.predictionUncertainty

/-- The structural consumption from prediction (uncertainty grows). -/
def predictionConsumption (prev curr : ℝ) (hp : 0 < prev) (hc : 0 < curr) : ℝ :=
  -log (prev / curr)

/-- Better measurement → more recovery → lower updated uncertainty. -/
theorem better_measurement_helps (M₁ M₂ : KalmanModel)
    (h : M₁.measurementPrecision < M₂.measurementPrecision)
    (h1 : M₁.predictionUncertainty = M₂.predictionUncertainty) :
    kalmanGain M₁ < kalmanGain M₂ := by
  unfold kalmanGain
  rw [h1]
  apply div_lt_div_of_pos_left M₂.pred_pos
  · have := M₂.meas_pos; have := M₂.pred_pos; positivity
  · have hR₁ : 0 < 1 / M₁.measurementPrecision := div_pos one_pos M₁.meas_pos
    have hR₂ : 0 < 1 / M₂.measurementPrecision := div_pos one_pos M₂.meas_pos
    linarith [div_lt_div_of_pos_left one_pos M₁.meas_pos h]
end
end Survival.KalmanBridge
