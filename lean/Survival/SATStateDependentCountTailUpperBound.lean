import Survival.SATStateDependentCountReduction
import Survival.SATStateDependentTailUpperBound

/-!
# SAT State-Dependent Count Tail Upper Bound

This module turns the count reduction of the non-flat SAT clause-exposure
process into a reusable high-probability bridge.

The key point is:

* `SATStateDependentCountReduction` shows that, on the active prefix, the exact
  lower-tail event depends only on the unsatisfied-clause count;
* therefore any explicit upper bound on the count-based failure profile
  immediately yields threshold-crossing, collapse, and hitting-time bounds for
  the actual non-flat SAT process;
* a specialization to the Azuma/Hoeffding profile is then obtained for free.

So the remaining SAT-specific analytic task has been localized from the full
path-space process to a single inequality for `exactCountFailureBound`.
-/

namespace Survival.SATStateDependentCountTailUpperBound

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentTailUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- A closed-form upper bound candidate for the exact count-based lower-tail
failure profile. -/
abbrev CountFailureProfile := ℕ → ℝ → ENNReal

/-- The only remaining SAT-specific analytic input after count reduction:
an upper bound on the active-prefix count tail. -/
def HasCountFailureUpperBound
    (N : ℕ) (B : CountFailureProfile) : Prop :=
  ∀ ⦃n : ℕ⦄, n ≤ N + 1 → ∀ r, exactCountFailureBound N n r ≤ B n r

/-- Active-prefix exact SAT lower-tail failure is bounded by any upper profile
that dominates the count-based tail. -/
theorem exactFailureBound_le_of_hasCountFailureUpperBound
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B) :
    exactFailureBound N s₀ n r ≤ B n r := by
  calc
    exactFailureBound N s₀ n r = exactCountFailureBound N n r := by
      exact exactFailureBound_eq_exactCountFailureBound N s₀ hn r
    _ ≤ B n r := hB hn r

/-- Active-prefix threshold crossing for the actual non-flat SAT process follows
from any upper bound on the count-based tail. -/
theorem thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (B n r) := by
  refine ⟨exactLowerTailEvent N s₀ n r, ?_, ?_⟩
  · refine ⟨measurable_exactLowerTailEvent N s₀ n r, ?_⟩
    exact exactFailureBound_le_of_hasCountFailureUpperBound hn (hB := hB)
  · intro τ hτ
    have htail :=
      lower_bound_on_exactLowerTailEvent N s₀ n r τ hτ
    have hcenter :
        -Real.log θ ≤
          (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r := by
      rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hn]
      exact hmargin
    change
      -Real.log θ ≤
        StochasticTotalProduction.cumulativeTotalProductionRV
          (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission) n τ
    linarith

/-- Therefore any active-prefix count-tail upper bound gives a collapse bound
for the actual non-flat SAT process. -/
theorem collapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (B n r) := by
  exact collapseWithFailureBound_of_thresholdCrossingWithFailureBound
    _ _ hθ
    (thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn (hB := hB) hmargin)

/-- Terminal stopped-collapse bound from an active-prefix count-tail upper
bound. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (B T r) := by
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        T θ
        (B T r) :=
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT (hB := hB) hmargin
  exact
    stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hθ hcross

/-- Earlier threshold crossing from an active-prefix count-tail upper bound
forces the collapse hitting time to occur before the horizon. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (B k r) := by
  have hcross :
      ThresholdCrossingWithFailureBound
        (μ := pathMeasure N)
        (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
        k θ
        (B k r) :=
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hk (hB := hB) hmargin
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      hkT hcross

/-- Specialization of the previous generic bridge to the concrete SAT
Azuma/Hoeffding profile. -/
def HasCountAzumaFailureUpperBound
    (N : ℕ) : Prop :=
  HasCountFailureUpperBound N satAzumaFailureBound

/-- Active-prefix exact SAT tail is bounded by the concrete Azuma/Hoeffding
profile as soon as the count tail is. -/
theorem exactFailureBound_le_satAzumaFailureBound_of_hasCountAzumaFailureUpperBound
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N) :
    exactFailureBound N s₀ n r ≤ satAzumaFailureBound n r :=
  exactFailureBound_le_of_hasCountFailureUpperBound hn (hB := hB)

/-- Active-prefix stopped-collapse bound under a count-based Azuma/Hoeffding
upper bound. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountAzumaFailureUpperBound
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satAzumaFailureBound T r) :=
  stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    hT (hB := hB) hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound under a count-based
Azuma/Hoeffding upper bound. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountAzumaFailureUpperBound
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satAzumaFailureBound k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
    hkT hk (hB := hB) hmargin

end

end Survival.SATStateDependentCountTailUpperBound
