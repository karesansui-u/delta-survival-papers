Domain Registry
===============

Domains are registered here so the theory can grow without turning the main papers into
an unstable list of examples.

Use `registry.tsv` as the table of record. Each domain should have one profile file and,
when applicable, one or more evidence records.


Layer Meanings
--------------

| Layer | Meaning |
|---|---|
| specification_fixed | \(V,m\), drift, boundary, or exposure law can be fixed from the domain specification |
| structurally_inferred | structure is not directly counted; observation / inference indicators and frozen validation are required |
| conditional_embedding | an existing theory is mapped into \(d_t,r_t,b_t,B_n\) under stated conditions |

Directory order:

| Directory | Layer |
|---|---|
| `01_specification_fixed/` | `specification_fixed` |
| `02_structurally_inferred/` | `structurally_inferred` |
| `03_conditional_embedding/` | `conditional_embedding` |

The numbered directories define the reading order. The `layer` values in `registry.tsv`
remain unnumbered stable identifiers.


Rule
----

Do not add a new domain to the main theory text. Add it to the registry, then create a
domain profile.
