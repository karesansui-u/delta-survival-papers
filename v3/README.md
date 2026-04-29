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
3. `01_theory/02_core.md`
4. `CLAIMS.md`
5. `03_domains/registry.tsv`

Then read the layer you need:

- Main spine: `01_theory/10_paper1_minimal_form.md`, `01_theory/11_paper2_balance_principle.md`
- Mathematical foundations: `02_foundations/`
- Domain anchors: `03_domains/`
- Operational rules: `04_operations/`
- Evidence and rerun records: `05_evidence/`


2. Stable Core
--------------

The stable core is intentionally small:

- minimal kernel: \(S = M e^{-L}\)
- balance kernel: \(S = M e^{-B}\)
- cumulative net consumption: \(B_n = \sum_{t<n}(d_t-r_t)\)
- observability layers:
  - specification-fixed structural layer
  - structurally inferred layer
  - conditional structural-embedding layer
- validation discipline:
  - candidate
  - frozen
  - supported / no-support / silence

New domains should not require edits to the core theory. They should enter through
`03_domains/registry.tsv`, a domain profile, and the evidence ledgers.


3. Extension Rule
-----------------

Adding a domain means adding a registered mapping, not extending the theory by prose.

Use this sequence:

1. Create a domain profile from `06_templates/domain_profile_template.md`.
2. Add one row to `03_domains/registry.tsv`.
3. If there is a frozen test, add a manifest using `06_templates/frozen_test_manifest_template.md`.
4. If the test involves \(M\)-side component profiles, also use
   `06_templates/m_profile_validation_manifest_template.md`.
5. If the test claims intervention-ranking support, also use
   `06_templates/intervention_ranking_prereg_template.md`.
6. Record support, no-support, or silence in `05_evidence/`.
7. Update `CLAIMS.md` only if the claim taxonomy itself changes.

Do not import support from one domain into another. Cross-domain transfer creates a
candidate mapping or candidate intervention; it becomes support only after frozen
validation in the target domain.

For \(M\)-side work, held-out risk-prediction improvement is preparatory support.
The primary M-side target is a pre-frozen intervention-ranking prediction.


4. Why This Layout Exists
-------------------------

The theory can grow across many domains only if the main text does not become a list of
examples. v3 keeps the main claims fixed and lets domains grow through a registry.

This prevents three common failures:

- treating Paper 1 as an obvious prelude instead of the first nontrivial representation theorem;
- treating structurally inferred domains as theorem-side evidence;
- treating a successful design transfer as support before target-domain validation.
