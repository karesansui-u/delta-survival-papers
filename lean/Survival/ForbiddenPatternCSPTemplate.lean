import Survival.BernoulliCSPTemplate

/-!
# Forbidden-Pattern CSP Bernoulli Template

This module packages a generic finite-alphabet forbidden-pattern exposure model.
If an arity-`k` local constraint is sampled uniformly from `alphabet^k` local
patterns and `forbidden` of those patterns are bad, then the bad-event
probability is

`forbidden / alphabet^k`.

The module stays at the Bernoulli exposure layer.  It does not model dependency
between overlapping constraints or solver-adaptive sampling.
-/

namespace Survival.ForbiddenPatternCSPTemplate

open Survival.BernoulliCSPTemplate

noncomputable section

/-- Bad-event probability for a finite-alphabet forbidden-pattern CSP exposure. -/
def forbiddenPatternBadProb (alphabet forbidden : ℝ) (arity : ℕ) : ℝ :=
  forbidden / alphabet ^ arity

theorem forbiddenPatternBadProb_pos
    {alphabet forbidden : ℝ} (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden) :
    0 < forbiddenPatternBadProb alphabet forbidden arity := by
  unfold forbiddenPatternBadProb
  exact div_pos hf (pow_pos ha arity)

theorem forbiddenPatternBadProb_lt_one
    {alphabet forbidden : ℝ} {arity : ℕ}
    (ha : 0 < alphabet)
    (hlt : forbidden < alphabet ^ arity) :
    forbiddenPatternBadProb alphabet forbidden arity < 1 := by
  unfold forbiddenPatternBadProb
  have hden : 0 < alphabet ^ arity := pow_pos ha arity
  rw [div_lt_iff₀ hden]
  simpa using hlt

/-- Bernoulli-CSP parameters for a finite-alphabet forbidden-pattern exposure. -/
def forbiddenPatternParameters
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) : Parameters where
  badProb := forbiddenPatternBadProb alphabet forbidden arity
  badProb_pos := forbiddenPatternBadProb_pos arity ha hf
  badProb_lt_one := forbiddenPatternBadProb_lt_one ha hlt

theorem forbiddenPatternParameters_badProb
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).badProb =
      forbiddenPatternBadProb alphabet forbidden arity := rfl

/-- Drift induced by the forbidden-pattern bad-event probability. -/
def forbiddenPatternDrift
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) : ℝ :=
  (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).drift

theorem forbiddenPatternDrift_eq_log_ratio
    {alphabet forbidden : ℝ} {arity : ℕ}
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    forbiddenPatternDrift alphabet forbidden arity ha hf hlt =
      Real.log (alphabet ^ arity / (alphabet ^ arity - forbidden)) := by
  unfold forbiddenPatternDrift forbiddenPatternParameters Parameters.drift
    forbiddenPatternBadProb
  congr 1
  have hden_pos : 0 < alphabet ^ arity := pow_pos ha arity
  have hden_ne : alphabet ^ arity ≠ 0 := ne_of_gt hden_pos
  have hsub_ne : alphabet ^ arity - forbidden ≠ 0 :=
    ne_of_gt (sub_pos.mpr hlt)
  field_simp [hden_ne, hsub_ne]

theorem forbiddenPatternDrift_pos
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    0 < forbiddenPatternDrift alphabet forbidden arity ha hf hlt :=
  (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).drift_pos

/-- One-sided bad-pattern emission scale. -/
def forbiddenPatternBadEmissionScale
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) : ℝ :=
  (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).badEmissionScale

theorem forbiddenPatternBadEmissionScale_pos
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    0 <
      forbiddenPatternBadEmissionScale alphabet forbidden arity ha hf hlt :=
  (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).badEmissionScale_pos

theorem forbiddenPattern_expectedBadEmission_eq_drift
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) :
    forbiddenPatternBadProb alphabet forbidden arity *
        forbiddenPatternBadEmissionScale alphabet forbidden arity ha hf hlt =
      forbiddenPatternDrift alphabet forbidden arity ha hf hlt := by
  exact
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt).expectedBadEmission_eq_drift

/-- The generic interior KL/Chernoff identity specialized to forbidden-pattern
CSP exposure. -/
theorem forbiddenPattern_optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    {alphabet forbidden : ℝ} {arity n : ℕ}
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hforb : forbidden < alphabet ^ arity) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r <
      (n : ℝ) * forbiddenPatternDrift alphabet forbidden arity ha hf hforb) :
    ENNReal.ofReal
        (Parameters.optimizedClosedMGFReal
          (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
          n r) =
      Parameters.chernoffFailureBound
        (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
        n r := by
  exact
    Parameters.optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
      (forbiddenPatternParameters alphabet forbidden arity ha hf hforb)
      hr hlt

end

end Survival.ForbiddenPatternCSPTemplate
