import Survival.SATPositiveDriftCollapse
import Survival.MartingaleDrift

/-!
# SAT Unconditional Tendency

This module records the first expectation-level law-of-tendency statement for
the random 3-SAT drift extracted in `SATDriftLowerBound`.

The important point is conceptual: the drift is no longer an externally chosen
parameter. It is the domain-specific quantity `log (8 / 7)` derived from the
first-moment information loss of a uniform random 3-clause.

From that explicit drift we obtain:

* exact one-step expected drift;
* submartingale-like expected monotonicity;
* an exact linear lower bound on expected cumulative total production.
-/

namespace Survival.SATUnconditionalTendency

open MeasureTheory
open Survival.SATDriftLowerBound
open Survival.SATPositiveDriftCollapse
open Survival.MartingaleDrift

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- In the SAT specialization, the expected one-step total-production drift is
exactly the explicit random-3-SAT drift. -/
theorem expectedIncrement_eq_random3ClauseDrift
    (s₀ : ℝ) (t : ℕ) :
    ((random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expectedIncrement t) =
      random3ClauseDrift := by
  have hsucc :=
    ((random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expected_succ t)
  rw [expectedCumulative_eq (μ := μ) s₀ (t + 1)] at hsucc
  rw [expectedCumulative_eq (μ := μ) s₀ t] at hsucc
  norm_num at hsucc ⊢
  linarith

/-- Therefore the SAT first-moment process is submartingale-like without any
additional externally supplied drift assumption. -/
theorem submartingaleLike_random3ClauseStepModel
    (s₀ : ℝ) :
    SubmartingaleLike
      (μ := μ)
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess := by
  intro t
  rw [expectedIncrement_eq_random3ClauseDrift (μ := μ) s₀ t]
  exact random3ClauseDrift_nonneg

/-- Hence expected cumulative total production is monotone in the SAT
first-moment specialization. -/
theorem expectedCumulative_monotone_random3ClauseStepModel
    (s₀ : ℝ) :
    Monotone
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expectedCumulative := by
  exact expectedCumulative_monotone_of_submartingaleLike
    (μ := μ)
    (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess
    (submartingaleLike_random3ClauseStepModel (μ := μ) s₀)

/-- The expected cumulative total production satisfies the exact linear law
with slope `log (8 / 7)`, and therefore in particular the corresponding lower
bound. -/
theorem expectedCumulative_lower_linear_random3ClauseStepModel
    (s₀ : ℝ) (n : ℕ) :
    s₀ + (n : ℝ) * random3ClauseDrift ≤
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expectedCumulative n := by
  rw [expectedCumulative_eq (μ := μ) s₀ n]

/-- Since the SAT drift is strictly positive, the one-step expected drift is
strictly positive at every step. -/
theorem expectedIncrement_pos_random3ClauseStepModel
    (s₀ : ℝ) (t : ℕ) :
    0 <
      (random3ClauseStepModel (μ := μ) s₀).toStochasticProcess.toExpectedProcess.expectedIncrement t := by
  rw [expectedIncrement_eq_random3ClauseDrift (μ := μ) s₀ t]
  exact random3ClauseDrift_pos

end

end Survival.SATUnconditionalTendency
