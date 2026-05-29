import Survival.CoarseStochasticTotalProduction
import Survival.CoarseTotalProduction
import Survival.TotalProduction
import Survival.ResourceBoundedStochasticCollapse
import Survival.ResourceBoundedConditionalAzuma

/-!
Coarse Typical Nondecrease
coarse-grained typical nondecrease の主定理層

This module packages the main monotonicity statements that correspond most
directly to the supplement's target theorem on coarse-grained typical
nondecrease.

The point is not to add new probability machinery, but to expose the existing
stack in the mathematically natural order:

* micro almost-sure nonnegative total production
* resource-bounded micro dynamics
* conditional-Azuma / submartingale drift
* deterministic coarse-grained special case

All of these routes end in monotonicity of the coarse expected cumulative total
production, which is the current Lean-level proxy for a second-law-like
"law of tendency".
-/

namespace Survival.CoarseTypicalNondecrease

open MeasureTheory
open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.ResourceBoundedStochasticCollapse
open Survival.ResourceBoundedConditionalAzuma
open Survival.GeneralStateDynamics
open Survival.CoarseGraining
open Survival.CoarseTotalProduction
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- The most direct coarse typical nondecrease theorem:
if the micro stochastic total-production process has almost surely nonnegative
one-step total production and the coarse process is compatible with it, then
coarse expected cumulative total production is monotone. -/
theorem coarse_expectedCumulative_monotone_of_micro_nonnegative
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (hStep : AENonnegativeStepTotalProduction (μ := μ) Smicro) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  coarse_expectedCumulative_monotone_of_micro_ae_nonnegative hcomp hStep

/-- Resource-bounded micro dynamics imply coarse typical nondecrease. -/
theorem coarse_expectedCumulative_monotone_of_micro_resourceBounded
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (A : ResourceBoundedStepModelAzuma (μ := μ) Smicro) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  coarse_expectedCumulative_monotone_of_micro_nonnegative
    hcomp A.ae_nonnegative_stepTotalProduction

/-- Conditional submartingale drift on the micro dynamics implies coarse
expected monotonicity. This is the coarse-grained, expectation-level shadow of
the conditional-Azuma route to high-probability collapse bounds. -/
theorem coarse_expectedCumulative_monotone_of_micro_conditionalAzuma
    [IsFiniteMeasure μ]
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (A : StepModelConditionalAzumaData (μ := μ) Smicro)
    [SigmaFiniteFiltration μ A.filtration] :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative := by
  apply coarse_expectedCumulative_monotone_of_micro hcomp
  exact expectedCumulative_monotone_of_conditionalAzuma (μ := μ) A

section DeterministicEmbedding

variable [IsProbabilityMeasure μ]
variable {X Y : Type*}
variable {P : ProblemSpec X} {Q : ProblemSpec Y}

/-- Deterministic coarse typical nondecrease:
under admissible coarse-graining, uniform mass scaling, and cost-invariant
budgeting, coarse cumulative total production is monotone whenever the micro
dynamics is resource-bounded. -/
theorem deterministic_coarse_cumulativeTotalProduction_monotone
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    Monotone (cumulativeTotalProduction Bcoarse) :=
  ResourceBoundedDynamics.coarse_cumulativeTotalProduction_monotone cg hs hB R

/-- Deterministic embedding version phrased on the expected cumulative process
of the coarse stochastic realization. -/
theorem deterministic_coarse_expectedCumulative_monotone
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    Monotone (deterministicExpectedCumulative (μ := μ) Bcoarse) :=
  Survival.CoarseStochasticTotalProduction.deterministic_coarse_expectedCumulative_monotone
    (μ := μ) cg hs hB R

end DeterministicEmbedding

end

end Survival.CoarseTypicalNondecrease
