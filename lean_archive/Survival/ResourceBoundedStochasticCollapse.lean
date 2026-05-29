import Survival.StochasticTotalProductionAzuma

/-!
Resource-Bounded Stochastic Collapse

This module packages the resource-bounded stochastic total-production story into
a single operational interface.

The intent is to remove most of the user-side plumbing:

* one-step total production is almost surely nonnegative (resource-boundedness);
* one-step total production has bounded increments;
* a lower-tail Azuma witness is available for the cumulative process.

From these ingredients we obtain, in one step:

* high-probability stopped collapse bounds;
* high-probability direct hitting-time-before-horizon bounds;
* initial-margin versions obtained from the monotonicity forced by
  resource-boundedness.
-/

namespace Survival.ResourceBoundedStochasticCollapse

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.BoundedAzumaConstruction
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Resource-bounded stochastic total production together with the bounded
increment / lower-tail data needed for Azuma/Hoeffding collapse bounds. -/
structure ResourceBoundedStepModelAzuma
    (S : StepModel (μ := μ)) where
  incrementBound : ℕ → ℝ
  incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t
  boundedStepTotalProduction :
    ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t
  ae_nonnegative_stepTotalProduction :
    AENonnegativeStepTotalProduction (μ := μ) S
  lowerTailWitness :
    StepModelLowerTailWitness (μ := μ) S incrementBound

/-- Forgetful conversion to the total-production Azuma interface. -/
def ResourceBoundedStepModelAzuma.toStepModelAzumaData
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S) :
    StepModelAzumaData (μ := μ) S :=
  StepModelAzumaData.of_boundedIncrements
    (μ := μ)
    A.incrementBound
    A.incrementBound_nonneg
    A.boundedStepTotalProduction
    A.lowerTailWitness

/-- Automatic constructor from bounded increments, a resource-bounded
one-step-nonnegativity witness, and a lower-tail Azuma witness. This is the
generic entry point when the user has not yet bundled these ingredients into
`ResourceBoundedStepModelAzuma`. -/
def ResourceBoundedStepModelAzuma.of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (ae_nonnegative_stepTotalProduction :
      AENonnegativeStepTotalProduction (μ := μ) S)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound) :
    ResourceBoundedStepModelAzuma (μ := μ) S where
  incrementBound := incrementBound
  incrementBound_nonneg := incrementBound_nonneg
  boundedStepTotalProduction := boundedStepTotalProduction
  ae_nonnegative_stepTotalProduction := ae_nonnegative_stepTotalProduction
  lowerTailWitness := W

/-- Resource-boundedness implies monotonicity of the expected cumulative total
production. -/
theorem expectedCumulative_monotone
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S) :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (μ := μ) S A.ae_nonnegative_stepTotalProduction

/-- Terminal-margin version: resource-bounded stochastic total production gives
high-probability stopped collapse directly. -/
theorem stoppedCollapseWithFailureBound_of_expectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) :=
  stoppedCollapseWithFailureBound_of_stepModelAzuma_expectedMargin
    (μ := μ) A.toStepModelAzumaData hθ hmargin

/-- Initial-margin version: monotonicity from resource-boundedness lets one use
the margin at time `0` instead of the margin at time `N`. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hmono := expectedCumulative_monotone (μ := μ) A
  have h0N :
      S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative N :=
    hmono (Nat.zero_le N)
  have hmarginN :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r := by
    linarith
  exact stoppedCollapseWithFailureBound_of_expectedMargin (μ := μ) A hθ hmarginN

/-- Raw-ingredients version of the terminal-margin theorem. This packages the
resource-boundedness witness automatically. Corresponds to the high-probability
operational collapse layer built on top of goal theorems 2–5 in the supplement. -/
theorem stoppedCollapseWithFailureBound_of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (ae_nonnegative_stepTotalProduction :
      AENonnegativeStepTotalProduction (μ := μ) S)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) N r) := by
  exact stoppedCollapseWithFailureBound_of_expectedMargin
    (μ := μ)
    (ResourceBoundedStepModelAzuma.of_boundedIncrements
      (μ := μ) incrementBound incrementBound_nonneg boundedStepTotalProduction
      ae_nonnegative_stepTotalProduction W)
    hθ hmargin

/-- Direct hitting-time event version with a margin at time `k < N`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_stepModelAzuma_expectedMargin
    (μ := μ) A.toStepModelAzumaData hkN hmargin

