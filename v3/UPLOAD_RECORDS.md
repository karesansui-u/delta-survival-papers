v3 Upload Records
=================

Status: upload record ledger

Purpose: record public uploads of the v3 working structure.

Current caution:

As of the 2026-05-18 audit, the intended current public artifact is the
restricted two-PDF bundle. The OSF project may still expose earlier legacy
uploads and result folders. Do not treat OSF project `mdh7b` as restricted-only
until the legacy folder and older full-v3 archive are removed or hidden.


1. Record Format
----------------

For each upload, record:

- upload date;
- platform;
- title;
- URL;
- DOI, if any;
- source commit;
- archive filename;
- checksum, if available;
- notes on whether the full `v3/` directory was included.


2. Records
----------

| Date | Platform | Title | URL | DOI | Source commit | Archive filename | Checksum | Notes |
|---|---|---|---|---|---|---|---|---|
| 2026-04-29 | OSF | Structural Persistence Theory v3 public working structure | `https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f1c6e0a1f4ba559ad9480b` | pending | `89b0cfa9ab8113d578e69f07dae5f306c7c7758a` | `structural-persistence-theory-v3_2026-04-29_89b0cfa.zip` | `sha256:325c7553d9664c083d440fa2a3823bfc58513ed436e71140826216f071ee7b37` | Uploaded via OSF / WaterButler API to project `mdh7b`; OSF file id `osfstorage/69f1c6e0a1f4ba559ad9480b`; size `267907` bytes; OSF-reported sha256 matched local archive; full `v3/` directory included under archive prefix |
| 2026-04-30 | OSF | Structural Persistence Theory v3 public working structure refresh | `https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f303304780d1de10d948bd` | pending | `d933ac6371f17bfc432b4fd11f9a547e66d7fa9a` | `structural-persistence-theory-v3_2026-04-30_d933ac6.zip` | `sha256:ecbef92124992d88e95c81e0d50e748e6e46af7dfd72000939526973fc789d8e` | Uploaded via OSF / WaterButler API to project `mdh7b`; original root OSF file id `osfstorage/69f2ab150e70496d2b4bd884`; archived as OSF file id `osfstorage/69f303304780d1de10d948bd`; size `282555` bytes; OSF-reported sha256 matched local archive; root copy removed after archive copy; refresh includes refined Core framing, resource-boundary terminology, v3 metadata, and the full `v3/` directory under archive prefix |
| 2026-04-30 | OSF | Structural Persistence Theory v3 public working structure Core/PDF refresh | `https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69f2ffda8f11259a91435450` | pending | `c2185ec3b49584175dce3f78374e62d9703e6c36` | `structural-persistence-theory-v3_2026-04-30_c2185ec3.zip` | `sha256:74c2012388827be3099bfeb03aa1c8b58a52c6f57c3a16b0f8fb2fa1b7f80165` | Uploaded via OSF / WaterButler API to project `mdh7b`; OSF file id `osfstorage/69f2ffda8f11259a91435450`; size `1182950` bytes; OSF-reported sha256 matched local archive; refresh includes latest Core mapping clarifications, regenerated public PDFs in `07_exports/`, and the full `v3/` directory under archive prefix |
| 2026-05-18 | OSF | Structural Persistence Theory restricted public PDF bundle | `https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/6a0a0f01656ace1d0981fdf1` | pending | `73966ccf43a3c37cf323bd31e2aa607fbe7fd0ea` | `public_structural_persistence_2026-05_restricted_pdf_bundle_73966cc.zip` | `sha256:579f028a0fa5c8f99e47b87c6fe12851110d0568167beeda69e60cf187f01a3c` | Uploaded via OSF / WaterButler API to project `mdh7b`; OSF file id `osfstorage/6a0a0f01656ace1d0981fdf1`; size `577176` bytes; OSF-reported sha256 matched local archive; restricted public bundle includes only the May 2026 two-PDF public set and README, not the full `v3/` directory |


3. Visibility Audits
--------------------

2026-05-18 audit:

- GitHub repository `karesansui-u/delta-survival-papers` remained private.
- The May 2026 restricted PDF bundle contains only the two public PDFs and
  README.
- OSF project `mdh7b` was public and still listed legacy entries outside the
  May 2026 restricted bundle:
  - `archive_root_legacy_2026-04-30/`
  - `structural-persistence-theory-v3_2026-04-30_c2185ec3.zip`
- The legacy folder listed experiment/result-style materials such as
  `exp42_scope_gradient_results_2026-04-22/`,
  `exp41_width_replication_results_2026-04-22.zip`, and
  `mixed_csp_true_outside_g7_8e63981_2026-04-28.zip`.
- Attempted API deletion of `archive_root_legacy_2026-04-30/` returned
  `403 Forbidden`; the active shell credentials had only read permission on the
  OSF project.

Required remediation before calling OSF restricted-only:

- remove or hide `archive_root_legacy_2026-04-30/`;
- remove or hide `structural-persistence-theory-v3_2026-04-30_c2185ec3.zip`;
- update the OSF project description so the current public package points to
  `public_structural_persistence_2026-05_restricted_pdf_bundle_73966cc.zip`;
- rerun the OSF file listing check and record that only the restricted bundle
  remains public.
