import Survival.ResourceBudgetToTotalProductionDrift
import Survival.StochasticTotalProduction
import Survival.MartingaleDrift

/-!
# Resource Budget to `Σ` Drift

This module upgrades the pointwise bridge from
`ResourceBudgetToTotalProductionDrift` to the expectation-level drift language.

The key reading is:

* a resource budget makes repair slack nonnegative;
* a domain-specific lower bound on contraction loss then lifts to the same
  lower bound on one-step total production;
* after deterministic embedding into an actual probability space, this becomes
  a lower bound on the expected one-step `Σ` drift.

This is the generic place where

  ResourceBudget + TypicalContractionLowerBound

turns into

  E[ΔΣ_t] ≥ α.
-/

namespace Survival.ResourceBudgetToSigmaDrift

open MeasureTheory
open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBudgetToTotalProductionDrift
open Survival.StochasticTotalProduction
open Survival.MartingaleDrift

noncomputable section

variable {Ω X : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- A domain-specific lower bound on one-step contraction loss. -/
def TypicalContractionLowerBound (P : ProblemSpec X) (α : ℝ) : Prop :=
  ∀ t, α ≤ stepLoss P t

/-- In the deterministic embedding, the expected one-step total production is
exactly the deterministic one-step total production. -/
theorem deterministic_expectedIncrement_eq
    {P : ProblemSpec X} (B : RepairBudget P) (t : ℕ) :
    (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      stepTotalProduction B t := by
  change
    ∫ ω, stepTotalProductionRV (μ := μ) (deterministicStepModel (μ := μ) B) t ω ∂μ =
      stepTotalProduction B t
  rw [deterministic_stepTotalProductionRV_eq_const (μ := μ) B t]
  exact Survival.ProbabilityConnection.expected_constant_eq
    (μ := μ) (stepTotalProduction B t)

/-- Therefore any lower bound on one-step contraction loss lifts to a lower
bound on the expected one-step total-production drift. -/
theorem expectedIncrement_lowerBound_of_stepLoss_lowerBound
    {P : ProblemSpec X} (B : RepairBudget P) {t : ℕ} {α : ℝ}
    (hloss : α ≤ stepLoss P t) :
    α ≤
      (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedIncrement t := by
  rw [deterministic_expectedIncrement_eq (μ := μ) B t]
  exact stepTotalProduction_lowerBound_of_stepLoss_lowerBound B hloss

/-- Uniform contraction lower bounds yield an expectation-level lower drift
bound for deterministic total production. -/
theorem expectedDriftLowerBound_of_typicalContraction
    {P : ProblemSpec X} (B : RepairBudget P) {α : ℝ}
    (hcontr : TypicalContractionLowerBound P α) :
    ExpectedDriftLowerBound
      (μ := μ)
      (deterministicStepModel (μ := μ) B).toStochasticProcess
      (fun _ => α) := by
  intro t
  exact expectedIncrement_lowerBound_of_stepLoss_lowerBound (μ := μ) B (hcontr t)

/-- The cumulative expected total production inherits the same linear lower
bound. -/
theorem expectedCumulative_lowerBound_of_typicalContraction
    {P : ProblemSpec X} (B : RepairBudget P) {α : ℝ}
    (hcontr : TypicalContractionLowerBound P α) (n : ℕ) :
    cumulativeTotalProduction B 0 + (n : ℝ) * α ≤
      (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedCumulative n := by
  have hlower :=
    expectedCumulative_lower_bound_of_expectedDriftLowerBound
      (μ := μ)
      ((deterministicStepModel (μ := μ) B).toStochasticProcess)
      (d := fun _ => α)
      (expectedDriftLowerBound_of_typicalContraction (μ := μ) B hcontr)
      n
  rw [deterministic_expectedCumulative_eq (μ := μ) B 0] at hlower
  calc
    cumulativeTotalProduction B 0 + (n : ℝ) * α
        = cumulativeTotalProduction B 0 + ∑ t ∈ Finset.range n, α := by
            simp
    _ ≤ (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedCumulative n :=
      hlower

/-- If the contraction lower bound itself is nonnegative, then deterministic
total production is submartingale-like at the expectation level. -/
theorem submartingaleLike_of_nonneg_typicalContraction
    {P : ProblemSpec X} (B : RepairBudget P) {α : ℝ}
    (hα : 0 ≤ α)
    (hcontr : TypicalContractionLowerBound P α) :
    SubmartingaleLike
      (μ := μ)
      (deterministicStepModel (μ := μ) B).toStochasticProcess := by
  intro t
  have hstep :=
    expectedIncrement_lowerBound_of_stepLoss_lowerBound
      (μ := μ) B (hcontr t)
  linarith

/-- Hence the expected cumulative total production is monotone. -/
theorem expectedCumulative_monotone_of_nonneg_typicalContraction
    {P : ProblemSpec X} (B : RepairBudget P) {α : ℝ}
    (hα : 0 ≤ α)
    (hcontr : TypicalContractionLowerBound P α) :
    Monotone
      (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedCumulative := by
  exact expectedCumulative_monotone_of_submartingaleLike
    (μ := μ)
    (deterministicStepModel (μ := μ) B).toStochasticProcess
    (submartingaleLike_of_nonneg_typicalContraction (μ := μ) B hα hcontr)

/-- If the contraction lower bound is strictly positive, then the expected
one-step total-production drift is strictly positive as well. -/
theorem expectedIncrement_pos_of_pos_typicalContraction
    {P : ProblemSpec X} (B : RepairBudget P) {t : ℕ} {α : ℝ}
    (hα : 0 < α)
    (hcontr : TypicalContractionLowerBound P α) :
    0 <
      (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess.expectedIncrement t := by
  have hstep :=
    expectedIncrement_lowerBound_of_stepLoss_lowerBound
      (μ := μ) B (hcontr t)
  linarith

end

end Survival.ResourceBudgetToSigmaDrift
