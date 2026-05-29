/-
Robust Survival — Conservative Bounds Under Weak Dependence
ロバスト存続 — 弱依存下の保守的境界

Connects:
- `WeakDependence`: ρ-parameterized exponential bracket around joint survival
- `AxiomsToExp`: independent reference `jointSurvival = exp(-δ)`
- `Basic`: positivity of `SurvivalPotential`

The conservative factor `conservativeSurvival δ ρ = exp(-δ·(1+ρ))` is a *pessimistic*
surrogate when dependence widens uncertainty; multiplying by `μ` gives a robust
survival potential that is never optimistic versus the independent case (for ρ ≥ 0).

References:
- Paper 1: empirical relaxation of axiom A3 (independence)
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Survival.Basic
import Survival.WeakDependence
import Survival.AxiomsToExp

open Real

namespace Survival.RobustSurvival

open WeakDependence

noncomputable section

variable {ι : Type*}

/-! ## Robust survival potential -/

/-- Conservative survival potential: `μ · exp(-δ·(1+ρ))`. -/
def robustPotential (μ δ ρ : ℝ) : ℝ :=
  μ * WeakDependence.conservativeSurvival δ ρ

/-! ## Positivity and monotonicity -/

theorem robustPotential_pos {μ δ ρ : ℝ} (hμ : 0 < μ) :
    0 < robustPotential μ δ ρ := by
  unfold robustPotential
  exact mul_pos hμ (WeakDependence.conservativeSurvival_pos δ ρ)

theorem robustPotential_le_independent {μ δ ρ : ℝ}
    (hμ : 0 ≤ μ) (hδ : 0 ≤ δ) (hρ : 0 ≤ ρ) :
    robustPotential μ δ ρ ≤ μ * exp (-δ) := by
  unfold robustPotential WeakDependence.conservativeSurvival
  exact mul_le_mul_of_nonneg_left (WeakDependence.conservative_le_independent hδ hρ) hμ

/-- **ρ → 0** recovers the independent exponential factor. -/
theorem robustPotential_rho_zero (μ δ : ℝ) :
    robustPotential μ δ 0 = μ * exp (-δ) := by
  simp [robustPotential, WeakDependence.conservativeSurvival_rho_zero]

/-- Dependence budget `ρ = 0` recovers the independent-factor potential (plan: `error_vanishes`). -/
theorem error_vanishes_at_independent_limit (μ δ : ℝ) :
    robustPotential μ δ 0 = μ * exp (-δ) :=
  robustPotential_rho_zero μ δ

/-- Plan-facing name: conservative robust factor never overestimates independence. -/
theorem survival_robust_vs_independent {μ δ ρ : ℝ}
    (hμ : 0 ≤ μ) (hδ : 0 ≤ δ) (hρ : 0 ≤ ρ) :
    robustPotential μ δ ρ ≤ μ * exp (-δ) :=
  robustPotential_le_independent hμ hδ hρ

/-! ## From a weak-dependence sandwich -/

theorem robust_potential_le_actual {μ δ ρ P : ℝ}
    (hμ : 0 ≤ μ) (h : WeakDependenceSandwich P δ ρ) :
    robustPotential μ δ ρ ≤ μ * P :=
  mul_le_mul_of_nonneg_left h.lower hμ

theorem actual_le_optimistic_potential {μ δ ρ P : ℝ}
    (hμ : 0 ≤ μ) (h : WeakDependenceSandwich P δ ρ) :
    μ * P ≤ μ * WeakDependence.optimisticSurvival δ ρ :=
  mul_le_mul_of_nonneg_left h.upper hμ

/-! ## Link to `SurvivalPotential` (paper-style product) -/

