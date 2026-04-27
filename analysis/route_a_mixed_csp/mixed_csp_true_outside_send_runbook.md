# Mixed-CSP True Outside-Group Send Runbook

Status: sender-side runbook for the first true outside-group rerun request.
This is not an empirical result and not validation evidence.

Date: 2026-04-27

Purpose:

Turn the existing Mixed-CSP handoff bundle into an actual outbound send without
guesswork about hash capture, attachment identity, or message wording.

Preferred handoff route:

```text
clone the published repository from the exact current HEAD
```

Acceptable practical fallback:

```text
send a zip bundle exported from that exact published HEAD
```

The repository-clone route is slightly cleaner for audit. The zip route is
often easier for an outside replicator who does not usually work with git. If
the zip is exported from the exact published HEAD and that commit hash is
recorded in the message, the rerun still counts as an outside-project rerun.

## 1. Inputs

Use these checked-in artifacts:

- `analysis/g7_true_outside_handoff_overview.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_template.md`
- `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`

## 2. Pre-Send Commands

Run these immediately before sending:

```bash
git fetch origin codeberg
git rev-parse HEAD
git rev-parse origin/main
git rev-parse codeberg/main
sha256sum \
  analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl \
  analysis/route_a_mixed_csp/mixed_csp_results.json \
  analysis/route_a_mixed_csp/mixed_csp_results_summary.md
```

Expected sender judgment:

1. `HEAD`, `origin/main`, and `codeberg/main` are identical.
2. The three official reference artifacts still match the published hashes
   listed in `mixed_csp_true_outside_handoff_checklist.md`.

If either condition fails, do not send yet.

## 3. Exact Commit Hash To Put In The Message

After the checks above, capture:

```bash
SEND_COMMIT_HASH=$(git rev-parse --short=12 HEAD)
SEND_COMMIT_FULL=$(git rev-parse HEAD)
printf '%s\n%s\n' "$SEND_COMMIT_HASH" "$SEND_COMMIT_FULL"
```

Use the short hash in the human-readable email body and keep the full hash in a
local send log.

## 4. Minimum Attachment Set

Attach or link exactly these:

1. `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
2. `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
3. `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
4. `analysis/route_a_mixed_csp/mixed_csp_results.json`
5. `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`
6. `requirements.txt`
7. `analysis/route_a_mixed_csp/mixed_csp_zip_receiver_guide_ja.md`

Optional context:

1. `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`
2. `analysis/g7_true_outside_handoff_overview.md`
3. `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`
4. `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_packet_ja.md`

## 4A. Zip Fallback Bundle

If the recipient is uncomfortable with git, create a zip bundle directly from
the exact published HEAD:

```bash
SEND_COMMIT_HASH=$(git rev-parse --short=12 HEAD)
git archive \
  --format=zip \
  --output "mixed_csp_true_outside_bundle_${SEND_COMMIT_HASH}.zip" \
  HEAD \
  analysis/route_a_mixed_csp \
  requirements.txt
shasum -a 256 "mixed_csp_true_outside_bundle_${SEND_COMMIT_HASH}.zip"
```

When using the zip route, include all of the following in the outbound
message:

1. exact published commit hash;
2. zip filename;
3. zip sha256;
4. a statement that the zip was exported from that published HEAD without local
   edits.

The recipient can then unzip the bundle and run the same command order listed
in `mixed_csp_external_rerun_package.md`.

## 5. Message Fill-In

Use `mixed_csp_true_outside_send_template.md` and replace:

- `<SEND_COMMIT_HASH>` with the exact short hash captured above

Keep these points unchanged:

1. already validated primary;
2. replication request, not redesign request;
3. separate outputs only;
4. official artifacts must not be overwritten;
5. return bundle should include hashes, row counts, support flags, held-out
   summary, environment note, and anomaly notes.
6. if zip fallback is used, say explicitly that the zip was exported from the
   published HEAD named in the message.

## 6. Local Send Log

Record the following in a private note or issue comment:

- date sent
- recipient / group
- email or channel used
- exact full commit hash
- attached filenames
- whether optional context files were included

This runbook does not require that log to be committed to the repository.

## 7. After Return

When the outside group returns artifacts:

1. save their rerun outputs outside the tracked repository or under an ignored
   output folder;
2. compute hashes locally;
3. fill
   `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`;
4. classify the outcome as:
   - successful outside-group reproduction;
   - non-failure with minor drift;
   - replication failure requiring dedicated follow-up.

## 8. One-Line Operational Summary

```text
Verify remotes and official hashes, capture the exact current HEAD, send the
frozen Mixed-CSP package with separate-output instructions, then fill the G7
replication report template when the outside-group bundle returns.
```
