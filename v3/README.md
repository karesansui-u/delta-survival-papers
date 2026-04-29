Structural Persistence Theory v3
================================

v3 is the public, extensible organization of the Structural Persistence Theory program.

v2 remains the archived preprint bundle. v3 is the working public structure for reading,
domain registration, external validation, and contributor workflows. The goal is to make
the theory usable without letting new domains blur the claim boundaries.


1. Read Order
-------------

Start here:

1. `theory/00_map.md`
2. `theory/01_overview.md`
3. `theory/02_core.md`
4. `CLAIMS.md`
5. `domains/registry.tsv`

Then read the layer you need:

- Main spine: `theory/10_paper1_minimal_form.md`, `theory/11_paper2_balance_principle.md`
- Mathematical foundations: `foundations/`
- Domain anchors: `domains/`
- Operational rules: `operations/`
- Evidence and rerun records: `evidence/`


2. Stable Core
--------------

The stable core is intentionally small:

- minimal kernel: \(S = M e^{-L}\)
- balance kernel: \(S = M e^{-B}\)
- pure consumption: \(B_n = \sum_{t<n}(d_t-r_t)\)
- observability layers:
  - specification-fixed structural layer
  - structurally inferred layer
  - conditional structural-embedding layer
- validation discipline:
  - candidate
  - frozen
  - supported / no-support / silence

New domains should not require edits to the core theory. They should enter through
`domains/registry.tsv`, a domain profile, and the evidence ledgers.


3. Extension Rule
-----------------

Adding a domain means adding a registered mapping, not extending the theory by prose.

Use this sequence:

1. Create a domain profile from `templates/domain_profile_template.md`.
2. Add one row to `domains/registry.tsv`.
3. If there is a frozen test, add a manifest using `templates/frozen_test_manifest_template.md`.
4. Record support, no-support, or silence in `evidence/`.
5. Update `CLAIMS.md` only if the claim taxonomy itself changes.

Do not import support from one domain into another. Cross-domain transfer creates a
candidate mapping or candidate intervention; it becomes support only after frozen
validation in the target domain.


4. Why This Layout Exists
-------------------------

The theory can grow across many domains only if the main text does not become a list of
examples. v3 keeps the main claims fixed and lets domains grow through a registry.

This prevents three common failures:

- treating Paper 1 as an obvious prelude instead of the first nontrivial representation theorem;
- treating structurally inferred domains as theorem-side evidence;
- treating a successful design transfer as support before target-domain validation.

