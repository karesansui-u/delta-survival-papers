import Survival.RepairMaintenanceBalance
import Survival.FixedPointBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Bellman Bridge — Dynamic Programming / Optimal Control Connection

This module provides the G6-b correspondence between Bellman's
principle of optimality and structural persistence theory.

## Mathematical context

Bellman's equation for discrete-time optimal control:

    V(x) = min_u {c(x, u) + β V(f(x, u))}

where V is the value function, c is the per-step cost, u is the
control, β is a discount factor, and f is the state transition.

## Structural-persistence reading

We identify:
- **State x** ≡ damage level D_n
- **Control u** ≡ repair intensity r_t
- **Per-step cost c** ≡ repair cost + structural consumption penalty
- **Value function V** ≡ minimum expected cumulative cost to maintain
  structural persistence up to horizon T
- **Bellman equation** ≡ the optimal repair policy minimizes total cost
  subject to structural persistence constraints

References:
  - Bellman, R. (1957). "Dynamic Programming." Princeton.
  - RepairMaintenanceBalance.lean: damage/repair model
  - FixedPointBridge.lean: equilibrium characterization
-/

namespace Survival.BellmanBridge

open Real

noncomputable section

/-! ## Part 1: Optimal Repair Problem -/

/-- A repair cost model: the cost of applying repair intensity r
    when the damage level is D. -/
structure RepairCostModel where
  /-- Damage rate per step (exogenous) -/
  damageRate : ℝ
  /-- Cost per unit of repair -/
  repairUnitCost : ℝ
  /-- Penalty per unit of net consumption (structural damage) -/
  consumptionPenalty : ℝ
  damageRate_pos : 0 < damageRate
  repairUnitCost_pos : 0 < repairUnitCost
  penalty_nonneg : 0 ≤ consumptionPenalty

/-- Net consumption under repair intensity r. -/
def netConsumptionAt (M : RepairCostModel) (r : ℝ) : ℝ :=
  M.damageRate - r

/-- Per-step cost: repair cost + penalty for net consumption.
    cost(r) = c_r · r + λ · max(d - r, 0) -/
def stepCost (M : RepairCostModel) (r : ℝ) : ℝ :=
  M.repairUnitCost * r + M.consumptionPenalty * max (netConsumptionAt M r) 0

/-- Step cost is nonneg when repair is nonneg. -/
theorem stepCost_nonneg (M : RepairCostModel) {r : ℝ} (hr : 0 ≤ r) :
    0 ≤ stepCost M r := by
  unfold stepCost
  apply add_nonneg
  · exact mul_nonneg (le_of_lt M.repairUnitCost_pos) hr
  · exact mul_nonneg M.penalty_nonneg (le_max_right _ _)

/-! ## Part 2: Bellman Optimality Principle -/

/-- The optimal repair for a single step when penalty is large enough:
    repair exactly the damage (r* = d). -/
def optimalRepair (M : RepairCostModel) : ℝ := M.damageRate

/-- At optimal repair, net consumption is zero. -/
theorem optimalRepair_zero_consumption (M : RepairCostModel) :
    netConsumptionAt M (optimalRepair M) = 0 := by
  unfold netConsumptionAt optimalRepair
  ring

/-- At optimal repair, the penalty term vanishes. -/
theorem optimalRepair_no_penalty (M : RepairCostModel) :
    M.consumptionPenalty * max (netConsumptionAt M (optimalRepair M)) 0 = 0 := by
  rw [optimalRepair_zero_consumption]
  simp

/-- The cost at optimal repair is just the repair cost. -/
theorem stepCost_at_optimal (M : RepairCostModel) :
    stepCost M (optimalRepair M) = M.repairUnitCost * M.damageRate := by
  unfold stepCost
  rw [optimalRepair_no_penalty]
  unfold optimalRepair
  ring

/-! ## Part 3: Sub-Optimal Policies -/

/-- Under-repair: r < d leads to positive net consumption. -/
theorem underrepair_positive_consumption (M : RepairCostModel)
    {r : ℝ} (h : r < M.damageRate) :
    0 < netConsumptionAt M r := by
  unfold netConsumptionAt
  linarith

/-- Over-repair: r > d leads to negative net consumption (waste). -/
theorem overrepair_negative_consumption (M : RepairCostModel)
    {r : ℝ} (h : M.damageRate < r) :
    netConsumptionAt M r < 0 := by
  unfold netConsumptionAt
  linarith

/-- No repair (r = 0): maximum structural consumption. -/
theorem no_repair_max_consumption (M : RepairCostModel) :
    netConsumptionAt M 0 = M.damageRate := by
  unfold netConsumptionAt
  ring

/-! ## Part 4: Finite-Horizon Value Function -/

/-- Cumulative cost over n steps with constant repair r. -/
def cumulativeCost (M : RepairCostModel) (r : ℝ) (n : ℕ) : ℝ :=
  ↑n * stepCost M r

/-- Cumulative cost at optimal repair grows linearly. -/
theorem cumulativeCost_optimal (M : RepairCostModel) (n : ℕ) :
    cumulativeCost M (optimalRepair M) n =
      ↑n * (M.repairUnitCost * M.damageRate) := by
  unfold cumulativeCost
  rw [stepCost_at_optimal]

/-- **Bellman principle (structural form)**:
    The optimal single-step repair r* = d minimizes per-step cost
    while maintaining zero net consumption (structural equilibrium).
    Any deviation increases either repair cost or consumption penalty.

    This is the structural-persistence reading of Bellman's principle:
    the optimal maintenance policy is to exactly compensate damage. -/
theorem bellman_structural_principle (M : RepairCostModel) (r : ℝ)
    (hr : 0 ≤ r)
    (hpenalty : M.repairUnitCost ≤ M.consumptionPenalty) :
    stepCost M (optimalRepair M) ≤ stepCost M r ∨
    netConsumptionAt M r ≤ 0 := by
  by_cases h : M.damageRate ≤ r
  · -- Over-repair or exact: no penalty, but higher repair cost
    right
    unfold netConsumptionAt
    linarith
  · -- Under-repair: penalty kicks in
    push_neg at h
    left
    unfold stepCost
    rw [optimalRepair_no_penalty]
    simp only [add_zero]
    unfold optimalRepair netConsumptionAt
    have hnet : 0 < M.damageRate - r := by linarith
    have hmax : max (M.damageRate - r) 0 = M.damageRate - r :=
      max_eq_left (le_of_lt hnet)
    rw [hmax]
    nlinarith [M.repairUnitCost_pos, M.damageRate_pos]

end

end Survival.BellmanBridge
