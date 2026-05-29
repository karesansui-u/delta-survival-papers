import Survival.EpistemicBenchmarkProtocol
import Survival.SoftwareEvidencePacketToy

/-!
# Software Evidence Net-Action Bridge

This file connects the software evidence-packet layer to the evaluation /
benchmark protocol layer.

It does not prove real repository semantics, workflow correctness, benchmark
validity, or maintainer judgment.  Instead, it packages the obligations a
software evidence workflow must supply before it can invoke the finite
epistemic-control benchmark comparison:

* eligible, key-sound evidence;
* a sound dependency packet;
* a repair packet covering the dependency closure;
* a valid benchmark protocol carrying the metric-dominance and readout
  alignment witnesses.

Under those explicit assumptions, the software evidence package can invoke the
same `NetActionNoWorse` and coherent-mass comparison theorems.
-/

namespace Survival.SoftwareEvidenceNetActionBridge

open Survival.EpistemicBenchmarkProtocol
open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.EvidencePacketBridge
open Survival.SoftwareContractToyRepository
open Survival.SoftwareEvidencePacketToy

noncomputable section

variable {X RepairAction : Type*}

/-- A software evidence benchmark protocol packages the evidence-side objects
beside the generic benchmark protocol. -/
structure SoftwareEvidenceBenchmarkProtocol
    (X RepairAction : Type*) where
  protocol : BenchmarkProtocol X
  evidence : EvidencePacket ContractSurface ToyContractKey SoftwareProvenance
  dependencyPacket : EvidenceDependencyPacket ContractSurface
  repairPacket : RepairPacket ContractSurface RepairAction

/-- Validity witnesses for the software evidence bridge.

These are still assumptions.  A real implementation or benchmark must justify
them outside this Lean file. -/
structure ValidSoftwareEvidenceBenchmarkProtocol
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction) : Prop where
  evidence_eligible : EligibleEvidence P.evidence
  evidence_key_sound : SurfaceSharesPacketKey toySurfaceKey P.evidence
  repair_covers_dependency_closure :
    TouchesAll P.repairPacket (dependencyClosureSurfaces P.dependencyPacket)
  benchmark_valid : ValidEpistemicBenchmarkProtocol P.protocol

/-- Eligible, key-sound software evidence is a contradiction witness for the
selected contract surface. -/
def softwareEvidenceContradictionWitness
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    ContradictionWitness ContractSurface ToyContractKey SoftwareProvenance
      toySurfaceKey where
  packet := P.evidence
  eligible := hvalid.evidence_eligible
  keySound := hvalid.evidence_key_sound

/-- A valid software evidence protocol has a multi-surface contradiction
witness. -/
theorem software_evidence_has_two_surfaces
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    HasAtLeastTwoSurfaces P.evidence.surfaces :=
  witness_has_two_surfaces
    (softwareEvidenceContradictionWitness P hvalid)

/-- Repair coverage of the dependency closure covers the localized semantic
invalidations. -/
theorem software_evidence_repair_touches_invalidations
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    TouchesAll P.repairPacket
      (invalidatedSurfaces P.dependencyPacket) :=
  repair_touches_invalidations P.dependencyPacket
    P.repairPacket hvalid.repair_covers_dependency_closure

/-- The software evidence package exposes the valid generic benchmark
protocol it carries. -/
theorem software_evidence_benchmark_valid
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    ValidEpistemicBenchmarkProtocol P.protocol :=
  hvalid.benchmark_valid

/-- A valid software evidence benchmark protocol witnesses no-worse net
action through the generic benchmark protocol. -/
theorem software_evidence_implies_net_action_no_worse
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    NetActionNoWorse P.protocol.controlled P.protocol.baseline
      P.protocol.horizon :=
  benchmark_protocol_implies_net_action_no_worse
    P.protocol hvalid.benchmark_valid

/-- End-to-end software evidence bridge.

If the software evidence packet is eligible and key-sound, dependency repair
covers the closure, and the benchmark protocol is valid, then the controlled
layer preserves at least the baseline coherent mass in the finite accounting
model. -/
theorem software_evidence_implies_controlled_mass_ge_baseline
    (P : SoftwareEvidenceBenchmarkProtocol X RepairAction)
    (hvalid : ValidSoftwareEvidenceBenchmarkProtocol P) :
    coherentMass P.protocol.baseline P.protocol.horizon ≤
      coherentMass P.protocol.controlled P.protocol.horizon :=
  benchmark_protocol_implies_controlled_mass_ge_baseline
    P.protocol hvalid.benchmark_valid

end

end Survival.SoftwareEvidenceNetActionBridge
