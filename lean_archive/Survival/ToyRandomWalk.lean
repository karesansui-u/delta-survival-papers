import Survival.CoarseTypicalNondecrease

/-!
Toy Random Walk
最小の stochastic total-production 具体例

This module gives a genuinely stochastic, but deliberately lightweight,
concrete instance of the total-production formalism.

The model is a random walk with:

* constant initial value `s₀`;
* zero stochastic net action;
* arbitrary nonnegative integrable stochastic increments `ξ_t`.

So the cumulative total production is

  `Σ_n(ω) = s₀ + ∑_{t < n} ξ_t(ω)`.

This is still much simpler than a full Markov repair process, but it is
already non-deterministic and sufficient to show that the coarse typical
nondecrease layer applies to an actual stochastic family, not only to constant
processes.
-/

open scoped BigOperators
open Finset

namespace Survival.ToyRandomWalk

open MeasureTheory
open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.CoarseTypicalNondecrease

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Nonnegative integrable stochastic increments for a toy total-production
walk. -/
structure IncrementProcess where
  incrementRV : ℕ → Ω → ℝ
  integrable_increment : ∀ t, Integrable (incrementRV t) μ
  ae_nonnegative_increment : ∀ t, 0 ≤ᵐ[μ] incrementRV t

/-- The associated stochastic total-production step model:
all randomness sits in the step cost, while the net action is zero. -/
def stepModel (s₀ : ℝ) (W : IncrementProcess (μ := μ)) : StepModel (μ := μ) where
  initialRV := fun _ => s₀
  stepNetActionRV _ := fun _ => 0
  stepCostRV := W.incrementRV
  integrable_initial := integrable_const s₀
  integrable_stepNetAction := by
    intro _
    simp
  integrable_stepCost := W.integrable_increment

theorem stepTotalProductionRV_eq_increment
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) (t : ℕ) :
    stepTotalProductionRV (stepModel (μ := μ) s₀ W) t = W.incrementRV t := by
  funext ω
  simp [stepTotalProductionRV, stepModel]

theorem cumulativeTotalProductionRV_eq_initial_add_sum
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) :
    ∀ n,
      cumulativeTotalProductionRV (stepModel (μ := μ) s₀ W) n =
        fun ω => s₀ + Finset.sum (Finset.range n) (fun t => W.incrementRV t ω)
  | 0 => by
      funext ω
      simp [cumulativeTotalProductionRV, stepModel]
  | n + 1 => by
      funext ω
      rw [cumulativeTotalProductionRV,
        cumulativeTotalProductionRV_eq_initial_add_sum s₀ W n,
        stepTotalProductionRV_eq_increment (μ := μ) s₀ W n]
      simp [Finset.sum_range_succ, add_left_comm, add_comm]

theorem expectedIncrement_eq_integral_increment
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) (t : ℕ) :
    (stepModel (μ := μ) s₀ W).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      ∫ ω, W.incrementRV t ω ∂μ := by
  change ∫ ω, stepTotalProductionRV (stepModel (μ := μ) s₀ W) t ω ∂μ =
      ∫ ω, W.incrementRV t ω ∂μ
  rw [stepTotalProductionRV_eq_increment (μ := μ) s₀ W t]

theorem expectedCumulative_eq_initial_add_sum
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) :
    ∀ n,
      (stepModel (μ := μ) s₀ W).toStochasticProcess.toExpectedProcess.expectedCumulative n =
        s₀ + Finset.sum (Finset.range n) (fun t => ∫ ω, W.incrementRV t ω ∂μ)
  | 0 => by
      change ∫ ω, cumulativeTotalProductionRV (stepModel (μ := μ) s₀ W) 0 ω ∂μ = s₀ + 0
      simp [cumulativeTotalProductionRV, stepModel]
  | n + 1 => by
      rw [(stepModel (μ := μ) s₀ W).toStochasticProcess.toExpectedProcess.expected_succ n]
      rw [expectedCumulative_eq_initial_add_sum s₀ W n]
      rw [expectedIncrement_eq_integral_increment (μ := μ) s₀ W n]
      rw [Finset.sum_range_succ]
      ring

/-- The toy walk is resource-bounded in the stochastic sense: one-step total
production is almost surely nonnegative. -/
theorem ae_nonnegative_stepTotalProduction
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) :
    AENonnegativeStepTotalProduction (μ := μ) (stepModel (μ := μ) s₀ W) := by
  intro t
  simpa [stepTotalProductionRV_eq_increment (μ := μ) s₀ W t] using
    W.ae_nonnegative_increment t

/-- Therefore expected cumulative total production is monotone. -/
theorem expectedCumulative_monotone
    (s₀ : ℝ) (W : IncrementProcess (μ := μ)) :
    Monotone (stepModel (μ := μ) s₀ W).toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (stepModel (μ := μ) s₀ W)
    (ae_nonnegative_stepTotalProduction (μ := μ) s₀ W)

/-- The coarse-grained typical nondecrease theorem applies directly to the toy
random walk. -/
theorem coarse_expectedCumulative_monotone
    (s₀ : ℝ) (W : IncrementProcess (μ := μ))
    {Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) (stepModel (μ := μ) s₀ W) Scoarse) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  coarse_expectedCumulative_monotone_of_micro_nonnegative
    hcomp (ae_nonnegative_stepTotalProduction (μ := μ) s₀ W)

end

end Survival.ToyRandomWalk
