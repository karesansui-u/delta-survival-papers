import Survival.FiniteStateMarkovRepairChain
import Survival.ResourceBoundedStochasticCollapse
import Survival.BoundedAzumaConstruction

/-!
# Finite-State Markov Collapse Bounds

This module connects the finite-horizon actual Markov path-space construction
to the high-probability collapse / hitting-time API.

The role of the file is intentionally thin:

* the concrete probability space is supplied by
  `FiniteStateMarkovRepairChain.pathMeasure`;
* one-step resource-boundedness comes for free from the statewise emission
  nonnegativity already packaged in `Emission`;
* a uniform bounded-increment witness is generated directly from the
  finite-state emission bounds;
* the remaining probabilistic input is a lower-tail witness on the actual
  Markov path space.

Thus the user-facing theorem shape becomes

  actual finite-state Markov chain + lower-tail witness
    -> stopped collapse / hitting-time bound.
-/

namespace Survival.FiniteStateMarkovCollapse

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.ResourceBoundedStochasticCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Uniform total-production increment bound induced by the finite-state
emission bounds. -/
def incrementBound (E : Emission) : ℕ → ℝ :=
  fun _ => netActionBound E + costBound E

theorem incrementBound_nonneg (E : Emission) (t : ℕ) :
    0 ≤ incrementBound E t := by
  unfold incrementBound netActionBound costBound
  positivity

/-- On the actual Markov path space, one-step total production is uniformly
bounded by the sum of the net-action and repair-cost emission envelopes. -/
theorem boundedStepTotalProduction
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) :
    ∀ t, ∀ᵐ τ ∂pathMeasure M N,
      |stepTotalProductionRV (stepModel M N s₀ E) t τ| ≤ incrementBound E t := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  by_cases ht : t ≤ N
  · have hnet :
        |E.netActionOf (τ ⟨t, Nat.lt_succ_of_le ht⟩)| ≤ netActionBound E :=
      abs_netAction_le_bound E (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    have hcost :
        |E.costOf (τ ⟨t, Nat.lt_succ_of_le ht⟩)| ≤ costBound E :=
      abs_cost_le_bound E (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    have hsum :
        |E.netActionOf (τ ⟨t, Nat.lt_succ_of_le ht⟩) +
            E.costOf (τ ⟨t, Nat.lt_succ_of_le ht⟩)| ≤
          netActionBound E + costBound E := by
      rcases abs_le.mp hnet with ⟨hnetL, hnetU⟩
      rcases abs_le.mp hcost with ⟨hcostL, hcostU⟩
      refine abs_le.mpr ?_
      constructor <;> linarith
    simpa [incrementBound, StochasticTotalProduction.stepTotalProductionRV,
      FiniteStateMarkovRepairChain.stepModel, stepNetActionRV, stepCostRV, ht]
      using hsum
  · suffices 0 ≤ incrementBound E t by
      simpa [incrementBound, StochasticTotalProduction.stepTotalProductionRV,
        FiniteStateMarkovRepairChain.stepModel, stepNetActionRV, stepCostRV, ht]
    exact incrementBound_nonneg E t

/-- The finite-state actual Markov chain automatically packages into the
resource-bounded Azuma interface once a lower-tail witness is supplied. -/
def resourceBoundedStepModelAzuma
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E)) :
    ResourceBoundedStepModelAzuma
      (μ := pathMeasure M N)
      (stepModel M N s₀ E) :=
  ResourceBoundedStepModelAzuma.of_boundedIncrements
    (μ := pathMeasure M N)
    (incrementBound E)
    (incrementBound_nonneg E)
    (boundedStepTotalProduction M N s₀ E)
    (ae_nonnegative_stepTotalProduction M N s₀ E)
    W

/-- Terminal-margin high-probability stopped collapse for the actual finite
horizon Markov repair/failure chain. -/
theorem markov_stoppedCollapseWithFailureBound_of_expectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) T r) := by
  let A := resourceBoundedStepModelAzuma M N s₀ E W
  exact
    stoppedCollapseWithFailureBound_of_expectedMargin
      (μ := pathMeasure M N)
      A hθ hmargin

/-- Initial-margin high-probability stopped collapse for the actual finite
horizon Markov repair/failure chain. -/
theorem markov_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) T r) := by
  let A := resourceBoundedStepModelAzuma M N s₀ E W
  exact
    stoppedCollapseWithFailureBound_of_initialExpectedMargin
      (μ := pathMeasure M N)
      A hθ hmargin₀

/-- Direct hitting-time-before-horizon high-probability bound for the actual
finite-horizon Markov repair/failure chain. -/
theorem markov_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) k r) := by
  let A := resourceBoundedStepModelAzuma M N s₀ E W
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      (μ := pathMeasure M N)
      A hkT hmargin

/-- Initial-margin direct hitting-time-before-horizon high-probability bound for
the actual finite-horizon Markov repair/failure chain. -/
theorem markov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    (W :
      StepModelLowerTailWitness
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        (incrementBound E))
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (stepModel M N s₀ E).toStochasticProcess T θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) k r) := by
  let A := resourceBoundedStepModelAzuma M N s₀ E W
  refine
    (hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
      (μ := pathMeasure M N) A hkT hmargin₀)

end

end Survival.FiniteStateMarkovCollapse
