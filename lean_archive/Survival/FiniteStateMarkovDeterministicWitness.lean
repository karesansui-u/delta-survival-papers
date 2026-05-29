import Survival.FiniteStateMarkovConditionalAzuma

/-!
# Finite-State Markov Deterministic Witness

This module isolates a broader automatic lower-tail criterion than the flat
emission subclass.

The key assumption is no longer that one-step total production is statewise
constant, but only that the cumulative total-production process on the actual
finite-horizon Markov path space is pathwise deterministic:

  cumulativeTotalProductionRV n = constant (center n).

From this we automatically obtain:

* an explicit expected cumulative process;
* an automatic lower-tail witness;
* adaptedness with respect to any filtration;
* conditional submartingale drift when the deterministic center has
  nonnegative increments;
* the corresponding `MarkovConditionalAzumaData`.

Thus `FiniteStateMarkovFlatWitness` becomes a concrete instance of a more
general deterministic-cumulative criterion.
-/

namespace Survival.FiniteStateMarkovDeterministicWitness

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovCollapse
open Survival.FiniteStateMarkovConditionalAzuma
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.AzumaHoeffding
open Survival.ConditionalMartingale

noncomputable section

/-- Data asserting that cumulative total production on the actual finite-state
Markov path space is pathwise deterministic. -/
structure DeterministicCumulativeData
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) where
  center : ℕ → ℝ
  cumulative_eq_const :
    ∀ n,
      cumulativeTotalProductionRV (stepModel M N s₀ E) n =
        fun _ : Trajectory N => center n

/-- In the deterministic-cumulative case, expected cumulative total production
is exactly the deterministic center. -/
theorem expectedCumulative_eq
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E) (n : ℕ) :
    (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      D.center n := by
  change
    ∫ τ,
      cumulativeTotalProductionRV (stepModel M N s₀ E) n τ
        ∂pathMeasure M N
      = D.center n
  rw [D.cumulative_eq_const n]
  exact Survival.ProbabilityConnection.expected_constant_eq
    (μ := pathMeasure M N) (D.center n)

/-- A pathwise deterministic cumulative process is adapted to any filtration on
the finite-horizon path space. -/
theorem adapted_cumulative
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N)) :
    Adapted ℱ (cumulativeTotalProductionRV (stepModel M N s₀ E)) := by
  intro n
  rw [D.cumulative_eq_const n]
  exact stronglyMeasurable_const

/-- Automatic lower-tail witness from a pathwise deterministic cumulative total
production process. -/
def lowerTailWitness
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E) :
    StepModelLowerTailWitness
      (μ := pathMeasure M N)
      (stepModel M N s₀ E)
      (incrementBound E) where
  goodEvent _ r := if 0 ≤ r then Set.univ else ∅
  measurable_goodEvent _ r := by
    by_cases hr : 0 ≤ r <;> simp [hr]
  lower_bound_on_good n r τ hτ := by
    by_cases hr : 0 ≤ r
    · rw [expectedCumulative_eq D n, D.cumulative_eq_const n]
      linarith
    · simp [hr] at hτ
  azuma_failure_bound n r := by
    by_cases hr : 0 ≤ r
    · simp [hr, azumaHoeffdingFailureBound]
    · have hfail :
        azumaHoeffdingFailureBound
          (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) n r = 1 := by
        have hrate :
            azumaHoeffdingRate
              (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (incrementBound E)) n r = 0 := by
          simp [azumaHoeffdingRate, hr]
        simp [azumaHoeffdingFailureBound,
          Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]
      rw [hfail]
      simp [hr]

/-- If the deterministic cumulative center has nonnegative increments, it
induces conditional submartingale drift on the actual finite-state Markov path
space. -/
theorem conditional_submartingale_drift
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (hmono : ∀ n, 0 ≤ D.center (n + 1) - D.center n) :
    ConditionalIncrementSubmartingaleDrift
      (cumulativeTotalProductionRV (stepModel M N s₀ E))
      ℱ
      (pathMeasure M N) := by
  intro n
  have hdiff :
      cumulativeTotalProductionRV (stepModel M N s₀ E) (n + 1)
        - cumulativeTotalProductionRV (stepModel M N s₀ E) n
        =
      (fun _ : Trajectory N => D.center (n + 1) - D.center n) := by
    rw [D.cumulative_eq_const (n + 1), D.cumulative_eq_const n]
    funext τ
    simp
  rw [hdiff, MeasureTheory.condExp_const (μ := pathMeasure M N) (ℱ.le n)]
  exact Filter.Eventually.of_forall (fun _ => hmono n)

/-- Automatic finite-state Markov conditional-Azuma data from a pathwise
deterministic cumulative process with nonnegative deterministic drift. -/
def toMarkovConditionalAzumaData
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (hmono : ∀ n, 0 ≤ D.center (n + 1) - D.center n) :
    MarkovConditionalAzumaData M N s₀ E where
  filtration := ℱ
  adapted_cumulative := adapted_cumulative D ℱ
  conditional_submartingale_drift := conditional_submartingale_drift D ℱ hmono
  lowerTailWitness := lowerTailWitness D

/-- Automatic finite-state Markov concentration data from a pathwise
deterministic cumulative process with nonnegative deterministic drift. -/
def toMarkovConditionalAzumaConcentrationData
    {M : ChainData} {N : ℕ} {s₀ : ℝ} {E : Emission}
    (D : DeterministicCumulativeData M N s₀ E)
    (ℱ : Filtration ℕ (instMeasurableSpaceTrajectory N))
    (hmono : ∀ n, 0 ≤ D.center (n + 1) - D.center n) :
    MarkovConditionalAzumaConcentrationData M N s₀ E :=
  (toMarkovConditionalAzumaData D ℱ hmono).toMarkovConditionalAzumaConcentrationData

end

end Survival.FiniteStateMarkovDeterministicWitness
