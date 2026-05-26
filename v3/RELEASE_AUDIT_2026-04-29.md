v3 Release-Candidate Audit
==========================

Status: recorded release-candidate audit

Date: 2026-04-29


1. Scope
--------

This audit checks whether the v3 public working structure is internally
consistent after the contract-coherence diagnostics rename and evidence-ledger
split.

Checked scope:

- `README.md`
- `CLAIMS.md`
- `RELEASE_NOTES.md`
- `UPLOAD_MANIFEST.md`
- `01_theory/`
- `03_domains/registry.tsv`
- `05_evidence/*.tsv`


2. Results
----------

| Check | Result |
|---|---|
| Working tree before audit | clean |
| TSV column counts | pass |
| Local Markdown links surfaced by `rg` | pass |
| Figure link in overview | target exists |
| Legacy software domain id | clean |
| Stale contract-workflow product-as-theory wording | clean: the workflow remains only an implementation layer |
| Legacy product benchmark-as-theory wording | clean |
| Legacy route / layer wording in software evidence | clean |
| Evidence-ledger separation | pass |
| `.DS_Store` in v3 tree | removed from local tree; ignored by `.gitignore` |
| Whitespace / patch check | `git diff --check` clean |


3. TSV Column Counts
--------------------

| File | Expected columns |
|---|---:|
| `03_domains/registry.tsv` | 13 |
| `05_evidence/bounded_benchmarks.tsv` | 10 |
| `05_evidence/field_demonstrations.tsv` | 9 |
| `05_evidence/frozen_packages.tsv` | 9 |
| `05_evidence/no_support.tsv` | 7 |
| `05_evidence/outside_reruns.tsv` | 8 |

All checked rows matched their file header width.


4. Claim-Boundary Notes
-----------------------

- The theory-level software domain is now `software_contract_coherence`.
- the contract-coherence workflow is treated as the current implementation layer, not the
  theory-level object.
- Public OSS merged PRs are recorded as field demonstration /
  maintainer-acceptance evidence.
- The bounded Product-arm calibration is recorded as a controlled benchmark
  surface.
- Neither layer is direct software-collapse evidence, raw precision / recall, or
  M-side profile support.


5. Remaining Open Items
-----------------------

- This audit does not run a full external Markdown-link checker; it records the
  local links surfaced by repository search and the known figure target.
- v3 remains a public working organization, while v2 remains the archived
  preprint / PDF bundle.
