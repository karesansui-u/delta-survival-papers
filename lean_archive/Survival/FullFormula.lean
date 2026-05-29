/-
Full Survival Formula with μ_c Penalty Term
完全な存続式（μ_cペナルティ項付き）

Complete hazard rate: h = h_min + h₀ × exp(-k × δ × N_eff) × g(μ/μ_c)
where g is a penalty function that increases when μ < μ_c
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.Basic
import Survival.Penalty

namespace Survival.FullFormula

/-! ## Penalty Function g(μ/μ_c) -/

/-- Penalty function: g(y) = 1/y for y > 0
    When μ < μ_c: y < 1 → g(y) > 1 (penalty)
    When μ = μ_c: y = 1 → g(y) = 1 (neutral)
    When μ > μ_c: y > 1 → g(y) < 1 (bonus)
-/
noncomputable def PenaltyFunction (y : ℝ) : ℝ := 1 / y

/-- Alternative: exponential penalty g(y) = exp(1 - y)
    Smoother behavior near y = 0
-/
noncomputable def ExpPenaltyFunction (y : ℝ) : ℝ := Real.exp (1 - y)

/-! ## Complete Hazard Rate Formula -/

/-- Full hazard rate with penalty term
    h = h_min + h₀ × exp(-k × δ × N_eff) × g(μ/μ_c)
-/
noncomputable def FullHazardRate (h_min h₀ k δ N_eff μ μ_c : ℝ) : ℝ :=
  h_min + h₀ * Real.exp (-k * δ * N_eff) * PenaltyFunction (μ / μ_c)

/-- Full hazard rate with exponential penalty
    h = h_min + h₀ × exp(-k × δ × N_eff) × exp(1 - μ/μ_c)
-/
noncomputable def FullHazardRateExp (h_min h₀ k δ N_eff μ μ_c : ℝ) : ℝ :=
  h_min + h₀ * Real.exp (-k * δ * N_eff) * ExpPenaltyFunction (μ / μ_c)

/-! ## Penalty Function Properties -/

/-- Penalty at critical margin is 1
    μ = μ_c のとき g = 1
-/
theorem penalty_at_critical (μ_c : ℝ) (hμc : μ_c ≠ 0) :
    PenaltyFunction (μ_c / μ_c) = 1 := by
  unfold PenaltyFunction
  rw [div_self hμc]
  simp

/-- Subcritical penalty > 1 (penalty active)
    μ < μ_c のとき g > 1
-/
theorem subcritical_penalty (μ μ_c : ℝ) (hμ : 0 < μ) (hμc : 0 < μ_c) (h : μ < μ_c) :
    PenaltyFunction (μ / μ_c) > 1 := by
  unfold PenaltyFunction
  have hy : 0 < μ / μ_c := div_pos hμ hμc
  have hy1 : μ / μ_c < 1 := by
    rw [div_lt_one hμc]
    exact h
  have h1 : 1 < 1 / (μ / μ_c) := by
    rw [one_lt_div hy]
    exact hy1
  exact h1

/-- Supercritical penalty < 1 (bonus)
    μ > μ_c のとき g < 1
-/
theorem supercritical_penalty (μ μ_c : ℝ) (hμc : 0 < μ_c) (h : μ > μ_c) :
    PenaltyFunction (μ / μ_c) < 1 := by
  unfold PenaltyFunction
  have hy : μ / μ_c > 1 := by
    have h1 : 1 < μ / μ_c := by
      rw [one_lt_div hμc]
      exact h
    exact h1
  have hy0 : 0 < μ / μ_c := by linarith
  rw [div_lt_one hy0]
  exact hy

/-- Exponential penalty at critical is 1
    exp(1 - 1) = exp(0) = 1
-/
theorem exp_penalty_at_critical (μ_c : ℝ) (hμc : μ_c ≠ 0) :
    ExpPenaltyFunction (μ_c / μ_c) = 1 := by
  unfold ExpPenaltyFunction
  rw [div_self hμc]
  simp

/-! ## Full Formula Properties -/

/-- Full hazard rate is well-defined when μ > 0 and μ_c > 0
    完全式は μ > 0, μ_c > 0 で well-defined
-/
theorem full_hazard_rate_pos (h_min h₀ k δ N_eff μ μ_c : ℝ)
    (hh₀ : h₀ > 0) (hμ : μ > 0) (hμc : μ_c > 0) :
    FullHazardRate h_min h₀ k δ N_eff μ μ_c > h_min := by
  unfold FullHazardRate PenaltyFunction
  have h1 : Real.exp (-k * δ * N_eff) > 0 := Real.exp_pos _
  have h2 : μ / μ_c > 0 := div_pos hμ hμc
  have h3 : 1 / (μ / μ_c) > 0 := one_div_pos.mpr h2
  have h4 : h₀ * Real.exp (-k * δ * N_eff) > 0 := mul_pos hh₀ h1
  have h5 : h₀ * Real.exp (-k * δ * N_eff) * (1 / (μ / μ_c)) > 0 := mul_pos h4 h3
  linarith

/-! ## Connection to Survival Potential -/

/-- Full survival potential with penalty: S = E × N × Y × (1/penalty)
    When penalty is high (low margin), S is low
-/
noncomputable def FullSurvivalWithPenalty (N_eff δ μ μ_c : ℝ) : ℝ :=
  Penalty.FullSurvival N_eff δ μ μ_c * (μ / μ_c)

/-- Higher margin → higher survival potential -/
theorem margin_increases_survival (N_eff δ μ₁ μ₂ μ_c : ℝ)
    (hN : N_eff > 0) (hμ1 : μ₁ > 0) (hμ2 : μ₂ > 0) (hμc : μ_c > 0)
    (hμ : μ₁ < μ₂) :
    FullSurvivalWithPenalty N_eff δ μ₁ μ_c < FullSurvivalWithPenalty N_eff δ μ₂ μ_c := by
  unfold FullSurvivalWithPenalty
  have h1 : Penalty.FullSurvival N_eff δ μ₁ μ_c < Penalty.FullSurvival N_eff δ μ₂ μ_c :=
    Penalty.survival_increasing_in_margin N_eff δ μ₁ μ₂ μ_c hN hμ hμc
  have h2 : μ₁ / μ_c < μ₂ / μ_c := div_lt_div_of_pos_right hμ hμc
  have hU1_pos : Penalty.FullSurvival N_eff δ μ₁ μ_c > 0 :=
    Penalty.full_survival_condition N_eff δ μ₁ μ_c hN hμ1 hμc
  have hU2_pos : Penalty.FullSurvival N_eff δ μ₂ μ_c > 0 :=
    Penalty.full_survival_condition N_eff δ μ₂ μ_c hN hμ2 hμc
  have hy1_pos : μ₁ / μ_c > 0 := div_pos hμ1 hμc
  calc Penalty.FullSurvival N_eff δ μ₁ μ_c * (μ₁ / μ_c)
      < Penalty.FullSurvival N_eff δ μ₂ μ_c * (μ₁ / μ_c) :=
        mul_lt_mul_of_pos_right h1 hy1_pos
    _ < Penalty.FullSurvival N_eff δ μ₂ μ_c * (μ₂ / μ_c) :=
        mul_lt_mul_of_pos_left h2 hU2_pos

end Survival.FullFormula
