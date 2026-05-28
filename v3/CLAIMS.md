Claims and Non-Claims
=====================

This file is the public claim boundary for v3. If an informal summary, figure,
registry row, or domain note sounds stronger than this file, this file wins.


0. Claim-Package Rule
---------------------

Claims are package-scoped. A whole domain is not promoted as supported merely
because one package inside that domain has a formal anchor or a frozen support
result.

Every claim package should state, before validation or interpretation:

1. the maintenance problem: substrate or state space \(X\), target condition
   \(G\), the state/action/path targets being counted, feasible region \(V_G\),
   ruler \(m\), update or observation unit, time horizon, and boundary
   convention;
2. the observability classification: `specification_fixed` or `inference`
   (the registry label for the estimation layer);
3. any optional `existing-theory connection` attribute, with the exact drift,
   balance, rank, cutset, path-ratio, stopping-boundary, or stability quantity
   being connected;
4. the evidence state: candidate, frozen, support, no-support, silence,
   invalid-run, formal anchor, or another pre-declared ledger label.

There are two observability classifications. `specification_fixed` means
\(G,V_G,m\), the counted targets, the update rule, and the boundary can be fixed
from the domain specification. `inference` is the registry label for the
estimation layer: the true \(V_G,m,L,B\) are not directly counted, so frozen
observation or estimation indicators are tested instead.

Existing-theory connection is not a third observability layer. It is an
attribute of a specific claim package, and it only covers the named quantity or
conditional theorem that has actually been mapped.


1. Core Structural-Coordinate Claims
------------------------------------

1. In a pre-fixed structural maintenance problem, structural loss is represented
   by shrinkage of the feasible region compatible with the target condition
   \(G\).
2. Under ratio dependence, normalization, additivity, and continuity, the
   structural consumption scale is logarithmic up to a unit convention.
3. With \(k=1\), cumulative structural consumption is measured in nats. The
   loss-only kernel is \(S = M e^{-L}\).
4. With recovery represented on the same logarithmic scale, the balance kernel
   is \(S = M e^{-B}\), where \(B_n=\sum_{t<n}(d_t-r_t)\).
5. \(L\) and \(B\) are structural-compatibility coordinates. \(M\) is the
   familiar effective maintenance surplus or usable resource side.

The nontrivial addition of the theory is not that resources matter. It is the
separation between the resource-side quantity \(M\) and the structural
shrinkage coordinates \(L\) and \(B\). A system can approach a maintenance boundary
because the feasible structural region shrinks, because the effective resource
side reaches \(M=0\), or because both happen together.

\(S\) is a structural persistence potential for the stated maintenance problem.
It is not automatically a probability, a physical free energy, or a derivation
of \(M\). \(S=0\), or a pre-fixed threshold \(S\le S_c\), is a boundary
convention whose observational form may be collapse, functional failure, halt,
phase transition, or structural reorganization.


2. Theorem-Side Anchors
-----------------------

A theorem-side anchor shows that a pre-fixed coordinate closes mathematically
against an independently stated endpoint or boundary. It is not empirical
support by itself.

Current examples include finite CSP first-moment collapse, finite CSP
second-moment survival under a controlled second-moment ratio, finite BEC
linear-code erasure-rank unique recovery, finite row-budget converse, random
parity-check row-slack envelope, BEC erasure-count concentration bridge,
finite BEC capacity-style bound bundle, finite \(s\)-\(t\) cutset reliability
embedding, spanning-tree persistence theory, stationary-current and
trajectory-ratio guardrails, Foster-Lyapunov sign bridges, and the LLM
epistemic-control bridge that maps contradiction / repair control interfaces
to the finite net-action kernel. These anchors strengthen the vocabulary and
the boundary discipline. They do not replace frozen prediction packages.

For finite BEC rank accounting, the compatible ambiguity grows as
\(2^{a(E)}\). The structural-loss coordinate is not defined on that growing
ambiguity mass. It is defined on retained distinguishable message-cell mass:
\[
\frac{m(V_E)}{m(V_0)}=2^{-a(E)},
\qquad
L_E=-\log\frac{m(V_E)}{m(V_0)}=a(E)\log 2.
\]

For finite \(s\)-\(t\) cutset reliability, the operational embedding includes
the union-bound skeleton
\[
\Pr(s\not\leftrightarrow t)\le \sum_j N_j q^j
\]
under a fixed independent edge-failure law. Low-order cut-spectrum coordinates
are frozen low-order cutset proxies, not exact reliability superiority.

