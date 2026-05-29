import Survival.ConstantFractionDecay

/-!
# Branching-Process Extinction Skeleton

This module formalizes the Route A core example A13 at the expectation level.
For a Galton--Watson-style branching process with mean offspring number `m`,
the expected population after `n` generations is `initial * m^n`.

In the subcritical or critical regime `0 < m <= 1`, this is exactly the same
constant-fraction exponential skeleton as `ConstantFractionDecay`:

`m^n = exp (-(n * -log m))`.

The file intentionally does not claim almost-sure extinction.  It records the
finite-prefix expectation-level law and the subcritical positive log-loss
direction.
-/

namespace Survival.BranchingProcessExtinction

noncomputable section

/-- Mean-offspring data for a critical/subcritical branching process. -/
structure MeanOffspringModel where
  meanOffspring : ℝ
  mean_pos : 0 < meanOffspring
  mean_le_one : meanOffspring ≤ 1

/-- The expectation-level branching skeleton is a constant-fraction decay law
with retained fraction equal to the mean offspring number. -/
def toDecaySystem (B : MeanOffspringModel) :
    ConstantFractionDecay.System where
  q := B.meanOffspring
  q_pos := B.mean_pos
  q_le_one := B.mean_le_one

/-- Expected surviving lineage fraction after `n` generations. -/
def survivalFraction (B : MeanOffspringModel) (n : ℕ) : ℝ :=
  ConstantFractionDecay.remainingFraction (toDecaySystem B) n

/-- Expected population after `n` generations from an initial mass. -/
def expectedPopulation (B : MeanOffspringModel) (initial : ℝ) (n : ℕ) : ℝ :=
  ConstantFractionDecay.remainingMass (toDecaySystem B) initial n

/-- One-generation mean log-loss. -/
def meanStepLoss (B : MeanOffspringModel) : ℝ :=
  ConstantFractionDecay.stepLoss (toDecaySystem B)

/-- Cumulative mean log-loss after `n` generations. -/
def cumulativeMeanLoss (B : MeanOffspringModel) (n : ℕ) : ℝ :=
  ConstantFractionDecay.cumulativeLoss (toDecaySystem B) n

@[simp] theorem survivalFraction_zero (B : MeanOffspringModel) :
    survivalFraction B 0 = 1 := by
  simp [survivalFraction]

@[simp] theorem cumulativeMeanLoss_zero (B : MeanOffspringModel) :
    cumulativeMeanLoss B 0 = 0 := by
  simp [cumulativeMeanLoss]

/-- The expected surviving fraction is `m^n`. -/
theorem survivalFraction_eq_pow (B : MeanOffspringModel) (n : ℕ) :
    survivalFraction B n = B.meanOffspring ^ n := by
  rfl

/-- Expected population is initial mass times `m^n`. -/
theorem expectedPopulation_eq_initial_mul_pow
    (B : MeanOffspringModel) (initial : ℝ) (n : ℕ) :
    expectedPopulation B initial n = initial * B.meanOffspring ^ n := by
  rfl

/-- Mean log-loss is nonnegative in the critical/subcritical regime. -/
theorem meanStepLoss_nonneg (B : MeanOffspringModel) :
    0 ≤ meanStepLoss B :=
  ConstantFractionDecay.stepLoss_nonneg (toDecaySystem B)

/-- Mean log-loss is strictly positive in the subcritical regime `m < 1`. -/
theorem meanStepLoss_pos_of_subcritical
    (B : MeanOffspringModel) (hsub : B.meanOffspring < 1) :
    0 < meanStepLoss B := by
  unfold meanStepLoss ConstantFractionDecay.stepLoss toDecaySystem
  have hlog : Real.log B.meanOffspring < 0 :=
    Real.log_neg B.mean_pos hsub
  linarith

/-- Mean log-loss vanishes in the critical case `m = 1`. -/
theorem meanStepLoss_eq_zero_of_critical
    (B : MeanOffspringModel) (hcrit : B.meanOffspring = 1) :
    meanStepLoss B = 0 := by
  simp [meanStepLoss, ConstantFractionDecay.stepLoss, toDecaySystem, hcrit]

/-- Cumulative mean log-loss is nonnegative. -/
theorem cumulativeMeanLoss_nonneg (B : MeanOffspringModel) (n : ℕ) :
    0 ≤ cumulativeMeanLoss B n :=
  ConstantFractionDecay.cumulativeLoss_nonneg (toDecaySystem B) n

/-- In the subcritical regime, cumulative mean loss is strictly positive after
at least one generation. -/
theorem cumulativeMeanLoss_pos_of_subcritical
    (B : MeanOffspringModel) {n : ℕ}
    (hsub : B.meanOffspring < 1) (hn : 0 < n) :
    0 < cumulativeMeanLoss B n := by
  unfold cumulativeMeanLoss ConstantFractionDecay.cumulativeLoss
  exact mul_pos (Nat.cast_pos.mpr hn) (meanStepLoss_pos_of_subcritical B hsub)

/-- The expected surviving fraction has the structural-persistence exponential
form. -/
theorem exp_neg_cumulativeMeanLoss_eq_survivalFraction
    (B : MeanOffspringModel) (n : ℕ) :
    Real.exp (-cumulativeMeanLoss B n) = survivalFraction B n :=
  ConstantFractionDecay.exp_neg_cumulativeLoss_eq_remainingFraction
    (toDecaySystem B) n

/-- Expected population inherits the exponential-loss representation. -/
theorem expectedPopulation_eq_initial_mul_exp_neg_cumulativeMeanLoss
    (B : MeanOffspringModel) (initial : ℝ) (n : ℕ) :
    expectedPopulation B initial n =
      initial * Real.exp (-cumulativeMeanLoss B n) :=
  ConstantFractionDecay.remainingMass_eq_initial_mul_exp_neg_cumulativeLoss
    (toDecaySystem B) initial n

/-- If cumulative mean loss crosses `-log θ`, then the expected surviving
fraction is at most `θ`. -/
theorem survivalFraction_le_threshold_of_cumulativeMeanLoss_ge
    (B : MeanOffspringModel) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeMeanLoss B n) :
    survivalFraction B n ≤ θ :=
  ConstantFractionDecay.remainingFraction_le_threshold_of_cumulativeLoss_ge
    (toDecaySystem B) n hθ hcross

/-- Initial-mass version of the threshold bound. -/
theorem expectedPopulation_le_initial_mul_threshold
    (B : MeanOffspringModel) (initial : ℝ) (n : ℕ) {θ : ℝ}
    (hinit : 0 ≤ initial)
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeMeanLoss B n) :
    expectedPopulation B initial n ≤ initial * θ := by
  unfold expectedPopulation ConstantFractionDecay.remainingMass
  exact mul_le_mul_of_nonneg_left
    (survivalFraction_le_threshold_of_cumulativeMeanLoss_ge B n hθ hcross)
    hinit

end

end Survival.BranchingProcessExtinction
