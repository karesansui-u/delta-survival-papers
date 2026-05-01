import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Probability.ProbabilityMassFunction.Constructions

/-!
# Finite Path Trajectory-Ratio Bridge

This module is the first conservative Lean step toward trajectory-level
ratio bookkeeping.

It does not identify Core's structural accounting term `B_n` with entropy
production, and it does not prove a physical fluctuation theorem.  It proves
only a finite path-space identity for two explicitly supplied path PMFs:

* a forward PMF `P`;
* a reverse PMF `Q`;
* a reversal map `θ`;
* a one-sided support guard for pointwise ratios; and
* a separate reverse-mass coverage hypothesis when closing the finite
  identity to `1`.

This is the formal version of the guardrail: path probability ratios require
additional path-measure data beyond the Core log-ratio accounting.
-/

namespace Survival.FinitePathTrajectoryRatioBridge

open scoped BigOperators

noncomputable section

variable {Ω : Type*}

/-- The forward support, carried as a subtype so that every path has
`0 < P γ` available in the local context. -/
def ForwardSupport (P : PMF Ω) : Type _ :=
  {γ : Ω // 0 < P γ}

/-- One-sided absolute-continuity guard used only to define the pointwise
forward-support ratio. -/
def ReversePositiveOnForward (P Q : PMF Ω) (θ : Ω → Ω) : Prop :=
  ∀ γ, 0 < P γ → 0 < Q (θ γ)

/-- The forward probability of a forward-supported path is positive after
conversion to real coordinates. -/
theorem forward_toReal_pos (P : PMF Ω) (γ : ForwardSupport P) :
    0 < (P γ.1).toReal := by
  exact ENNReal.toReal_pos (ne_of_gt γ.2) (P.apply_ne_top γ.1)

/-- The reverse probability paired with a forward-supported path is positive
under the one-sided support guard. -/
theorem reverse_toReal_pos_on_forward
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    0 < (Q (θ γ.1)).toReal := by
  exact ENNReal.toReal_pos (ne_of_gt (hAC γ.1 γ.2))
    (Q.apply_ne_top (θ γ.1))

/-- The log path-ratio observable on forward support:
`log P(γ) - log Q(θ γ)`. -/
def trajectoryRatio (P Q : PMF Ω) (θ : Ω → Ω)
    (_hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) : ℝ :=
  Real.log (P γ.1).toReal - Real.log (Q (θ γ.1)).toReal

/-- The exponential weight corresponding to `exp (-trajectoryRatio)`,
written directly as the reverse-over-forward probability ratio. -/
def ratioWeight (P Q : PMF Ω) (θ : Ω → Ω)
    (_hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) : ℝ :=
  (Q (θ γ.1)).toReal / (P γ.1).toReal

/-- The pointwise reverse-over-forward weight is positive on forward support. -/
theorem ratioWeight_pos
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    0 < ratioWeight P Q θ hAC γ := by
  unfold ratioWeight
  exact div_pos (reverse_toReal_pos_on_forward hAC γ) (forward_toReal_pos P γ)

/-- Pointwise exponential/log form of the finite trajectory-ratio weight. -/
theorem exp_neg_trajectoryRatio_eq_ratioWeight
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    Real.exp (-(trajectoryRatio P Q θ hAC γ)) =
      ratioWeight P Q θ hAC γ := by
  unfold trajectoryRatio ratioWeight
  have hp : 0 < (P γ.1).toReal := forward_toReal_pos P γ
  have hq : 0 < (Q (θ γ.1)).toReal :=
    reverse_toReal_pos_on_forward hAC γ
  rw [neg_sub]
  rw [← Real.log_div hq.ne' hp.ne']
  exact Real.exp_log (div_pos hq hp)

/-- Pointwise cancellation: forward probability times the ratio weight gives
the paired reverse probability. -/
theorem forward_mul_ratioWeight_eq_reverse
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) (γ : ForwardSupport P) :
    (P γ.1).toReal * ratioWeight P Q θ hAC γ =
      (Q (θ γ.1)).toReal := by
  unfold ratioWeight
  field_simp [(forward_toReal_pos P γ).ne']

variable [Fintype Ω]

instance instFintypeForwardSupport (P : PMF Ω) :
    Fintype (ForwardSupport P) := by
  classical
  unfold ForwardSupport
  infer_instance

/-- The extra coverage condition needed to close the finite ratio identity to
`1`.  This is intentionally separate from `ReversePositiveOnForward`: pointwise
ratios need only denominator safety, while the identity needs the reverse mass
summed along the reversed forward-support enumeration to be `1`.  If `θ` is not
injective, this is a multiplicity-sensitive sum rather than a set-image mass. -/
def ReverseMassCoverage (P Q : PMF Ω) (θ : Ω → Ω) : Prop :=
  Finset.sum Finset.univ
      (fun γ : ForwardSupport P => (Q (θ γ.1)).toReal) = 1

/-- The forward-weighted finite ratio sum. -/
def forwardWeightedRatioSum (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal * ratioWeight P Q θ hAC γ)

/-- The forward-weighted finite ratio sum, written explicitly as
`∑ P(γ) * exp (-σ(γ))`. -/
def forwardWeightedExpNegRatioSum (P Q : PMF Ω) (θ : Ω → Ω)
    (hAC : ReversePositiveOnForward P Q θ) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P =>
      (P γ.1).toReal * Real.exp (-(trajectoryRatio P Q θ hAC γ)))

