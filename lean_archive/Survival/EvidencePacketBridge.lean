import Survival.EpistemicControlBridge

/-!
# Evidence Packet Bridge

This file adds a small implementation-adjacent layer below
`EpistemicControlBridge`.

It does not prove that a real LLM, software workflow, detector, or repository
semantics is correct.  Instead, it formalizes the shape of evidence packets
that an implementation can emit before the abstract epistemic-control bridge
uses them:

* provenance must be present;
* unsupported or style-only packets are not eligible;
* contradiction witnesses carry at least two distinct surfaces and a shared key;
* dependency packets localize semantic invalidation through a sound closure;
* repair packets that cover the closure also cover semantic invalidations;
* eligible filtering reuses the bridge's log-loss comparison lemma.

The point is to make the implementation boundary explicit without claiming that
the implementation itself has been verified.
-/

namespace Survival.EvidencePacketBridge

open Survival.EpistemicControlBridge
open Survival.GeneralStateDynamics

noncomputable section

/-- Coarse validation status for evidence emitted by an implementation. -/
inductive ValidationStatus where
  | unsupported
  | styleOnly
  | validated
  deriving DecidableEq, Repr

variable {Surface Key Provenance RepairAction State Raw : Type*}

/-- A packet records the contract key, affected surfaces, optional provenance,
and validation status of an implementation-level observation. -/
structure EvidencePacket (Surface Key Provenance : Type*) where
  surfaces : Set Surface
  contractKey : Key
  provenance? : Option Provenance
  status : ValidationStatus

/-- Evidence has provenance exactly when the implementation supplied a source. -/
def HasProvenance (p : EvidencePacket Surface Key Provenance) : Prop :=
  p.provenance?.isSome

/-- A contradiction-style witness must involve two distinct surfaces. -/
def HasAtLeastTwoSurfaces (surfaces : Set Surface) : Prop :=
  ∃ a b, a ∈ surfaces ∧ b ∈ surfaces ∧ a ≠ b

/-- Eligibility gate used before an evidence packet may feed the bridge layer. -/
def EligibleEvidence (p : EvidencePacket Surface Key Provenance) : Prop :=
  p.status = ValidationStatus.validated ∧
    HasProvenance p ∧ HasAtLeastTwoSurfaces p.surfaces

/-- Eligible evidence is validated. -/
theorem eligible_status_validated
    {p : EvidencePacket Surface Key Provenance}
    (h : EligibleEvidence p) :
    p.status = ValidationStatus.validated :=
  h.1

/-- Eligible evidence has provenance. -/
theorem eligible_has_provenance
    {p : EvidencePacket Surface Key Provenance}
    (h : EligibleEvidence p) :
    HasProvenance p :=
  h.2.1

/-- Eligible evidence carries at least two distinct surfaces. -/
theorem eligible_has_two_surfaces
    {p : EvidencePacket Surface Key Provenance}
    (h : EligibleEvidence p) :
    HasAtLeastTwoSurfaces p.surfaces :=
  h.2.2

/-- Unsupported evidence cannot pass the eligibility gate. -/
theorem unsupported_not_eligible
    {p : EvidencePacket Surface Key Provenance}
    (h : p.status = ValidationStatus.unsupported) :
    ¬ EligibleEvidence p := by
  intro heligible
  rcases heligible with ⟨hstatus, _⟩
  rw [h] at hstatus
  cases hstatus

/-- Style-only evidence cannot pass the eligibility gate. -/
theorem styleOnly_not_eligible
    {p : EvidencePacket Surface Key Provenance}
    (h : p.status = ValidationStatus.styleOnly) :
    ¬ EligibleEvidence p := by
  intro heligible
  rcases heligible with ⟨hstatus, _⟩
  rw [h] at hstatus
  cases hstatus

/-- Evidence without provenance cannot pass the eligibility gate. -/
theorem missing_provenance_not_eligible
    {p : EvidencePacket Surface Key Provenance}
    (h : p.provenance? = none) :
    ¬ EligibleEvidence p := by
  intro heligible
  unfold EligibleEvidence HasProvenance at heligible
  simp [h] at heligible

/-- Surfaces in a packet are keyed consistently with the packet key. -/
def SurfaceSharesPacketKey
    (surfaceKey : Surface → Key)
    (p : EvidencePacket Surface Key Provenance) : Prop :=
  ∀ {s}, s ∈ p.surfaces → surfaceKey s = p.contractKey

/-- A contradiction witness is eligible evidence plus a key-soundness proof. -/
structure ContradictionWitness
    (Surface Key Provenance : Type*) (surfaceKey : Surface → Key) where
  packet : EvidencePacket Surface Key Provenance
  eligible : EligibleEvidence packet
  keySound : SurfaceSharesPacketKey surfaceKey packet

