import Survival.SATStateDependentClauseExposure
import Survival.MartingaleDrift

/-!
# SAT State-Dependent Unconditional Tendency

This module upgrades `SATUnconditionalTendency` from the constant-drift wrapper
to the actual clause-exposure path space with a genuinely non-flat observable.

The key point is that the probability space is now the recursive finite-horizon
SAT clause-exposure law from `SATClauseExposureProcess`, while the total
production observable is the realized-outcome dependent emission

* `sat ↦ 0`
* `unsat ↦ 8 * log (8 / 7)`.

Even on this non-flat actual process, the first-moment calculation still yields
the same expectation-level tendency law on the active prefix.
-/

namespace Survival.SATStateDependentUnconditionalTendency

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.MartingaleDrift

noncomputable section

/-- Outside the active finite horizon, the default extension uses the benign
outcome `sat`, so the expected one-step drift vanishes. -/
theorem expectedIncrement_eq_zero_of_not_le
    (N : ℕ) (s₀ : ℝ) {t : ℕ} (ht : ¬ t ≤ N) :
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      0 := by
  rw [expectedIncrement_eq_sat_of_not_le N s₀ oneSidedUnsatEmission ht]
  simp [oneSidedUnsatEmission]

/-- On the active prefix, the realized-outcome dependent SAT process still has
strictly positive expected one-step drift. -/
theorem expectedIncrement_pos_of_le
    (N : ℕ) (s₀ : ℝ) {t : ℕ} (ht : t ≤ N) :
    0 <
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedIncrement t := by
  rw [expectedIncrement_eq_random3ClauseDrift_of_le N s₀ ht]
  exact random3ClauseDrift_pos

/-- Therefore the non-flat actual SAT clause-exposure process is
submartingale-like without any externally supplied drift parameter. -/
theorem submartingaleLike_stepModel
    (N : ℕ) (s₀ : ℝ) :
    SubmartingaleLike
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess := by
  intro t
  by_cases ht : t ≤ N
  · rw [expectedIncrement_eq_random3ClauseDrift_of_le N s₀ ht]
    exact random3ClauseDrift_nonneg
  · rw [expectedIncrement_eq_zero_of_not_le N s₀ ht]

/-- Hence expected cumulative total production is monotone on the actual
non-flat SAT clause-exposure process. -/
theorem expectedCumulative_monotone_stepModel
    (N : ℕ) (s₀ : ℝ) :
    Monotone
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative := by
  exact expectedCumulative_monotone_of_submartingaleLike
    (μ := pathMeasure N)
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
    (submartingaleLike_stepModel N s₀)

/-- The exact linear center on the active prefix, now recorded as the
expectation-level law-of-tendency statement for the non-flat actual SAT
clause-exposure process. -/
theorem expectedCumulative_eq_initial_add_linear
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) :
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (n : ℝ) * random3ClauseDrift :=
  expectedCumulative_eq_initial_add_linear_of_le N s₀ hn

end

end Survival.SATStateDependentUnconditionalTendency
