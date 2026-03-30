/-
Weak Dependence — Robust Exponential Survival Bounds
弱依存 — 指数型存続のロバスト境界

This module formalizes a *modeling interface* for weakly dependent constraints:
weak dependence is encoded as a sandwich of the joint survival probability P
between two scaled exponentials in δ.

  exp(-δ·(1+ρ)) ≤ P ≤ exp(-δ·(1-ρ))   (0 ≤ ρ < 1, δ ≥ 0)

When ρ = 0 this collapses to P = exp(-δ), matching full independence
(`AxiomsToExp.joint_survival_eq_exp_neg_delta`).

The lower endpoint is a *conservative* (pessimistic) survival factor when ρ > 0:
it is never larger than the independent case.

References:
- Paper 1: independence axiom (A3) and empirical relaxation for correlated systems
- Connection: `Survival.AxiomsToExp`
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.AxiomsToExp

open Real

namespace Survival.WeakDependence

noncomputable section

/-! ## Scaled exponentials (ρ-parameterized bracket) -/

/-- Conservative survival factor: exp(-δ·(1+ρ)).
    Larger ρ ⇒ more negative exponent ⇒ smaller factor (pessimistic bound). -/
def conservativeSurvival (δ ρ : ℝ) : ℝ :=
  exp (-(δ * (1 + ρ)))

/-- Optimistic survival factor: exp(-δ·(1-ρ)).
    Larger ρ ⇒ less negative exponent ⇒ larger factor. -/
def optimisticSurvival (δ ρ : ℝ) : ℝ :=
  exp (-(δ * (1 - ρ)))

/-! ## Weak dependence as a sandwich predicate -/

/-- Joint survival P lies in the [conservative, optimistic] interval induced by (δ, ρ). -/
structure WeakDependenceSandwich (P δ ρ : ℝ) : Prop where
  lower : conservativeSurvival δ ρ ≤ P
  upper : P ≤ optimisticSurvival δ ρ

/-- Pairwise covariance-style bound (abstract; used as documentation / future extension).
    |cov| ≤ ρ·P(A)·P(B) is a common weak-dependence parameterization in probability. -/
structure PairwiseCovarianceBound (cov pA pB ρ : ℝ) : Prop where
  abs_le : |cov| ≤ ρ * pA * pB

/-! ## ρ = 0: collapse to independence scale -/

@[simp]
theorem conservativeSurvival_rho_zero (δ : ℝ) : conservativeSurvival δ 0 = exp (-δ) := by
  unfold conservativeSurvival
  simp

@[simp]
theorem optimisticSurvival_rho_zero (δ : ℝ) : optimisticSurvival δ 0 = exp (-δ) := by
  unfold optimisticSurvival
  simp

theorem weakDependenceSandwich_rho_zero {P δ : ℝ} :
    WeakDependenceSandwich P δ 0 ↔ exp (-δ) ≤ P ∧ P ≤ exp (-δ) := by
  constructor
  · intro h
    exact ⟨by simpa [conservativeSurvival_rho_zero] using h.lower,
           by simpa [optimisticSurvival_rho_zero] using h.upper⟩
  · intro ⟨hl, hu⟩
    refine ⟨?_, ?_⟩
    · simpa [conservativeSurvival_rho_zero] using hl
    · simpa [optimisticSurvival_rho_zero] using hu

theorem weakDependenceSandwich_rho_zero_iff_eq {P δ : ℝ} :
    WeakDependenceSandwich P δ 0 ↔ P = exp (-δ) := by
  rw [weakDependenceSandwich_rho_zero]
  constructor
  · intro ⟨hl, hu⟩; exact le_antisymm hu hl
  · intro h; rw [h]; exact ⟨le_rfl, le_rfl⟩

/-! ## Connection to AxiomsToExp (independent product) -/

