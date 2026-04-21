import Survival.FiniteStateMarkovRepairChain
import Survival.FiniteStateMarkovFlatWitness
import Survival.TypicalNondecrease

/-!
# Finite-State Markov Stationary Production

This module adds a mean-production / stationary-distribution layer on top of the
existing finite-horizon actual Markov repair/failure chain.

The goal is not yet a full ergodic theorem. Instead, we formalize the first
"law of tendency" step in two stages:

* a general mean-production process driven by the time marginals `μ_t`
* a stationary state distribution `π`
* a stationary mean one-step total production
* the induced linear expected cumulative center
* monotonicity whenever the stationary mean production is nonnegative

This provides the finite-state microfoundation for the claim that, under a
stationary regime, total production has a preferred average direction.
-/

namespace Survival.FiniteStateMarkovStationaryProduction

open scoped BigOperators
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.TypicalNondecrease

noncomputable section

/-- The one-step state marginal induced by the initial distribution and the
transition kernel. -/
def stateMarginal (M : ChainData) : ℕ → PMF RepairState
  | 0 => M.init
  | n + 1 => (stateMarginal M n).bind M.step

/-- A stationary distribution for the finite-state repair/failure chain. -/
structure StationaryData (M : ChainData) where
  π : PMF RepairState
  init_eq : M.init = π
  stationary : π.bind M.step = π

/-- Finite-state expectation under a `PMF`, written as a finite weighted sum. -/
def stateAverage (p : PMF RepairState) (f : RepairState → ℝ) : ℝ :=
  Finset.sum Finset.univ fun s => (p s).toReal * f s

/-- Statewise one-step total production. -/
def totalProductionOfState (E : Emission) (s : RepairState) : ℝ :=
  E.netActionOf s + E.costOf s

/-- The stationary mean one-step total production. -/
def stationaryMean (S : StationaryData M) (E : Emission) : ℝ :=
  stateAverage S.π (totalProductionOfState E)

theorem stateMarginal_eq_stationary (S : StationaryData M) :
    ∀ n, stateMarginal M n = S.π
  | 0 => by simpa [stateMarginal] using S.init_eq
  | n + 1 => by
      rw [stateMarginal, stateMarginal_eq_stationary S n, S.stationary]

theorem stationaryMean_nonneg (S : StationaryData M) (E : Emission) :
    0 ≤ stationaryMean S E := by
  unfold stationaryMean stateAverage totalProductionOfState
  refine Finset.sum_nonneg ?_
  intro s _
  exact mul_nonneg ENNReal.toReal_nonneg (E.total_nonneg s)

theorem stateMarginal_totalProduction_eq_stationaryMean
    (S : StationaryData M) (E : Emission) (n : ℕ) :
    stateAverage (stateMarginal M n) (totalProductionOfState E) = stationaryMean S E := by
  rw [stateMarginal_eq_stationary S n, stationaryMean]

/-- Expected one-step total production computed from the time-`t` state
marginal, with the finite-horizon truncation built in. -/
def meanExpectedIncrement (N : ℕ) (M : ChainData) (E : Emission) (t : ℕ) : ℝ :=
  if t ≤ N then
    stateAverage (stateMarginal M t) (totalProductionOfState E)
  else
    0

theorem meanExpectedIncrement_nonneg
    (N : ℕ) (M : ChainData) (E : Emission) (t : ℕ) :
    0 ≤ meanExpectedIncrement N M E t := by
  by_cases ht : t ≤ N
  · simp [meanExpectedIncrement, ht, stateAverage, totalProductionOfState]
    refine Finset.sum_nonneg ?_
    intro s _
    exact mul_nonneg ENNReal.toReal_nonneg (E.total_nonneg s)
  · simp [meanExpectedIncrement, ht]

/-- Finite-prefix sum of the mean one-step total production. -/
def meanCumulativeSum (N : ℕ) (M : ChainData) (E : Emission) (n : ℕ) : ℝ :=
  Finset.sum (Finset.range n) (fun t => meanExpectedIncrement N M E t)

/-- General mean-production expected process:
\[
E[\Sigma_n] = s_0 + \sum_{t<n} \langle \mu_t,\phi \rangle
\]
with finite-horizon truncation after time `N`. -/
def meanExpectedProcess
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission) :
    ExpectedTotalProduction where
  expectedCumulative n := s₀ + meanCumulativeSum N M E n
  expectedIncrement := meanExpectedIncrement N M E
  expected_succ t := by
    unfold meanCumulativeSum
    rw [Finset.sum_range_succ]
    ring

theorem meanExpectedProcess_expectedIncrement_eq
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission) (t : ℕ) :
    (meanExpectedProcess N s₀ M E).expectedIncrement t = meanExpectedIncrement N M E t := rfl

theorem meanExpectedProcess_expectedCumulative_eq
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission) (n : ℕ) :
    (meanExpectedProcess N s₀ M E).expectedCumulative n = s₀ + meanCumulativeSum N M E n := rfl

theorem meanExpectedCumulative_eq_initial_add_sum
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission) (n : ℕ) :
    (meanExpectedProcess N s₀ M E).expectedCumulative n =
      s₀ + meanCumulativeSum N M E n := by
  rfl

theorem meanExpectedCumulative_eq_initial_add_active_sum_of_le
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission)
    {n : ℕ} (hn : n ≤ N + 1) :
    (meanExpectedProcess N s₀ M E).expectedCumulative n =
      s₀ + Finset.sum (Finset.range n) (fun t => stateAverage (stateMarginal M t) (totalProductionOfState E)) := by
  rw [meanExpectedCumulative_eq_initial_add_sum]
  apply congrArg (fun x => s₀ + x)
  unfold meanCumulativeSum
  apply Finset.sum_congr rfl
  intro t ht
  have htlt : t < n := Finset.mem_range.mp ht
  have htleN : t ≤ N := Nat.lt_succ_iff.mp (lt_of_lt_of_le htlt hn)
  simp [meanExpectedIncrement, htleN]

