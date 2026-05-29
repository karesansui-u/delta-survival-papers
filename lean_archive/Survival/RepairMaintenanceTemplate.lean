import Survival.RepairMaintenanceBalance
import Survival.SecondLawTotalProduction
import Survival.ResourceBoundedStochasticCollapse

/-!
# Repair-Maintenance Template Wrappers

Phase 6.2 reader-facing wrappers for the third limited-class template.

This file deliberately adds no optimal-maintenance theorem, no stochastic
reliability theorem, no repair-policy theorem, and no unconditional repair
"second law".  It only gives stable names to the existing finite-prefix and
resource-bounded anchors:

* damage / repair amounts as finite-prefix net consumption;
* remaining margin and threshold crossing;
* repair as margin improvement relative to damage-only dynamics;
* `Σ = B + C = L + slack` as the resource-cost grammar;
* resource-bounded Azuma stopped/hitting certificates when a stochastic
  repair-maintenance step model is supplied.
-/

open scoped ProbabilityTheory
open MeasureTheory

namespace Survival.RepairMaintenanceTemplate

noncomputable section

/-- Phase 6.2 name: net consumption is damage minus repair. -/
theorem netConsumption_eq_damage_sub_repair
    (damage repair : ℕ → ℝ) (t : ℕ) :
    Survival.RepairMaintenanceBalance.netAction damage repair t =
      damage t - repair t := rfl

/-- Phase 6.2 name: cumulative net consumption obeys the finite-prefix
successor equation. -/
theorem cumulativeNetConsumption_succ
    (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair (n + 1) =
      Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n +
        Survival.RepairMaintenanceBalance.netAction damage repair n :=
  Survival.RepairMaintenanceBalance.cumulativeNetAction_succ damage repair n

/-- Phase 6.2 name: accumulated damage level is initial damage plus cumulative
net consumption. -/
theorem damageLevel_eq_initial_plus_cumulativeNetConsumption
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.damageLevel D0 damage repair n =
      D0 + Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n :=
  Survival.RepairMaintenanceBalance.damageLevel_eq_initial_plus_cumulative_net_action
    D0 damage repair n

/-- Phase 6.2 name: remaining margin is initial margin minus cumulative net
consumption. -/
theorem margin_eq_initial_margin_sub_cumulativeNetConsumption
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.margin B D0 damage repair n =
      (B - D0) - Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n :=
  Survival.RepairMaintenanceBalance.margin_eq_initial_margin_sub_cumulative_net_action
    B D0 damage repair n

/-- Phase 6.2 name: threshold crossing is equivalent to nonpositive remaining
margin. -/
theorem thresholdCrossed_iff_margin_nonpos
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.ThresholdCrossed B D0 damage repair n ↔
      Survival.RepairMaintenanceBalance.margin B D0 damage repair n ≤ 0 :=
  Survival.RepairMaintenanceBalance.thresholdCrossed_iff_margin_nonpos
    B D0 damage repair n

/-- Phase 6.2 name: cumulative net consumption exhausting the initial margin
forces threshold crossing. -/
theorem thresholdCrossed_of_initial_margin_le_cumulativeNetConsumption
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (h : B - D0 ≤
      Survival.RepairMaintenanceBalance.cumulativeNetAction damage repair n) :
    Survival.RepairMaintenanceBalance.ThresholdCrossed B D0 damage repair n :=
  Survival.RepairMaintenanceBalance.thresholdCrossed_of_initial_margin_le_cumulativeNetAction
    B D0 damage repair n h

/-- Phase 6.2 name: the exponential maintenance coordinate has the local
signed-action update. -/
theorem relativeMaintenance_succ_eq_mul_exp_neg_netConsumption
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    Survival.RepairMaintenanceBalance.relativeMaintenance D0 damage repair (n + 1) =
      Survival.RepairMaintenanceBalance.relativeMaintenance D0 damage repair n *
        Real.exp (-(Survival.RepairMaintenanceBalance.netAction damage repair n)) :=
  Survival.RepairMaintenanceBalance.relativeMaintenance_succ_eq_mul_exp_neg_netAction
    D0 damage repair n

/-- Nonnegative repair means net consumption is bounded above by raw damage. -/
theorem netConsumption_le_damage_of_repair_nonneg
    (damage repair : ℕ → ℝ) (t : ℕ)
    (hrepair : 0 ≤ repair t) :
    Survival.RepairMaintenanceBalance.netAction damage repair t ≤ damage t :=
  Survival.RepairMaintenanceBalance.netAction_le_damage_of_repair_nonneg
    damage repair t hrepair

/-- If repair covers damage at a step, that step's net consumption is
nonpositive. -/
theorem netConsumption_nonpos_of_damage_le_repair
    (damage repair : ℕ → ℝ) (t : ℕ)
    (hcover : damage t ≤ repair t) :
    Survival.RepairMaintenanceBalance.netAction damage repair t ≤ 0 :=
  Survival.RepairMaintenanceBalance.netAction_nonpos_of_damage_le_repair
    damage repair t hcover

/-- Nonnegative repair keeps the finite-prefix damage level below the
damage-only process. -/
theorem damageLevel_le_damageOnlyLevel_of_repair_nonneg
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : ∀ t, 0 ≤ repair t) :
    Survival.RepairMaintenanceBalance.damageLevel D0 damage repair n ≤
      Survival.RepairMaintenanceBalance.damageOnlyLevel D0 damage n :=
  Survival.RepairMaintenanceBalance.damageLevel_le_damageOnlyLevel_of_repair_nonneg
    D0 damage repair n hrepair

