Contributing to v3
==================

v3 is designed for shared operation. Contributions should add domains, evidence, reruns,
or clarifications without weakening the claim boundaries.


1. Adding a Domain
------------------

1. Copy `06_templates/domain_profile_template.md` into the appropriate directory under
   `03_domains/`.
2. Fill in the observability layer:
   - `specification_fixed`
   - `structurally_inferred`
   - `conditional_embedding`
3. Add exactly one row to `03_domains/registry.tsv`.
4. If there is a frozen test, add a manifest based on
   `06_templates/frozen_test_manifest_template.md`.
5. If the test fails, record the failure. Do not delete it.


2. What Must Be Frozen Before Support
-------------------------------------

Before a result can be called support, freeze:

- target structure;
- measurement unit or observation unit;
- \(V,m\) or indicator readout;
- \(d_t,r_t,L,B,M\)-side indicators;
- baseline family;
- model class;
- metric;
- split or future surface;
- support and no-support rules.


3. What Not To Do
-----------------

Do not:

- tune the mapping on the outcome-bearing archive and call it support;
- move a domain from no-support to support without a new frozen test;
- describe structurally inferred evidence as theorem-side evidence;
- claim that transfer from another domain is support;
- edit the main theory to accommodate a failed indicator;
- erase failed attempts.


4. When To Edit Core Files
--------------------------

Edit `01_theory/` or `02_foundations/` only when the theory statement itself changes.

Most contributions should edit:

- `03_domains/registry.tsv`
- a domain profile under `03_domains/`
- evidence ledgers under `05_evidence/`
- templates, if the contribution protocol needs clarification.
