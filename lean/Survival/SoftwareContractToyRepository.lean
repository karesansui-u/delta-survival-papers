import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Survival.EpistemicControlBridge

/-!
# Software Contract Toy Repository

This module gives a deliberately tiny repository-contract surface that
instantiates `EpistemicControlBridge`.

It does not formalize program semantics, repository correctness, or detector
quality.  The point is narrower: a finite software contract surface can be
represented as an epistemic control layer whose contradiction and repair
operators satisfy the same interface used by the general net-action kernel.
-/

open scoped BigOperators

namespace Survival.SoftwareContractToyRepository

open Survival.EpistemicControlBridge
open Survival.GeneralStateDynamics

noncomputable section

/-! ## Toy repository vocabulary -/

/-- Surfaces across which a repository-level contract may be stated or used. -/
inductive ContractSurface where
  | api
  | docs
  | caller
  | test
  deriving DecidableEq, Fintype, Repr

/-- Lightweight provenance labels for toy contract claims. -/
inductive SoftwareProvenance where
  | implementation
  | referenceDocs
  | downstreamCaller
  | regressionTest
  deriving DecidableEq, Fintype, Repr

/-- Toy claims about one frozen contract. -/
inductive ContractClaim where
  | apiAllowsEmptyToken
  | docsRejectEmptyToken
  | callerSendsEmptyToken
  | testCoversEmptyToken
  deriving DecidableEq, Fintype, Repr

/-- A claim together with its repository surface and provenance. -/
structure ContractRecord where
  surface : ContractSurface
  provenance : SoftwareProvenance
  claim : ContractClaim
  deriving DecidableEq, Repr

/-- Complete toy epistemic configurations for the selected repository scope. -/
inductive ToyRepoState where
  | baselineCoherent
  | docImplementationMismatch
  | callerApiMismatch
  | synchronizedPatch
  deriving DecidableEq, Fintype, Repr

/-! ## A small positive mass readout -/

/-- One-state indicator used by the explicit toy count. -/
def stateIndicator (A : Set ToyRepoState) (x : ToyRepoState) : ℝ :=
  by
    classical
    exact if x ∈ A then 1 else 0

/-- Count the toy states in a region.  We keep this count explicit so the toy
mass values can be shown without importing a heavier finite-cardinality API. -/
def stateCount (A : Set ToyRepoState) : ℝ :=
  stateIndicator A ToyRepoState.baselineCoherent +
    stateIndicator A ToyRepoState.docImplementationMismatch +
    stateIndicator A ToyRepoState.callerApiMismatch +
    stateIndicator A ToyRepoState.synchronizedPatch

/-- A regularized count keeps every finite toy region positive for log-ratio
accounting.  This is a toy readout, not an empirical natural mass claim. -/
def regularizedStateMass (A : Set ToyRepoState) : ℝ :=
  1 + stateCount A

theorem stateIndicator_nonneg (A : Set ToyRepoState) (x : ToyRepoState) :
    0 ≤ stateIndicator A x := by
  classical
  unfold stateIndicator
  by_cases hmem : x ∈ A <;> simp [hmem]

theorem stateIndicator_mono {A B : Set ToyRepoState} (hAB : A ⊆ B)
    (x : ToyRepoState) :
    stateIndicator A x ≤ stateIndicator B x := by
  classical
  unfold stateIndicator
  by_cases hA : x ∈ A
  · have hB : x ∈ B := hAB hA
    simp [hA, hB]
  · by_cases hB : x ∈ B <;> simp [hA, hB]

theorem stateCount_nonneg (A : Set ToyRepoState) :
    0 ≤ stateCount A := by
  unfold stateCount
  linarith [stateIndicator_nonneg A ToyRepoState.baselineCoherent,
    stateIndicator_nonneg A ToyRepoState.docImplementationMismatch,
    stateIndicator_nonneg A ToyRepoState.callerApiMismatch,
    stateIndicator_nonneg A ToyRepoState.synchronizedPatch]

theorem stateCount_mono {A B : Set ToyRepoState} (hAB : A ⊆ B) :
    stateCount A ≤ stateCount B := by
  unfold stateCount
  linarith [stateIndicator_mono hAB ToyRepoState.baselineCoherent,
    stateIndicator_mono hAB ToyRepoState.docImplementationMismatch,
    stateIndicator_mono hAB ToyRepoState.callerApiMismatch,
    stateIndicator_mono hAB ToyRepoState.synchronizedPatch]

theorem regularizedStateMass_pos (A : Set ToyRepoState) :
    0 < regularizedStateMass A := by
  unfold regularizedStateMass
  have hnonneg : 0 ≤ stateCount A := stateCount_nonneg A
  linarith

theorem regularizedStateMass_mono {A B : Set ToyRepoState} (hAB : A ⊆ B) :
    regularizedStateMass A ≤ regularizedStateMass B := by
  unfold regularizedStateMass
  have hmono : stateCount A ≤ stateCount B := stateCount_mono hAB
  linarith

