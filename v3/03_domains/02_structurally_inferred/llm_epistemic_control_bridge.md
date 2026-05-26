LLM Epistemic Control Bridge
============================

domain_id: llm_epistemic_control_bridge

domain_name: LLM epistemic control bridge

classification: inference

status: formal_bridge


1. Role
-------

This note records the reader-facing meaning of
`lean/Survival/EpistemicControlBridge.lean` and the implementation-boundary
schema in `lean/Survival/EvidencePacketBridge.lean`.

The bridge does not formalize natural-language semantics, model weights,
attention dynamics, or LLM performance.  It formalizes a narrower interface:
if an LLM control layer can be represented as a finite epistemic state space
with a coherent region, a mass readout, a contradiction update, and a repair
update satisfying the stated contraction / expansion laws, then the existing
structural-persistence net-action kernel applies to that abstract control
layer.

The bridge therefore sits between:

- the Lean core: finite regions, log-ratio accounting, contraction / repair,
  and signed exponential kernels;
- the epistemic-control bridge and evidence-packet bridge: abstract
  contradiction / repair operators plus provenance, eligibility, witness,
  dependency-closure, and repair guardrails;
- the finite toy strengthening layer: dependency-closure cardinality budgets,
  lifecycle memory guards, provenance trust ordering, minimal contradiction
  witnesses, and composed repair wrappers;
- the LLM inference-layer profiles: reasoning degradation, continual-learning
  structural forgetting, and long-term memory control;
- the implementation / experiment layer: contradiction metabolism,
  dependency-aware refresh, memory qualification, and software
  contract-coherence diagnostics.

![Figure. Layered stack connecting the Lean core, the epistemic-control bridge, the evidence-packet bridge, and bounded implementation candidates.](../../01_theory/figures/figure3_epistemic_control_stack_en.svg)


2. Lean Objects
---------------

The bridge is intentionally thin.  Its central structure is
`EpistemicControlSpec X`, where `X` is the type of complete epistemic
configurations.  The bridge does not prescribe whether `X` is represented by
claims, assumptions, provenance labels, dependency graphs, memory records, or
implementation traces.

The mathematically relevant fields are:

| Lean object | Reading |
|---|---|
| `initialRegion` | initially coherent / feasible epistemic configurations |
| `massModel` | pre-fixed mass readout over epistemic regions |
| `contradictionUpdate` | contraction step induced by contradiction, unscoped update, or unsafe admission |
| `repairUpdate` | repair / expansion step induced by scoping, contradiction metabolism, dependency refresh, or controlled readout |
| `contradiction_contracts` | the contradiction update is a contraction |
| `repair_expands` | the repair update expands from the post-contraction region |

The bridge then defines `toProblemSpec`, which converts this interface into the
existing `GeneralStateDynamics.ProblemSpec`.  This conversion is the main point:
the LLM-side object is not a new theory; it is an instance-shaped wrapper for
the already verified contraction / repair kernel.


3. Theorem Map
--------------

The main checked statements are:

