import Survival.FiniteStateMarkovCollapse
import Survival.FiniteStateMarkovMeanBridge
import Survival.FiniteStateMarkovStationaryProduction
import Survival.StochasticTotalProductionAzuma

/-!
# Three-State State-Dependent Example

This file gives a concrete end-to-end finite-state Markov example with
genuinely state-dependent total production.

Unlike `ThreeStateTransitionExample`, the total production is not flat across
states. Instead, we keep the *path* deterministic:

* the chain starts at `failure`;
* the transition is the deterministic cycle
  `failure -> idle -> repair -> failure`;
* therefore the actual finite-horizon path measure is a Dirac mass on a single
  trajectory.

This lets us build an automatic lower-tail witness from the singleton support
event, while still keeping the total production genuinely state-dependent.
-/

namespace Survival.ThreeStateStateDependentExample

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovCollapse
open Survival.FiniteStateMarkovMeanBridge
open Survival.FiniteStateMarkovStationaryProduction
open Survival.StochasticTotalProduction
open Survival.StochasticTotalProductionAzuma
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent
open Survival.AzumaHoeffding
open Survival.BoundedAzumaConstruction

noncomputable section

/-- Deterministic 3-cycle on the repair/failure states. -/
def nextState : RepairState → RepairState
  | .failure => .idle
  | .idle => .repair
  | .repair => .failure

/-- Actual finite-state Markov chain with deterministic start and deterministic
transition. -/
def cycleChain : ChainData where
  init := PMF.pure .failure
  step s := PMF.pure (nextState s)

/-- State-dependent emission with varying total production across states. -/
def stateDependentEmission (a b c : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) : Emission where
  netActionOf
    | .failure => a
    | .idle => b / 2
    | .repair => 0
  costOf
    | .failure => 0
    | .idle => b / 2
    | .repair => c
  total_nonneg := by
    intro s
    cases s <;> nlinarith

/-- The unique finite-horizon trajectory in the deterministic 3-cycle. -/
def canonicalPath : ∀ N : ℕ, Trajectory N
  | 0 => singletonTraj .failure
  | N + 1 =>
      snoc (canonicalPath N) (nextState ((canonicalPath N) (Fin.last N)))

theorem pathPMF_eq_pure_canonicalPath :
    ∀ N : ℕ, pathPMF cycleChain N = PMF.pure (canonicalPath N)
  | 0 => by
      simpa [pathPMF, cycleChain, canonicalPath] using
        (show singletonTraj <$> (PMF.pure RepairState.failure) =
            PMF.pure (singletonTraj RepairState.failure) from
          map_pure singletonTraj RepairState.failure)
  | N + 1 => by
      rw [pathPMF, pathPMF_eq_pure_canonicalPath N]
      simpa [canonicalPath, cycleChain] using
        (show snoc (canonicalPath N) <$> (PMF.pure (nextState (canonicalPath N (Fin.last N)))) =
            PMF.pure (snoc (canonicalPath N) (nextState (canonicalPath N (Fin.last N)))) from
          map_pure (snoc (canonicalPath N)) (nextState (canonicalPath N (Fin.last N))))

/-- Recursive deterministic center along the unique cycle trajectory, truncated
after the finite horizon. -/
def activeCenter (N : ℕ) (s₀ : ℝ) (E : Emission) : ℕ → ℝ
  | 0 => s₀
  | t + 1 =>
      activeCenter N s₀ E t +
        if _ : t ≤ N then totalProductionOfState E (stateAt (canonicalPath N) t) else 0

theorem cumulative_on_canonicalPath_eq_activeCenter
    (N : ℕ) (s₀ : ℝ) (E : Emission) :
    ∀ n,
      cumulativeTotalProductionRV (stepModel cycleChain N s₀ E) n (canonicalPath N) =
        activeCenter N s₀ E n
  | 0 => by
      simp [StochasticTotalProduction.cumulativeTotalProductionRV, activeCenter,
        FiniteStateMarkovRepairChain.stepModel]
  | t + 1 => by
      by_cases ht : t ≤ N
      · simp [StochasticTotalProduction.cumulativeTotalProductionRV, activeCenter,
          cumulative_on_canonicalPath_eq_activeCenter N s₀ E t, ht,
          stepTotalProductionRV_eq_stateTotal_of_le cycleChain N s₀ E ht]
      · simp [StochasticTotalProduction.cumulativeTotalProductionRV, activeCenter,
          cumulative_on_canonicalPath_eq_activeCenter N s₀ E t, ht,
          stepTotalProductionRV_eq_zero_of_not_le cycleChain N s₀ E ht]

