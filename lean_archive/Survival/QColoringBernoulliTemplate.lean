import Survival.BernoulliCSPTemplate

/-!
# q-Coloring Bernoulli Template

This module instantiates the reusable Bernoulli-CSP algebra for a fixed-coloring
edge-exposure model.  A random edge exposure is bad when its two exposed endpoint
colors coincide, so the bad-event probability is `1 / q`.

This is intentionally the Bernoulli bad-event exposure layer.  It does not model
full random graph dynamics, degree correlations, or coloring-algorithm dynamics.
-/

namespace Survival.QColoringBernoulliTemplate

open Survival.BernoulliCSPTemplate

noncomputable section

/-- Bad-edge probability for `q`-coloring exposure. -/
def qColoringBadProb (q : ℝ) : ℝ :=
  1 / q

theorem qColoringBadProb_pos {q : ℝ} (hq : 1 < q) :
    0 < qColoringBadProb q := by
  unfold qColoringBadProb
  have hqpos : 0 < q := lt_trans zero_lt_one hq
  exact one_div_pos.mpr hqpos

theorem qColoringBadProb_lt_one {q : ℝ} (hq : 1 < q) :
    qColoringBadProb q < 1 := by
  unfold qColoringBadProb
  have hqpos : 0 < q := lt_trans zero_lt_one hq
  rw [div_lt_iff₀ hqpos]
  linarith

/-- Bernoulli-CSP parameters for `q`-coloring edge exposure. -/
def qColoringParameters (q : ℝ) (hq : 1 < q) : Parameters where
  badProb := qColoringBadProb q
  badProb_pos := qColoringBadProb_pos hq
  badProb_lt_one := qColoringBadProb_lt_one hq

theorem qColoringParameters_badProb (q : ℝ) (hq : 1 < q) :
    (qColoringParameters q hq).badProb = qColoringBadProb q := rfl

/-- `q`-coloring exposure drift in the Bernoulli-CSP template. -/
def qColoringDrift (q : ℝ) (hq : 1 < q) : ℝ :=
  (qColoringParameters q hq).drift

theorem qColoringDrift_eq_log_ratio {q : ℝ} (hq : 1 < q) :
    qColoringDrift q hq = Real.log (q / (q - 1)) := by
  unfold qColoringDrift qColoringParameters Parameters.drift qColoringBadProb
  congr 1
  have hqpos : 0 < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hqpos
  have hsubne : q - 1 ≠ 0 := ne_of_gt (sub_pos.mpr hq)
  field_simp [hqne, hsubne]

theorem qColoringDrift_pos (q : ℝ) (hq : 1 < q) :
    0 < qColoringDrift q hq :=
  (qColoringParameters q hq).drift_pos

/-- One-sided bad-edge emission scale for the `q`-coloring exposure model. -/
def qColoringBadEmissionScale (q : ℝ) (hq : 1 < q) : ℝ :=
  (qColoringParameters q hq).badEmissionScale

theorem qColoringBadEmissionScale_eq_mul_drift {q : ℝ} (hq : 1 < q) :
    qColoringBadEmissionScale q hq = q * qColoringDrift q hq := by
  unfold qColoringBadEmissionScale qColoringDrift qColoringParameters
    Parameters.badEmissionScale qColoringBadProb
  have hqpos : 0 < q := lt_trans zero_lt_one hq
  field_simp [ne_of_gt hqpos]

theorem qColoringBadEmissionScale_pos (q : ℝ) (hq : 1 < q) :
    0 < qColoringBadEmissionScale q hq :=
  (qColoringParameters q hq).badEmissionScale_pos

theorem qColoring_expectedBadEmission_eq_drift (q : ℝ) (hq : 1 < q) :
    qColoringBadProb q * qColoringBadEmissionScale q hq =
      qColoringDrift q hq := by
  exact (qColoringParameters q hq).expectedBadEmission_eq_drift

/-- The generic interior KL/Chernoff identity specialized to `q`-coloring
bad-edge exposure. -/
theorem qColoring_optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    {q : ℝ} (hq : 1 < q) {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * qColoringDrift q hq) :
    ENNReal.ofReal ((qColoringParameters q hq).optimizedClosedMGFReal n r) =
      (qColoringParameters q hq).chernoffFailureBound n r := by
  exact
    (qColoringParameters q hq).optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
      hr hlt

end

end Survival.QColoringBernoulliTemplate
