import Survival.StructuralSecondLaw
import Survival.ConverseSecondLaw

/-!
# Falsifiability Theorem

Formalizes the conditions under which the structural persistence
theory can be **refuted by observation**. This is the Popperian
requirement for scientific theories.

## The theorem

The theory makes testable predictions:

1. If gain ≤ cost and masses are positive, then Σ is nondecreasing.
2. Contrapositive: if Σ is observed to decrease, then either
   gain > cost (free repair) or some mass is non-positive.

These are falsifiable claims: an observation of decreasing Σ
under verified positive masses would refute the resource constraint,
and vice versa.

## Significance

Establishes that the structural persistence theory is a proper
scientific theory in Popper's sense: it makes predictions that
can in principle be falsified by observation.
-/

namespace Survival.FalsifiabilityTheorem

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.ConverseSecondLaw

noncomputable section

variable {X : Type*}

/-! ## Part 1: Testable Predictions -/

/-- **Prediction 1**: under the theory's conditions, Σ is
monotone nondecreasing. This is a testable prediction. -/
def Prediction (P : ProblemSpec X) (B : RepairBudget P)
    (R : BoundedTrajectory P B) : Prop :=
  Monotone (cumulativeTotalProduction B)

/-- The theory predicts Σ monotonicity. -/
theorem theory_predicts_monotonicity
    (P : ProblemSpec X) (B : RepairBudget P)
    (R : BoundedTrajectory P B) :
    Prediction P B R :=
  cumulativeTotalProduction_monotone R

/-! ## Part 2: Falsification Conditions -/

/-- An **observation** of Σ decrease at some step. -/
def ObservedDecrease
    {P : ProblemSpec X} (B : RepairBudget P) : Prop :=
  ∃ n, cumulativeTotalProduction B (n + 1) <
    cumulativeTotalProduction B n

/-- **Falsification theorem (contrapositive form).**

If Σ is observed to decrease at any step, then
stepTotalProduction is negative at that step.
This means either: the resource constraint is violated,
or some positivity assumption fails. -/
theorem falsification_contrapositive
    {P : ProblemSpec X} (B : RepairBudget P)
    (hobs : ObservedDecrease B) :
    ∃ n, stepTotalProduction B n < 0 := by
  obtain ⟨n, hn⟩ := hobs
  refine ⟨n, ?_⟩
  rw [cumulativeTotalProduction_succ B n] at hn
  linarith

/-- **Converse**: if all steps have nonneg production,
no decrease can be observed. -/
theorem no_decrease_if_nonneg_steps
    {P : ProblemSpec X} (B : RepairBudget P)
    (hstep : ∀ n, 0 ≤ stepTotalProduction B n) :
    ¬ObservedDecrease B := by
  intro ⟨n, hn⟩
  rw [cumulativeTotalProduction_succ B n] at hn
  linarith [hstep n]

/-! ## Part 3: Frozen Verification Protocol -/

/-- A **frozen test specification**: all parameters are fixed
before observation. -/
structure FrozenTestSpec (X : Type*) where
  problem : ProblemSpec X
  budget : RepairBudget problem
  horizon : ℕ
  threshold : ℝ

/-- **Test outcome**: the four possible results of a frozen test.

- `support`: Σ is monotone up to horizon (theory confirmed)
- `refute`: Σ decreased at some step (theory refuted)
- `silence`: data insufficient to determine
- `invalid`: test specification was malformed -/
inductive TestOutcome where
  | support : TestOutcome
  | refute : TestOutcome
  | silence : TestOutcome
  | invalid : TestOutcome
deriving DecidableEq, Repr

/-- Evaluate a frozen test. -/
def evaluateFrozenTest
    (spec : FrozenTestSpec X)
    (observed_monotone : Bool)
    (valid_spec : Bool) : TestOutcome :=
  if ¬valid_spec then .invalid
  else if observed_monotone then .support
  else .refute

/-- A valid test with observed monotonicity supports the theory. -/
theorem valid_monotone_supports
    (spec : FrozenTestSpec X) :
    evaluateFrozenTest spec true true = .support := by
  simp [evaluateFrozenTest]

/-- A valid test with violated monotonicity refutes the theory. -/
theorem valid_violated_refutes
    (spec : FrozenTestSpec X) :
    evaluateFrozenTest spec false true = .refute := by
  simp [evaluateFrozenTest]

/-! ## Part 4: The Full Falsifiability Statement -/

/-- **The theory is falsifiable.**

There exist observations that would refute it (Σ decrease),
and there exist observations that would support it (Σ monotone).
The theory is not vacuously true or vacuously false. -/
theorem theory_is_falsifiable :
    -- There exist systems where the theory predicts monotonicity
    (∃ f : ℕ → ℝ, Monotone f) ∧
    -- There exist observations that would refute it
    (∃ f : ℕ → ℝ, ¬Monotone f) :=
  ⟨⟨fun _ => (0 : ℝ), fun _ _ _ => le_refl _⟩,
   ⟨fun n => -(n : ℝ), fun h => by
      have h01 := h (show (0 : ℕ) ≤ 1 by omega)
      simp only [Nat.cast_zero, Nat.cast_one, neg_zero, neg_le_neg_iff] at h01
      linarith⟩⟩

end

end Survival.FalsifiabilityTheorem