For existing theories, v3 claims only the mapped part. For example, a rank
accounting bridge or finite capacity-style bound bundle does not prove Shannon
capacity, a second-moment survival anchor does not prove a sharp CSP threshold,
a path-ratio identity does not prove a physical fluctuation theorem, and a
Foster-Lyapunov sign bridge does not prove positive recurrence.


3. Epistemic-Control Bridge Boundary
------------------------------------

The epistemic-control bridge is a theorem-side interface claim, not an
empirical support claim.

`lean/Survival/EpistemicControlBridge.lean` shows that a finite epistemic
control layer inherits the existing net-action kernel once it supplies:

1. a finite coherent-region interface;
2. a mass readout;
3. contradiction updates that contract the region;
4. repair updates that expand from the post-contradiction region;
5. finite-prefix positivity;
6. explicit soundness assumptions for memory filtering and dependency closure.

`lean/Survival/EpistemicControlComparison.lean` strengthens this bridge with a
baseline comparison contract. If a controlled finite epistemic layer has the
same initial coherent mass as a baseline layer and no larger cumulative net
action at a fixed horizon, then the controlled layer has at least the baseline
coherent mass at that horizon. This is still a conditional theorem over the
abstract interface, not a performance claim about any real model.

`lean/Survival/EpistemicControlEvaluationContract.lean` connects this
comparison premise to evaluation-facing readouts. If per-step controlled
contradiction loss is no larger than baseline loss, per-step controlled repair
gain is no smaller than baseline repair gain, and the cumulative metric sums
match the bridge-level cumulative net actions, then the metrics witness
`NetActionNoWorse` and the coherent-mass comparison theorem applies. This does
not prove that any benchmark or implementation measures those quantities
correctly.

`lean/Survival/EpistemicBenchmarkProtocol.lean` fixes the protocol obligations
needed before those evaluation metrics can be used: frozen task surface, frozen
readout, same finite horizon, same initial coherent mass, finite positivity,
metric dominance, and readout alignment. A valid protocol invokes the
evaluation contract and the coherent-mass comparison theorem. This does not
validate a real benchmark, dataset split, or decision rule by itself.

`lean/Survival/EpistemicBenchmarkResultCertificate.lean` adds a theorem-side
result-certificate layer above the benchmark protocol. It states that if an
external result artifact supplies protocol-shape, frozen-surface,
frozen-readout, same-horizon, same-initial-mass, positivity, metric-dominance,
and readout-alignment witnesses, then it induces a valid benchmark protocol
and invokes the same no-worse-net-action and coherent-mass comparison
theorems. It does not parse JSON, validate a benchmark, or prove model
performance.

`v3/05_evidence/llm_epistemic_control_benchmark_manifest.md` is the public
manifest template for connecting future experiments to this protocol layer. It
freezes the task surface, baseline, controlled system, finite horizon, per-step
loss / repair metrics, dominance rule, readout-alignment statement, and
decision rule before outcome-bearing execution. It is a protocol artifact, not
theorem-side evidence by itself.

`analysis/epistemic_control_frozen_toy_v0/run_eval.py` is a deterministic
scorer for the first frozen toy packet. It checks the v0 task surface, frozen
metric fields, aggregate dominance rule, and toy readout alignment, and emits a
JSON / Markdown smoke summary. It is a reproducibility aid for the protocol
shape, not validation evidence for a real model or workflow.

`v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.json`
is the first named deterministic toy result artifact emitted by that scorer.
It exercises the result-certificate loop for the frozen toy packet only. It is
not empirical support for a real LLM, benchmark, memory system, or workflow.

`v3/05_evidence/llm_epistemic_control_real_eval_candidate_mapping.md` maps
existing implementation-side logs to candidate future witnesses for premise
update, memory qualification, benchmark-audit discipline, and software evidence
packaging. It is planning material for future frozen protocols, not support
evidence and not a retrospective upgrade of existing logs.

`v3/05_evidence/iqc_failure_suite_final_result_ja.md` records an
implementation-side Information Qualification Control (IQC) benchmark summary,
not a Lean theorem.
Under the corrected benchmark injection path and bare environment / hybrid
judge, the reported suite has Information Qualification Control single-best on
speechAct and permission failures, co-best on versionState, and neutral on
source attribution. It may be used as package-scoped empirical benchmark
evidence for the memory-control design boundary. The implementation package is
published in `karesansui-u/delta-zero`
PR #2 at commit `8d0b3b2`, with 220 passed and 2 warnings reported there.
This does not prove LLM semantics, memory safety, product reliability, or
general continual-learning correctness.

`v3/05_evidence/llm_epistemic_premise_update_v0/` is the first frozen
real-eval candidate task surface following that mapping. It fixes 12
premise-update / dependency-staleness cases and their stale / updated marker
readout before outcome-bearing execution. It has no model outputs and no
support decision.

