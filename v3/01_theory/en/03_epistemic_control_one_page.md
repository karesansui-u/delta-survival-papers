Epistemic-Control Bridge: One-Page Summary
=========================================

One-Sentence Claim
------------------

LLM-style reasoning degradation, continual-update failures, and long-term
memory-control failures can be studied as finite epistemic-control problems
when they are represented through coherent regions, contradiction updates,
repair updates, memory-eligibility filters, and dependency-closure guards.

This is a structural interface claim. It is not a claim that Lean proves LLM
semantics, model performance, belief revision, memory safety, or detector
correctness.


Layered Stack
-------------

![Figure. Layered stack connecting the Lean core, the epistemic-control bridge, the evidence-packet bridge, and bounded implementation candidates.](../figures/figure3_epistemic_control_stack_en.svg)

![Figure. Result-certificate chain from an external runner artifact to the Lean benchmark protocol and coherent-mass comparison theorem.](../figures/figure4_epistemic_result_certificate_chain_en.svg)

The intended reading is:

1. Lean core: finite feasible regions, mass readouts, contraction / repair, and
   the signed net-action kernel.
2. Epistemic-control bridge: an abstract interface that maps contradiction
   updates, repair updates, memory filters, and dependency rewrites into that
   kernel under explicit assumptions.
3. Evidence-packet bridge: provenance, eligibility, contradiction-witness,
   dependency-closure, and repair-coverage guardrails for artifacts that may
   feed the abstract bridge.
4. Finite strengthening toys: dependency-closure cardinality budgets,
   lifecycle memory guards, provenance trust ordering, minimal contradiction
   witnesses, and composed repair wrappers.
5. Implementation candidates: reasoning-control, continual-update,
   memory-control, and software contract-coherence workflows evaluated through
   their own evidence packages.
6. Result-certificate chain: external runners may emit certificate-like result
   artifacts; Lean does not parse those artifacts, but it formalizes which
   witnesses are sufficient to induce a valid benchmark protocol and invoke
   the coherent-mass comparison theorem.


What Lean Proves
----------------

The central bridge theorem is:

```text
epistemic_control_composition_kernel
```

It says that if a finite epistemic-control layer supplies the required
contraction, repair, and positivity assumptions, then its coherent mass follows
the existing net-action kernel:

```text
coherentMass n =
  coherentMass 0 * exp (-(cumulativeEpistemicNetAction n))
```

The finite LLM-side toy instantiation is:

```text
LLMEpistemicControlToy.lean
```

It proves checked toy links for all three LLM-facing control surfaces:

```text
llmReasoningToy_composition_kernel
llmReasoningContradictionWitness_has_two_surfaces
staleMemory_not_eligible
eligibleMemory_eligible
eligibleMemory_no_more_loss
premiseUpdate_invalidations_localized
repairTouches_downstreamInvalidations
```

These are finite toy statements about bridge interfaces, not claims about real
LLM semantics or model performance.

The LLM memory use-condition toy is:

```text
LLMMemoryUseConditionToy.lean
```

It makes memory-use eligibility explicit:

```text
memory_without_permission_not_eligible
deleted_memory_not_eligible
out_of_scope_memory_not_eligible
unstable_memory_not_eligible
action_blocked_memory_not_eligible
useConditionMemory_no_more_loss
```

This is still a finite use-condition schema, not a proof of arbitrary
long-term memory safety.

The dependency-closure budget toy is:

```text
DependencyClosureBudgetToy.lean
```

It gives finite cardinality readings of the dependency guard:

```text
llm_invalidated_ncard_le_repair_touched_ncard
software_invalidated_ncard_le_repair_touched_ncard
```

These statements say that, once a sound dependency closure and covering repair
packet are supplied, localized invalidations are bounded by the touched repair
surface budget. They do not prove real semantic dependency discovery.

The LLM memory / reasoning strengthening toy is:

```text
LLMMemoryReasoningStrengtheningToy.lean
```

It adds checked toy guardrails:

