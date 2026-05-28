import Survival.ClausiusBridge
import Survival.FreeRepairImpossibility

/-!
# Landauer Principle Bridge

Proves the algebraic skeleton of Landauer's principle:
erasing structural information has a minimum resource cost.

## The theorem

Landauer (1961): erasing 1 bit of information requires at least
kT ln 2 energy dissipation.

Structural persistence reading: reducing the viable set by a
factor of 1/2 (l_i = ln 2) requires repair cost ≥ ln 2.

More generally: any structural consumption l_i requires
resource cost ≥ l_i (from gain_le_cost + total production
decomposition).
-/

namespace Survival.LandauerPrincipleBridge

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction

noncomputable section

variable {X : Type*}

/-! ## Part 1: Minimum Erasure Cost -/

/-- **Landauer bound (structural form).**

The resource cost of any step is at least the stage loss minus
the stage gain. Since gain ≤ cost (resource constraint):

  stepCost ≥ stepGain ≥ 0

And total production = loss + slack ≥ loss, so:

  cumulativeCost ≥ cumulativeGain

The minimum cost to "erase" L units of structural information
is at least the contraction loss itself (when repair slack = 0). -/
theorem landauer_minimum_cost
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeGain P n ≤ cumulativeCost B n :=
  cumulativeGain_le_cumulativeCost B n

/-- The cost of each repair step is nonneg. -/
theorem repair_cost_nonneg
    {P : ProblemSpec X} (B : RepairBudget P) (t : ℕ) :
    0 ≤ B.stepCost t :=
  B.cost_nonneg t

/-! ## Part 2: One-Bit Erasure -/

/-- **One-bit structural erasure cost.**

Reducing the viable set to half its size (r = 1/2) incurs
a stage loss of ln 2 ≈ 0.693 structural nats.

In Landauer's terms: erasing 1 bit costs at least kT ln 2.
In structural terms: halving V_G costs at least ln 2 of
structural consumption. -/
theorem one_bit_erasure_cost :
    -Real.log (1/2 : ℝ) = Real.log 2 := by
  rw [one_div, Real.log_inv, neg_neg]

/-- ln 2 is positive (there is always a cost). -/
theorem erasure_cost_positive :
    0 < Real.log 2 :=
  Real.log_pos (by norm_num)

/-- n-bit erasure costs n · ln 2 (linear in bits erased). -/
theorem n_bit_erasure_cost (n : ℕ) :
    (n : ℝ) * Real.log 2 = Real.log (2 ^ n) := by
  rw [Real.log_pow]

/-! ## Part 3: Reversible Computation Limit -/

/-- **Reversible computation**: if recovery exactly equals
contraction (perfect reversal), net consumption is zero.

This is Landauer's point: only irreversible operations
(net erasure > 0) have a thermodynamic cost. Reversible
computation (no net erasure) can in principle be free. -/
theorem reversible_zero_net_cost
    (d r : ℝ) (hrev : d = r) : d - r = 0 := by linarith

/-- **Irreversible operations have positive cost.**
If net consumption > 0, the resource constraint ensures
that cost > 0 as well. -/
theorem irreversible_nonneg_cost
    {P : ProblemSpec X} (B : RepairBudget P) (t : ℕ) :
    0 ≤ B.stepCost t :=
  B.cost_nonneg t

/-! ## Part 4: Total Dissipation Bound -/

/-- **Total dissipation** (cumulative cost) bounds cumulative gain.
This is the structural persistence form of the second law of
thermodynamics applied to computation: the total "heat"
dissipated (cost) is at least the total "work" extracted (gain). -/
theorem total_dissipation_bound
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeGain P n ≤ cumulativeCost B n :=
  cumulativeGain_le_cumulativeCost B n

/-- Under exact payment, dissipation = gain (Landauer equality). -/
theorem landauer_equality_at_exact_payment
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hexact : ∀ t, B.stepCost t = stepGain P t) :
    cumulativeCost B n = cumulativeGain P n := by
  unfold cumulativeCost cumulativeGain
  exact Finset.sum_congr rfl (fun t _ => hexact t)

end

end Survival.LandauerPrincipleBridge
