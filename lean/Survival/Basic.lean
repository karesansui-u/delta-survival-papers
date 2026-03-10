/-
Survival Model - Basic Definitions
存続モデルの基本定義

Core equation: S = N_eff * exp(-delta) * (mu/mu_c)
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic

namespace Survival

/-! ## Core Definitions -/

/-- Survival potential S = E * N * Y (simplified form) -/
def SurvivalPotential (E N Y : ℝ) : ℝ := E * N * Y

/-- Hazard rate (collapse probability per unit time) -/
noncomputable def HazardRate (h_min h0 k δ N_eff : ℝ) : ℝ :=
  h_min + h0 * Real.exp (-k * δ * N_eff)

/-- Abstract dependency δ ∈ [0, 1] -/
structure AbstractDependency where
  δ : ℝ
  h_nonneg : 0 ≤ δ
  h_le_one : δ ≤ 1

/-- Effective dispersion N_eff = N × I (number × independence) -/
structure EffectiveDispersion where
  N_eff : ℝ
  h_pos : 0 < N_eff

/-- Margin (slack) μ -/
structure Margin where
  μ : ℝ
  μ_c : ℝ  -- critical margin

/-! ## Core Theorems -/

/-- Theorem 1: S > 0 iff all factors are positive -/
theorem survival_iff_all_positive (E N Y : ℝ) (hE : 0 ≤ E) (hN : 0 ≤ N) (hY : 0 ≤ Y) :
    SurvivalPotential E N Y > 0 ↔ E > 0 ∧ N > 0 ∧ Y > 0 := by
  constructor
  · intro h
    unfold SurvivalPotential at h
    constructor
    · by_contra hE0
      push_neg at hE0
      have : E = 0 := le_antisymm hE0 hE
      simp [this] at h
    constructor
    · by_contra hN0
      push_neg at hN0
      have : N = 0 := le_antisymm hN0 hN
      simp [this] at h
    · by_contra hY0
      push_neg at hY0
      have : Y = 0 := le_antisymm hY0 hY
      simp [this] at h
  · intro ⟨hE', hN', hY'⟩
    unfold SurvivalPotential
    exact mul_pos (mul_pos hE' hN') hY'

/-- Theorem 2: Any factor = 0 implies collapse (S = 0) -/
theorem collapse_if_any_zero (E N Y : ℝ) :
    E = 0 ∨ N = 0 ∨ Y = 0 → SurvivalPotential E N Y = 0 := by
  intro h
  rcases h with hE | hN | hY
  · simp [SurvivalPotential, hE]
  · simp [SurvivalPotential, hN]
  · simp [SurvivalPotential, hY]

/-- Theorem 3: Hazard rate is always ≥ h_min -/
theorem hazard_rate_geq_h_min (h_min h0 k δ N_eff : ℝ) (hh0 : 0 ≤ h0) :
    h_min ≤ HazardRate h_min h0 k δ N_eff := by
  unfold HazardRate
  have h_exp_nonneg : 0 ≤ Real.exp (-k * δ * N_eff) := Real.exp_nonneg _
  linarith [mul_nonneg hh0 h_exp_nonneg]

/-- Theorem 4: Hazard rate decreases as δ * N_eff increases (when k > 0) -/
theorem hazard_rate_decreasing (h_min h0 k : ℝ) (hk : 0 < k) (hh0 : 0 < h0) :
    ∀ x y : ℝ, x < y → HazardRate h_min h0 k 1 y < HazardRate h_min h0 k 1 x := by
  intro x y hxy
  unfold HazardRate
  simp only [mul_one]
  have h1 : -k * y < -k * x := by nlinarith
  have h2 : Real.exp (-k * y) < Real.exp (-k * x) := Real.exp_strictMono h1
  have h3 : h0 * Real.exp (-k * y) < h0 * Real.exp (-k * x) := by
    exact mul_lt_mul_of_pos_left h2 hh0
  linarith

end Survival
