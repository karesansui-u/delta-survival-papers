import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Memory Thrashing / Working-Set Overflow Skeleton

This module formalizes the Route A bridge example A27 at a deterministic
working-set level.  It does not model an operating-system page replacement
algorithm.  Instead, it records the minimal resource-overflow skeleton:

`faultPressure_n = initial + n * (workingSet - physicalMemory)`.

If the working set fits in physical memory, pressure does not grow.  If the
working set exceeds physical memory, page-fault pressure accumulates linearly
and crosses any finite operational threshold once enough steps have elapsed.
-/

namespace Survival.MemoryThrashing

noncomputable section

/-- Deterministic working-set model. -/
structure System where
  workingSet : ℝ
  physicalMemory : ℝ
  workingSet_nonneg : 0 ≤ workingSet
  physicalMemory_nonneg : 0 ≤ physicalMemory

/-- Per-step working-set excess over physical memory. -/
def excessWorkingSet (M : System) : ℝ :=
  M.workingSet - M.physicalMemory

/-- Remaining physical-memory margin in the non-thrashing regime. -/
def memoryMargin (M : System) : ℝ :=
  M.physicalMemory - M.workingSet

/-- Accumulated page-fault / locality pressure after `n` steps. -/
def faultPressure (M : System) (initial : ℝ) (n : ℕ) : ℝ :=
  initial + (n : ℝ) * excessWorkingSet M

/-- Finite-prefix thrashing threshold event. -/
def ThrashingThresholdExceeded
    (M : System) (initial : ℝ) (n : ℕ) (threshold : ℝ) : Prop :=
  threshold ≤ faultPressure M initial n

@[simp] theorem faultPressure_zero (M : System) (initial : ℝ) :
    faultPressure M initial 0 = initial := by
  simp [faultPressure]

/-- One more step adds exactly the working-set excess. -/
theorem faultPressure_succ (M : System) (initial : ℝ) (n : ℕ) :
    faultPressure M initial (n + 1) =
      faultPressure M initial n + excessWorkingSet M := by
  unfold faultPressure
  norm_num
  ring

/-- If the working set fits in memory, the margin is nonnegative. -/
theorem memoryMargin_nonneg_of_fits
    (M : System) (hfits : M.workingSet ≤ M.physicalMemory) :
    0 ≤ memoryMargin M := by
  unfold memoryMargin
  linarith

/-- If the working set fits in memory, excess demand is nonpositive. -/
theorem excessWorkingSet_nonpos_of_fits
    (M : System) (hfits : M.workingSet ≤ M.physicalMemory) :
    excessWorkingSet M ≤ 0 := by
  unfold excessWorkingSet
  linarith

/-- If the working set exceeds memory, excess demand is strictly positive. -/
theorem excessWorkingSet_pos_of_thrashing
    (M : System) (hthrash : M.physicalMemory < M.workingSet) :
    0 < excessWorkingSet M := by
  unfold excessWorkingSet
  linarith

/-- In the fitted regime, page-fault pressure does not exceed its initial
level in this deterministic skeleton. -/
theorem faultPressure_le_initial_of_fits
    (M : System) (initial : ℝ) (n : ℕ)
    (hfits : M.workingSet ≤ M.physicalMemory) :
    faultPressure M initial n ≤ initial := by
  unfold faultPressure
  have hex : excessWorkingSet M ≤ 0 :=
    excessWorkingSet_nonpos_of_fits M hfits
  have hmul : (n : ℝ) * excessWorkingSet M ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (Nat.cast_nonneg n) hex
  linarith

/-- In the thrashing regime, page-fault pressure is monotone over time. -/
theorem faultPressure_mono_of_thrashing
    (M : System) (initial : ℝ) {n m : ℕ}
    (hthrash : M.physicalMemory < M.workingSet) (hnm : n ≤ m) :
    faultPressure M initial n ≤ faultPressure M initial m := by
  unfold faultPressure
  have hex_nonneg : 0 ≤ excessWorkingSet M :=
    le_of_lt (excessWorkingSet_pos_of_thrashing M hthrash)
  have hcast : (n : ℝ) ≤ (m : ℝ) := by
    exact_mod_cast hnm
  have hmul :
      (n : ℝ) * excessWorkingSet M ≤ (m : ℝ) * excessWorkingSet M :=
    mul_le_mul_of_nonneg_right hcast hex_nonneg
  linarith

/-- If enough thrashing steps have elapsed, the fault-pressure threshold is
crossed. -/
theorem thresholdExceeded_of_steps_ge
    (M : System) (initial threshold : ℝ) (n : ℕ)
    (hthrash : M.physicalMemory < M.workingSet)
    (hsteps : (threshold - initial) / excessWorkingSet M ≤ (n : ℝ)) :
    ThrashingThresholdExceeded M initial n threshold := by
  unfold ThrashingThresholdExceeded faultPressure
  have hex : 0 < excessWorkingSet M :=
    excessWorkingSet_pos_of_thrashing M hthrash
  have hbase : threshold - initial ≤ (n : ℝ) * excessWorkingSet M := by
    have hmul := (div_le_iff₀ hex).1 hsteps
    linarith [hmul]
  linarith

/-- Equivalent reading: a linear margin inequality is enough to certify
threshold crossing. -/
theorem thresholdExceeded_of_linear_margin
    (M : System) (initial threshold : ℝ) (n : ℕ)
    (hmargin : threshold ≤ initial + (n : ℝ) * excessWorkingSet M) :
    ThrashingThresholdExceeded M initial n threshold := by
  simpa [ThrashingThresholdExceeded, faultPressure] using hmargin

/-- The per-step structural loss in the working-set-overflow reading. -/
def thrashingLoss (M : System) : ℝ :=
  excessWorkingSet M

/-- Cumulative thrashing loss after `n` steps. -/
def cumulativeThrashingLoss (M : System) (n : ℕ) : ℝ :=
  (n : ℝ) * thrashingLoss M

/-- Cumulative thrashing loss is the fault-pressure increase over the initial
level. -/
theorem faultPressure_eq_initial_add_cumulativeThrashingLoss
    (M : System) (initial : ℝ) (n : ℕ) :
    faultPressure M initial n =
      initial + cumulativeThrashingLoss M n := by
  rfl

/-- In the thrashing regime, per-step thrashing loss is strictly positive. -/
theorem thrashingLoss_pos_of_thrashing
    (M : System) (hthrash : M.physicalMemory < M.workingSet) :
    0 < thrashingLoss M := by
  exact excessWorkingSet_pos_of_thrashing M hthrash

/-- In the thrashing regime, cumulative thrashing loss is nonnegative. -/
theorem cumulativeThrashingLoss_nonneg_of_thrashing
    (M : System) (n : ℕ)
    (hthrash : M.physicalMemory < M.workingSet) :
    0 ≤ cumulativeThrashingLoss M n := by
  unfold cumulativeThrashingLoss
  exact mul_nonneg (Nat.cast_nonneg n)
    (le_of_lt (thrashingLoss_pos_of_thrashing M hthrash))

end

end Survival.MemoryThrashing
