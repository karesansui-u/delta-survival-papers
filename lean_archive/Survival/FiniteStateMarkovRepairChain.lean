import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Survival.MarkovRepairFailureExample

/-!
# Finite-State Markov Repair Chain

This module upgrades the previous `MarkovRepairFailureExample` from a
"Markov-style" bookkeeping process to a genuine finite-horizon stochastic
process built from:

* an initial distribution on the finite state space
* a state-dependent transition `PMF`
* the recursively induced path-space `PMF`

The resulting path measure is an actual probability measure on finite
trajectories, not merely an abstract process on an arbitrary probability space.

We still stop one layer short of the full infinite-horizon
Ionescu-Tulcea construction; the present file is a finite-horizon concrete
instance tailored to the survival / total-production pipeline.
-/

namespace Survival.FiniteStateMarkovRepairChain

open MeasureTheory
open scoped BigOperators

open Survival.StochasticTotalProduction
open Survival.CoarseStochasticTotalProduction
open Survival.CoarseTypicalNondecrease
open Survival.MarkovRepairFailureExample

noncomputable section

/-- Finite-state Markov repair/failure chain data:
an initial distribution together with a one-step transition `PMF`. -/
structure ChainData where
  init : PMF RepairState
  step : RepairState → PMF RepairState

/-- Finite-horizon trajectories of length `N + 1`. -/
abbrev Trajectory (N : ℕ) := Fin (N + 1) → RepairState

instance instMeasurableSpaceTrajectory (N : ℕ) : MeasurableSpace (Trajectory N) := ⊤

instance instMeasurableSingletonClassTrajectory (N : ℕ) :
    MeasurableSingletonClass (Trajectory N) where
  measurableSet_singleton _ := by trivial

/-- Length-1 trajectory generated from an initial state. -/
def singletonTraj (s : RepairState) : Trajectory 0 := fun _ => s

/-- Extend a trajectory by one final state. -/
def snoc {N : ℕ} (τ : Trajectory N) (s : RepairState) : Trajectory (N + 1)
  | ⟨i, _⟩ =>
      if h : i < N + 1 then
        τ ⟨i, h⟩
      else
        s

/-- The finite-horizon path `PMF` induced by the initial distribution and the
transition law. -/
def pathPMF (M : ChainData) : ∀ N : ℕ, PMF (Trajectory N)
  | 0 => M.init.map singletonTraj
  | N + 1 =>
      (pathPMF M N).bind fun τ =>
        (M.step (τ (Fin.last N))).map (snoc τ)

/-- The corresponding actual probability measure on finite trajectories. -/
def pathMeasure (M : ChainData) (N : ℕ) : Measure (Trajectory N) :=
  (pathPMF M N).toMeasure

instance instIsProbabilityMeasurePathMeasure (M : ChainData) (N : ℕ) :
    IsProbabilityMeasure (pathMeasure M N) := by
  dsimp [pathMeasure]
  infer_instance

/-- State observed at time `t` along a finite trajectory. Outside the finite
horizon we return `idle`, so that the resulting step model extends by zeros. -/
def stateAt {N : ℕ} (τ : Trajectory N) (t : ℕ) : RepairState :=
  if ht : t ≤ N then
    τ ⟨t, Nat.lt_succ_of_le ht⟩
  else
    .idle

