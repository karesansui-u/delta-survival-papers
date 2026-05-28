import Survival.CoarseGraining
import Survival.CoarseTotalProduction
import Survival.ResourceBoundedDynamics

/-!
# Renormalization Group Bridge

The coarse-graining layer IS a discrete renormalization group.
The structural second law's coarse-graining invariance IS the
statement that the RG flow preserves the law of tendency.
-/

namespace Survival.RenormalizationBridge

open Survival.GeneralStateDynamics
open Survival.CoarseGraining
open Survival.CoarseTotalProduction
open Survival.ResourceBoundedDynamics

noncomputable section

variable {X Y : Type*}

/-- An RG step is an admissible coarse-graining. -/
abbrev RGStep (P : ProblemSpec X) (Q : ProblemSpec Y) :=
  AdmissibleCoarseGraining P Q

/-- A problem is an RG fixed point if self-coarse-graining
preserves total production exactly. -/
def IsRGFixedPoint
    {P : ProblemSpec X}
    (cg : AdmissibleCoarseGraining P P)
    (hs : UniformMassScaling cg)
    {Bmicro Bcoarse : Survival.ResourceBudget.RepairBudget P}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (n : ℕ) (hpos : PositiveTrajectory P n) : Prop :=
  Survival.TotalProduction.cumulativeTotalProduction Bcoarse n =
    Survival.TotalProduction.cumulativeTotalProduction Bmicro n

/-- Admissible coarse-graining preserves total production.
In RG language: the effective theory is exactly preserved. -/
theorem admissible_is_fixed_point
    {P : ProblemSpec X}
    (cg : AdmissibleCoarseGraining P P)
    (hs : UniformMassScaling cg)
    {Bmicro Bcoarse : Survival.ResourceBudget.RepairBudget P}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (n : ℕ) (hpos : PositiveTrajectory P n) :
    IsRGFixedPoint cg hs hB n hpos :=
  cumulativeTotalProduction_preserved cg hs hB n hpos

/-- **RG invariance of the structural second law.**
If micro total production is monotone, coarse total production
is also monotone. The law of tendency is an RG invariant. -/
theorem rg_preserves_monotonicity
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg)
    {Bmicro : Survival.ResourceBudget.RepairBudget P}
    {Bcoarse : Survival.ResourceBudget.RepairBudget Q}
    (hB : CostInvariantBudget Bmicro Bcoarse)
    (R : BoundedTrajectory P Bmicro) :
    Monotone (Survival.TotalProduction.cumulativeTotalProduction
      Bcoarse) :=
  coarse_cumulativeTotalProduction_monotone cg hs hB R

/-- Net action is RG-invariant: it does not change under
admissible coarse-graining. -/
theorem rg_invariant_net_action
    {P : ProblemSpec X} {Q : ProblemSpec Y}
    (cg : AdmissibleCoarseGraining P Q)
    (hs : UniformMassScaling cg) (n : ℕ)
    (hpos : PositiveTrajectory P n) :
    cumulativeNetAction Q n = cumulativeNetAction P n :=
  cumulativeNetAction_preserved cg hs n hpos

end

end Survival.RenormalizationBridge
