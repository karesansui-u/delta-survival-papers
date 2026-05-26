Software Contract-Coherence as an Epistemic-Control Instantiation
=================================================================

Status: lightweight instantiation note for `llm_epistemic_control_bridge.md`
and `EvidencePacketBridge.lean`.

This note does not add a new support claim.  It records how the software
contract-coherence diagnostics track can be read as the first concrete
engineering instantiation of the abstract epistemic-control bridge.


1. Role
-------

`EpistemicControlBridge.lean` is not limited to chat memory.  It formalizes an
abstract interface:

```text
state space
coherent region
mass readout
contradiction update
repair update
filter / dependency guard lemmas
```

`EvidencePacketBridge.lean` adds the implementation-boundary schema that sits
between this abstract interface and concrete artifacts:

```text
provenance
eligibility status
multi-surface contradiction witness
dependency closure
repair coverage
```

Software contract-coherence diagnostics fits this interface because a
repository snapshot contains many epistemic claims about how a system behaves:
API contracts, documentation promises, default-value conventions, guard
conditions, serialization formats, config-runtime assumptions, lifecycle
promises, tests, and caller expectations.

One implementation workflow searches for distributed-contract contradictions
in that epistemic surface.  This note maps the workflow to the bridge; it does
not prove detector correctness.


2. Instantiation Map
--------------------

| Bridge object | Software contract-coherence reading |
|---|---|
| `X` | complete software-contract epistemic configurations for a frozen repository scope |
| `initialRegion` | configurations in which the selected contract surfaces remain mutually coherent |
| `massModel` | abstract coherent-region mass; not directly counted in current field evidence |
| `contradictionUpdate` | admission or discovery of a distributed-contract mismatch |
| `repairUpdate` | patch, propagation, documentation synchronization, test update, rollback, or refactor that restores consistency |
| `contradiction_contracts` | a validated mismatch cannot create additional coherent future modification paths for the same contract scope |
| `repair_expands` | a valid repair reopens at least the post-contradiction coherent region, and may reopen more |
| `cumulativeEpistemicNetAction` | cumulative contradiction pressure minus explicit repair, only when repair is measured |

In the current static-detection track, the main measured object is the
detection of contradiction pressure.  A full \(B_t=d_t-r_t\) software balance
track would require explicit repair windows and recurrence / future-cost
endpoints.  That is intentionally outside the current field-demonstration
claim.

2.1 Evaluation Contract Reading
-------------------------------

`../../../lean/Survival/EpistemicControlEvaluationContract.lean` gives the
finite bridge from measured loss / repair readouts to the baseline-comparison
premise.  In a software contract-coherence workflow, this means that a future
evaluation can connect to `NetActionNoWorse` only after it fixes:

- a per-step contradiction-loss readout for baseline and controlled workflows;
- a per-step repair-gain readout for baseline and controlled workflows;
- a proof obligation that the cumulative metric sums match the bridge-level
  cumulative net actions;
- the same initial coherent region / mass condition.

The Lean theorem then says that metric dominance can witness the comparison
premise. It does not say that the current field-demonstration metrics already
measure \(d_t\), \(r_t\), or \(B_t\) for a real repository.


3. Contract Surfaces
--------------------

A software-contract epistemic configuration may include:

- contract claims extracted from code, tests, docs, examples, configs, and API
  boundaries;
- provenance for each claim: file, symbol, commit, route, documentation page,
  test case, or maintainer-facing evidence packet;
- dependency edges among producer / consumer surfaces;
- validity status for candidate contradictions;
- patch or synchronization actions that restore consistency.

The existing structural-contradiction definition in
`analysis/software_contract_coherence_diagnostics_note.md` supplies the
admission discipline:

1. the referenced surfaces exist at the frozen commit;
2. the surfaces share a contract or invariant;
3. the surfaces disagree in a behaviorally relevant way;
4. the divergence is not clearly intentional or explicitly supported;
5. the claim can be made from frozen evidence, not model speculation.

This plays the role of a software-specific memory / claim eligibility filter.
It rejects style-only comments, isolated local bugs, pure performance opinions,
and generic best-practice advice before they are treated as structural
contradictions.

The same discipline is now reflected in the evidence-packet bridge: unsupported
or style-only packets are ineligible, missing provenance blocks eligibility, and
eligible contradiction witnesses must carry at least two distinct surfaces under
a shared contract key.


4. Bridge Theorem Reading
-------------------------

If a software-contract control layer supplies the bridge assumptions, then the
Lean bridge gives the same finite net-action kernel:

```text
coherentMass n =
  coherentMass 0 * exp (-(cumulativeEpistemicNetAction n))
```

For software, the safe reading is conditional:

- a validated distributed-contract mismatch is a contraction-like update;
- a maintainer-accepted or test-backed synchronization is a repair-like update;
- an evidence gate that preserves valid structural roots while excluding
  unsupported candidates can be read through the filter lemma;
- a dependency map that soundly over-approximates producer / consumer influence
  can be read through the dependency-rewrite localization lemma.

The theorem does not say that the present contract-coherence workflow has
proven a natural mass model, measured coherent mass, or estimated long-term
software collapse.  It says that once those finite interface conditions are
supplied, the existing structural-persistence accounting kernel applies.


5. Evidence Boundary
--------------------

The current evidence remains exactly the evidence recorded in the software
contract-coherence profile:

- field demonstration / maintainer acceptance in public OSS workflows;
- bounded internal calibration against same-scope generic review;
- no raw precision / recall estimate;
- no direct software-collapse prediction;
- no M-side validation.

