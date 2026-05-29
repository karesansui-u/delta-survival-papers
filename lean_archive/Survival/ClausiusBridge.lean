import Survival.StructuralSecondLaw
import Survival.CrooksFluctuationBridge

/-!
# Clausius Bridge — Thermodynamic Second Law Direct Connection

Establishes the formal algebraic isomorphism between the structural
second law (Σ monotone nondecreasing) and the Clausius formulation
of the thermodynamic second law (entropy is nondecreasing).

## Isomorphism

| Clausius / Thermodynamics | Structural Persistence |
|---|---|
| Entropy S_thermo | Total production Σ_n |
| dS ≥ 0 (isolated) | Σ_{n+1} ≥ Σ_n |
| dS = dQ/T + σ_irr | Σ = L + slack (loss + repair slack) |
| σ_irr ≥ 0 | repair slack ≥ 0 |
| Reversible: σ_irr = 0 | Exact payment: slack = 0, Σ = L |
| Free energy F = U - TS | S = M exp(-L) |
| ΔF ≤ -W | retention ≤ initial × exp(-net) |

The structural second law IS a discrete Clausius inequality.
-/

namespace Survival.ClausiusBridge

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction
open Survival.ResourceBoundedDynamics
open Survival.CrossClassUnificationV3
open Survival.StructuralSecondLaw

noncomputable section

variable {X : Type*}

/-! ## Part 1: Clausius = Structural Second Law -/

/-- **Clausius inequality (structural form).**

Total production (structural entropy) is nondecreasing.
This IS the Clausius inequality ΔS ≥ 0 in discrete time. -/
theorem clausius_inequality
    (C : StructuralMaintenanceClass X) (n : ℕ) :
    cumulativeTotalProduction C.budget n ≤
      cumulativeTotalProduction C.budget (n + 1) :=
  deterministic_second_law_step C n

/-- Clausius monotonicity over arbitrary intervals. -/
theorem clausius_monotone
    (C : StructuralMaintenanceClass X) :
    Monotone (cumulativeTotalProduction C.budget) :=
  deterministic_second_law C

/-! ## Part 2: Entropy Production Decomposition -/

/-- **Entropy production decomposition (structural form).**

Σ = L + slack, where L is contraction loss (irreversible
structural consumption) and slack is repair overhead.

This parallels: dS = dQ/T + σ_irr where σ_irr ≥ 0. -/
theorem entropy_production_decomposition
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeLoss P n + cumulativeRepairSlack B n :=
  cumulativeTotalProduction_eq_cumulativeLoss_add_cumulativeRepairSlack
    B n

/-- The irreversible part (repair slack) is nonneg.
This IS σ_irr ≥ 0 in Clausius. -/
theorem irreversible_production_nonneg
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ) :
    0 ≤ cumulativeRepairSlack B n :=
  cumulativeRepairSlack_nonneg B n

/-- Contraction loss is bounded by total entropy production.
This IS L ≤ Σ, i.e., structural loss never exceeds total
entropy production. -/
theorem loss_bounded_by_entropy
    (C : StructuralMaintenanceClass X) (n : ℕ) :
    cumulativeLoss C.problem n ≤
      cumulativeTotalProduction C.budget n :=
  loss_bounded_by_sigma C n

/-! ## Part 3: Reversibility -/

/-- **Reversible process (structural form).**

Under exact payment (each repair gain equals its cost),
total production collapses to contraction loss alone.
The irreversible overhead vanishes.

This parallels: reversible process → σ_irr = 0 → dS = dQ/T. -/
theorem reversible_clausius
    {P : ProblemSpec X} (B : RepairBudget P) (n : ℕ)
    (hexact : ∀ t, B.stepCost t = stepGain P t) :
    cumulativeTotalProduction B n = cumulativeLoss P n :=
  cumulativeTotalProduction_eq_cumulativeLoss_of_exact_payment
    B n hexact

/-! ## Part 4: Free Energy Reading -/

/-- **Structural free energy.**

The feasible mass m(V^n) = m(V^0) exp(-B_n) is the structural
analogue of the Boltzmann factor exp(-βF). The net consumption
B_n plays the role of βΔF.

Higher B_n → lower feasible mass → structural decay.
This parallels: higher free energy difference → less available work. -/
theorem structural_free_energy
    (P : ProblemSpec X) (n : ℕ) (hpos : PositiveTrajectory P n) :
    feasibleMass P n =
      feasibleMass P 0 *
        Real.exp (-cumulativeNetAction P n) :=
  feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n hpos

/-- Under the structural second law, the exponential factor
can only decrease (or stay constant). This IS the discrete
second law of thermodynamics: free energy can only decrease
(or stay constant) in an isolated system. -/
theorem retention_nonincreasing
    (P : ProblemSpec X) {n m : ℕ} (hnm : n ≤ m)
    (hpos : PositiveTrajectory P m)
    (hmono : cumulativeNetAction P n ≤ cumulativeNetAction P m) :
    feasibleMass P m ≤ feasibleMass P n := by
  rw [feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P m hpos,
      feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n
        (PositiveTrajectory.mk
          (fun t ht => hpos.feasible_pos t (le_trans ht hnm))
          (fun t ht => hpos.contracted_pos t (lt_of_lt_of_le ht hnm)))]
  apply mul_le_mul_of_nonneg_left _ (le_of_lt (hpos.feasible_pos 0 (Nat.zero_le m)))
  exact Real.exp_le_exp.mpr (by linarith)

end

end Survival.ClausiusBridge
