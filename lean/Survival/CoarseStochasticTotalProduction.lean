import Survival.StochasticTotalProduction
import Survival.CoarseTotalProduction

/-!
Coarse Stochastic Total Production
coarse-grained typical nondecrease の確率版

This module lifts the coarse-grained total-production story to actual
probability spaces.

The key interface is a conservative compatibility notion between a micro
stochastic total-production model and a coarse one:

* the initial random variables agree almost everywhere;
* the one-step net action random variables agree almost everywhere;
* the one-step cost random variables agree almost everywhere.

Under this compatibility, cumulative total production agrees almost everywhere,
so expected cumulative total production is preserved. As a result, any
micro-level expected monotonicity transfers to the coarse level.

The deterministic coarse-grained theorems from the previous modules are then
recovered as a special case by embedding both micro and coarse dynamics as
constant stochastic processes.
-/

open MeasureTheory

namespace Survival.CoarseStochasticTotalProduction

open Survival.GeneralStateDynamics
open Survival.CoarseGraining
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.CoarseTotalProduction
open Survival.ResourceBoundedDynamics
open Survival.ProbabilityConnection
open Survival.StochasticTotalProduction

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Compatibility between a micro stochastic total-production model and a
coarse one. This is the probability-space version of coarse-grained invariance:
the initial value, one-step net action, and one-step cost agree almost
everywhere. -/
structure CoarseStochasticCompatibility
    (Smicro Scoarse : StepModel (μ := μ)) : Prop where
  initial_ae : Scoarse.initialRV =ᵐ[μ] Smicro.initialRV
  stepNetAction_ae : ∀ t, Scoarse.stepNetActionRV t =ᵐ[μ] Smicro.stepNetActionRV t
  stepCost_ae : ∀ t, Scoarse.stepCostRV t =ᵐ[μ] Smicro.stepCostRV t

theorem stepTotalProductionRV_ae
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (t : ℕ) :
    stepTotalProductionRV Scoarse t =ᵐ[μ] stepTotalProductionRV Smicro t := by
  filter_upwards [hcomp.stepNetAction_ae t, hcomp.stepCost_ae t] with ω hA hC
  simp [stepTotalProductionRV, hA, hC]

theorem cumulativeTotalProductionRV_ae
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse) :
    ∀ n, cumulativeTotalProductionRV Scoarse n =ᵐ[μ] cumulativeTotalProductionRV Smicro n
  | 0 => hcomp.initial_ae
  | n + 1 => by
      filter_upwards
        [cumulativeTotalProductionRV_ae hcomp n, stepTotalProductionRV_ae hcomp n] with ω hcum hstep
      simp [cumulativeTotalProductionRV, hcum, hstep]

theorem expectedIncrement_eq
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (t : ℕ) :
    Scoarse.toStochasticProcess.toExpectedProcess.expectedIncrement t =
      Smicro.toStochasticProcess.toExpectedProcess.expectedIncrement t := by
  change ∫ ω, stepTotalProductionRV Scoarse t ω ∂μ = ∫ ω, stepTotalProductionRV Smicro t ω ∂μ
  exact integral_congr_ae (stepTotalProductionRV_ae hcomp t)

theorem expectedCumulative_eq
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (n : ℕ) :
    Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative n =
      Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative n := by
  change
    ∫ ω, cumulativeTotalProductionRV Scoarse n ω ∂μ =
      ∫ ω, cumulativeTotalProductionRV Smicro n ω ∂μ
  exact integral_congr_ae (cumulativeTotalProductionRV_ae hcomp n)

theorem coarse_expectedCumulative_monotone_of_micro
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (hmono : Monotone Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative := by
  intro m n hmn
  rw [expectedCumulative_eq hcomp m, expectedCumulative_eq hcomp n]
  exact hmono hmn

/-- Probability-space coarse typical nondecrease:
if micro one-step total production is almost surely nonnegative and the coarse
stochastic model is compatible with the micro one, then coarse expected
cumulative total production is monotone. -/
theorem coarse_expectedCumulative_monotone_of_micro_ae_nonnegative
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (hStep : AENonnegativeStepTotalProduction (μ := μ) Smicro) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative := by
  apply coarse_expectedCumulative_monotone_of_micro hcomp
  exact expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction Smicro hStep

section DeterministicEmbedding

variable [IsProbabilityMeasure μ]
variable {X Y : Type*}
variable {P : ProblemSpec X} {Q : ProblemSpec Y}

theorem deterministic_coarseCompatibility
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    CoarseStochasticCompatibility
      (μ := μ)
      (deterministicStepModel (μ := μ) Bmicro)
      (deterministicStepModel (μ := μ) Bcoarse) := by
  refine
    { initial_ae := ?_
      stepNetAction_ae := ?_
      stepCost_ae := ?_ }
  · refine Filter.Eventually.of_forall ?_
    intro ω
    change cumulativeTotalProduction Bcoarse 0 = cumulativeTotalProduction Bmicro 0
    simpa using
      (cumulativeTotalProduction_preserved cg hs hB 0 (toPositiveTrajectory R 0))
  · intro t
    refine Filter.Eventually.of_forall ?_
    intro ω
    change stepNetAction Q t = stepNetAction P t
    exact stepNetAction_preserved cg hs t
      (R.feasible_pos t)
      (R.contracted_pos t)
      (R.feasible_pos (t + 1))
  · intro t
    refine Filter.Eventually.of_forall ?_
    intro ω
    change Bcoarse.stepCost t = Bmicro.stepCost t
    exact hB.stepCost_eq t

theorem deterministic_coarse_expectedCumulative_eq
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro)
    (n : ℕ) :
    deterministicExpectedCumulative (μ := μ) Bcoarse n =
      deterministicExpectedCumulative (μ := μ) Bmicro n := by
  exact expectedCumulative_eq (deterministic_coarseCompatibility (μ := μ) cg hs hB R) n

theorem deterministic_coarse_expectedCumulative_monotone
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : RepairBudget P} {Bcoarse : RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    Monotone (deterministicExpectedCumulative (μ := μ) Bcoarse) := by
  apply coarse_expectedCumulative_monotone_of_micro_ae_nonnegative
    (μ := μ)
    (Smicro := deterministicStepModel (μ := μ) Bmicro)
    (Scoarse := deterministicStepModel (μ := μ) Bcoarse)
  · exact deterministic_coarseCompatibility (μ := μ) cg hs hB R
  · exact deterministic_ae_nonnegative_stepTotalProduction (μ := μ) Bmicro R

end DeterministicEmbedding

end

end Survival.CoarseStochasticTotalProduction
