import Survival.StoppingTimeHighProbabilityCollapse
import Survival.ConditionalMartingale

/-!
Stopping-Time Collapse Event

This module strengthens the stopping-time collapse story by turning it into a
direct event about the collapse hitting time.

The key idea is simple:

* if threshold crossing is already certified at some time `k < N`,
* then the collapse hitting time before horizon `N` must satisfy `τ < N`.

This gives a direct high-probability event-level statement for
`collapseHittingTime < N`, rather than only a statement about the stopped
value.
-/

open scoped ProbabilityTheory
open MeasureTheory

namespace Survival.StoppingTimeCollapseEvent

open Survival.ProbabilityConnection
open Survival.HighProbabilityCollapse
open Survival.ConcentrationInterface
open Survival.BoundedAzumaConstruction
open Survival.StoppingTimeCliffWarning
open Survival.ConditionalMartingale
open Survival.MartingaleDrift

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Event-level statement that the collapse hitting time occurs strictly before
the horizon `N`. -/
def HittingTimeBeforeHorizonOnEvent
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) : Prop :=
  ∀ ω ∈ E, collapseHittingTime S.cumulativeRV θ N ω < N

/-- Failure-bound packaging for the event `collapseHittingTime < N`. -/
def HittingTimeBeforeHorizonWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    (N : ℕ) (θ : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set Ω,
    EventWithFailureBound (μ := μ) E ε ∧
      HittingTimeBeforeHorizonOnEvent (μ := μ) S N θ E

/-- Threshold crossing by any earlier time `k < N` forces the hitting time to
occur strictly before `N`. -/
theorem hittingTimeBeforeHorizonOnEvent_of_thresholdCrossingOnEvent
    (S : StochasticExpectedProcess (μ := μ))
    {k N : ℕ} (hkN : k < N)
    {θ : ℝ} {E : Set Ω}
    (hE : ThresholdCrossingOnEvent (μ := μ) S k θ E) :
    HittingTimeBeforeHorizonOnEvent (μ := μ) S N θ E := by
  intro ω hω
  have hcross : -Real.log θ ≤ S.cumulativeRV k ω := hE ω hω
  rw [collapseHittingTime]
  refine (MeasureTheory.hittingBtwn_lt_iff
    (u := S.cumulativeRV) (s := collapseSet θ) (n := 0) (m := N) (ω := ω) N le_rfl).2 ?_
  refine ⟨k, ?_, ?_⟩
  · exact ⟨Nat.zero_le k, hkN⟩
  · simpa [collapseSet] using hcross

/-- Failure-bound transfer from earlier fixed-time threshold crossing to the
event `collapseHittingTime < N`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    {k N : ℕ} (hkN : k < N)
    {θ : ℝ} {ε : ENNReal}
    (hE : ThresholdCrossingWithFailureBound (μ := μ) S k θ ε) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S N θ ε := by
  rcases hE with ⟨E, hfail, hcross⟩
  refine ⟨E, hfail, ?_⟩
  exact hittingTimeBeforeHorizonOnEvent_of_thresholdCrossingOnEvent S hkN hcross

/-- Azuma/Hoeffding instantiation:
an expected margin at an earlier time `k < N` yields a high-probability bound
for the direct event `collapseHittingTime < N`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hcross :
      ThresholdCrossingWithFailureBound (μ := μ) S k θ
        (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
          (varianceProxyOfBounds A.incrementBound) k r) := by
    exact thresholdCrossingWithFailureBound_of_expected_center
      A.toAzumaHoeffdingConcentration.toExpectationLowerConcentration hmargin
  exact hittingTimeBeforeHorizonWithFailureBound_of_thresholdCrossingWithFailureBound
    (μ := μ) S hkN hcross

/-- Submartingale corollary:
an initial expected margin already suffices for the direct event
`collapseHittingTime < N`, provided one evaluates Azuma at some `k < N`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_initialMargin_submartingale
    {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    (hsub : Submartingale S.cumulativeRV ℱ μ)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative 0 - r) :
    HittingTimeBeforeHorizonWithFailureBound (μ := μ) S N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) k r) := by
  have hsubLike :
      SubmartingaleLike (μ := μ)
        (processAsStochasticExpectedProcess (μ := μ) S.cumulativeRV hsub.integrable) :=
    submartingaleLike_of_submartingale (μ := μ) (ℱ := ℱ) hsub
  have hmono :
      Monotone
        ((processAsStochasticExpectedProcess
          (μ := μ) S.cumulativeRV hsub.integrable).toExpectedProcess.expectedCumulative) :=
    expectedCumulative_monotone_of_submartingaleLike _ hsubLike
  have hmonoS : Monotone S.toExpectedProcess.expectedCumulative := by
    simpa
      [processAsStochasticExpectedProcess,
        ProbabilityConnection.StochasticExpectedProcess.toExpectedProcess]
      using hmono
  have h0k : S.toExpectedProcess.expectedCumulative 0 ≤ S.toExpectedProcess.expectedCumulative k :=
    hmonoS (Nat.zero_le k)
  have hmargink : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative k - r := by
    linarith
  exact hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) A hkN hmargink

end

end Survival.StoppingTimeCollapseEvent