/-- Initial-margin version for the direct hitting-time event. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hmono := expectedCumulative_monotone (μ := μ) A
  have h0k :
      S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative k :=
    hmono (Nat.zero_le k)
  have hmargink :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    linarith
  exact hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    (μ := μ) A hkN hmargink

/-- Raw-ingredients version of the direct hitting-time event theorem. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrements
    {S : StepModel (μ := μ)}
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ, |stepTotalProductionRV S t ω| ≤ incrementBound t)
    (ae_nonnegative_stepTotalProduction :
      AENonnegativeStepTotalProduction (μ := μ) S)
    (W : StepModelLowerTailWitness (μ := μ) S incrementBound)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds incrementBound) k r) := by
  exact hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    (μ := μ)
    (ResourceBoundedStepModelAzuma.of_boundedIncrements
      (μ := μ) incrementBound incrementBound_nonneg boundedStepTotalProduction
      ae_nonnegative_stepTotalProduction W)
    hkN hmargin

section DeterministicEmbedding

variable [IsProbabilityMeasure μ]
variable {X Y : Type*}
variable {P : Survival.GeneralStateDynamics.ProblemSpec X}
variable {Q : Survival.GeneralStateDynamics.ProblemSpec Y}

/-- Constructor for the deterministic constant-process embedding. This packages
resource-boundedness together with a bounded-increment / lower-tail witness into
the `ResourceBoundedStepModelAzuma` interface. -/
def deterministicResourceBoundedStepModelAzuma
    (B : RepairBudget P)
    (R : BoundedTrajectory P B)
    (incrementBound : ℕ → ℝ)
    (incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t)
    (boundedStepTotalProduction :
      ∀ t, ∀ᵐ ω ∂μ,
        |stepTotalProductionRV (deterministicStepModel (μ := μ) B) t ω| ≤ incrementBound t)
    (W :
      StepModelLowerTailWitness
        (μ := μ) (deterministicStepModel (μ := μ) B) incrementBound) :
    ResourceBoundedStepModelAzuma
      (μ := μ) (deterministicStepModel (μ := μ) B) where
  incrementBound := incrementBound
  incrementBound_nonneg := incrementBound_nonneg
  boundedStepTotalProduction := boundedStepTotalProduction
  ae_nonnegative_stepTotalProduction :=
    deterministic_ae_nonnegative_stepTotalProduction (μ := μ) B R
  lowerTailWitness := W

/-- Deterministic resource-bounded stopped collapse bound stated directly in
terms of cumulative total production. -/
theorem deterministic_stoppedCollapseWithFailureBound_of_expectedMargin
    {B : RepairBudget P}
    (A : ResourceBoundedStepModelAzuma (μ := μ) (deterministicStepModel (μ := μ) B))
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ cumulativeTotalProduction B N - r) :
    StoppedCollapseWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) B).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hmargin' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) B N - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) B N]
    exact hmargin
  simpa [deterministicExpectedCumulative] using
    (stoppedCollapseWithFailureBound_of_expectedMargin (μ := μ) A hθ hmargin')

/-- Deterministic initial-margin version of the previous theorem. -/
theorem deterministic_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    {B : RepairBudget P}
    (A : ResourceBoundedStepModelAzuma (μ := μ) (deterministicStepModel (μ := μ) B))
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ cumulativeTotalProduction B 0 - r) :
    StoppedCollapseWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) B).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hmargin₀' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) B 0 - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) B 0]
    exact hmargin₀
  simpa [deterministicExpectedCumulative] using
    (stoppedCollapseWithFailureBound_of_initialExpectedMargin (μ := μ) A hθ hmargin₀')

/-- Deterministic resource-bounded direct hitting-time event bound. -/
theorem deterministic_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    {B : RepairBudget P}
    (A : ResourceBoundedStepModelAzuma (μ := μ) (deterministicStepModel (μ := μ) B))
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ cumulativeTotalProduction B k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) B).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hmargin' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) B k - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) B k]
    exact hmargin
  simpa [deterministicExpectedCumulative] using
    (hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      (μ := μ) A hkN hmargin')

/-- Deterministic initial-margin version of the direct hitting-time event bound. -/
theorem deterministic_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    {B : RepairBudget P}
    (A : ResourceBoundedStepModelAzuma (μ := μ) (deterministicStepModel (μ := μ) B))
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ cumulativeTotalProduction B 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) (deterministicStepModel (μ := μ) B).toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hmargin₀' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) B 0 - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) B 0]
    exact hmargin₀
  simpa [deterministicExpectedCumulative] using
    (hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
      (μ := μ) A hkN hmargin₀')

end DeterministicEmbedding

section CoarseTransfer

/-- Under coarse stochastic compatibility, a micro expected-margin statement may
be reused on a resource-bounded coarse model. -/
theorem coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
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
  exact stoppedCollapseWithFailureBound_of_expectedMargin
    (μ := μ) Acoarse hθ hmargin_coarse

/-- Initial-margin version of the previous coarse transfer theorem. -/
theorem coarse_stoppedCollapseWithFailureBound_of_micro_initialExpectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    StoppedCollapseWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) N r) := by
  have hmargin₀_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r := by
    rw [expectedCumulative_eq hcomp 0]
    exact hmargin₀_micro
  exact stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (μ := μ) Acoarse hθ hmargin₀_coarse

