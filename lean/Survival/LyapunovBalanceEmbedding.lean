import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Survival.QueueStability

/-!
# Lyapunov Balance Embedding

This module records the minimal G6-c formal embedding described in the
structural-balance draft:

* a Lyapunov/load sequence `Z_t`,
* its one-step net action `a_t = Z_{t+1} - Z_t`,
* the cumulative action `A_n = ∑_{t<n} a_t = Z_n - Z_0`,
* the exponential maintenance coordinate `R_t = exp (-Z_t)`, with
  `R_{t+1} = R_t * exp (-a_t)`.

It is deliberately narrow.  It does not formalize the Foster--Lyapunov
positive-recurrence theorem; it only packages the algebraic embedding that lets
Lyapunov drift conditions be read as expectation-level structural-balance
tendencies.
-/

open scoped BigOperators

namespace Survival.LyapunovBalanceEmbedding

noncomputable section

/-- A one-step Lyapunov/load increment, read as net structural action. -/
def increment (Z : ℕ → ℝ) (t : ℕ) : ℝ :=
  Z (t + 1) - Z t

/-- Cumulative net action over the finite prefix `0, ..., n-1`. -/
def cumulativeAction (Z : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, increment Z t

/-- Exponential maintenance coordinate induced by the load sequence. -/
def relativeMaintenance (Z : ℕ → ℝ) (t : ℕ) : ℝ :=
  Real.exp (-(Z t))

/-- Positive part of the load increment, read as loss flow. -/
def lossFlow (Z : ℕ → ℝ) (t : ℕ) : ℝ :=
  max (increment Z t) 0

/-- Negative part of the load increment, read as repair / compensation flow. -/
def repairFlow (Z : ℕ → ℝ) (t : ℕ) : ℝ :=
  max (-(increment Z t)) 0

@[simp] theorem cumulativeAction_zero (Z : ℕ → ℝ) :
    cumulativeAction Z 0 = 0 := by
  simp [cumulativeAction]

@[simp] theorem relativeMaintenance_pos (Z : ℕ → ℝ) (t : ℕ) :
    0 < relativeMaintenance Z t := by
  exact Real.exp_pos _

theorem lossFlow_nonneg (Z : ℕ → ℝ) (t : ℕ) :
    0 ≤ lossFlow Z t := by
  unfold lossFlow
  exact le_max_right (increment Z t) 0

theorem repairFlow_nonneg (Z : ℕ → ℝ) (t : ℕ) :
    0 ≤ repairFlow Z t := by
  unfold repairFlow
  exact le_max_right (-(increment Z t)) 0

/-- The cumulative action telescopes to final load minus initial load. -/
theorem cumulativeAction_eq_load_diff (Z : ℕ → ℝ) (n : ℕ) :
    cumulativeAction Z n = Z n - Z 0 := by
  induction n with
  | zero =>
      simp [cumulativeAction]
  | succ n ih =>
      rw [cumulativeAction, Finset.sum_range_succ]
      rw [← cumulativeAction, ih]
      unfold increment
      ring

/-- The exponential maintenance coordinate obeys the local balance update. -/
theorem relativeMaintenance_succ_eq_mul_exp_neg_increment
    (Z : ℕ → ℝ) (t : ℕ) :
    relativeMaintenance Z (t + 1) =
      relativeMaintenance Z t * Real.exp (-(increment Z t)) := by
  unfold relativeMaintenance increment
  rw [← Real.exp_add]
  congr 1
  ring

lemma max_self_zero_sub_max_neg_self_zero_eq_self (x : ℝ) :
    max x 0 - max (-x) 0 = x := by
  by_cases hx : 0 ≤ x
  · have hmax₁ : max x 0 = x := max_eq_left hx
    have hneg : -x ≤ 0 := by linarith
    have hmax₂ : max (-x) 0 = 0 := max_eq_right hneg
    rw [hmax₁, hmax₂]
    ring
  · have hxlt : x < 0 := lt_of_not_ge hx
    have hmax₁ : max x 0 = 0 := max_eq_right (le_of_lt hxlt)
    have hneg : 0 ≤ -x := by linarith
    have hmax₂ : max (-x) 0 = -x := max_eq_left hneg
    rw [hmax₁, hmax₂]
    ring

/-- Positive/negative part decomposition of a Lyapunov increment. -/
theorem increment_eq_lossFlow_sub_repairFlow (Z : ℕ → ℝ) (t : ℕ) :
    increment Z t = lossFlow Z t - repairFlow Z t := by
  unfold lossFlow repairFlow
  exact (max_self_zero_sub_max_neg_self_zero_eq_self (increment Z t)).symm

/-- Queue backlog as the Lyapunov/load sequence for the fluid skeleton. -/
def queueLoad (Q : Survival.QueueStability.System) (initial : ℝ) : ℕ → ℝ :=
  fun n => Survival.QueueStability.backlog Q initial n

/-- Queue one-step net action is exactly arrival minus service. -/
theorem queue_increment_eq_excessDemand
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ) :
    increment (queueLoad Q initial) n =
      Survival.QueueStability.excessDemand Q := by
  unfold increment queueLoad
  rw [Survival.QueueStability.backlog_succ]
  ring

/-- Queue cumulative action is the deterministic cumulative overload loss. -/
theorem queue_cumulativeAction_eq_cumulativeOverloadLoss
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ) :
    cumulativeAction (queueLoad Q initial) n =
      Survival.QueueStability.cumulativeOverloadLoss Q n := by
  rw [cumulativeAction_eq_load_diff]
  unfold queueLoad
  rw [Survival.QueueStability.backlog_eq_initial_add_cumulativeOverloadLoss]
  rw [Survival.QueueStability.backlog_zero]
  ring

/-- Stable fluid queue: the structural action is nonpositive. -/
theorem queue_increment_nonpos_of_stable
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ)
    (hstable : Q.arrivalRate ≤ Q.serviceRate) :
    increment (queueLoad Q initial) n ≤ 0 := by
  rw [queue_increment_eq_excessDemand]
  exact Survival.QueueStability.excessDemand_nonpos_of_stable Q hstable

/-- Overloaded fluid queue: the structural action is positive. -/
theorem queue_increment_pos_of_overloaded
    (Q : Survival.QueueStability.System) (initial : ℝ) (n : ℕ)
    (hover : Q.serviceRate < Q.arrivalRate) :
    0 < increment (queueLoad Q initial) n := by
  rw [queue_increment_eq_excessDemand]
  exact Survival.QueueStability.excessDemand_pos_of_overloaded Q hover

end

end Survival.LyapunovBalanceEmbedding
