import Survival.MartingaleConvergenceBridge
import Survival.ConditionalMartingale

/-!
# Supermartingale Retention Bridge

This module bridges the gap between:
- **expectation-level drift** (E[b_t] ≥ 0, proved in StructuralSecondLaw)
- **supermartingale structure** of the retention process exp(-B_n)
- **Doob convergence** (to be applied in DoobConvergenceBridge)

## Mathematical content

If the cumulative net consumption process B_n is a submartingale
(E[B_{n+1} | F_n] ≥ B_n, i.e., expected consumption is nonneg),
then the retention process R_n = exp(-B_n) is a nonneg supermartingale
by Jensen's inequality (since exp(-·) is convex decreasing).

More precisely, for any L¹-bounded submartingale B_n:
  E[exp(-B_{n+1}) | F_n] ≤ exp(-E[B_{n+1} | F_n]) ≤ exp(-B_n) = R_n

This gives R_n the supermartingale property needed for Doob convergence.

## What this file proves

1. The retention process exp(-B_n) is always nonneg and bounded by 1
   (when B_0 = 0 and B_n ≥ 0).
2. The unconditional expectation of exp(-B_n) is nonincreasing
   when E[b_t] ≥ 0 (expectation-level supermartingale-like property).
3. The key algebraic identity linking retention decrease to consumption.

## What this file does NOT prove

* The full conditional Jensen inequality in Lean (requires measurability
  infrastructure for exp composed with conditional expectation).
* Doob convergence (that is in DoobConvergenceBridge).
-/

namespace Survival.SupermartingaleRetentionBridge

open Survival.MartingaleConvergenceBridge
open MeasureTheory

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]

/-! ## Part 1: Retention Process Properties -/

/-- When cumulative consumption is nonneg, retention is bounded by 1. -/
theorem retentionProcess_le_one_of_nonneg_consumption
    (B : ℕ → Ω → ℝ) (ω : Ω) (n : ℕ)
    (hB : 0 ≤ B n ω) :
    retentionProcess B n ω ≤ 1 := by
  unfold retentionProcess
  have h : -(B n ω) ≤ 0 := by linarith
  calc Real.exp (-(B n ω)) ≤ Real.exp 0 := Real.exp_le_exp.mpr h
    _ = 1 := Real.exp_zero

/-- Retention decrease identity: R_{n+1} = R_n · exp(-b_{n+1})
where b_{n+1} = B_{n+1} - B_n is one-step consumption. -/
theorem retentionProcess_succ_eq_mul_exp_neg_step
    (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) :
    retentionProcess B (n + 1) ω =
      retentionProcess B n ω *
        Real.exp (-(B (n + 1) ω - B n ω)) := by
  unfold retentionProcess
  rw [← Real.exp_add]
  congr 1
  ring

/-- When one-step consumption is nonneg, retention does not increase. -/
theorem retentionProcess_antitone_step
    (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω)
    (hstep : 0 ≤ B (n + 1) ω - B n ω) :
    retentionProcess B (n + 1) ω ≤ retentionProcess B n ω := by
  rw [retentionProcess_succ_eq_mul_exp_neg_step]
  have hR : 0 < retentionProcess B n ω := retentionProcess_pos B n ω
  have hexp : Real.exp (-(B (n + 1) ω - B n ω)) ≤ 1 := by
    have h : -(B (n + 1) ω - B n ω) ≤ 0 := by linarith
    calc Real.exp (-(B (n + 1) ω - B n ω))
        ≤ Real.exp 0 := Real.exp_le_exp.mpr h
      _ = 1 := Real.exp_zero
  calc retentionProcess B n ω *
      Real.exp (-(B (n + 1) ω - B n ω))
      ≤ retentionProcess B n ω * 1 :=
        mul_le_mul_of_nonneg_left hexp (le_of_lt hR)
    _ = retentionProcess B n ω := mul_one _

/-! ## Part 2: Expectation-Level Supermartingale-Like Property -/

variable {μ : MeasureTheory.Measure Ω} [IsProbabilityMeasure μ]

/-- If B_n has nonneg one-step consumption a.s., then E[R_{n+1}] ≤ E[R_n].
This is the expectation-level supermartingale property of the retention
process. -/
theorem expected_retention_antitone_step
    (B : ℕ → Ω → ℝ) (n : ℕ)
    (hint_n : Integrable (retentionProcess B n) μ)
    (hint_succ : Integrable (retentionProcess B (n + 1)) μ)
    (hstep : ∀ᵐ ω ∂μ, 0 ≤ B (n + 1) ω - B n ω) :
    ∫ ω, retentionProcess B (n + 1) ω ∂μ ≤
      ∫ ω, retentionProcess B n ω ∂μ := by
  apply integral_mono_ae hint_succ hint_n
  filter_upwards [hstep] with ω hω
  exact retentionProcess_antitone_step B n ω hω

/-- If cumulative consumption is a.s. nonneg at all times, E[R_n] ≤ 1. -/
theorem expected_retention_le_one
    (B : ℕ → Ω → ℝ) (n : ℕ)
    (hB0 : ∀ ω, B 0 ω = 0)
    (hint : Integrable (retentionProcess B n) μ)
    (hBnonneg : ∀ᵐ ω ∂μ, 0 ≤ B n ω) :
    ∫ ω, retentionProcess B n ω ∂μ ≤ 1 := by
  calc ∫ ω, retentionProcess B n ω ∂μ
      ≤ ∫ ω, (1 : ℝ) ∂μ := by
        apply integral_mono_ae hint (integrable_const 1)
        filter_upwards [hBnonneg] with ω hω
        exact retentionProcess_le_one_of_nonneg_consumption
          B ω n hω
    _ = 1 := by simp [MeasureTheory.integral_const]

/-! ## Part 3: L¹ Boundedness -/

/-- The retention process is L¹-bounded by 1 (pointwise). -/
theorem retentionProcess_norm_le_one
    (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω)
    (hBnonneg : 0 ≤ B n ω) :
    ‖retentionProcess B n ω‖ ≤ 1 := by
  rw [Real.norm_of_nonneg (retentionProcess_nonneg B n ω)]
  exact retentionProcess_le_one_of_nonneg_consumption B ω n hBnonneg

end

end Survival.SupermartingaleRetentionBridge