`analysis/epistemic_control_premise_update_v0/` contains the corresponding
marker-based scorer and result schema. The scorer consumes externally supplied
baseline / controlled outputs and emits a result-certificate-shaped summary; it
does not call a model, validate benchmark semantics, or create support without
an outcome-bearing result artifact.

`v3/05_evidence/llm_epistemic_premise_update_v0/output_collection_protocol_v0.md`
fixes the raw output collection procedure for future premise-update runs. It is
not model output and not validation evidence.

`v3/05_evidence/llm_epistemic_premise_update_v0/run_manifest_result_001.md`
fixes the model, prompt, runtime, and planned artifact paths for the first
output-bearing run before those outputs are promoted.
`v3/05_evidence/llm_epistemic_premise_update_v0/collection_attempt_result_001_timeout_qwen35_9b.md`
records an aborted timeout attempt that produced no raw-output or result
artifact; it is operational audit material only.
`v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md`
records the first completed output-bearing run. Its protocol-local decision is
`silence`, so it does not instantiate a valid benchmark result certificate and
does not provide support evidence.

`v3/05_evidence/llm_epistemic_premise_update_v1/` is a successor frozen
readout package, not a correction or retrospective rescoring of v0. Its task
digest, readout label, scorer / schema, preflight suite, output-collection
protocol, run manifest, output template, and result-certificate mapping are
recorded under v1 paths. A v1 support label is valid only for that finite
package when `decision = support_clean`, `silence = false`, `invalid_run =
false`, `mixed = false`, `ambiguous = false`, `promotable = true`, and
`protocol_shape_valid = true`. It remains marker / label-readout-local
evidence, not proof of LLM semantics, memory safety, continual-learning safety,
or product reliability.

The result-certificate boundary is:

| Layer | It proves or checks | It does not prove |
|---|---|---|
| Lean theorem layer | If the explicit witnesses are supplied, the benchmark protocol, no-worse-net-action premise, and coherent-mass comparison follow | real LLM performance, natural-language semantics, benchmark validity, or product reliability |
| Runner layer | JSON shape, frozen task-surface identity, metric aggregation, dominance flags, and toy readout summaries | semantic correctness of model outputs or correctness of the benchmark design |
| Frozen benchmark manifest | predeclared task surface, readout fields, horizon, baseline / controlled comparison rule, and decision rule | universal performance, general memory safety, or transfer to another domain |
| Field / operational evidence | practical usefulness under its own package-scoped evidence rules | theorem-side evidence, raw detector precision by itself, or proof of repository semantics |

The software-contract toy in
`lean/Survival/SoftwareContractToyRepository.lean` is a formal instantiation of
that interface. It proves the toy repository-contract kernel, toy admission
filter guard, toy dependency-localization guard, and concrete regularized toy
mass values. This is a formal loop from bridge to finite toy surface. It is not
evidence that any real detector is correct.

`lean/Survival/EvidencePacketBridge.lean` sits between the abstract bridge and
implementation artifacts. It checks the packet-level guardrails expected before
an artifact is allowed to feed the bridge: provenance presence, eligibility
status, multi-surface contradiction witnesses with a shared key, dependency
closure localization, repair coverage, and the inherited no-more-loss admission
comparison. It is still not a proof that a real workflow or repository semantics
is correct.

`lean/Survival/LLMEpistemicControlToy.lean` is the finite LLM-side toy
instantiation. It connects reasoning degradation, long-term memory eligibility,
and continual-update dependency repair to the abstract bridge and
evidence-packet bridge. It proves the toy reasoning net-action kernel,
validated contradiction witness, stale-memory rejection, eligible-memory
admission comparison, premise-update invalidation localization, and downstream
repair coverage. It is not a proof of real LLM semantics, model performance, or
unconditional memory safety.

`lean/Survival/LLMMemoryUseConditionToy.lean` refines the memory side of the
LLM toy by splitting use eligibility into explicit permission, deletion state,
scope, stability, and action-eligibility guards. It proves that memories
without permission, deleted memories, out-of-scope memories, unstable memories,
and action-blocked memories cannot pass the toy use-condition gate, while a
scoped correction record can pass it and inherits the admission no-more-loss
comparison. This remains a finite toy schema, not a proof of arbitrary
long-term memory safety.

`lean/Survival/DependencyClosureBudgetToy.lean` adds a quantitative finite
reading of the dependency-localization guard: once a sound dependency packet
localizes invalidations inside a checked closure, the number of invalidated
surfaces is bounded by the closure budget, the whole finite control surface,
and a repair packet's touched-surface budget when the repair covers the
closure. This is still a finite toy budget statement, not a proof of real
semantic dependency discovery.

