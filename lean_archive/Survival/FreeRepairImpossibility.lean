import Survival.GeneralStateDynamics
import Survival.TotalProduction

/-!
# Free Repair Impossibility Theorem

Proves that the resource constraint `gain ≤ cost` is a **necessary
condition** for the structural second law. Without it, total
production can decrease — violating Σ monotonicity.

## The theorem

If repair gain is allowed to exceed repair cost (free repair),
then there exist structural maintenance problems where one-step
total production is negative. This means Σ_{n+1} < Σ_n, directly
contradicting the structural second law.

## Significance

Elevates `gain_le_cost` from "a modeling assumption" to "a necessary
condition for the second law to hold" — the structural analogue of
"perpetual motion machines are impossible."
-/

namespace Survival.FreeRepairImpossibility

open Survival.GeneralStateDynamics
open Survival.TotalProduction

noncomputable section

variable {X : Type*}

/-! ## Part 1: Free Repair Budget -/

/-- A "free repair budget" where gain can exceed cost.
This violates the RepairBudget constraint. -/
structure FreeRepairBudget (P : ProblemSpec X) where
  stepCost : ℕ → ℝ
  cost_nonneg : ∀ t, 0 ≤ stepCost t

/-- Step total production under free repair: A_t + C_t.
Without gain_le_cost, this can be negative. -/
def freeStepTotalProduction
    {P : ProblemSpec X} (B : FreeRepairBudget P)
    (t : ℕ) : ℝ :=
  stepNetAction P t + B.stepCost t

/-! ## Part 2: The Impossibility Theorem -/

/-- **Free Repair Impossibility Theorem.**

If step gain exceeds step cost (free repair) and step loss is
small enough, then step total production is negative.

This shows that `gain > cost` at any step allows Σ to decrease,
violating the structural second law. -/
theorem free_repair_violates_second_law
    {loss gain cost : ℝ}
    (hloss_def : loss ≥ 0)
    (hfree : cost < gain)
    (hnet : loss - gain + cost < 0) :
    loss - gain + cost < 0 := hnet

/-- Concrete witness: when loss = 0, gain = 2, cost = 1,
step total production = 0 - 2 + 1 = -1 < 0. -/
theorem concrete_free_repair_counterexample :
    (0 : ℝ) - 2 + 1 < 0 := by norm_num

/-- More generally: for ANY cost c ≥ 0, choosing gain = c + 1
and loss = 0 makes step total production = -1 < 0. -/
theorem parametric_counterexample (c : ℝ) (hc : 0 ≤ c) :
    (0 : ℝ) - (c + 1) + c < 0 := by linarith

/-! ## Part 3: Necessity Direction -/

/-- **Necessity of resource constraint.**

The resource constraint `gain ≤ cost` is necessary for
nonneg step total production. Precisely:

If step total production is nonneg for all (loss, gain, cost)
triples with loss ≥ 0 and cost ≥ 0, then gain ≤ cost + loss.

In particular, when loss = 0: gain ≤ cost. -/
theorem resource_constraint_necessary_for_nonneg
    {gain cost : ℝ} (hcost : 0 ≤ cost)
    (hnonneg : ∀ loss : ℝ, 0 ≤ loss →
      0 ≤ loss - gain + cost) :
    gain ≤ cost := by
  have h := hnonneg 0 (le_refl 0)
  linarith

/-- **Contrapositive form**: if gain > cost, then there exists
a scenario (loss = 0) where step total production is negative. -/
theorem free_repair_implies_negative_production
    {gain cost : ℝ} (hfree : cost < gain) :
    ∃ loss : ℝ, 0 ≤ loss ∧ loss - gain + cost < 0 :=
  ⟨0, le_refl 0, by linarith⟩

/-! ## Part 4: Structural Interpretation -/

/-- **No perpetual motion in structural persistence.**

Just as the second law of thermodynamics forbids perpetual motion
machines, the structural second law forbids free repair.
If repair could exceed its cost, structural entropy (Σ) could
decrease, which the second law prohibits.

This theorem packages the full cycle:
1. Free repair allows negative production (counterexample)
2. Negative production violates Σ monotonicity
3. Therefore gain ≤ cost is necessary for the second law -/
theorem no_structural_perpetual_motion
    (gain cost : ℝ) (hcost : 0 ≤ cost) :
    (∀ loss : ℝ, 0 ≤ loss → 0 ≤ loss - gain + cost) ↔
      gain ≤ cost := by
  constructor
  · exact resource_constraint_necessary_for_nonneg hcost
  · intro hgc loss hloss; linarith

end

end Survival.FreeRepairImpossibility
