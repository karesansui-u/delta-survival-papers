LLM Epistemic-Control Real-Eval Candidate Mapping
=================================================

Status: candidate mapping; not support evidence

Date: 2026-05-27


1. Purpose
----------

This note maps existing implementation-side logs and design artifacts in the
`delta-zero` workspace to the Lean-side epistemic benchmark protocol. It does
not claim empirical support. It identifies which existing artifacts could be
converted into candidate witnesses for a future frozen evaluation.

The relevant Lean / protocol chain is:

```text
EpistemicControlBridge
  -> EpistemicControlComparison
  -> EpistemicControlEvaluationContract
  -> EpistemicBenchmarkProtocol
  -> EpistemicBenchmarkResultCertificate
```

The current toy loop already has:

```text
freeze_manifest_v0.md
  -> tasks.jsonl
  -> run_eval.py
  -> llm_epistemic_control_frozen_toy_v0_result_001.json
  -> result-certificate theorem layer
```

This note asks a narrower implementation question:

```text
Which existing implementation logs could become future frozen witnesses for
the same protocol shape?
```


2. Non-Claims
-------------

This note does not claim that:

- existing implementation logs are theorem-side evidence;
- old logs satisfy a frozen protocol;
- real LLM semantics, model performance, memory safety, or workflow correctness
  have been proven;
- a benchmark runner's labels are semantically correct just because they have a
  JSON shape;
- field or operational outcomes certify repository semantics.

The safe reading is:

```text
Existing logs can guide the next frozen protocol. They are candidate mappings,
not support records.
```


3. Protocol Fields To Witness
-----------------------------

| Lean / protocol obligation | Future real-eval witness | Candidate implementation surface |
|---|---|---|
| frozen task surface | predeclared cases, setup/update/probe fields, and oracle rules | `benchmarks/iqc_failure_suite/cases.jsonl`; structured memory micro cases; memory-tagging stress cases |
| same finite horizon | fixed number of turns, update/probe steps, or benchmark checkpoints | StageB benchmark turns; fixed micro readout case count; fixed per-case setup/update/probe cycle |
| same initial mass | same initial state family for baseline and controlled conditions | paired baseline / controlled trials; fixed synthetic memory states |
| baseline loss | stale premise reuse, unsafe memory use, quote misattribution, no-store violation, or benchmark false pass | IQC failure modes, memory readout failures, benchmark audit fields |
| controlled loss | the same loss under a controlled readout / update / filtering path | structured memory context, metabolism-enabled condition, gated execution / memory qualification |
| repair gain | downstream update coverage, stale-memory rejection, corrected current-state answer, or safe replan | dependency-staleness repairs, use-condition gates, execution qualification replans |
| metric dominance | controlled loss no larger than baseline loss and controlled repair no smaller than baseline repair | future runner output; not established by this note |
| readout alignment | predeclared formula translating observed errors into cumulative net action | future scorer schema derived from this mapping |
| result certificate | result JSON with protocol id, result id, task digest, metric flags, and boundary text | future result artifact; toy example already exists |


4. Candidate Track A: Premise Update / Dependency Staleness
-----------------------------------------------------------

Priority: highest

Why this is the cleanest next real-eval candidate:

- the setup / update / probe structure is already explicit;
- stale premise use has a natural contradiction-loss reading;
- successful update of downstream answers has a natural repair-gain reading;
- dependency closure is interpretable at the case level;
- privacy and long-term-memory safety issues are lighter than broad memory
  benchmarks.

Candidate implementation artifacts:

- `delta-zero/benchmarks/iqc_failure_suite/cases.jsonl`
- `delta-zero/benchmarks/iqc_failure_suite/results_comparison.json`
- `delta-zero/benchmarks/iqc_failure_suite/runner.py`
- `delta-zero/benchmarks/iqc_failure_suite/test_runner.py`

The strongest case family is `dependency_staleness` (`m4_*`). Examples include:

- office relocation causing stale nearest-station answers;
- address change causing stale local-information answers;
- diet / allergy changes causing stale recommendation answers;
- service rename, deadline change, or app migration causing stale old-name
  answers.

Candidate mapping:

