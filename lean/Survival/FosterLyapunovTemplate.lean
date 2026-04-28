import Survival.LyapunovBalanceEmbedding
import Survival.QueueStability
import Survival.ResourceBoundedConditionalAzuma
import Survival.CoarseTypicalNondecrease

/-!
# Foster-Lyapunov / Queueing Template Wrappers

Phase 6.1 reader-facing wrappers for the second limited-class template.

This file deliberately adds no positive-recurrence theorem, no geometric
ergodicity theorem, and no unconditional Lyapunov "second law".  It only gives
stable names to the existing algebraic and conditional-Azuma anchors:

* Lyapunov/load increments as signed structural action;
* queue overload as a deterministic finite-prefix skeleton;
* conditional-Azuma data as an expectation-level and stopped-collapse route;
* coarse expectation-level transfer under explicit stochastic compatibility.
-/

open scoped ProbabilityTheory
open MeasureTheory

namespace Survival.FosterLyapunovTemplate

noncomputable section

open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.ResourceBoundedConditionalAzuma

/-- Reader-facing Phase-6 name: Lyapunov/load cumulative action telescopes to
final load minus initial load. -/
theorem lyapunov_cumulativeAction_eq_load_diff
    (Z : ℕ → ℝ) (n : ℕ) :
    Survival.LyapunovBalanceEmbedding.cumulativeAction Z n = Z n - Z 0 :=
  Survival.LyapunovBalanceEmbedding.cumulativeAction_eq_load_diff Z n

/-- Reader-facing Phase-6 name: a Lyapunov/load increment is the difference
between its positive structural-consumption part and its recovery part. -/
theorem lyapunov_increment_eq_consumption_sub_recovery
    (Z : ℕ → ℝ) (t : ℕ) :
    Survival.LyapunovBalanceEmbedding.increment Z t =
      Survival.LyapunovBalanceEmbedding.consumptionAmount Z t -
        Survival.LyapunovBalanceEmbedding.recoveryAmount Z t :=
  Survival.LyapunovBalanceEmbedding.increment_eq_consumptionAmount_sub_recoveryAmount Z t

/-- Reader-facing Phase-6 name: the exponential maintenance coordinate obeys
the local signed-action update. -/
theorem lyapunov_relativeMaintenance_succ_eq_mul_exp_neg_increment
    (Z : ℕ → ℝ) (t : ℕ) :
    Survival.LyapunovBalanceEmbedding.relativeMaintenance Z (t + 1) =
      Survival.LyapunovBalanceEmbedding.relativeMaintenance Z t *
        Real.exp (-(Survival.LyapunovBalanceEmbedding.increment Z t)) :=
  Survival.LyapunovBalanceEmbedding.relativeMaintenance_succ_eq_mul_exp_neg_increment Z t

/-- Reader-facing Phase-6 name: in the fluid queue skeleton, the load increment
is exactly arrival minus service. -/
theorem queue_increment_eq_excessDemand
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ) :
    Survival.LyapunovBalanceEmbedding.increment
        (Survival.LyapunovBalanceEmbedding.queueLoad Q initial) n =
      Survival.QueueStability.excessDemand Q :=
  Survival.LyapunovBalanceEmbedding.queue_increment_eq_excessDemand Q initial n

/-- Reader-facing Phase-6 name: queue cumulative action is deterministic
cumulative overload loss. -/
theorem queue_cumulativeAction_eq_cumulativeOverloadLoss
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ) :
    Survival.LyapunovBalanceEmbedding.cumulativeAction
        (Survival.LyapunovBalanceEmbedding.queueLoad Q initial) n =
      Survival.QueueStability.cumulativeOverloadLoss Q n :=
  Survival.LyapunovBalanceEmbedding.queue_cumulativeAction_eq_cumulativeOverloadLoss
    Q initial n

/-- Stable fluid queue: the structural load increment is nonpositive. -/
theorem queue_stable_increment_nonpos
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ)
    (hstable : Q.arrivalRate ≤ Q.serviceRate) :
    Survival.LyapunovBalanceEmbedding.increment
        (Survival.LyapunovBalanceEmbedding.queueLoad Q initial) n ≤ 0 :=
  Survival.LyapunovBalanceEmbedding.queue_increment_nonpos_of_stable
    Q initial n hstable

/-- Overloaded fluid queue: the structural load increment is positive. -/
theorem queue_overloaded_increment_pos
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ)
    (hover : Q.serviceRate < Q.arrivalRate) :
    0 <
      Survival.LyapunovBalanceEmbedding.increment
        (Survival.LyapunovBalanceEmbedding.queueLoad Q initial) n :=
  Survival.LyapunovBalanceEmbedding.queue_increment_pos_of_overloaded
    Q initial n hover

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Conditional-Azuma data give expectation-level monotonicity for cumulative
`Σ`.  This is the Foster-Lyapunov / queueing Phase-6 counterpart of the
Bernoulli expectation-level tendency wrapper, under explicit martingale and
bounded-increment assumptions. -/
theorem expectedSigma_monotone_of_conditionalAzuma
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : Survival.ResourceBoundedConditionalAzuma.StepModelConditionalAzumaData
      (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration] :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  Survival.ResourceBoundedConditionalAzuma.expectedCumulative_monotone_of_conditionalAzuma
    (μ := μ) A

/-- Conditional-Azuma data plus an initial expected margin give a stopped
collapse failure-bound wrapper.  This is not an unconditional recurrence or
ergodicity theorem. -/
theorem fosterLyapunov_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : Survival.ResourceBoundedConditionalAzuma.StepModelConditionalAzumaData
      (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration]
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeHighProbabilityCollapse.StoppedCollapseWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) N r) :=
  stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (μ := μ) A hθ hmargin₀

/-- Conditional-Azuma data plus an initial expected margin give a direct
hitting-time failure-bound wrapper. -/
theorem fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    [IsFiniteMeasure μ]
    {S : StepModel (μ := μ)}
    (A : Survival.ResourceBoundedConditionalAzuma.StepModelConditionalAzumaData
      (μ := μ) S)
    [SigmaFiniteFiltration μ A.filtration]
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeCollapseEvent.HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (μ := μ) A hkN hmargin₀

/-- Coarse expectation-level monotonicity transfers under explicit stochastic
compatibility and conditional-Azuma data.  This is a conditional coarse
tendency wrapper, not an unconditional coarse-graining DPI. -/
theorem coarseExpectedSigma_monotone_of_conditionalAzuma
    [IsFiniteMeasure μ]
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp :
      Survival.CoarseStochasticTotalProduction.CoarseStochasticCompatibility
        (μ := μ) Smicro Scoarse)
    (A : Survival.ResourceBoundedConditionalAzuma.StepModelConditionalAzumaData
      (μ := μ) Smicro)
    [SigmaFiniteFiltration μ A.filtration] :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  Survival.CoarseTypicalNondecrease.coarse_expectedCumulative_monotone_of_micro_conditionalAzuma
    (μ := μ) hcomp A

end

end Survival.FosterLyapunovTemplate