theorem meanExpectedCumulative_monotone
    (N : ℕ) (s₀ : ℝ) (M : ChainData) (E : Emission) :
    Monotone (meanExpectedProcess N s₀ M E).expectedCumulative := by
  apply TypicalNondecrease.expectedCumulative_monotone
  intro t
  rw [meanExpectedProcess_expectedIncrement_eq]
  exact meanExpectedIncrement_nonneg N M E t

/-- The expected-process center induced by a stationary one-step total
production mean over a finite horizon. It grows linearly over the active
window and then stays flat. -/
def stationaryExpectedProcess
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) :
    ExpectedTotalProduction where
  expectedCumulative n := s₀ + (activeSteps N n : ℝ) * stationaryMean S E
  expectedIncrement t := if t ≤ N then stationaryMean S E else 0
  expected_succ t := by
    rw [activeSteps_succ]
    by_cases ht : t ≤ N
    · simp [ht]
      ring
    · simp [ht]

theorem stationaryExpectedProcess_expectedCumulative_eq
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) (n : ℕ) :
    (stationaryExpectedProcess N s₀ S E).expectedCumulative n =
      s₀ + (activeSteps N n : ℝ) * stationaryMean S E := rfl

theorem stationaryExpectedIncrement_eq_stationaryMean
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {t : ℕ} (ht : t ≤ N) :
    (stationaryExpectedProcess N s₀ S E).expectedIncrement t = stationaryMean S E := by
  simp [stationaryExpectedProcess, ht]

theorem stationaryExpectedIncrement_eq_zero_after_horizon
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {t : ℕ} (ht : ¬ t ≤ N) :
    (stationaryExpectedProcess N s₀ S E).expectedIncrement t = 0 := by
  simp [stationaryExpectedProcess, ht]

theorem meanExpectedIncrement_eq_stationaryExpectedIncrement
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) (t : ℕ) :
    (meanExpectedProcess N s₀ M E).expectedIncrement t =
      (stationaryExpectedProcess N s₀ S E).expectedIncrement t := by
  by_cases ht : t ≤ N
  · rw [meanExpectedProcess_expectedIncrement_eq, stationaryExpectedIncrement_eq_stationaryMean N s₀ S E ht]
    simp [meanExpectedIncrement, ht, stateMarginal_totalProduction_eq_stationaryMean S E t]
  · rw [meanExpectedProcess_expectedIncrement_eq, stationaryExpectedIncrement_eq_zero_after_horizon N s₀ S E ht]
    simp [meanExpectedIncrement, ht]

theorem meanExpectedCumulative_eq_stationaryExpectedCumulative
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) :
    ∀ n,
      (meanExpectedProcess N s₀ M E).expectedCumulative n =
        (stationaryExpectedProcess N s₀ S E).expectedCumulative n
  | 0 => by
      rw [meanExpectedProcess_expectedCumulative_eq, stationaryExpectedProcess_expectedCumulative_eq]
      simp [meanCumulativeSum, activeSteps]
  | n + 1 => by
      rw [(meanExpectedProcess N s₀ M E).expected_succ n]
      rw [(stationaryExpectedProcess N s₀ S E).expected_succ n]
      have hcum :=
        meanExpectedCumulative_eq_stationaryExpectedCumulative
          (N := N) (s₀ := s₀) (S := S) (E := E) n
      have hinc := meanExpectedIncrement_eq_stationaryExpectedIncrement N s₀ S E n
      simpa [hcum, hinc]

theorem stationaryExpectedCumulative_eq_initial_add_linear_of_le
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {n : ℕ} (hn : n ≤ N + 1) :
    (stationaryExpectedProcess N s₀ S E).expectedCumulative n =
      s₀ + (n : ℝ) * stationaryMean S E := by
  have hmin : activeSteps N n = n := by
    unfold activeSteps
    exact Nat.min_eq_left hn
  simp [stationaryExpectedProcess, hmin]

theorem stationaryExpectedCumulative_monotone
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) :
    Monotone (stationaryExpectedProcess N s₀ S E).expectedCumulative := by
  apply TypicalNondecrease.expectedCumulative_monotone
  intro t
  by_cases ht : t ≤ N
  · rw [stationaryExpectedIncrement_eq_stationaryMean N s₀ S E ht]
    exact stationaryMean_nonneg S E
  · rw [stationaryExpectedIncrement_eq_zero_after_horizon N s₀ S E ht]

theorem meanExpectedCumulative_eq_initial_add_linear_of_stationary
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {n : ℕ} (hn : n ≤ N + 1) :
    (meanExpectedProcess N s₀ M E).expectedCumulative n =
      s₀ + (n : ℝ) * stationaryMean S E := by
  rw [meanExpectedCumulative_eq_stationaryExpectedCumulative N s₀ S E n]
  exact stationaryExpectedCumulative_eq_initial_add_linear_of_le N s₀ S E hn

/-- Along the active finite horizon, the stationary expected process advances by
exactly the stationary mean one-step total production. -/
theorem stationaryExpectedCumulative_succ_eq_add_mean
    (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {t : ℕ} (ht : t ≤ N) :
    (stationaryExpectedProcess N s₀ S E).expectedCumulative (t + 1) =
      (stationaryExpectedProcess N s₀ S E).expectedCumulative t + stationaryMean S E := by
  rw [(stationaryExpectedProcess N s₀ S E).expected_succ t]
  simp [stationaryExpectedIncrement_eq_stationaryMean N s₀ S E ht]

end

end Survival.FiniteStateMarkovStationaryProduction
