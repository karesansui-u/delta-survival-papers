import Survival.GeneralStateDynamics
import Survival.LyapunovBalanceEmbedding
import Survival.RepairMaintenanceBalance

/-!
# Structural Persistence Balance Principle

Reader-facing Lean wrappers for Paper 3, "Structural Persistence Balance Principle and Collapse
Tendency".

This file deliberately adds no new mathematical substance.  The pathwise balance
exponential kernel is proved in `Survival.GeneralStateDynamics`; the
Foster--Lyapunov algebraic embedding is proved in
`Survival.LyapunovBalanceEmbedding`; and the repair / maintenance finite-prefix
skeleton is proved in `Survival.RepairMaintenanceBalance`.

The purpose of this module is naming: it gives Paper 3 a single Lean entry point
whose theorem names match the paper-level claims.  It does not formalize
domain-natural choice of `m`, empirical observability of `r_t`, positive
recurrence, geometric ergodicity, or any universal-law claim.
-/

open scoped BigOperators
open Survival.GeneralStateDynamics

namespace Survival.StructuralPersistenceBalancePrinciple

noncomputable section

variable {X : Type*}

/-- Paper 3 name for the general finite state-dynamics specification. -/
abbrev StructuralSystem (X : Type*) := ProblemSpec X

/-- Paper 3 name for the positivity assumptions needed by the log-ratio kernel. -/
abbrev PositiveFiniteTrajectory (P : StructuralSystem X) (n : ℕ) :=
  PositiveTrajectory P n

/-- Paper 3 notation: one-step balance is structural consumption minus recovery. -/
theorem oneStepBalance_eq_consumption_sub_recovery
    (P : StructuralSystem X) (t : ℕ) :
    stepNetAction P t = stepLoss P t - stepGain P t := rfl

/-- Paper 3 notation: cumulative balance is the finite-prefix sum of one-step
balances. -/
theorem cumulativeBalance_eq_sum_oneStepBalance
    (P : StructuralSystem X) (n : ℕ) :
    cumulativeNetAction P n =
      ∑ t ∈ Finset.range n, stepNetAction P t := rfl

/-- Paper 3 local balance identity, checked under positive finite-trajectory
assumptions. -/
theorem local_exponential_balance
    (P : StructuralSystem X) (t : ℕ)
    (hfeas : 0 < feasibleMass P t)
    (hcontract : 0 < contractedMass P t)
    (hnext : 0 < feasibleMass P (t + 1)) :
    feasibleMass P (t + 1) =
      feasibleMass P t * Real.exp (-(stepNetAction P t)) :=
  feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction P t hfeas hcontract hnext

/-- Paper 3 pathwise balance exponential kernel. -/
theorem pathwise_balance_exponential_kernel
    (P : StructuralSystem X) (n : ℕ)
    (hpos : PositiveFiniteTrajectory P n) :
    feasibleMass P n =
      feasibleMass P 0 * Real.exp (-(cumulativeNetAction P n)) :=
  feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction P n hpos

/-- Pure contraction has zero repair gain at each step. -/
theorem pureContraction_stepGain_eq_zero
    (P : StructuralSystem X) (t : ℕ)
    (hpure : PureContraction P.D)
    (hcontract : 0 < contractedMass P t) :
    stepGain P t = 0 :=
  stepGain_eq_zero_of_pureContraction P t hpure hcontract

/-- In pure contraction mode the cumulative balance reduces to cumulative loss. -/
theorem pureContraction_cumulativeBalance_eq_cumulativeLoss
    (P : StructuralSystem X) (n : ℕ)
    (hpure : PureContraction P.D)
    (hpos : PositiveFiniteTrajectory P n) :
    cumulativeNetAction P n = cumulativeLoss P n :=
  cumulativeNetAction_eq_cumulativeLoss_of_pureContraction P n hpure hpos

/-- Paper 1/2 loss-only kernel recovered as the pure-contraction special case. -/
theorem pureContraction_recovers_loss_only_kernel
    (P : StructuralSystem X) (n : ℕ)
    (hpure : PureContraction P.D)
    (hpos : PositiveFiniteTrajectory P n) :
    feasibleMass P n =
      feasibleMass P 0 * Real.exp (-(cumulativeLoss P n)) :=
  feasibleMass_eq_initial_mul_exp_neg_cumulativeLoss_of_pureContraction P n hpure hpos

