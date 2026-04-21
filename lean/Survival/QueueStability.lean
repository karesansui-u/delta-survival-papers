import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Queue Stability / Overload Collapse Skeleton

This module formalizes the Route A bridge examples A07/A28 at a deterministic
fluid level.  It does not model a reflected stochastic queue.  Instead, it
records the minimal overload skeleton:

`backlog_n = initial + n * (arrivalRate - serviceRate)`.

If `arrivalRate <= serviceRate`, the excess-work trajectory does not grow.  If
`serviceRate < arrivalRate`, overload accumulates linearly and crosses any
finite operational threshold once enough steps have elapsed.
-/

namespace Survival.QueueStability

noncomputable section

/-- Deterministic fluid queue data. -/
structure System where
  arrivalRate : ℝ
  serviceRate : ℝ
  arrival_nonneg : 0 ≤ arrivalRate
  service_nonneg : 0 ≤ serviceRate

/-- Per-step excess demand.  Positive values mean overload. -/
def excessDemand (Q : System) : ℝ :=
  Q.arrivalRate - Q.serviceRate

/-- Fluid backlog / accumulated excess work after `n` steps. -/
def backlog (Q : System) (initial : ℝ) (n : ℕ) : ℝ :=
  initial + (n : ℝ) * excessDemand Q

/-- Remaining service margin in the stable regime. -/
def serviceMargin (Q : System) : ℝ :=
  Q.serviceRate - Q.arrivalRate

/-- The overload event at a finite operational threshold. -/
def ThresholdExceeded (Q : System) (initial : ℝ) (n : ℕ) (threshold : ℝ) : Prop :=
  threshold ≤ backlog Q initial n

@[simp] theorem backlog_zero (Q : System) (initial : ℝ) :
    backlog Q initial 0 = initial := by
  simp [backlog]

/-- One step adds exactly the excess demand. -/
theorem backlog_succ (Q : System) (initial : ℝ) (n : ℕ) :
    backlog Q initial (n + 1) = backlog Q initial n + excessDemand Q := by
  unfold backlog
  norm_num
  ring

/-- Stable regime: service margin is nonnegative. -/
theorem serviceMargin_nonneg_of_stable
    (Q : System) (hstable : Q.arrivalRate ≤ Q.serviceRate) :
    0 ≤ serviceMargin Q := by
  unfold serviceMargin
  linarith

/-- Stable regime: excess demand is nonpositive. -/
theorem excessDemand_nonpos_of_stable
    (Q : System) (hstable : Q.arrivalRate ≤ Q.serviceRate) :
    excessDemand Q ≤ 0 := by
  unfold excessDemand
  linarith

/-- Overloaded regime: excess demand is strictly positive. -/
theorem excessDemand_pos_of_overloaded
    (Q : System) (hover : Q.serviceRate < Q.arrivalRate) :
    0 < excessDemand Q := by
  unfold excessDemand
  linarith

/-- In the stable fluid skeleton, accumulated excess work never exceeds the
initial backlog. -/
theorem backlog_le_initial_of_stable
    (Q : System) (initial : ℝ) (n : ℕ)
    (hstable : Q.arrivalRate ≤ Q.serviceRate) :
    backlog Q initial n ≤ initial := by
  unfold backlog
  have hex : excessDemand Q ≤ 0 := excessDemand_nonpos_of_stable Q hstable
  have hmul : (n : ℝ) * excessDemand Q ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (Nat.cast_nonneg n) hex
  linarith

/-- In the overloaded fluid skeleton, backlog is monotone over time. -/
theorem backlog_mono_of_overloaded
    (Q : System) (initial : ℝ) {n m : ℕ}
    (hover : Q.serviceRate < Q.arrivalRate) (hnm : n ≤ m) :
    backlog Q initial n ≤ backlog Q initial m := by
  unfold backlog
  have hex_nonneg : 0 ≤ excessDemand Q :=
    le_of_lt (excessDemand_pos_of_overloaded Q hover)
  have hcast : (n : ℝ) ≤ (m : ℝ) := by
    exact_mod_cast hnm
  have hmul :
      (n : ℝ) * excessDemand Q ≤ (m : ℝ) * excessDemand Q :=
    mul_le_mul_of_nonneg_right hcast hex_nonneg
  linarith

/-- If enough overloaded steps have elapsed, the backlog crosses the threshold. -/
theorem thresholdExceeded_of_steps_ge
    (Q : System) (initial threshold : ℝ) (n : ℕ)
    (hover : Q.serviceRate < Q.arrivalRate)
    (hsteps : (threshold - initial) / excessDemand Q ≤ (n : ℝ)) :
    ThresholdExceeded Q initial n threshold := by
  unfold ThresholdExceeded backlog
  have hex : 0 < excessDemand Q := excessDemand_pos_of_overloaded Q hover
  have hbase : threshold - initial ≤ (n : ℝ) * excessDemand Q := by
    have hmul := (div_le_iff₀ hex).1 hsteps
    linarith [hmul]
  linarith

/-- Equivalent reading: if a proposed horizon `n` already satisfies the linear
margin inequality, overload collapse has occurred by that horizon. -/
theorem thresholdExceeded_of_linear_margin
    (Q : System) (initial threshold : ℝ) (n : ℕ)
    (hmargin : threshold ≤ initial + (n : ℝ) * excessDemand Q) :
    ThresholdExceeded Q initial n threshold := by
  simpa [ThresholdExceeded, backlog] using hmargin

/-- Overload creates a positive per-step structural loss in the excess-work
reading. -/
def overloadLoss (Q : System) : ℝ :=
  excessDemand Q

/-- Cumulative overload loss after `n` steps. -/
def cumulativeOverloadLoss (Q : System) (n : ℕ) : ℝ :=
  (n : ℝ) * overloadLoss Q

/-- Cumulative overload loss is the backlog increase over the initial value. -/
theorem backlog_eq_initial_add_cumulativeOverloadLoss
    (Q : System) (initial : ℝ) (n : ℕ) :
    backlog Q initial n = initial + cumulativeOverloadLoss Q n := by
  rfl

/-- In overload, the per-step overload loss is strictly positive. -/
theorem overloadLoss_pos_of_overloaded
    (Q : System) (hover : Q.serviceRate < Q.arrivalRate) :
    0 < overloadLoss Q := by
  exact excessDemand_pos_of_overloaded Q hover

/-- In overload, cumulative overload loss is nonnegative. -/
theorem cumulativeOverloadLoss_nonneg_of_overloaded
    (Q : System) (n : ℕ) (hover : Q.serviceRate < Q.arrivalRate) :
    0 ≤ cumulativeOverloadLoss Q n := by
  unfold cumulativeOverloadLoss
  exact mul_nonneg (Nat.cast_nonneg n)
    (le_of_lt (overloadLoss_pos_of_overloaded Q hover))

end

end Survival.QueueStability
