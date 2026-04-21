import Survival.SATStateDependentClauseExposure
import Survival.StochasticTotalProduction
import Survival.ConcentrationInterface
import Survival.StoppingTimeCollapseEvent
import Survival.StoppingTimeHighProbabilityCollapse

/-!
# SAT State-Dependent Exact Concentration

This module records the exact lower-tail concentration object associated with
the actual non-flat SAT clause-exposure process.

Unlike `SATStateDependentAzuma`, this file does not try to upper-bound the tail
probability by a closed-form Azuma/Hoeffding expression. Instead, it packages
the genuinely realized lower-tail event itself:

* the good event is the exact lower-tail threshold event;
* the failure profile is the exact complement probability under the actual path
  measure;
* from this, one obtains exact fixed-time threshold-crossing, collapse, and
  hitting-time-before-horizon bounds.

This gives a conservative but fully honest concentration layer for the
state-dependent SAT process, on top of which sharper Azuma / Chernoff style
upper bounds can later be imposed.
-/

namespace Survival.SATStateDependentExactConcentration

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.StochasticTotalProduction
open Survival.ConcentrationInterface
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- The exact lower-tail good event for the actual non-flat SAT process. -/
def exactLowerTailEvent
    (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  {τ |
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
      cumulativeTotalProductionRV (stepModel N s₀ oneSidedUnsatEmission) n τ}

theorem measurable_exactLowerTailEvent
    (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) :
    MeasurableSet (exactLowerTailEvent N s₀ n r) := by
  trivial

theorem lower_bound_on_exactLowerTailEvent
    (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) (τ : Trajectory N)
    (hτ : τ ∈ exactLowerTailEvent N s₀ n r) :
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
      cumulativeTotalProductionRV (stepModel N s₀ oneSidedUnsatEmission) n τ :=
  hτ

/-- Exact lower-tail failure profile under the actual non-flat SAT path
measure. -/
def exactFailureBound
    (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) : ENNReal :=
  pathMeasure N ((exactLowerTailEvent N s₀ n r)ᶜ)

/-- Exact expectation-centered concentration object for the actual non-flat SAT
clause-exposure process. -/
def exactExpectationLowerConcentration
    (N : ℕ) (s₀ : ℝ) :
    ExpectationLowerConcentration
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess where
  toLowerDeviationConcentration := {
    center := (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative
    goodEvent := exactLowerTailEvent N s₀
    measurable_goodEvent := measurable_exactLowerTailEvent N s₀
    lower_bound_on_good := lower_bound_on_exactLowerTailEvent N s₀
    failureBound := exactFailureBound N s₀
    failure_bound := by
      intro n r
      show
        pathMeasure N ((exactLowerTailEvent N s₀ n r)ᶜ) ≤
          exactFailureBound N s₀ n r
      exact le_rfl
  }
  center_eq_expected := rfl

/-- Exact fixed-time threshold-crossing bound from an expected margin. -/
theorem thresholdCrossingWithExactFailureBound_of_expectedMargin
    {N n : ℕ} {s₀ θ r : ℝ}
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (exactFailureBound N s₀ n r) := by
  exact
    thresholdCrossingWithFailureBound_of_expected_center
      (μ := pathMeasure N)
      (exactExpectationLowerConcentration N s₀)
      hmargin

/-- Exact fixed-time collapse bound from an expected margin. -/
theorem collapseWithExactFailureBound_of_expectedMargin
    {N n : ℕ} {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (exactFailureBound N s₀ n r) := by
  exact
    collapseWithFailureBound_of_expected_center
      (μ := pathMeasure N)
      (exactExpectationLowerConcentration N s₀)
      hθ hmargin

/-- Exact stopped-collapse bound at the terminal time from an expected margin. -/
theorem stoppedCollapseWithExactFailureBound_of_expectedMargin
    {N : ℕ} {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (exactFailureBound N s₀ N r) := by
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        N θ
        (exactFailureBound N s₀ N r) := by
    exact thresholdCrossingWithExactFailureBound_of_expectedMargin hmargin
  exact
    stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hθ hcross

/-- Exact hitting-time-before-horizon bound from an earlier expected margin. -/
theorem hittingTimeBeforeHorizonWithExactFailureBound_of_expectedMargin
    {N k : ℕ} (hkN : k < N) {s₀ θ r : ℝ}
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (exactFailureBound N s₀ k r) := by
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        k θ
        (exactFailureBound N s₀ k r) := by
    exact thresholdCrossingWithExactFailureBound_of_expectedMargin hmargin
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hkN hcross

/-- On the active prefix, the exact linear center can be fed into the exact
lower-tail concentration interface. -/
theorem thresholdCrossingWithExactFailureBound_of_activeLinearMargin
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (exactFailureBound N s₀ n r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hn]
    exact hmargin
  exact thresholdCrossingWithExactFailureBound_of_expectedMargin hmargin'

/-- Active-prefix exact collapse bound from the linear center. -/
theorem collapseWithExactFailureBound_of_activeLinearMargin
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (exactFailureBound N s₀ n r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hn]
    exact hmargin
  exact collapseWithExactFailureBound_of_expectedMargin hθ hmargin'

/-- Active-prefix exact stopped-collapse bound from the linear center. -/
theorem stoppedCollapseWithExactFailureBound_of_activeLinearMargin
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (exactFailureBound N s₀ T r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative T - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hT]
    exact hmargin
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        T θ
        (exactFailureBound N s₀ T r) := by
    exact thresholdCrossingWithExactFailureBound_of_expectedMargin hmargin'
  exact
    stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hθ hcross

/-- Active-prefix exact hitting-time-before-horizon bound from the linear
center. -/
theorem hittingTimeBeforeHorizonWithExactFailureBound_of_activeLinearMargin
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (exactFailureBound N s₀ k r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hk]
    exact hmargin
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        k θ
        (exactFailureBound N s₀ k r) := by
    exact thresholdCrossingWithExactFailureBound_of_expectedMargin hmargin'
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hkT hcross

end

end Survival.SATStateDependentExactConcentration
