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
- `upload_description_2026-04-30.md`
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
- stale internal route labels or older M-side profile labels;
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
osf_file_id:osfstorage/69f2ab150e70496d2b4bd884
download_url:https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f2ab150e70496d2b4bd884
osf_reported_sha256:ecbef92124992d88e95c81e0d50e748e6e46af7dfd72000939526973fc789d8e
```
