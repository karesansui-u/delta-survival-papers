import Survival.StochasticCollapseTimeBound

/-!
Stochastic Cliff Warning
cliff の確率版 early-warning

This module gives the probabilistic early-warning analogue of `CliffWarning`.

At the stochastic level, the remaining safety margin is itself random:

  remainingMargin = -log θ - Aₙ.

If this random remaining margin is almost surely no larger than the next
increment, then almost surely the collapse threshold is crossed at the next
step. Therefore the survival ratio drops below `θ` almost surely at time `n+1`.
-/

open MeasureTheory

namespace Survival.StochasticCliffWarning

open Survival.ProbabilityConnection
open Survival.StochasticCollapseTimeBound

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Random remaining safety margin before the collapse threshold `θ`. -/
def remainingMarginRV
    (S : StochasticExpectedProcess (μ := μ)) (n : ℕ) (θ : ℝ) : Ω → ℝ :=
  fun ω => -Real.log θ - S.cumulativeRV n ω

/-- If the remaining margin is almost surely already below the next increment,
then the next-step cumulative action crosses the collapse threshold almost
surely. -/
theorem thresholdCrossingNext_ae_of_remainingMargin_le_increment_ae
    (S : StochasticExpectedProcess (μ := μ)) (n : ℕ)
    {θ : ℝ} (_hθ : 0 < θ)
    (hwarn : ∀ᵐ ω ∂μ, remainingMarginRV (μ := μ) S n θ ω ≤ S.incrementRV n ω) :
    ∀ᵐ ω ∂μ, -Real.log θ ≤ S.cumulativeRV (n + 1) ω := by
  filter_upwards [hwarn, S.cumulative_succ_ae n] with ω hw hrec
  unfold remainingMarginRV at hw
  rw [hrec]
  linarith

/-- Probabilistic early warning:
if the next increment dominates the remaining margin almost surely, then
collapse below `θ` occurs almost surely at the next step. -/
theorem collapseAlmostSurely_next_of_remainingMargin_le_increment_ae
    (S : StochasticExpectedProcess (μ := μ)) (n : ℕ)
    {θ : ℝ} (hθ : 0 < θ)
    (hwarn : ∀ᵐ ω ∂μ, remainingMarginRV (μ := μ) S n θ ω ≤ S.incrementRV n ω) :
    CollapseAlmostSurely S (n + 1) θ := by
  exact collapseAlmostSurely_of_threshold_ae S (n + 1) hθ
    (thresholdCrossingNext_ae_of_remainingMargin_le_increment_ae S n hθ hwarn)

/-- Lower-bound form of the previous theorem:
if a certified lower bound `a` dominates the remaining margin and is itself
dominated by the next increment almost surely, collapse follows almost surely. -/
theorem collapseAlmostSurely_next_of_remainingMargin_le_lowerBound_ae
    (S : StochasticExpectedProcess (μ := μ)) (n : ℕ)
    {θ a : ℝ} (hθ : 0 < θ)
    (hmargin : ∀ᵐ ω ∂μ, remainingMarginRV (μ := μ) S n θ ω ≤ a)
    (ha : ∀ᵐ ω ∂μ, a ≤ S.incrementRV n ω) :
    CollapseAlmostSurely S (n + 1) θ := by
  have hwarn : ∀ᵐ ω ∂μ, remainingMarginRV (μ := μ) S n θ ω ≤ S.incrementRV n ω := by
    filter_upwards [hmargin, ha] with ω hm haω
    linarith
  exact collapseAlmostSurely_next_of_remainingMargin_le_increment_ae S n hθ hwarn

end

end Survival.StochasticCliffWarning