`lean/Survival/LLMMemoryReasoningStrengtheningToy.lean` adds four finite toy
guardrails on top of the LLM memory and reasoning surface: lifecycle memory
guards for revoked and expired records, a provenance trust order for overwrite
decisions, a minimal two-surface contradiction-witness predicate, and a
composed-repair wrapper that still inherits the net-action kernel. These
guardrails sharpen the formal interface but do not prove product-level agent
reliability or arbitrary memory safety.

`lean/Survival/EpistemicControlStack.lean` is the stack-level entry point. It
collects the main abstract bridge, baseline comparison, evaluation contract,
benchmark protocol, result-certificate bridge, evidence-packet, LLM toy, memory use-condition,
dependency-budget, memory / reasoning strengthening, software toy, and software
evidence-packet / software evidence net-action bridge theorems under
stack-prefixed names. It is a reader-facing integration file, not an additional
semantic claim.

`lean/Survival/SoftwareEvidencePacketToy.lean` connects the toy
software-contract surface to this packet bridge. It proves that the toy raw
candidate gate, two-surface witness, shared contract key, dependency packet,
repair packet, and admission filter instantiate the evidence-packet guardrails.
This remains a finite toy instantiation, not a correctness proof for a real
repository workflow.

`lean/Survival/SoftwareEvidenceNetActionBridge.lean` connects the toy software
evidence surface to the benchmark-comparison layer. It packages eligible
evidence, shared-key witness soundness, dependency-closure repair coverage,
and a valid benchmark protocol as sufficient obligations for invoking
`NetActionNoWorse` and the coherent-mass baseline comparison theorem. This is
still a finite assumption-to-guarantee bridge; it does not prove real program
semantics, repository workflow correctness, or maintainer judgment.

This bridge supports the following claim:

> A finite epistemic-control layer satisfying the stated contraction, repair,
> positivity, filter-soundness, dependency-closure, and packet-eligibility
> assumptions inherits the structural-persistence net-action kernel; if it
> also has no larger cumulative net action than a same-initial-mass baseline,
> then it preserves at least the baseline coherent mass at that finite horizon.
> Per-step loss and repair metrics can witness that no-worse-net-action
> premise when their cumulative readouts are explicitly aligned with the
> bridge-level net actions.
> A valid benchmark protocol fixes the task surface, readout, horizon, initial
> mass, metric-dominance, and readout-alignment obligations needed to use that
> evaluation contract.
> A valid result certificate can induce the same benchmark-protocol witness
> when its protocol-shape and metric/readout witnesses are supplied.
> A software evidence package can invoke the same finite comparison theorem
> when eligible evidence, shared-key witness soundness, dependency-repair
> coverage, and a valid benchmark protocol are supplied.

It does not support these claims:

- Lean proves LLM natural-language semantics;
- Lean proves model performance or reasoning accuracy;
- Lean proves full belief revision or unconditional memory safety;
- Lean proves continual-learning safety or product-level agent reliability;
- Lean proves the correctness of a concrete software detector;
- the toy repository mass values are empirical software metrics;
- implementation or field results become theorem-side evidence.


4. Empirical Support Claim
--------------------------

The usual empirical value claim is not that an SP-only model replaces a strong
domain model. The central frozen test is:

\[
\text{domain baseline}+\text{SP} > \text{domain baseline}
\]

on unused data, a future surface, a fresh archive, or an outside rerun, under a
pre-fixed metric and decision rule.

Here SP means a structural persistence coordinate: structural consumption,
recovery, net consumption, alternative-path, cut-spectrum, dependency-pressure,
contract-coherence, or a related coordinate derived from the theory.

In `specification_fixed` packages, support can bear on the structural coordinate
because \(V_G,m\), the update rule, and the boundary are fixed by construction.
In estimation-layer (`inference`) packages, support is weaker: it shows that a
frozen indicator adds predictive value beyond the domain baseline. It does not
prove that the indicator is the true \(L\), \(B\), or mechanism.

Estimation-layer indicators must be read as candidate readouts, not as the
structural coordinates themselves. A frozen package should therefore separate:

1. support: the package passes its pre-fixed rule;
2. no-support: the package is valid but fails its pre-fixed rule;
3. silence: the target, label, comparison, or observable is not fixed enough for
   the theory to speak;
4. invalid-run: the frozen specification is not actually executed, for example
   because the generator, algebraic constraints, or audit checks fail before the
   main decision rule can be evaluated.

