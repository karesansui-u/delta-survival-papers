import Survival.FiniteStateMarkovRepairChain
import Survival.AzumaHoeffding
import Survival.StochasticTotalProductionAzuma
import Survival.ResourceBoundedStochasticCollapse

/-!
# Finite-State Markov Flat Lower-Tail Witness

This module isolates a concrete subclass of finite-state Markov repair/failure
chains where the lower-tail witness can be generated automatically.

The key extra assumption is that the emitted one-step total production is
state-independent:

  netActionOf s + costOf s = σ

for every finite state `s`.

On the actual finite-horizon Markov path space, this makes cumulative total
production deterministic even though the state path itself remains stochastic.
Hence the lower-tail witness becomes automatic, exactly as in the constant-drift
example but now on a genuine finite-state actual Markov chain.
-/

namespace Survival.FiniteStateMarkovFlatWitness

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.AzumaHoeffding
open Survival.StochasticTotalProduction
open Survival.ResourceBoundedStochasticCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Flat total-production emission: the sum of net action and repair cost is the
same scalar `σ` in every finite state. -/
structure FlatTotalEmission extends Emission where
  σ : ℝ
  total_eq : ∀ s, netActionOf s + costOf s = σ

/-- The actual finite-horizon Markov step model associated to a flat emission. -/
def flatStepModel (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) :
    StepModel (μ := pathMeasure M N) :=
  FiniteStateMarkovRepairChain.stepModel M N s₀ E.toEmission

/-- Number of active one-step emissions contributing up to cumulative time `n`
for a finite horizon `N`. -/
def activeSteps (N n : ℕ) : ℕ :=
  min n (N + 1)

theorem activeSteps_succ (N n : ℕ) :
    activeSteps N (n + 1) = activeSteps N n + if n ≤ N then 1 else 0 := by
  unfold activeSteps
  by_cases h : n ≤ N
  · have h1 : min (n + 1) (N + 1) = n + 1 := by
      exact Nat.min_eq_left (Nat.succ_le_succ h)
    have h2 : min n (N + 1) = n := by
      exact Nat.min_eq_left (Nat.le_trans h (Nat.le_succ _))
    simp [h, h2]
  · have hgt : N + 1 ≤ n := Nat.succ_le_of_lt (lt_of_not_ge h)
    have h1 : min (n + 1) (N + 1) = N + 1 := by
      exact Nat.min_eq_right (Nat.le_trans hgt (Nat.le_succ _))
    have h2 : min n (N + 1) = N + 1 := by
      exact Nat.min_eq_right hgt
    simp [h, h1, h2]

/-- One-step total production is constant `σ` on the active finite-horizon
window and zero afterwards. -/
theorem stepTotalProductionRV_eq_piecewise_const
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) (t : ℕ) :
    stepTotalProductionRV (flatStepModel M N s₀ E) t =
      fun _ => if t ≤ N then E.σ else 0 := by
  funext τ
  by_cases ht : t ≤ N
  · have hσ :
        E.toEmission.netActionOf (τ ⟨t, Nat.lt_succ_of_le ht⟩) +
          E.toEmission.costOf (τ ⟨t, Nat.lt_succ_of_le ht⟩) = E.σ :=
      E.total_eq (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    unfold StochasticTotalProduction.stepTotalProductionRV flatStepModel
    change
      FiniteStateMarkovRepairChain.stepNetActionRV N E.toEmission t τ +
        FiniteStateMarkovRepairChain.stepCostRV N E.toEmission t τ =
          if t ≤ N then E.σ else 0
    simpa [FiniteStateMarkovRepairChain.stepNetActionRV,
      FiniteStateMarkovRepairChain.stepCostRV, ht] using hσ
  · unfold StochasticTotalProduction.stepTotalProductionRV flatStepModel
    change
      FiniteStateMarkovRepairChain.stepNetActionRV N E.toEmission t τ +
        FiniteStateMarkovRepairChain.stepCostRV N E.toEmission t τ =
          if t ≤ N then E.σ else 0
    simp [FiniteStateMarkovRepairChain.stepNetActionRV,
      FiniteStateMarkovRepairChain.stepCostRV, ht]

/-- Therefore cumulative total production is deterministic and equals the
initial margin plus the number of active steps times `σ`. -/
theorem cumulativeTotalProductionRV_eq_const
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) :
    ∀ n,
      cumulativeTotalProductionRV (flatStepModel M N s₀ E) n =
        fun _ => s₀ + (activeSteps N n : ℝ) * E.σ
  | 0 => by
      funext τ
      change s₀ = s₀ + (activeSteps N 0 : ℝ) * E.σ
      simp [activeSteps]
  | n + 1 => by
      funext τ
      rw [StochasticTotalProduction.cumulativeTotalProductionRV,
        cumulativeTotalProductionRV_eq_const M N s₀ E n,
        stepTotalProductionRV_eq_piecewise_const M N s₀ E n,
        activeSteps_succ]
      by_cases h : n ≤ N
      · simp [h, Nat.cast_add, Nat.cast_one]
        ring
      · simp [h]

