# Exp43c True Outside-Group Send Runbook

Status: sender-side runbook for the Exp43c true outside-group rerun request.
This is not an empirical result and not validation evidence.

Date: 2026-04-27

Purpose:

Turn the existing Exp43c handoff checklist into an outbound send package without
guesswork about attachment identity, zip fallback, or return-bundle handling.

Preferred handoff route:

```text
send a locked zip bundle exported from a published repository state
```

The zip route is preferred here because the official Exp43c reference artifacts
live under a gitignored `data/` directory and therefore are not guaranteed to be
present in a fresh public clone.

## 1. Inputs

Use these checked-in artifacts:

1. `analysis/g7_exp43c_replication_package_plan.md`
2. `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
3. `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`
4. `analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md`
5. `analysis/exp43_qcoloring/exp43c_execution_environment_note_template_ja.md`
6. `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`
7. `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`

## 2. Pre-Send Commands

Run these immediately before creating or sending a bundle:

```bash
git fetch origin codeberg
git rev-parse HEAD
git rev-parse origin/main
git rev-parse codeberg/main
shasum -a 256 \
  analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl \
  analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl \
  analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json
```

Expected sender judgment:

1. `HEAD`, `origin/main`, and `codeberg/main` are identical.
2. The three official reference artifacts still match the hashes listed in
   `exp43c_true_outside_handoff_checklist.md`.

If either condition fails, do not send yet.

## 2.5 Bundle Build Command

After the receiver guide / environment template are final and the repository is
committed, create the locked zip with:

```bash
scripts/build_exp43c_handoff_zip.sh
```

The generated receiver entry point is `手順書.md`. `RUN_INSTRUCTIONS_JA.md` is
kept only as an ASCII filename copy of the same instructions.

## 3. Exact Commit Hash To Put In The Message

Capture:

```bash
SEND_COMMIT_HASH=$(git rev-parse --short=12 HEAD)
SEND_COMMIT_FULL=$(git rev-parse HEAD)
printf '%s\n%s\n' "$SEND_COMMIT_HASH" "$SEND_COMMIT_FULL"
```

Use the short hash in the human-readable request body and keep the full hash in
the local send log.

## 4. Minimum Zip Bundle Contents

The zip bundle should contain:

1. `手順書.md`
2. `requirements.txt`
3. `実行環境メモ_テンプレート.md`
4. `BUNDLE_INFO.txt`
5. `analysis/exp43_qcoloring/README.md`
6. `analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md`
7. `analysis/exp43_qcoloring/exp43c_calibration_closeout.md`
8. `analysis/exp43_qcoloring/exp43c_freeze_package.md`
9. `analysis/exp43_qcoloring/exp43c_primary_report.md`
10. `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
11. `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`
12. `analysis/exp43_qcoloring/config/exp43c_primary_config.json`
13. `analysis/exp43_qcoloring/src/primary_manifest.py`
14. `analysis/exp43_qcoloring/src/pilot_runner.py`
15. `analysis/exp43_qcoloring/src/evaluate_primary.py`
16. `analysis/exp43_qcoloring/src/generator.py`
17. `analysis/exp43_qcoloring/src/cnf_encoder.py`
18. `analysis/exp43_qcoloring/src/solver.py`
19. `analysis/exp43_qcoloring/src/feature_extractor.py`
20. `analysis/exp43_qcoloring/src/__init__.py`
21. official reference artifacts:
    `exp43c_primary_manifest.jsonl`,
    `exp43c_primary_results.jsonl`,
    `exp43c_primary_evaluation.json`

Do not include:

1. Exp43 / Exp43b exploration outputs;
2. local `replication_outputs/`;
3. unrelated observational branches;
4. Backblaze / C-MAPSS / Mixed-CSP files.

## 5. Message Fill-In

Use `exp43c_true_outside_send_packet_ja.md` and fill:

1. `<SEND_COMMIT_HASH>`;
2. `<ZIP_FILENAME>`;
3. `<ZIP_SHA256>`.

Keep these points unchanged:

1. already validated primary;
2. replication request, not redesign request;
3. separate outputs only;
4. official reference artifacts must not be overwritten;
5. return bundle should include hashes, row counts, status counts, evaluation
   JSON, environment note, workaround note, and one-line conclusion.

## 6. Local Send Log

Record privately:

1. date sent;
2. recipient / group;
3. channel used;
4. exact full commit hash;
5. zip filename and sha256;
6. whether any extra context files were included.

This runbook does not require that private send log to be committed.

## 7. After Return

When the outside group returns artifacts:

1. save returned files outside the tracked repository or under an ignored
   output folder;
2. compute hashes locally;
3. verify row counts and status counts;
4. compare qualitative support decision to the official Exp43c result;
5. fill `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`;
6. classify the outcome as:
   - successful outside-group reproduction;
   - non-failure with minor drift;
   - replication failure requiring dedicated follow-up.

## 8. One-Line Operational Summary

```text
Verify remotes and official hashes, capture the exact current HEAD, send the
locked Exp43c zip with separate-output instructions, then fill the Exp43c G7
replication report template when the outside-group bundle returns.
```
