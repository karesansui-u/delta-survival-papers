import Mathlib.Tactic.NormNum
import Survival.LLMMemoryUseConditionToy

/-!
# LLM Memory and Reasoning Strengthening Toy

This module adds four small strengthening layers on top of the finite LLM
epistemic-control toy:

* memory revocation / freshness guards;
* a provenance trust order for overwrite decisions;
* a minimal two-surface contradiction-witness predicate;
* repair-composition wrappers that still inherit the net-action kernel.

These are toy bridge results.  They do not prove real natural-language
semantics, model performance, or production memory safety.
-/

namespace Survival.LLMMemoryReasoningStrengtheningToy

open Survival.EpistemicControlBridge
open Survival.EvidencePacketBridge
open Survival.GeneralStateDynamics
open Survival.LLMEpistemicControlToy
open Survival.LLMMemoryUseConditionToy

noncomputable section

/-! ## Memory revocation and freshness -/

inductive MemoryRevocationState where
  | current
  | revoked
  deriving DecidableEq, Fintype, Repr

inductive MemoryFreshness where
  | fresh
  | expired
  deriving DecidableEq, Fintype, Repr

/-- Lifecycle guards checked after the ordinary use-condition gate. -/
structure MemoryLifecycleCondition where
  revocation : MemoryRevocationState
  freshness : MemoryFreshness
  deriving DecidableEq, Repr

/-- A lifecycle condition is eligible only when the record is current and
fresh. -/
structure LifecycleEligible (c : MemoryLifecycleCondition) : Prop where
  current : c.revocation = MemoryRevocationState.current
  fresh : c.freshness = MemoryFreshness.fresh

/-- A long-term memory record plus revocation / freshness state. -/
structure LifecycleMemoryRecord where
  base : LongTermMemoryRecord
  lifecycle : MemoryLifecycleCondition

/-- Full lifecycle memory eligibility: base memory eligibility plus lifecycle
guards. -/
def EligibleLifecycleMemory (r : LifecycleMemoryRecord) : Prop :=
  EligibleLongTermMemory r.base ∧ LifecycleEligible r.lifecycle

theorem revoked_memory_not_lifecycle_eligible
    {r : LifecycleMemoryRecord}
    (h : r.lifecycle.revocation = MemoryRevocationState.revoked) :
    ¬ EligibleLifecycleMemory r := by
  intro heligible
  have hcurrent := heligible.2.current
  rw [h] at hcurrent
  cases hcurrent

theorem expired_memory_not_lifecycle_eligible
    {r : LifecycleMemoryRecord}
    (h : r.lifecycle.freshness = MemoryFreshness.expired) :
    ¬ EligibleLifecycleMemory r := by
  intro heligible
  have hfresh := heligible.2.fresh
  rw [h] at hfresh
  cases hfresh

def currentFreshLifecycle : MemoryLifecycleCondition where
  revocation := MemoryRevocationState.current
  freshness := MemoryFreshness.fresh

def revokedLifecycle : MemoryLifecycleCondition where
  revocation := MemoryRevocationState.revoked
  freshness := MemoryFreshness.fresh

def expiredLifecycle : MemoryLifecycleCondition where
  revocation := MemoryRevocationState.current
  freshness := MemoryFreshness.expired

def freshScopedMemoryRecord : LifecycleMemoryRecord where
  base := scopedCorrectionRecord
  lifecycle := currentFreshLifecycle

def revokedScopedMemoryRecord : LifecycleMemoryRecord where
  base := scopedCorrectionRecord
  lifecycle := revokedLifecycle

def expiredScopedMemoryRecord : LifecycleMemoryRecord where
  base := scopedCorrectionRecord
  lifecycle := expiredLifecycle

theorem currentFreshLifecycle_ok :
    LifecycleEligible currentFreshLifecycle where
  current := rfl
  fresh := rfl

theorem freshScopedMemoryRecord_eligible :
    EligibleLifecycleMemory freshScopedMemoryRecord := by
  exact ⟨scopedCorrectionRecord_eligible, currentFreshLifecycle_ok⟩

theorem revokedScopedMemoryRecord_not_eligible :
    ¬ EligibleLifecycleMemory revokedScopedMemoryRecord :=
  revoked_memory_not_lifecycle_eligible rfl

theorem expiredScopedMemoryRecord_not_eligible :
    ¬ EligibleLifecycleMemory expiredScopedMemoryRecord :=
  expired_memory_not_lifecycle_eligible rfl

inductive RawLifecycleMemory where
  | revoked
  | expired
  | eligible
  deriving DecidableEq, Fintype, Repr

def lifecycleRecordOfRaw :
    RawLifecycleMemory → LifecycleMemoryRecord
  | RawLifecycleMemory.revoked => revokedScopedMemoryRecord
  | RawLifecycleMemory.expired => expiredScopedMemoryRecord
  | RawLifecycleMemory.eligible => freshScopedMemoryRecord

