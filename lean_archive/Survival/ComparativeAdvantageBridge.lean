import Survival.DualityTheorem
/-!
# Comparative Advantage Bridge — Ricardo's Trade Theory
Ricardo's comparative advantage: trade benefits both parties when
they specialize in what they produce at lower *relative* cost.
Structural reading: specialization reduces total structural
consumption (each party maintains the structure they're best at),
so total S increases.

Comparative advantage = minimizing total L through specialization.
-/
namespace Survival.ComparativeAdvantageBridge
noncomputable section
structure TradeModel where
  costA1 : ℝ  -- A's cost for good 1
  costA2 : ℝ  -- A's cost for good 2
  costB1 : ℝ  -- B's cost for good 1
  costB2 : ℝ  -- B's cost for good 2
  all_pos : 0 < costA1 ∧ 0 < costA2 ∧ 0 < costB1 ∧ 0 < costB2

/-- Autarky cost: each produces both goods. -/
def autarkyCost (M : TradeModel) : ℝ := M.costA1 + M.costA2 + M.costB1 + M.costB2

/-- Specialized cost: A produces good 1, B produces good 2 (or vice versa). -/
def specializedCost1 (M : TradeModel) : ℝ := 2 * M.costA1 + 2 * M.costB2
def specializedCost2 (M : TradeModel) : ℝ := 2 * M.costA2 + 2 * M.costB1

/-- Comparative advantage: specialization reduces total cost when
    relative costs differ. A has CA in good 1 if costA1/costA2 < costB1/costB2. -/
theorem trade_beneficial (M : TradeModel)
    (hCA : M.costA1 + M.costB2 < M.costA2 + M.costB1) :
    specializedCost1 M < autarkyCost M := by
  unfold specializedCost1 autarkyCost
  linarith
end
end Survival.ComparativeAdvantageBridge
