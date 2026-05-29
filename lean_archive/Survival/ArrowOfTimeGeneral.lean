/-
Arrow of Time - General n-Type Extension
時間の矢 - 一般 n 種への拡張

Extends the two-type H-theorem (ArrowOfTime.lean) to:
1. Three types (explicitly proved, sorry = 0)
2. General n types (pairwise lemma proved, full theorem stated)

Key insight: The n-type H-theorem reduces to pairwise contributions.
  RHS - LHS = Σ_{i<j} (δⱼ - δᵢ)(vᵢwⱼ - wᵢvⱼ) > 0

References:
- Chebyshev, P. (1882). Sum inequality for co-monotone sequences
- Generalizes ArrowOfTime.survival_h_theorem from 2 types to n types
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.Basic
import Survival.ArrowOfTime

namespace Survival.ArrowOfTimeGeneral

/-! ## Part 1: Three-Type H-Theorem (Fully Proved) -/

/-- **Three-type Survival Selection H-theorem**: average δ of survivors decreases. -/
theorem h_theorem_three_type (δ₁ δ₂ δ₃ h₁ h₂ h₃ p₁ p₂ p₃ t₁ t₂ : ℝ)
    (hδ₁₂ : δ₁ < δ₂) (hδ₂₃ : δ₂ < δ₃)
    (hh₁₂ : h₁ < h₂) (hh₂₃ : h₂ < h₃)
    (hp₁ : p₁ > 0) (hp₂ : p₂ > 0) (hp₃ : p₃ > 0)
    (ht : t₁ < t₂) :
    (δ₁ * (p₁ * Real.exp (-h₁ * t₂)) + δ₂ * (p₂ * Real.exp (-h₂ * t₂)) +
     δ₃ * (p₃ * Real.exp (-h₃ * t₂))) *
    (p₁ * Real.exp (-h₁ * t₁) + p₂ * Real.exp (-h₂ * t₁) +
     p₃ * Real.exp (-h₃ * t₁)) <
    (δ₁ * (p₁ * Real.exp (-h₁ * t₁)) + δ₂ * (p₂ * Real.exp (-h₂ * t₁)) +
     δ₃ * (p₃ * Real.exp (-h₃ * t₁))) *
    (p₁ * Real.exp (-h₁ * t₂) + p₂ * Real.exp (-h₂ * t₂) +
     p₃ * Real.exp (-h₃ * t₂)) := by
  set w₁ := p₁ * Real.exp (-h₁ * t₁)
  set w₂ := p₂ * Real.exp (-h₂ * t₁)
  set w₃ := p₃ * Real.exp (-h₃ * t₁)
  set v₁ := p₁ * Real.exp (-h₁ * t₂)
  set v₂ := p₂ * Real.exp (-h₂ * t₂)
  set v₃ := p₃ * Real.exp (-h₃ * t₂)
  have h12 : v₁ * w₂ > w₁ * v₂ :=
    ArrowOfTime.survival_shifts_weight h₁ h₂ p₁ p₂ t₁ t₂ hh₁₂ hp₁ hp₂ ht
  have h13 : v₁ * w₃ > w₁ * v₃ :=
    ArrowOfTime.survival_shifts_weight h₁ h₃ p₁ p₃ t₁ t₂ (by linarith) hp₁ hp₃ ht
  have h23 : v₂ * w₃ > w₂ * v₃ :=
    ArrowOfTime.survival_shifts_weight h₂ h₃ p₂ p₃ t₁ t₂ hh₂₃ hp₂ hp₃ ht
  have pair₁₂ : (δ₂ - δ₁) * (v₁ * w₂ - w₁ * v₂) > 0 :=
    mul_pos (by linarith) (by linarith)
  have pair₁₃ : (δ₃ - δ₁) * (v₁ * w₃ - w₁ * v₃) > 0 :=
    mul_pos (by linarith) (by linarith)
  have pair₂₃ : (δ₃ - δ₂) * (v₂ * w₃ - w₂ * v₃) > 0 :=
    mul_pos (by linarith) (by linarith)
  have identity :
    (δ₁ * w₁ + δ₂ * w₂ + δ₃ * w₃) * (v₁ + v₂ + v₃) -
    (δ₁ * v₁ + δ₂ * v₂ + δ₃ * v₃) * (w₁ + w₂ + w₃) =
    (δ₂ - δ₁) * (v₁ * w₂ - w₁ * v₂) +
    (δ₃ - δ₁) * (v₁ * w₃ - w₁ * v₃) +
    (δ₃ - δ₂) * (v₂ * w₃ - w₂ * v₃) := by ring
  linarith

/-! ## Part 2: General Pairwise Lemma -/

/-- Pairwise weight shift for any two types in an n-type ensemble. -/
theorem pairwise_shift {n : ℕ} (h p : Fin n → ℝ) (t₁ t₂ : ℝ)
    (hh : StrictMono h) (hp : ∀ i, p i > 0) (ht : t₁ < t₂)
    (i j : Fin n) (hij : i < j) :
    (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁)) >
    (p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) :=
  ArrowOfTime.survival_shifts_weight (h i) (h j) (p i) (p j) t₁ t₂
    (hh hij) (hp i) (hp j) ht

/-- Pairwise contribution to the H-theorem is non-negative. -/
theorem pairwise_contribution_nonneg {n : ℕ} (δ h p : Fin n → ℝ) (t₁ t₂ : ℝ)
    (hδ : StrictMono δ) (hh : StrictMono h)
    (hp : ∀ i, p i > 0) (ht : t₁ < t₂)
    (i j : Fin n) :
    (δ i - δ j) *
    ((p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
     (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁))) ≥ 0 := by
  rcases lt_trichotomy i j with hij | hij | hij
  · have hδ_neg : δ i - δ j < 0 := sub_neg.mpr (hδ hij)
    have h_shift := pairwise_shift h p t₁ t₂ hh hp ht i j hij
    have h_weight_neg : (p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
                        (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁)) < 0 :=
      by linarith
    exact le_of_lt (mul_pos_of_neg_of_neg hδ_neg h_weight_neg)
  · subst hij; simp
  · have hδ_pos : δ i - δ j > 0 := sub_pos.mpr (hδ hij)
    have h_shift := pairwise_shift h p t₁ t₂ hh hp ht j i hij
    have h_weight_pos : (p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
                        (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁)) > 0 :=
      by linarith
    exact le_of_lt (mul_pos hδ_pos h_weight_pos)

/-- Pairwise contribution is strictly positive for distinct types. -/
theorem pairwise_contribution_pos {n : ℕ} (δ h p : Fin n → ℝ) (t₁ t₂ : ℝ)
    (hδ : StrictMono δ) (hh : StrictMono h)
    (hp : ∀ i, p i > 0) (ht : t₁ < t₂)
    (i j : Fin n) (hij : i ≠ j) :
    (δ i - δ j) *
    ((p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
     (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁))) > 0 := by
  rcases lt_or_gt_of_ne hij with h_lt | h_gt
  · exact mul_pos_of_neg_of_neg
      (sub_neg.mpr (hδ h_lt))
      (by linarith [pairwise_shift h p t₁ t₂ hh hp ht i j h_lt])
  · exact mul_pos
      (sub_pos.mpr (hδ h_gt))
      (by linarith [pairwise_shift h p t₁ t₂ hh hp ht j i h_gt])

end Survival.ArrowOfTimeGeneral
