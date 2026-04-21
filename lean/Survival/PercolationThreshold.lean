import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Percolation / Giant-Component Threshold Skeleton

This module formalizes Route A bridge examples A11/A12 at a deterministic
threshold level.  It does not prove a random-graph or lattice percolation
theorem.  Instead, it records the finite-prefix control skeleton:

`occupation_n = initialOccupation + n * occupationIncrement`.

The subcritical regime is `occupation_n <= pc`; the threshold is reached once
`pc <= occupation_n`, and the supercritical regime is `pc < occupation_n`.
-/

namespace Survival.PercolationThreshold

noncomputable section

/-- Deterministic occupation ramp for a percolation-threshold skeleton. -/
structure System where
  initialOccupation : ℝ
  occupationIncrement : ℝ
  criticalOccupation : ℝ
  initial_nonneg : 0 ≤ initialOccupation
  increment_nonneg : 0 ≤ occupationIncrement
  critical_pos : 0 < criticalOccupation

/-- Occupation probability / density after `n` exposure steps. -/
def occupationAt (P : System) (n : ℕ) : ℝ :=
  P.initialOccupation + (n : ℝ) * P.occupationIncrement

/-- Remaining gap to the percolation threshold. -/
def thresholdGap (P : System) (n : ℕ) : ℝ :=
  P.criticalOccupation - occupationAt P n

/-- Finite-prefix subcritical regime. -/
def SubcriticalAt (P : System) (n : ℕ) : Prop :=
  occupationAt P n ≤ P.criticalOccupation

/-- The percolation threshold has been reached. -/
def ThresholdReached (P : System) (n : ℕ) : Prop :=
  P.criticalOccupation ≤ occupationAt P n

/-- The occupation is strictly above the critical threshold. -/
def SupercriticalAt (P : System) (n : ℕ) : Prop :=
  P.criticalOccupation < occupationAt P n

@[simp] theorem occupationAt_zero (P : System) :
    occupationAt P 0 = P.initialOccupation := by
  simp [occupationAt]

@[simp] theorem thresholdGap_zero (P : System) :
    thresholdGap P 0 = P.criticalOccupation - P.initialOccupation := by
  simp [thresholdGap]

/-- One more exposure step adds exactly the occupation increment. -/
theorem occupationAt_succ (P : System) (n : ℕ) :
    occupationAt P (n + 1) =
      occupationAt P n + P.occupationIncrement := by
  unfold occupationAt
  norm_num
  ring

/-- Occupation is monotone along a nonnegative exposure ramp. -/
theorem occupationAt_mono (P : System) {n m : ℕ} (hnm : n ≤ m) :
    occupationAt P n ≤ occupationAt P m := by
  unfold occupationAt
  have hcast : (n : ℝ) ≤ (m : ℝ) := by
    exact_mod_cast hnm
  have hmul :
      (n : ℝ) * P.occupationIncrement ≤
        (m : ℝ) * P.occupationIncrement :=
    mul_le_mul_of_nonneg_right hcast P.increment_nonneg
  linarith

/-- The threshold gap is monotone nonincreasing along the exposure ramp. -/
theorem thresholdGap_mono_decreasing
    (P : System) {n m : ℕ} (hnm : n ≤ m) :
    thresholdGap P m ≤ thresholdGap P n := by
  unfold thresholdGap
  have hocc := occupationAt_mono P hnm
  linarith

/-- Subcriticality is exactly nonnegative threshold gap. -/
theorem subcriticalAt_iff_thresholdGap_nonneg
    (P : System) (n : ℕ) :
    SubcriticalAt P n ↔ 0 ≤ thresholdGap P n := by
  unfold SubcriticalAt thresholdGap
  constructor <;> intro h <;> linarith

/-- Supercriticality is exactly negative threshold gap. -/
theorem supercriticalAt_iff_thresholdGap_neg
    (P : System) (n : ℕ) :
    SupercriticalAt P n ↔ thresholdGap P n < 0 := by
  unfold SupercriticalAt thresholdGap
  constructor <;> intro h <;> linarith

/-- Subcritical and strictly supercritical are complementary finite-prefix
readings. -/
theorem subcriticalAt_iff_not_supercritical
    (P : System) (n : ℕ) :
    SubcriticalAt P n ↔ ¬ SupercriticalAt P n := by
  unfold SubcriticalAt SupercriticalAt
  constructor
  · intro hsub hsuper
    linarith
  · intro hnot
    exact le_of_not_gt hnot

/-- If the occupation ramp has advanced far enough, the percolation threshold
is reached. -/
theorem thresholdReached_of_steps_ge
    (P : System) (n : ℕ)
    (hincr : 0 < P.occupationIncrement)
    (hsteps :
      (P.criticalOccupation - P.initialOccupation) /
        P.occupationIncrement ≤ (n : ℝ)) :
    ThresholdReached P n := by
  unfold ThresholdReached occupationAt
  have hmul := (div_le_iff₀ hincr).1 hsteps
  linarith

/-- If the occupation ramp advances strictly beyond the critical horizon, the
system is supercritical. -/
theorem supercriticalAt_of_steps_gt
    (P : System) (n : ℕ)
    (hincr : 0 < P.occupationIncrement)
    (hsteps :
      (P.criticalOccupation - P.initialOccupation) /
        P.occupationIncrement < (n : ℝ)) :
    SupercriticalAt P n := by
  unfold SupercriticalAt occupationAt
  have hmul := (div_lt_iff₀ hincr).1 hsteps
  linarith

/-- A direct linear-margin proof of threshold reachability. -/
theorem thresholdReached_of_linear_margin
    (P : System) (n : ℕ)
    (hmargin :
      P.criticalOccupation ≤
        P.initialOccupation + (n : ℝ) * P.occupationIncrement) :
    ThresholdReached P n := by
  simpa [ThresholdReached, occupationAt] using hmargin

/-- Per-step occupation exposure, read as the structural control parameter. -/
def exposureIncrement (P : System) : ℝ :=
  P.occupationIncrement

/-- Cumulative occupation exposure after `n` steps. -/
def cumulativeExposure (P : System) (n : ℕ) : ℝ :=
  (n : ℝ) * exposureIncrement P

/-- Occupation equals initial occupation plus cumulative exposure. -/
theorem occupationAt_eq_initial_add_cumulativeExposure
    (P : System) (n : ℕ) :
    occupationAt P n = P.initialOccupation + cumulativeExposure P n := by
  rfl

/-- Cumulative exposure is nonnegative. -/
theorem cumulativeExposure_nonneg (P : System) (n : ℕ) :
    0 ≤ cumulativeExposure P n := by
  unfold cumulativeExposure exposureIncrement
  exact mul_nonneg (Nat.cast_nonneg n) P.increment_nonneg

end

end Survival.PercolationThreshold
