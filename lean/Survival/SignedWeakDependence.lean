import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.WeakDependence

/-!
Signed Weak Dependence — Robust Exponential Bounds for Signed Action
符号付き弱依存 — 符号付き作用に対する指数境界

This module formalizes a cautious signed-action extension of
`Survival.WeakDependence`.

For a signed reference action `A_ref`, the natural perturbation scale is
`ρ * |A_ref|`, not `ρ * A_ref`, because the latter changes sign when
`A_ref < 0`.

If the effective action `A_eff` stays within that absolute envelope,

  |A_eff - A_ref| ≤ ρ * |A_ref|,

then the survival factor `exp (-A_eff)` is sandwiched between the signed
endpoints

  exp (-(A_ref + ρ |A_ref|)) ≤ exp (-A_eff) ≤ exp (-(A_ref - ρ |A_ref|)).

When `A_ref ≥ 0`, these reduce to the usual nonnegative bracket

  exp (-(A_ref * (1 + ρ))) ≤ exp (-A_eff) ≤ exp (-(A_ref * (1 - ρ))).

This is the mathematically safe form appropriate to the supplement's note
that the signed weak-dependence extension is not identical to the
nonnegative-loss case.
-/

open Real

namespace Survival.SignedWeakDependence

noncomputable section

/-- Survival factor induced by a signed net action. -/
def signedSurvival (A : ℝ) : ℝ :=
  exp (-A)

/-- Lower endpoint of the signed-action survival bracket. -/
def signedLowerSurvival (Aref ρ : ℝ) : ℝ :=
  exp (-(Aref + ρ * |Aref|))

/-- Upper endpoint of the signed-action survival bracket. -/
def signedUpperSurvival (Aref ρ : ℝ) : ℝ :=
  exp (-(Aref - ρ * |Aref|))

/-- Effective action stays within a relative absolute-value envelope around the reference. -/
structure SignedActionClose (Aeff Aref ρ : ℝ) : Prop where
  abs_le : |Aeff - Aref| ≤ ρ * |Aref|

theorem signed_action_interval {Aeff Aref ρ : ℝ}
    (h : SignedActionClose Aeff Aref ρ) :
    Aref - ρ * |Aref| ≤ Aeff ∧ Aeff ≤ Aref + ρ * |Aref| := by
  have habs := abs_le.mp h.abs_le
  constructor
  · linarith
  · linarith

/-- Main signed weak-dependence bound: a relative absolute-value action control
induces an exponential survival sandwich. -/
theorem signed_survival_sandwich {Aeff Aref ρ : ℝ}
    (h : SignedActionClose Aeff Aref ρ) :
    signedLowerSurvival Aref ρ ≤ signedSurvival Aeff ∧
      signedSurvival Aeff ≤ signedUpperSurvival Aref ρ := by
  rcases signed_action_interval h with ⟨hlow, hupp⟩
  constructor
  · unfold signedLowerSurvival signedSurvival
    have hneg : -(Aref + ρ * |Aref|) ≤ -Aeff := by linarith
    exact (exp_le_exp).2 hneg
  · unfold signedUpperSurvival signedSurvival
    have hneg : -Aeff ≤ -(Aref - ρ * |Aref|) := by linarith
    exact (exp_le_exp).2 hneg

theorem signedLowerSurvival_pos (Aref ρ : ℝ) : 0 < signedLowerSurvival Aref ρ :=
  exp_pos _

theorem signedUpperSurvival_pos (Aref ρ : ℝ) : 0 < signedUpperSurvival Aref ρ :=
  exp_pos _

/-- On the nonnegative branch, the signed lower endpoint coincides with
the conservative survival factor from `WeakDependence`. -/
theorem signedLower_eq_conservative_of_nonneg {Aref ρ : ℝ}
    (hAref : 0 ≤ Aref) :
    signedLowerSurvival Aref ρ = Survival.WeakDependence.conservativeSurvival Aref ρ := by
  unfold signedLowerSurvival Survival.WeakDependence.conservativeSurvival
  rw [abs_of_nonneg hAref]
  congr 1
  ring

/-- On the nonnegative branch, the signed upper endpoint coincides with
the optimistic survival factor from `WeakDependence`. -/
theorem signedUpper_eq_optimistic_of_nonneg {Aref ρ : ℝ}
    (hAref : 0 ≤ Aref) :
    signedUpperSurvival Aref ρ = Survival.WeakDependence.optimisticSurvival Aref ρ := by
  unfold signedUpperSurvival Survival.WeakDependence.optimisticSurvival
  rw [abs_of_nonneg hAref]
  congr 1
  ring

/-- The signed survival sandwich recovers the previous nonnegative weak-dependence
bracket when the reference action is nonnegative. -/
theorem signed_survival_sandwich_nonneg {Aeff Aref ρ : ℝ}
    (h : SignedActionClose Aeff Aref ρ)
    (hAref : 0 ≤ Aref) :
    Survival.WeakDependence.conservativeSurvival Aref ρ ≤ signedSurvival Aeff ∧
      signedSurvival Aeff ≤ Survival.WeakDependence.optimisticSurvival Aref ρ := by
  rcases signed_survival_sandwich h with ⟨hl, hu⟩
  constructor
  · rw [← signedLower_eq_conservative_of_nonneg hAref]
    exact hl
  · rw [← signedUpper_eq_optimistic_of_nonneg hAref]
    exact hu

end

end Survival.SignedWeakDependence
