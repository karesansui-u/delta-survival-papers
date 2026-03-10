/-
Arrow of Time - General n-Type H-Theorem (Fully Proved)
時間の矢 - 一般 n 種 H 定理（完全証明）

Completes the general n-type survival selection H-theorem using Finset.sum.

All building blocks were proved in ArrowOfTimeGeneral.lean:
- pairwise_shift: each pair's weight shift
- pairwise_contribution_nonneg: each pair's contribution ≥ 0
- pairwise_contribution_pos: each pair's contribution > 0 for i ≠ j

This file assembles them into the full theorem via:
1. Chebyshev algebraic identity (chebyshev_identity)
2. Positivity of double sum (double_sum_pos)
3. Main theorem (h_theorem_general)

References:
- Chebyshev, P. (1882). Sum inequality for co-monotone sequences
- Generalizes ArrowOfTime.survival_h_theorem from 2 types to n types
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic
import Survival.ArrowOfTime
import Survival.ArrowOfTimeGeneral

open Finset BigOperators

namespace Survival.ArrowOfTimeNGeneral

/-! ## Stage A: Chebyshev Algebraic Identity -/

/-- **Chebyshev algebraic identity.**
    2 × ((Σ aᵢwᵢ)(Σ vⱼ) - (Σ aᵢvᵢ)(Σ wⱼ)) = Σᵢ Σⱼ (aᵢ - aⱼ)(wᵢvⱼ - vᵢwⱼ)
-/
theorem chebyshev_identity {n : ℕ} (a w v : Fin n → ℝ) :
    2 * ((∑ i, a i * w i) * (∑ j, v j) - (∑ i, a i * v i) * (∑ j, w j)) =
    ∑ i, ∑ j, (a i - a j) * (w i * v j - v i * w j) := by
  have expand_rhs : ∑ i : Fin n, ∑ j : Fin n,
      (a i - a j) * (w i * v j - v i * w j) =
      ∑ i, ∑ j, (a i * w i * v j - a i * v i * w j
                 - a j * w i * v j + a j * v i * w j) := by
    congr 1; ext i; congr 1; ext j; ring
  rw [expand_rhs]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have factor := @Fintype.sum_mul_sum (Fin n) (Fin n) ℝ _ _ _
  have t1 : ∑ i : Fin n, ∑ j : Fin n, a i * w i * v j =
      (∑ i, a i * w i) * (∑ j, v j) :=
    (factor (fun i => a i * w i) v).symm
  have t2 : ∑ i : Fin n, ∑ j : Fin n, a i * v i * w j =
      (∑ i, a i * v i) * (∑ j, w j) :=
    (factor (fun i => a i * v i) w).symm
  have t3 : ∑ i : Fin n, ∑ j : Fin n, a j * w i * v j =
      (∑ i, w i) * (∑ j, a j * v j) := by
    rw [Finset.sum_comm]
    simp_rw [show ∀ j i : Fin n, a j * w i * v j = (a j * v j) * w i from
      fun _ _ => by ring]
    rw [← factor]; ring
  have t4 : ∑ i : Fin n, ∑ j : Fin n, a j * v i * w j =
      (∑ i, v i) * (∑ j, a j * w j) := by
    rw [Finset.sum_comm]
    simp_rw [show ∀ j i : Fin n, a j * v i * w j = (a j * w j) * v i from
      fun _ _ => by ring]
    rw [← factor]; ring
  rw [t1, t2, t3, t4]
  ring

/-! ## Stage B: Double Sum Positivity -/

/-- **Double sum is strictly positive for n ≥ 2.** -/
theorem double_sum_pos {n : ℕ} (δ h p : Fin n → ℝ) (t₁ t₂ : ℝ)
    (hn : 2 ≤ n)
    (hδ : StrictMono δ) (hh : StrictMono h)
    (hp : ∀ i, p i > 0) (ht : t₁ < t₂) :
    0 < ∑ i : Fin n, ∑ j : Fin n,
      (δ i - δ j) *
      ((p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
       (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁))) := by
  have h_nonneg : ∀ i ∈ Finset.univ, 0 ≤ ∑ j : Fin n,
      (δ i - δ j) *
      ((p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
       (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁))) := by
    intro i _
    apply Finset.sum_nonneg
    intro j _
    exact ArrowOfTimeGeneral.pairwise_contribution_nonneg δ h p t₁ t₂ hδ hh hp ht i j
  have h_exists_pos : ∃ i ∈ Finset.univ, 0 < ∑ j : Fin n,
      (δ i - δ j) *
      ((p i * Real.exp (-h i * t₁)) * (p j * Real.exp (-h j * t₂)) -
       (p i * Real.exp (-h i * t₂)) * (p j * Real.exp (-h j * t₁))) := by
    refine ⟨⟨0, by omega⟩, Finset.mem_univ _, ?_⟩
    apply Finset.sum_pos'
    · intro j _
      exact ArrowOfTimeGeneral.pairwise_contribution_nonneg δ h p t₁ t₂ hδ hh hp ht
            ⟨0, by omega⟩ j
    · refine ⟨⟨1, by omega⟩, Finset.mem_univ _, ?_⟩
      exact ArrowOfTimeGeneral.pairwise_contribution_pos δ h p t₁ t₂ hδ hh hp ht
            ⟨0, by omega⟩ ⟨1, by omega⟩ (by simp [Fin.ext_iff])
  exact Finset.sum_pos' h_nonneg h_exists_pos

/-! ## Stage C: Main Theorem -/

/-- **General n-Type Survival Selection H-Theorem.**

    For any n ≥ 2 types with strictly co-monotone δ and h,
    positive initial proportions, and t₂ > t₁:
    the survival-weighted average δ strictly decreases.

    ⟨δ⟩(t₂) < ⟨δ⟩(t₁)

    This is the discrete Chebyshev Sum Inequality applied to survival dynamics.
-/
theorem h_theorem_general {n : ℕ} (hn : 2 ≤ n)
    (δ h : Fin n → ℝ) (p : Fin n → ℝ) (t₁ t₂ : ℝ)
    (hδ : StrictMono δ) (hh : StrictMono h)
    (hp : ∀ i, p i > 0) (ht : t₁ < t₂) :
    (∑ i : Fin n, δ i * (p i * Real.exp (-h i * t₂))) *
    (∑ i : Fin n, p i * Real.exp (-h i * t₁)) <
    (∑ i : Fin n, δ i * (p i * Real.exp (-h i * t₁))) *
    (∑ i : Fin n, p i * Real.exp (-h i * t₂)) := by
  set w : Fin n → ℝ := fun i => p i * Real.exp (-h i * t₁)
  set v : Fin n → ℝ := fun i => p i * Real.exp (-h i * t₂)
  suffices hsuff : 0 < (∑ i, δ i * w i) * (∑ j, v j) -
                       (∑ i, δ i * v i) * (∑ j, w j) by linarith
  have h_identity := chebyshev_identity δ w v
  have h_pos := double_sum_pos δ h p t₁ t₂ hn hδ hh hp ht
  linarith

end Survival.ArrowOfTimeNGeneral
