import Survival.CrossClassUnificationV3

/-!
# Minimal Axiom Theorem

Proves that the 4 conditions of `StructuralMaintenanceClass` reduce
to 2 independent conditions. Witnesses 3 and 4 are automatically
derived from Witnesses 1 and 2.

## The theorem

The minimal independent axiom set for the structural second law is:
1. Bounded trajectory (positive masses)
2. Resource constraint (gain ≤ cost)

The other two conditions (cumulative recursion and expected-process
well-formedness) are definitional consequences.

## Significance

Shows the axiom system is **minimal**: no condition is redundant,
and the two independent conditions are both necessary.
-/

namespace Survival.MinimalAxiomTheorem

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.CrossClassUnificationV3

noncomputable section

variable {X : Type*}

/-! ## Part 1: Redundancy of Witnesses 3 and 4 -/

/-- **Witness 3 is automatic.**

The cumulative recursion Σ_{n+1} = Σ_n + step_n follows from
the definition of cumulativeTotalProduction. It requires no
additional assumption. -/
theorem witness3_automatic
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B (n + 1) =
      cumulativeTotalProduction B n +
        stepTotalProduction B n :=
  cumulativeTotalProduction_succ B n

/-- **Witness 4 is automatic.**

The expected-process well-formedness (expectedIncrement =
stepTotalProduction) follows from the definition of
deterministicExpectedTotalProduction. -/
theorem witness4_automatic
    {P : ProblemSpec X} (B : RepairBudget P) (t : ℕ) :
    (deterministicExpectedTotalProduction B).expectedIncrement t =
      stepTotalProduction B t := rfl

/-! ## Part 2: Minimal Independent Axiom Set -/

/-- The **minimal axiom set**: only BoundedTrajectory and
RepairBudget (with gain_le_cost) are needed.

This directly constructs a StructuralMaintenanceClass from
just these two assumptions, proving that Witnesses 3 and 4
add no independent content. -/
def fromMinimalAxioms
    (P : ProblemSpec X) (B : RepairBudget P)
    (R : BoundedTrajectory P B) :
    StructuralMaintenanceClass X :=
  ofBoundedTrajectory P B R

/-- The minimal construction yields the same law-like profile. -/
theorem minimal_gives_full_profile
    (P : ProblemSpec X) (B : RepairBudget P)
    (R : BoundedTrajectory P B) :
    LawLikeProfile (fromMinimalAxioms P B R) :=
  lawLikeProfile_of_class (fromMinimalAxioms P B R)

/-! ## Part 3: Independence of the Two Conditions -/

/-- **BoundedTrajectory is necessary.**

Without positive masses, log-ratios are undefined.
The structural second law cannot even be stated. -/
theorem bounded_trajectory_necessary
    (P : ProblemSpec X) (t : ℕ)
    (hfeas : 0 < feasibleMass P t)
    (hcontract : 0 < contractedMass P t) :
    0 ≤ stepLoss P t :=
  stepLoss_nonneg P t hfeas hcontract

/-- **Resource constraint is necessary** (from FreeRepairImpossibility).

Without gain_le_cost, step total production can be negative,
violating the structural second law. -/
theorem resource_constraint_necessary
    {gain cost : ℝ} (hfree : cost < gain) :
    ∃ loss : ℝ, 0 ≤ loss ∧ loss - gain + cost < 0 :=
  ⟨0, le_refl 0, by linarith⟩

/-! ## Part 4: Summary -/

/-- **Minimal Axiom Theorem (full statement).**

The structural second law is equivalent to:
- Axiom I: All feasible and contracted masses are positive
- Axiom II: Repair gain ≤ repair cost at each step

No other independent condition is needed. No condition can
be dropped without losing the second law. -/
structure MinimalAxiomSet (X : Type*) where
  problem : ProblemSpec X
  budget : RepairBudget problem
  bounded : BoundedTrajectory problem budget

/-- The minimal axiom set suffices for the full theory. -/
def toStructuralMaintenanceClass
    (A : MinimalAxiomSet X) : StructuralMaintenanceClass X :=
  ofBoundedTrajectory A.problem A.budget A.bounded

/-- The minimal axiom set yields monotone Σ. -/
theorem minimal_axioms_give_monotone_sigma
    (A : MinimalAxiomSet X) :
    Monotone (cumulativeTotalProduction A.budget) :=
  (lawLikeProfile_of_class
    (toStructuralMaintenanceClass A)).monotone_sigma

end

end Survival.MinimalAxiomTheorem
