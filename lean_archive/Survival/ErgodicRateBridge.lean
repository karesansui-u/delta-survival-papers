import Survival.MartingaleConvergenceBridge
import Survival.LargeDeviationBridge

/-!
# Ergodic Rate Bridge — Birkhoff's Ergodic Theorem Connection

This module provides the G6-b/c correspondence between ergodic
time-averages and the structural-persistence consumption rate.

## Structural-persistence reading

The structural consumption density L_n / n has a natural
"ergodic" interpretation: if the per-step structural consumption
{l_i} is stationary and ergodic, then L_n / n → l̄ (a.s.) where
l̄ = E[l_1] is the stationary mean consumption rate.

The dichotomy is:
- l̄ > 0 → structural collapse (L_n → ∞, exp(-L_n) → 0)
- l̄ = 0 → boundary (structural consumption balanced)
- l̄ < 0 → structural recovery (net recovery exceeds consumption)

This module formalizes the algebraic core without requiring
Birkhoff's ergodic theorem from Mathlib (which is not yet available
in a form compatible with our setting).

References:
  - Birkhoff, G.D. (1931). "Proof of the ergodic theorem."
  - Walters, P. (1982). "An Introduction to Ergodic Theory." Springer.
  - MartingaleConvergenceBridge.lean: retention process convergence
  - LargeDeviationBridge.lean: exponential rate function
-/

namespace Survival.ErgodicRateBridge

open Real

noncomputable section

/-! ## Part 1: Consumption Rate -/

/-- The structural consumption density (time-averaged cumulative loss). -/
def consumptionDensity (L : ℕ → ℝ) (n : ℕ) : ℝ :=
  L (n + 1) / (↑(n + 1))

/-- The cumulative loss at time 0 is 0 (standard initial condition). -/
def HasZeroInitial (L : ℕ → ℝ) : Prop := L 0 = 0

/-- Consumption density at step 0 equals L(1). -/
theorem consumptionDensity_zero (L : ℕ → ℝ) :
    consumptionDensity L 0 = L 1 := by
  unfold consumptionDensity
  simp

/-! ## Part 2: Constant-Rate Model -/

/-- A constant-rate consumption model: each step has the same
    structural consumption l̄. This is the simplest ergodic model. -/
structure ConstantRateModel where
  /-- The stationary consumption rate -/
  rate : ℝ

/-- Cumulative loss: L(n) = n * rate -/
def ConstantRateModel.cumulative (M : ConstantRateModel) (n : ℕ) : ℝ :=
  ↑n * M.rate

/-- Cumulative loss at 0 is 0. -/
theorem constantRate_zero_initial (M : ConstantRateModel) :
    M.cumulative 0 = 0 := by
  unfold ConstantRateModel.cumulative
  simp

/-- The consumption density of a constant-rate model converges to the rate. -/
theorem constantRate_density_eq (M : ConstantRateModel) (n : ℕ) :
    consumptionDensity M.cumulative n = M.rate := by
  unfold consumptionDensity ConstantRateModel.cumulative
  push_cast
  field_simp

/-- The retention factor of a constant-rate model. -/
def constantRateRetention (M : ConstantRateModel) (n : ℕ) : ℝ :=
  exp (-(M.cumulative n))

/-- Retention equals exp(-n * rate). -/
theorem constantRateRetention_eq (M : ConstantRateModel) (n : ℕ) :
    constantRateRetention M n = exp (-(↑n * M.rate)) := rfl

/-! ## Part 3: Ergodic Dichotomy -/

/-- **Collapse regime**: positive stationary rate implies
    cumulative loss diverges and retention vanishes.

    l̄ > 0  ⟹  L_n → ∞  ⟹  exp(-L_n) → 0 -/
theorem collapse_of_positive_rate (M : ConstantRateModel)
    (hpos : 0 < M.rate) :
    Filter.Tendsto (fun n => constantRateRetention M n)
      Filter.atTop (nhds 0) := by
  -- Show constantRateRetention M n = retentionProcess (fun n _ => M.cumulative n) n ()
  -- and then apply retention_tends_zero_of_consumption_diverges
  change Filter.Tendsto (fun n => exp (-(M.cumulative n))) Filter.atTop (nhds 0)
  -- M.cumulative n = ↑n * M.rate, so we need to show exp(-(↑n * rate)) → 0
  -- Use the same pattern as LargeDeviationBridge.chernoff_tends_zero
  -- which internally uses MartingaleConvergenceBridge
  have key := Survival.MartingaleConvergenceBridge.retention_tends_zero_of_consumption_diverges
    (fun n (_ : Unit) => M.cumulative n) ()
  simp only [Survival.MartingaleConvergenceBridge.retentionProcess] at key
  apply key
  simp only [ConstantRateModel.cumulative]
  exact Filter.Tendsto.atTop_mul_const hpos tendsto_natCast_atTop_atTop

/-- **Persistence regime**: non-positive stationary rate implies
    retention stays bounded away from zero.

    l̄ ≤ 0  ⟹  L_n ≤ 0  ⟹  exp(-L_n) ≥ 1

    (In the net-recovery case, retention actually grows.) -/
theorem persistence_of_nonpositive_rate (M : ConstantRateModel)
    (hnonpos : M.rate ≤ 0) (n : ℕ) :
    1 ≤ constantRateRetention M n := by
  unfold constantRateRetention ConstantRateModel.cumulative
  rw [Real.one_le_exp_iff]
  have : (↑n : ℝ) * M.rate ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (Nat.cast_nonneg n) hnonpos
  linarith

/-- **Boundary regime**: zero rate means retention is identically 1. -/
theorem boundary_of_zero_rate (M : ConstantRateModel)
    (hzero : M.rate = 0) (n : ℕ) :
    constantRateRetention M n = 1 := by
  unfold constantRateRetention ConstantRateModel.cumulative
  rw [hzero]
  simp

/-! ## Part 4: Rate Sign Determines Structural Fate -/

/-- The complete ergodic trichotomy: the sign of the stationary
    consumption rate determines whether the system collapses,
    persists at the boundary, or recovers. -/
theorem ergodic_trichotomy (M : ConstantRateModel) :
    (0 < M.rate → Filter.Tendsto (fun n => constantRateRetention M n)
        Filter.atTop (nhds 0)) ∧
    (M.rate = 0 → ∀ n, constantRateRetention M n = 1) ∧
    (M.rate < 0 → ∀ n, 1 ≤ constantRateRetention M n) :=
  ⟨fun h => collapse_of_positive_rate M h,
   fun h => boundary_of_zero_rate M h,
   fun h n => persistence_of_nonpositive_rate M (le_of_lt h) n⟩

end

end Survival.ErgodicRateBridge
