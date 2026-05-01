import Survival.FinitePathTrajectoryRatioBridge

/-!
# Finite Path Structural-Observable Bridge

This module is the v3-c coupling layer for the trajectory-ratio bridge.

It places three quantities on the same finite path support:

* the trajectory probability ratio `σ(γ)`;
* a structural net observable `B(γ)`;
* a housekeeping / maintenance observable `C(γ)`;

and defines the residual

`R(γ) = σ(γ) - (B(γ) + C(γ))`.

The point is deliberately conservative: Core-style structural accounting is
not identified with the trajectory ratio by default.  Equality with `B + C`
requires the additional condition that the residual vanish.
-/

namespace Survival.FinitePathStructuralObservableBridge

open scoped BigOperators
open Survival.FinitePathTrajectoryRatioBridge

noncomputable section

variable {Ω : Type*}

/-- Structural observables living on the forward support of a finite
trajectory-ratio comparison.  The fields are intentionally separate from the
path probability ratio. -/
structure StructuralObservableData
    (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) where
  structuralNet : ForwardSupport P → ℝ
  housekeepingCost : ForwardSupport P → ℝ

/-- The Core-side total observable `B(γ) + C(γ)` on the same path support. -/
def structuralTotal
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (γ : ForwardSupport P) : ℝ :=
  D.structuralNet γ + D.housekeepingCost γ

/-- The residual between the trajectory ratio and the supplied structural
observables.  This is a definition, not a physics claim. -/
def trajectoryResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (γ : ForwardSupport P) : ℝ :=
  trajectoryRatio P Q θ hAC γ - structuralTotal D γ

/-- The condition under which the trajectory ratio is exactly exhausted by
the supplied structural observables. -/
def HasZeroResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC) : Prop :=
  ∀ γ, trajectoryResidual D γ = 0

/-- A bounded-residual condition for future approximate bridges. -/
def HasResidualBound
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC) (ε : ℝ) : Prop :=
  0 ≤ ε ∧ ∀ γ, |trajectoryResidual D γ| ≤ ε

/-- Tautological residual decomposition:
`B(γ) + C(γ) + R(γ) = σ(γ)`. -/
theorem structuralTotal_add_residual_eq_trajectoryRatio
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (γ : ForwardSupport P) :
    structuralTotal D γ + trajectoryResidual D γ =
      trajectoryRatio P Q θ hAC γ := by
  unfold trajectoryResidual
  ring

/-- If the residual vanishes, the trajectory ratio equals the structural total
observable `B + C`. -/
theorem trajectoryRatio_eq_structuralTotal_of_zeroResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (hzero : HasZeroResidual D)
    (γ : ForwardSupport P) :
    trajectoryRatio P Q θ hAC γ = structuralTotal D γ := by
  have h :=
    structuralTotal_add_residual_eq_trajectoryRatio D γ
  rw [hzero γ] at h
  linarith

variable [Fintype Ω]

/-- The forward-weighted finite sum using only the supplied structural total
observable `B + C`. -/
def forwardWeightedStructuralTotalExpSum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal * Real.exp (-(structuralTotal D γ)))

/-- The forward-weighted finite sum using the structural total plus the
residual, i.e. `B + C + R`. -/
def forwardWeightedStructuralResidualExpSum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal *
        Real.exp (-(structuralTotal D γ + trajectoryResidual D γ)))

/-- Including the residual makes the structural-observable exponential sum
exactly the finite path-ratio exponential sum. -/
theorem forward_weighted_structural_residual_exp_sum_eq_exp_neg_ratio_sum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC) :
    forwardWeightedStructuralResidualExpSum D =
      forwardWeightedExpNegRatioSum P Q θ hAC := by
  unfold forwardWeightedStructuralResidualExpSum
  unfold forwardWeightedExpNegRatioSum
  refine Finset.sum_congr rfl ?_
  intro γ _
  rw [structuralTotal_add_residual_eq_trajectoryRatio D γ]

/-- Under reverse-mass coverage, the residual-including structural observable
sum closes to `1`. -/
theorem finite_integral_structural_residual_identity_of_reverseMassCoverage
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedStructuralResidualExpSum D = 1 := by
  rw [forward_weighted_structural_residual_exp_sum_eq_exp_neg_ratio_sum D]
  exact finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage hAC hcov

/-- If the residual vanishes, the structural-total sum and the
residual-including sum coincide. -/
theorem forward_weighted_structural_total_exp_sum_eq_residual_exp_sum_of_zeroResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (hzero : HasZeroResidual D) :
    forwardWeightedStructuralTotalExpSum D =
      forwardWeightedStructuralResidualExpSum D := by
  unfold forwardWeightedStructuralTotalExpSum
  unfold forwardWeightedStructuralResidualExpSum
  refine Finset.sum_congr rfl ?_
  intro γ _
  rw [hzero γ]
  simp

/-- Under reverse-mass coverage and zero residual, the structural total alone
satisfies the finite exponential identity. -/
theorem finite_integral_structural_total_identity_of_zeroResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : StructuralObservableData P Q θ hAC)
    (hzero : HasZeroResidual D)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedStructuralTotalExpSum D = 1 := by
  rw [forward_weighted_structural_total_exp_sum_eq_residual_exp_sum_of_zeroResidual
    D hzero]
  exact finite_integral_structural_residual_identity_of_reverseMassCoverage
    D hcov

end

end Survival.FinitePathStructuralObservableBridge