/-- One-step net action induced by a finite-horizon trajectory and a
state-dependent emission map. -/
def stepNetActionRV (N : ℕ) (E : Emission) (t : ℕ) :
    Trajectory N → ℝ :=
  fun τ =>
    if ht : t ≤ N then
      E.netActionOf (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    else
      0

/-- One-step repair cost induced by a finite-horizon trajectory and a
state-dependent emission map. -/
def stepCostRV (N : ℕ) (E : Emission) (t : ℕ) :
    Trajectory N → ℝ :=
  fun τ =>
    if ht : t ≤ N then
      E.costOf (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    else
      0

/-- Uniform absolute bound for the state-dependent net-action emission. -/
def netActionBound (E : Emission) : ℝ :=
  max |E.netActionOf .failure|
    (max |E.netActionOf .idle| |E.netActionOf .repair|)

/-- Uniform absolute bound for the state-dependent repair-cost emission. -/
def costBound (E : Emission) : ℝ :=
  max |E.costOf .failure|
    (max |E.costOf .idle| |E.costOf .repair|)

theorem abs_netAction_le_bound (E : Emission) (s : RepairState) :
    |E.netActionOf s| ≤ netActionBound E := by
  cases s <;> simp [netActionBound]

theorem abs_cost_le_bound (E : Emission) (s : RepairState) :
    |E.costOf s| ≤ costBound E := by
  cases s <;> simp [costBound]

theorem integrable_stepNetActionRV
    (M : ChainData) (N : ℕ) (E : Emission) (t : ℕ) :
    Integrable (stepNetActionRV N E t) (pathMeasure M N) := by
  have hmeas : AEStronglyMeasurable (stepNetActionRV N E t) (pathMeasure M N) := by
    exact (measurable_from_top : Measurable (stepNetActionRV N E t)).aestronglyMeasurable
  refine Integrable.of_bound hmeas (netActionBound E) ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  by_cases ht : t ≤ N
  · simp [stepNetActionRV, ht]
    simpa using abs_netAction_le_bound E (τ ⟨t, Nat.lt_succ_of_le ht⟩)
  · simp [stepNetActionRV, ht, netActionBound]

theorem integrable_stepCostRV
    (M : ChainData) (N : ℕ) (E : Emission) (t : ℕ) :
    Integrable (stepCostRV N E t) (pathMeasure M N) := by
  have hmeas : AEStronglyMeasurable (stepCostRV N E t) (pathMeasure M N) := by
    exact (measurable_from_top : Measurable (stepCostRV N E t)).aestronglyMeasurable
  refine Integrable.of_bound hmeas (costBound E) ?_
  refine Filter.Eventually.of_forall ?_
  intro τ
  by_cases ht : t ≤ N
  · simp [stepCostRV, ht]
    simpa using abs_cost_le_bound E (τ ⟨t, Nat.lt_succ_of_le ht⟩)
  · simp [stepCostRV, ht, costBound]

/-- The stochastic total-production step model attached to the actual finite
horizon Markov path measure. -/
def stepModel (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) :
    StepModel (μ := pathMeasure M N) where
  initialRV := fun _ => s₀
  stepNetActionRV := stepNetActionRV N E
  stepCostRV := stepCostRV N E
  integrable_initial := integrable_const s₀
  integrable_stepNetAction := integrable_stepNetActionRV M N E
  integrable_stepCost := integrable_stepCostRV M N E

/-- Statewise nonnegative total production yields almost-surely nonnegative
step total production on the actual Markov path space. -/
theorem ae_nonnegative_stepTotalProduction
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) :
    AENonnegativeStepTotalProduction (μ := pathMeasure M N) (stepModel M N s₀ E) := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  by_cases ht : t ≤ N
  · have hnonneg : 0 ≤
        E.netActionOf (τ ⟨t, Nat.lt_succ_of_le ht⟩) +
        E.costOf (τ ⟨t, Nat.lt_succ_of_le ht⟩) :=
        E.total_nonneg (τ ⟨t, Nat.lt_succ_of_le ht⟩)
    simpa [StochasticTotalProduction.stepTotalProductionRV, stepModel,
      stepNetActionRV, stepCostRV, ht] using hnonneg
  · simp [StochasticTotalProduction.stepTotalProductionRV, stepModel,
      stepNetActionRV, stepCostRV, ht]

/-- Therefore the expected cumulative total production is monotone on the
actual finite-horizon Markov path space. -/
theorem expectedCumulative_monotone
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) :
    Monotone
      (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (stepModel M N s₀ E)
    (ae_nonnegative_stepTotalProduction M N s₀ E)

/-- The coarse-grained typical nondecrease theorem applies directly to the
finite-horizon actual Markov path construction. -/
theorem coarse_expectedCumulative_monotone
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission)
    {Scoarse : StepModel (μ := pathMeasure M N)}
    (hcomp :
      CoarseStochasticCompatibility
        (μ := pathMeasure M N)
        (stepModel M N s₀ E)
        Scoarse) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  coarse_expectedCumulative_monotone_of_micro_nonnegative
    hcomp
    (ae_nonnegative_stepTotalProduction M N s₀ E)

end

end Survival.FiniteStateMarkovRepairChain
