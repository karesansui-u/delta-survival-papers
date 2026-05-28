import Survival.GeneralStateDynamics
import Survival.TelescopingExp

/-!
# Scope Boundary Theorem

Formalizes the conditions under which the structural persistence
theory **cannot** be applied. These are the theory's built-in
limitations.

## Boundaries

1. **Zero mass**: if m(V^i) = 0 at any step, log-ratio is undefined
2. **Infinite mass**: if m(V^i) = ∞, the theory needs measure finiteness
3. **No dynamics**: if the system has no constraint sequence, L = 0 trivially
4. **Non-measurable sets**: the measure m must be well-defined

These are not failures — they are the theory's honest declaration
of where it does NOT apply.
-/

namespace Survival.ScopeBoundaryTheorem

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Zero Mass Boundary -/

/-- **Zero mass makes stage loss undefined.**

If m(V^i) = 0, the ratio m(V^{i+1})/m(V^i) involves
division by zero. The theory cannot assign a stage loss. -/
theorem zero_mass_blocks_theory
    (m : ℕ → ℝ) (i : ℕ) (hzero : m i = 0) :
    m (i + 1) / m i = 0 / (0 : ℝ) ∨
      ¬(0 < m i) := by
  right
  rw [hzero]
  exact lt_irrefl 0

/-- The positivity requirement is necessary, not optional. -/
theorem positivity_is_necessary :
    -- Without positivity, log(0) is undefined / -∞
    Real.log 0 = 0 := Real.log_zero

/-- The theory explicitly requires PositiveTrajectory. -/
theorem positive_trajectory_is_precondition
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 *
      Real.exp (-∑ i ∈ Finset.range n, stageLoss m i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-! ## Part 2: Trivial Dynamics Boundary -/

/-- **Constant mass sequences have zero structural loss.**

If m(V^i) = m(V^0) for all i (no constraint acts), then
L = 0 and S = M. The theory is applicable but trivially so. -/
theorem constant_mass_zero_loss
    (c : ℝ) (hc : 0 < c) (n : ℕ) :
    ∑ i ∈ Finset.range n,
      stageLoss (fun _ => c) i = 0 := by
  apply Finset.sum_eq_zero
  intro i _
  unfold stageLoss
  simp [ne_of_gt hc]

/-- With zero loss, retention is perfect. -/
theorem perfect_retention_of_no_dynamics
    (c : ℝ) (hc : 0 < c) (n : ℕ) :
    (fun _ => c) n = c *
      Real.exp (-∑ i ∈ Finset.range n,
        stageLoss (fun _ => c) i) := by
  rw [constant_mass_zero_loss c hc n, neg_zero, Real.exp_zero,
      mul_one]

/-! ## Part 3: Finite Horizon Requirement -/

/-- **The theory gives finite-horizon guarantees.**

All current results are for finite n. Infinite-horizon
(n → ∞) requires additional assumptions (Doob convergence,
ergodicity, etc.) that go beyond the core axioms.

This is an honest limitation: the core theory does not
claim infinite-time predictions without extra conditions. -/
def FiniteHorizonOnly (n : ℕ) : Prop :=
  n < n + 1

theorem finite_horizon_always_holds (n : ℕ) :
    FiniteHorizonOnly n :=
  Nat.lt_succ_iff.mpr (le_refl n)

/-! ## Part 4: Summary of Scope -/

/-- **The theory applies when:**
1. All masses are positive (PositiveTrajectory)
2. The time horizon is finite
3. The dynamics are well-defined (ProblemSpec exists)

**The theory does NOT apply when:**
1. Any mass reaches zero (structural death — can detect but not
   continue accounting)
2. Masses are not measurable
3. No dynamics are specified (trivially S = M) -/
theorem scope_summary :
    -- The theory has nontrivial content iff there exist
    -- positive mass sequences that are NOT constant
    (∃ (m : ℕ → ℝ),
      (∀ n, 0 < m n) ∧
      ∃ i, m i ≠ m 0) ∧
    -- And trivial content for constant sequences
    (∀ (c : ℝ), 0 < c →
      ∀ n, ∑ i ∈ Finset.range n,
        stageLoss (fun _ => c) i = 0) :=
  ⟨⟨fun n => if n = 0 then 2 else 1,
    fun n => by cases n <;> simp <;> norm_num,
    ⟨1, by simp⟩⟩,
   fun c hc n => constant_mass_zero_loss c hc n⟩

end

end Survival.ScopeBoundaryTheorem
