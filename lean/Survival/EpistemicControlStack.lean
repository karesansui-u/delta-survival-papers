import Survival.EpistemicControlComparison
import Survival.EpistemicControlEvaluationContract
import Survival.EpistemicBenchmarkProtocol
import Survival.LLMMemoryUseConditionToy
import Survival.SoftwareEvidencePacketToy
import Survival.DependencyClosureBudgetToy
import Survival.LLMMemoryReasoningStrengtheningToy

/-!
# Epistemic Control Stack

This file is a single Lean entry point for the checked epistemic-control stack.

It does not add stronger semantic claims.  It collects the main bridge,
evidence-packet, LLM-toy, memory-use-condition, software-toy,
software-evidence, dependency-budget, and memory / reasoning strengthening
theorems under short stack-level names.
-/

namespace Survival.EpistemicControlStack

open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.EpistemicControlEvaluationContract
open Survival.EpistemicBenchmarkProtocol
open Survival.EvidencePacketBridge
open Survival.GeneralStateDynamics
open Survival.LLMEpistemicControlToy
open Survival.LLMMemoryUseConditionToy
open Survival.SoftwareContractToyRepository
open Survival.SoftwareEvidencePacketToy
open Survival.DependencyClosureBudgetToy
open Survival.LLMMemoryReasoningStrengtheningToy

noncomputable section

/-! ## Abstract bridge entry points -/

theorem stack_epistemic_kernel
    {X : Type*} (S : EpistemicControlSpec X) (n : ℕ)
    (hpos : PositiveTrajectory (toProblemSpec S) n) :
    coherentMass S n =
      coherentMass S 0 * Real.exp (-(cumulativeEpistemicNetAction S n)) :=
  epistemic_control_composition_kernel S n hpos

theorem stack_controlled_coherentMass_ge_baseline
    {X : Type*}
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hcmp : BaselineComparison controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n :=
  controlled_coherentMass_ge_baseline
    controlled baseline n hcontrolled hbaseline hcmp

theorem stack_metric_net_action_no_worse
    {X : Type*}
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hdom : EvaluationMetricDominance M n)
    (hreadout : MetricsReadoutMatchesNetAction M controlled baseline n) :
    NetActionNoWorse controlled baseline n :=
  metric_net_action_no_worse M controlled baseline n hdom hreadout

theorem stack_metrics_controlled_coherentMass_ge_baseline
    {X : Type*}
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hsame : SameInitialMass controlled baseline)
    (hdom : EvaluationMetricDominance M n)
    (hreadout : MetricsReadoutMatchesNetAction M controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n :=
  metrics_controlled_coherentMass_ge_baseline
    M controlled baseline n hcontrolled hbaseline hsame hdom hreadout

theorem stack_benchmark_protocol_implies_net_action_no_worse
    {X : Type*}
    (P : BenchmarkProtocol X)
    (hvalid : ValidEpistemicBenchmarkProtocol P) :
    NetActionNoWorse P.controlled P.baseline P.horizon :=
  benchmark_protocol_implies_net_action_no_worse P hvalid

theorem stack_benchmark_protocol_implies_controlled_mass_ge_baseline
    {X : Type*}
    (P : BenchmarkProtocol X)
    (hvalid : ValidEpistemicBenchmarkProtocol P) :
    coherentMass P.baseline P.horizon ≤
      coherentMass P.controlled P.horizon :=
  benchmark_protocol_implies_controlled_mass_ge_baseline P hvalid

theorem stack_evidence_filter_no_more_loss
    {Raw State : Type*} (M : MassModel State)
    (A : EvidenceAdmission Raw State)
    (raw : Raw) (before : Set State)
    (hbefore : 0 < M.mass before)
    (haccept : 0 < M.mass (A.acceptAllAfter raw before)) :
    lossFrom M before (A.eligibleAfter raw before) ≤
      lossFrom M before (A.acceptAllAfter raw before) :=
  evidence_filter_no_more_loss M A raw before hbefore haccept

theorem stack_evidence_invalidations_localized
    {Surface : Type*} (p : EvidenceDependencyPacket Surface) :
    invalidatedSurfaces p ⊆ dependencyClosureSurfaces p :=
  evidence_invalidations_localized p

theorem stack_repair_touches_invalidations
    {Surface RepairAction : Type*}
    (p : EvidenceDependencyPacket Surface)
    (repair : RepairPacket Surface RepairAction)
    (hrepair : TouchesAll repair (dependencyClosureSurfaces p)) :
    TouchesAll repair (invalidatedSurfaces p) :=
  repair_touches_invalidations p repair hrepair

/-! ## LLM toy entry points -/

theorem stack_llm_reasoning_kernel (n : ℕ) :
    coherentMass llmReasoningSpec n =
      coherentMass llmReasoningSpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction llmReasoningSpec n)) :=
  llmReasoningToy_composition_kernel n

theorem stack_llm_reasoning_witness_has_two_surfaces :
    HasAtLeastTwoSurfaces reasoningContradictionWitness.packet.surfaces :=
  llmReasoningContradictionWitness_has_two_surfaces

theorem stack_llm_stale_memory_rejected :
    ¬ EligibleEvidence
      (memoryEvidencePacket RawMemoryItem.staleUnscopedMemory) :=
  staleMemory_not_eligible

