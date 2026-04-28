import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Survival.SaturationDefect

/-!
# Defect-Controlled Admissible-Map Compatibility

This module closes the narrow algebraic bridge between exact admissible-map
compatibility and saturation-defect coarse-graining.

The setting is still at the finite readout level.  We track two mass readouts:

* `f t`: the feasible-region mass at time `t`;
* `c t`: the contracted-intermediate mass at time `t`.

Their coarse / saturated counterparts are `F t` and `C t`.  If the feasible
defect is

`eV t = log (F t / f t)`

and the contracted-intermediate defect is

`eC t = log (C t / c t)`,

then the contracted defect appears in both the contraction-loss and repair-gain
readouts, and cancels in the signed net action:

`b̄_t = b_t + eV t - eV (t+1)`.

Consequently, cumulative coarse signed action differs from the micro signed
action only by the endpoint feasible defects:

`B̄_n = B_n + eV 0 - eV n`.

This deliberately does **not** define a full measurable coarse map and does
**not** prove an unconditional DPI.  It is the algebra that a later set-level
admissible-map interface should instantiate.
-/

open scoped BigOperators
open Finset

namespace Survival.DefectControlledAdmissibleMap

open Survival.SaturationDefect

noncomputable section

/-- Readout-level contraction loss from feasible mass to contracted mass. -/
def contractionLoss (feasibleMass contractedMass : ℕ → ℝ) (t : ℕ) : ℝ :=
  -Real.log (contractedMass t / feasibleMass t)

/-- Readout-level repair gain from contracted mass to next feasible mass. -/
def repairGain (feasibleMass contractedMass : ℕ → ℝ) (t : ℕ) : ℝ :=
  Real.log (feasibleMass (t + 1) / contractedMass t)

/-- Signed net action: contraction loss minus repair gain. -/
def stepNetAction (feasibleMass contractedMass : ℕ → ℝ) (t : ℕ) : ℝ :=
  contractionLoss feasibleMass contractedMass t -
    repairGain feasibleMass contractedMass t

