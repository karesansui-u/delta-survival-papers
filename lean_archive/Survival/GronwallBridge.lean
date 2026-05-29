import Survival.GeneralStateDynamics
import Survival.ResourceBoundedDynamics

/-!
# Gronwall Inequality Bridge

Establishes that the structural persistence equation
m(V^(n)) = m(V^(0)) exp(-B_n) is a discrete Gronwall inequality.

## Correspondence

| Gronwall / ODE Theory | Structural Persistence |
|---|---|
| y'(t) ≤ -λ(t)y(t) + r(t) | m_{n+1} = m_n · exp(-b_n) |
| y(t) ≤ y(0) exp(-∫λ ds) | m(V^n) ≤ m(V^0) exp(-L_n) |
| Gronwall: y(t) ≤ u(t) | feasibleMass ≤ initial · exp(-net) |
| Comparison principle | monotonicity of Σ |

The key insight: the telescoping exponential identity IS a discrete
Gronwall inequality. The structural second law IS the Gronwall
comparison principle applied to total production.
-/

namespace Survival.GronwallBridge

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics

noncomputable section

variable {X : Type*}

/-! ## Part 1: Discrete Gronwall Inequality -/

/-- **Discrete Gronwall inequality (structural form).**

Given a sequence y_n with y_{n+1} ≤ y_n · exp(a_n), we have
y_n ≤ y_0 · exp(Σ a_i).

The structural persistence kernel m(V^n) = m(V^0) exp(-B_n)
is the equality case of this inequality. -/
theorem discrete_gronwall
    (y : ℕ → ℝ) (a : ℕ → ℝ)
    (hy0 : 0 < y 0)
    (hstep : ∀ n, y (n + 1) ≤ y n * Real.exp (a n))
    (n : ℕ) :
    y n ≤ y 0 * Real.exp (∑ i ∈ Finset.range n, a i) := by
  induction n with
  | zero => simp
  | succ n ih =>
      calc y (n + 1)
          ≤ y n * Real.exp (a n) := hstep n
        _ ≤ (y 0 * Real.exp (∑ i ∈ Finset.range n, a i)) *
              Real.exp (a n) := by
            exact mul_le_mul_of_nonneg_right ih (Real.exp_nonneg _)
        _ = y 0 * (Real.exp (∑ i ∈ Finset.range n, a i) *
              Real.exp (a n)) := by ring
        _ = y 0 * Real.exp
              ((∑ i ∈ Finset.range n, a i) + a n) := by
            rw [Real.exp_add]
        _ = y 0 * Real.exp
              (∑ i ∈ Finset.range (n + 1), a i) := by
            rw [Finset.sum_range_succ]

/-- The structural persistence kernel is the Gronwall equality case:
when each step is exact (not just an inequality). -/
theorem structural_kernel_is_gronwall_equality
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P n) :
    feasibleMass P n =
      feasibleMass P 0 *
        Real.exp (-cumulativeNetAction P n) :=
  feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n hpos

/-! ## Part 2: Comparison Principle -/

/-- **Gronwall comparison principle (structural form).**

If net consumption B_n ≥ B_n' (system consumes more), then
exp(-B_n) ≤ exp(-B_n') (retention is lower).

This is the comparison principle: a harder environment
leads to faster structural decay. -/
theorem gronwall_comparison
    {b₁ b₂ : ℝ} (hb : b₁ ≤ b₂) :
    Real.exp (-b₂) ≤ Real.exp (-b₁) :=
  Real.exp_le_exp.mpr (by linarith)

/-- Comparison corollary: more consumption at each step
leads to lower retention at every time. -/
theorem pointwise_comparison
    (b₁ b₂ : ℕ → ℝ)
    (hstep : ∀ t, b₁ t ≤ b₂ t) (n : ℕ) :
    ∑ t ∈ Finset.range n, b₁ t ≤
      ∑ t ∈ Finset.range n, b₂ t :=
  Finset.sum_le_sum (fun t _ => hstep t)

/-! ## Part 3: Stability via Gronwall -/

/-- **Gronwall stability**: if per-step consumption is bounded by α,
then retention decays at most as exp(-nα).

This gives a structural stability bound: the decay rate is
controlled by the worst-case per-step consumption. -/
theorem gronwall_stability_bound
    (P : ProblemSpec X) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {α : ℝ} (hα : ∀ t, t < n → stepNetAction P t ≤ α) :
    feasibleMass P 0 *
      Real.exp (-(n : ℝ) * α) ≤
      feasibleMass P 0 *
        Real.exp (-cumulativeNetAction P n) := by
  apply mul_le_mul_of_nonneg_left _ (le_of_lt (hpos.feasible_pos 0 (Nat.zero_le n)))
  apply Real.exp_le_exp.mpr
  have hsum : cumulativeNetAction P n ≤ (n : ℝ) * α := by
    unfold cumulativeNetAction
    calc ∑ t ∈ Finset.range n, stepNetAction P t
        ≤ ∑ _ ∈ Finset.range n, α :=
          Finset.sum_le_sum (fun t ht =>
            hα t (Finset.mem_range.mp ht))
      _ = (n : ℝ) * α := by
          rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  linarith

end

end Survival.GronwallBridge