theorem stack_llm_eligible_memory_no_more_loss
    (raw : RawMemoryItem) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (llmMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (llmMemoryAdmission.acceptAllAfter raw before) :=
  eligibleMemory_no_more_loss raw before

theorem stack_llm_premise_update_localized :
    invalidatedSurfaces premiseUpdateDependencyPacket ⊆
      dependencyClosureSurfaces premiseUpdateDependencyPacket :=
  premiseUpdate_invalidations_localized

theorem stack_llm_repair_touches_downstream_invalidations :
    TouchesAll premiseRepairPacket
      (invalidatedSurfaces premiseUpdateDependencyPacket) :=
  repairTouches_downstreamInvalidations

theorem stack_llm_invalidated_ncard_le_repair_touched_ncard :
    (invalidatedSurfaces premiseUpdateDependencyPacket).ncard ≤
      premiseRepairPacket.touched.ncard :=
  llm_invalidated_ncard_le_repair_touched_ncard

/-! ## LLM memory use-condition entry points -/

theorem stack_llm_memory_without_permission_rejected
    {r : LongTermMemoryRecord}
    (h : r.useCondition.permission = MemoryPermission.denied) :
    ¬ EligibleLongTermMemory r :=
  memory_without_permission_not_eligible h

theorem stack_llm_deleted_memory_rejected
    {r : LongTermMemoryRecord}
    (h : r.useCondition.deletion = MemoryDeletionState.deleted) :
    ¬ EligibleLongTermMemory r :=
  deleted_memory_not_eligible h

theorem stack_llm_out_of_scope_memory_rejected
    {r : LongTermMemoryRecord}
    (h : r.useCondition.scope = MemoryScope.outOfScope) :
    ¬ EligibleLongTermMemory r :=
  out_of_scope_memory_not_eligible h

theorem stack_llm_unstable_memory_rejected
    {r : LongTermMemoryRecord}
    (h : r.useCondition.stability = MemoryStability.volatile) :
    ¬ EligibleLongTermMemory r :=
  unstable_memory_not_eligible h

theorem stack_llm_action_blocked_memory_rejected
    {r : LongTermMemoryRecord}
    (h : r.useCondition.action = MemoryActionEligibility.blocked) :
    ¬ EligibleLongTermMemory r :=
  action_blocked_memory_not_eligible h

theorem stack_llm_scoped_correction_record_eligible :
    EligibleLongTermMemory scopedCorrectionRecord :=
  scopedCorrectionRecord_eligible

theorem stack_llm_use_condition_memory_no_more_loss
    (raw : RawUseConditionMemory) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (useConditionMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (useConditionMemoryAdmission.acceptAllAfter raw before) :=
  useConditionMemory_no_more_loss raw before

/-! ## LLM memory / reasoning strengthening entry points -/

theorem stack_llm_revoked_lifecycle_memory_rejected :
    ¬ EligibleLifecycleMemory revokedScopedMemoryRecord :=
  revokedScopedMemoryRecord_not_eligible

theorem stack_llm_expired_lifecycle_memory_rejected :
    ¬ EligibleLifecycleMemory expiredScopedMemoryRecord :=
  expiredScopedMemoryRecord_not_eligible

theorem stack_llm_lifecycle_memory_no_more_loss
    (raw : RawLifecycleMemory) (before : Set LLMEpistemicState) :
    lossFrom llmMassModel before
        (lifecycleMemoryAdmission.eligibleAfter raw before) ≤
      lossFrom llmMassModel before
        (lifecycleMemoryAdmission.acceptAllAfter raw before) :=
  lifecycleMemory_no_more_loss raw before

theorem stack_llm_retrieval_packet_cannot_overwrite_userCorrection_packet :
    ¬ PacketMayOverwrite retrievalMemoryPacket userCorrectionMemoryPacket :=
  retrieval_packet_cannot_overwrite_userCorrection_packet

theorem stack_llm_reasoning_witness_minimal :
    MinimalContradictionWitness reasoningContradictionWitness :=
  reasoningContradictionWitness_minimal

theorem stack_llm_composed_repair_kernel (n : ℕ) :
    coherentMass llmComposedRepairSpec n =
      coherentMass llmComposedRepairSpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction llmComposedRepairSpec n)) :=
  llm_composed_repair_kernel n

/-! ## Software toy entry points -/

theorem stack_software_repository_kernel (n : ℕ) :
    coherentMass toyRepositorySpec n =
      coherentMass toyRepositorySpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction toyRepositorySpec n)) :=
  toyRepository_composition_kernel n

theorem stack_software_validated_candidate_eligible :
    EligibleEvidence
      (rawCandidateEvidence RawContractCandidate.validatedContractMismatch) :=
  toyValidatedCandidate_eligible

theorem stack_software_evidence_admission_no_more_loss
    (raw : RawContractCandidate) (before : Set ToyRepoState) :
    lossFrom toyMassModel before
        (toyEvidenceAdmission.eligibleAfter raw before) ≤
      lossFrom toyMassModel before
        (toyEvidenceAdmission.acceptAllAfter raw before) :=
  toyEvidenceAdmission_no_more_loss raw before

theorem stack_software_repair_touches_invalidations :
    TouchesAll toyRepairPacket
      (invalidatedSurfaces toyEvidenceDependencyPacket) :=
  toyRepair_touches_invalidations

theorem stack_software_invalidated_ncard_le_repair_touched_ncard :
    (invalidatedSurfaces toyEvidenceDependencyPacket).ncard ≤
      toyRepairPacket.touched.ncard :=
  software_invalidated_ncard_le_repair_touched_ncard

end

end Survival.EpistemicControlStack
