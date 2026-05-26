import Survival.LLMEpistemicControlToy

/-!
# LLM Memory Use-Condition Toy

This module refines the memory part of `LLMEpistemicControlToy`.

The point is not to prove arbitrary long-term memory safety.  The point is to
make the use conditions explicit in a finite toy schema: source/provenance is
still handled by evidence packets, while permission, scope, deletion state,
stability, and action eligibility are checked before a memory item may be used
as an admissible premise.
-/

namespace Survival.LLMMemoryUseConditionToy

open Survival.EpistemicControlBridge
open Survival.EvidencePacketBridge
open Survival.LLMEpistemicControlToy

noncomputable section

/-! ## Use-condition vocabulary -/

inductive MemoryScope where
  | currentTask
  | longTermPreference
  | outOfScope
  deriving DecidableEq, Fintype, Repr

inductive MemoryPermission where
  | granted
  | denied
  deriving DecidableEq, Fintype, Repr

inductive MemoryDeletionState where
  | active
  | deleted
  deriving DecidableEq, Fintype, Repr

inductive MemoryStability where
  | stable
  | volatile
  deriving DecidableEq, Fintype, Repr

inductive MemoryActionEligibility where
  | usable
  | blocked
  deriving DecidableEq, Fintype, Repr

/-- Explicit use conditions checked before a long-term memory item may be read
as a current premise. -/
structure MemoryUseCondition where
  scope : MemoryScope
  permission : MemoryPermission
  deletion : MemoryDeletionState
  stability : MemoryStability
  action : MemoryActionEligibility
  deriving DecidableEq, Repr

/-- A memory item is use-condition eligible when every operational guard passes. -/
structure UseConditionEligible (c : MemoryUseCondition) : Prop where
  permissionGranted : c.permission = MemoryPermission.granted
  notDeleted : c.deletion = MemoryDeletionState.active
  inScope : c.scope ≠ MemoryScope.outOfScope
  stable : c.stability = MemoryStability.stable
  actionUsable : c.action = MemoryActionEligibility.usable

/-- A long-term memory record combines an evidence packet with explicit use
conditions. -/
structure LongTermMemoryRecord where
  packet : EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance
  useCondition : MemoryUseCondition

/-- Full memory eligibility requires both packet eligibility and use-condition
eligibility. -/
def EligibleLongTermMemory (r : LongTermMemoryRecord) : Prop :=
  EligibleEvidence r.packet ∧ UseConditionEligible r.useCondition

/-! ## Projection and rejection lemmas -/

theorem eligible_memory_has_packet
    {r : LongTermMemoryRecord} (h : EligibleLongTermMemory r) :
    EligibleEvidence r.packet :=
  h.1

theorem eligible_memory_has_use_conditions
    {r : LongTermMemoryRecord} (h : EligibleLongTermMemory r) :
    UseConditionEligible r.useCondition :=
  h.2

theorem memory_without_permission_not_eligible
    {r : LongTermMemoryRecord}
    (h : r.useCondition.permission = MemoryPermission.denied) :
    ¬ EligibleLongTermMemory r := by
  intro heligible
  have hperm := heligible.2.permissionGranted
  rw [h] at hperm
  cases hperm

theorem deleted_memory_not_eligible
    {r : LongTermMemoryRecord}
    (h : r.useCondition.deletion = MemoryDeletionState.deleted) :
    ¬ EligibleLongTermMemory r := by
  intro heligible
  have hdelete := heligible.2.notDeleted
  rw [h] at hdelete
  cases hdelete

theorem out_of_scope_memory_not_eligible
    {r : LongTermMemoryRecord}
    (h : r.useCondition.scope = MemoryScope.outOfScope) :
    ¬ EligibleLongTermMemory r := by
  intro heligible
  exact heligible.2.inScope h

theorem unstable_memory_not_eligible
    {r : LongTermMemoryRecord}
    (h : r.useCondition.stability = MemoryStability.volatile) :
    ¬ EligibleLongTermMemory r := by
  intro heligible
  have hstable := heligible.2.stable
  rw [h] at hstable
  cases hstable

theorem action_blocked_memory_not_eligible
    {r : LongTermMemoryRecord}
    (h : r.useCondition.action = MemoryActionEligibility.blocked) :
    ¬ EligibleLongTermMemory r := by
  intro heligible
  have haction := heligible.2.actionUsable
  rw [h] at haction
  cases haction

/-! ## Concrete finite toy records -/

def eligibleUseCondition : MemoryUseCondition where
  scope := MemoryScope.longTermPreference
  permission := MemoryPermission.granted
  deletion := MemoryDeletionState.active
  stability := MemoryStability.stable
  action := MemoryActionEligibility.usable

def noPermissionUseCondition : MemoryUseCondition where
  scope := MemoryScope.longTermPreference
  permission := MemoryPermission.denied
  deletion := MemoryDeletionState.active
  stability := MemoryStability.stable
  action := MemoryActionEligibility.usable