| Protocol field | Premise-update reading |
|---|---|
| task | one setup/update/probe record |
| baseline | answer path without dependency-aware premise refresh |
| controlled | answer path with explicit premise-update / dependency-refresh control |
| contradiction loss | old premise or downstream stale value appears in the answer |
| repair gain | answer uses the updated premise, or explicitly refuses to infer stale downstream facts |
| dependency closure | fields semantically downstream of the updated premise |
| readout alignment | per-case stale-use score maps to loss; update-respecting answer maps to repair |

Main risks:

- existing results were not generated under this Lean protocol;
- old logs may mix model behavior, retrieval behavior, and judge behavior;
- keyword-based pass / fail can misread abstention or hedged answers;
- the dependency closure is currently implicit in natural-language cases;
- the same-initial-mass premise must be operationalized as a paired condition,
  not inferred after inspection.

Future frozen v0 proposal:

```text
protocol_id: llm_epistemic_premise_update_v0
surface: 10-30 preselected dependency_staleness cases
baseline: no explicit dependency refresh / ordinary readout
controlled: dependency-aware premise refresh / structured readout
horizon: setup -> update -> probe
loss: stale old premise appears in the probe answer
repair: updated premise or safe unknown answer appears in the probe answer
decision: support / no-support / silence fixed before execution
```


5. Candidate Track B: Memory Qualification / Use Conditions
-----------------------------------------------------------

Priority: high

Why this track matters:

- it maps directly to the Lean memory-use-condition toys;
- unsafe admission and unsafe use are easier to score than broad answer quality;
- the existing implementation artifacts already expose state labels such as
  authorship, epistemic status, scope, stability, and use state.

Candidate implementation artifacts:

- `delta-zero/data/memory_input_tagging_v4_stress_summary.json`
- `delta-zero/data/execution_candidate_control_stress_summary.json`
- `delta-zero/docs/memorygit_current_claim_boundary_ja.md`
- `delta-zero/docs/memory_context_compiler_structured_input_ja.md`
- `delta-zero/data/experiments/memory_context_compiler_ablation/report.md`
- `delta-zero/data/experiments/l5_structured_context_ablation_v0/summary.json`

Observed candidate signals:

- `memory_input_tagging_v4_stress_summary.json` records 12 tagging cases with
  `field_accuracy = 1.0`.
- `execution_candidate_control_stress_summary.json` records 11 action-gating
  cases with `accuracy = 1.0`.
- `memory_context_compiler_ablation/report.md` records deterministic
  contract-level scores: text `0.375`, structured JSON `1.000`, compact
  structured `1.000`.
- `l5_structured_context_ablation_v0/summary.json` records a micro readout
  benchmark over fixed synthetic retrieval states: text `0.875`, structured
  JSON `1.000`, compact structured `1.000`.

Candidate mapping:

| Protocol field | Memory-qualification reading |
|---|---|
| task | one memory item plus a query or action request |
| baseline | naive current-premise or text-only memory readout |
| controlled | use-condition-gated / structured memory readout |
| contradiction loss | unsafe use, stale use, quoted material promoted as current fact, no-store leak, or pending conflict used as fact |
| repair gain | item rejected, held, scoped, or routed to review / replan |
| eligibility witness | authorship, epistemic status, scope, stability, permission, deletion, no-store, and action-state labels |
| readout alignment | per-case unsafe-use score maps to loss; correct rejection / scoped readout maps to repair |

Main risks:

- deterministic stress cases are design checks, not frozen support;
- the micro readout benchmark is small and not a StageB-scale evaluation;
- a filter can reject useful memory, so the future protocol must score useful
  retention as well as unsafe rejection;
- permission / no-store / deletion semantics need a predeclared oracle and
  public-safe case generation rule;
- existing logs were inspected after creation, so they are design material only.

Future frozen v0 proposal:

```text
protocol_id: llm_epistemic_memory_qualification_v0
surface: public-safe synthetic memory-use cases
baseline: naive current-premise / text readout
controlled: explicit eligibility and use-condition gate
loss: unsafe or stale memory used as current premise
repair: memory blocked, scoped, or safely routed to review
secondary guard: useful eligible memory retained
```


6. Candidate Track C: Benchmark Audit / Result-Certificate Discipline
---------------------------------------------------------------------

Priority: protocol-governance layer

This track is not the cleanest source of coherent-mass metrics. Its value is
different: it already contains the discipline needed for future result
certificates.

Candidate implementation artifacts:

- `delta-zero/benchmark_integrity_audit_2026-04-03.md`
- `delta-zero/evaluation_transparency_note_2026-04-03.md`
- `delta-zero/frontier_validation_report.md`
- `delta-zero/scripts/benchmark_runner.py`