/-- Nonnegative repair improves the finite-prefix remaining margin relative to
the damage-only process. -/
theorem damageOnlyMargin_le_margin_of_repair_nonneg
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : ∀ t, 0 ≤ repair t) :
    Survival.RepairMaintenanceBalance.damageOnlyMargin B D0 damage n ≤
      Survival.RepairMaintenanceBalance.margin B D0 damage repair n :=
  Survival.RepairMaintenanceBalance.damageOnlyMargin_le_margin_of_repair_nonneg
    B D0 damage repair n hrepair

open Survival.GeneralStateDynamics
open Survival.ResourceBudget
open Survival.TotalProduction

/-- Phase 6.2 name for the resource-cost grammar `Σ_n = B_n + C_n`.

This is the same total-production interface used by the Bernoulli and
Foster-Lyapunov templates.  It does not by itself identify a stochastic repair
policy; that identification is supplied by a concrete `RepairBudget`. -/
theorem sigma_equals_B_plus_C {X : Type*} {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeNetAction P n + cumulativeCost B n :=
  Survival.SecondLawTotalProduction.sigma_equals_B_plus_C B n

/-- Phase 6.2 name for the decomposition `Σ_n = L_n + repair_slack_n`. -/
theorem sigma_equals_L_plus_repair_slack {X : Type*} {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeTotalProduction B n =
      cumulativeLoss P n + cumulativeRepairSlack B n :=
  Survival.SecondLawTotalProduction.sigma_equals_L_plus_repair_slack B n

/-- Phase 6.2 name: budgeted total production dominates contraction loss. -/
theorem sigma_at_least_L {X : Type*} {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ) :
    cumulativeLoss P n ≤ cumulativeTotalProduction B n :=
  Survival.SecondLawTotalProduction.sigma_at_least_L B n

/-- Phase 6.2 name: exact payment collapses `Σ` to contraction loss. -/
theorem sigma_equals_L_under_exact_payment {X : Type*} {P : ProblemSpec X}
    (B : RepairBudget P) (n : ℕ)
    (hexact : ∀ t, B.stepCost t = stepGain P t) :
    cumulativeTotalProduction B n = cumulativeLoss P n :=
  Survival.SecondLawTotalProduction.sigma_equals_L_under_exact_payment
    B n hexact

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}

open Survival.StochasticTotalProduction
open Survival.ResourceBoundedStochasticCollapse

/-- Phase 6.2 v0: when a repair-maintenance stochastic step model satisfies the
resource-bounded Azuma interface, expected cumulative `Σ` is monotone.

The theorem is intentionally stated through the generic step-model interface:
it is a certificate route for supplied repair-maintenance dynamics, not a
claim that every repair system satisfies the assumptions. -/
theorem repairMaintenance_resourceBoundedExpectedSigma_monotone
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S) :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone (μ := μ) A

/-- Phase 6.2 v0: terminal expected-margin stopped-collapse certificate for a
resource-bounded repair-maintenance step model. -/
theorem repairMaintenance_stoppedCollapseWithFailureBound_of_expectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    Survival.StoppingTimeHighProbabilityCollapse.StoppedCollapseWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) N r) :=
  stoppedCollapseWithFailureBound_of_expectedMargin (μ := μ) A hθ hmargin

