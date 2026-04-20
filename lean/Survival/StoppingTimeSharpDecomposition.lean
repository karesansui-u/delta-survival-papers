import Survival.StoppingTimeCollapseEvent

/-!
Stopping-Time Sharp Decomposition

This module sharpens the finite-horizon hitting-time story by explicitly
separating the two cases:

* `collapseHittingTime < N`
* `collapseHittingTime = N`

Since `collapseHittingTime ≤ N` always holds by construction, the equality case
is precisely the complement of the strict-before-horizon case.

We also provide a sufficient condition for the equality case: threshold
crossing occurs at the terminal time `N`, but does not occur at any earlier
time `k < N`.
-/

open scoped ProbabilityTheory
open MeasureTheory

namespace Survival.StoppingTimeSharpDecomposition

open Survival.ProbabilityConnection
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeCliffWarning
open Survival.StoppingTimeCollapseEvent

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Event-level statement that the collapse hitting time is exactly the horizon
`N`. -/
def HittingTimeAtHorizonOnEvent
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) : Prop :=
  ∀ ω ∈ E, collapseHittingTime S.cumulativeRV θ N ω = N

/-- Failure-bound packaging for the event `collapseHittingTime = N`. -/
def HittingTimeAtHorizonWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    (N : ℕ) (θ : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set Ω,
    EventWithFailureBound (μ := μ) E ε ∧
      HittingTimeAtHorizonOnEvent (μ := μ) S N θ E

/-- No threshold crossing strictly before the horizon. -/
def NoThresholdCrossingBeforeHorizonOnEvent
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) : Prop :=
  ∀ ω ∈ E, ∀ k < N, S.cumulativeRV k ω < -Real.log θ

/-- Pointwise decomposition of the finite-horizon hitting time: because
`collapseHittingTime ≤ N`, only the two cases `< N` or `= N` remain. -/
theorem hittingTimeBefore_or_atHorizon
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (ω : Ω) :
    collapseHittingTime S.cumulativeRV θ N ω < N ∨
      collapseHittingTime S.cumulativeRV θ N ω = N := by
  have hle := collapseHittingTime_le_horizon S.cumulativeRV θ N ω
  exact lt_or_eq_of_le hle

/-- On any event, equality at the horizon is equivalent to failure of the
strict-before-horizon event. -/
theorem hittingTimeAtHorizonOnEvent_iff_not_before
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) :
    HittingTimeAtHorizonOnEvent (μ := μ) S N θ E ↔
      ∀ ω ∈ E, ¬ collapseHittingTime S.cumulativeRV θ N ω < N := by
  constructor
  · intro h ω hω
    rw [h ω hω]
    exact lt_irrefl N
  · intro h ω hω
    have hle := collapseHittingTime_le_horizon S.cumulativeRV θ N ω
    exact le_antisymm hle (Nat.not_lt.mp (h ω hω))

/-- Terminal threshold crossing together with no earlier threshold crossing
forces the hitting time to equal the horizon `N`. -/
theorem hittingTimeAtHorizonOnEvent_of_terminalThresholdCrossing_and_noEarlierCrossing
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} {E : Set Ω}
    (_hterminal : ThresholdCrossingOnEvent (μ := μ) S N θ E)
    (hno : NoThresholdCrossingBeforeHorizonOnEvent (μ := μ) S N θ E) :
    HittingTimeAtHorizonOnEvent (μ := μ) S N θ E := by
  intro ω hω
  have hnotlt : ¬ collapseHittingTime S.cumulativeRV θ N ω < N := by
    intro hlt
    rcases
      (MeasureTheory.hittingBtwn_lt_iff
        (u := S.cumulativeRV) (s := collapseSet θ) (n := 0) (m := N) (ω := ω) N le_rfl).1 hlt
      with ⟨k, hk, hmem⟩
    have hstrict : S.cumulativeRV k ω < -Real.log θ := hno ω hω k hk.2
    have hcross : -Real.log θ ≤ S.cumulativeRV k ω := by
      simpa [collapseSet] using hmem
    linarith
  have hterm_le : collapseHittingTime S.cumulativeRV θ N ω ≤ N :=
    collapseHittingTime_le_horizon S.cumulativeRV θ N ω
  exact le_antisymm hterm_le (Nat.not_lt.mp hnotlt)

/-- Failure-bound introduction for the equality-at-horizon event. -/
theorem hittingTimeAtHorizonWithFailureBound_intro
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} {E : Set Ω} {ε : ENNReal}
    (hfail : EventWithFailureBound (μ := μ) E ε)
    (hterminal : ThresholdCrossingOnEvent (μ := μ) S N θ E)
    (hno : NoThresholdCrossingBeforeHorizonOnEvent (μ := μ) S N θ E) :
    HittingTimeAtHorizonWithFailureBound (μ := μ) S N θ ε := by
  refine ⟨E, hfail, ?_⟩
  exact hittingTimeAtHorizonOnEvent_of_terminalThresholdCrossing_and_noEarlierCrossing
    S hterminal hno

end

end Survival.StoppingTimeSharpDecomposition
