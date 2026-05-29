/-
Survival Factors - Formalization
存続因子の形式化

Core equation: S = N_eff × e^{-δ} × (μ/μ_c)

Three factors (3因子):
- Entropy (E) = N_eff : effective options
- Negentropy (N) = e^{-δ} : structural integrity (exponential penalty)
- MarginRatio (Y) = μ/μ_c : margin ratio

Derived quantity:
- SurvivalPotential (S) = E × N × Y
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.Basic

namespace Survival.Penalty

/-! ## Three Factors (3因子) -/

/-- Entropy factor E = N_eff (有効選択肢数)
    エントロピー因子：有効分散度
-/
noncomputable def Entropy (N_eff : ℝ) : ℝ := N_eff

/-- Negentropy factor N = e^{-δ} (構造的健全性)
    ネゲントロピー因子：累積情報損失の指数ペナルティ
-/
noncomputable def Negentropy (δ : ℝ) : ℝ := Real.exp (-δ)

/-- MarginRatio factor Y = μ/μ_c (マージン比)
    マージン比因子
-/
noncomputable def MarginRatio (μ μ_c : ℝ) : ℝ := μ / μ_c

/-! ## Complete Survival Equation (完全な存続方程式) -/

/-- Full survival potential: S = N_eff × e^{-δ} × (μ/μ_c)
    完全な存続方程式
-/
noncomputable def FullSurvival (N_eff δ μ μ_c : ℝ) : ℝ :=
  Entropy N_eff * Negentropy δ * MarginRatio μ μ_c

/-- Alternative form: S = E × N × Y
    代替形式：3因子の積
-/
theorem full_survival_as_product (N_eff δ μ μ_c : ℝ) :
    FullSurvival N_eff δ μ μ_c =
    Entropy N_eff * Negentropy δ * MarginRatio μ μ_c := rfl

/-! ## Factor Properties (因子の性質) -/

/-- Entropy is positive when N_eff > 0
    N_eff > 0 のとき E > 0
-/
theorem entropy_pos (N_eff : ℝ) (hN : N_eff > 0) :
    Entropy N_eff > 0 := hN

/-- Negentropy is always positive (e^x > 0)
    ネゲントロピーは常に正
-/
theorem negentropy_pos (δ : ℝ) :
    Negentropy δ > 0 := Real.exp_pos _

/-- Negentropy ≤ 1 when δ ≥ 0
    δ ≥ 0 のとき N ≤ 1
-/
theorem negentropy_le_one (δ : ℝ) (hδ : δ ≥ 0) :
    Negentropy δ ≤ 1 := by
  unfold Negentropy
  have h : -δ ≤ 0 := by linarith
  have h1 : Real.exp (-δ) ≤ Real.exp 0 := Real.exp_le_exp_of_le h
  simp only [Real.exp_zero] at h1
  exact h1

/-- Negentropy = 1 when δ = 0 (no information loss)
    δ = 0 のとき N = 1（情報損失なし）
-/
theorem negentropy_at_zero :
    Negentropy 0 = 1 := by
  unfold Negentropy
  simp

/-- MarginRatio is positive when μ > 0 and μ_c > 0
    μ > 0, μ_c > 0 のとき Y > 0
-/
theorem margin_ratio_pos (μ μ_c : ℝ) (hμ : μ > 0) (hμc : μ_c > 0) :
    MarginRatio μ μ_c > 0 := div_pos hμ hμc

/-! ## Survival Condition (存続条件) -/

/-- Full survival condition: S > 0 iff all factors positive
    完全な存続条件：S > 0 ⟺ すべての因子が正
-/
theorem full_survival_condition (N_eff δ μ μ_c : ℝ)
    (hN : N_eff > 0) (hμ : μ > 0) (hμc : μ_c > 0) :
    FullSurvival N_eff δ μ μ_c > 0 := by
  unfold FullSurvival
  apply mul_pos
  apply mul_pos
  · exact entropy_pos N_eff hN
  · exact negentropy_pos δ
  · exact margin_ratio_pos μ μ_c hμ hμc

/-! ## Death Conditions (崩壊条件) -/

/-- Death by homogenization: E → 0
    同質化による崩壊：E = 0
-/
theorem death_by_homogenization (δ μ μ_c : ℝ) :
    FullSurvival 0 δ μ μ_c = 0 := by
  unfold FullSurvival Entropy
  ring

/-- Death by fragmentation: N → 0 as δ → ∞
    分裂による崩壊：δ → ∞ のとき N → 0
-/
theorem negentropy_tends_to_zero :
    ∀ ε > 0, ∃ δ₀ : ℝ, ∀ δ > δ₀, Negentropy δ < ε := by
  intro ε hε
  use -Real.log ε
  intro δ hδ
  unfold Negentropy
  have h1 : -δ < Real.log ε := by linarith
  calc Real.exp (-δ) < Real.exp (Real.log ε) := Real.exp_strictMono h1
    _ = ε := Real.exp_log hε