/-- The reverse mass summed along the reversed forward-support enumeration.

This is intentionally not called an image mass: without an injectivity or
bijection hypothesis on `θ`, repeated reversed paths are counted with
multiplicity. -/
def reverseMassAlongForwardSupport (P Q : PMF Ω) (θ : Ω → Ω) : ℝ :=
  Finset.sum Finset.univ
    (fun γ : ForwardSupport P => (Q (θ γ.1)).toReal)

/-- The finite ratio sum equals the reverse mass summed along the reversed
forward-support enumeration. -/
theorem forward_weighted_ratio_sum_eq_reverse_mass_along_forward_support
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) :
    forwardWeightedRatioSum P Q θ hAC =
      reverseMassAlongForwardSupport P Q θ := by
  unfold forwardWeightedRatioSum reverseMassAlongForwardSupport
  refine Finset.sum_congr rfl ?_
  intro γ _
  exact forward_mul_ratioWeight_eq_reverse hAC γ

/-- The explicit exponential form of the finite ratio sum equals the same
multiplicity-sensitive reverse-support sum. -/
theorem forward_weighted_exp_neg_ratio_sum_eq_reverse_mass_along_forward_support
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ) :
    forwardWeightedExpNegRatioSum P Q θ hAC =
      reverseMassAlongForwardSupport P Q θ := by
  unfold forwardWeightedExpNegRatioSum reverseMassAlongForwardSupport
  refine Finset.sum_congr rfl ?_
  intro γ _
  rw [exp_neg_trajectoryRatio_eq_ratioWeight hAC γ]
  exact forward_mul_ratioWeight_eq_reverse hAC γ

/-- If all reverse mass is covered by the reversed forward support, the finite
path-ratio identity closes to `1`. -/
theorem finite_integral_ratio_identity_of_reverseMassCoverage
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedRatioSum P Q θ hAC = 1 := by
  rw [forward_weighted_ratio_sum_eq_reverse_mass_along_forward_support hAC]
  exact hcov

/-- If all reverse mass is covered by the reversed forward support, the
reader-facing exponential identity `∑ P(γ) * exp (-σ(γ)) = 1` holds. -/
theorem finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage
    {P Q : PMF Ω} {θ : Ω → Ω}
    (hAC : ReversePositiveOnForward P Q θ)
    (hcov : ReverseMassCoverage P Q θ) :
    forwardWeightedExpNegRatioSum P Q θ hAC = 1 := by
  rw [forward_weighted_exp_neg_ratio_sum_eq_reverse_mass_along_forward_support hAC]
  exact hcov

end

end Survival.FinitePathTrajectoryRatioBridge
