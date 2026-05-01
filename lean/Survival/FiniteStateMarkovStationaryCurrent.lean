import Mathlib.Probability.Distributions.Uniform
import Survival.FiniteStateMarkovHousekeepingBridge

/-!
# Finite-State Markov Stationary Current

This module adds the next conservative step in the NESS analogy.

The previous housekeeping bridge proves that Core-style net structural change
has zero stationary mean and that positive stationary total production must be
carried by a separate housekeeping cost term. This file keeps that separation
and adds only the finite-state current bookkeeping:

* stationary pair flow `π(x) K(x,y)`;
* antisymmetric current
  `J(x,y) = π(x) K(x,y) - π(y) K(y,x)`;
* detailed balance as zero current;
* an ENNReal detailed-balance condition implies stationarity of the marginal.

It still does not prove a stochastic-thermodynamic entropy-production theorem,
a fluctuation theorem, or a path probability ratio statement.
-/

namespace Survival.FiniteStateMarkovStationaryCurrent

open scoped BigOperators
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovStationaryProduction

noncomputable section

/-- Stationary pair-flow mass, read in real coordinates:
`π(x) K(x,y)`. -/
def stationaryFlow (M : ChainData) (π : PMF RepairState)
    (x y : RepairState) : ℝ :=
  ((π x) * (M.step x y)).toReal

/-- The antisymmetric stationary probability current. -/
def stationaryCurrent (M : ChainData) (π : PMF RepairState)
    (x y : RepairState) : ℝ :=
  stationaryFlow M π x y - stationaryFlow M π y x

/-- Detailed balance in real stationary-flow coordinates. -/
def DetailedBalance (M : ChainData) (π : PMF RepairState) : Prop :=
  ∀ x y, stationaryFlow M π x y = stationaryFlow M π y x

/-- Detailed balance in the underlying `ENNReal` probability coordinates.

This stronger-looking formulation is convenient when proving that detailed
balance implies stationarity of the marginal. -/
def DetailedBalanceENN (M : ChainData) (π : PMF RepairState) : Prop :=
  ∀ x y, π x * M.step x y = π y * M.step y x

/-- Stationary current is antisymmetric. -/
theorem stationaryCurrent_antisymm
    (M : ChainData) (π : PMF RepairState) (x y : RepairState) :
    stationaryCurrent M π x y = -stationaryCurrent M π y x := by
  unfold stationaryCurrent
  ring

/-- Detailed balance is equivalent to zero stationary current. -/
theorem detailedBalance_iff_current_eq_zero
    (M : ChainData) (π : PMF RepairState) :
    DetailedBalance M π ↔ ∀ x y, stationaryCurrent M π x y = 0 := by
  constructor
  · intro h x y
    unfold stationaryCurrent
    rw [h x y]
    ring
  · intro h x y
    have hxy := h x y
    unfold stationaryCurrent at hxy
    linarith

/-- The `ENNReal` detailed-balance condition implies detailed balance in real
stationary-flow coordinates. -/
theorem detailedBalance_of_detailedBalanceENN
    (M : ChainData) (π : PMF RepairState)
    (hdb : DetailedBalanceENN M π) :
    DetailedBalance M π := by
  intro x y
  unfold stationaryFlow
  rw [hdb x y]

/-- Hence `ENNReal` detailed balance forces zero stationary current. -/
theorem current_eq_zero_of_detailedBalanceENN
    (M : ChainData) (π : PMF RepairState)
    (hdb : DetailedBalanceENN M π) :
    ∀ x y, stationaryCurrent M π x y = 0 :=
  (detailedBalance_iff_current_eq_zero M π).1
    (detailedBalance_of_detailedBalanceENN M π hdb)

/-- If some stationary current is nonzero, real-coordinate detailed balance is
broken. -/
theorem nonzero_current_implies_not_detailedBalance
    (M : ChainData) (π : PMF RepairState) {x y : RepairState}
    (hJ : stationaryCurrent M π x y ≠ 0) :
    ¬ DetailedBalance M π := by
  intro hdb
  exact hJ ((detailedBalance_iff_current_eq_zero M π).1 hdb x y)

