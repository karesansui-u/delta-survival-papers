/-
Free Energy Correspondence — Landau Theory Connection
自由エネルギー対応 — ランダウ理論との類似構造

Defines F_j(δ) = -ln(S_j(δ)) = -ln(C_j) + δ as the "free energy" analogue
for each attractor basin.

Key result: F is LINEAR in δ. This proves that all transitions in this
framework are first-order (discontinuous jump in basin identity).

Note: This is a structural analogy with Landau theory, not an isomorphism.
Differences from full Landau theory:
  - Order parameter Φ (basin identity) is discrete, not continuous
  - No Φ^n polynomial expansion
  - No Ginzburg criterion

References:
  - Landau, L.D. (1937). On the theory of phase transitions.
  - MultiAttractor.lean: Basin definitions
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Survival.MultiAttractor

open Real

namespace Survival.FreeEnergy

noncomputable section

open Survival.MultiAttractor

/-! ## Free Energy Definition -/

/-- Free energy (negative log-survival) for a basin at information loss δ.
    F(δ) = -ln(C) + δ
    Analogous to Landau free energy; S-maximization ⟺ F-minimization. -/
def freeEnergy (b : Basin) (δ : ℝ) : ℝ :=
  -log b.C + δ

/-- Free energy equals negative log of survival potential. -/
theorem freeEnergy_eq_neg_log (b : Basin) (δ : ℝ) :
    freeEnergy b δ = -log (basinSurvival b δ) := by
  unfold freeEnergy basinSurvival
  rw [log_mul (ne_of_gt b.C_pos) (ne_of_gt (exp_pos _)), log_exp]
  ring

/-- Free energy at zero information loss. -/
theorem freeEnergy_zero (b : Basin) :
    freeEnergy b 0 = -log b.C := by
  unfold freeEnergy; ring

/-! ## Linearity of Free Energy -/

/-- **Free energy is LINEAR in δ** (first-order transition structure).
    F(δ) = F(0) + δ. -/
theorem freeEnergy_linear (b : Basin) (δ : ℝ) :
    freeEnergy b δ = freeEnergy b 0 + δ := by
  unfold freeEnergy; ring

/-- Free energy difference between two information losses. -/
theorem freeEnergy_diff (b : Basin) (δ₁ δ₂ : ℝ) :
    freeEnergy b δ₂ - freeEnergy b δ₁ = δ₂ - δ₁ := by
  unfold freeEnergy; ring

/-- Free energy is strictly increasing in δ. -/
theorem freeEnergy_strictMono (b : Basin) :
    StrictMono (freeEnergy b) := by
  intro δ₁ δ₂ hδ
  unfold freeEnergy; linarith

/-! ## S-Maximization ⟺ F-Minimization -/

/-- **Core equivalence**: Basin A has higher survival than B
    if and only if A has lower free energy than B. -/
theorem max_survival_iff_min_freeEnergy (A B : Basin) (δ_A δ_B : ℝ) :
    basinSurvival B δ_B < basinSurvival A δ_A ↔
    freeEnergy A δ_A < freeEnergy B δ_B := by
  rw [freeEnergy_eq_neg_log, freeEnergy_eq_neg_log]
  have hSA := basinSurvival_pos A δ_A
  have hSB := basinSurvival_pos B δ_B
  constructor
  · intro h
    have := log_lt_log hSB h
    linarith
  · intro h
    have hlog : log (basinSurvival A δ_A) > log (basinSurvival B δ_B) := by
      linarith
    exact exp_log hSB ▸ exp_log hSA ▸ exp_lt_exp_of_lt hlog

/-- Equal survival corresponds to equal free energy. -/
theorem equal_survival_iff_equal_freeEnergy (A B : Basin) (δ_A δ_B : ℝ) :
    basinSurvival A δ_A = basinSurvival B δ_B ↔
    freeEnergy A δ_A = freeEnergy B δ_B := by
  rw [freeEnergy_eq_neg_log, freeEnergy_eq_neg_log]
  have hSA := basinSurvival_pos A δ_A
  have hSB := basinSurvival_pos B δ_B
  constructor
  · intro h; rw [h]
  · intro h
    -- -log(S_A) = -log(S_B) → log(S_A) = log(S_B)
    have hlog : log (basinSurvival A δ_A) = log (basinSurvival B δ_B) := by
      linarith
    -- log injective on positives
    calc basinSurvival A δ_A
        = exp (log (basinSurvival A δ_A)) := (exp_log hSA).symm
      _ = exp (log (basinSurvival B δ_B)) := by rw [hlog]
      _ = basinSurvival B δ_B := exp_log hSB

/-! ## Uniform Constraints: Linear F(m) -/

/-- Free energy under uniform constraints: F(m) = -ln(C) + m × I. -/
def uniformFreeEnergy (b : Basin) (I m : ℝ) : ℝ :=
  -log b.C + m * I

/-- Uniform free energy equals general free energy at δ = m × I. -/
theorem uniformFreeEnergy_eq (b : Basin) (I m : ℝ) :
    uniformFreeEnergy b I m = freeEnergy b (m * I) := by
  unfold uniformFreeEnergy freeEnergy; ring

/-- **Slope of uniform free energy is I** (per-constraint information loss).
    Different basins have different slopes → lines cross → first-order transition. -/
theorem uniformFreeEnergy_slope (b : Basin) (I m₁ m₂ : ℝ) (hm : m₁ ≠ m₂) :
    (uniformFreeEnergy b I m₂ - uniformFreeEnergy b I m₁) / (m₂ - m₁) = I := by
  unfold uniformFreeEnergy
  have hne : m₂ - m₁ ≠ 0 := sub_ne_zero.mpr hm.symm
  field_simp
  ring

end

end Survival.FreeEnergy