/-- Phase 6.2 v0: initial expected-margin stopped-collapse certificate for a
resource-bounded repair-maintenance step model. -/
theorem repairMaintenance_stoppedCollapseWithFailureBound_of_initialExpectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeHighProbabilityCollapse.StoppedCollapseWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) N r) :=
  stoppedCollapseWithFailureBound_of_initialExpectedMargin
    (μ := μ) A hθ hmargin₀

/-- Phase 6.2 v0: direct hitting-time event certificate with a margin at
`k < N`, under the resource-bounded repair-maintenance step-model interface. -/
theorem repairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    Survival.StoppingTimeCollapseEvent.HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
    (μ := μ) A hkN hmargin

/-- Phase 6.2 v0: initial expected-margin version of the direct hitting-time
event certificate. -/
theorem repairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    {S : StepModel (μ := μ)}
    (A : ResourceBoundedStepModelAzuma (μ := μ) S)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀ :
      -Real.log θ ≤ S.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeCollapseEvent.HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) S.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds A.incrementBound) k r) :=
  hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin
    (μ := μ) A hkN hmargin₀

open Survival.CoarseStochasticTotalProduction

/-- Phase 6.2 v0: high-probability stopped-collapse transfer from a micro
expected-margin statement to a resource-bounded coarse repair-maintenance
model, under explicit stochastic compatibility.

This is conditional coarse transfer, not an unconditional coarse-graining DPI. -/
theorem coarseRepairMaintenance_stoppedCollapseWithFailureBound_of_microExpectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin_micro :
      -Real.log θ ≤
        Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    Survival.StoppingTimeHighProbabilityCollapse.StoppedCollapseWithFailureBound
      (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          Acoarse.incrementBound) N r) :=
  coarse_stoppedCollapseWithFailureBound_of_micro_expectedMargin
    (μ := μ) hcomp Acoarse hθ hmargin_micro

/-- Phase 6.2 v0: initial-margin version of the high-probability coarse
stopped-collapse transfer. -/
theorem coarseRepairMaintenance_stoppedCollapseWithFailureBound_of_microInitialMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {N : ℕ} {θ r : ℝ} (hθ : 0 < θ)
    (hmargin₀_micro :
      -Real.log θ ≤
        Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeHighProbabilityCollapse.StoppedCollapseWithFailureBound
      (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          Acoarse.incrementBound) N r) :=
  coarse_stoppedCollapseWithFailureBound_of_micro_initialExpectedMargin
    (μ := μ) hcomp Acoarse hθ hmargin₀_micro

/-- Phase 6.2 v0: direct hitting-time coarse transfer under explicit stochastic
compatibility and a resource-bounded coarse step model. -/
theorem coarseRepairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_microExpectedMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin_micro :
      -Real.log θ ≤
        Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    Survival.StoppingTimeCollapseEvent.HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          Acoarse.incrementBound) k r) :=
  coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_expectedMargin
    (μ := μ) hcomp Acoarse hkN hmargin_micro

/-- Phase 6.2 v0: initial-margin direct hitting-time coarse transfer. -/
theorem coarseRepairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_microInitialMargin
    {Smicro Scoarse : StepModel (μ := μ)}
    (hcomp : CoarseStochasticCompatibility (μ := μ) Smicro Scoarse)
    (Acoarse : ResourceBoundedStepModelAzuma (μ := μ) Scoarse)
    {k N : ℕ} (hkN : k < N)
    {θ r : ℝ}
    (hmargin₀_micro :
      -Real.log θ ≤
        Smicro.toStochasticProcess.toExpectedProcess.expectedCumulative 0 - r) :
    Survival.StoppingTimeCollapseEvent.HittingTimeBeforeHorizonWithFailureBound
      (μ := μ) Scoarse.toStochasticProcess N θ
      (Survival.AzumaHoeffding.azumaHoeffdingFailureBound
        (Survival.BoundedAzumaConstruction.varianceProxyOfBounds
          Acoarse.incrementBound) k r) :=
  coarse_hittingTimeBeforeHorizonWithFailureBound_of_micro_initialExpectedMargin
    (μ := μ) hcomp Acoarse hkN hmargin₀_micro

end

end Survival.RepairMaintenanceTemplate
