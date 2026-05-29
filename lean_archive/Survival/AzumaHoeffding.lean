import Survival.ConcentrationInterface
import Survival.ConditionalMartingale

/-!
Azuma / Hoeffding Concentration
Azuma / Hoeffding みたいな具体 concentration を interface に instantiate する

This module turns the abstract concentration layer into a concrete
Azuma/Hoeffding-style specialization.

We do not prove Azuma-Hoeffding from first principles here. Instead, we package
the standard one-sided tail shape

  exp ( - r^2 / (2 V_n) )

into the generic `ExpectationLowerConcentration` interface, so it can be used
immediately by the collapse machinery.

The resulting theorems are concrete operational statements:

* if the expected center stays above the collapse threshold by margin `r`,
  then collapse occurs with Azuma/Hoeffding failure bound;
* if the center process is martingale-like, the expected center can be replaced
  by the initial expectation.
-/

namespace Survival.AzumaHoeffding

open Survival.ProbabilityConnection
open Survival.MartingaleDrift
open Survival.ConcentrationInterface
open Survival.HighProbabilityCollapse

noncomputable section

open MeasureTheory

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Azuma/Hoeffding rate function with variance proxy `V_n`.

For one-sided lower-tail bounds, negative deviation budgets should not produce
failure probabilities below `1`. We therefore saturate the rate at `0` for
`r < 0`, so the induced failure profile is `1` on the negative side and the
usual Gaussian tail on the nonnegative side. -/
def azumaHoeffdingRate
    (varianceProxy : ℕ → ℝ) (n : ℕ) (r : ℝ) : ℝ :=
  if 0 ≤ r then r ^ (2 : ℕ) / (2 * varianceProxy n) else 0

/-- One-sided Azuma/Hoeffding failure profile. -/
def azumaHoeffdingFailureBound
    (varianceProxy : ℕ → ℝ) (n : ℕ) (r : ℝ) : ENNReal :=
  largeDeviationFailureBound (azumaHoeffdingRate varianceProxy) n r

/-- Concrete Azuma/Hoeffding specialization of the abstract expectation-centered
concentration interface. -/
structure AzumaHoeffdingConcentration
    (S : StochasticExpectedProcess (μ := μ))
    extends ExpectationLowerConcentration (μ := μ) S where
  varianceProxy : ℕ → ℝ
  failure_eq_azuma :
    ∀ n r, failureBound n r = azumaHoeffdingFailureBound varianceProxy n r

theorem collapseWithAzumaHoeffdingBound_of_expected_margin
    {S : StochasticExpectedProcess (μ := μ)}
    (A : AzumaHoeffdingConcentration (μ := μ) S)
    {n : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative n - r) :
    CollapseWithFailureBound (μ := μ) S n θ
      (azumaHoeffdingFailureBound A.varianceProxy n r) := by
  rcases collapseWithFailureBound_of_expected_center
      (μ := μ) A.toExpectationLowerConcentration hθ hmargin with
    ⟨E, hE, hcollapse⟩
  refine ⟨E, ?_, hcollapse⟩
  rcases hE with ⟨hmeas, hfail⟩
  refine ⟨hmeas, ?_⟩
  simpa [A.failure_eq_azuma n r] using hfail

theorem collapseWithAzumaHoeffdingBound_of_initial_margin_martingaleLike
    {S : StochasticExpectedProcess (μ := μ)}
    (A : AzumaHoeffdingConcentration (μ := μ) S)
    (hmg : MartingaleLike (μ := μ) S)
    {n : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative 0 - r) :
    CollapseWithFailureBound (μ := μ) S n θ
      (azumaHoeffdingFailureBound A.varianceProxy n r) := by
  have hconst := expectedCumulative_eq_initial_of_martingaleLike
    (μ := μ) S hmg n
  have hmargin' : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative n - r := by
    rw [hconst]
    exact hmargin
  exact collapseWithAzumaHoeffdingBound_of_expected_margin (μ := μ) A hθ hmargin'

end

end Survival.AzumaHoeffding
