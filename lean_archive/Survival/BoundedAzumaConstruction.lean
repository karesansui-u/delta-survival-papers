import Survival.AzumaHoeffding

/-!
Bounded-Increment Azuma Construction
bounded increments から AzumaHoeffdingConcentration を本当に構成する定理

This module packages the standard Azuma/Hoeffding ingredients into a concrete
constructor for `AzumaHoeffdingConcentration`.

The philosophy is conservative:

* the user provides almost-sure bounded increments;
* the user provides the corresponding good events and one-sided tail bound;
* from these ingredients we build the survival-layer concentration object.

This does not prove Azuma-Hoeffding from first principles inside this file.
Instead, it provides the exact constructor theorem needed to connect any
bounded-increment Azuma witness to the collapse machinery already formalized.
-/

namespace Survival.BoundedAzumaConstruction

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.ConcentrationInterface
open Survival.AzumaHoeffding
open Survival.HighProbabilityCollapse

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Two-sided almost-sure bounded increments. -/
def AETwoSidedBoundedIncrements
    (S : StochasticExpectedProcess (μ := μ)) (c : ℕ → ℝ) : Prop :=
  ∀ t, ∀ᵐ ω ∂μ, |S.incrementRV t ω| ≤ c t

/-- Variance proxy induced by one-step increment bounds. -/
def varianceProxyOfBounds
    (c : ℕ → ℝ) (n : ℕ) : ℝ :=
  Finset.sum (Finset.range n) (fun t => (c t) ^ (2 : ℕ))

theorem varianceProxyOfBounds_nonneg
    (c : ℕ → ℝ) (n : ℕ) :
    0 ≤ varianceProxyOfBounds c n := by
  unfold varianceProxyOfBounds
  exact Finset.sum_nonneg (by
    intro t ht
    positivity)

/-- Standard Azuma/Hoeffding witness built from bounded increments together
with a concrete lower-tail good-event family. -/
structure BoundedIncrementAzumaData
    (S : StochasticExpectedProcess (μ := μ)) where
  incrementBound : ℕ → ℝ
  incrementBound_nonneg : ∀ t, 0 ≤ incrementBound t
  boundedIncrements :
    AETwoSidedBoundedIncrements (μ := μ) S incrementBound
  goodEvent : ℕ → ℝ → Set Ω
  measurable_goodEvent : ∀ n r, MeasurableSet (goodEvent n r)
  lower_bound_on_good :
    ∀ n r ω, ω ∈ goodEvent n r →
      S.toExpectedProcess.expectedCumulative n - r ≤ S.cumulativeRV n ω
  azuma_failure_bound :
    ∀ n r, μ ((goodEvent n r)ᶜ) ≤
      azumaHoeffdingFailureBound (varianceProxyOfBounds incrementBound) n r

/-- Constructor theorem:
a bounded-increment Azuma witness yields a concrete
`AzumaHoeffdingConcentration`. -/
def BoundedIncrementAzumaData.toAzumaHoeffdingConcentration
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S) :
    AzumaHoeffdingConcentration (μ := μ) S where
  toExpectationLowerConcentration := {
    toLowerDeviationConcentration := {
      center := S.toExpectedProcess.expectedCumulative
      goodEvent := A.goodEvent
      measurable_goodEvent := A.measurable_goodEvent
      lower_bound_on_good := A.lower_bound_on_good
      failureBound := fun n r =>
        azumaHoeffdingFailureBound (varianceProxyOfBounds A.incrementBound) n r
      failure_bound := A.azuma_failure_bound
    }
    center_eq_expected := rfl
  }
  varianceProxy := varianceProxyOfBounds A.incrementBound
  failure_eq_azuma := by
    intro n r
    rfl

theorem collapseWithAzumaHoeffdingBound_of_boundedIncrementData_expectedMargin
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    {n : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative n - r) :
    Survival.HighProbabilityCollapse.CollapseWithFailureBound (μ := μ) S n θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) n r) := by
  exact collapseWithAzumaHoeffdingBound_of_expected_margin
    (μ := μ) A.toAzumaHoeffdingConcentration hθ hmargin

theorem collapseWithAzumaHoeffdingBound_of_boundedIncrementData_initialMargin
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    (hmg : Survival.MartingaleDrift.MartingaleLike (μ := μ) S)
    {n : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.HighProbabilityCollapse.CollapseWithFailureBound (μ := μ) S n θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) n r) := by
  exact collapseWithAzumaHoeffdingBound_of_initial_margin_martingaleLike
    (μ := μ) A.toAzumaHoeffdingConcentration hmg hθ hmargin

end

end Survival.BoundedAzumaConstruction