/-- Death by exhaustion: Y → 0 when μ → 0
    枯渇による崩壊：μ = 0 のとき Y = 0
-/
theorem death_by_exhaustion (N_eff δ μ_c : ℝ) (hμc : μ_c ≠ 0) :
    FullSurvival N_eff δ 0 μ_c = 0 := by
  unfold FullSurvival MarginRatio
  simp

/-! ## Monotonicity (単調性) -/

/-- Higher N_eff → higher S (dispersion helps survival)
    N_eff が高いほど S が高い
-/
theorem survival_increasing_in_neff (N₁ N₂ δ μ μ_c : ℝ)
    (hN : N₁ < N₂) (hμ : μ > 0) (hμc : μ_c > 0) :
    FullSurvival N₁ δ μ μ_c < FullSurvival N₂ δ μ μ_c := by
  unfold FullSurvival Entropy
  have h1 : Negentropy δ > 0 := negentropy_pos δ
  have h2 : MarginRatio μ μ_c > 0 := margin_ratio_pos μ μ_c hμ hμc
  have h3 : Negentropy δ * MarginRatio μ μ_c > 0 := mul_pos h1 h2
  calc N₁ * Negentropy δ * MarginRatio μ μ_c
      = N₁ * (Negentropy δ * MarginRatio μ μ_c) := by ring
    _ < N₂ * (Negentropy δ * MarginRatio μ μ_c) := mul_lt_mul_of_pos_right hN h3
    _ = N₂ * Negentropy δ * MarginRatio μ μ_c := by ring

/-- Lower δ → higher S (less information loss helps survival)
    δ が低いほど S が高い
-/
theorem survival_decreasing_in_delta (N_eff δ₁ δ₂ μ μ_c : ℝ)
    (hN : N_eff > 0) (hδ : δ₁ < δ₂) (hμ : μ > 0) (hμc : μ_c > 0) :
    FullSurvival N_eff δ₂ μ μ_c < FullSurvival N_eff δ₁ μ μ_c := by
  unfold FullSurvival Negentropy
  have h1 : Real.exp (-δ₂) < Real.exp (-δ₁) := by
    apply Real.exp_strictMono
    linarith
  have h2 : Entropy N_eff > 0 := entropy_pos N_eff hN
  have h3 : MarginRatio μ μ_c > 0 := margin_ratio_pos μ μ_c hμ hμc
  have h4 : Entropy N_eff * Real.exp (-δ₂) < Entropy N_eff * Real.exp (-δ₁) :=
    mul_lt_mul_of_pos_left h1 h2
  calc Entropy N_eff * Real.exp (-δ₂) * MarginRatio μ μ_c
      < Entropy N_eff * Real.exp (-δ₁) * MarginRatio μ μ_c :=
        mul_lt_mul_of_pos_right h4 h3

/-- Higher μ → higher S (more margin helps survival)
    μ が高いほど S が高い
-/
theorem survival_increasing_in_margin (N_eff δ μ₁ μ₂ μ_c : ℝ)
    (hN : N_eff > 0) (hμ : μ₁ < μ₂) (hμc : μ_c > 0) :
    FullSurvival N_eff δ μ₁ μ_c < FullSurvival N_eff δ μ₂ μ_c := by
  unfold FullSurvival MarginRatio
  have h1 : Entropy N_eff > 0 := entropy_pos N_eff hN
  have h2 : Negentropy δ > 0 := negentropy_pos δ
  have h3 : Entropy N_eff * Negentropy δ > 0 := mul_pos h1 h2
  have h4 : μ₁ / μ_c < μ₂ / μ_c := div_lt_div_of_pos_right hμ hμc
  calc Entropy N_eff * Negentropy δ * (μ₁ / μ_c)
      < Entropy N_eff * Negentropy δ * (μ₂ / μ_c) :=
        mul_lt_mul_of_pos_left h4 h3

/-! ## Critical Boundary (臨界境界) -/

/-- At critical margin (μ = μ_c), Y = 1
    臨界マージンでは Y = 1
-/
theorem margin_ratio_at_critical (μ_c : ℝ) (hμc : μ_c ≠ 0) :
    MarginRatio μ_c μ_c = 1 := div_self hμc

/-- Subcritical margin (μ < μ_c) means Y < 1
    亜臨界マージンでは Y < 1
-/
theorem subcritical_margin_ratio (μ μ_c : ℝ) (hμ : 0 < μ) (hμc : 0 < μ_c) (h : μ < μ_c) :
    MarginRatio μ μ_c < 1 := by
  unfold MarginRatio
  rw [div_lt_one hμc]
  exact h

/-- Supercritical margin (μ > μ_c) means Y > 1
    超臨界マージンでは Y > 1
-/
theorem supercritical_margin_ratio (μ μ_c : ℝ) (hμc : 0 < μ_c) (h : μ > μ_c) :
    MarginRatio μ μ_c > 1 := by
  unfold MarginRatio
  have h1 : 1 < μ / μ_c := by
    rw [one_lt_div hμc]
    exact h
  exact h1

end Survival.Penalty
