import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Fatigue Damage / Cumulative Threshold Skeleton

This module formalizes the Route A bridge example A23 at a finite-prefix
Miner-rule level.  It does not model crack propagation or stochastic material
failure.  Instead, it records the operational skeleton:

`cumulativeDamage_n = sum_{i < n} damage_i`.

Failure occurs once cumulative damage crosses the finite capacity threshold.
For a constant per-cycle damage `d`, this specializes to

`cumulativeDamage_n = n * d`.
-/

open scoped BigOperators

namespace Survival.FatigueDamage

noncomputable section

/-- Finite-prefix fatigue model with nonnegative per-cycle damage and a finite
damage capacity. -/
structure System where
  damage : ℕ → ℝ
  damage_nonneg : ∀ i, 0 ≤ damage i
  capacity : ℝ
  capacity_pos : 0 < capacity

/-- Accumulated fatigue damage over the first `n` cycles. -/
def cumulativeDamage (S : System) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, S.damage i

/-- Remaining damage margin before threshold failure. -/
def remainingMargin (S : System) (n : ℕ) : ℝ :=
  S.capacity - cumulativeDamage S n

/-- Finite-prefix fatigue failure event. -/
def FailureOccurred (S : System) (n : ℕ) : Prop :=
  S.capacity ≤ cumulativeDamage S n

@[simp] theorem cumulativeDamage_zero (S : System) :
    cumulativeDamage S 0 = 0 := by
  simp [cumulativeDamage]

@[simp] theorem remainingMargin_zero (S : System) :
    remainingMargin S 0 = S.capacity := by
  simp [remainingMargin]

/-- One more cycle adds exactly that cycle's damage. -/
theorem cumulativeDamage_succ (S : System) (n : ℕ) :
    cumulativeDamage S (n + 1) = cumulativeDamage S n + S.damage n := by
  unfold cumulativeDamage
  rw [Finset.sum_range_succ]

/-- Cumulative damage is nonnegative. -/
theorem cumulativeDamage_nonneg (S : System) (n : ℕ) :
    0 ≤ cumulativeDamage S n := by
  induction n with
  | zero =>
      simp
  | succ n ih =>
      rw [cumulativeDamage_succ]
      linarith [S.damage_nonneg n]

/-- Remaining margin is at most the initial capacity. -/
theorem remainingMargin_le_capacity (S : System) (n : ℕ) :
    remainingMargin S n ≤ S.capacity := by
  unfold remainingMargin
  have hD : 0 ≤ cumulativeDamage S n := cumulativeDamage_nonneg S n
  linarith

/-- Cumulative damage is monotone under appending more cycles. -/
theorem cumulativeDamage_le_cumulativeDamage_add_steps
    (S : System) (n k : ℕ) :
    cumulativeDamage S n ≤ cumulativeDamage S (n + k) := by
  induction k with
  | zero =>
      simp
  | succ k ih =>
      have hstep :
          cumulativeDamage S (n + k) ≤ cumulativeDamage S ((n + k) + 1) := by
        rw [cumulativeDamage_succ]
        linarith [S.damage_nonneg (n + k)]
      have htarget :
          cumulativeDamage S ((n + k) + 1) =
            cumulativeDamage S (n + (k + 1)) := by
        ring_nf
      rw [← htarget]
      exact le_trans ih hstep

/-- Remaining margin is monotone nonincreasing under appending more cycles. -/
theorem remainingMargin_add_steps_le
    (S : System) (n k : ℕ) :
    remainingMargin S (n + k) ≤ remainingMargin S n := by
  unfold remainingMargin
  have hD := cumulativeDamage_le_cumulativeDamage_add_steps S n k
  linarith

/-- Crossing the cumulative-damage threshold is exactly the failure predicate. -/
theorem failureOccurred_of_cumulativeDamage_ge
    (S : System) (n : ℕ)
    (hcross : S.capacity ≤ cumulativeDamage S n) :
    FailureOccurred S n := by
  exact hcross

/-- Nonpositive remaining margin implies threshold failure. -/
theorem failureOccurred_of_remainingMargin_nonpos
    (S : System) (n : ℕ)
    (hmargin : remainingMargin S n ≤ 0) :
    FailureOccurred S n := by
  unfold FailureOccurred remainingMargin at *
  linarith

/-- Threshold failure is the same as nonpositive remaining margin. -/
theorem remainingMargin_nonpos_of_failureOccurred
    (S : System) (n : ℕ)
    (hfail : FailureOccurred S n) :
    remainingMargin S n ≤ 0 := by
  unfold FailureOccurred remainingMargin at *
  linarith

/-- Constant-stress fatigue model with the same damage on every cycle. -/
structure ConstantStressSystem where
  perCycleDamage : ℝ
  damage_nonneg : 0 ≤ perCycleDamage
  capacity : ℝ
  capacity_pos : 0 < capacity

/-- The constant-stress model as a general damage stream. -/
def ConstantStressSystem.toSystem (C : ConstantStressSystem) : System where
  damage := fun _ => C.perCycleDamage
  damage_nonneg := fun _ => C.damage_nonneg
  capacity := C.capacity
  capacity_pos := C.capacity_pos

/-- Constant per-cycle damage accumulates linearly. -/
theorem cumulativeDamage_toSystem_eq_mul
    (C : ConstantStressSystem) (n : ℕ) :
    cumulativeDamage C.toSystem n = (n : ℝ) * C.perCycleDamage := by
  unfold cumulativeDamage ConstantStressSystem.toSystem
  simp

/-- Constant-stress remaining margin is capacity minus linear accumulated
damage. -/
theorem remainingMargin_toSystem_eq_capacity_sub_mul
    (C : ConstantStressSystem) (n : ℕ) :
    remainingMargin C.toSystem n =
      C.capacity - (n : ℝ) * C.perCycleDamage := by
  unfold remainingMargin
  rw [cumulativeDamage_toSystem_eq_mul]
  change C.capacity - (n : ℝ) * C.perCycleDamage =
    C.capacity - (n : ℝ) * C.perCycleDamage
  rfl

/-- If enough constant-damage cycles have elapsed, fatigue failure occurs. -/
theorem failureOccurred_of_cycles_ge
    (C : ConstantStressSystem) (n : ℕ)
    (hdamage : 0 < C.perCycleDamage)
    (hcycles : C.capacity / C.perCycleDamage ≤ (n : ℝ)) :
    FailureOccurred C.toSystem n := by
  unfold FailureOccurred
  rw [cumulativeDamage_toSystem_eq_mul]
  have hmul := (div_le_iff₀ hdamage).1 hcycles
  change C.capacity ≤ (n : ℝ) * C.perCycleDamage
  exact hmul

/-- Positive per-cycle damage creates positive accumulated damage after at
least one cycle. -/
theorem cumulativeDamage_pos_of_pos_damage_and_pos_cycles
    (C : ConstantStressSystem) {n : ℕ}
    (hdamage : 0 < C.perCycleDamage) (hn : 0 < n) :
    0 < cumulativeDamage C.toSystem n := by
  rw [cumulativeDamage_toSystem_eq_mul]
  exact mul_pos (Nat.cast_pos.mpr hn) hdamage

end

end Survival.FatigueDamage
