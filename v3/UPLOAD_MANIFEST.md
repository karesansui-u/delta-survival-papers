v3 Upload Manifest
==================

Status: release-candidate upload manifest

Date: 2026-04-29


1. Upload Scope
---------------

Upload the full `v3/` directory as the public working structure.

Include:

- `README.md`
- `CLAIMS.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `RELEASE_AUDIT_2026-04-29.md`
- `UPLOAD_MANIFEST.md`
- `UPLOAD_RECORDS.md`
- `upload_description_2026-04-29.md`
- `CONTRIBUTING.md`
- `01_theory/`
- `02_foundations/`
- `03_domains/`
- `04_operations/`
- `05_evidence/`
- `06_templates/`

Do not upload ignored local system files such as `.DS_Store`.


2. Relationship to v2
---------------------

v2 remains the archived preprint bundle. v3 is the public, extensible structure
for domain registration, evidence ledgers, and contributor workflows.

If both v2 and v3 are uploaded, describe them as:

- v2: archived preprint and PDF bundle;
- v3: current public working organization and evidence registry.


3. Reader Entry Points
----------------------

Recommended external reading order:

1. `README.md`
2. `01_theory/00_map.md`
3. `01_theory/01_overview.md`
4. `01_theory/02_core.md`
5. `CLAIMS.md`
6. `03_domains/registry.tsv`
7. `05_evidence/README.md`


4. Evidence Ledgers
-------------------

The evidence ledgers are part of the upload and should not be omitted:

- `05_evidence/frozen_packages.tsv`
- `05_evidence/outside_reruns.tsv`
- `05_evidence/no_support.tsv`
- `05_evidence/field_demonstrations.tsv`
- `05_evidence/bounded_benchmarks.tsv`

Failed attempts and no-support records are part of the research program. Do not
remove them from public bundles.


5. Pre-Upload Checks
--------------------

Run or record the following checks before creating an archive:

- local Markdown links in `v3/`;
- TSV column-count consistency for `03_domains/registry.tsv` and
  `05_evidence/*.tsv`;
- stale internal route labels or older M-side ranking-first labels;
- whitespace check with `git diff --check`.

If an archive is uploaded to OSF, Zenodo, or another repository, record the
source commit hash in the upload description.


6. Upload Description and Records
---------------------------------

Use `upload_description_2026-04-29.md` as the initial OSF / Zenodo description
for source commit:

```text
94c96c5ae7eedd64efc8ec63261482079a7e6352
```

After uploading, update `UPLOAD_RECORDS.md` with the URL, DOI, archive filename,
and checksum if available.
