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

The intended reading is:

1. Lean core: finite feasible regions, mass readouts, contraction / repair, and
   the signed net-action kernel.
2. Epistemic-control bridge: an abstract interface that maps contradiction
   updates, repair updates, memory filters, and dependency rewrites into that
   kernel under explicit assumptions.
3. Evidence-packet bridge: provenance, eligibility, contradiction-witness,
   dependency-closure, and repair-coverage guardrails for artifacts that may
   feed the abstract bridge.
4. Implementation candidates: reasoning-control, continual-update,
   memory-control, and software contract-coherence workflows evaluated through
   their own evidence packages.


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


What Lean Does Not Prove
------------------------

Lean does not prove:

- natural-language semantics;
- LLM reasoning accuracy or model performance;
- full belief revision;
- unconditional long-term memory safety;
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
- Evidence-packet bridge:
  `../../../lean/Survival/EvidencePacketBridge.lean`
- Toy software-contract instantiation:
  `../../../lean/Survival/SoftwareContractToyRepository.lean`