| Lean theorem | Meaning |
|---|---|
| `contradiction_update_is_contraction` | contradiction update contracts the current feasible epistemic region |
| `repair_update_is_repair` | repair update expands from the post-contradiction intermediate region |
| `contradiction_update_mass_le_current` | contradiction update cannot increase mass at the contraction substep |
| `repair_update_mass_ge_contradiction` | repair update has at least the post-contradiction mass |
| `epistemicNetAction_eq_contradictionLoss_sub_repairGain` | epistemic net action is `d_t - r_t` |
| `epistemic_control_composition_kernel` | coherent epistemic mass follows the existing signed exponential net-action kernel |
| `controlled_coherentMass_ge_baseline` | a same-initial-mass controlled layer with no larger cumulative net action preserves at least the baseline coherent mass |
| `metric_net_action_no_worse` | per-step loss / repair metric dominance witnesses the no-worse cumulative net-action premise when metric sums match the bridge readout |
| `metrics_controlled_coherentMass_ge_baseline` | evaluation metrics, readout alignment, positivity, and same initial mass invoke the coherent-mass baseline comparison |
| `eligibility_filter_no_more_loss_under_soundness` | a sound memory filter incurs no more log-ratio loss than an accept-all policy under the stated region-containment premise |
| `dependency_rewrite_localizes_under_sound_closure` | a sound rewritten dependency closure localizes semantic invalidation inside graph downstream closure |
| `evidence_filter_no_more_loss` | an evidence eligibility gate inherits the bridge-level admission loss comparison |
| `evidence_invalidations_localized` | evidence dependency packets localize semantic invalidations through a sound closure |
| `repair_touches_invalidations` | a repair covering the dependency closure also covers semantic invalidations |
| `llmReasoningToy_composition_kernel` | a finite LLM reasoning toy inherits the net-action kernel |
| `staleMemory_not_eligible` | a stale unscoped memory packet is rejected by the eligibility gate |
| `eligibleMemory_no_more_loss` | a toy LLM memory admission gate inherits the no-more-loss comparison |
| `memory_without_permission_not_eligible` | a toy memory without permission is rejected by the use-condition gate |
| `deleted_memory_not_eligible` | a deleted toy memory is rejected by the use-condition gate |
| `out_of_scope_memory_not_eligible` | an out-of-scope toy memory is rejected by the use-condition gate |
| `useConditionMemory_no_more_loss` | the explicit use-condition memory gate inherits the no-more-loss comparison |
| `premiseUpdate_invalidations_localized` | a toy premise update localizes downstream invalidations |
| `repairTouches_downstreamInvalidations` | a toy refresh repair covers the premise-update invalidations |
| `llm_invalidated_ncard_le_repair_touched_ncard` | localized toy LLM invalidations are bounded by the touched repair surface budget |
| `revokedScopedMemoryRecord_not_eligible` | a revoked lifecycle memory record is rejected |
| `expiredScopedMemoryRecord_not_eligible` | an expired lifecycle memory record is rejected |
| `lifecycleMemory_no_more_loss` | lifecycle memory admission inherits the no-more-loss comparison |
| `retrieval_packet_cannot_overwrite_userCorrection_packet` | lower-trust retrieval provenance cannot overwrite a user-correction packet in the toy trust order |
| `reasoningContradictionWitness_minimal` | the toy reasoning contradiction witness is exactly a two-surface witness |
| `llm_composed_repair_kernel` | composed toy repair still inherits the finite net-action kernel |
| `toyEvidenceAdmission_no_more_loss` | the software toy admission gate instantiates the evidence-packet admission comparison |
| `toyRepair_touches_invalidations` | the software toy repair packet covers localized toy invalidations |
| `software_invalidated_ncard_le_repair_touched_ncard` | localized toy software invalidations are bounded by the touched repair surface budget |

The composition theorem is the non-decorative part of the bridge:

```text
coherentMass S n =
  coherentMass S 0 * exp (-(cumulativeEpistemicNetAction S n))
```

under the same finite positivity assumptions used by
`GeneralStateDynamics.PositiveTrajectory`.

`EpistemicControlComparison.lean` adds the finite baseline-comparison reading:

```text
NetActionNoWorse controlled baseline n
  -> coherentMass baseline n <= coherentMass controlled n
```

provided the two layers start with the same coherent mass and both satisfy the
finite positivity assumptions.  This is a control-accounting comparison, not a
claim that any real model has lower net action.

`EpistemicControlEvaluationContract.lean` then gives an evaluation-facing
witness contract:

```text
controlledLoss_t <= baselineLoss_t
baselineRepair_t <= controlledRepair_t
metric sums match cumulative net actions
  -> NetActionNoWorse controlled baseline n
```

This says which loss / repair readouts can witness the comparison premise.  It
does not prove that a benchmark, implementation, or model output supplies a
valid readout.


4. LLM-Control Reading
----------------------

The bridge supports the following conditional readings.

For reasoning degradation, unscoped contradictions can be represented as
`contradictionUpdate`.  Scope markers, external contradiction metabolism, or
other repair operations can be represented as `repairUpdate`.  If these
operators satisfy the bridge interface, coherent mass follows the net-action
kernel.  The Lean theorem does not identify the model's internal reasoning
paths; it only checks the finite accounting interface.

For continual learning, a premise update can contract the region of currently
coherent knowledge states.  A dependency-aware refresh is a repair update when
it reopens states compatible with the updated premise.  The dependency guard
lemma says only that invalidation is localized when the rewritten graph
soundly over-approximates semantic downstream dependency.