theorem expectedCumulative_eq_activeCenter
    (N : ℕ) (s₀ : ℝ) (E : Emission) (n : ℕ) :
    (stepModel cycleChain N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      activeCenter N s₀ E n := by
  change
    ∫ τ,
      cumulativeTotalProductionRV (stepModel cycleChain N s₀ E) n τ
        ∂ (pathPMF cycleChain N).toMeasure
      = activeCenter N s₀ E n
  rw [pathPMF_eq_pure_canonicalPath, PMF.toMeasure_pure]
  simp [cumulative_on_canonicalPath_eq_activeCenter]

theorem pathMeasure_compl_singleton_canonicalPath
    (N : ℕ) :
    pathMeasure cycleChain N ({canonicalPath N}ᶜ) = 0 := by
  rw [pathMeasure, pathPMF_eq_pure_canonicalPath, PMF.toMeasure_pure]
  simp

/-- Lower-tail witness from the singleton support event of the deterministic
cycle path measure. -/
def lowerTailWitness
    (N : ℕ) (s₀ : ℝ) (E : Emission) :
    StepModelLowerTailWitness
      (μ := pathMeasure cycleChain N)
      (stepModel cycleChain N s₀ E)
      (incrementBound E) where
  goodEvent _ r := if 0 ≤ r then {canonicalPath N} else ∅
  measurable_goodEvent _ r := by
    by_cases hr : 0 ≤ r <;> simp [hr]
  lower_bound_on_good n r τ hτ := by
    by_cases hr : 0 ≤ r
    · have hτ' : τ = canonicalPath N := by simpa [hr] using hτ
      subst hτ'
      rw [expectedCumulative_eq_activeCenter, cumulative_on_canonicalPath_eq_activeCenter]
      linarith
    · simp [hr] at hτ
  azuma_failure_bound n r := by
    by_cases hr : 0 ≤ r
    · simp [hr]
      rw [pathMeasure_compl_singleton_canonicalPath]
      exact bot_le
    · have hfail :
          azumaHoeffdingFailureBound
            (varianceProxyOfBounds (incrementBound E)) n r = 1 := by
        have hrate :
            azumaHoeffdingRate
              (varianceProxyOfBounds (incrementBound E)) n r = 0 := by
          simp [azumaHoeffdingRate, hr]
        simp [azumaHoeffdingFailureBound,
          Survival.ConcentrationInterface.largeDeviationFailureBound, hrate]
      rw [hfail]
      simp [hr]

/-- End-to-end stopped-collapse bound for the deterministic 3-cycle with
genuinely state-dependent total production. -/
theorem stoppedCollapseWithFailureBound_of_activeCenter
    (N : ℕ) (s₀ : ℝ) (E : Emission)
    {T : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ activeCenter N s₀ E T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure cycleChain N)
      (stepModel cycleChain N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) T r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel cycleChain N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative T - r := by
    rw [expectedCumulative_eq_activeCenter]
    exact hmargin
  exact
    markov_stoppedCollapseWithFailureBound_of_expectedMargin
      (M := cycleChain) (N := N) (s₀ := s₀) (E := E)
      (lowerTailWitness N s₀ E) hθ hmargin'

/-- End-to-end direct hitting-time-before-horizon bound for the deterministic
3-cycle with genuinely state-dependent total production. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeCenter
    (N : ℕ) (s₀ : ℝ) (E : Emission)
    {k T : ℕ} (hkT : k < T)
    {θ r : ℝ}
    (hmargin : -Real.log θ ≤ activeCenter N s₀ E k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure cycleChain N)
      (stepModel cycleChain N s₀ E).toStochasticProcess T θ
      (azumaHoeffdingFailureBound
        (varianceProxyOfBounds (incrementBound E)) k r) := by
  have hmargin' :
      -Real.log θ ≤
        (stepModel cycleChain N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative k - r := by
    rw [expectedCumulative_eq_activeCenter]
    exact hmargin
  exact
    markov_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      (M := cycleChain) (N := N) (s₀ := s₀) (E := E)
      (lowerTailWitness N s₀ E) hkT hmargin'

end

end Survival.ThreeStateStateDependentExample
