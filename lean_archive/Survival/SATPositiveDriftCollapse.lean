import Survival.SATDriftLowerBound
import Survival.ConstantDriftExample

/-!
# SAT Positive-Drift Collapse

This module specializes the generic constant-drift collapse interface to the
random 3-SAT first-moment drift

  log (8 / 7).

It is intentionally conservative: the stochastic process is still the minimal
deterministic constant-drift process from `ConstantDriftExample`. The new point
is that its drift parameter is no longer an arbitrary `σ`, but the concrete
random-3-SAT information loss already derived in `SATDriftLowerBound`.
-/

open scoped ProbabilityTheory

namespace Survival.SATPositiveDriftCollapse

open MeasureTheory
open Survival.SATDriftLowerBound
open Survival.ConstantDriftExample
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]
variable (ℱ : Filtration ℕ ‹MeasurableSpace Ω›)

/-- The random-3-SAT constant-drift model. -/
def random3ClauseStepModel (s₀ : ℝ) :
    Survival.StochasticTotalProduction.StepModel (μ := μ) :=
  constantDriftStepModel (μ := μ) s₀ random3ClauseDrift

/-- Its expected cumulative total production is exactly linear with slope
`log (8 / 7)`. -/
theorem expectedCumulative_eq
    (s₀ : ℝ) (n : ℕ) :
    ((random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expectedCumulative n) =
      s₀ + (n : ℝ) * random3ClauseDrift := by
  unfold random3ClauseStepModel
  simpa using ConstantDriftExample.expectedCumulative_eq
    (μ := μ) s₀ random3ClauseDrift n

/-- Random 3-SAT drift yields the initial-margin stopped-collapse bound. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    [SigmaFiniteFiltration μ ℱ]
    {s₀ : ℝ} {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    StoppedCollapseWithFailureBound
      (μ := μ)
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) N r) := by
  unfold random3ClauseStepModel
  exact
    constantDrift_stoppedCollapseWithFailureBound_of_initialExpectedMargin
      (μ := μ) (ℱ := ℱ) random3ClauseDrift_nonneg hθ hmargin₀

/-- Random 3-SAT drift yields the initial-margin hitting-time-before-horizon
bound. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    [SigmaFiniteFiltration μ ℱ]
    {s₀ : ℝ} {k N : ℕ} (hkN : k < N) {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ s₀ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := μ)
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess N θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => random3ClauseDrift)) k r) := by
  unfold random3ClauseStepModel
  exact
    constantDrift_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
      (μ := μ) (ℱ := ℱ) random3ClauseDrift_nonneg hkN hmargin₀

end

end Survival.SATPositiveDriftCollapse