/-- `ENNReal` detailed balance implies stationarity of the one-step marginal.

This is the finite-state Markov-chain fact behind the safe NESS analogy:
detailed balance is a stronger condition than stationarity. -/
theorem detailedBalanceENN_implies_stationary
    (M : ChainData) (π : PMF RepairState)
    (hdb : DetailedBalanceENN M π) :
    π.bind M.step = π := by
  apply PMF.ext
  intro y
  rw [PMF.bind_apply]
  calc
    (∑' x, π x * M.step x y) = ∑' x, π y * M.step y x := by
      apply tsum_congr
      intro x
      exact hdb x y
    _ = π y * ∑' x, M.step y x := by
      rw [ENNReal.tsum_mul_left]
    _ = π y := by
      rw [(M.step y).tsum_coe, mul_one]

/-- The deterministic three-cycle used as a minimal non-equilibrium witness. -/
def cycleNext : RepairState → RepairState
  | .failure => .idle
  | .idle => .repair
  | .repair => .failure

instance instNonemptyRepairState : Nonempty RepairState :=
  ⟨RepairState.failure⟩

@[simp]
theorem fintype_card_repairState : Fintype.card RepairState = 3 := by
  decide

/-- Uniform stationary distribution on the three repair states. -/
def uniformRepairState : PMF RepairState :=
  PMF.uniformOfFintype RepairState

/-- Deterministic cycle with uniform initial distribution. -/
def uniformCycleChain : ChainData where
  init := uniformRepairState
  step s := PMF.pure (cycleNext s)

/-- The uniform distribution is stationary for the deterministic three-cycle. -/
theorem uniformCycle_stationary :
    uniformRepairState.bind uniformCycleChain.step = uniformRepairState := by
  apply PMF.ext
  intro y
  cases y
  · rw [PMF.bind_apply, tsum_fintype]
    rw [Finset.sum_eq_single RepairState.repair]
    · simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply]
    · intro b _ hb
      cases b <;> simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply] at hb ⊢
    · intro h
      simp at h
  · rw [PMF.bind_apply, tsum_fintype]
    rw [Finset.sum_eq_single RepairState.failure]
    · simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply]
    · intro b _ hb
      cases b <;> simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply] at hb ⊢
    · intro h
      simp at h
  · rw [PMF.bind_apply, tsum_fintype]
    rw [Finset.sum_eq_single RepairState.idle]
    · simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply]
    · intro b _ hb
      cases b <;> simp [uniformRepairState, uniformCycleChain, cycleNext,
        PMF.uniformOfFintype_apply] at hb ⊢
    · intro h
      simp at h

/-- The uniform three-cycle as a `StationaryData` witness. -/
def uniformCycleStationaryData : StationaryData uniformCycleChain where
  π := uniformRepairState
  init_eq := rfl
  stationary := uniformCycle_stationary

/-- The uniform three-cycle has nonzero stationary current. This is the small
finite witness that stationarity alone does not force detailed balance. -/
theorem uniformCycle_nonzero_current :
    stationaryCurrent
      uniformCycleChain
      uniformRepairState
      RepairState.failure
      RepairState.idle ≠ 0 := by
  simp [stationaryCurrent, stationaryFlow, uniformCycleChain,
    uniformRepairState, cycleNext, PMF.uniformOfFintype_apply]

/-- Consequently, stationarity can coexist with nonzero current. -/
theorem stationary_with_nonzero_current_witness :
    ∃ (M : ChainData) (S : StationaryData M) (x y : RepairState),
      stationaryCurrent M S.π x y ≠ 0 := by
  exact
    ⟨uniformCycleChain, uniformCycleStationaryData,
      RepairState.failure, RepairState.idle, uniformCycle_nonzero_current⟩

end

end Survival.FiniteStateMarkovStationaryCurrent
