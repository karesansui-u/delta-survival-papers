import Survival.EvidencePacketBridge
import Survival.SoftwareContractToyRepository

/-!
# Software Evidence Packet Toy

This module connects the software-contract toy surface to
`EvidencePacketBridge`.

It does not verify a real repository or workflow.  The goal is narrower: show
that the finite toy software surface can emit evidence packets satisfying the
bridge's provenance, eligibility, witness, dependency, repair, and admission
guardrails.
-/

namespace Survival.SoftwareEvidencePacketToy

open Survival.EvidencePacketBridge
open Survival.EpistemicControlBridge
open Survival.SoftwareContractToyRepository

noncomputable section

/-! ## Toy evidence vocabulary -/

/-- The selected toy repository has a single contract key. -/
inductive ToyContractKey where
  | tokenContract
  deriving DecidableEq, Fintype, Repr

/-- In the toy surface, every listed surface participates in the same selected
contract key. -/
def toySurfaceKey (_surface : ContractSurface) : ToyContractKey :=
  ToyContractKey.tokenContract

/-- A validated two-surface mismatch packet for the toy repository surface. -/
def toyMismatchEvidencePacket :
    EvidencePacket ContractSurface ToyContractKey SoftwareProvenance where
  surfaces := {s | s = ContractSurface.api ∨ s = ContractSurface.docs}
  contractKey := ToyContractKey.tokenContract
  provenance? := some SoftwareProvenance.implementation
  status := ValidationStatus.validated

/-- A raw toy candidate rendered as an evidence packet. -/
def rawCandidateEvidence :
    RawContractCandidate →
      EvidencePacket ContractSurface ToyContractKey SoftwareProvenance
  | RawContractCandidate.unsupportedStyleComment =>
      { surfaces := {s | s = ContractSurface.docs}
        contractKey := ToyContractKey.tokenContract
        provenance? := none
        status := ValidationStatus.styleOnly }
  | RawContractCandidate.validatedContractMismatch =>
      toyMismatchEvidencePacket

theorem toyMismatchEvidence_eligible :
    EligibleEvidence toyMismatchEvidencePacket := by
  refine ⟨rfl, ?_, ?_⟩
  · simp [HasProvenance, toyMismatchEvidencePacket]
  · refine ⟨ContractSurface.api, ContractSurface.docs, ?_, ?_, ?_⟩
    · simp [toyMismatchEvidencePacket]
    · simp [toyMismatchEvidencePacket]
    · decide

theorem toyValidatedCandidate_eligible :
    EligibleEvidence
      (rawCandidateEvidence RawContractCandidate.validatedContractMismatch) := by
  simpa [rawCandidateEvidence] using toyMismatchEvidence_eligible

theorem toyUnsupportedCandidate_not_eligible :
    ¬ EligibleEvidence
      (rawCandidateEvidence RawContractCandidate.unsupportedStyleComment) := by
  exact styleOnly_not_eligible
    (p := rawCandidateEvidence RawContractCandidate.unsupportedStyleComment) rfl

theorem toyUnsupportedCandidate_missing_provenance :
    ¬ EligibleEvidence
      (rawCandidateEvidence RawContractCandidate.unsupportedStyleComment) := by
  exact missing_provenance_not_eligible
    (p := rawCandidateEvidence RawContractCandidate.unsupportedStyleComment) rfl

/-! ## Toy contradiction witness -/

theorem toyMismatchEvidence_keySound :
    SurfaceSharesPacketKey toySurfaceKey toyMismatchEvidencePacket := by
  intro s _hs
  cases s <;> rfl

/-- The validated toy packet as a contradiction witness. -/
def toyContradictionWitness :
    ContradictionWitness ContractSurface ToyContractKey SoftwareProvenance
      toySurfaceKey where
  packet := toyMismatchEvidencePacket
  eligible := toyMismatchEvidence_eligible
  keySound := toyMismatchEvidence_keySound

theorem toyWitness_has_two_surfaces :
    HasAtLeastTwoSurfaces toyContradictionWitness.packet.surfaces :=
  witness_has_two_surfaces toyContradictionWitness

theorem toyWitness_surface_key_eq
    {s : ContractSurface} (hs : s ∈ toyContradictionWitness.packet.surfaces) :
    toySurfaceKey s = toyContradictionWitness.packet.contractKey :=
  witness_surface_key_eq toyContradictionWitness hs

/-! ## Toy dependency and repair evidence -/

/-- The toy dependency packet starts from the API surface. -/
def toyChangedRoots : Set ContractSurface :=
  {ContractSurface.api}

/-- The existing toy dependency graph as an evidence dependency packet. -/
def toyEvidenceDependencyPacket : EvidenceDependencyPacket ContractSurface where
  changedRoots := toyChangedRoots
  semanticDepends := toySemanticDepends
  graph := toyDependencyGraph
  graphSound := toyDependencyGraph_sound

theorem toyEvidence_invalidations_localized :
    invalidatedSurfaces toyEvidenceDependencyPacket ⊆
      dependencyClosureSurfaces toyEvidenceDependencyPacket :=
  evidence_invalidations_localized toyEvidenceDependencyPacket

/-- A toy repair action synchronizes downstream contract surfaces. -/
inductive ToyRepairAction where
  | synchronizeDownstream
  deriving DecidableEq, Fintype, Repr

/-- The toy repair touches every surface downstream of the API root. -/
def toyRepairPacket : RepairPacket ContractSurface ToyRepairAction where
  touched := contractDownstream ContractSurface.api
  action := ToyRepairAction.synchronizeDownstream

theorem toyRepair_covers_dependencyClosure :
    TouchesAll toyRepairPacket
      (dependencyClosureSurfaces toyEvidenceDependencyPacket) := by
  intro x hx
  rcases hx with ⟨root, hroot, hdown⟩
  have hroot_eq : root = ContractSurface.api := by
    simpa [toyEvidenceDependencyPacket, toyChangedRoots] using hroot
  subst root
  simpa [toyRepairPacket, toyDependencyGraph] using hdown

theorem toyRepair_touches_invalidations :
    TouchesAll toyRepairPacket
      (invalidatedSurfaces toyEvidenceDependencyPacket) :=
  repair_touches_invalidations toyEvidenceDependencyPacket
    toyRepairPacket toyRepair_covers_dependencyClosure

/-! ## Toy admission through the evidence bridge -/

/-- The existing toy claim-admission gate as evidence admission. -/
def toyEvidenceAdmission :
    EvidenceAdmission RawContractCandidate ToyRepoState where
  acceptAllAfter := toyClaimAdmission.acceptAllAfter
  eligibleAfter := toyClaimAdmission.filteredAfter
  eligible_contains_acceptAll := toyClaimAdmission_sound

theorem toyEvidenceAdmission_no_more_loss
    (raw : RawContractCandidate) (before : Set ToyRepoState) :
    lossFrom toyMassModel before
        (toyEvidenceAdmission.eligibleAfter raw before) ≤
      lossFrom toyMassModel before
        (toyEvidenceAdmission.acceptAllAfter raw before) := by
  exact evidence_filter_no_more_loss toyMassModel toyEvidenceAdmission raw before
    (toyMassModel_pos before)
    (toyMassModel_pos (toyEvidenceAdmission.acceptAllAfter raw before))

end

end Survival.SoftwareEvidencePacketToy
