import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith
import Survival.EvidencePacketBridge

/-!
# LLM Epistemic Control Toy

This module gives a finite toy instantiation for the three LLM-facing control
problems discussed in the prose layer:

* reasoning degradation as contradiction / repair over a coherent region;
* long-term memory control as provenance-and-eligibility admission;
* continual update as dependency invalidation plus scoped repair coverage.

It does not formalize natural-language semantics, model weights, model
performance, or real memory safety.  It only checks that finite toy versions of
these three control surfaces fit the existing bridge interfaces.
-/

namespace Survival.LLMEpistemicControlToy

open Survival.EpistemicControlBridge
open Survival.EvidencePacketBridge
open Survival.GeneralStateDynamics

noncomputable section

/-! ## Toy vocabulary -/

/-- Surfaces where an LLM-style control layer may store or use claims. -/
inductive LLMControlSurface where
  | contextClaim
  | memoryRecord
  | premise
  | derivedAnswer
  deriving DecidableEq, Fintype, Repr

/-- Provenance labels for the toy LLM control surface. -/
inductive LLMProvenance where
  | userCorrection
  | retrievalLog
  | dependencyAudit
  deriving DecidableEq, Fintype, Repr

/-- Keys for scoped toy epistemic facts. -/
inductive LLMEpistemicKey where
  | preferenceFact
  | premiseUpdate
  deriving DecidableEq, Fintype, Repr

/-- Complete finite toy states for the selected LLM control scope. -/
inductive LLMEpistemicState where
  | coherentContext
  | unscopedContradiction
  | staleMemoryAdmitted
  | repairedAfterUpdate
  deriving DecidableEq, Fintype, Repr

/-! ## Positive toy mass readout -/

def llmStateIndicator (A : Set LLMEpistemicState) (x : LLMEpistemicState) : ℝ :=
  by
    classical
    exact if x ∈ A then 1 else 0

def llmStateCount (A : Set LLMEpistemicState) : ℝ :=
  llmStateIndicator A LLMEpistemicState.coherentContext +
    llmStateIndicator A LLMEpistemicState.unscopedContradiction +
    llmStateIndicator A LLMEpistemicState.staleMemoryAdmitted +
    llmStateIndicator A LLMEpistemicState.repairedAfterUpdate

def regularizedLLMMass (A : Set LLMEpistemicState) : ℝ :=
  1 + llmStateCount A

theorem llmStateIndicator_nonneg
    (A : Set LLMEpistemicState) (x : LLMEpistemicState) :
    0 ≤ llmStateIndicator A x := by
  classical
  unfold llmStateIndicator
  by_cases hmem : x ∈ A <;> simp [hmem]

theorem llmStateIndicator_mono
    {A B : Set LLMEpistemicState} (hAB : A ⊆ B)
    (x : LLMEpistemicState) :
    llmStateIndicator A x ≤ llmStateIndicator B x := by
  classical
  unfold llmStateIndicator
  by_cases hA : x ∈ A
  · have hB : x ∈ B := hAB hA
    simp [hA, hB]
  · by_cases hB : x ∈ B <;> simp [hA, hB]

theorem llmStateCount_nonneg (A : Set LLMEpistemicState) :
    0 ≤ llmStateCount A := by
  unfold llmStateCount
  linarith [llmStateIndicator_nonneg A LLMEpistemicState.coherentContext,
    llmStateIndicator_nonneg A LLMEpistemicState.unscopedContradiction,
    llmStateIndicator_nonneg A LLMEpistemicState.staleMemoryAdmitted,
    llmStateIndicator_nonneg A LLMEpistemicState.repairedAfterUpdate]

theorem llmStateCount_mono
    {A B : Set LLMEpistemicState} (hAB : A ⊆ B) :
    llmStateCount A ≤ llmStateCount B := by
  unfold llmStateCount
  linarith [llmStateIndicator_mono hAB LLMEpistemicState.coherentContext,
    llmStateIndicator_mono hAB LLMEpistemicState.unscopedContradiction,
    llmStateIndicator_mono hAB LLMEpistemicState.staleMemoryAdmitted,
    llmStateIndicator_mono hAB LLMEpistemicState.repairedAfterUpdate]

theorem regularizedLLMMass_pos (A : Set LLMEpistemicState) :
    0 < regularizedLLMMass A := by
  unfold regularizedLLMMass
  have hnonneg : 0 ≤ llmStateCount A := llmStateCount_nonneg A
  linarith

theorem regularizedLLMMass_mono
    {A B : Set LLMEpistemicState} (hAB : A ⊆ B) :
    regularizedLLMMass A ≤ regularizedLLMMass B := by
  unfold regularizedLLMMass
  have hmono : llmStateCount A ≤ llmStateCount B := llmStateCount_mono hAB
  linarith

def llmMassModel : MassModel LLMEpistemicState where
  mass := regularizedLLMMass
  mono := by
    intro A B hAB
    exact regularizedLLMMass_mono hAB

