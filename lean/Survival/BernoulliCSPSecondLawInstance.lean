import Survival.BernoulliTypicalSigma
import Survival.CrossClassUnificationV3
import Survival.StructuralSecondLaw

/-!
# Bernoulli-CSP Second Law Instance

This module registers Bernoulli-CSP as a concrete instance of the
structural second law framework.

## What this file does

1. Wraps the existing `BernoulliTypicalSigma` monotonicity result into
   the V3 interface vocabulary.
2. Shows that Bernoulli-CSP expected Σ satisfies `ExpectedNonnegativeDrift`.
3. Provides the structural second law for Bernoulli-CSP at expectation level.

## What this file does NOT do

* Register Bernoulli-CSP as a `StructuralMaintenanceClass` directly
  (that requires converting `Parameters` + `Trajectory` into
  `ProblemSpec X` + `RepairBudget`).
* Prove pathwise monotonicity as a universal requirement.
-/

namespace Survival.BernoulliCSPSecondLawInstance

open Survival.BernoulliTypicalSigma
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.ProbabilityConnection
open Survival.TypicalNondecrease

noncomputable section

/-! ## Part 1: Expectation-Level Second Law for Bernoulli-CSP -/

/-- The Bernoulli-CSP Σ process has nonnegative expected drift. -/
theorem bernoulliCSP_nonneg_expected_drift
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    ExpectedNonnegativeDrift
      (bernoulliSigmaProcess P N s₀).toExpectedProcess :=
  toExpectedProcess_has_nonnegative_drift
    (bernoulliSigmaProcess P N s₀)
    (bernoulliSigma_ae_nonnegative_increment P N s₀)

/-- **Bernoulli-CSP Structural Second Law (Expectation Level).**
The expected cumulative Σ observable is monotone nondecreasing. -/
theorem bernoulliCSP_expected_sigma_monotone
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    let proc := bernoulliSigmaProcess P N s₀
    Monotone (proc.toExpectedProcess.expectedCumulative) :=
  bernoulliSigma_expectedCumulative_monotone P N s₀

/-- Bernoulli-CSP additionally has pathwise monotonicity
(class-specific, not required by generic second law). -/
theorem bernoulliCSP_pathwise_monotone
    (P : Parameters) (s₀ : ℝ) {N : ℕ}
    (τ : Trajectory N) :
    Monotone (bernoulliSigma P s₀ τ) := by
  intro m n hmn
  induction hmn with
  | refl => exact le_refl _
  | step hmn ih =>
      exact le_trans ih (bernoulliSigma_succ_le P s₀ τ _)

/-! ## Part 2: Second Law Components Bundle -/

/-- Bundles the key second law properties for Bernoulli-CSP. -/
structure SecondLawComponents
    (P : Parameters) (N : ℕ) (s₀ : ℝ) : Prop where
  /-- Expected drift is nonneg at each step. -/
  nonneg_drift :
    ExpectedNonnegativeDrift
      (bernoulliSigmaProcess P N s₀).toExpectedProcess
  /-- Expected cumulative Σ is monotone. -/
  monotone_expected :
    let proc := bernoulliSigmaProcess P N s₀
    Monotone (proc.toExpectedProcess.expectedCumulative)
  /-- Pathwise Σ is monotone (class-specific bonus). -/
  monotone_pathwise :
    ∀ (τ : Trajectory N),
      Monotone (bernoulliSigma P s₀ τ)

/-- Every Bernoulli-CSP instance satisfies the second law. -/
theorem satisfies_second_law
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    SecondLawComponents P N s₀ where
  nonneg_drift := bernoulliCSP_nonneg_expected_drift P N s₀
  monotone_expected :=
    bernoulliCSP_expected_sigma_monotone P N s₀
  monotone_pathwise := fun τ =>
    bernoulliCSP_pathwise_monotone P s₀ τ

end

end Survival.BernoulliCSPSecondLawInstance
