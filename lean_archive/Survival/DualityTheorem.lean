import Survival.ErgodicRateBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Duality Theorem — min L ⟺ max S

This module proves that minimizing cumulative structural consumption L
and maximizing the structural persistence potential S = M exp(-L)
are **dual** problems: they have the same optimal solutions.

## The theorem

For fixed M > 0:
- S = M · exp(-L)
- exp is strictly decreasing in -L, so exp(-L) is strictly
  decreasing in L
- Therefore: argmin L = argmax S

This is a structural-persistence analogue of the duality between
minimizing energy and maximizing entropy in thermodynamics, or
between minimizing risk and maximizing expected utility.

## Significance

This establishes that "preventing structural collapse" (min L) and
"maximizing structural viability" (max S) are mathematically
equivalent — not just intuitively similar, but provably the same
optimization problem.

References:
  - Boyd, S. & Vandenberghe, L. (2004). "Convex Optimization."
  - ErgodicRateBridge.lean: ergodic trichotomy
-/

namespace Survival.DualityTheorem

open Real

noncomputable section

/-! ## Part 1: Monotonicity of the Persistence Map -/

/-- The persistence map L ↦ M · exp(-L) is strictly decreasing in L
    (for fixed M > 0). -/
theorem persistence_strictAnti (M : ℝ) (hM : 0 < M) :
    StrictAnti (fun L => M * exp (-L)) := by
  intro L₁ L₂ h
  exact mul_lt_mul_of_pos_left
    (exp_lt_exp.mpr (by linarith)) hM

/-- The persistence map is antitone (non-strictly decreasing). -/
theorem persistence_antitone (M : ℝ) (hM : 0 < M) :
    Antitone (fun L => M * exp (-L)) :=
  (persistence_strictAnti M hM).antitone

/-! ## Part 2: Duality Theorem -/

/-- **Duality Theorem (pointwise):**
    For fixed M > 0, L₁ < L₂ iff S(L₁) > S(L₂).
    Lower consumption ⟺ higher persistence. -/
theorem consumption_persistence_duality (M : ℝ) (hM : 0 < M)
    (L₁ L₂ : ℝ) :
    L₁ < L₂ ↔ M * exp (-L₂) < M * exp (-L₁) := by
  constructor
  · exact fun h => persistence_strictAnti M hM h
  · intro h
    by_contra hle
    push_neg at hle
    exact not_lt.mpr (persistence_antitone M hM hle) h

/-- **Duality Theorem (optimality):**
    An action that minimizes L over a set also maximizes S over
    the same set. -/
theorem min_consumption_eq_max_persistence (M : ℝ) (hM : 0 < M)
    (L_opt : ℝ) (S_set : Set ℝ)
    (hmin : ∀ L ∈ S_set, L_opt ≤ L) :
    ∀ L ∈ S_set, M * exp (-L) ≤ M * exp (-L_opt) := by
  intro L hL
  exact persistence_antitone M hM (hmin L hL)

/-! ## Part 3: Log-Space Duality -/

/-- In log-space, the duality becomes additive:
    log S = log M - L.
    Maximizing log S is equivalent to minimizing L. -/
theorem log_persistence_eq_neg_consumption (M L : ℝ) (hM : 0 < M) :
    log (M * exp (-L)) = log M - L := by
  rw [log_mul (ne_of_gt hM) (ne_of_gt (exp_pos _)), log_exp]
  ring

/-- The log-space representation makes the duality transparent:
    ∂(log S)/∂L = -1 (unit slope, universal). -/
theorem log_persistence_slope (M L₁ L₂ : ℝ) (hM : 0 < M) (h : L₁ ≠ L₂) :
    (log (M * exp (-L₂)) - log (M * exp (-L₁))) / (L₂ - L₁) = -1 := by
  rw [log_persistence_eq_neg_consumption M L₂ hM,
      log_persistence_eq_neg_consumption M L₁ hM]
  have : L₂ - L₁ ≠ 0 := sub_ne_zero.mpr h.symm
  field_simp [this]
  ring

/-! ## Part 5: Thermodynamic Analogy -/

/-- The structural free energy F = -log S = L - log M.
    Minimizing F ≡ minimizing L (for fixed M).
    This is the structural analogue of Helmholtz free energy. -/
def structuralFreeEnergy (M L : ℝ) : ℝ := L - log M

/-- Free energy and persistence are related by F = -log S. -/
theorem freeEnergy_eq_neg_log_persistence (M L : ℝ) (hM : 0 < M) :
    structuralFreeEnergy M L = -(log (M * exp (-L))) := by
  unfold structuralFreeEnergy
  rw [log_persistence_eq_neg_consumption M L hM]
  ring

/-- Minimizing free energy = minimizing L = maximizing S. -/
theorem min_freeEnergy_iff_min_consumption (M : ℝ) (hM : 0 < M)
    (L₁ L₂ : ℝ) :
    structuralFreeEnergy M L₁ ≤ structuralFreeEnergy M L₂ ↔ L₁ ≤ L₂ := by
  unfold structuralFreeEnergy
  constructor
  · intro h; linarith
  · intro h; linarith

end

end Survival.DualityTheorem