theorem survivalPotential_robust_lower {E N Y δ ρ : ℝ}
    (hE : 0 ≤ E) (hN : 0 ≤ N) (hY : 0 ≤ Y)
    (hδ : 0 ≤ δ) (hρ : 0 ≤ ρ) :
    E * N * Y * WeakDependence.conservativeSurvival δ ρ
      ≤ E * N * Y * exp (-δ) := by
  have hc := WeakDependence.conservative_le_independent hδ hρ
  have hprod : 0 ≤ E * N * Y := by
    exact mul_nonneg (mul_nonneg hE hN) hY
  exact mul_le_mul_of_nonneg_left hc hprod

theorem survivalPotential_pos_of_robust {E N Y δ ρ : ℝ}
    (hE : 0 < E) (hN : 0 < N) (hY : 0 < Y) :
    0 < E * N * Y * WeakDependence.conservativeSurvival δ ρ := by
  have h := WeakDependence.conservativeSurvival_pos δ ρ
  exact mul_pos (mul_pos (mul_pos hE hN) hY) h

/-! ## δ interval from bounded pass-through rates (“LLM bridge”) -/

theorem selfInfo_antitone {p q : ℝ} (hp : 0 < p) (hpq : p ≤ q) :
    AxiomsToExp.selfInfo q ≤ AxiomsToExp.selfInfo p := by
  unfold AxiomsToExp.selfInfo
  have hlog : Real.log p ≤ Real.log q := Real.log_le_log hp hpq
  linarith

/-- If each pass-through rate lies in `[p_lo, p_hi]`, then `δ` lies in a corresponding interval
    (plan: LLM / empirical bridge from bounded removal rates). -/
theorem delta_uniform_bounds (s : Finset ι) (p : ι → ℝ) (p_lo p_hi : ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i)
    (_hp_hi_le_one : ∀ i ∈ s, p i ≤ 1)
    (h_lo : ∀ i ∈ s, p_lo ≤ p i)
    (h_hi : ∀ i ∈ s, p i ≤ p_hi)
    (hp_lo_pos : 0 < p_lo) (_hp_hi_pos : 0 < p_hi) :
    (↑s.card : ℝ) * AxiomsToExp.selfInfo p_hi ≤ AxiomsToExp.delta s p
    ∧ AxiomsToExp.delta s p ≤ (↑s.card : ℝ) * AxiomsToExp.selfInfo p_lo := by
  classical
  unfold AxiomsToExp.delta
  constructor
  · have h_each :
        ∀ i ∈ s, AxiomsToExp.selfInfo p_hi ≤ AxiomsToExp.selfInfo (p i) := by
      intro i hi
      exact selfInfo_antitone (hp_pos i hi) (h_hi i hi)
    have hsum := Finset.sum_le_sum (fun i hi => h_each i hi)
    have hLHS :
        ∑ i ∈ s, AxiomsToExp.selfInfo p_hi = (↑s.card : ℝ) * AxiomsToExp.selfInfo p_hi := by
      rw [Finset.sum_eq_card_nsmul (fun _ _ => rfl)]
      simp [nsmul_eq_mul]
    rw [hLHS] at hsum
    exact hsum
  · have h_each :
        ∀ i ∈ s, AxiomsToExp.selfInfo (p i) ≤ AxiomsToExp.selfInfo p_lo := by
      intro i hi
      exact selfInfo_antitone hp_lo_pos (h_lo i hi)
    have hsum := Finset.sum_le_sum (fun i hi => h_each i hi)
    have hRHS :
        ∑ i ∈ s, AxiomsToExp.selfInfo p_lo = (↑s.card : ℝ) * AxiomsToExp.selfInfo p_lo := by
      rw [Finset.sum_eq_card_nsmul (fun _ _ => rfl)]
      simp [nsmul_eq_mul]
    rw [hRHS] at hsum
    exact hsum

/-! ## Independent reference matches sandwich at ρ = 0 -/

theorem jointSurvival_eq_robust_reference (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    AxiomsToExp.jointSurvival s p = exp (-AxiomsToExp.delta s p) := by
  classical
  exact AxiomsToExp.joint_survival_eq_exp_neg_delta s p hp_pos

end

end Survival.RobustSurvival
