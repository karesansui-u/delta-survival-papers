import Survival.GeneralStateDynamics
import Survival.ResourceBoundedDynamics
import Survival.MinimumRepairRate

/-!
# Hamilton-Jacobi-Bellman Bridge — Optimal Control Correspondence

Establishes the correspondence between stochastic optimal control
(Hamilton-Jacobi-Bellman equation) and structural persistence.

## Correspondence

| HJB / Optimal Control | Structural Persistence |
|---|---|
| State x(t) | Feasible mass m(V^(t)) |
| Control u(t) | Repair strategy (r_t allocation) |
| Cost function g(x, u) | Step total production Σ_t |
| Value function V(x) | Structural persistence potential S |
| Bellman equation | Σ recursion: Σ_{n+1} = Σ_n + step_n |
| Optimal policy u*(x) | Minimum-cost repair strategy |
| Running cost | Step contraction loss d_t |
| Terminal cost | -ln(θ) collapse threshold |

The key insight: the Bellman recursion for cumulative total production
IS the discrete HJB equation. The value function (= structural
persistence potential S) satisfies the same optimality principle.
-/

namespace Survival.HJBBridge

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.MinimumRepairRate

noncomputable section

variable {X : Type*}

/-! ## Part 1: Bellman Recursion = Σ Recursion -/

/-- **Bellman recursion (structural form).**

The cumulative total production satisfies:
Σ_{n+1} = Σ_n + step_n

This IS the discrete Bellman equation where:
- "state" = cumulative Σ
- "running cost" = one-step total production
- "transition" = additive increment -/
theorem bellman_recursion
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B (n + 1) =
      cumulativeTotalProduction B n +
        stepTotalProduction B n :=
  cumulativeTotalProduction_succ B n

/-! ## Part 2: Value Function = Persistence Potential -/

/-- The **structural value function**: the maximum retention factor
achievable from the current state, given the remaining budget.

V(n) = sup over repair strategies of exp(-B_N) starting from
state at time n. Since we work with a fixed budget, V(n) is
simply the retention exp(-B_n) under the given strategy. -/
def valueFunction (P : ProblemSpec X) (n : ℕ) : ℝ :=
  feasibleMass P n

/-- The value function satisfies the Bellman equation:
V(n+1) = V(n) * exp(-b_n).

In HJB terms: V(x_{n+1}) = V(x_n) · transition_factor. -/
theorem value_bellman
    (P : ProblemSpec X) (t : ℕ)
    (hfeas : 0 < feasibleMass P t)
    (hcontract : 0 < contractedMass P t)
    (hnext : 0 < feasibleMass P (t + 1)) :
    valueFunction P (t + 1) =
      valueFunction P t *
        Real.exp (-stepNetAction P t) := by
  unfold valueFunction
  exact feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction
    P t hfeas hcontract hnext

/-! ## Part 3: Optimal Repair = Minimum Cost -/

/-- **Minimum repair cost theorem (HJB form).**

To maintain structural persistence above threshold θ by time n,
the cumulative repair cost must be at least L_n + ln θ.

This IS the HJB sufficient condition: the "control cost"
(repair budget) must exceed the "running cost" (contraction loss)
minus the "terminal value" (ln θ). -/
theorem hjb_minimum_cost
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hretain : θ * feasibleMass P 0 ≤ feasibleMass P n) :
    cumulativeLoss P n + Real.log θ ≤ cumulativeCost B n :=
  cumulativeCost_lower_bound_of_mass_retention B n hpos hθ hretain

/-! ## Part 4: Optimality Principle -/

/-- **Bellman optimality principle (structural form).**

The structural second law implies that total production is
monotone. Under this constraint, the optimal repair strategy
minimizes total production while maintaining persistence.

Since Σ = L + slack and slack ≥ 0, the optimum is achieved
when slack = 0 (exact payment: each repair costs exactly
what it recovers). -/
theorem optimal_is_exact_payment
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hexact : ∀ t, B.stepCost t = stepGain P t) :
    cumulativeTotalProduction B n = cumulativeLoss P n :=
  cumulativeTotalProduction_eq_cumulativeLoss_of_exact_payment
    B n hexact

/-- Under exact payment, total production = contraction loss.
This is the minimum possible total production (Σ = L, slack = 0).
Any other budget has Σ ≥ L. -/
theorem exact_payment_is_minimum
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeLoss P n ≤ cumulativeTotalProduction B n :=
  cumulativeLoss_le_cumulativeTotalProduction B n

/-! ## Part 5: Dynamic Programming Decomposition -/

/-- **Stage-wise decomposition**: the total cost decomposes into
a sum of per-stage costs, each of which can be optimized
locally. This is Bellman's principle of optimality.

Σ_n = Σ_{t=0}^{n-1} (stepLoss_t + stepSlack_t). -/
theorem dynamic_programming_decomposition
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeLoss P n + cumulativeRepairSlack B n :=
  cumulativeTotalProduction_eq_cumulativeLoss_add_cumulativeRepairSlack
    B n

end

end Survival.HJBBridge
