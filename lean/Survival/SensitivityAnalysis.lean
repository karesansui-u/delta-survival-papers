/-
Sensitivity Analysis - Formalization
感度分析の形式化

Core claim: The multiplicative and additive models differ qualitatively
(zero-collapse property) but their quantitative difference is bounded.

This bridges the mathematical structure to the unresolved empirical question
of whether multiplicative aggregation outperforms additive aggregation.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.Basic
import Survival.Penalty

namespace Survival.SensitivityAnalysis

/-! ## Part 1: Model Definitions -/

/-- Multiplicative survival model (the survival equation).
    乗法的存続モデル（存続方程式）。 -/
noncomputable def S_mult (N δ μ μ_c : ℝ) : ℝ :=
  N * Real.exp (-δ) * (μ / μ_c)

/-- Additive survival model (linear combination).
    加法的存続モデル（線形結合）。 -/
noncomputable def S_add (N δ μ μ_c : ℝ) : ℝ :=
  N + Real.exp (-δ) + μ / μ_c

/-- S_mult equals FullSurvival from Penalty. -/
theorem S_mult_eq_full_survival (N δ μ μ_c : ℝ) :
    S_mult N δ μ μ_c =
    Penalty.FullSurvival N δ μ μ_c := by
  unfold S_mult Penalty.FullSurvival
    Penalty.Entropy Penalty.Negentropy Penalty.MarginRatio
  ring

/-! ## Part 2: Zero-Collapse Property (Qualitative Difference) -/

/-- **Multiplicative Zero-Collapse**: N = 0 → S_mult = 0. -/
theorem mult_zero_collapse_N (δ μ μ_c : ℝ) :
    S_mult 0 δ μ μ_c = 0 := by
  unfold S_mult; ring

/-- **Multiplicative Zero-Collapse**: μ = 0 → S_mult = 0. -/
theorem mult_zero_collapse_mu (N δ μ_c : ℝ) :
    S_mult N δ 0 μ_c = 0 := by
  unfold S_mult; simp [zero_div]

/-- **Additive model lacks zero-collapse for N = 0**. -/
theorem additive_lacks_zero_collapse_N :
    ∃ δ μ μ_c : ℝ, μ_c > 0 ∧ S_add 0 δ μ μ_c > 0 := by
  use 0, 1, 1
  refine ⟨by norm_num, ?_⟩
  unfold S_add
  simp only [Real.exp_zero, neg_zero]
  norm_num

/-- **Additive model lacks zero-collapse for μ = 0**. -/
theorem additive_lacks_zero_collapse_mu :
    ∃ N δ μ_c : ℝ, μ_c > 0 ∧ S_add N δ 0 μ_c > 0 := by
  use 1, 0, 1
  refine ⟨by norm_num, ?_⟩
  unfold S_add
  simp only [Real.exp_zero, neg_zero]
  norm_num

/-- **General Zero-Collapse**: Any factor = 0 → S_mult = 0.
    This is the fundamental structural theorem that distinguishes
    multiplicative from additive aggregation. -/
theorem mult_general_zero_collapse (N δ μ μ_c : ℝ) :
    N = 0 ∨ μ = 0 →
    S_mult N δ μ μ_c = 0 := by
  intro h
  rcases h with hN | hμ
  · rw [hN]; unfold S_mult; ring
  · rw [hμ]; unfold S_mult; simp [zero_div]

/-! ## Part 3: Both Models Agree on Monotonicity -/

/-- Additive model is increasing in N. -/
theorem additive_increasing_in_N (N₁ N₂ δ μ μ_c : ℝ)
    (h : N₁ < N₂) :
    S_add N₁ δ μ μ_c < S_add N₂ δ μ μ_c := by
  unfold S_add
  linarith

/-- Additive model is decreasing in δ. -/
theorem additive_decreasing_in_delta (N δ₁ δ₂ μ μ_c : ℝ)
    (h : δ₁ < δ₂) :
    S_add N δ₂ μ μ_c < S_add N δ₁ μ μ_c := by
  unfold S_add
  have : Real.exp (-δ₂) < Real.exp (-δ₁) :=
    Real.exp_strictMono (by linarith)
  linarith