/-- The mass model used by the toy repository surface. -/
def toyMassModel : MassModel ToyRepoState where
  mass := regularizedStateMass
  mono := by
    intro A B hAB
    exact regularizedStateMass_mono hAB

theorem toyMassModel_pos (A : Set ToyRepoState) :
    0 < toyMassModel.mass A := by
  simpa [toyMassModel] using regularizedStateMass_pos A

/-! ## Contract contradiction and repair operators -/

/-- Coherent toy states after the disputed contract has been scoped. -/
def coherentContractRegion : Set ToyRepoState :=
  {s | s = ToyRepoState.baselineCoherent ∨ s = ToyRepoState.synchronizedPatch}

/-- Before diagnosis, all four toy configurations remain possible. -/
def initialRepositoryRegion : Set ToyRepoState :=
  Set.univ

/-- Discovering or admitting a contract contradiction contracts the feasible
repository-contract region to scoped coherent configurations. -/
def contractContradictionUpdate (_t : ℕ) (A : Set ToyRepoState) : Set ToyRepoState :=
  A ∩ coherentContractRegion

/-- A synchronization patch reopens the patched coherent configuration. -/
def contractRepairUpdate (_t : ℕ) (A : Set ToyRepoState) : Set ToyRepoState :=
  A ∪ {ToyRepoState.synchronizedPatch}

theorem contractContradictionUpdate_contracts (t : ℕ) (A : Set ToyRepoState) :
    contractContradictionUpdate t A ⊆ A := by
  intro x hx
  exact hx.1

theorem contractRepairUpdate_expands (t : ℕ) (A : Set ToyRepoState) :
    A ⊆ contractRepairUpdate t A := by
  intro x hx
  exact Or.inl hx

/-- Concrete toy repository surface as an epistemic-control specification. -/
def toyRepositorySpec : EpistemicControlSpec ToyRepoState where
  initialRegion := initialRepositoryRegion
  massModel := toyMassModel
  contradictionUpdate := contractContradictionUpdate
  repairUpdate := contractRepairUpdate
  contradiction_contracts := contractContradictionUpdate_contracts
  repair_expands := contractRepairUpdate_expands

/-- The toy mass readout makes the positivity side-condition automatic. -/
theorem toyRepository_positiveTrajectory (n : ℕ) :
    PositiveTrajectory (toProblemSpec toyRepositorySpec) n where
  feasible_pos := by
    intro t ht
    dsimp [feasibleMass, toProblemSpec, toyRepositorySpec, toyMassModel]
    exact regularizedStateMass_pos _
  contracted_pos := by
    intro t ht
    dsimp [contractedMass, toProblemSpec, toyRepositorySpec, toyMassModel]
    exact regularizedStateMass_pos _

/-- The concrete toy repository inherits the epistemic-control net-action
kernel without any additional software-semantics claim. -/
theorem toyRepository_composition_kernel (n : ℕ) :
    coherentMass toyRepositorySpec n =
      coherentMass toyRepositorySpec 0 *
        Real.exp (-(cumulativeEpistemicNetAction toyRepositorySpec n)) := by
  exact epistemic_control_composition_kernel toyRepositorySpec n
    (toyRepository_positiveTrajectory n)

/-! ## Concrete toy mass values -/

theorem toyRepository_stateCount_initial :
    stateCount initialRepositoryRegion = 4 := by
  simp [stateCount, stateIndicator, initialRepositoryRegion]
  norm_num

theorem toyRepository_stateCount_coherentContractRegion :
    stateCount coherentContractRegion = 2 := by
  simp [stateCount, stateIndicator, coherentContractRegion]
  norm_num

theorem toyRepository_coherentMass_zero :
    coherentMass toyRepositorySpec 0 = 5 := by
  change regularizedStateMass initialRepositoryRegion = 5
  rw [regularizedStateMass, toyRepository_stateCount_initial]
  norm_num

theorem toyRepository_feasibleRegion_one :
    feasibleEpistemicRegion toyRepositorySpec 1 = coherentContractRegion := by
  ext x
  constructor
  · intro hx
    rcases hx with hx | hx
    · exact hx.2
    · exact Or.inr hx
  · intro hx
    exact Or.inl ⟨trivial, hx⟩

theorem toyRepository_coherentMass_one :
    coherentMass toyRepositorySpec 1 = 3 := by
  change toyMassModel.mass (feasible (toProblemSpec toyRepositorySpec) 1) = 3
  rw [show feasible (toProblemSpec toyRepositorySpec) 1 =
      coherentContractRegion from toyRepository_feasibleRegion_one]
  change regularizedStateMass coherentContractRegion = 3
  rw [regularizedStateMass, toyRepository_stateCount_coherentContractRegion]
  norm_num

