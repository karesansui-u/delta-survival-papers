v3 Upload Manifest
==================

Status: superseded full-v3 manifest; current policy is restricted public export

Date: 2026-05-18

Important:

Do not upload the full `v3/` directory as a public bundle without a fresh
redaction pass. This manifest originally described the 2026-04 release-candidate
structure, before the repository accumulated non-public implementation
experiments, input-qualification cases, Hermes / MemoryGit materials, provider
smoke outputs, and patent-sensitive evaluation details.

For the current public/private boundary, use:

- `PUBLICATION_SCOPE_2026-05.md`
- `07_exports/pdf/public_structural_persistence_2026-05/README.md`

The current safe public unit is the two-PDF public set under
`07_exports/pdf/public_structural_persistence_2026-05/`.

OSF remediation note:

The May 2026 restricted bundle is safe as a standalone artifact, but OSF project
`mdh7b` should not be treated as restricted-only while older legacy entries are
still visible. Remove or hide `archive_root_legacy_2026-04-30/` and
`structural-persistence-theory-v3_2026-04-30_c2185ec3.zip` before using OSF as
the public canonical entry point for this restricted release.


1. Upload Scope
---------------

Do not upload the full `v3/` directory as the public working structure in its
current mixed state.

Current May 2026 public scope:

- `07_exports/pdf/public_structural_persistence_2026-05/README.md`
- `07_exports/pdf/public_structural_persistence_2026-05/01_structural_persistence_fixed_spec_layer_ja.pdf`
- `07_exports/pdf/public_structural_persistence_2026-05/02_structural_persistence_estimation_layer_ja.pdf`
- `07_exports/pdf/public_structural_persistence_2026-05.zip`

The corresponding source drafts may be released only through a clean source
bundle or clean branch:

- `01_theory/20_public_first_draft.md`
- `01_theory/22_public_second_draft.md`

Keep private unless separately redacted:

- `scripts/`
- raw/generated experimental outputs;
- `05_evidence/*input_qualification*`;
- `05_evidence/*memory_qualification*`;
- `05_evidence/*conversation_log*`;
- `05_evidence/*hermes*`;
- `03_domains/02_structurally_inferred/llm_input_qualification_*`;
- `07_exports/pdf/llm_input_qualification_memory_update_control_ja.pdf`;
- controller details, repair rules, provider smoke outputs, prompt packets, and
  implementation-specific claim mappings.

Historical 2026-04 full-v3 scope, retained below for archive provenance:

Include:

- `README.md`
- `CLAIMS.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `RELEASE_AUDIT_2026-04-29.md`
- `UPLOAD_MANIFEST.md`
- `UPLOAD_RECORDS.md`
- `upload_description_2026-04-29.md`
- `upload_description_2026-04-30.md`
- `CONTRIBUTING.md`
- `01_theory/`
- `02_foundations/`
- `03_domains/`
- `04_operations/`
- `05_evidence/`
- `06_templates/`
- `07_exports/`

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
4. `01_theory/02_accounting_framework.md`
5. `CLAIMS.md`
6. `03_domains/registry.tsv`
7. `05_evidence/README.md`


4. Evidence Ledgers
-------------------

For the historical 2026-04 full-v3 release-candidate, the evidence ledgers were
part of the upload and should not be omitted:

- `05_evidence/frozen_packages.tsv`
- `05_evidence/outside_reruns.tsv`
- `05_evidence/no_support.tsv`
- `05_evidence/field_demonstrations.tsv`
- `05_evidence/bounded_benchmarks.tsv`

Failed attempts and no-support records are part of the research program. For a
future evidence release, do not remove them merely because they are negative.
However, evidence materials that contain raw cases, provider outputs, scripts,
implementation-specific repair rules, or patent-sensitive details must remain
private until a separate redaction pass produces a public evidence package.


5. Pre-Upload Checks
--------------------

Run or record the following checks before creating an archive:

- confirm the intended release type: PDF-only, source, evidence, or full archive;
- local Markdown links in `v3/`;
- TSV column-count consistency for `03_domains/registry.tsv` and
  `05_evidence/*.tsv`;
- stale internal route labels or older M-side profile labels;
- local paths and private terms in PDF text: `/Users`, `Project`, `private`;
- implementation-sensitive terms: `Hermes`, `MemoryGit`, `input qualification`,
  `provider`, `smoke`, `controller`, `raw`, `claim_boundary`;
- whitespace check with `git diff --check`.

If an archive is uploaded to OSF, Zenodo, or another repository, record the
source commit hash in the upload description.


6. Upload Description and Records
---------------------------------

Use `upload_description_2026-04-29.md` for the first OSF / Zenodo description.
Use `upload_description_2026-04-30.md` for the 2026-04-30 refresh and later
updates unless a newer upload description is added.

After uploading, update `UPLOAD_RECORDS.md` with the URL, DOI, archive filename,
and checksum if available.

The first local archive was prepared as:

```text
/tmp/structural-persistence-theory-v3_2026-04-29_89b0cfa.zip
sha256:325c7553d9664c083d440fa2a3823bfc58513ed436e71140826216f071ee7b37
size:267907 bytes
source_commit:89b0cfa9ab8113d578e69f07dae5f306c7c7758a
```

The archive was uploaded to OSF project `mdh7b` via the WaterButler API:

```text
osf_file_id:osfstorage/69f1c6e0a1f4ba559ad9480b
download_url:https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f1c6e0a1f4ba559ad9480b
osf_reported_sha256:325c7553d9664c083d440fa2a3823bfc58513ed436e71140826216f071ee7b37
```

The 2026-04-30 refresh should be recorded in `UPLOAD_RECORDS.md` after upload.
The upload description intentionally points readers to `UPLOAD_RECORDS.md` for
the exact source commit and checksum, so archive metadata can be maintained
without requiring a self-referential commit hash.

The 2026-04-30 refresh was prepared as:

```text
/tmp/delta-survival-osf/structural-persistence-theory-v3_2026-04-30_d933ac6.zip
sha256:ecbef92124992d88e95c81e0d50e748e6e46af7dfd72000939526973fc789d8e
size:282555 bytes
source_commit:d933ac6371f17bfc432b4fd11f9a547e66d7fa9a
```

The archive was uploaded to OSF project `mdh7b` via the WaterButler API:

```text
original_root_osf_file_id:osfstorage/69f2ab150e70496d2b4bd884
archive_osf_file_id:osfstorage/69f303304780d1de10d948bd
archive_download_url:https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f303304780d1de10d948bd
osf_reported_sha256:ecbef92124992d88e95c81e0d50e748e6e46af7dfd72000939526973fc789d8e
root_copy_status:removed_after_archive_copy
```

The 2026-04-30 Core/PDF refresh was prepared as:

```text
/tmp/delta-survival-osf/structural-persistence-theory-v3_2026-04-30_c2185ec3.zip
sha256:74c2012388827be3099bfeb03aa1c8b58a52c6f57c3a16b0f8fb2fa1b7f80165
size:1182950 bytes
source_commit:c2185ec3b49584175dce3f78374e62d9703e6c36
```

The archive was uploaded to OSF project `mdh7b` via the WaterButler API:

```text
osf_file_id:osfstorage/69f2ffda8f11259a91435450
download_url:https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f2ffda8f11259a91435450
osf_reported_sha256:74c2012388827be3099bfeb03aa1c8b58a52c6f57c3a16b0f8fb2fa1b7f80165
```