theorem joint_independent_satisfies_sandwich_rho_zero {ι : Type*}
    (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    WeakDependenceSandwich (AxiomsToExp.jointSurvival s p)
      (AxiomsToExp.delta s p) 0 := by
  classical
  have hjs := AxiomsToExp.joint_survival_eq_exp_neg_delta s p hp_pos
  rw [weakDependenceSandwich_rho_zero_iff_eq, hjs]

/-! ## Monotonicity: conservative ↓ and optimistic ↑ in ρ (δ ≥ 0) -/

theorem conservativeSurvival_antitone_in_rho {δ ρ₁ ρ₂ : ℝ}
    (hδ : 0 ≤ δ) (hρ : ρ₁ ≤ ρ₂) :
    conservativeSurvival δ ρ₂ ≤ conservativeSurvival δ ρ₁ := by
  unfold conservativeSurvival
  have _h1 : δ * (1 + ρ₁) ≤ δ * (1 + ρ₂) := by
    apply mul_le_mul_of_nonneg_left _ hδ
    linarith
  have hexp : -(δ * (1 + ρ₂)) ≤ -(δ * (1 + ρ₁)) := by linarith
  exact (exp_le_exp).2 hexp

theorem optimisticSurvival_mono_in_rho {δ ρ₁ ρ₂ : ℝ}
    (hδ : 0 ≤ δ) (hρ : ρ₁ ≤ ρ₂) :
    optimisticSurvival δ ρ₁ ≤ optimisticSurvival δ ρ₂ := by
  unfold optimisticSurvival
  have _h1 : δ * (1 - ρ₂) ≤ δ * (1 - ρ₁) := by
    apply mul_le_mul_of_nonneg_left _ hδ
    linarith
  have hexp : -(δ * (1 - ρ₁)) ≤ -(δ * (1 - ρ₂)) := by linarith
  exact (exp_le_exp).2 hexp

/-! ## Conservative never exceeds independent survival (ρ ≥ 0, δ ≥ 0) -/

theorem conservative_le_independent {δ ρ : ℝ}
    (hδ : 0 ≤ δ) (hρ : 0 ≤ ρ) :
    conservativeSurvival δ ρ ≤ exp (-δ) := by
  unfold conservativeSurvival
  have hmul : δ ≤ δ * (1 + ρ) := by
    have : δ * 1 ≤ δ * (1 + ρ) := mul_le_mul_of_nonneg_left (by linarith) hδ
    simpa using this
  have hneg : -(δ * (1 + ρ)) ≤ -δ := by linarith
  exact (exp_le_exp).2 hneg

theorem independent_le_optimistic {δ ρ : ℝ}
    (hδ : 0 ≤ δ) (hρ₀ : 0 ≤ ρ) :
    exp (-δ) ≤ optimisticSurvival δ ρ := by
  unfold optimisticSurvival
  have hmul : δ * (1 - ρ) ≤ δ := by
    have : δ * (1 - ρ) ≤ δ * 1 := mul_le_mul_of_nonneg_left (by linarith) hδ
    simpa using this
  have hneg : -δ ≤ -(δ * (1 - ρ)) := by linarith
  exact (exp_le_exp).2 hneg

/-! ## Sandwich always brackets the independent reference -/

theorem sandwich_brackets_independent {δ ρ : ℝ}
    (hδ : 0 ≤ δ) (hρ₀ : 0 ≤ ρ) :
    conservativeSurvival δ ρ ≤ exp (-δ) ∧ exp (-δ) ≤ optimisticSurvival δ ρ :=
  ⟨conservative_le_independent hδ hρ₀, independent_le_optimistic hδ hρ₀⟩

theorem weak_dependence_sandwich_unpack {P δ ρ : ℝ}
    (h : WeakDependenceSandwich P δ ρ) :
    conservativeSurvival δ ρ ≤ P ∧ P ≤ optimisticSurvival δ ρ :=
  ⟨h.lower, h.upper⟩

theorem sandwich_contains_independent_point {P δ : ℝ}
    (h : WeakDependenceSandwich P δ 0) :
    P = exp (-δ) :=
  (weakDependenceSandwich_rho_zero_iff_eq.mp h)

/-! ## Factorization (algebraic robustness) -/

theorem conservativeSurvival_mul_exp {δ ρ : ℝ} :
    conservativeSurvival δ ρ = exp (-δ) * exp (-(δ * ρ)) := by
  unfold conservativeSurvival
  have h : -(δ * (1 + ρ)) = -δ + -(δ * ρ) := by ring
  rw [h, exp_add]

theorem optimisticSurvival_mul_exp {δ ρ : ℝ} :
    optimisticSurvival δ ρ = exp (-δ) * exp (δ * ρ) := by
  unfold optimisticSurvival
  have h : -(δ * (1 - ρ)) = -δ + δ * ρ := by ring
  rw [h, exp_add]

/-! ## Positivity -/

theorem conservativeSurvival_pos (δ ρ : ℝ) : 0 < conservativeSurvival δ ρ :=
  exp_pos _

theorem optimisticSurvival_pos (δ ρ : ℝ) : 0 < optimisticSurvival δ ρ :=
  exp_pos _

end

end Survival.WeakDependence
