/-
Transition Theorem — Parameter-Free Prediction of Phase Transitions
遷移定理 — 相転移のパラメータフリー予測

Two attractor basins A, B with different per-constraint information losses
I_A ≠ I_B have a unique transition point m* where S_A(m*) = S_B(m*).

  m* = ln(C_A / C_B) / (I_A - I_B)

References:
  - Paper 1, Section 3: SAT ratio prediction
  - Landau first-order phase transition
  - MultiAttractor.lean: Basin definitions and survival functions
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Survival.MultiAttractor

open Real

namespace Survival.TransitionTheorem

noncomputable section

open Survival.MultiAttractor

/-! ## General Transition Condition -/

theorem general_transition_condition (A B : Basin) (δ_A δ_B : ℝ) :
    basinSurvival A δ_A = basinSurvival B δ_B ↔
    A.C * exp (-δ_A) = B.C * exp (-δ_B) := by
  unfold basinSurvival; exact Iff.rfl

theorem transition_delta_difference (A B : Basin) (δ_A δ_B : ℝ)
    (heq : basinSurvival A δ_A = basinSurvival B δ_B) :
    δ_A - δ_B = log (A.C / B.C) := by
  unfold basinSurvival at heq
  have hCA := A.C_pos
  have hCB := B.C_pos
  have hL : log (A.C * exp (-δ_A)) = log (B.C * exp (-δ_B)) := by rw [heq]
  rw [log_mul (ne_of_gt hCA) (ne_of_gt (exp_pos _)),
      log_mul (ne_of_gt hCB) (ne_of_gt (exp_pos _)),
      log_exp, log_exp] at hL
  rw [log_div (ne_of_gt hCA) (ne_of_gt hCB)]
  linarith

/-! ## Uniform Constraint Transition -/

def transitionPoint (A B : Basin) (I_A I_B : ℝ) : ℝ :=
  log (A.C / B.C) / (I_A - I_B)

/-- **Core Theorem**: At the transition point, both basins have equal survival. -/
theorem survival_equal_at_transition (A B : Basin) (I_A I_B : ℝ)
    (hI : I_A ≠ I_B) :
    uniformBasinSurvival A I_A (transitionPoint A B I_A I_B) =
    uniformBasinSurvival B I_B (transitionPoint A B I_A I_B) := by
  unfold uniformBasinSurvival transitionPoint
  have hCB := B.C_pos
  have hCAB : 0 < A.C / B.C := div_pos A.C_pos hCB
  rw [show A.C = B.C * (A.C / B.C) from (mul_div_cancel₀ A.C (ne_of_gt hCB)).symm,
      mul_assoc]
  congr 1
  rw [← exp_log hCAB, ← exp_add]
  congr 1
  rw [exp_log hCAB]
  have hI_ne : I_A - I_B ≠ 0 := sub_ne_zero.mpr hI
  field_simp
  ring

theorem transition_unique (A B : Basin) (I_A I_B : ℝ)
    (hI : I_A ≠ I_B) (_hIA : 0 < I_A) (_hIB : 0 < I_B)
    (m : ℝ) (heq : uniformBasinSurvival A I_A m = uniformBasinSurvival B I_B m) :
    m = transitionPoint A B I_A I_B := by
  unfold uniformBasinSurvival at heq
  unfold transitionPoint
  have hCA := A.C_pos
  have hCB := B.C_pos
  have hI_ne : I_A - I_B ≠ 0 := sub_ne_zero.mpr hI
  have hL : log (A.C * exp (-m * I_A)) = log (B.C * exp (-m * I_B)) := by rw [heq]
  rw [log_mul (ne_of_gt hCA) (ne_of_gt (exp_pos _)),
      log_mul (ne_of_gt hCB) (ne_of_gt (exp_pos _)),
      log_exp, log_exp] at hL
  have h2 : log A.C - log B.C = m * (I_A - I_B) := by linarith
  rw [← log_div (ne_of_gt hCA) (ne_of_gt hCB)] at h2
  field_simp at h2 ⊢
  linarith

/-! ## Pre/Post-Transition Dominance (via log comparison) -/

private lemma log_uniformBasinSurvival (b : Basin) (I m : ℝ) :
    log (uniformBasinSurvival b I m) = log b.C + (-m * I) := by
  unfold uniformBasinSurvival
  rw [log_mul (ne_of_gt b.C_pos) (ne_of_gt (exp_pos _)), log_exp]

theorem basin_A_dominates_before (A B : Basin) (I_A I_B : ℝ)
    (_hIA : 0 < I_A) (_hIB : 0 < I_B) (hI : I_B < I_A) (_hC : B.C < A.C)
    (m : ℝ) (hm : m < transitionPoint A B I_A I_B) :
    uniformBasinSurvival B I_B m < uniformBasinSurvival A I_A m := by
  have hCB := B.C_pos
  have hI_pos : 0 < I_A - I_B := by linarith
  unfold transitionPoint at hm
  have hm_scaled : m * (I_A - I_B) < log (A.C / B.C) := (lt_div_iff₀ hI_pos).mp hm
  rw [← (log_lt_log_iff (uniformBasinSurvival_pos B I_B m)
                         (uniformBasinSurvival_pos A I_A m))]
  rw [log_uniformBasinSurvival, log_uniformBasinSurvival]
  rw [log_div (ne_of_gt A.C_pos) (ne_of_gt hCB)] at hm_scaled
  linarith

theorem basin_B_dominates_after (A B : Basin) (I_A I_B : ℝ)
    (_hIA : 0 < I_A) (_hIB : 0 < I_B) (hI : I_B < I_A) (_hC : B.C < A.C)
    (m : ℝ) (hm : transitionPoint A B I_A I_B < m) :
    uniformBasinSurvival A I_A m < uniformBasinSurvival B I_B m := by
  have hCB := B.C_pos
  have hI_pos : 0 < I_A - I_B := by linarith
  unfold transitionPoint at hm
  have hm_scaled : log (A.C / B.C) < m * (I_A - I_B) := (div_lt_iff₀ hI_pos).mp hm
  rw [← (log_lt_log_iff (uniformBasinSurvival_pos A I_A m)
                         (uniformBasinSurvival_pos B I_B m))]
  rw [log_uniformBasinSurvival, log_uniformBasinSurvival]
  rw [log_div (ne_of_gt A.C_pos) (ne_of_gt hCB)] at hm_scaled
  linarith

theorem transitionPoint_pos (A B : Basin) (I_A I_B : ℝ)
    (hI : I_B < I_A) (hC : B.C < A.C) :
    0 < transitionPoint A B I_A I_B := by
  unfold transitionPoint
  apply div_pos
  · rw [log_div (ne_of_gt A.C_pos) (ne_of_gt B.C_pos)]
    linarith [log_lt_log B.C_pos hC]
  · linarith

end

end Survival.TransitionTheorem