Candidate mapping:

| Protocol field | Benchmark-audit reading |
|---|---|
| frozen readout | fixed scoring policy and decision policy fields |
| result certificate | raw and corrected outputs retained separately |
| invalid-run boundary | quarantine report and model-agnostic anomaly triggers |
| runner audit fields | `keyword_passed`, `uncertainty_flag`, `decision_policy`, retrieval flags |
| non-support / silence discipline | anomalous runs are not silently promoted or deleted |

Main risks:

- this track audits scoring integrity; it does not by itself supply loss /
  repair dominance;
- old corrected results are not a frozen Lean-protocol result certificate;
- benchmark false positives show why future readout alignment must be fixed
  before execution;
- raw / corrected / quarantined distinctions must remain visible.

Future use:

```text
Use the audit discipline as a template for every future real-eval runner:
raw output retained, corrected output separated, quarantine explicit,
decision policy recorded, and result certificate emitted only after the
predeclared scoring rule has run.
```


7. Candidate Track D: Software Evidence Packaging
-------------------------------------------------

Priority: deferred for this specific real-eval path

The software contract-coherence workflow is already represented in the Lean
toy software evidence bridge. For the next real-eval cycle, however, premise
update and memory qualification are cleaner because they map directly to LLM
epistemic-control fields and have smaller benchmark surfaces.

Candidate future use:

- define a software evidence packet with provenance, witness, dependency
  closure, repair coverage, and result digest;
- map the packet to `SoftwareEvidenceNetActionBridge.lean`;
- keep maintainer acceptance as field / operational evidence, not theorem-side
  evidence.


8. Recommended Next Frozen Protocol
-----------------------------------

The recommended first real-eval candidate is:

```text
llm_epistemic_premise_update_v0
```

Minimum files:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/freeze_manifest_v0.md
v3/05_evidence/llm_epistemic_premise_update_v0/tasks.jsonl
v3/05_evidence/llm_epistemic_premise_update_v0/output_collection_protocol_v0.md
v3/05_evidence/llm_epistemic_premise_update_v0/run_manifest_result_001.md
analysis/epistemic_control_premise_update_v0/make_output_template.py
analysis/epistemic_control_premise_update_v0/collect_with_ollama.py
analysis/epistemic_control_premise_update_v0/run_eval.py
analysis/epistemic_control_premise_update_v0/results_schema.json
```

Current status:

```text
The frozen task surface now exists at
v3/05_evidence/llm_epistemic_premise_update_v0/.
The marker-based scorer and result schema now exist at
analysis/epistemic_control_premise_update_v0/.
The output collection protocol and template generator also exist.
The result_001 run manifest also exists.
The first outcome-bearing result artifact has been emitted with protocol-local
decision `silence`; it is not support evidence.
```

Required frozen fields:

- `case_id`
- `failure_family`
- `setup`
- `update`
- `probe`
- `baseline_condition`
- `controlled_condition`
- `oracle_pass`
- `oracle_fail`
- `stale_markers`
- `updated_markers`
- `dependency_surface`
- `horizon`

Suggested metric readout:

| Metric | Definition |
|---|---|
| `baselineLoss` | `1` if the baseline answer uses stale downstream information; else `0` |
| `controlledLoss` | `1` if the controlled answer uses stale downstream information; else `0` |
| `baselineRepair` | `1` if the baseline answer updates downstream state or safely refuses stale inference; else `0` |
| `controlledRepair` | `1` if the controlled answer updates downstream state or safely refuses stale inference; else `0` |

Decision rule:

```text
The run supports the protocol only if:
1. the frozen task surface digest matches;
2. all result rows have the same finite horizon;
3. controlledLoss <= baselineLoss under the predeclared aggregation;
4. controlledRepair >= baselineRepair under the predeclared aggregation;
5. readout alignment is recorded in the result artifact;
6. no invalid-run / quarantine trigger fires.
```


9. Current Status
-----------------

This mapping upgrades the research workflow from:

```text
toy certificate loop only
```

to:

```text
toy certificate loop
+ real-eval candidate mapping for premise update, memory qualification,
  benchmark audit, and software evidence packaging
```

It does not upgrade any existing implementation run to support evidence. The
next support-bearing step must be a new frozen protocol, executed after its
manifest, task surface, runner schema, and decision rule are fixed.