/-- Additive model is increasing in μ. -/
theorem additive_increasing_in_mu
    (N δ μ₁ μ₂ μ_c : ℝ) (hμc : μ_c > 0)
    (h : μ₁ < μ₂) :
    S_add N δ μ₁ μ_c < S_add N δ μ₂ μ_c := by
  unfold S_add
  have : μ₁ / μ_c < μ₂ / μ_c := div_lt_div_of_pos_right h hμc
  linarith

/-! ## Part 4: Quantitative Sensitivity Bound -/

/-- The multiplicative model is bounded above by the product of upper bounds. -/
theorem mult_upper_bound (N δ μ μ_c B_N B_Y : ℝ)
    (hN : 0 ≤ N) (hN_bound : N ≤ B_N)
    (hδ : 0 ≤ δ) (hμ : 0 < μ) (hμc : 0 < μ_c)
    (hY_bound : μ / μ_c ≤ B_Y) :
    S_mult N δ μ μ_c ≤ B_N * 1 * B_Y := by
  unfold S_mult
  have h_exp_le : Real.exp (-δ) ≤ 1 := by
    have h : -δ ≤ 0 := by linarith
    calc Real.exp (-δ)
        ≤ Real.exp 0 := Real.exp_le_exp_of_le h
      _ = 1 := Real.exp_zero
  have h_exp_nn : 0 ≤ Real.exp (-δ) :=
    le_of_lt (Real.exp_pos _)
  have hY_nn : 0 ≤ μ / μ_c := le_of_lt (div_pos hμ hμc)
  calc N * Real.exp (-δ) * (μ / μ_c)
      ≤ B_N * Real.exp (-δ) * (μ / μ_c) := by
        apply mul_le_mul_of_nonneg_right
        · exact mul_le_mul_of_nonneg_right hN_bound h_exp_nn
        · exact hY_nn
    _ ≤ B_N * 1 * (μ / μ_c) := by
        apply mul_le_mul_of_nonneg_right
        · exact mul_le_mul_of_nonneg_left h_exp_le
            (by linarith)
        · exact hY_nn
    _ ≤ B_N * 1 * B_Y := by
        apply mul_le_mul_of_nonneg_left hY_bound
        · exact mul_nonneg (by linarith) (by norm_num)

/-- The additive model is bounded above by the sum of upper bounds. -/
theorem additive_upper_bound (N δ μ μ_c B_N B_Y : ℝ)
    (hN_bound : N ≤ B_N) (hδ : 0 ≤ δ)
    (hY_bound : μ / μ_c ≤ B_Y) :
    S_add N δ μ μ_c ≤ B_N + 1 + B_Y := by
  unfold S_add
  have h_exp_le : Real.exp (-δ) ≤ 1 := by
    have h : -δ ≤ 0 := by linarith
    calc Real.exp (-δ)
        ≤ Real.exp 0 := Real.exp_le_exp_of_le h
      _ = 1 := Real.exp_zero
  linarith

/-! ## Part 5: Critical Region Identification -/

/-- At the critical boundary (one factor → 0), the additive model
    overestimates survival compared to the multiplicative model. -/
theorem additive_overestimates_at_boundary
    (δ μ μ_c : ℝ) (hδ : δ ≥ 0) (hμ : μ > 0) (hμc : μ_c > 0) :
    S_mult 0 δ μ μ_c < S_add 0 δ μ μ_c := by
  rw [mult_zero_collapse_N δ μ μ_c]
  unfold S_add
  have h1 : Real.exp (-δ) > 0 := Real.exp_pos _
  have h2 : μ / μ_c > 0 := div_pos hμ hμc
  linarith

/-- When all factors are equal to 1, the models give different values
    (S_mult = 1, S_add = 3). -/
theorem models_differ_at_unit :
    S_mult 1 0 1 1 = 1 ∧ S_add 1 0 1 1 = 3 := by
  constructor
  · unfold S_mult
    simp [Real.exp_zero]
  · unfold S_add
    simp [Real.exp_zero]
    norm_num

end Survival.SensitivityAnalysis
