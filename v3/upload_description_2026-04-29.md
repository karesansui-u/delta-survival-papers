v3 Upload Description
=====================

Status: send-ready upload description

Date: 2026-04-29

Source commit:

```text
94c96c5ae7eedd64efc8ec63261482079a7e6352
```


Short Description
-----------------

This upload contains the v3 public working structure for the Structural
Persistence Theory program.

v3 is not a replacement for the archived v2 preprint / PDF bundle. Instead, it
is the public, extensible organization for:

- the stable theory spine;
- public claim boundaries;
- domain registration;
- evidence ledgers;
- no-support and failure records;
- contributor-facing templates for future validation.

The recommended entry point is `README.md`. The public claim boundary is
`CLAIMS.md`.


Relationship to v2
------------------

- v2: archived preprint and PDF bundle.
- v3: current public working organization and evidence registry.

v3 keeps the mathematical core small while allowing new domains to enter through
`03_domains/registry.tsv`, domain profiles, and `05_evidence/` ledgers.


What Is Included
----------------

The archive should include the full `v3/` directory:

- `README.md`
- `CLAIMS.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `RELEASE_AUDIT_2026-04-29.md`
- `UPLOAD_MANIFEST.md`
- `CONTRIBUTING.md`
- `01_theory/`
- `02_foundations/`
- `03_domains/`
- `04_operations/`
- `05_evidence/`
- `06_templates/`


Evidence and Claim Boundary
---------------------------

The evidence ledgers separate:

- frozen packages;
- outside reruns;
- no-support records;
- field demonstrations;
- bounded benchmarks.

Failed attempts and no-support records are intentionally preserved. They are
part of the research program and should not be removed from public bundles.

Software contract-coherence diagnostics is recorded as a structurally inferred
software track. DeltaLint is the current implementation / workflow name, not the
theory-level object.


Pre-Upload Audit
----------------

The release-candidate audit is recorded in:

```text
RELEASE_AUDIT_2026-04-29.md
```

The audit checked TSV column counts, stale labels, evidence-ledger separation,
local surfaced links, ignored local system files, and whitespace / patch status.


Suggested Citation Note
-----------------------

When citing this upload, please cite it as a working public structure and
evidence registry for the Structural Persistence Theory program, not as a
single finalized preprint.

Suggested wording:

```text
Structural Persistence Theory v3 public working structure, source commit
94c96c5ae7eedd64efc8ec63261482079a7e6352.
```
