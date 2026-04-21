import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Buckling / Critical-Load Threshold Skeleton

This module formalizes the Route A bridge example A10 at a deterministic
critical-load level.  It does not derive Euler's buckling formula.  Instead, it
records the operational skeleton:

`load_n = initialLoad + n * loadIncrement`.

The structure remains in the linear stable regime while `load_n <= Pcr`, and
the critical threshold is reached once `Pcr <= load_n`.
-/

namespace Survival.BucklingThreshold

noncomputable section

/-- Deterministic load-ramp data for a critical-load skeleton. -/
structure System where
  initialLoad : ℝ
  loadIncrement : ℝ
  criticalLoad : ℝ
  initial_nonneg : 0 ≤ initialLoad
  increment_nonneg : 0 ≤ loadIncrement
  critical_pos : 0 < criticalLoad

/-- Applied compressive load after `n` load-increase steps. -/
def loadAt (B : System) (n : ℕ) : ℝ :=
  B.initialLoad + (n : ℝ) * B.loadIncrement

/-- Remaining load margin before the critical threshold. -/
def loadMargin (B : System) (n : ℕ) : ℝ :=
  B.criticalLoad - loadAt B n

/-- Stable critical-load regime at a finite prefix. -/
def StableAt (B : System) (n : ℕ) : Prop :=
  loadAt B n ≤ B.criticalLoad

/-- The critical-load threshold has been reached. -/
def CriticalLoadReached (B : System) (n : ℕ) : Prop :=
  B.criticalLoad ≤ loadAt B n

/-- The applied load has strictly exceeded the critical threshold. -/
def Buckled (B : System) (n : ℕ) : Prop :=
  B.criticalLoad < loadAt B n

@[simp] theorem loadAt_zero (B : System) :
    loadAt B 0 = B.initialLoad := by
  simp [loadAt]

@[simp] theorem loadMargin_zero (B : System) :
    loadMargin B 0 = B.criticalLoad - B.initialLoad := by
  simp [loadMargin]

/-- One more step adds exactly the load increment. -/
theorem loadAt_succ (B : System) (n : ℕ) :
    loadAt B (n + 1) = loadAt B n + B.loadIncrement := by
  unfold loadAt
  norm_num
  ring

/-- Load is monotone along a nonnegative load ramp. -/
theorem loadAt_mono (B : System) {n m : ℕ} (hnm : n ≤ m) :
    loadAt B n ≤ loadAt B m := by
  unfold loadAt
  have hcast : (n : ℝ) ≤ (m : ℝ) := by
    exact_mod_cast hnm
  have hmul :
      (n : ℝ) * B.loadIncrement ≤ (m : ℝ) * B.loadIncrement :=
    mul_le_mul_of_nonneg_right hcast B.increment_nonneg
  linarith

/-- Load margin is monotone nonincreasing along the load ramp. -/
theorem loadMargin_mono_decreasing
    (B : System) {n m : ℕ} (hnm : n ≤ m) :
    loadMargin B m ≤ loadMargin B n := by
  unfold loadMargin
  have hload := loadAt_mono B hnm
  linarith

/-- Stability is exactly nonnegative remaining load margin. -/
theorem stableAt_iff_loadMargin_nonneg (B : System) (n : ℕ) :
    StableAt B n ↔ 0 ≤ loadMargin B n := by
  unfold StableAt loadMargin
  constructor <;> intro h <;> linarith

/-- Strict buckling is exactly negative remaining load margin. -/
theorem buckled_iff_loadMargin_neg (B : System) (n : ℕ) :
    Buckled B n ↔ loadMargin B n < 0 := by
  unfold Buckled loadMargin
  constructor <;> intro h <;> linarith

/-- Stable and strictly buckled are complementary finite-prefix readings. -/
theorem stableAt_iff_not_buckled (B : System) (n : ℕ) :
    StableAt B n ↔ ¬ Buckled B n := by
  unfold StableAt Buckled
  constructor
  · intro hstable hbuckled
    linarith
  · intro hnot
    exact le_of_not_gt hnot

/-- If the load ramp has advanced far enough, the critical load is reached. -/
theorem criticalLoadReached_of_steps_ge
    (B : System) (n : ℕ)
    (hincr : 0 < B.loadIncrement)
    (hsteps : (B.criticalLoad - B.initialLoad) / B.loadIncrement ≤ (n : ℝ)) :
    CriticalLoadReached B n := by
  unfold CriticalLoadReached loadAt
  have hmul := (div_le_iff₀ hincr).1 hsteps
  linarith

/-- If the load ramp advances strictly beyond the critical horizon, buckling
has occurred. -/
theorem buckled_of_steps_gt
    (B : System) (n : ℕ)
    (hincr : 0 < B.loadIncrement)
    (hsteps : (B.criticalLoad - B.initialLoad) / B.loadIncrement < (n : ℝ)) :
    Buckled B n := by
  unfold Buckled loadAt
  have hmul := (div_lt_iff₀ hincr).1 hsteps
  linarith

/-- A direct linear-margin proof of critical-load reachability. -/
theorem criticalLoadReached_of_linear_margin
    (B : System) (n : ℕ)
    (hmargin : B.criticalLoad ≤ B.initialLoad + (n : ℝ) * B.loadIncrement) :
    CriticalLoadReached B n := by
  simpa [CriticalLoadReached, loadAt] using hmargin

/-- Positive load increment is a positive per-step structural stress in this
critical-load reading. -/
def stressIncrement (B : System) : ℝ :=
  B.loadIncrement

/-- Cumulative load-ramp stress after `n` steps. -/
def cumulativeStress (B : System) (n : ℕ) : ℝ :=
  (n : ℝ) * stressIncrement B

/-- The load ramp equals initial load plus cumulative stress. -/
theorem loadAt_eq_initial_add_cumulativeStress
    (B : System) (n : ℕ) :
    loadAt B n = B.initialLoad + cumulativeStress B n := by
  rfl

/-- Cumulative stress is nonnegative. -/
theorem cumulativeStress_nonneg (B : System) (n : ℕ) :
    0 ≤ cumulativeStress B n := by
  unfold cumulativeStress stressIncrement
  exact mul_nonneg (Nat.cast_nonneg n) B.increment_nonneg

end

end Survival.BucklingThreshold