```text
revokedScopedMemoryRecord_not_eligible
expiredScopedMemoryRecord_not_eligible
lifecycleMemory_no_more_loss
retrieval_packet_cannot_overwrite_userCorrection_packet
reasoningContradictionWitness_minimal
llm_composed_repair_kernel
```

These sharpen memory and reasoning control at the interface level. They are not
proofs of product-level agent reliability or arbitrary memory safety.

The finite baseline-comparison layer is:

```text
EpistemicControlComparison.lean
```

It proves that if a controlled epistemic layer starts with the same coherent
mass as a baseline layer and has no larger cumulative net action at a fixed
finite horizon, then the controlled layer preserves at least the baseline
coherent mass:

```text
controlled_coherentMass_ge_baseline
```

This is a theorem about the abstract accounting interface, not a claim that a
real model or deployed workflow satisfies the comparison premise.

The evaluation-facing metric contract is:

```text
EpistemicControlEvaluationContract.lean
```

It proves that per-step metric dominance can witness the comparison premise:

```text
metric_net_action_no_worse
metrics_controlled_coherentMass_ge_baseline
```

If controlled loss is no larger than baseline loss, controlled repair is no
smaller than baseline repair, and the cumulative metric sums match the
bridge-level cumulative net actions, then the metrics supply the
`NetActionNoWorse` assumption used by the comparison theorem. This is a
readout contract, not a proof that any benchmark measures those quantities
correctly.

The benchmark protocol layer is:

```text
EpistemicBenchmarkProtocol.lean
```

It fixes the protocol obligations needed to invoke the evaluation contract:

```text
benchmark_protocol_implies_net_action_no_worse
benchmark_protocol_implies_controlled_mass_ge_baseline
```

A valid protocol supplies frozen task-surface and readout obligations, same
finite horizon, same initial coherent mass, finite positivity, metric
dominance, and readout alignment. It does not validate a real dataset split,
benchmark, or decision rule.

The result-certificate layer is:

```text
EpistemicBenchmarkResultCertificate.lean
```

It records the theorem-side shape of a result certificate:

```text
result_certificate_implies_benchmark_valid
result_certificate_implies_net_action_no_worse
result_certificate_implies_controlled_mass_ge_baseline
```

If an external result artifact supplies protocol-shape, frozen-surface,
frozen-readout, same-horizon, same-initial-mass, positivity, metric-dominance,
and readout-alignment witnesses, the certificate induces a valid benchmark
protocol and invokes the coherent-mass comparison theorem. This does not parse
JSON, validate a real benchmark, or prove model performance.

The stack-level Lean entry point is:

```text
EpistemicControlStack.lean
```

It collects the abstract bridge, baseline comparison, evaluation contract,
benchmark protocol, result-certificate bridge, evidence-packet bridge, LLM toy, memory use-condition toy,
dependency-budget toy, memory / reasoning strengthening toy, software toy,
software evidence-packet, and software evidence net-action theorem aliases
under `stack_...` names for easier review.

The first toy software-side instantiation is:

```text
SoftwareContractToyRepository.lean
```

It proves, among other checked statements:

```text
toyRepository_composition_kernel
toyRepository_coherentMass_zero
toyRepository_coherentMass_one
toyRepository_coherentMass_two
toyClaimAdmission_no_more_loss
toyDependencyRewrite_localizes
```

The toy regularized mass values are 5 initially, 3 after one scoped
contradiction / repair step, and 3 after a second step. These are finite toy
accounting values, not empirical software metrics.

The implementation-boundary evidence schema is:

```text
EvidencePacketBridge.lean
```

It proves provenance and eligibility guard lemmas, multi-surface witness
conditions, dependency-localization and repair-coverage statements, and the
inherited admission-filter loss comparison:

```text
evidence_filter_no_more_loss
evidence_invalidations_localized
repair_touches_invalidations
```

The first toy software evidence-packet instantiation is:

```text
SoftwareEvidencePacketToy.lean
```

It connects the toy repository surface to the packet bridge through checked
validated / unsupported candidate gates, a two-surface witness, shared contract
key, dependency packet, repair packet, and admission-filter theorem.

