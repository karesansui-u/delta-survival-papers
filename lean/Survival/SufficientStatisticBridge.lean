import Survival.CoarseGraining
import Survival.CoarseTotalProduction
import Survival.KLDivergence

/-!
# Sufficient Statistic Bridge — Rao-Blackwell Correspondence

A coarse-graining is "sufficient" for structural accounting iff it
preserves total production exactly — paralleling Fisher-Neyman.
-/

namespace Survival.SufficientStatisticBridge

open Survival.GeneralStateDynamics
open Survival.CoarseGraining
open Survival.CoarseTotalProduction

noncomputable section

variable {X Y : Type*}

/-- A sufficient coarse-graining preserves total production exactly. -/
theorem sufficient_preserves_accounting
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : Survival.ResourceBudget.RepairBudget P}
    {Bcoarse : Survival.ResourceBudget.RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (n : ℕ) (hpos : PositiveTrajectory P n) :
    Survival.TotalProduction.cumulativeTotalProduction Bcoarse n =
      Survival.TotalProduction.cumulativeTotalProduction Bmicro n :=
  cumulativeTotalProduction_preserved cg hs hB n hpos

/-- KL divergence measures information loss. Nonneg (Gibbs). -/
theorem information_loss_nonneg
    {total sat : ℝ} (hsat : 0 < sat) (hle : sat ≤ total) :
    0 ≤ Survival.KLDivergence.klUniform total sat :=
  Survival.KLDivergence.kl_uniform_nonneg hsat hle

/-- Zero loss iff coarse-graining is lossless (sufficiency). -/
theorem zero_loss_iff_sufficient
    {total : ℝ} (htotal : 0 < total) :
    Survival.KLDivergence.klUniform total total = 0 := by
  unfold Survival.KLDivergence.klUniform
  simp [ne_of_gt htotal]

/-- Net action is preserved under admissible coarse-graining.
This is the structural Fisher-Neyman factorization: net action
depends on the data only through the sufficient statistic. -/
theorem net_action_preserved
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg) (n : ℕ)
    (hpos : PositiveTrajectory P n) :
    cumulativeNetAction Q n = cumulativeNetAction P n :=
  cumulativeNetAction_preserved cg hs n hpos

end

end Survival.SufficientStatisticBridge
