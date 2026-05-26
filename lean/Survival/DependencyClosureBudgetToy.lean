import Mathlib.Data.Set.Card
import Survival.LLMEpistemicControlToy
import Survival.SoftwareEvidencePacketToy

/-!
# Dependency Closure Budget Toy

This module adds a quantitative reading of the dependency-localization
guardrails from `EvidencePacketBridge`.

The previous bridge proves that semantic invalidations are contained in the
checked dependency closure.  Here we add the finite-cardinality consequence:
on finite toy control surfaces, the number of invalidated surfaces is bounded
by the closure budget, by the touched repair budget, and by the whole surface
cardinality.

This is still a toy bridge result.  It does not verify real LLM semantics,
real program semantics, or a production detector.  It only says that once an
evidence dependency packet has a sound closure, the finite budget accounting
follows from the existing inclusion theorem.
-/

namespace Survival.DependencyClosureBudgetToy

open Survival.EvidencePacketBridge
open Survival.LLMEpistemicControlToy
open Survival.SoftwareContractToyRepository
open Survival.SoftwareEvidencePacketToy

noncomputable section

variable {Surface RepairAction : Type*}

/-! ## Generic finite budget lemmas -/

/-- A sound evidence dependency packet bounds invalidations by its checked
dependency closure budget. -/
theorem invalidated_ncard_le_closure_ncard
    [Finite Surface] (p : EvidenceDependencyPacket Surface) :
    (invalidatedSurfaces p).ncard ≤
      (dependencyClosureSurfaces p).ncard := by
  exact Set.ncard_le_ncard (evidence_invalidations_localized p)

/-- A checked dependency closure on a finite surface is bounded by the whole
control surface. -/
theorem closure_ncard_le_surface_card
    [Finite Surface] (p : EvidenceDependencyPacket Surface) :
    (dependencyClosureSurfaces p).ncard ≤ Nat.card Surface := by
  exact Set.ncard_le_card (dependencyClosureSurfaces p)

/-- Invalidations are bounded by the whole finite control surface. -/
theorem invalidated_ncard_le_surface_card
    [Finite Surface] (p : EvidenceDependencyPacket Surface) :
    (invalidatedSurfaces p).ncard ≤ Nat.card Surface := by
  exact Nat.le_trans (invalidated_ncard_le_closure_ncard p)
    (closure_ncard_le_surface_card p)

/-- A repair that covers the dependency closure also provides a finite touched
budget for semantic invalidations. -/
theorem invalidated_ncard_le_repair_touched_ncard
    [Finite Surface]
    (p : EvidenceDependencyPacket Surface)
    (repair : RepairPacket Surface RepairAction)
    (hrepair : TouchesAll repair (dependencyClosureSurfaces p)) :
    (invalidatedSurfaces p).ncard ≤ repair.touched.ncard := by
  exact Set.ncard_le_ncard
    (repair_touches_invalidations p repair hrepair)

/-! ## LLM toy surface budget consequences -/

/-- LLM continual-update toy: premise-update invalidations are no larger than
the checked downstream closure. -/
theorem llm_invalidated_ncard_le_closure_ncard :
    (invalidatedSurfaces premiseUpdateDependencyPacket).ncard ≤
      (dependencyClosureSurfaces premiseUpdateDependencyPacket).ncard := by
  exact invalidated_ncard_le_closure_ncard premiseUpdateDependencyPacket

/-- LLM continual-update toy: the checked downstream closure is bounded by the
finite LLM control surface. -/
theorem llm_closure_ncard_le_surface_card :
    (dependencyClosureSurfaces premiseUpdateDependencyPacket).ncard ≤
      Nat.card LLMControlSurface := by
  exact closure_ncard_le_surface_card premiseUpdateDependencyPacket

/-- LLM continual-update toy: invalidations are bounded by the finite LLM
control surface. -/
theorem llm_invalidated_ncard_le_surface_card :
    (invalidatedSurfaces premiseUpdateDependencyPacket).ncard ≤
      Nat.card LLMControlSurface := by
  exact invalidated_ncard_le_surface_card premiseUpdateDependencyPacket

/-- LLM continual-update toy: a repair covering the closure bounds the
invalidation budget by the repair's touched surface budget. -/
theorem llm_invalidated_ncard_le_repair_touched_ncard :
    (invalidatedSurfaces premiseUpdateDependencyPacket).ncard ≤
      premiseRepairPacket.touched.ncard := by
  exact invalidated_ncard_le_repair_touched_ncard
    premiseUpdateDependencyPacket premiseRepairPacket
    premiseRepair_covers_dependencyClosure

/-! ## Software contract toy surface budget consequences -/

/-- Software-contract toy: API-root invalidations are no larger than the
checked downstream closure. -/
theorem software_invalidated_ncard_le_closure_ncard :
    (invalidatedSurfaces toyEvidenceDependencyPacket).ncard ≤
      (dependencyClosureSurfaces toyEvidenceDependencyPacket).ncard := by
  exact invalidated_ncard_le_closure_ncard toyEvidenceDependencyPacket

/-- Software-contract toy: the checked downstream closure is bounded by the
finite contract surface. -/
theorem software_closure_ncard_le_surface_card :
    (dependencyClosureSurfaces toyEvidenceDependencyPacket).ncard ≤
      Nat.card ContractSurface := by
  exact closure_ncard_le_surface_card toyEvidenceDependencyPacket

/-- Software-contract toy: invalidations are bounded by the finite contract
surface. -/
theorem software_invalidated_ncard_le_surface_card :
    (invalidatedSurfaces toyEvidenceDependencyPacket).ncard ≤
      Nat.card ContractSurface := by
  exact invalidated_ncard_le_surface_card toyEvidenceDependencyPacket

/-- Software-contract toy: a repair covering the closure bounds the
invalidation budget by the repair's touched surface budget. -/
theorem software_invalidated_ncard_le_repair_touched_ncard :
    (invalidatedSurfaces toyEvidenceDependencyPacket).ncard ≤
      toyRepairPacket.touched.ncard := by
  exact invalidated_ncard_le_repair_touched_ncard
    toyEvidenceDependencyPacket toyRepairPacket
    toyRepair_covers_dependencyClosure

end

end Survival.DependencyClosureBudgetToy