The bridge instantiation adds explanatory structure, not new validation.
It helps state what kind of object contract-coherence workflows are trying to
control: a repository's distributed contract epistemic state.


6. Lean Evidence-Packet Bridge
------------------------------

The implementation-boundary Lean bridge is:

- `../../../lean/Survival/EvidencePacketBridge.lean`

It does not prove the current workflow correct.  It proves a thin packet schema
that is closer to implementation artifacts than the abstract epistemic-control
interface:

| Lean theorem | Software-contract reading |
|---|---|
| `unsupported_not_eligible`, `styleOnly_not_eligible`, `missing_provenance_not_eligible` | unsupported, style-only, or provenance-free artifacts do not pass the packet gate |
| `witness_has_two_surfaces`, `witness_surface_key_eq` | contradiction witnesses expose multiple surfaces and a shared contract key |
| `evidence_invalidations_localized` | semantic invalidation is localized by a sound dependency closure |
| `repair_touches_invalidations` | a repair covering the dependency closure covers all localized invalidations |
| `evidence_filter_no_more_loss` | the packet eligibility gate inherits the bridge-level no-more-loss admission comparison |


7. Lean Toy Instantiation
-------------------------

The first Lean-side toy instantiation is:

- `../../../lean/Survival/SoftwareContractToyRepository.lean`

It introduces thin software-specific types:

```text
ContractSurface
ContractClaim
SoftwareProvenance
ContractRecord
ToyRepoState
```

The checked toy uses a finite repository-contract state space, a positive toy
mass readout, a contradiction update, a repair update, a claim-admission
filter, and a dependency closure.  It then provides a concrete
`EpistemicControlSpec` and specializes the bridge kernel and guard lemmas:

| Lean theorem | Toy reading |
|---|---|
| `toyRepository_composition_kernel` | the finite repository-contract toy inherits the bridge net-action kernel |
| `toyRepository_coherentMass_zero` | the initial regularized toy mass is 5 |
| `toyRepository_coherentMass_one` | after one scoped contradiction / repair step, the regularized toy mass is 3 |
| `toyRepository_coherentMass_two` | after a second step, the regularized toy mass remains 3 |
| `toyClaimAdmission_no_more_loss` | the toy admission filter incurs no more loss than accept-all under the bridge soundness premise |
| `toyDependencyRewrite_localizes` | toy semantic invalidation is inside the dependency downstream closure |

This remains finite and assumption-explicit.  It does not try to formalize
arbitrary program semantics, whole-repository correctness, or maintainer
judgment.  Its role is to close the first formal loop from abstract bridge to
toy repository surface.


8. Lean Toy Evidence-Packet Instantiation
-----------------------------------------

The next Lean-side toy instantiation is:

- `../../../lean/Survival/SoftwareEvidencePacketToy.lean`

It connects the toy repository surface to `EvidencePacketBridge.lean`.
The checked toy packet layer proves that the finite software toy can emit
packets satisfying the packet bridge guardrails:

| Lean theorem | Toy evidence reading |
|---|---|
| `toyValidatedCandidate_eligible` | a validated raw contract mismatch maps to eligible evidence |
| `toyUnsupportedCandidate_not_eligible` | an unsupported style-only candidate is rejected by the packet gate |
| `toyWitness_has_two_surfaces` | the toy contradiction witness has two distinct surfaces |
| `toyWitness_surface_key_eq` | every witness surface shares the selected toy contract key |
| `toyEvidence_invalidations_localized` | toy semantic invalidations are localized by the toy dependency packet |
| `toyRepair_touches_invalidations` | the toy repair packet covers the localized invalidations |
| `toyEvidenceAdmission_no_more_loss` | the toy evidence-admission gate inherits the no-more-loss comparison |

This is the first checked bridge from a software toy surface to packet-level
evidence conditions. It is still finite and schematic; it does not verify real
program semantics or operational judgment.


9. Lean Dependency-Budget Reading
---------------------------------

The finite dependency-budget layer is:

- `../../../lean/Survival/DependencyClosureBudgetToy.lean`

For the software toy surface, it turns dependency-localization inclusions into
finite cardinality bounds:

| Lean theorem | Toy software reading |
|---|---|
| `software_invalidated_ncard_le_closure_ncard` | localized invalidations are no larger than the checked dependency closure |
| `software_closure_ncard_le_surface_card` | the checked dependency closure is bounded by the finite contract surface |
| `software_invalidated_ncard_le_surface_card` | localized invalidations are bounded by the finite contract surface |
| `software_invalidated_ncard_le_repair_touched_ncard` | a repair covering the closure bounds invalidations by the repair's touched-surface budget |

This is a useful bridge for engineering language: a sound dependency closure
does not merely localize invalidations qualitatively; in the finite toy it also
gives a touched-surface budget. It still does not prove that a real dependency
graph is complete or that a real workflow has found all downstream effects.


10. Non-Claims
-------------

This instantiation note does not claim:

- the detector is proved correct by Lean;
- merged PR counts are raw detector precision;
- software contract contradictions prove long-term software collapse;
- all software bugs are structural contradictions;
- the current field demonstration measures \(B_t\);
- a dependency graph is sound without validation;
- a software-specific mass model has already been empirically identified.

Safe wording:

> Software contract-coherence diagnostics can be read as a concrete engineering
> instantiation candidate of the epistemic-control bridge: distributed contract
> mismatches are contradiction-like updates, and patches or synchronizations are
> repair-like updates.  The current evidence is field and bounded-calibration
> evidence for detection, not a Lean proof of detector correctness or software
> collapse prediction.