theorem llmMassModel_pos (A : Set LLMEpistemicState) :
    0 < llmMassModel.mass A := by
  simpa [llmMassModel] using regularizedLLMMass_pos A

/-! ## Reasoning: contradiction / repair toy -/

def coherentLLMRegion : Set LLMEpistemicState :=
  {s | s = LLMEpistemicState.coherentContext ∨
    s = LLMEpistemicState.repairedAfterUpdate}

def initialLLMRegion : Set LLMEpistemicState :=
  Set.univ

def llmContradictionUpdate (_t : ℕ)
    (A : Set LLMEpistemicState) : Set LLMEpistemicState :=
  A ∩ coherentLLMRegion

def llmRepairUpdate (_t : ℕ)
    (A : Set LLMEpistemicState) : Set LLMEpistemicState :=
  A ∪ {LLMEpistemicState.repairedAfterUpdate}

theorem llmContradictionUpdate_contracts
    (t : ℕ) (A : Set LLMEpistemicState) :
    llmContradictionUpdate t A ⊆ A := by
  intro x hx
  exact hx.1

theorem llmRepairUpdate_expands
    (t : ℕ) (A : Set LLMEpistemicState) :
    A ⊆ llmRepairUpdate t A := by
  intro x hx
  exact Or.inl hx

def llmReasoningSpec : EpistemicControlSpec LLMEpistemicState where
  initialRegion := initialLLMRegion
  massModel := llmMassModel
  contradictionUpdate := llmContradictionUpdate
  repairUpdate := llmRepairUpdate
  contradiction_contracts := llmContradictionUpdate_contracts
  repair_expands := llmRepairUpdate_expands

theorem llmReasoningToy_positiveTrajectory (n : ℕ) :
    PositiveTrajectory (toProblemSpec llmReasoningSpec) n where
  feasible_pos := by
    intro t ht
    dsimp [feasibleMass, toProblemSpec, llmReasoningSpec, llmMassModel]
    exact regularizedLLMMass_pos _
  contracted_pos := by
    intro t ht
    dsimp [contractedMass, toProblemSpec, llmReasoningSpec, llmMassModel]
    exact regularizedLLMMass_pos _

/-- Reasoning toy: contradiction and repair inherit the finite net-action
kernel through the abstract bridge. -/
theorem llmReasoningToy_composition_kernel (n : ℕ) :
    coherentMass llmReasoningSpec n =
      coherentMass llmReasoningSpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction llmReasoningSpec n)) := by
  exact epistemic_control_composition_kernel llmReasoningSpec n
    (llmReasoningToy_positiveTrajectory n)

/-! ## Reasoning evidence witness -/

def llmSurfaceKey (_surface : LLMControlSurface) : LLMEpistemicKey :=
  LLMEpistemicKey.preferenceFact

def reasoningContradictionPacket :
    EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance where
  surfaces := {s | s = LLMControlSurface.contextClaim ∨
    s = LLMControlSurface.memoryRecord}
  contractKey := LLMEpistemicKey.preferenceFact
  provenance? := some LLMProvenance.userCorrection
  status := ValidationStatus.validated

theorem reasoningContradiction_eligible :
    EligibleEvidence reasoningContradictionPacket := by
  refine ⟨rfl, ?_, ?_⟩
  · simp [HasProvenance, reasoningContradictionPacket]
  · refine ⟨LLMControlSurface.contextClaim, LLMControlSurface.memoryRecord,
      ?_, ?_, ?_⟩
    · simp [reasoningContradictionPacket]
    · simp [reasoningContradictionPacket]
    · decide

theorem reasoningContradiction_keySound :
    SurfaceSharesPacketKey llmSurfaceKey reasoningContradictionPacket := by
  intro s _hs
  cases s <;> rfl

def reasoningContradictionWitness :
    ContradictionWitness LLMControlSurface LLMEpistemicKey LLMProvenance
      llmSurfaceKey where
  packet := reasoningContradictionPacket
  eligible := reasoningContradiction_eligible
  keySound := reasoningContradiction_keySound

theorem llmReasoningContradictionWitness_has_two_surfaces :
    HasAtLeastTwoSurfaces reasoningContradictionWitness.packet.surfaces :=
  witness_has_two_surfaces reasoningContradictionWitness

/-! ## Memory: provenance and eligibility toy -/

inductive RawMemoryItem where
  | staleUnscopedMemory
  | eligibleScopedCorrection
  deriving DecidableEq, Fintype, Repr

def memoryEvidencePacket :
    RawMemoryItem →
      EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance
  | RawMemoryItem.staleUnscopedMemory =>
      { surfaces := {s | s = LLMControlSurface.memoryRecord}
        contractKey := LLMEpistemicKey.preferenceFact
        provenance? := some LLMProvenance.retrievalLog
        status := ValidationStatus.unsupported }
  | RawMemoryItem.eligibleScopedCorrection =>
      { surfaces := {s | s = LLMControlSurface.contextClaim ∨
          s = LLMControlSurface.memoryRecord}
        contractKey := LLMEpistemicKey.preferenceFact
        provenance? := some LLMProvenance.userCorrection
        status := ValidationStatus.validated }

