# v3 Exports

This directory is the public export surface for v3-readable files.

The current PDF build pipeline still emits files under `v2/pdf用/` for compatibility
with the existing preprint builder. Files under `v3/07_exports/pdf/` are copied
exports for readers and OSF/GitHub navigation.

Current main PDFs:

- `pdf/public_structural_persistence_2026-05/`
  - public-facing two-PDF set for the structural persistence theory drafts
  - excludes internal master/core PDFs and private evidence/config details

Public-now set:

- `pdf/public_structural_persistence_2026-05/01_structural_persistence_fixed_spec_layer_ja.pdf`
- `pdf/public_structural_persistence_2026-05/02_structural_persistence_estimation_layer_ja.pdf`

Review-before-public set:

- `pdf/02_core.pdf`
- `pdf/20_public_first_draft.pdf`
- `pdf/22_public_second_draft.pdf`
- `pdf/02_core_en.pdf`
- `pdf/10_paper1_minimal_form_en.pdf`
- `pdf/11_paper2_balance_principle_en.pdf`
- `pdf/Core_構造持続の最小核と収支原理.pdf`
- `pdf/1_構造持続の最小形式.pdf`
- `pdf/2_構造持続の収支原理.pdf`

Private unless separately redacted:

- `pdf/llm_input_qualification_memory_update_control_ja.pdf`

The top-level repository should stay private until a clean public branch or
allowlisted archive is prepared. See `../PUBLICATION_SCOPE_2026-05.md`.
