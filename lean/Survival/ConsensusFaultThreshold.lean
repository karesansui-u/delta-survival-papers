import Mathlib.Algebra.BigOperators.Ring.Finset

/-!
# Consensus Fault-Threshold Skeleton

This module formalizes the Route A bridge example A25 at a finite-prefix
threshold level.  It does not prove a concrete Byzantine agreement theorem.
Instead, it records the operational skeleton:

`cumulativeFaults_n = sum_{i < n} newFaults_i`.

Consensus is possible while cumulative faults stay within a finite fault
budget, and fails once the cumulative count exceeds that budget.
-/

open scoped BigOperators

namespace Survival.ConsensusFaultThreshold

/-- Finite-prefix distributed-system fault model. -/
structure System where
  faultIncrement : ℕ → ℕ
  faultBudget : ℕ

/-- Accumulated faulty nodes / fault events over the first `n` steps. -/
def cumulativeFaults (S : System) (n : ℕ) : ℕ :=
  ∑ i ∈ Finset.range n, S.faultIncrement i

/-- Consensus is still within the tolerated fault budget. -/
def ConsensusPossible (S : System) (n : ℕ) : Prop :=
  cumulativeFaults S n ≤ S.faultBudget

/-- Consensus has crossed the tolerated fault budget. -/
def ConsensusFailed (S : System) (n : ℕ) : Prop :=
  S.faultBudget < cumulativeFaults S n

@[simp] theorem cumulativeFaults_zero (S : System) :
    cumulativeFaults S 0 = 0 := by
  simp [cumulativeFaults]

/-- One more prefix step adds exactly the newly faulty count at that step. -/
theorem cumulativeFaults_succ (S : System) (n : ℕ) :
    cumulativeFaults S (n + 1) =
      cumulativeFaults S n + S.faultIncrement n := by
  unfold cumulativeFaults
  rw [Finset.sum_range_succ]

/-- With zero processed steps, consensus is still possible. -/
theorem consensusPossible_zero (S : System) :
    ConsensusPossible S 0 := by
  simp [ConsensusPossible]

/-- Cumulative faults are monotone under appending more steps. -/
theorem cumulativeFaults_le_cumulativeFaults_add_steps
    (S : System) (n k : ℕ) :
    cumulativeFaults S n ≤ cumulativeFaults S (n + k) := by
  induction k with
  | zero =>
      simp
  | succ k ih =>
      have hstep :
          cumulativeFaults S (n + k) ≤ cumulativeFaults S ((n + k) + 1) := by
        rw [cumulativeFaults_succ]
        exact Nat.le_add_right _ _
      have hstep' :
          cumulativeFaults S (n + k) ≤ cumulativeFaults S (n + (k + 1)) := by
        simpa [Nat.add_assoc] using hstep
      exact le_trans ih hstep'

/-- Crossing the fault budget is exactly the failure predicate. -/
theorem consensusFailed_of_budget_lt_cumulativeFaults
    (S : System) (n : ℕ)
    (hcross : S.faultBudget < cumulativeFaults S n) :
    ConsensusFailed S n := by
  exact hcross

/-- Being within the fault budget is exactly the possible predicate. -/
theorem consensusPossible_of_cumulativeFaults_le_budget
    (S : System) (n : ℕ)
    (hwithin : cumulativeFaults S n ≤ S.faultBudget) :
    ConsensusPossible S n := by
  exact hwithin

/-- In the finite-prefix skeleton, possible and failed are complementary
threshold readings. -/
theorem consensusPossible_iff_not_consensusFailed
    (S : System) (n : ℕ) :
    ConsensusPossible S n ↔ ¬ ConsensusFailed S n := by
  unfold ConsensusPossible ConsensusFailed
  constructor
  · intro hwithin hfail
    exact Nat.lt_irrefl _ (lt_of_lt_of_le hfail hwithin)
  · intro hnot
    exact le_of_not_gt hnot

/-- Once failure has occurred, the possible predicate is false. -/
theorem not_consensusPossible_of_consensusFailed
    (S : System) (n : ℕ)
    (hfail : ConsensusFailed S n) :
    ¬ ConsensusPossible S n := by
  rw [consensusPossible_iff_not_consensusFailed]
  exact not_not.mpr hfail

/-- Constant fault-arrival specialization. -/
structure ConstantFaultSystem where
  perStepFaults : ℕ
  faultBudget : ℕ

/-- The constant fault-arrival model as a general fault stream. -/
def ConstantFaultSystem.toSystem (C : ConstantFaultSystem) : System where
  faultIncrement := fun _ => C.perStepFaults
  faultBudget := C.faultBudget

/-- Constant per-step faults accumulate linearly. -/
theorem cumulativeFaults_toSystem_eq_mul
    (C : ConstantFaultSystem) (n : ℕ) :
    cumulativeFaults C.toSystem n = n * C.perStepFaults := by
  unfold cumulativeFaults ConstantFaultSystem.toSystem
  simp

/-- If the linear accumulated faults exceed the budget, consensus fails. -/
theorem consensusFailed_of_budget_lt_mul
    (C : ConstantFaultSystem) (n : ℕ)
    (hcross : C.faultBudget < n * C.perStepFaults) :
    ConsensusFailed C.toSystem n := by
  unfold ConsensusFailed
  rw [cumulativeFaults_toSystem_eq_mul]
  exact hcross

/-- The one-new-fault-per-step specialization. -/
def oneFaultPerStep (faultBudget : ℕ) : ConstantFaultSystem where
  perStepFaults := 1
  faultBudget := faultBudget

/-- With one new fault per step, cumulative faults equal elapsed steps. -/
theorem cumulativeFaults_oneFaultPerStep_eq
    (faultBudget n : ℕ) :
    cumulativeFaults (oneFaultPerStep faultBudget).toSystem n = n := by
  rw [cumulativeFaults_toSystem_eq_mul]
  change n * 1 = n
  exact Nat.mul_one n

/-- With one new fault per step, exceeding the budget in time implies failure. -/
theorem consensusFailed_oneFaultPerStep_of_budget_lt_steps
    {faultBudget n : ℕ}
    (hcross : faultBudget < n) :
    ConsensusFailed (oneFaultPerStep faultBudget).toSystem n := by
  unfold ConsensusFailed
  rw [cumulativeFaults_oneFaultPerStep_eq]
  exact hcross

end Survival.ConsensusFaultThreshold