def deletedUseCondition : MemoryUseCondition where
  scope := MemoryScope.longTermPreference
  permission := MemoryPermission.granted
  deletion := MemoryDeletionState.deleted
  stability := MemoryStability.stable
  action := MemoryActionEligibility.usable

def outOfScopeUseCondition : MemoryUseCondition where
  scope := MemoryScope.outOfScope
  permission := MemoryPermission.granted
  deletion := MemoryDeletionState.active
  stability := MemoryStability.stable
  action := MemoryActionEligibility.usable

def volatileUseCondition : MemoryUseCondition where
  scope := MemoryScope.longTermPreference
  permission := MemoryPermission.granted
  deletion := MemoryDeletionState.active
  stability := MemoryStability.volatile
  action := MemoryActionEligibility.usable

def actionBlockedUseCondition : MemoryUseCondition where
  scope := MemoryScope.longTermPreference
  permission := MemoryPermission.granted
  deletion := MemoryDeletionState.active
  stability := MemoryStability.stable
  action := MemoryActionEligibility.blocked

def scopedCorrectionRecord : LongTermMemoryRecord where
  packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
  useCondition := eligibleUseCondition

def noPermissionRecord : LongTermMemoryRecord where
  packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
  useCondition := noPermissionUseCondition

def deletedRecord : LongTermMemoryRecord where
  packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
  useCondition := deletedUseCondition

def outOfScopeRecord : LongTermMemoryRecord where
  packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
  useCondition := outOfScopeUseCondition

theorem eligibleUseCondition_ok :
    UseConditionEligible eligibleUseCondition where
  permissionGranted := rfl
  notDeleted := rfl
  inScope := by decide
  stable := rfl
  actionUsable := rfl

theorem scopedCorrectionRecord_eligible :
    EligibleLongTermMemory scopedCorrectionRecord := by
  exact ⟨eligibleMemory_eligible, eligibleUseCondition_ok⟩

theorem noPermissionRecord_not_eligible :
    ¬ EligibleLongTermMemory noPermissionRecord :=
  memory_without_permission_not_eligible rfl

theorem deletedRecord_not_eligible :
    ¬ EligibleLongTermMemory deletedRecord :=
  deleted_memory_not_eligible rfl

theorem outOfScopeRecord_not_eligible :
    ¬ EligibleLongTermMemory outOfScopeRecord :=
  out_of_scope_memory_not_eligible rfl

/-! ## Use-condition admission gate -/

inductive RawUseConditionMemory where
  | noPermission
  | deleted
  | outOfScope
  | volatile
  | actionBlocked
  | eligible
  deriving DecidableEq, Fintype, Repr

def recordOfRawUseCondition :
    RawUseConditionMemory → LongTermMemoryRecord
  | RawUseConditionMemory.noPermission =>
      { packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
        useCondition := noPermissionUseCondition }
  | RawUseConditionMemory.deleted =>
      { packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
        useCondition := deletedUseCondition }
  | RawUseConditionMemory.outOfScope =>
      { packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
        useCondition := outOfScopeUseCondition }
  | RawUseConditionMemory.volatile =>
      { packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
        useCondition := volatileUseCondition }
  | RawUseConditionMemory.actionBlocked =>
      { packet := memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection
        useCondition := actionBlockedUseCondition }
  | RawUseConditionMemory.eligible =>
      scopedCorrectionRecord

/-- Accept-all treats every raw memory candidate as if it could contract the
current coherent region.  The use-condition gate blocks candidates whose
permission, deletion, scope, stability, or action guards fail. -/
def useConditionMemoryAdmission :
    EvidenceAdmission RawUseConditionMemory LLMEpistemicState where
  acceptAllAfter := fun _raw before => llmContradictionUpdate 0 before
  eligibleAfter := fun raw before =>
    match raw with
    | RawUseConditionMemory.eligible => llmContradictionUpdate 0 before
    | _ => before
  eligible_contains_acceptAll := by
    intro raw before x hx
    cases raw
    · exact hx.1
    · exact hx.1
    · exact hx.1
    · exact hx.1
    · exact hx.1
    · exact hx

/-- The explicit use-condition gate inherits the no-more-loss comparison
against accept-all admission under the bridge's region-containment premise. -/
theorem useConditionMemory_no_more_loss
    (raw : RawUseConditionMemory) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (useConditionMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (useConditionMemoryAdmission.acceptAllAfter raw before) := by
  exact evidence_filter_no_more_loss llmMassModel useConditionMemoryAdmission
    raw before (llmMassModel_pos before)
    (llmMassModel_pos (useConditionMemoryAdmission.acceptAllAfter raw before))

end

end Survival.LLMMemoryUseConditionToy