/-- Accept-all treats every lifecycle candidate as potentially contracting the
current coherent region; the lifecycle gate blocks revoked and expired
records. -/
def lifecycleMemoryAdmission :
    EvidenceAdmission RawLifecycleMemory LLMEpistemicState where
  acceptAllAfter := fun _raw before => llmContradictionUpdate 0 before
  eligibleAfter := fun raw before =>
    match raw with
    | RawLifecycleMemory.eligible => llmContradictionUpdate 0 before
    | _ => before
  eligible_contains_acceptAll := by
    intro raw before x hx
    cases raw
    · exact hx.1
    · exact hx.1
    · exact hx

theorem lifecycleMemory_no_more_loss
    (raw : RawLifecycleMemory) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (lifecycleMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (lifecycleMemoryAdmission.acceptAllAfter raw before) := by
  exact evidence_filter_no_more_loss llmMassModel lifecycleMemoryAdmission
    raw before (llmMassModel_pos before)
    (llmMassModel_pos (lifecycleMemoryAdmission.acceptAllAfter raw before))

/-! ## Provenance trust order -/

inductive TrustTier where
  | low
  | medium
  | high
  deriving DecidableEq, Fintype, Repr

def trustRank : TrustTier → Nat
  | TrustTier.low => 0
  | TrustTier.medium => 1
  | TrustTier.high => 2

/-- Toy trust projection for memory provenance. -/
def provenanceTrust : LLMProvenance → TrustTier
  | LLMProvenance.retrievalLog => TrustTier.low
  | LLMProvenance.dependencyAudit => TrustTier.medium
  | LLMProvenance.userCorrection => TrustTier.high

/-- An incoming provenance may overwrite an existing provenance when it is at
least as trusted as the existing source. -/
def TrustDominates (incoming existing : LLMProvenance) : Prop :=
  trustRank (provenanceTrust existing) ≤ trustRank (provenanceTrust incoming)

/-- Packet-level overwrite guard.  Missing provenance cannot satisfy it. -/
def PacketMayOverwrite
    (incoming existing :
      EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance) : Prop :=
  ∃ pin pex,
    incoming.provenance? = some pin ∧
      existing.provenance? = some pex ∧ TrustDominates pin pex

theorem retrievalLog_cannot_overwrite_userCorrection :
    ¬ TrustDominates LLMProvenance.retrievalLog
      LLMProvenance.userCorrection := by
  unfold TrustDominates provenanceTrust trustRank
  norm_num

theorem userCorrection_can_overwrite_retrievalLog :
    TrustDominates LLMProvenance.userCorrection
      LLMProvenance.retrievalLog := by
  unfold TrustDominates provenanceTrust trustRank
  norm_num

def retrievalMemoryPacket :
    EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance :=
  memoryEvidencePacket RawMemoryItem.staleUnscopedMemory

def userCorrectionMemoryPacket :
    EvidencePacket LLMControlSurface LLMEpistemicKey LLMProvenance :=
  memoryEvidencePacket RawMemoryItem.eligibleScopedCorrection

theorem retrieval_packet_cannot_overwrite_userCorrection_packet :
    ¬ PacketMayOverwrite retrievalMemoryPacket userCorrectionMemoryPacket := by
  intro h
  rcases h with ⟨pin, pex, hpin, hpex, htrust⟩
  have hpin_eq : pin = LLMProvenance.retrievalLog := by
    simpa [retrievalMemoryPacket, memoryEvidencePacket] using hpin.symm
  have hpex_eq : pex = LLMProvenance.userCorrection := by
    simpa [userCorrectionMemoryPacket, memoryEvidencePacket] using hpex.symm
  rw [hpin_eq, hpex_eq] at htrust
  exact retrievalLog_cannot_overwrite_userCorrection htrust

theorem userCorrection_packet_can_overwrite_retrieval_packet :
    PacketMayOverwrite userCorrectionMemoryPacket retrievalMemoryPacket := by
  refine ⟨LLMProvenance.userCorrection, LLMProvenance.retrievalLog,
    ?_, ?_, userCorrection_can_overwrite_retrievalLog⟩
  · simp [userCorrectionMemoryPacket, memoryEvidencePacket]
  · simp [retrievalMemoryPacket, memoryEvidencePacket]

/-! ## Minimal contradiction witnesses -/

variable {Surface Key Provenance : Type*}

/-- A two-surface set has exactly the two displayed surfaces. -/
def IsTwoSurfaceSet (surfaces : Set Surface) : Prop :=
  ∃ a b, a ≠ b ∧ surfaces = {s | s = a ∨ s = b}

/-- Minimality predicate for contradiction witnesses in this toy layer:
exactly two surfaces, not merely at least two. -/
def MinimalContradictionWitness
    {surfaceKey : Surface → Key}
    (w : ContradictionWitness Surface Key Provenance surfaceKey) : Prop :=
  IsTwoSurfaceSet w.packet.surfaces

theorem minimal_witness_has_at_least_two_surfaces
    {surfaceKey : Surface → Key}
    (w : ContradictionWitness Surface Key Provenance surfaceKey)
    (hmin : MinimalContradictionWitness w) :
    HasAtLeastTwoSurfaces w.packet.surfaces := by
  rcases hmin with ⟨a, b, hne, hsurfaces⟩
  refine ⟨a, b, ?_, ?_, hne⟩
  · rw [hsurfaces]
    exact Or.inl rfl
  · rw [hsurfaces]
    exact Or.inr rfl

theorem minimal_witness_no_third_surface
    {surfaces : Set Surface} (hmin : IsTwoSurfaceSet surfaces) :
    ∃ a b, a ≠ b ∧ ∀ x, x ∈ surfaces → x = a ∨ x = b := by
  rcases hmin with ⟨a, b, hne, hsurfaces⟩
  refine ⟨a, b, hne, ?_⟩
  intro x hx
  rw [hsurfaces] at hx
  exact hx

theorem reasoningContradictionWitness_minimal :
    MinimalContradictionWitness reasoningContradictionWitness := by
  refine ⟨LLMControlSurface.contextClaim, LLMControlSurface.memoryRecord,
    ?_, ?_⟩
  · decide
  · ext s
    simp [reasoningContradictionWitness, reasoningContradictionPacket]

theorem reasoningMinimalWitness_has_at_least_two_surfaces :
    HasAtLeastTwoSurfaces reasoningContradictionWitness.packet.surfaces :=
  minimal_witness_has_at_least_two_surfaces
    reasoningContradictionWitness reasoningContradictionWitness_minimal

/-! ## Repair composition -/

variable {X : Type*}

/-- Compose an existing epistemic repair with a second expanding repair pass. -/
def composeRepairSpec
    (S : EpistemicControlSpec X)
    (extraRepair : ℕ → Set X → Set X)
    (extra_expands : ∀ t A, A ⊆ extraRepair t A) :
    EpistemicControlSpec X where
  initialRegion := S.initialRegion
  massModel := S.massModel
  contradictionUpdate := S.contradictionUpdate
  repairUpdate := fun t A => extraRepair t (S.repairUpdate t A)
  contradiction_contracts := S.contradiction_contracts
  repair_expands := by
    intro t A x hx
    exact extra_expands t (S.repairUpdate t A)
      (S.repair_expands t A hx)

/-- A composed repair spec still inherits the same net-action kernel whenever
its composed trajectory is positive. -/
theorem composed_repair_kernel
    (S : EpistemicControlSpec X)
    (extraRepair : ℕ → Set X → Set X)
    (extra_expands : ∀ t A, A ⊆ extraRepair t A)
    (n : ℕ)
    (hpos :
      PositiveTrajectory
        (toProblemSpec (composeRepairSpec S extraRepair extra_expands)) n) :
    coherentMass (composeRepairSpec S extraRepair extra_expands) n =
      coherentMass (composeRepairSpec S extraRepair extra_expands) 0 *
        Real.exp
          (-(cumulativeEpistemicNetAction
            (composeRepairSpec S extraRepair extra_expands) n)) := by
  exact epistemic_control_composition_kernel
    (composeRepairSpec S extraRepair extra_expands) n hpos

/-- A second toy repair pass that also preserves the coherent-context state. -/
def llmSecondRepairUpdate (_t : ℕ)
    (A : Set LLMEpistemicState) : Set LLMEpistemicState :=
  A ∪ {LLMEpistemicState.coherentContext}

theorem llmSecondRepair_expands
    (t : ℕ) (A : Set LLMEpistemicState) :
    A ⊆ llmSecondRepairUpdate t A := by
  intro x hx
  exact Or.inl hx

def llmComposedRepairSpec : EpistemicControlSpec LLMEpistemicState :=
  composeRepairSpec llmReasoningSpec
    llmSecondRepairUpdate llmSecondRepair_expands

theorem llmComposedRepair_positiveTrajectory (n : ℕ) :
    PositiveTrajectory (toProblemSpec llmComposedRepairSpec) n where
  feasible_pos := by
    intro t ht
    dsimp [feasibleMass, toProblemSpec, llmComposedRepairSpec,
      composeRepairSpec, llmReasoningSpec, llmMassModel]
    exact regularizedLLMMass_pos _
  contracted_pos := by
    intro t ht
    dsimp [contractedMass, toProblemSpec, llmComposedRepairSpec,
      composeRepairSpec, llmReasoningSpec, llmMassModel]
    exact regularizedLLMMass_pos _

theorem llm_composed_repair_kernel (n : ℕ) :
    coherentMass llmComposedRepairSpec n =
      coherentMass llmComposedRepairSpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction llmComposedRepairSpec n)) := by
  exact composed_repair_kernel llmReasoningSpec
    llmSecondRepairUpdate llmSecondRepair_expands n
    (llmComposedRepair_positiveTrajectory n)

end

end Survival.LLMMemoryReasoningStrengtheningToy