/-- Foster--Lyapunov/load increments decompose as structural consumption amount
minus recovery amount. -/
theorem lyapunov_increment_eq_consumptionAmount_sub_recoveryAmount
    (Z : ℕ → ℝ) (t : ℕ) :
    Survival.LyapunovBalanceEmbedding.increment Z t =
      Survival.LyapunovBalanceEmbedding.consumptionAmount Z t -
        Survival.LyapunovBalanceEmbedding.recoveryAmount Z t :=
  Survival.LyapunovBalanceEmbedding.increment_eq_consumptionAmount_sub_recoveryAmount Z t

/-- Foster--Lyapunov cumulative load increment telescopes to final load minus
initial load. -/
theorem lyapunov_cumulativeAction_eq_load_diff
    (Z : ℕ → ℝ) (n : ℕ) :
    Survival.LyapunovBalanceEmbedding.cumulativeAction Z n = Z n - Z 0 :=
  Survival.LyapunovBalanceEmbedding.cumulativeAction_eq_load_diff Z n

/-- Foster--Lyapunov local balance in the exponential maintenance coordinate. -/
theorem lyapunov_relativeMaintenance_local_balance
    (Z : ℕ → ℝ) (t : ℕ) :
    Survival.LyapunovBalanceEmbedding.relativeMaintenance Z (t + 1) =
      Survival.LyapunovBalanceEmbedding.relativeMaintenance Z t *
        Real.exp (-(Survival.LyapunovBalanceEmbedding.increment Z t)) :=
  Survival.LyapunovBalanceEmbedding.relativeMaintenance_succ_eq_mul_exp_neg_increment Z t

/-- Repair / maintenance finite-prefix damage balance. -/
theorem repair_damageLevel_eq_initial_plus_cumulative_balance
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.damageLevel D0 damage repair n =
      D0 + Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n :=
  Survival.RepairMaintenanceBalance.damageLevel_eq_initial_plus_cumulative_net_action
    D0 damage repair n

/-- Remaining margin is threshold minus accumulated damage.  This is a margin
coordinate, not the Paper 1 resource term `M`. -/
theorem repair_remainingMargin_eq_initial_margin_sub_cumulative_balance
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.margin B D0 damage repair n =
      (B - D0) - Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n :=
  Survival.RepairMaintenanceBalance.margin_eq_initial_margin_sub_cumulative_net_action
    B D0 damage repair n

/-- Repair / maintenance local balance in the exponential maintenance
coordinate. -/
theorem repair_relativeMaintenance_local_balance
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.relativeMaintenance D0 damage repair (n + 1) =
      Survival.RepairMaintenanceBalance.relativeMaintenance D0 damage repair n *
        Real.exp (-(Survival.RepairMaintenanceBalance.netAction damage repair n)) :=
  Survival.RepairMaintenanceBalance.relativeMaintenance_succ_eq_mul_exp_neg_netAction
    D0 damage repair n

/-- Threshold crossing is equivalent to nonpositive remaining margin. -/
theorem repair_thresholdCrossed_iff_remainingMargin_nonpos
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.ThresholdCrossed B D0 damage repair n ↔
      Survival.RepairMaintenanceBalance.margin B D0 damage repair n ≤ 0 :=
  Survival.RepairMaintenanceBalance.thresholdCrossed_iff_margin_nonpos
    B D0 damage repair n

/-- Nonnegative repair improves the finite-prefix remaining margin relative to
the damage-only process. -/
theorem repair_nonnegative_flow_improves_remainingMargin
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : ∀ t, 0 ≤ repair t) :
    Survival.RepairMaintenanceBalance.damageOnlyMargin B D0 damage n ≤
      Survival.RepairMaintenanceBalance.margin B D0 damage repair n :=
  Survival.RepairMaintenanceBalance.damageOnlyMargin_le_margin_of_repair_nonneg
    B D0 damage repair n hrepair

end

end Survival.StructuralPersistenceBalancePrinciple