/-- Cumulative signed net action for a two-stage readout. -/
def cumulativeNetAction (feasibleMass contractedMass : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, stepNetAction feasibleMass contractedMass t

/-- The contraction-loss readout carries both feasible and contracted defects. -/
theorem contractionLoss_coarse_eq_micro_add_feasible_defect_sub_contracted_defect
    (f c F C : ℕ → ℝ) (t : ℕ)
    (hf : 0 < f t) (hc : 0 < c t) (hF : 0 < F t) (hC : 0 < C t) :
    contractionLoss F C t =
      contractionLoss f c t +
        saturationDefect f F t - saturationDefect c C t := by
  have hf_ne : f t ≠ 0 := ne_of_gt hf
  have hc_ne : c t ≠ 0 := ne_of_gt hc
  have hF_ne : F t ≠ 0 := ne_of_gt hF
  have hC_ne : C t ≠ 0 := ne_of_gt hC
  unfold contractionLoss saturationDefect
  rw [Real.log_div hC_ne hF_ne]
  rw [Real.log_div hc_ne hf_ne]
  rw [Real.log_div hF_ne hf_ne]
  rw [Real.log_div hC_ne hc_ne]
  ring

/-- The repair-gain readout carries the next feasible defect and the contracted
intermediate defect. -/
theorem repairGain_coarse_eq_micro_add_next_feasible_defect_sub_contracted_defect
    (f c F C : ℕ → ℝ) (t : ℕ)
    (hf_next : 0 < f (t + 1)) (hc : 0 < c t)
    (hF_next : 0 < F (t + 1)) (hC : 0 < C t) :
    repairGain F C t =
      repairGain f c t +
        saturationDefect f F (t + 1) - saturationDefect c C t := by
  have hf_ne : f (t + 1) ≠ 0 := ne_of_gt hf_next
  have hc_ne : c t ≠ 0 := ne_of_gt hc
  have hF_ne : F (t + 1) ≠ 0 := ne_of_gt hF_next
  have hC_ne : C t ≠ 0 := ne_of_gt hC
  unfold repairGain saturationDefect
  rw [Real.log_div hF_ne hC_ne]
  rw [Real.log_div hf_ne hc_ne]
  rw [Real.log_div hF_ne hf_ne]
  rw [Real.log_div hC_ne hc_ne]
  ring

/-- Contracted-intermediate defects cancel in the signed net action. -/
theorem stepNetAction_coarse_eq_micro_add_feasible_defect_sub_next_feasible_defect
    (f c F C : ℕ → ℝ) (t : ℕ)
    (hf : 0 < f t) (hf_next : 0 < f (t + 1)) (hc : 0 < c t)
    (hF : 0 < F t) (hF_next : 0 < F (t + 1)) (hC : 0 < C t) :
    stepNetAction F C t =
      stepNetAction f c t +
        saturationDefect f F t - saturationDefect f F (t + 1) := by
  unfold stepNetAction
  rw [contractionLoss_coarse_eq_micro_add_feasible_defect_sub_contracted_defect
    f c F C t hf hc hF hC]
  rw [repairGain_coarse_eq_micro_add_next_feasible_defect_sub_contracted_defect
    f c F C t hf_next hc hF_next hC]
  ring

/-- Cumulative coarse signed action differs from micro signed action only by
the endpoint feasible defects. -/
theorem cumulativeNetAction_coarse_eq_micro_add_initial_defect_sub_terminal
    (f c F C : ℕ → ℝ) (n : ℕ)
    (hf : ∀ t, t ≤ n → 0 < f t)
    (hc : ∀ t, t < n → 0 < c t)
    (hF : ∀ t, t ≤ n → 0 < F t)
    (hC : ∀ t, t < n → 0 < C t) :
    cumulativeNetAction F C n =
      cumulativeNetAction f c n +
        saturationDefect f F 0 - saturationDefect f F n := by
  induction n with
  | zero =>
      simp [cumulativeNetAction]
  | succ n ih =>
      have ih' :
          cumulativeNetAction F C n =
            cumulativeNetAction f c n +
              saturationDefect f F 0 - saturationDefect f F n := by
        exact ih
          (fun t ht => hf t (Nat.le_trans ht (Nat.le_succ n)))
          (fun t ht => hc t (Nat.lt_trans ht (Nat.lt_succ_self n)))
          (fun t ht => hF t (Nat.le_trans ht (Nat.le_succ n)))
          (fun t ht => hC t (Nat.lt_trans ht (Nat.lt_succ_self n)))
      unfold cumulativeNetAction at ih' ⊢
      rw [Finset.sum_range_succ, Finset.sum_range_succ]
      rw [ih']
      have hstep :
          stepNetAction F C n =
            stepNetAction f c n +
              saturationDefect f F n - saturationDefect f F (n + 1) :=
        stepNetAction_coarse_eq_micro_add_feasible_defect_sub_next_feasible_defect
          f c F C n
          (hf n (Nat.le_succ n))
          (hf (n + 1) (Nat.le_refl (n + 1)))
          (hc n (Nat.lt_succ_self n))
          (hF n (Nat.le_succ n))
          (hF (n + 1) (Nat.le_refl (n + 1)))
          (hC n (Nat.lt_succ_self n))
      rw [hstep]
      ring

/-- Conditional DPI-style monotonicity for signed action: coarse action is at
most micro action when terminal feasible defect is at least the initial
feasible defect. -/
theorem cumulativeNetAction_coarse_le_micro_of_terminal_defect_ge_initial
    (f c F C : ℕ → ℝ) (n : ℕ)
    (hf : ∀ t, t ≤ n → 0 < f t)
    (hc : ∀ t, t < n → 0 < c t)
    (hF : ∀ t, t ≤ n → 0 < F t)
    (hC : ∀ t, t < n → 0 < C t)
    (hmono : saturationDefect f F 0 ≤ saturationDefect f F n) :
    cumulativeNetAction F C n ≤ cumulativeNetAction f c n := by
  rw [cumulativeNetAction_coarse_eq_micro_add_initial_defect_sub_terminal
    f c F C n hf hc hF hC]
  linarith

/-- The reverse comparison can hold when terminal feasible defect is no larger
than the initial feasible defect.  This is a guardrail against unconditional
DPI claims. -/
theorem micro_cumulativeNetAction_le_coarse_of_terminal_defect_le_initial
    (f c F C : ℕ → ℝ) (n : ℕ)
    (hf : ∀ t, t ≤ n → 0 < f t)
    (hc : ∀ t, t < n → 0 < c t)
    (hF : ∀ t, t ≤ n → 0 < F t)
    (hC : ∀ t, t < n → 0 < C t)
    (hmono : saturationDefect f F n ≤ saturationDefect f F 0) :
    cumulativeNetAction f c n ≤ cumulativeNetAction F C n := by
  rw [cumulativeNetAction_coarse_eq_micro_add_initial_defect_sub_terminal
    f c F C n hf hc hF hC]
  linarith

end

end Survival.DefectControlledAdmissibleMap