The software evidence net-action bridge is:

```text
SoftwareEvidenceNetActionBridge.lean
```

It packages eligible evidence, shared-key witness soundness, dependency repair
coverage, and a valid benchmark protocol as sufficient obligations for the
comparison layer:

```text
software_evidence_implies_net_action_no_worse
software_evidence_implies_controlled_mass_ge_baseline
```

This is a finite assumption-to-guarantee bridge from evidence packages to the
comparison theorem. It does not prove real program semantics, repository
workflow correctness, or operational judgment.


What Lean Does Not Prove
------------------------

Lean does not prove:

- natural-language semantics;
- LLM reasoning accuracy or model performance;
- full belief revision;
- unconditional long-term memory safety;
- continual-learning safety or product-level agent reliability;
- the correctness of a concrete detector or workflow;
- that a toy mass readout is a natural empirical mass model;
- that implementation results are theorem-side evidence.

Experimental or operational evidence remains package-scoped. It must be judged
by the relevant frozen baseline, metric, validation rule, and evidence ledger.


Why This Matters
----------------

Before the bridge, the connection from structural-persistence accounting to
LLM-style control could look like prose mapping. The bridge makes the
connection thinner and sharper:

```text
finite coherent-region interface
  -> contradiction / repair / eligibility / dependency operators
  -> provenance / witness / dependency / repair evidence packets
  -> existing net-action kernel
```

The value is not overclaiming that Lean proves an LLM. The value is that the
control layer can be stated as an explicit contract: if the implementation
supplies the interface conditions, the finite accounting theorem applies.


Where To Read Next
------------------

- Core-paper bridge section: `02_core_en.md`, Section 10.1
- Claim boundary: `../../CLAIMS.md`, Section 3
- Bridge note:
  `../../03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md`
- Information Qualification Control note:
  `04_information_qualification_control_note.md`
- Baseline-comparison bridge:
  `../../../lean/Survival/EpistemicControlComparison.lean`
- Evaluation-facing metric contract:
  `../../../lean/Survival/EpistemicControlEvaluationContract.lean`
- Benchmark protocol contract:
  `../../../lean/Survival/EpistemicBenchmarkProtocol.lean`
- Result-certificate bridge:
  `../../../lean/Survival/EpistemicBenchmarkResultCertificate.lean`
- Evidence-packet bridge:
  `../../../lean/Survival/EvidencePacketBridge.lean`
- Toy LLM epistemic-control instantiation:
  `../../../lean/Survival/LLMEpistemicControlToy.lean`
- Toy LLM memory use-condition instantiation:
  `../../../lean/Survival/LLMMemoryUseConditionToy.lean`
- Toy dependency-closure budget instantiation:
  `../../../lean/Survival/DependencyClosureBudgetToy.lean`
- Toy LLM memory / reasoning strengthening instantiation:
  `../../../lean/Survival/LLMMemoryReasoningStrengtheningToy.lean`
- Stack-level Lean entry point:
  `../../../lean/Survival/EpistemicControlStack.lean`
- Toy software-contract instantiation:
  `../../../lean/Survival/SoftwareContractToyRepository.lean`
- Toy software evidence-packet instantiation:
  `../../../lean/Survival/SoftwareEvidencePacketToy.lean`
- Software evidence net-action bridge:
  `../../../lean/Survival/SoftwareEvidenceNetActionBridge.lean`
- Frozen toy protocol runner:
  `../../../analysis/epistemic_control_frozen_toy_v0/run_eval.py`
- First named deterministic toy result artifact:
  `../../05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.json`
- Real-eval candidate mapping:
  `../../05_evidence/llm_epistemic_control_real_eval_candidate_mapping.md`
- First frozen premise-update surface:
  `../../05_evidence/llm_epistemic_premise_update_v0/freeze_manifest_v0.md`
- Premise-update output collection protocol:
  `../../05_evidence/llm_epistemic_premise_update_v0/output_collection_protocol_v0.md`
- Premise-update scorer / schema:
  `../../../analysis/epistemic_control_premise_update_v0/run_eval.py`