/-- Hence expected cumulative total production is explicit as well. -/
theorem expectedCumulative_eq
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) (n : ℕ) :
    (flatStepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (activeSteps N n : ℝ) * E.σ := by
  change
    ∫ τ,
      cumulativeTotalProductionRV (flatStepModel M N s₀ E) n τ
        ∂pathMeasure M N
      = s₀ + (activeSteps N n : ℝ) * E.σ
  rw [cumulativeTotalProductionRV_eq_const M N s₀ E n]
  exact Survival.ProbabilityConnection.expected_constant_eq
    (μ := pathMeasure M N) (s₀ + (activeSteps N n : ℝ) * E.σ)

/-- Automatic lower-tail witness for flat total-production emissions on the
actual finite-horizon Markov path space. -/
def lowerTailWitness
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) :
    StepModelLowerTailWitness
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E)
      (fun _ => |E.σ|) where
  goodEvent _ r := if 0 ≤ r then Set.univ else ∅
  measurable_goodEvent _ r := by
    by_cases hr : 0 ≤ r <;> simp [hr]
  lower_bound_on_good n r τ hτ := by
    by_cases hr : 0 ≤ r
    · rw [expectedCumulative_eq M N s₀ E n,
        cumulativeTotalProductionRV_eq_const M N s₀ E n]
      linarith
    · simp [hr] at hτ
  azuma_failure_bound n r := by
    by_cases hr : 0 ≤ r
    · simp [hr, azumaHoeffdingFailureBound]
    · have hfail :
        azumaHoeffdingFailureBound
          (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |E.σ|)) n r = 1 := by
        have hrate :
            azumaHoeffdingRate
              (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |E.σ|)) n r = 0 := by
          simp [azumaHoeffdingRate, hr]
        simp [azumaHoeffdingFailureBound,
          Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]
      rw [hfail]
      simp [hr]

/-- Under flat total emission, one-step total production is uniformly bounded
by `|σ|`. -/
theorem boundedStepTotalProduction
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) :
    ∀ t, ∀ᵐ τ ∂pathMeasure M N,
      |stepTotalProductionRV (flatStepModel M N s₀ E) t τ| ≤ |E.σ| := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  by_cases ht : t ≤ N
  · rw [stepTotalProductionRV_eq_piecewise_const M N s₀ E t]
    simp [ht]
  · rw [stepTotalProductionRV_eq_piecewise_const M N s₀ E t]
    simp [ht]

/-- Automatic resource-bounded Azuma package for flat total emissions on the
actual finite-horizon Markov path space. -/
def resourceBoundedStepModelAzuma
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission) :
    ResourceBoundedStepModelAzuma
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E) :=
  ResourceBoundedStepModelAzuma.of_boundedIncrements
    (μ := pathMeasure M N)
    (fun _ => |E.σ|)
    (fun _ => abs_nonneg E.σ)
    (boundedStepTotalProduction M N s₀ E)
    (FiniteStateMarkovRepairChain.ae_nonnegative_stepTotalProduction M N s₀ E.toEmission)
    (lowerTailWitness M N s₀ E)

/-- End-to-end stopped-collapse bound for actual finite-state Markov chains with
flat total emission. -/
theorem stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤
        (((flatStepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0)) - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |E.σ|)) T r) :=
  ResourceBoundedStochasticCollapse.stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (μ := pathMeasure M N)
    (resourceBoundedStepModelAzuma M N s₀ E)
    hθ hmargin₀

/-- End-to-end direct hitting-time-before-horizon bound for actual finite-state
Markov chains with flat total emission. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : FlatTotalEmission)
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤
        (((flatStepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative 0)) - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure M N)
      (flatStepModel M N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds (fun _ => |E.σ|)) k r) :=
  ResourceBoundedStochasticCollapse.hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (μ := pathMeasure M N)
    (resourceBoundedStepModelAzuma M N s₀ E)
    hkT hmargin₀

end

end Survival.FiniteStateMarkovFlatWitness
