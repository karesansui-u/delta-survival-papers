import Survival.TotalProduction
import Survival.ResourceBudgetToSigmaDrift
import Survival.CoarseTypicalNondecrease

/-!
# Reader-facing `Σ` / Total-Production Wrappers

This module gives second-law-roadmap names to the already proved
total-production facts.

It deliberately adds no new mathematical substance.  The underlying algebra is
in `Survival.TotalProduction`; the expectation-level drift bridge is in
`Survival.ResourceBudgetToSigmaDrift`; and the coarse expected nondecrease
wrappers are in `Survival.CoarseTypicalNondecrease`.

The purpose is reader-facing access: paper and supplement prose can point to
stable theorem names such as `sigma_equals_B_plus_C`,
`sigma_at_least_L`, and `expected_sigma_drift_lower_bound`.
-/

namespace Survival.SecondLawTotalProduction

open MeasureTheory
open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.StochasticTotalProduction
open Survival.ResourceBudgetToSigmaDrift
open Survival.CoarseTypicalNondecrease

noncomputable section

variable {Ω X : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Reader-facing abbreviation for the expected `Σ` process obtained by
deterministically embedding a repair-budgeted structural system into a
probability space. -/
abbrev deterministicExpectedSigmaProcess {P : ProblemSpec X}
    (B : RepairBudget P) :=
  (deterministicStepModel (μ := μ) B).toStochasticProcess.toExpectedProcess

/-- Reader-facing name for the definition `Σ_n = B_n + C_n`: cumulative total
production is cumulative net action plus cumulative resource cost. -/
theorem sigma_equals_B_plus_C {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeNetAction P n + cumulativeCost B n := rfl

/-- Reader-facing name for the decomposition `Σ_n = L_n + slack_n`. -/
theorem sigma_equals_L_plus_repair_slack {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeLoss P n + cumulativeRepairSlack B n :=
  cumulativeTotalProduction_eq_cumulativeLoss_add_cumulativeRepairSlack B n

/-- Reader-facing name for the conservative inequality: when repair gain must
be paid for by resource cost, total production dominates contraction loss. -/
theorem sigma_at_least_L {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeLoss P n ≤ cumulativeTotalProduction B n :=
  cumulativeLoss_le_cumulativeTotalProduction B n

/-- Reader-facing name for the exact-payment special case: if each repair gain
is paid exactly, total production collapses to cumulative contraction loss. -/
theorem sigma_equals_L_under_exact_payment {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ)
    (hexact : ∀ t, B.stepCost t = stepGain P t) :
    cumulativeTotalProduction B n = cumulativeLoss P n :=
  cumulativeTotalProduction_eq_cumulativeLoss_of_exact_payment B n hexact

/-- Reader-facing name for the expectation-level drift bridge:
resource budget plus a one-step contraction lower bound gives a one-step
expected `Σ` lower bound. -/
theorem expected_sigma_drift_lower_bound {P : ProblemSpec X}
    (B : RepairBudget P) {t : ℕ} {α : ℝ}
    (hloss : α ≤ stepLoss P t) :
    α ≤ (deterministicExpectedSigmaProcess (μ := μ) B).expectedIncrement t :=
  expectedIncrement_lowerBound_of_stepLoss_lowerBound (μ := μ) B hloss

/-- Reader-facing name for the cumulative expected lower bound inherited from
a uniform typical-contraction lower bound. -/
theorem expected_cumulative_sigma_lower_bound {P : ProblemSpec X}
    (B : RepairBudget P) {α : ℝ}
    (hcontr : TypicalContractionLowerBound P α) (n : ℕ) :
    cumulativeTotalProduction B 0 + (n : ℝ) * α ≤
      (deterministicExpectedSigmaProcess (μ := μ) B).expectedCumulative n :=
  expectedCumulative_lowerBound_of_typicalContraction (μ := μ) B hcontr n

/-- Reader-facing name for the expectation-level monotonicity schema:
nonnegative typical contraction makes expected cumulative `Σ` monotone in the
deterministic stochastic embedding. -/
theorem expected_sigma_monotone_of_nonnegative_typical_contraction
    {P : ProblemSpec X} (B : RepairBudget P) {α : ℝ}
    (hα : 0 ≤ α)
    (hcontr : TypicalContractionLowerBound P α) :
    Monotone (deterministicExpectedSigmaProcess (μ := μ) B).expectedCumulative :=
  expectedCumulative_monotone_of_nonneg_typicalContraction
    (μ := μ) B hα hcontr

end

end Survival.SecondLawTotalProduction
