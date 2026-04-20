import Survival.CoarseStochasticTotalProduction
import Survival.StoppingTimeCollapseEvent

/-!
Coarse / Stochastic Stopping-Time Collapse

This module instantiates the stopping-time collapse bounds on top of the
stochastic total-production and coarse-stochastic interfaces.

The purpose is modest:

* package the stopping-time theorems for `StepModel` directly;
* show that coarse expected-margin information can be imported from a
  compatible micro model;
* recover deterministic coarse-grained versions through the constant-process
  embedding.
-/

namespace Survival.CoarseStochasticStoppingTimeCollapse

open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.BoundedAzumaConstruction
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

open MeasureTheory

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Step-model wrapper for the stopping-time high-probability collapse bound. -/
theorem stepModel_stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
    (S : StepModel (μ := μ))
    (A : BoundedIncrementAzumaData (μ := μ) S.toStochasticProcess)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) :=
  stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) A hθ hmargin

/-- Step-model wrapper for the direct hitting-time event bound. -/
theorem stepModel_hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
    (S : StepModel (μ := μ))
    (A : BoundedIncrementAzumaData (μ := μ) S.toStochasticProcess)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) A hkN hmargin

/-- Under coarse stochastic compatibility, any expected-margin statement from
the micro model may be reused on the coarse model. -/
theorem coarse_stepModel_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : BoundedIncrementAzumaData (μ := μ) Scoarse.toStochasticProcess)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) N r) := by
  have hmargin_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative N - r := by
    rw [expectedCumulative_eq hcomp N]
    exact hmargin_micro
  exact stepModel_stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) Scoarse Acoarse hθ hmargin_coarse

/-- Direct hitting-time event version of the previous coarse transfer. -/
theorem coarse_stepModel_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : BoundedIncrementAzumaData (μ := μ) Scoarse.toStochasticProcess)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) k r) := by
  have hmargin_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq hcomp k]
    exact hmargin_micro
  exact stepModel_hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) Scoarse Acoarse hkN hmargin_coarse

section DeterministicEmbedding

variable [IsProbabilityMeasure μ]
variable {X Y : Type*}
variable {P : Survival.GeneralStateDynamics.ProblemSpec X}
variable {Q : Survival.GeneralStateDynamics.ProblemSpec Y}

/-- Deterministic coarse-grained stopping-time collapse bound, expressed through
the micro expected margin and the constant-process embedding. -/
theorem deterministic_coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : Survival.ResourceBudget.RepairBudget P}
    {Bcoarse : Survival.ResourceBudget.RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : Survival.ResourceBoundedDynamics.BoundedTrajectory P Bmicro)
    (Acoarse :
      BoundedIncrementAzumaData
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse).toStochasticProcess)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin_micro :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro N - r) :
    StoppedCollapseWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) Bcoarse).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) N r) := by
  have hcomp :
      CoarseStochasticCompatibility
        (μ := μ)
        (deterministicStepModel (μ := μ) Bmicro)
        (deterministicStepModel (μ := μ) Bcoarse) :=
    deterministic_coarseCompatibility (μ := μ) cg hs hB R
  exact coarse_stepModel_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    (μ := μ) hcomp Acoarse hθ hmargin_micro

/-- Deterministic coarse-grained direct hitting-time event bound. -/
theorem deterministic_coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : Survival.ResourceBudget.RepairBudget P}
    {Bcoarse : Survival.ResourceBudget.RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : Survival.ResourceBoundedDynamics.BoundedTrajectory P Bmicro)
    (Acoarse :
      BoundedIncrementAzumaData
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse).toStochasticProcess)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin_micro :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) Bcoarse).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) k r) := by
  have hcomp :
      CoarseStochasticCompatibility
        (μ := μ)
        (deterministicStepModel (μ := μ) Bmicro)
        (deterministicStepModel (μ := μ) Bcoarse) :=
    deterministic_coarseCompatibility (μ := μ) cg hs hB R
  exact coarse_stepModel_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    (μ := μ) hcomp Acoarse hkN hmargin_micro

end DeterministicEmbedding

end

end Survival.CoarseStochasticStoppingTimeCollapse
