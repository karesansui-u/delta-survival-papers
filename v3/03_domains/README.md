Domain Registry
===============

Domains are registered here so the theory can grow without turning the main papers into
an unstable list of examples.

Use `registry.tsv` as the table of record. Each domain should have one profile file and,
when applicable, one or more evidence records.


Classification Meanings
-----------------------

`registry.tsv` uses a claim-package classification rather than a domain essence.

| Classification | Meaning |
|---|---|
| specification_fixed | \(V,m\), drift, boundary, or exposure law can be fixed from the domain specification |
| inference | structure is not directly counted; observation / inference indicators and frozen validation are required |
| connection_attribute | an existing theory is mapped into \(d_t,r_t,b_t,B_n\) under stated conditions |

Only `specification_fixed` and `inference` are observability-layer classifications.
`connection_attribute` is not a third observability layer; it marks claim packages
whose main role is an existing-theory bridge.

Directory order:

| Directory | Storage role |
|---|---|
| `01_specification_fixed/` | `specification_fixed` |
| `02_structurally_inferred/` | inference-layer profiles; directory name retained for compatibility |
| `03_conditional_embedding/` | existing-theory connection attribute profiles; directory name retained for compatibility |

The numbered directories define the reading order. The `classification` values in
`registry.tsv` remain unnumbered stable identifiers.


Rule
----

Do not add a new domain to the main theory text. Add it to the registry, then create a
domain profile.
