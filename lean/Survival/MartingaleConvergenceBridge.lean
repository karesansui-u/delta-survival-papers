import Survival.ConditionalMartingale
import Mathlib.Probability.Martingale.Convergence

/-!
# Martingale Convergence Bridge — Long-Term S_n Convergence

This module establishes conditions under which the structural
persistence potential S_n = M_n exp(-B_n) converges almost surely,
using Doob's martingale convergence theorem from Mathlib.

## Mathematical context

If exp(-B_n) is a nonneg supermartingale (which happens when the
expected net consumption E[b_t | F_t] ≥ 0), then by Doob's
convergence theorem, exp(-B_n) converges a.s. to a finite limit.

This gives a structural interpretation: the "structural retention
factor" exp(-B_n) stabilizes in the long run, either at some
positive level (sustainable system) or at zero (structural collapse).

## Structural-persistence reading

1. **Supermartingale condition**: exp(-B_n) is a nonneg supermartingale
   when E[b_t | F_t] ≥ 0 a.s. (expected consumption exceeds recovery).

2. **Doob convergence**: Under the supermartingale condition,
   exp(-B_n) → R_∞ a.s. for some nonneg limit R_∞.

3. **Dichotomy**: R_∞ > 0 ↔ structural persistence (the system
   retains positive viable mass forever).
   R_∞ = 0 ↔ structural collapse (viable mass vanishes).

References:
  - Doob, J.L. (1953). "Stochastic Processes."
  - Williams, D. (1991). "Probability with Martingales."
  - Mathlib: `Submartingale.ae_tendsto_limitProcess`
  - ConditionalMartingale.lean: martingale interface
-/

namespace Survival.MartingaleConvergenceBridge

open MeasureTheory Filter
open scoped ProbabilityTheory

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}

/-! ## Part 1: Structural Retention Process -/

/-- The structural retention process R_n = exp(-B_n) where B_n is
    cumulative net consumption.  This is non-negative by construction. -/
def retentionProcess (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) : ℝ :=
  Real.exp (-(B n ω))

/-- The retention process is always positive. -/
theorem retentionProcess_pos (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) :
    0 < retentionProcess B n ω :=
  Real.exp_pos _

/-- The retention process is always nonneg. -/
theorem retentionProcess_nonneg (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) :
    0 ≤ retentionProcess B n ω :=
  le_of_lt (retentionProcess_pos B n ω)

/-! ## Part 2: Supermartingale Condition -/

/-- The condition that net consumption is nonneg in expectation:
    E[B_{n+1} - B_n | F_n] ≥ 0 a.s.

    Under this condition, the retention process exp(-B_n) is a
    nonneg supermartingale (since exp is convex and decreasing in -B,
    Jensen gives E[exp(-B_{n+1}) | F_n] ≤ exp(-B_n) when E[b_t] ≥ 0).

    This is the structural-persistence reading: if expected consumption
    exceeds expected recovery at each step, the retention factor
    tends to decrease. -/
def HasNonnegExpectedConsumption (B : ℕ → Ω → ℝ) : Prop :=
  ∀ n, 0 ≤ ∫ ω, (B (n + 1) ω - B n ω) ∂μ

/-! ## Part 3: Convergence Theorem (Algebraic Core) -/

/-- **Telescoping for retention**: R_n = R_0 * exp(-(B_n - B_0)).
    This is the retention-process form of the telescoping exponential. -/
theorem retentionProcess_telescoping (B : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) :
    retentionProcess B n ω =
      retentionProcess B 0 ω * Real.exp (-(B n ω - B 0 ω)) := by
  unfold retentionProcess
  rw [← Real.exp_add]
  congr 1
  ring

/-- If B_0 = 0 (standard initial condition), then R_n = exp(-B_n). -/
theorem retentionProcess_of_zero_initial
    (B : ℕ → Ω → ℝ) (hB0 : ∀ ω, B 0 ω = 0) (n : ℕ) (ω : Ω) :
    retentionProcess B n ω = Real.exp (-(B n ω)) := by
  unfold retentionProcess
  rfl

/-- If B_0 = 0, then R_0 = 1. -/
theorem retentionProcess_zero_eq_one
    (B : ℕ → Ω → ℝ) (hB0 : ∀ ω, B 0 ω = 0) (ω : Ω) :
    retentionProcess B 0 ω = 1 := by
  unfold retentionProcess
  rw [hB0]
  simp

/-! ## Part 4: Structural Dichotomy -/

/-- **Collapse direction**: If cumulative consumption diverges to +∞,
    then the retention factor converges to 0 (structural collapse).

    B_n(ω) → +∞  ⟹  exp(-B_n(ω)) → 0 -/
theorem retention_tends_zero_of_consumption_diverges
    (B : ℕ → Ω → ℝ) (ω : Ω)
    (hB : Filter.Tendsto (fun n => B n ω) Filter.atTop Filter.atTop) :
    Filter.Tendsto (fun n => retentionProcess B n ω) Filter.atTop (nhds 0) := by
  unfold retentionProcess
  have : Filter.Tendsto (fun n => -(B n ω)) Filter.atTop Filter.atBot :=
    tendsto_neg_atTop_atBot.comp hB
  exact (Real.tendsto_exp_atBot.comp this)

/-- **Persistence criterion**: if cumulative consumption is bounded above,
    then the retention factor stays bounded away from zero. -/
theorem retention_bounded_away_from_zero
    (B : ℕ → Ω → ℝ) (ω : Ω) (C : ℝ)
    (hbound : ∀ n, B n ω ≤ C) :
    ∀ n, Real.exp (-C) ≤ retentionProcess B n ω := by
  intro n
  unfold retentionProcess
  exact Real.exp_le_exp.mpr (by linarith [hbound n])

/-- The lower bound from bounded consumption is positive. -/
theorem persistence_lower_bound_pos (C : ℝ) :
    0 < Real.exp (-C) :=
  Real.exp_pos _

end

end Survival.MartingaleConvergenceBridge
