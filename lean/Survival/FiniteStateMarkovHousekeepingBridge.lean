import Survival.FiniteStateMarkovStationaryProduction

/-!
# Finite-State Markov Housekeeping Bridge

This module records the conservative finite-state bridge behind the
NESS analogy.

It does not prove a stochastic-thermodynamic NESS theorem. Instead, it proves
the bookkeeping facts that should be true before making that analogy:

* under a stationary start, the expected one-step change of any state
  potential is zero;
* if total production is decomposed as
  `potential net change + housekeeping cost`, then the stationary mean total
  production is exactly the stationary mean housekeeping cost;
* nonnegative housekeeping cost gives nonnegative stationary mean total
  production, and positive mean housekeeping cost gives positive stationary
  mean total production.

This is the formal guardrail against reading Core's net structural change
`b_t` itself as positive housekeeping entropy production in a steady regime.
-/

namespace Survival.FiniteStateMarkovHousekeepingBridge

open scoped BigOperators
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovStationaryProduction

noncomputable section

/-- Stationary expected one-step change of a state potential.

This is the expectation of `φ(X_t) - φ(X_{t+1})` in a stationary start, written
only in terms of the current stationary marginal and the next marginal induced
by the transition kernel. -/
def stationaryExpectedNetChange (S : StationaryData M) (φ : RepairState → ℝ) : ℝ :=
  stateAverage S.π φ - stateAverage (S.π.bind M.step) φ

/-- Stationary mean housekeeping / maintenance cost. -/
def stationaryExpectedCost (S : StationaryData M) (C : RepairState → ℝ) : ℝ :=
  stateAverage S.π C

/-- Stationary mean total production when total production is decomposed as
net potential change plus housekeeping cost. -/
def stationaryExpectedTotalProduction
    (S : StationaryData M) (φ C : RepairState → ℝ) : ℝ :=
  stationaryExpectedNetChange S φ + stationaryExpectedCost S C

/-- In stationarity, the expected one-step net change of any state potential is
zero. -/
theorem stationary_expected_netChange_eq_zero
    (S : StationaryData M) (φ : RepairState → ℝ) :
    stationaryExpectedNetChange S φ = 0 := by
  unfold stationaryExpectedNetChange
  rw [S.stationary]
  ring

/-- Therefore stationary mean total production is exactly the stationary mean
housekeeping cost. -/
theorem stationary_expected_totalProduction_eq_cost
    (S : StationaryData M) (φ C : RepairState → ℝ) :
    stationaryExpectedTotalProduction S φ C = stationaryExpectedCost S C := by
  unfold stationaryExpectedTotalProduction
  rw [stationary_expected_netChange_eq_zero S φ]
  ring

/-- Nonnegative housekeeping cost gives nonnegative stationary mean total
production. -/
theorem stationary_expected_totalProduction_nonneg
    (S : StationaryData M) (φ C : RepairState → ℝ)
    (hC : ∀ s, 0 ≤ C s) :
    0 ≤ stationaryExpectedTotalProduction S φ C := by
  rw [stationary_expected_totalProduction_eq_cost]
  unfold stationaryExpectedCost stateAverage
  refine Finset.sum_nonneg ?_
  intro s _
  exact mul_nonneg ENNReal.toReal_nonneg (hC s)

/-- If the stationary mean housekeeping cost is positive, then stationary mean
total production is positive. -/
theorem positive_housekeeping_of_positive_cost
    (S : StationaryData M) (φ C : RepairState → ℝ)
    (hCpos : 0 < stationaryExpectedCost S C) :
    0 < stationaryExpectedTotalProduction S φ C := by
  rw [stationary_expected_totalProduction_eq_cost]
  exact hCpos

/-- Multiplying the stationary mean identity by an arbitrary number of steps.

This is only a mean-level bookkeeping identity. It does not construct a
path-level cumulative process. -/
theorem n_times_stationary_expected_totalProduction_eq_cost
    (S : StationaryData M) (φ C : RepairState → ℝ) (n : ℕ) :
    (n : ℝ) * stationaryExpectedTotalProduction S φ C =
      (n : ℝ) * stationaryExpectedCost S C := by
  rw [stationary_expected_totalProduction_eq_cost]

end

end Survival.FiniteStateMarkovHousekeepingBridge
