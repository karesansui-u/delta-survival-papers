import Survival.FinitePathTrajectoryRatioBridge

/-!
# Finite Path Local-Detailed-Balance Bridge

This module records the conservative finite-path layer for a
local-detailed-balance-style reading.

It does not prove physical local detailed balance.  Instead, it separates the
extra data needed to read a path probability ratio as an entropy-production
observable:

* a system-boundary term;
* a medium / environment term;
* a residual term.

The trajectory ratio `σ(γ)` is identified with `system + medium` only under an
explicit zero-residual hypothesis.  This keeps the stochastic-thermodynamics
reading separate from Core structural accounting.
-/

namespace Survival.FinitePathLocalDetailedBalanceBridge

open scoped BigOperators
open Survival.FinitePathTrajectoryRatioBridge

noncomputable section

variable {Ω : Type*}

/-- Extra system/medium observables on the forward support of a finite
path-ratio comparison.  These are supplied data; Lean does not infer them from
Core's structural accounting. -/
structure SystemMediumEntropyData
    (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) where
  systemBoundary : ForwardSupport P → ℝ
  mediumEntropy : ForwardSupport P → ℝ

/-- The candidate entropy-production observable `system + medium`. -/
def totalEntropyProductionObservable
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (γ : ForwardSupport P) : ℝ :=
  D.systemBoundary γ + D.mediumEntropy γ

/-- The residual between the path probability ratio and the supplied
system/medium split.  This is the formal guardrail: local detailed balance is
not assumed unless this residual is controlled or zero. -/
def localDetailedBalanceResidual
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (γ : ForwardSupport P) : ℝ :=
  trajectoryRatio P Q θ hAC γ - totalEntropyProductionObservable D γ

/-- Exact local-detailed-balance reading: the path ratio has no residual after
the chosen system/medium split. -/
def HasExactLocalDetailedBalanceReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC) : Prop :=
  ∀ γ, localDetailedBalanceResidual D γ = 0

/-- Approximate local-detailed-balance reading with a nonnegative residual
radius. -/
def HasLocalDetailedBalanceResidualBound
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC) (ε : ℝ) : Prop :=
  0 ≤ ε ∧ ∀ γ, |localDetailedBalanceResidual D γ| ≤ ε

/-- Tautological system/medium/residual decomposition:
`system + medium + residual = σ`. -/
theorem totalEntropyProduction_add_residual_eq_trajectoryRatio
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (γ : ForwardSupport P) :
    totalEntropyProductionObservable D γ +
        localDetailedBalanceResidual D γ =
      trajectoryRatio P Q θ hAC γ := by
  unfold localDetailedBalanceResidual
  ring

/-- Under exact local-detailed-balance reading, the path ratio equals the
system/medium entropy-production observable. -/
theorem trajectoryRatio_eq_totalEntropyProduction_of_exactReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hexact : HasExactLocalDetailedBalanceReading D)
    (γ : ForwardSupport P) :
    trajectoryRatio P Q θ hAC γ =
      totalEntropyProductionObservable D γ := by
  have h :=
    totalEntropyProduction_add_residual_eq_trajectoryRatio D γ
  rw [hexact γ] at h
  linarith

variable [Fintype Ω]

/-- The forward-weighted finite sum using only the supplied system/medium
entropy-production observable. -/
def forwardWeightedTotalEntropyProductionExpSum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal *
        Real.exp (-(totalEntropyProductionObservable D γ)))

/-- The forward-weighted finite sum using system + medium + residual. -/
def forwardWeightedSystemMediumResidualExpSum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal *
        Real.exp (-(
          totalEntropyProductionObservable D γ +
            localDetailedBalanceResidual D γ)))

/-- Including the local-detailed-balance residual makes the system/medium sum
exactly the finite path-ratio exponential sum. -/
theorem forward_weighted_system_medium_residual_exp_sum_eq_exp_neg_ratio_sum
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC) :
    forwardWeightedSystemMediumResidualExpSum D =
      forwardWeightedExpNegRatioSum P Q θ hAC := by
  unfold forwardWeightedSystemMediumResidualExpSum
  unfold forwardWeightedExpNegRatioSum
  refine Finset.sum_congr rfl ?_
  intro γ _
  rw [totalEntropyProduction_add_residual_eq_trajectoryRatio D γ]

/-- Under reverse-mass coverage, the residual-including local-detailed-balance
reading inherits the finite path-ratio identity. -/
theorem finite_integral_system_medium_residual_identity_of_reverseMassCoverage
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedSystemMediumResidualExpSum D = 1 := by
  rw [forward_weighted_system_medium_residual_exp_sum_eq_exp_neg_ratio_sum D]
  exact finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage hAC hcov

/-- If the local-detailed-balance residual vanishes, the system/medium sum and
the residual-including sum coincide. -/
theorem forward_weighted_totalEntropy_exp_sum_eq_residual_exp_sum_of_exactReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hexact : HasExactLocalDetailedBalanceReading D) :
    forwardWeightedTotalEntropyProductionExpSum D =
      forwardWeightedSystemMediumResidualExpSum D := by
  unfold forwardWeightedTotalEntropyProductionExpSum
  unfold forwardWeightedSystemMediumResidualExpSum
  refine Finset.sum_congr rfl ?_
  intro γ _
  rw [hexact γ]
  simp

/-- Under reverse-mass coverage and exact local-detailed-balance reading, the
system/medium entropy-production observable satisfies the finite exponential
identity. -/
theorem finite_integral_totalEntropy_identity_of_exactReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hexact : HasExactLocalDetailedBalanceReading D)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedTotalEntropyProductionExpSum D = 1 := by
  rw [forward_weighted_totalEntropy_exp_sum_eq_residual_exp_sum_of_exactReading
    D hexact]
  exact finite_integral_system_medium_residual_identity_of_reverseMassCoverage
    D hcov

end

end Survival.FinitePathLocalDetailedBalanceBridge
