import Survival.CoarseGraining

/-!
# Admissible-Map Compatibility

This module gives reader-facing names for the narrow compatibility layer of an
admissible coarse map.

It deliberately proves only the exact-compatibility case:

* the initial feasible region commutes with the coarse map;
* the whole feasible trajectory commutes;
* the contracted and repaired intermediate regions commute;
* under uniform mass scaling, the signed kernel is preserved exactly.

It does **not** claim that every coarse map is admissible, nor does it prove an
unconditional coarse-graining DPI.  Defect-controlled coarse-graining belongs to
`SaturationDefect` and later admissible-map work.
-/

namespace Survival.AdmissibleMapCompatibility

open Survival.GeneralStateDynamics
open Survival.CoarseGraining

noncomputable section

variable {X Y : Type*}
variable {P : ProblemSpec X} {Q : ProblemSpec Y}

/-- Reader-facing alias for the exact admissible coarse-map compatibility
package. -/
abbrev CompatibleCoarseMap (P : ProblemSpec X) (Q : ProblemSpec Y) :=
  AdmissibleCoarseGraining P Q

/-- The initial feasible region is compatible by definition. -/
theorem initial_region_commutes (cg : CompatibleCoarseMap P Q) :
    cg.map.pushSet P.V0 = Q.V0 :=
  cg.initial_commutes

/-- The full feasible trajectory commutes with an admissible coarse map. -/
theorem feasible_trajectory_commutes (cg : CompatibleCoarseMap P Q) :
    ∀ n, cg.map.pushSet (feasible P n) = feasible Q n :=
  feasible_commutes cg

/-- The contracted intermediate region commutes along the feasible trajectory. -/
theorem contraction_commutes_along_trajectory
    (cg : CompatibleCoarseMap P Q) (t : ℕ) :
    cg.map.pushSet (contracted P t) = contracted Q t :=
  contracted_commutes' cg t

/-- The repaired intermediate region commutes along the feasible trajectory. -/
theorem repair_commutes_along_trajectory
    (cg : CompatibleCoarseMap P Q) (t : ℕ) :
    cg.map.pushSet (repaired P t) = repaired Q t :=
  repaired_commutes cg t

/-- The one-step update itself commutes along the feasible trajectory. -/
theorem step_commutes_along_trajectory
    (cg : CompatibleCoarseMap P Q) (t : ℕ) :
    cg.map.pushSet (step P t (feasible P t)) =
      step Q t (feasible Q t) := by
  simpa [step, repaired, contracted] using repair_commutes_along_trajectory cg t

/-- Under uniform mass scaling, the one-step contraction loss is preserved. -/
theorem step_loss_preserved_of_uniform_mass_scaling
    (cg : CompatibleCoarseMap P Q)
    (hs : UniformMassScaling cg)
    (t : ℕ)
    (hfeas : 0 < feasibleMass P t) :
    stepLoss Q t = stepLoss P t :=
  stepLoss_preserved cg hs t hfeas

/-- Under uniform mass scaling, the one-step repair gain is preserved. -/
theorem step_gain_preserved_of_uniform_mass_scaling
    (cg : CompatibleCoarseMap P Q)
    (hs : UniformMassScaling cg)
    (t : ℕ)
    (hcontract : 0 < contractedMass P t) :
    stepGain Q t = stepGain P t :=
  stepGain_preserved cg hs t hcontract

/-- Under uniform mass scaling, the one-step signed kernel is preserved. -/
theorem step_net_action_preserved_of_uniform_mass_scaling
    (cg : CompatibleCoarseMap P Q)
    (hs : UniformMassScaling cg)
    (t : ℕ)
    (hfeas : 0 < feasibleMass P t)
    (hcontract : 0 < contractedMass P t)
    (hnext : 0 < feasibleMass P (t + 1)) :
    stepNetAction Q t = stepNetAction P t :=
  stepNetAction_preserved cg hs t hfeas hcontract hnext

/-- Under uniform mass scaling, the cumulative signed kernel is preserved. -/
theorem cumulative_net_action_preserved_of_uniform_mass_scaling
    (cg : CompatibleCoarseMap P Q)
    (hs : UniformMassScaling cg)
    (n : ℕ)
    (hpos : PositiveTrajectory P n) :
    cumulativeNetAction Q n = cumulativeNetAction P n :=
  cumulativeNetAction_preserved cg hs n hpos

end

end Survival.AdmissibleMapCompatibility
