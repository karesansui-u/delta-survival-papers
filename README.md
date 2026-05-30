# Structural Persistence Theory (v3)

This repository hosts the v3 public working structure for Structural Persistence
Theory.

構造は、資源が残っていても保てなくなりうる。その構造として存在し続けられる
状態領域が失われるからである。

The current public entry point is `v3/`. Older `v1/` and `v2/` materials remain
in the repository as archive and build history, but it is no longer the primary
reading path.

## Start Here

Read in this order:

1. [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md)
2. [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md)
3. [`v3/01_theory/02_accounting_framework.md`](v3/01_theory/02_accounting_framework.md)
4. [`v3/CLAIMS.md`](v3/CLAIMS.md)
5. [`v3/03_domains/registry.tsv`](v3/03_domains/registry.tsv)
6. [`v3/05_evidence/README.md`](v3/05_evidence/README.md)

English entry path:

- [`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md)
- [`v3/01_theory/en/03_epistemic_control_one_page.md`](v3/01_theory/en/03_epistemic_control_one_page.md)
- [`v3/01_theory/en/04_information_qualification_control_note.md`](v3/01_theory/en/04_information_qualification_control_note.md)
- [`v3/01_theory/en/10_paper1_minimal_form_en.md`](v3/01_theory/en/10_paper1_minimal_form_en.md)
- [`v3/01_theory/en/11_paper2_balance_principle_en.md`](v3/01_theory/en/11_paper2_balance_principle_en.md)

Current exported PDFs:

- [`v3/07_exports/pdf/02_core.pdf`](v3/07_exports/pdf/02_core.pdf)
- [`v3/07_exports/pdf/20_public_first_draft.pdf`](v3/07_exports/pdf/20_public_first_draft.pdf)
- [`v3/07_exports/pdf/22_public_second_draft.pdf`](v3/07_exports/pdf/22_public_second_draft.pdf)
- [`v3/07_exports/pdf/02_core_en.pdf`](v3/07_exports/pdf/02_core_en.pdf)
- [`v3/07_exports/pdf/10_paper1_minimal_form_en.pdf`](v3/07_exports/pdf/10_paper1_minimal_form_en.pdf)
- [`v3/07_exports/pdf/11_paper2_balance_principle_en.pdf`](v3/07_exports/pdf/11_paper2_balance_principle_en.pdf)
- [`v3/07_exports/pdf/Core_構造持続の最小核と収支原理.pdf`](v3/07_exports/pdf/Core_構造持続の最小核と収支原理.pdf)

The PDF build pipeline still writes into `v2/pdf用/` for
compatibility. `v3/07_exports/pdf/` is the public export surface.

## Core Claim

Structural Persistence Theory separates two failure routes that are often
collapsed into one:

- resource-side exhaustion, represented by the effective maintenance reserve
  \(M\);
- structure-side shrinkage, represented by the log-ratio structural depletion
  coordinate \(L\), and by the net depletion coordinate \(B\) when recovery is
  explicit.

The reader-facing kernels are

\[
S = M e^{-L},
\qquad
S_n = M_n e^{-B_n},
\qquad
B_n = \sum_{t<n}(d_t-r_t).
\]

The novelty is not that resources matter, nor that an exponential expression can
be written down. The contribution is to formulate structural failure as loss of
the state region in which a system can continue as the specified structure, and
to separate that shrinkage from the resource reserve that supports maintenance.

## Observability Layers

v3 uses layers rather than the old internal Route labels.

| Layer | Role |
|---|---|
| Specification-fixed structural layer | \(V\), \(m\), \(L/B\), and boundaries can be fixed from the specification. This is the law-side candidate layer. |
| Conditional structural-embedding layer | Existing theories such as Foster-Lyapunov or queueing are conditionally mapped into the same variables. This is a bridge layer. |
| Structurally inferred layer | The true \(V,m,L/B\) are not directly observed. Frozen observational or estimated indicators are tested out of sample. This is an engineering and diagnostic layer, not a universal-law claim. |

## Current Evidence Status

The strongest empirical footing is currently in the specification-fixed
structural layer.

- Mixed-CSP: 3/3 outside reruns, each with 12,000 primary rows, 0 checked core
  mismatches, and reproduced support flags.
- q-coloring, internal package name Exp43c: 3/3 outside reruns, each with 4,000
  primary rows, 0 checked core mismatches, TIMEOUT = 0, MALFORMED = 0, and the
  same qualitative support decision.

This is not a proof of a universal law. It is package-scoped replication support
for the first law-side empirical anchors.

Lean formalization is maintained in a dedicated repository:
**[persistence-lean](https://github.com/karesansui-u/persistence-lean)** —
428 `Persistence/*.lean` modules, sorry/admit/axiom = 0.

The historical copy in this repo has been moved to [`lean_archive/`](lean_archive/)
(namespace `Survival`). It is no longer maintained. Use persistence-lean for
the canonical, up-to-date formalization (namespace `Persistence`).

The 428 modules fall into three tiers of mathematical depth
(see [persistence-lean README](https://github.com/karesansui-u/persistence-lean#honest-assessment)
for the full honest assessment):

- **Tier A — Core-routed bridges (~20)**: invoke the telescoping kernel to
  derive domain-specific conclusions that do not follow from single-step
  properties (e.g. `ForgettingCurveBridge`, `DunbarBridge`, `RSABridge`)
- **Tier B — Structural core + necessity (~40)**: representation/impossibility
  theorems, structural second law (converse, minimal axioms, free repair
  impossibility, complete scope closure), resource dynamics, identity /
  asymptotic identity / phase transition, interaction defect,
  forward collapse-time prediction (`n* <= (-log theta) / rate`),
  Mathlib-backed connections (Category instance, Galois connection,
  KL embedding, Cesaro ergodic extension)
- **Tier C — Vocabulary mappings (~160)**: map domain terminology into the
  SP coordinate system. These are **naming conventions, not theorems**.
  They carry no independent mathematical weight.

The remaining ~190 modules are internal infrastructure (definitions,
API lemmas, SAT/CSP chain, stochastic layer, epistemic-control protocol).

The theorem-to-paper map is
[`PAPER_MAPPING.md`](https://github.com/karesansui-u/persistence-lean/blob/main/PAPER_MAPPING.md).

The LLM-facing abstract bridge is documented in
[`v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md`](v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md).
It connects contradiction / repair / memory-filter / dependency-rewrite
control layers to the finite net-action kernel under explicit assumptions; it
does not claim to prove LLM semantics or performance.
The baseline comparison layer is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlComparison.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlComparison.lean);
it proves that, at a fixed finite horizon, a controlled epistemic layer with
the same initial coherent mass and no larger cumulative net action preserves
at least the baseline coherent mass.
The evaluation contract layer is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlEvaluationContract.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlEvaluationContract.lean);
it shows how per-step contradiction-loss and repair-gain metrics can witness
the no-worse cumulative net-action assumption used by that comparison theorem.
The benchmark protocol layer is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicBenchmarkProtocol.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicBenchmarkProtocol.lean);
it fixes the task-surface, readout, same-horizon, same-initial-mass,
metric-dominance, and readout-alignment obligations needed before a benchmark
can invoke the evaluation contract.
The result-certificate layer is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicBenchmarkResultCertificate.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicBenchmarkResultCertificate.lean);
it states which external result-certificate witnesses are sufficient to induce
a valid benchmark protocol and invoke the same finite comparison theorem.
The evidence-packet bridge is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EvidencePacketBridge.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EvidencePacketBridge.lean);
it records the provenance, eligibility, witness, dependency-closure, and repair
guardrails expected at the implementation boundary without proving any concrete
workflow correct.
The finite LLM-side toy instantiation is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMEpistemicControlToy.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMEpistemicControlToy.lean);
it connects reasoning, memory eligibility, and continual-update dependency
repair to the same bridge interfaces without proving real model semantics.
The LLM memory use-condition toy is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMMemoryUseConditionToy.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMMemoryUseConditionToy.lean);
it makes permission, scope, deletion state, stability, and action eligibility
explicit before a memory item may be used as a current premise.
The dependency closure budget toy is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/DependencyClosureBudgetToy.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/DependencyClosureBudgetToy.lean);
it turns dependency-localization inclusions into finite invalidation, closure,
surface, and repair-touched cardinality bounds.
The LLM memory / reasoning strengthening toy is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMMemoryReasoningStrengtheningToy.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/LLMMemoryReasoningStrengtheningToy.lean);
it adds lifecycle memory guards, provenance trust ordering, minimal witness
guards, and composed repair-kernel wrappers.
The stack-level Lean entry point is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlStack.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/EpistemicControlStack.lean);
it collects the main bridge, evidence, LLM, memory, and software toy theorems
under stack-level names.
The public one-page summary is
[`v3/01_theory/en/03_epistemic_control_one_page.md`](v3/01_theory/en/03_epistemic_control_one_page.md).
The reader-facing core-paper section is
[`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md), Section 10.1.
The overview diagram for this layered structure is
[`v3/01_theory/figures/figure3_epistemic_control_stack_en.svg`](v3/01_theory/figures/figure3_epistemic_control_stack_en.svg).
The result-certificate chain diagram is
[`v3/01_theory/figures/figure4_epistemic_result_certificate_chain_en.svg`](v3/01_theory/figures/figure4_epistemic_result_certificate_chain_en.svg).
The toy software-contract instantiation is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareContractToyRepository.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareContractToyRepository.lean).
The toy evidence-packet instantiation connecting that surface to the packet
bridge is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareEvidencePacketToy.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareEvidencePacketToy.lean).
The software evidence net-action bridge is
[`https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareEvidenceNetActionBridge.lean`](https://github.com/karesansui-u/persistence-lean/blob/main/Persistence/SoftwareEvidenceNetActionBridge.lean);
it packages eligible evidence, dependency closure, repair coverage, and a valid
benchmark protocol as sufficient obligations for invoking the same finite
comparison theorem.

### Validating A New Epistemic-Control Experiment

To connect a new experiment to the Lean comparison theorem, first freeze a
manifest such as
[`v3/05_evidence/llm_epistemic_control_benchmark_manifest.md`](v3/05_evidence/llm_epistemic_control_benchmark_manifest.md).
The manifest must fix the task surface, baseline, controlled system, horizon,
per-step loss / repair metrics, dominance rule, readout alignment, and
decision rule before outcome-bearing execution. A run becomes theorem-adjacent
only by supplying the corresponding protocol witnesses; it is not theorem-side
evidence by default.

The first toy protocol packet has a deterministic scorer:

```bash
python3 analysis/epistemic_control_frozen_toy_v0/run_eval.py \
  --result-id llm_epistemic_control_frozen_toy_v0_smoke \
  --tasks v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl \
  --out v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.json \
  --summary-md v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.md
```

This checks protocol shape and toy metric dominance; it does not validate a
real model or workflow.

The first named toy result artifact is:

- [`v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.json`](v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.json)
- [`v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.md`](v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.md)

It exercises the deterministic toy certificate loop once; it is still not
validation evidence for a real model or workflow.

The next real-eval planning layer is
[`v3/05_evidence/llm_epistemic_control_real_eval_candidate_mapping.md`](v3/05_evidence/llm_epistemic_control_real_eval_candidate_mapping.md).
It maps existing implementation-side logs to candidate future protocol
witnesses for premise update, memory qualification, benchmark-audit, and
software evidence packaging. It is planning material, not support evidence.

The current Information Qualification Control (IQC) benchmark summary is
[`v3/05_evidence/iqc_failure_suite_final_result_ja.md`](v3/05_evidence/iqc_failure_suite_final_result_ja.md).
It records the latest implementation-side M1--M4 failure-suite table after the
benchmark injection path was aligned with the no-store policy: Information
Qualification Control is single-best on speechAct and permission failures,
co-best on versionState, and neutral on source attribution. The implementation
package is published in
`karesansui-u/delta-zero` PR #2 at commit `8d0b3b2`, with 220 passed and
2 warnings reported there. This is empirical benchmark evidence, not Lean
theorem-side evidence.

The first frozen real-eval candidate surface is
[`v3/05_evidence/llm_epistemic_premise_update_v0/`](v3/05_evidence/llm_epistemic_premise_update_v0/).
It fixes 12 premise-update / dependency-staleness tasks and a predeclared
loss / repair readout, but contains no model outputs or support decision.
The corresponding scorer / result schema live at
[`analysis/epistemic_control_premise_update_v0/`](analysis/epistemic_control_premise_update_v0/);
they score externally supplied baseline / controlled outputs and do not call a
model.
The output collection rule is fixed in
[`v3/05_evidence/llm_epistemic_premise_update_v0/output_collection_protocol_v0.md`](v3/05_evidence/llm_epistemic_premise_update_v0/output_collection_protocol_v0.md).
The first run condition is fixed in
[`v3/05_evidence/llm_epistemic_premise_update_v0/run_manifest_result_001.md`](v3/05_evidence/llm_epistemic_premise_update_v0/run_manifest_result_001.md).
The first completed output-bearing run is
[`v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md`](v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md);
its protocol-local decision is `silence`, not support.

The successor v1 planning layer is
[`v3/05_evidence/llm_epistemic_premise_update_v1/`](v3/05_evidence/llm_epistemic_premise_update_v1/).
It leaves v0 unchanged and freezes a slot-state readout package with scorer
preflight coverage, explicit output statuses, and first-class mixed /
ambiguous outcomes. Its scorer lives at
[`analysis/epistemic_control_premise_update_v1/`](analysis/epistemic_control_premise_update_v1/).
V1 is not support evidence before a future outcome-bearing result has
`decision = support_clean`, `protocol_shape_valid = true`, and
`promotable = true`.

### Reproducible Toy Protocol Bundle

Local bundle candidate for OSF fixation:

- bundle: `llm_epistemic_control_frozen_toy_v0_bundle.zip`
- local path: `/private/tmp/llm_epistemic_control_frozen_toy_v0_bundle.zip`
- SHA256: `2ebaf5dbf6a72e96a309d9a5c9e0ea2ed4c85270dfde9b1a3fd5f9397ac11d7c`

The bundle contains the frozen task surface, benchmark manifest, deterministic
runner, result schema, smoke result summary, named toy result artifact, and
`EpistemicBenchmarkResultCertificate.lean`. The recipe is documented in
[`analysis/epistemic_control_frozen_toy_v0/repro_bundle_manifest.md`](analysis/epistemic_control_frozen_toy_v0/repro_bundle_manifest.md).

The current evidence map is [`analysis/current_evidence_map.md`](analysis/current_evidence_map.md).

## Repository Layout

```text
v3/          public reading path, domain registry, evidence ledgers, templates
v2/          archived preprint bundle and PDF build pipeline
v1/          older archived material
lean/        Lean 4 formalization
analysis/    experiment packages, evidence maps, design notes
data/        local data summaries and derived materials
```

## Adding A Domain

New domains should not edit the main theory prose. Add them through the v3
registry and evidence ledgers:

1. Create a domain profile from [`v3/06_templates/domain_profile_template.md`](v3/06_templates/domain_profile_template.md).
2. Add a row to [`v3/03_domains/registry.tsv`](v3/03_domains/registry.tsv).
3. If there is a frozen test, add a manifest from [`v3/06_templates/frozen_test_manifest_template.md`](v3/06_templates/frozen_test_manifest_template.md).
4. Record support, no-support, silence, field demonstration, or bounded
   benchmark in [`v3/05_evidence/`](v3/05_evidence/).
5. Update [`v3/CLAIMS.md`](v3/CLAIMS.md) only if the claim taxonomy itself
   changes.

Support does not transfer across domains. Cross-domain transfer creates a
candidate mapping; it becomes support only after frozen validation in the target
domain.

## OSF

The current public OSF entry point is:

- [Structural Persistence Theory (v3)](https://osf.io/mdh7b/)

The OSF root storage is intentionally minimal: the current v3 package plus one
legacy archive folder.