theorem staleMemory_not_eligible :
    ¬ EligibleEvidence (memoryEvidencePacket RawMemoryItem.staleUnscopedMemory) := by
  exact unsupported_not_eligible
    (p := memoryEvidencePacket RawMemoryItem.staleUnscopedMemory) rfl

theorem eligibleMemory_eligible :
    EligibleEvidence
      (memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection) := by
  refine ⟨rfl, ?_, ?_⟩
  · simp [HasProvenance, memoryEvidencePacket]
  · refine ⟨LLMControlSurface.contextClaim, LLMControlSurface.memoryRecord,
      ?_, ?_, ?_⟩
    · simp [memoryEvidencePacket]
    · simp [memoryEvidencePacket]
    · decide

def llmMemoryAdmission : EvidenceAdmission RawMemoryItem LLMEpistemicState where
  acceptAllAfter := fun _raw before => llmContradictionUpdate 0 before
  eligibleAfter := fun raw before =>
    match raw with
    | RawMemoryItem.staleUnscopedMemory => before
    | RawMemoryItem.eligibleScopedCorrection => llmContradictionUpdate 0 before
  eligible_contains_acceptAll := by
    intro raw before x hx
    cases raw
    · exact hx.1
    · exact hx

/-- Memory toy: a provenance / eligibility gate inherits the bridge-level
no-more-loss comparison against accept-all admission. -/
theorem eligibleMemory_no_more_loss
    (raw : RawMemoryItem) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (llmMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (llmMemoryAdmission.acceptAllAfter raw before) := by
  exact evidence_filter_no_more_loss llmMassModel llmMemoryAdmission raw before
    (llmMassModel_pos before)
    (llmMassModel_pos (llmMemoryAdmission.acceptAllAfter raw before))

/-! ## Continual update: dependency invalidation and repair toy -/

def llmDownstream : LLMControlSurface → Set LLMControlSurface
  | LLMControlSurface.premise =>
      {s | s = LLMControlSurface.premise ∨
        s = LLMControlSurface.contextClaim ∨
        s = LLMControlSurface.memoryRecord ∨
        s = LLMControlSurface.derivedAnswer}
  | LLMControlSurface.contextClaim =>
      {s | s = LLMControlSurface.contextClaim ∨
        s = LLMControlSurface.derivedAnswer}
  | LLMControlSurface.memoryRecord =>
      {s | s = LLMControlSurface.memoryRecord ∨
        s = LLMControlSurface.derivedAnswer}
  | LLMControlSurface.derivedAnswer =>
      {s | s = LLMControlSurface.derivedAnswer}

def llmDependencyGraph : DependencyGraph LLMControlSurface where
  downstream := llmDownstream

def llmSemanticDepends (root x : LLMControlSurface) : Prop :=
  x ∈ llmDownstream root

theorem llmDependencyGraph_sound :
    SoundDependencyClosure llmDependencyGraph llmSemanticDepends := by
  intro root x hdep
  exact hdep

def premiseUpdateRoots : Set LLMControlSurface :=
  {LLMControlSurface.premise}

def premiseUpdateDependencyPacket :
    EvidenceDependencyPacket LLMControlSurface where
  changedRoots := premiseUpdateRoots
  semanticDepends := llmSemanticDepends
  graph := llmDependencyGraph
  graphSound := llmDependencyGraph_sound

theorem premiseUpdate_invalidations_localized :
    invalidatedSurfaces premiseUpdateDependencyPacket ⊆
      dependencyClosureSurfaces premiseUpdateDependencyPacket :=
  evidence_invalidations_localized premiseUpdateDependencyPacket

inductive LLMRepairAction where
  | refreshDownstream
  deriving DecidableEq, Fintype, Repr

def premiseRepairPacket : RepairPacket LLMControlSurface LLMRepairAction where
  touched := llmDownstream LLMControlSurface.premise
  action := LLMRepairAction.refreshDownstream

theorem premiseRepair_covers_dependencyClosure :
    TouchesAll premiseRepairPacket
      (dependencyClosureSurfaces premiseUpdateDependencyPacket) := by
  intro x hx
  rcases hx with ⟨root, hroot, hdown⟩
  have hroot_eq : root = LLMControlSurface.premise := by
    simpa [premiseUpdateDependencyPacket, premiseUpdateRoots] using hroot
  subst root
  simpa [premiseRepairPacket, llmDependencyGraph] using hdown

/-- Continual-update toy: a repair covering the dependency closure covers all
semantic invalidations induced by the premise update. -/
theorem repairTouches_downstreamInvalidations :
    TouchesAll premiseRepairPacket
      (invalidatedSurfaces premiseUpdateDependencyPacket) :=
  repair_touches_invalidations premiseUpdateDependencyPacket
    premiseRepairPacket premiseRepair_covers_dependencyClosure

end

end Survival.LLMEpistemicControlToy