/-- A contradiction witness contains at least two distinct surfaces. -/
theorem witness_has_two_surfaces
    {surfaceKey : Surface → Key}
    (w : ContradictionWitness Surface Key Provenance surfaceKey) :
    HasAtLeastTwoSurfaces w.packet.surfaces :=
  eligible_has_two_surfaces w.eligible

/-- Every surface in a key-sound witness shares the witness packet key. -/
theorem witness_surface_key_eq
    {surfaceKey : Surface → Key}
    (w : ContradictionWitness Surface Key Provenance surfaceKey)
    {s : Surface} (hs : s ∈ w.packet.surfaces) :
    surfaceKey s = w.packet.contractKey :=
  w.keySound hs

/-! ## Dependency and repair packets -/

/-- A dependency packet packages changed roots, semantic dependency, and a
sound graph closure emitted or checked at the implementation boundary. -/
structure EvidenceDependencyPacket (Surface : Type*) where
  changedRoots : Set Surface
  semanticDepends : Surface → Surface → Prop
  graph : DependencyGraph Surface
  graphSound : SoundDependencyClosure graph semanticDepends

/-- Semantic invalidations represented by an evidence dependency packet. -/
def invalidatedSurfaces (p : EvidenceDependencyPacket Surface) : Set Surface :=
  semanticInvalidation p.semanticDepends p.changedRoots

/-- Graph closure represented by an evidence dependency packet. -/
def dependencyClosureSurfaces (p : EvidenceDependencyPacket Surface) : Set Surface :=
  downstreamClosure p.graph p.changedRoots

/-- Sound dependency packets localize invalidations to the graph closure. -/
theorem evidence_invalidations_localized
    (p : EvidenceDependencyPacket Surface) :
    invalidatedSurfaces p ⊆ dependencyClosureSurfaces p := by
  intro x hx
  rcases hx with ⟨root, hroot, hdep⟩
  exact ⟨root, hroot, p.graphSound hdep⟩

/-- A repair packet records which surfaces the repair action touches. -/
structure RepairPacket (Surface RepairAction : Type*) where
  touched : Set Surface
  action : RepairAction

/-- A repair covers every target in a target set. -/
def TouchesAll
    (repair : RepairPacket Surface RepairAction) (targets : Set Surface) : Prop :=
  targets ⊆ repair.touched

/-- A repair touches at least one target in a target set. -/
def TouchesSome
    (repair : RepairPacket Surface RepairAction) (targets : Set Surface) : Prop :=
  ∃ s, s ∈ targets ∧ s ∈ repair.touched

/-- Covering all targets implies touching some target when the target set is
nonempty. -/
theorem touchesAll_touchesSome
    {repair : RepairPacket Surface RepairAction} {targets : Set Surface}
    (hcover : TouchesAll repair targets)
    (hne : ∃ s, s ∈ targets) :
    TouchesSome repair targets := by
  rcases hne with ⟨s, hs⟩
  exact ⟨s, hs, hcover hs⟩

/-- If a repair covers the dependency closure, then it covers every semantic
invalidation localized by the evidence dependency packet. -/
theorem repair_touches_invalidations
    (p : EvidenceDependencyPacket Surface)
    (repair : RepairPacket Surface RepairAction)
    (hrepair : TouchesAll repair (dependencyClosureSurfaces p)) :
    TouchesAll repair (invalidatedSurfaces p) := by
  intro x hx
  exact hrepair (evidence_invalidations_localized p hx)

/-! ## Admission filter bridge -/

/-- Implementation-adjacent admission comparison for raw artifacts. -/
structure EvidenceAdmission (Raw : Type*) (State : Type*) where
  acceptAllAfter : Raw → Set State → Set State
  eligibleAfter : Raw → Set State → Set State
  eligible_contains_acceptAll :
    ∀ raw before, acceptAllAfter raw before ⊆ eligibleAfter raw before

/-- Evidence admission as the abstract memory-admission interface. -/
def EvidenceAdmission.toMemoryAdmission
    (A : EvidenceAdmission Raw State) : MemoryAdmission Raw State where
  acceptAllAfter := A.acceptAllAfter
  filteredAfter := A.eligibleAfter

/-- The evidence eligibility gate inherits the bridge-level no-more-loss
comparison whenever its resulting coherent region contains the accept-all
region for the same raw artifact. -/
theorem evidence_filter_no_more_loss
    (M : MassModel State) (A : EvidenceAdmission Raw State)
    (raw : Raw) (before : Set State)
    (hbefore : 0 < M.mass before)
    (haccept : 0 < M.mass (A.acceptAllAfter raw before)) :
    lossFrom M before (A.eligibleAfter raw before) ≤
      lossFrom M before (A.acceptAllAfter raw before) :=
  eligibility_filter_no_more_loss_under_soundness M
    (A.toMemoryAdmission) raw before hbefore haccept
    (A.eligible_contains_acceptAll raw before)

end

end Survival.EvidencePacketBridge
