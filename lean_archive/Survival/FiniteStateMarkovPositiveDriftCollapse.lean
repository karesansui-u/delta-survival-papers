import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Survival.FiniteStateMarkovFlatWitness
import Survival.FiniteStateMarkovStationaryProduction

/-!
# Finite-State Markov Positive Drift Collapse

This module turns the flat-emission finite-state Markov example into a
long-time positive-drift collapse / hitting-time interface.

The key point is that for flat total production,

* cumulative total production is deterministic on the actual path space;
* expected cumulative total production is therefore exactly linear on the active
  finite horizon;
* this exact linear center can be fed directly into the existing Azuma /
  stopping-time API.

In particular, this gives a clean expectation-level bridge from a positive
drift parameter `σ` (or equivalently the stationary mean production in the flat
case) to high-probability finite-horizon collapse bounds.
-/

namespace Survival.FiniteStateMarkovPositiveDriftCollapse

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.FiniteStateMarkovStationaryProduction
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

instance : MeasurableSpace RepairState := ⊤

instance : MeasurableSingletonClass RepairState where
  measurableSet_singleton _ := by trivial

/-- Finite-state expectation of a constant state function is that same
constant. -/
theorem stateAverage_const (p : PMF RepairState) (c : ℝ) :
    stateAverage p (fun _ : RepairState => c) = c := by
  unfold stateAverage
  have h_int : ∫ s : RepairState, c ∂(p.toMeasure) = c := by
    simpa using integral_const (μ := p.toMeasure) c
  rw [PMF.integral_eq_sum] at h_int
  simpa [smul_eq_mul, mul_comm, mul_left_comm, mul_assoc] using h_int

/-- For a flat total emission, the stationary mean production equals the common
state-independent total production `σ`. -/
theorem stationaryMean_eq_sigma_of_flatEmission
    (S : StationaryData M) (E : FlatTotalEmission) :
    stationaryMean S E.toEmission = E.σ := by
  unfold stationaryMean
  rw [show totalProductionOfState E.toEmission = (fun _ : RepairState => E.σ) by
    funext s
    simp [totalProductionOfState, E.total_eq]]
  exact stateAverage_const S.π E.σ

/-- High-probability stopped-collapse bound from the exact linear expected
center of a flat-emission finite-state Markov chain. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ s₀ + (activeSteps N T : ℝ) * E.σ - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) T r) := by
  have hmargin' :
      -Real.log θ ≤
        (flatStepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative T - r := by
    rw [expectedCumulative_eq M N s₀ E T]
    exact hmargin
  exact
    stoppedCollapseWithFailureBound_of_boundedIncrements
      (μ := pathMeasure M N)
      (S := flatStepModel M N s₀ E)
      (incrementBound := fun _ => |E.σ|)
      (incrementBound_nonneg := by intro t; positivity)
      (boundedStepTotalProduction := boundedStepTotalProduction M N s₀ E)
      (W := lowerTailWitness M N s₀ E)
      hθ hmargin'

/-- On the active window, the previous theorem can be stated using the exact
linear center `s₀ + T * σ`. -/
theorem stoppedCollapseWithFailureBound_of_linearMargin_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {T : ℕ} (hT : T ≤ N + 1)
    {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * E.σ - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) T r) := by
  have hactive : activeSteps N T = T := by
    unfold activeSteps
    exact Nat.min_eq_left hT
  apply stoppedCollapseWithFailureBound_of_activeLinearMargin (M := M) (N := N) (s₀ := s₀) (E := E) hθ
  simpa [hactive] using hmargin

/-- Direct hitting-time-before-horizon bound from the exact linear expected
center of a flat-emission finite-state Markov chain. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ s₀ + (activeSteps N k : ℝ) * E.σ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) k r) := by
  have hmargin' :
      -Real.log θ ≤
        (flatStepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq M N s₀ E k]
    exact hmargin
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_boundedIncrements
      (μ := pathMeasure M N)
      (S := flatStepModel M N s₀ E)
      (incrementBound := fun _ => |E.σ|)
      (incrementBound_nonneg := by intro t; positivity)
      (boundedStepTotalProduction := boundedStepTotalProduction M N s₀ E)
      (W := lowerTailWitness M N s₀ E)
      hkT hmargin'

/-- On the active window, the previous theorem can be stated using the exact
linear center `s₀ + k * σ`. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_linearMargin_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * E.σ - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) k r) := by
  have hactive : activeSteps N k = k := by
    unfold activeSteps
    exact Nat.min_eq_left hk
  apply hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin
    (M := M) (N := N) (s₀ := s₀) (E := E) hkT
  simpa [hactive] using hmargin

/-- Stationary-mean reformulation of the active-window stopped-collapse bound
for flat emissions. -/
theorem stoppedCollapseWithFailureBound_of_stationaryMean_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    (S : StationaryData M)
    {T : ℕ} (hT : T ≤ N + 1)
    {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * stationaryMean S E.toEmission - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) T r) := by
  rw [stationaryMean_eq_sigma_of_flatEmission S E] at hmargin
  exact
    stoppedCollapseWithFailureBound_of_linearMargin_of_le
      (M := M) (N := N) (s₀ := s₀) (E := E) hT hθ hmargin

/-- Stationary-mean reformulation of the active-window hitting-time bound for
flat emissions. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_stationaryMean_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    (S : StationaryData M)
    {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * stationaryMean S E.toEmission - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (fun _ => |E.σ|)) k r) := by
  rw [stationaryMean_eq_sigma_of_flatEmission S E] at hmargin
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_linearMargin_of_le
      (M := M) (N := N) (s₀ := s₀) (E := E) hkT hk hmargin

end

end Survival.FiniteStateMarkovPositiveDriftCollapse
