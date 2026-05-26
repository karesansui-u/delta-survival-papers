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

Lean formalization is in [`lean/`](lean/). Current status is `168 Survival
modules`, with no project-level `sorry`, `admit`, or declared `axiom` in the
imported `Survival` target. The top-level import spine is
[`lean/Survival.lean`](lean/Survival.lean). The theorem-to-paper map is
[`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md), and the strengthened Lean
landing page is [`lean/README.md`](lean/README.md).

The LLM-facing abstract bridge is documented in
[`v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md`](v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md).
It connects contradiction / repair / memory-filter / dependency-rewrite
control layers to the finite net-action kernel under explicit assumptions; it
does not claim to prove LLM semantics or performance.
The evidence-packet bridge is
[`lean/Survival/EvidencePacketBridge.lean`](lean/Survival/EvidencePacketBridge.lean);
it records the provenance, eligibility, witness, dependency-closure, and repair
guardrails expected at the implementation boundary without proving any concrete
workflow correct.
The public one-page summary is
[`v3/01_theory/en/03_epistemic_control_one_page.md`](v3/01_theory/en/03_epistemic_control_one_page.md).
The reader-facing core-paper section is
[`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md), Section 10.1.
The overview diagram for this layered structure is
[`v3/01_theory/figures/figure3_epistemic_control_stack_en.svg`](v3/01_theory/figures/figure3_epistemic_control_stack_en.svg).
The toy software-contract instantiation is
[`lean/Survival/SoftwareContractToyRepository.lean`](lean/Survival/SoftwareContractToyRepository.lean).

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
