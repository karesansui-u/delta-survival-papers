import Survival.BoundedAzumaConstruction
import Survival.StoppingTimeCliffWarning

/-!
Stopping-Time High-Probability Collapse

This module connects the fixed-time Azuma/Hoeffding concentration layer to the
stopping-time collapse layer.

The philosophy is conservative:

* first obtain a high-probability threshold-crossing bound at the terminal time
  `N` via `BoundedAzumaConstruction`;
* then transfer that same event to the stopped value at the collapse hitting
  time `τ = collapseHittingTime ...`;
* finally, convert the stopped threshold crossing into a stopped collapse bound.

An optional-stopping flavored corollary is also provided: if the cumulative
process is a submartingale, an initial expected margin is enough, because the
stopped-value expectation is squeezed between the initial and terminal
expectations by `StoppingTimeCliffWarning`.
-/

open scoped ProbabilityTheory
open MeasureTheory

namespace Survival.StoppingTimeHighProbabilityCollapse

open Survival.ProbabilityConnection
open Survival.HighProbabilityCollapse
open Survival.ConcentrationInterface
open Survival.BoundedAzumaConstruction
open Survival.StoppingTimeCliffWarning

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

/-- Threshold crossing for the stopped value at the collapse hitting time. -/
def StoppedThresholdCrossingOnEvent
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) : Prop :=
  ∀ ω ∈ E,
    -Real.log θ ≤
      stoppedValue S.cumulativeRV
        (fun ω ↦ (collapseHittingTime S.cumulativeRV θ N ω : ℕ)) ω

/-- Collapse of the stopped survival ratio at the collapse hitting time. -/
def StoppedCollapseOnEvent
    (S : StochasticExpectedProcess (μ := μ)) (N : ℕ) (θ : ℝ) (E : Set Ω) : Prop :=
  ∀ ω ∈ E,
    Real.exp
        (-stoppedValue S.cumulativeRV
          (fun ω ↦ (collapseHittingTime S.cumulativeRV θ N ω : ℕ)) ω)
      ≤ θ

/-- Failure-bound packaging for stopped-value threshold crossing. -/
def StoppedThresholdCrossingWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    (N : ℕ) (θ : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set Ω,
    EventWithFailureBound (μ := μ) E ε ∧
      StoppedThresholdCrossingOnEvent (μ := μ) S N θ E

/-- Failure-bound packaging for stopped-value collapse. -/
def StoppedCollapseWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    (N : ℕ) (θ : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set Ω,
    EventWithFailureBound (μ := μ) E ε ∧
      StoppedCollapseOnEvent (μ := μ) S N θ E

/-- A terminal threshold-crossing event transfers to the stopped value at the
collapse hitting time, because terminal crossing gives a witness `j = N` for
the hitting-time lemma. -/
theorem stoppedThresholdCrossingOnEvent_of_terminalThresholdCrossingOnEvent
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} {E : Set Ω}
    (hE : ThresholdCrossingOnEvent (μ := μ) S N θ E) :
    StoppedThresholdCrossingOnEvent (μ := μ) S N θ E := by
  intro ω hω
  have hterm : -Real.log θ ≤ S.cumulativeRV N ω := hE ω hω
  have hhit : ∃ j ∈ Set.Icc 0 N, -Real.log θ ≤ S.cumulativeRV j ω := by
    refine ⟨N, ?_, hterm⟩
    simp
  exact threshold_le_stoppedValue_of_exists_hit
    (f := S.cumulativeRV) (θ := θ) (N := N) (ω := ω) hhit

/-- Stopped-value threshold crossing implies stopped-value collapse by the same
exponential monotonicity argument used in the fixed-time case. -/
theorem stoppedCollapseOnEvent_of_stoppedThresholdCrossingOnEvent
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} (hθ : 0 < θ) {E : Set Ω}
    (hE : StoppedThresholdCrossingOnEvent (μ := μ) S N θ E) :
    StoppedCollapseOnEvent (μ := μ) S N θ E := by
  intro ω hω
  have hth := hE ω hω
  have hexp :
      Real.exp
          (-stoppedValue S.cumulativeRV
            (fun ω ↦ (collapseHittingTime S.cumulativeRV θ N ω : ℕ)) ω)
        ≤ Real.exp (Real.log θ) := by
    exact (Real.exp_le_exp).2 (by linarith)
  simpa [Real.exp_log hθ] using hexp

