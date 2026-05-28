import Survival.LogUniqueness
/-!
# Weber-Fechner Bridge — Sensation ∝ log(Stimulus)
Weber-Fechner law: perceived intensity ∝ log(physical stimulus).
This IS the structural log-ratio: the perceptual system measures
proportional change (ratios), not absolute change. The log form
is forced by the same axioms as structural consumption (B1-B4).

Weber-Fechner = the representation theorem applied to perception.
-/
namespace Survival.WeberFechnerBridge
open Real
noncomputable section

/-- Perceived intensity = log of stimulus ratio. Same axioms as
    structural consumption: additivity of successive stimuli,
    normalization at unit ratio, continuity. -/
def perceivedIntensity (stimulus reference : ℝ) (hs : 0 < stimulus) (hr : 0 < reference) : ℝ :=
  log (stimulus / reference)

theorem just_noticeable_difference_proportional
    (s₁ s₂ ref : ℝ) (hs₁ : 0 < s₁) (hs₂ : 0 < s₂) (hr : 0 < ref) (h : s₁ < s₂) :
    perceivedIntensity s₁ ref hs₁ hr < perceivedIntensity s₂ ref hs₂ hr := by
  unfold perceivedIntensity
  exact log_lt_log (div_pos hs₁ hr) (div_lt_div_of_pos_right h hr)

theorem no_perception_at_reference (ref : ℝ) (hr : 0 < ref) :
    perceivedIntensity ref ref hr hr = 0 := by
  unfold perceivedIntensity
  rw [div_self (ne_of_gt hr), log_one]
end
end Survival.WeberFechnerBridge
