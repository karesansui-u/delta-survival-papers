Structural Persistence Theory v3
================================

v3 is the public, extensible organization of the Structural Persistence Theory program.

v2 remains the archived preprint bundle. v3 is the working public structure for reading,
domain registration, external validation, and contributor workflows. The goal is to make
the theory usable without letting new domains blur the claim boundaries.


1. Read Order
-------------

Start here:

1. `01_theory/00_map.md`
2. `01_theory/01_overview.md`
3. `01_theory/02_accounting_framework.md`
4. `CLAIMS.md`
5. `RELEASE_NOTES.md`
6. `RELEASE_AUDIT_2026-04-29.md`
7. `03_domains/registry.tsv`

Then read the layer you need:

- Main spine: `01_theory/10_log_ratio_accounting.md`, `01_theory/11_balance_accounting.md`
- Mathematical foundations: `02_foundations/`
- Domain anchors: `03_domains/`
- Operational rules: `04_operations/`
- Evidence and rerun records: `05_evidence/`
- Upload bundle guidance: `UPLOAD_MANIFEST.md`
- Upload description and records: `upload_description_2026-04-30.md`,
  `UPLOAD_RECORDS.md`

English entry path:

- `01_theory/en/02_core_en.md`
- `01_theory/en/10_paper1_minimal_form_en.md`
- `01_theory/en/11_paper2_balance_principle_en.md`
- Japanese PDFs: `07_exports/pdf/02_core.pdf`,
  `07_exports/pdf/20_public_first_draft.pdf`,
  `07_exports/pdf/22_public_second_draft.pdf`
- English PDFs: `07_exports/pdf/02_core_en.pdf`,
  `07_exports/pdf/10_paper1_minimal_form_en.pdf`,
  `07_exports/pdf/11_paper2_balance_principle_en.pdf`


2. Stable Core
--------------

The stable core is intentionally small:

- minimal kernel: \(S = M e^{-L}\)
- balance kernel: \(S = M e^{-B}\)
- cumulative net consumption: \(B_n = \sum_{t<n}(d_t-r_t)\)
- classification and connection:
  - specification-fixed layer
  - inference layer
  - existing-theory connection attribute
- validation discipline:
  - candidate
  - frozen
  - supported / no-support / silence

New domains should not require edits to the core theory. They should enter through
`03_domains/registry.tsv`, a domain profile, and the evidence ledgers.


3. Current Hard Evidence
------------------------

The strongest current empirical entry point is the specification-fixed layer,
not the inference layer.

Two frozen packages already have clean outside-rerun anchors:

- Mixed-CSP: 3/3 outside reruns, each with 12000 primary rows, 0 checked
  core mismatches, and reproduced support flags.
- q-coloring (Exp43c package): 3/3 outside reruns, each with 4000 primary rows, 0
  checked core mismatches, TIMEOUT = 0, MALFORMED = 0, and the same
  qualitative support decision.

This is not a proof of the whole theory and not a universal-law declaration.
It is the first hard law-side footing: frozen packages in which a structural
\(L\) / first-moment coordinate is evaluated against raw baselines and then
successfully rerun outside the author's environment.

See `05_evidence/outside_reruns.tsv`,
`05_evidence/frozen_packages.tsv`, and
`../analysis/g7_route_a_true_outside_replication_summary.md`.


4. Extension Rule
-----------------

Adding a domain means adding a registered mapping, not extending the theory by prose.

Use this sequence:

1. Create a domain profile from `06_templates/domain_profile_template.md`.
2. Add one row to `03_domains/registry.tsv`.
3. If there is a frozen test, add a manifest using `06_templates/frozen_test_manifest_template.md`.
4. If the test involves \(M\)-side component profiles, also use
   `06_templates/m_profile_validation_manifest_template.md`.
5. Record support, no-support, silence, field demonstration, or bounded
   calibration in `05_evidence/`.
6. Update `CLAIMS.md` only if the claim taxonomy itself changes.

Do not import support from one domain into another. Cross-domain transfer creates a
candidate mapping or candidate intervention; it becomes support only after frozen
validation in the target domain.

For \(M\)-side work, \(M\) is the familiar support-side effective maintenance
amount: usable resource, slack, or capacity for the pre-fixed maintenance
problem. Component profiles are optional diagnostic readouts, not a built-in
theory for choosing interventions.


5. Why This Layout Exists
-------------------------

The theory can grow across many domains only if the main text does not become a list of
examples. v3 keeps the main claims fixed and lets domains grow through a registry.

This prevents three common failures:

- treating Paper 1 as an obvious prelude instead of the first nontrivial representation theorem;
- treating inference-layer domains as theorem-side evidence;
- treating a successful design transfer as support before target-domain validation.