theorem contractStep_preserves_coherentContractRegion (t : ℕ) :
    contractRepairUpdate t (contractContradictionUpdate t coherentContractRegion) =
      coherentContractRegion := by
  ext x
  constructor
  · intro hx
    rcases hx with hx | hx
    · exact hx.2
    · exact Or.inr hx
  · intro hx
    rcases hx with hbase | hsync
    · exact Or.inl ⟨Or.inl hbase, Or.inl hbase⟩
    · exact Or.inr hsync

theorem toyRepository_feasibleRegion_two :
    feasibleEpistemicRegion toyRepositorySpec 2 = coherentContractRegion := by
  change contractRepairUpdate 1
      (contractContradictionUpdate 1 (feasibleEpistemicRegion toyRepositorySpec 1)) =
    coherentContractRegion
  rw [toyRepository_feasibleRegion_one]
  exact contractStep_preserves_coherentContractRegion 1

theorem toyRepository_coherentMass_two :
    coherentMass toyRepositorySpec 2 = 3 := by
  change toyMassModel.mass (feasible (toProblemSpec toyRepositorySpec) 2) = 3
  rw [show feasible (toProblemSpec toyRepositorySpec) 2 =
      coherentContractRegion from toyRepository_feasibleRegion_two]
  change regularizedStateMass coherentContractRegion = 3
  rw [regularizedStateMass, toyRepository_stateCount_coherentContractRegion]
  norm_num

/-! ## Toy memory / claim-admission filter -/

/-- Two raw claim candidates for the toy repository gate. -/
inductive RawContractCandidate where
  | unsupportedStyleComment
  | validatedContractMismatch
  deriving DecidableEq, Fintype, Repr

/-- Accept-all treats every raw candidate as if it contracted the region.
The filtered policy blocks unsupported style comments while accepting validated
contract mismatches. -/
def toyClaimAdmission : MemoryAdmission RawContractCandidate ToyRepoState where
  acceptAllAfter := fun _raw before => contractContradictionUpdate 0 before
  filteredAfter := fun raw before =>
    match raw with
    | RawContractCandidate.unsupportedStyleComment => before
    | RawContractCandidate.validatedContractMismatch =>
        contractContradictionUpdate 0 before

theorem toyClaimAdmission_sound
    (raw : RawContractCandidate) (before : Set ToyRepoState) :
    toyClaimAdmission.acceptAllAfter raw before ⊆
      toyClaimAdmission.filteredAfter raw before := by
  intro x hx
  cases raw
  · exact hx.1
  · exact hx

/-- The bridge's filter lemma specializes to the toy repository admission gate. -/
theorem toyClaimAdmission_no_more_loss
    (raw : RawContractCandidate) (before : Set ToyRepoState) :
    lossFrom toyMassModel before (toyClaimAdmission.filteredAfter raw before) ≤
      lossFrom toyMassModel before (toyClaimAdmission.acceptAllAfter raw before) := by
  exact eligibility_filter_no_more_loss_under_soundness
    toyMassModel toyClaimAdmission raw before
    (toyMassModel_pos before)
    (toyMassModel_pos (toyClaimAdmission.acceptAllAfter raw before))
    (toyClaimAdmission_sound raw before)

/-! ## Toy dependency closure -/

/-- A tiny dependency closure for the selected contract surface. -/
def contractDownstream : ContractSurface → Set ContractSurface
  | ContractSurface.api =>
      {s | s = ContractSurface.api ∨ s = ContractSurface.docs ∨
        s = ContractSurface.caller ∨ s = ContractSurface.test}
  | ContractSurface.docs =>
      {s | s = ContractSurface.docs ∨ s = ContractSurface.test}
  | ContractSurface.caller =>
      {s | s = ContractSurface.caller ∨ s = ContractSurface.test}
  | ContractSurface.test =>
      {s | s = ContractSurface.test}

/-- The toy graph is just its downstream-closure oracle. -/
def toyDependencyGraph : DependencyGraph ContractSurface where
  downstream := contractDownstream

/-- In the toy model, semantic dependency is exactly the listed downstream
closure.  A real instantiation would have to justify this relation separately. -/
def toySemanticDepends (root x : ContractSurface) : Prop :=
  x ∈ contractDownstream root

theorem toyDependencyGraph_sound :
    SoundDependencyClosure toyDependencyGraph toySemanticDepends := by
  intro root x hdep
  exact hdep

/-- A no-op rewrite used to specialize the dependency-localization bridge. -/
def toyDependencyRewrite : DependencyRewrite ContractSurface where
  apply := fun G => G

/-- Semantic invalidation is localized to the graph downstream closure in the
toy repository surface. -/
theorem toyDependencyRewrite_localizes (roots : Set ContractSurface) :
    semanticInvalidation toySemanticDepends roots ⊆
      downstreamClosure (toyDependencyRewrite.apply toyDependencyGraph) roots := by
  exact dependency_rewrite_localizes_under_sound_closure
    toyDependencyRewrite toyDependencyGraph toySemanticDepends roots
    toyDependencyGraph_sound

end

end Survival.SoftwareContractToyRepository