/-- Direct hitting-time event version of the coarse transfer theorem. -/
theorem coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
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
  exact hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    (μ := μ) Acoarse hkN hmargin_coarse

/-- Initial-margin version of the direct hitting-time event coarse transfer. -/
theorem coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_initialExpectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀_micro :
      -Real.log θ ≤ Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds Acoarse.incrementBound) k r) := by
  have hmargin₀_coarse :
      -Real.log θ ≤ Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r := by
    rw [expectedCumulative_eq hcomp 0]
    exact hmargin₀_micro
  exact hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (μ := μ) Acoarse hkN hmargin₀_coarse

end CoarseTransfer

section DeterministicCoarseTransfer

variable [IsProbabilityMeasure μ]
variable {X Y : Type*}
variable {P : Survival.GeneralStateDynamics.ProblemSpec X}
variable {Q : Survival.GeneralStateDynamics.ProblemSpec Y}

/-- Deterministic coarse-grained stopped collapse bound stated using the micro
deterministic total-production margin. -/
theorem deterministic_coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro)
    (Acoarse :
      ResourceBoundedStepModelAzuma
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse))
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin_micro : -Real.log θ ≤ cumulativeTotalProduction Bmicro N - r) :
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
  have hmargin_micro' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro N - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) Bmicro N]
    exact hmargin_micro
  simpa [deterministicExpectedCumulative] using
    (coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
      (μ := μ) hcomp Acoarse hθ hmargin_micro')

/-- Deterministic coarse-grained initial-margin stopped collapse bound. -/
theorem deterministic_coarse_stoppedCollapseWithFailureBound_of_micro_initialExpectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro)
    (Acoarse :
      ResourceBoundedStepModelAzuma
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse))
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀_micro : -Real.log θ ≤ cumulativeTotalProduction Bmicro 0 - r) :
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
  have hmargin₀_micro' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro 0 - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) Bmicro 0]
    exact hmargin₀_micro
  simpa [deterministicExpectedCumulative] using
    (coarse_stoppedCollapseWithFailureBound_of_micro_initialExpectedMargin
      (μ := μ) hcomp Acoarse hθ hmargin₀_micro')

/-- Deterministic coarse-grained direct hitting-time event bound. -/
theorem deterministic_coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro)
    (Acoarse :
      ResourceBoundedStepModelAzuma
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse))
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin_micro : -Real.log θ ≤ cumulativeTotalProduction Bmicro k - r) :
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
  have hmargin_micro' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro k - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) Bmicro k]
    exact hmargin_micro
  simpa [deterministicExpectedCumulative] using
    (coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
      (μ := μ) hcomp Acoarse hkN hmargin_micro')

/-- Deterministic coarse-grained initial-margin direct hitting-time event bound. -/
theorem deterministic_coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_initialExpectedMargin
    (cg : Survival.CoarseGraining.AdmissibleCoarseGraining P Q)
    (hs : Survival.CoarseGraining.UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : Survival.CoarseTotalProduction.CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro)
    (Acoarse :
      ResourceBoundedStepModelAzuma
        (μ := μ) (deterministicStepModel (μ := μ) Bcoarse))
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀_micro : -Real.log θ ≤ cumulativeTotalProduction Bmicro 0 - r) :
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
  have hmargin₀_micro' :
      -Real.log θ ≤ deterministicExpectedCumulative (μ := μ) Bmicro 0 - r := by
    rw [deterministicExpectedCumulative, deterministic_expectedCumulative_eq (μ := μ) Bmicro 0]
    exact hmargin₀_micro
  simpa [deterministicExpectedCumulative] using
    (coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_initialExpectedMargin
      (μ := μ) hcomp Acoarse hkN hmargin₀_micro')

end DeterministicCoarseTransfer

end

end Survival.ResourceBoundedStochasticCollapse
