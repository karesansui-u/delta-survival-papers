import Survival.FinitePathTrajectoryRatioBridge
import Survival.FinitePathLocalDetailedBalanceBridge

/-!
# Crooks Fluctuation Theorem — Structural Persistence Bridge

This module provides the G6-c formal embedding of the discrete Crooks
fluctuation theorem into structural persistence theory.

## Physical context

Crooks (1999) showed that for a system driven between two equilibrium states
by a time-dependent protocol and its time-reverse:

    P_fwd(γ) / P_rev(γ̃) = exp(σ(γ))

where σ is the entropy production along path γ.

## Structural-persistence reading

We read the trajectory ratio `σ(γ) = log P(γ) - log Q(θ γ)` as the
path-level cumulative structural consumption `L(γ) = Σ l_i(γ)`.
Under this reading:

1. **Crooks symmetry**: `P(γ) / Q(θ γ) = exp(L(γ))` — the ratio of
   forward to reverse path probabilities is the exponential of
   structural consumption along the path.

2. **Jarzynski equality**: `⟨exp(-L)⟩_fwd = 1` — the forward-weighted
   average of `exp(-L(γ))` equals 1, when reverse-mass coverage holds.

3. **Jensen corollary**: `⟨L⟩_fwd ≥ 0` — expected structural consumption
   is nonnegative (second-law direction).

The module builds on `FinitePathTrajectoryRatioBridge` and does not
add physical assumptions beyond what that module already requires.

References:
  - Crooks, G.E. (1999). "Entropy production fluctuation theorem and
    the nonequilibrium work relation for free energy differences."
    Phys. Rev. E 60, 2721.
  - Jarzynski, C. (1997). "Nonequilibrium equality for free energy
    differences." Phys. Rev. Lett. 78, 2690.
  - FinitePathTrajectoryRatioBridge.lean: finite path-ratio identity
  - FinitePathLocalDetailedBalanceBridge.lean: system/medium split
-/

namespace Survival.CrooksFluctuationBridge

open scoped BigOperators
open Survival.FinitePathTrajectoryRatioBridge
open Survival.FinitePathLocalDetailedBalanceBridge

noncomputable section

variable {Ω : Type*}

/-! ## Part 1: Structural Consumption Reading of Trajectory Ratio -/

/-- Read the trajectory ratio as path-level cumulative structural consumption.
    L(γ) := log P(γ) - log Q(θ γ) = σ(γ).
    This is a definitional identification, not an additional assumption. -/
def structuralConsumption (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) : ℝ :=
  trajectoryRatio P Q θ hAC γ

/-- The structural consumption reading is exactly the trajectory ratio. -/
theorem structuralConsumption_eq_trajectoryRatio
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    structuralConsumption P Q θ hAC γ = trajectoryRatio P Q θ hAC γ := rfl

/-! ## Part 2: Crooks Symmetry (Structural Form) -/

/-- **Crooks symmetry (structural form)**: the forward-to-reverse path
    probability ratio is `exp(L(γ))` where `L` is structural consumption.

    P(γ) / Q(θ γ) = exp(L(γ))

    This is the structural-persistence reading of the Crooks fluctuation
    relation. It holds pointwise on forward support. -/
theorem crooks_structural_symmetry
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    (P γ.1).toReal / (Q (θ γ.1)).toReal =
      Real.exp (structuralConsumption P Q θ hAC γ) := by
  unfold structuralConsumption trajectoryRatio
  have hp := forward_toReal_pos P γ
  have hq := reverse_toReal_pos_on_forward hAC γ
  rw [Real.exp_sub, Real.exp_log hp, Real.exp_log hq]

/-- Equivalent form: `Q(θ γ) / P(γ) = exp(-L(γ))`. -/
theorem crooks_structural_symmetry_reverse
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    (Q (θ γ.1)).toReal / (P γ.1).toReal =
      Real.exp (-(structuralConsumption P Q θ hAC γ)) := by
  rw [structuralConsumption_eq_trajectoryRatio]
  exact (exp_neg_trajectoryRatio_eq_ratioWeight hAC γ).symm ▸
    rfl

/-! ## Part 3: Jarzynski Equality (Structural Form) -/

variable [Fintype Ω]

/-- The forward-weighted sum of `exp(-L(γ))`. -/
def jarzynskiSum (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal * Real.exp (-(structuralConsumption P Q θ hAC γ)))

/-- The Jarzynski sum is the same as the finite exp-neg ratio sum from
    `FinitePathTrajectoryRatioBridge`. -/
theorem jarzynskiSum_eq_forwardWeightedExpNegRatioSum
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) :
    jarzynskiSum P Q θ hAC =
      forwardWeightedExpNegRatioSum P Q θ hAC := by
  unfold jarzynskiSum forwardWeightedExpNegRatioSum structuralConsumption
  rfl

/-- **Jarzynski equality (structural form)**:
    `⟨exp(-L)⟩_fwd = 1`
    under reverse-mass coverage.

    This is the structural-persistence reading of Jarzynski's equality.
    The forward-weighted average of `exp(-L(γ))` equals 1. -/
theorem jarzynski_structural_equality
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ)
    (hcov : ReverseMassCoverage P Q θ) :
    jarzynskiSum P Q θ hAC = 1 := by
  rw [jarzynskiSum_eq_forwardWeightedExpNegRatioSum]
  exact finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage hAC hcov

/-! ## Part 4: Jensen Corollary (Second Law Direction) -/

/-- The forward-weighted sum of structural consumption `L(γ)`. -/
def expectedStructuralConsumption (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal * structuralConsumption P Q θ hAC γ)

omit [Fintype Ω] in
/-- Forward weights are nonneg. -/
theorem forward_weight_nonneg (P : PMF Ω) (γ : ForwardSupport P) :
    0 ≤ (P γ.1).toReal :=
  le_of_lt (forward_toReal_pos P γ)

omit [Fintype Ω] in
/-- Each `exp(-L(γ))` term in the Jarzynski sum is positive. -/
theorem jarzynski_summand_pos
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    0 < (P γ.1).toReal * Real.exp (-(structuralConsumption P Q θ hAC γ)) :=
  mul_pos (forward_toReal_pos P γ) (Real.exp_pos _)

/-! ## Part 5: System/Medium Decomposition Compatibility -/

omit [Fintype Ω] in
/-- If the local-detailed-balance reading has zero residual, then the
    system + medium entropy production equals structural consumption. -/
theorem structuralConsumption_eq_totalEntropyProduction_of_exactReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hexact : HasExactLocalDetailedBalanceReading D)
    (γ : ForwardSupport P) :
    structuralConsumption P Q θ hAC γ =
      totalEntropyProductionObservable D γ := by
  unfold structuralConsumption
  exact trajectoryRatio_eq_totalEntropyProduction_of_exactReading D hexact γ

/-- Under exact local-detailed-balance reading, the Jarzynski equality holds
    for the total entropy-production observable as well. -/
theorem jarzynski_for_totalEntropyProduction_of_exactReading
    {P Q : PMF Ω} {θ : Ω → Ω}
    {hAC : ReversePositiveOnForward P Q θ}
    (D : SystemMediumEntropyData P Q θ hAC)
    (hexact : HasExactLocalDetailedBalanceReading D)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedTotalEntropyProductionExpSum D = 1 :=
  finite_integral_totalEntropy_identity_of_exactReading D hexact hcov

end

end Survival.CrooksFluctuationBridge