/-- Failure-bound transfer from terminal threshold crossing to stopped-value
threshold crossing. -/
theorem stoppedThresholdCrossingWithFailureBound_of_terminalThresholdCrossingWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} {ε : ENNReal}
    (hE : ThresholdCrossingWithFailureBound (μ := μ) S N θ ε) :
    StoppedThresholdCrossingWithFailureBound (μ := μ) S N θ ε := by
  rcases hE with ⟨E, hfail, hcross⟩
  refine ⟨E, hfail, ?_⟩
  exact stoppedThresholdCrossingOnEvent_of_terminalThresholdCrossingOnEvent S hcross

/-- Failure-bound transfer from terminal threshold crossing to stopped-value
collapse. -/
theorem stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
    (S : StochasticExpectedProcess (μ := μ))
    {N : ℕ} {θ : ℝ} (hθ : 0 < θ) {ε : ENNReal}
    (hE : ThresholdCrossingWithFailureBound (μ := μ) S N θ ε) :
    StoppedCollapseWithFailureBound (μ := μ) S N θ ε := by
  rcases stoppedThresholdCrossingWithFailureBound_of_terminalThresholdCrossingWithFailureBound
      (μ := μ) S hE with ⟨E, hfail, hstopped⟩
  refine ⟨E, hfail, ?_⟩
  exact stoppedCollapseOnEvent_of_stoppedThresholdCrossingOnEvent S hθ hstopped

/-- Main bridge theorem:
a bounded-increment Azuma witness plus an expected terminal margin yields a
high-probability collapse bound for the stopped value at the collapse hitting
time. -/
theorem stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound (μ := μ) S N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hterminal :
      ThresholdCrossingWithFailureBound (μ := μ) S N θ
        (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
          (varianceProxyOfBounds A.incrementBound) N r) := by
    exact thresholdCrossingWithFailureBound_of_expected_center
      A.toAzumaHoeffdingConcentration.toExpectationLowerConcentration hmargin
  exact stoppedCollapseWithFailureBound_of_terminalThresholdCrossingWithFailureBound
    (μ := μ) S hθ hterminal

/-- Optional-stopping flavored corollary:
for a submartingale, an initial expected margin is enough, since the terminal
expectation dominates the initial one through the stopping-time inequality. -/
theorem stoppedCollapseWithFailureBound_of_boundedIncrementData_initialMargin_submartingale
    {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {S : StochasticExpectedProcess (μ := μ)}
    (A : BoundedIncrementAzumaData (μ := μ) S)
    (hsub : Submartingale S.cumulativeRV ℱ μ)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative 0 - r) :
    StoppedCollapseWithFailureBound (μ := μ) S N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (varianceProxyOfBounds A.incrementBound) N r) := by
  have hchain :=
    Submartingale.expected_initial_le_expected_collapseHittingTime_le_terminal
      (ℱ := ℱ) hsub θ N
  have hinit_le_terminal_raw :
      (∫ ω, S.cumulativeRV 0 ω ∂μ) ≤ ∫ ω, S.cumulativeRV N ω ∂μ :=
    le_trans hchain.1 hchain.2
  have hinit_le_terminal :
      S.toExpectedProcess.expectedCumulative 0 ≤
        S.toExpectedProcess.expectedCumulative N := by
    simpa [StochasticExpectedProcess.toExpectedProcess] using hinit_le_terminal_raw
  have hmarginN : -Real.log θ ≤ S.toExpectedProcess.expectedCumulative N - r := by
    linarith
  exact stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin
    (μ := μ) A hθ hmarginN

end

end Survival.StoppingTimeHighProbabilityCollapse