For long-term memory control, raw memory admission is not modeled as truth.
The memory-filter lemma compares the coherent region after an accept-all
policy with the coherent region after a filtered policy.  The theorem is
conditional: the filtered region must contain the accept-all coherent region
under the chosen soundness premise.  This is where an implementation must
justify that bad memory was blocked without discarding required coherent
states.

`LLMEpistemicControlToy.lean` adds a finite toy surface for these three
readings.  It checks a reasoning contradiction / repair kernel, a
provenance-and-eligibility memory gate, and a premise-update dependency repair
packet.  It is a toy bridge instantiation, not a proof of real model semantics.
`LLMMemoryUseConditionToy.lean` refines the memory gate by making permission,
deletion state, scope, stability, and action eligibility explicit before a
memory item may be used as a current premise.
`DependencyClosureBudgetToy.lean` turns dependency-localization inclusions into
finite invalidation, closure, surface, and repair-touched cardinality bounds.
`LLMMemoryReasoningStrengtheningToy.lean` adds lifecycle memory guards,
provenance trust ordering, minimal contradiction witnesses, and composed repair
wrappers.  These are finite guardrail statements, not general LLM safety
theorems.


5. Claims
---------

This bridge supports a formal-interface claim:

> LLM-style epistemic control layers can be connected to the existing
> structural-persistence contraction / repair kernel once they are represented
> by a finite coherent-region interface satisfying explicit contraction,
> repair, positivity, filter-soundness, and dependency-closure assumptions.
> Under the additional same-initial-mass and no-worse-net-action assumptions,
> the comparison layer also gives a finite coherent-mass lower bound relative
> to a baseline.
> Under explicit metric-readout alignment, per-step loss / repair dominance can
> witness that no-worse-net-action assumption.

This is a theorem-side bridge, not empirical support.  Experimental support
for any concrete implementation still belongs to the relevant inference-layer
package and must be evaluated against its own frozen baseline, metric, and
decision rule.


6. Non-Claims
-------------

This bridge does not claim:

- Lean proves LLM reasoning performance;
- Lean proves natural-language semantics, belief revision, or memory safety;
- the bridge identifies a model's internal computation or attention dynamics;
- every contradiction, memory input, or dependency relation has a unique natural
  mass readout;
- memory filtering is unconditionally beneficial;
- dependency rewrite is sound when the dependency graph is incomplete;
- implementation success transfers support across reasoning, continual
  learning, memory, or software diagnostics.

Safe wording:

> The Lean layer now includes a checked abstract bridge showing that an
> epistemic control layer satisfying contraction / repair interface conditions
> inherits the existing finite net-action kernel, plus a checked
> evidence-packet schema for provenance, eligibility, witness, dependency, and
> repair guardrails, and a finite LLM-side toy instantiation for reasoning,
> memory, continual update, dependency budgets, lifecycle guards, provenance
> trust, minimal witnesses, and composed repair.  The LLM experiments and
> implementations are candidate instantiations of that interface, not proofs of
> LLM semantics.


7. Related Profiles
-------------------

- `llm_reasoning_degradation.md`
- `continual_learning_forgetting.md`
- `llm_long_term_memory_control.md`
- `software_contract_coherence.md`
- `software_contract_coherence_epistemic_instantiation.md`
- `../../../lean/Survival/EpistemicControlBridge.lean`
- `../../../lean/Survival/EpistemicControlComparison.lean`
- `../../../lean/Survival/EpistemicControlEvaluationContract.lean`
- `../../../lean/Survival/EvidencePacketBridge.lean`
- `../../../lean/Survival/LLMEpistemicControlToy.lean`
- `../../../lean/Survival/LLMMemoryUseConditionToy.lean`
- `../../../lean/Survival/DependencyClosureBudgetToy.lean`
- `../../../lean/Survival/LLMMemoryReasoningStrengtheningToy.lean`
- `../../../lean/Survival/EpistemicControlStack.lean`
- `../../../lean/Survival/SoftwareContractToyRepository.lean`
- `../../../lean/Survival/SoftwareEvidencePacketToy.lean`
