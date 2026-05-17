# Public / Private Scope for May 2026

Status: current publication gate

Date: 2026-05-18

OSF caution: the May 2026 two-PDF bundle is safe as a standalone artifact, but
the OSF project `mdh7b` may still expose earlier legacy uploads. Do not describe
the OSF project as restricted to the May 2026 bundle until the legacy public
folder and older full-v3 archive have been removed or the project has been made
private.

This repository is still private. Do not flip the full GitHub repository to
public visibility as-is. The working tree contains public theory drafts together
with non-public implementation experiments, memory-control cases, scripts, and
patent-sensitive evaluation details.

The current public release unit is the two-PDF public set under:

```text
07_exports/pdf/public_structural_persistence_2026-05/
```

A zip bundle is also prepared at:

```text
07_exports/pdf/public_structural_persistence_2026-05.zip
```

## Public Now

The following files may be published as the May 2026 reader-facing package:

- `07_exports/pdf/public_structural_persistence_2026-05/README.md`
- `07_exports/pdf/public_structural_persistence_2026-05/01_structural_persistence_fixed_spec_layer_ja.pdf`
- `07_exports/pdf/public_structural_persistence_2026-05/02_structural_persistence_estimation_layer_ja.pdf`

Current hashes:

```text
94db3e860f1e983c9e933d382335c12f8e50c6f41c67f9d8df493f162011e336  01_structural_persistence_fixed_spec_layer_ja.pdf
afa8546044ae85cc9708a4268e705aa633755d78adaf1817966cb9c440c23e09  02_structural_persistence_estimation_layer_ja.pdf
579f028a0fa5c8f99e47b87c6fe12851110d0568167beeda69e60cf187f01a3c  public_structural_persistence_2026-05.zip
```

The corresponding source drafts are public-facing in content, but should be
published only as part of a clean release branch or clean archive:

- `01_theory/20_public_first_draft.md`
- `01_theory/22_public_second_draft.md`

## Review Before Wider Public Release

These files can become public after citation, terminology, and claim-boundary
review:

- `README.md`
- `CLAIMS.md`
- `01_theory/00_map.md`
- `01_theory/01_overview.md`
- `01_theory/02_accounting_framework.md`
- `02_foundations/20_conditional_derivation.md`
- `02_foundations/21_balance_details.md`
- selected `05_evidence` dashboard / ledger summaries that contain no raw cases,
  scripts, provider outputs, or implementation-specific repair rules.

## Keep Private

Do not publish the following from this repository without a separate redaction
pass:

- `scripts/`
- `private/`, `results/`, `runs/`, `logs/`, `outputs/`, `artifacts/`
- raw or generated experimental outputs
- provider smoke results
- JSONL cases that reveal memory-control evaluation surfaces
- Hermes Agent / MemoryGit implementation experiments
- input-qualification schemas, provider adapters, and test cases
- controller details, repair rules, prompt packets, or model-routing logic
- patent-support notes or implementation-specific claim mappings

This includes experimental result archives and OSF legacy folders such as
`archive_root_legacy_2026-04-30/` when they contain experiment-result folders,
raw rerun bundles, or full working-structure archives.

Current examples that should stay private unless separately redacted:

- `03_domains/02_structurally_inferred/llm_input_qualification_*`
- `05_evidence/*input_qualification*`
- `05_evidence/*memory_qualification*`
- `05_evidence/*conversation_log*`
- `05_evidence/*hermes*`
- `07_exports/pdf/llm_input_qualification_memory_update_control_ja.pdf`

## GitHub Visibility Rule

Do not make `karesansui-u/delta-survival-papers` public directly while it
contains the mixed working tree.

If a public GitHub repository is needed, create a clean public branch or a
separate clean repository from an allowlist. The minimum allowlist is the
two-PDF public set above. A wider source release should be produced only after a
fresh redaction review.

## OSF Visibility Rule

For OSF project `mdh7b`, the intended current public artifact is only:

- `public_structural_persistence_2026-05_restricted_pdf_bundle_73966cc.zip`

Remove or hide these legacy public entries before treating OSF as clean under
the May 2026 publication gate:

- `archive_root_legacy_2026-04-30/`
- `structural-persistence-theory-v3_2026-04-30_c2185ec3.zip`

If removal is not possible immediately, keep the OSF project private or clearly
mark the project as containing legacy public materials that are not part of the
current restricted release.

## Required Pre-Publication Checks

Before uploading a public bundle:

- extract PDF text and search for local paths such as `/Users`, `Project`, and
  `private`;
- search for implementation-sensitive strings such as `Hermes`, `MemoryGit`,
  `input qualification`, `provider`, `smoke`, `controller`, `raw`, and
  `claim_boundary`;
- confirm `git diff --check` is clean for the release files;
- record hashes for every public artifact;
- record whether the release is a PDF-only package, a source package, or an
  evidence package.
