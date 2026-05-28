import Survival.CollapseTimeBound
import Survival.StochasticCollapseTimeBound
import Survival.SupermartingaleRetentionBridge

/-!
# Ruin Theory Bridge — Cramér-Lundberg Correspondence

This module establishes the structural isomorphism between ruin theory
(Cramér-Lundberg model) and structural persistence theory.

## Correspondence

| Ruin Theory | Structural Persistence |
|---|---|
| Surplus u(t) = u + ct - S(t) | Structural margin M - B_n |
| Claim process S(t) | Cumulative contraction loss L_n |
| Premium rate c | Repair rate (resource inflow) |
| Safety loading ρ = c/λμ - 1 | Repair slack / safety margin |
| Ruin probability ψ(u) | Collapse probability P[S ≤ 0] |
| Adjustment coefficient R | Minimum structural consumption rate |
| Lundberg bound ψ(u) ≤ exp(-Ru) | Retention bound exp(-B_n) |
| Ruin time τ | Collapse time (hitting time) |

References:
  - Cramér, H. (1930). On the mathematical theory of risk.
  - Lundberg, F. (1903). Approximerad framställning av
    sannolikhetsfunktionen.
  - CollapseTimeBound.lean, MinimumRepairRate.lean
-/

namespace Survival.RuinTheoryBridge

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.CollapseTimeBound
open Survival.MinimumRepairRate
open Survival.MartingaleConvergenceBridge

noncomputable section

variable {X : Type*}

/-! ## Part 1: Surplus Process -/

/-- The structural surplus at time n: initial reserve plus cumulative
repair cost minus cumulative contraction loss.

In ruin theory: u(t) = u₀ + c·t - S(t).
Here: surplus_n = M₀ + cumulativeCost - cumulativeLoss. -/
def surplus {P : ProblemSpec X} (B : RepairBudget P)
    (initialReserve : ℝ) (n : ℕ) : ℝ :=
  initialReserve + cumulativeCost B n - cumulativeLoss P n

/-- Initial surplus equals the initial reserve. -/
theorem surplus_zero {P : ProblemSpec X} (B : RepairBudget P)
    (u₀ : ℝ) : surplus B u₀ 0 = u₀ := by
  unfold surplus cumulativeCost cumulativeLoss
  simp

/-- Surplus one-step recursion:
surplus_{n+1} = surplus_n + (stepCost - stepLoss).

In ruin theory: u(t+1) = u(t) + premium - claim. -/
theorem surplus_succ {P : ProblemSpec X} (B : RepairBudget P)
    (u₀ : ℝ) (n : ℕ) :
    surplus B u₀ (n + 1) =
      surplus B u₀ n + (B.stepCost n - stepLoss P n) := by
  unfold surplus cumulativeCost cumulativeLoss
  rw [Finset.sum_range_succ, Finset.sum_range_succ]
  ring

/-! ## Part 2: Safety Loading -/

/-- The safety loading condition: average repair rate exceeds
average contraction loss. In ruin theory: c > λμ (net profit).

Under this condition, the surplus drifts upward on average. -/
def HasPositiveSafetyLoading {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) : Prop :=
  cumulativeLoss P n < cumulativeCost B n

/-- Positive safety loading implies positive surplus growth. -/
theorem surplus_growth_of_safety_loading
    {P : ProblemSpec X} (B : RepairBudget P)
    (u₀ : ℝ) (n : ℕ)
    (hsafe : HasPositiveSafetyLoading B n) :
    u₀ < surplus B u₀ n := by
  unfold surplus HasPositiveSafetyLoading at *
  linarith

/-! ## Part 3: Lundberg Bound = Retention Bound -/

/-- **Lundberg inequality (algebraic form).**

If B_n ≥ B_0 (net consumption is nondecreasing from initial),
then exp(-B_n) ≤ exp(-B_0).

This is the algebraic core of the Lundberg bound: higher
cumulative consumption reduces the retention factor. -/
theorem lundberg_algebraic_bound
    (b₀ bₙ : ℝ) (hB : b₀ ≤ bₙ) :
    Real.exp (-bₙ) ≤ Real.exp (-b₀) :=
  Real.exp_le_exp.mpr (by linarith)

/-! ## Part 4: Ruin Time = Collapse Time -/

/-- Structural ruin occurs when feasible mass drops below a threshold.
This is exactly `CollapsedAtFraction` from CollapseTimeBound. -/
def StructuralRuin (P : ProblemSpec X) (n : ℕ) (θ : ℝ) : Prop :=
  CollapsedAtFraction P n θ

/-- The collapse time bound gives a sufficient condition for
structural ruin, which corresponds to the ruin time bound
in Cramér-Lundberg theory. -/
theorem ruin_of_excess_consumption
    (P : ProblemSpec X) (n : ℕ)
    (hpos : PositiveTrajectory P n)
    {θ : ℝ} (hθ : 0 < θ)
    (hnet : -Real.log θ ≤ cumulativeNetAction P n) :
    StructuralRuin P n θ :=
  collapsedAtFraction_of_cumulativeNetAction_lower_bound
    P n hpos hθ hnet

/-! ## Part 5: Dictionary -/

/-- Surplus = initial reserve + cumulative repair slack.
This connects surplus to the total production decomposition. -/
theorem surplus_decomposition
    {P : ProblemSpec X} (B : RepairBudget P)
    (u₀ : ℝ) (n : ℕ) :
    surplus B u₀ n = u₀ + (cumulativeCost B n - cumulativeLoss P n) := by
  unfold surplus
  ring

end

end Survival.RuinTheoryBridge