No-support may not be renamed as support after inspection. Silence is neither
success nor failure. Invalid-run is not evidence against the coordinate.

The strongest current outside-rerun empirical footing is package-scoped:
Mixed-CSP and q-coloring each have 3/3 clean outside reruns with
decision-relevant outputs reproduced. Finite non-CSP support is also recorded
for scoped finite \(s\)-\(t\) cutset reliability and finite BEC linear-code
packages, with spanning-tree persistence recorded as an exact endpoint-accounting
anchor plus separate scoped prediction results. These are finite-surface support
claims, not arbitrary-network, arbitrary-code, Shannon-limit, real-world causal,
\(M\)-side, or universal-law evidence.


5. Transfer Claim
-----------------

Cross-domain transfer is a hypothesis generator.

A successful design in one package can suggest a candidate mapping,
intervention, or indicator in another package. It does not transfer support.
Support in the target package requires the target mapping, indicator, baseline,
metric, split, and decision rule to be frozen before validation.


6. Software Contract-Coherence Boundary
---------------------------------------

Software contract-coherence diagnostics is an estimation-layer (`inference`)
operational track for distributed-contract contradictions. The current
implementation workflow is not the theory-level object. This track is not
direct evidence of software collapse.

Use two evidence forms:

1. field demonstration / maintainer-acceptance evidence: public OSS PRs or
   issues selected, reproduced, patched, submitted, and accepted by external
   maintainers;
2. controlled benchmark evidence: frozen same-scope comparisons in which a
   structural lens adds validated distributed-contract roots over matched
   generic review.

PR merge counts are not raw precision / recall and are not the primary
benchmark endpoint. They may be cited as operational field evidence only when
the selection and human-workflow caveats are stated.


7. Resource / M Boundary
------------------------

For resource-side work, \(M\) should be read as the effective maintenance
amount: the resource-side slack, capacity, budget, attention, time, or other
usable resource available for maintaining the target condition \(G\).

The minimal meaning of \(M\) is scalar. Optional component decompositions of
\(M\) are diagnostics, not core structural-coordinate claims. \(M=0\) is a resource-side
route to the maintenance boundary and may appear as functional failure or halt
even when some feasible structural region remains.

| Label | Meaning |
|---|---|
| scalar-M readout | effective resource or slack indicator for the pre-fixed maintenance problem |
| M-component diagnostic | optional exploratory decomposition of \(M\); not a core structural-coordinate claim |

Claims about component decompositions or which intervention should be chosen
first are outside the default \(M\)-side evidence vocabulary.


8. Non-Claims
-------------

The v3 program does not claim:

- all systems empirically decay exponentially;
- every domain has a unique natural \(G,V_G,m,d_t,r_t,M\);
- package-level support promotes a whole domain;
- theorem-side anchors are empirical support;
- estimation-layer support has the same evidential strength as
  specification-fixed support;
- indicator success proves a universal law or mechanism;
- no-support in one frozen package refutes the mathematical kernel;
- \(M\) is derived from the exponential kernel itself;
- cross-domain transfer imports support;
- existing-theory connection means the whole existing theory has been
  re-proved;
- merged PRs alone prove raw detector precision, long-term software
  collapse prediction, or M-side profile support.
- the LLM epistemic-control bridge proves LLM semantics, model performance,
  belief revision, memory safety, or the correctness of a concrete memory /
  continual-learning implementation.
- MemoryGit or any LLM long-term memory-control note proves full belief
  revision, arbitrary natural-conversation safety, AGI, recursive
  self-improvement, or a literal implementation of human memory.
- private small-suite closure for MemoryGit or selected-readout telemetry proves
  safety on product traffic, independent large blind logs, or general continual
  learning.


9. Support Vocabulary
---------------------

Use these labels consistently:

| Label | Meaning |
|---|---|
| candidate | mapping, indicator, theorem-side bridge, or intervention proposed before frozen validation |
| formal anchor | theorem-side or Lean-side accounting result; not empirical support by itself |
| frozen | mapping, indicators, baseline, metric, split, and decision rule fixed |
| support | frozen package passes its pre-fixed support rule |
| weak support | frozen SP-only or compressed coordinate beats a simple baseline |
| incremental support | domain baseline + SP beats domain baseline out-of-sample |
| externally supported | outside rerun, fresh archive, future surface, or independent runner reproduces the support decision |
| no-support | frozen test fails its pre-fixed support rule |
| weak-axis failure | SP feature mostly renames or duplicates the baseline |
| silence | the theory should not speak for this package under current observability |
| invalid-run | frozen specification was not validly executed; do not score as support or no-support |
