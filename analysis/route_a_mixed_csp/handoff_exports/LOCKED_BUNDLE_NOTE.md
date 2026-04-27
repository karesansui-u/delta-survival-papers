# Locked Bundle Note

Date: 2026-04-27

This folder contains a distribution-facing Mixed-CSP rerun bundle and a
separate locked archive copy.

## Current distribution-facing bundle

- file:
  `mixed_csp_true_outside_bundle_df41b0fa7208.zip`
- sha256:
  `0d68f52f3b80c02f555065280d116ae785392ac3ed601105651a20593eaf1170`

## Locked archive copy

- directory:
  `archive_locked/2026-04-27_df41b0fa7208/`
- contents:
  - `mixed_csp_true_outside_bundle_df41b0fa7208.zip`
  - `mixed_csp_true_outside_bundle_df41b0fa7208.manifest.txt`
  - `mixed_csp_true_outside_bundle_df41b0fa7208.zip.sha256`

## Superseded local-only materials

Older `68edc582456f` send artifacts were moved under:

- `superseded/`

They are retained only for local forensic reference and should not be sent.

## Operational rule

Do not rebuild, replace, or resend another Mixed-CSP zip under this directory
without first creating a new commit-specific filename and keeping this locked
copy intact.
