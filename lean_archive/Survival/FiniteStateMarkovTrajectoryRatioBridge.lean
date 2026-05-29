import Mathlib.Data.Fin.Rev
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Survival.FinitePathTrajectoryRatioBridge

/-!
# Finite-State Markov Trajectory-Ratio Bridge

This module is the v3-b specialization layer for the trajectory-ratio bridge.

It constructs finite-horizon path PMFs from explicit finite-state Markov data
and connects those PMFs to the generic finite path-ratio identity in
`Survival.FinitePathTrajectoryRatioBridge`.

It still does not define a physical reverse protocol, local detailed balance,
medium entropy, or a stochastic-thermodynamic fluctuation theorem.  The reverse
chain is supplied as separate data, and the support / coverage conditions are
kept explicit.
-/

namespace Survival.FiniteStateMarkovTrajectoryRatioBridge

open scoped BigOperators
open Survival.FinitePathTrajectoryRatioBridge

noncomputable section

/-- Generic finite-state Markov chain data.  The reverse chain used in a
trajectory-ratio comparison is supplied as another value of the same type; no
physical reverse-protocol interpretation is built in here. -/
structure MarkovData (α : Type*) where
  init : PMF α
  step : α → PMF α

/-- Finite-horizon trajectories of length `N + 1`. -/
abbrev Trajectory (α : Type*) (N : ℕ) := Fin (N + 1) → α

/-- Length-1 trajectory generated from an initial state. -/
def singletonTraj {α : Type*} (s : α) : Trajectory α 0 :=
  fun _ => s

/-- Extend a trajectory by one final state. -/
def snoc {α : Type*} {N : ℕ} (τ : Trajectory α N) (s : α) :
    Trajectory α (N + 1)
  | ⟨i, _⟩ =>
      if h : i < N + 1 then
        τ ⟨i, h⟩
      else
        s

/-- The finite-horizon path PMF induced by an initial law and transition
kernel. -/
def pathPMF {α : Type*} (M : MarkovData α) : ∀ N : ℕ, PMF (Trajectory α N)
  | 0 => M.init.map singletonTraj
  | N + 1 =>
      (pathPMF M N).bind fun τ =>
        (M.step (τ (Fin.last N))).map (snoc τ)

/-- Deterministic time reversal on a finite trajectory. -/
def timeReverse {α : Type*} {N : ℕ} (τ : Trajectory α N) :
    Trajectory α N :=
  fun i => τ (Fin.rev i)

@[simp]
theorem timeReverse_apply {α : Type*} {N : ℕ}
    (τ : Trajectory α N) (i : Fin (N + 1)) :
    timeReverse τ i = τ (Fin.rev i) := rfl

/-- Time reversal is an involution on finite trajectories. -/
theorem timeReverse_involutive {α : Type*} {N : ℕ} :
    Function.Involutive (@timeReverse α N) := by
  intro τ
  funext i
  simp [timeReverse]

/-- Therefore deterministic time reversal is injective. -/
theorem timeReverse_injective {α : Type*} {N : ℕ} :
    Function.Injective (@timeReverse α N) := by
  intro τ σ h
  calc
    τ = timeReverse (timeReverse τ) := (timeReverse_involutive τ).symm
    _ = timeReverse (timeReverse σ) := congrArg (@timeReverse α N) h
    _ = σ := timeReverse_involutive σ

/-- Therefore deterministic time reversal is surjective. -/
theorem timeReverse_surjective {α : Type*} {N : ℕ} :
    Function.Surjective (@timeReverse α N) := by
  intro τ
  exact ⟨timeReverse τ, timeReverse_involutive τ⟩

/-- Deterministic time reversal is bijective. -/
theorem timeReverse_bijective {α : Type*} {N : ℕ} :
    Function.Bijective (@timeReverse α N) :=
  ⟨timeReverse_injective, timeReverse_surjective⟩

variable {α : Type*} [Fintype α]

/-- Markov-specialized one-sided support guard. -/
def MarkovReversePositiveOnForward
    (F R : MarkovData α) (N : ℕ) : Prop :=
  ReversePositiveOnForward (pathPMF F N) (pathPMF R N) timeReverse

/-- Markov-specialized reverse-mass coverage condition.  As in the generic
finite bridge, this is a multiplicity-sensitive sum along forward support; it
is not by itself a physical fluctuation-theorem assumption. -/
def MarkovReverseMassCoverage
    (F R : MarkovData α) (N : ℕ) : Prop :=
  ReverseMassCoverage (pathPMF F N) (pathPMF R N) timeReverse

/-- Markov-specialized trajectory ratio on forward-supported paths. -/
def markovTrajectoryRatio
    (F R : MarkovData α) (N : ℕ)
    (hAC : MarkovReversePositiveOnForward F R N)
    (γ : ForwardSupport (pathPMF F N)) : ℝ :=
  trajectoryRatio (pathPMF F N) (pathPMF R N) timeReverse hAC γ

/-- Markov-specialized exponential weighted sum. -/
def markovForwardWeightedExpNegRatioSum
    (F R : MarkovData α) (N : ℕ)
    (hAC : MarkovReversePositiveOnForward F R N) : ℝ :=
  forwardWeightedExpNegRatioSum (pathPMF F N) (pathPMF R N) timeReverse hAC

/-- The v3-a finite path-ratio identity specialized to two finite-state Markov
path PMFs. -/
theorem markov_finite_integral_exp_neg_ratio_identity
    (F R : MarkovData α) (N : ℕ)
    (hAC : MarkovReversePositiveOnForward F R N)
    (hcov : MarkovReverseMassCoverage F R N) :
    markovForwardWeightedExpNegRatioSum F R N hAC = 1 :=
  finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage hAC hcov

end

end Survival.FiniteStateMarkovTrajectoryRatioBridge
