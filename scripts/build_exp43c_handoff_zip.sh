#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SHORT_HASH="$(git rev-parse --short=12 HEAD)"
FULL_HASH="$(git rev-parse HEAD)"
OUTDIR="analysis/exp43_qcoloring/handoff_exports"
ZIP_NAME="exp43c_true_outside_bundle_${SHORT_HASH}.zip"
ZIP_PATH="${OUTDIR}/${ZIP_NAME}"
SHA_PATH="${ZIP_PATH}.sha256"
MANIFEST_PATH="${OUTDIR}/exp43c_true_outside_bundle_${SHORT_HASH}.manifest.txt"
BUNDLE_DIR_NAME="exp43c_true_outside_bundle_${SHORT_HASH}"
TMPDIR="$(mktemp -d)"
STAGE_DIR="${TMPDIR}/${BUNDLE_DIR_NAME}"

mkdir -p "$OUTDIR"
mkdir -p "$STAGE_DIR"

FILES=(
  analysis/exp43_qcoloring/README.md
  analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md
  analysis/exp43_qcoloring/exp43c_calibration_closeout.md
  analysis/exp43_qcoloring/exp43c_freeze_package.md
  analysis/exp43_qcoloring/exp43c_primary_report.md
  analysis/exp43_qcoloring/exp43c_external_rerun_package.md
  analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md
  analysis/exp43_qcoloring/config/exp43c_primary_config.json
  analysis/exp43_qcoloring/src/__init__.py
  analysis/exp43_qcoloring/src/primary_manifest.py
  analysis/exp43_qcoloring/src/pilot_runner.py
  analysis/exp43_qcoloring/src/evaluate_primary.py
  analysis/exp43_qcoloring/src/generator.py
  analysis/exp43_qcoloring/src/cnf_encoder.py
  analysis/exp43_qcoloring/src/solver.py
  analysis/exp43_qcoloring/src/feature_extractor.py
  analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl
  analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl
  analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json
)

for file in "${FILES[@]}"; do
  mkdir -p "${STAGE_DIR}/$(dirname "$file")"
  cp "$file" "${STAGE_DIR}/${file}"
done

cat > "${STAGE_DIR}/requirements.txt" <<'EOF'
# Exp43c q-coloring rerun dependencies
python-sat>=0.1.8.dev13
numpy>=1.24
scipy>=1.10
scikit-learn>=1.3
EOF

cp analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md "${STAGE_DIR}/手順書.md"
cp analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md "${STAGE_DIR}/RUN_INSTRUCTIONS_JA.md"
cp analysis/exp43_qcoloring/exp43c_execution_environment_note_template_ja.md "${STAGE_DIR}/実行環境メモ_テンプレート.md"
cp analysis/exp43_qcoloring/exp43c_execution_environment_note_template_ja.md "${STAGE_DIR}/ENVIRONMENT_NOTE_TEMPLATE_JA.md"

cat > "${STAGE_DIR}/BUNDLE_INFO.txt" <<EOF
Exp43c true outside-group rerun bundle

exported_from_commit_short: ${SHORT_HASH}
exported_from_commit_full: ${FULL_HASH}
created_date: $(date +%F)

Purpose:
Rerun the frozen Exp43c q-coloring primary package outside the project
environment. This is a replication task, not a redesign task.

Python:
Use Python 3.10 or later. If plain Windows \`python\` is not Python 3, use
\`py -3\` as described in \`手順書.md\`.

Official reference hashes:
exp43c_primary_manifest.jsonl: e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
exp43c_primary_results.jsonl: 37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b
exp43c_primary_evaluation.json: 901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539

Receiver entry point:
手順書.md

RUN_INSTRUCTIONS_JA.md is an ASCII filename copy of the same instructions.
EOF

rm -f "$ZIP_PATH"
ROOT_FOR_ZIP="$ROOT" TMPDIR_FOR_ZIP="$TMPDIR" BUNDLE_FOR_ZIP="$BUNDLE_DIR_NAME" ZIP_PATH_FOR_ZIP="$ZIP_PATH" python3 - <<'PY'
import os
from pathlib import Path
import zipfile

root = Path(os.environ["ROOT_FOR_ZIP"])
tmpdir = Path(os.environ["TMPDIR_FOR_ZIP"])
bundle = os.environ["BUNDLE_FOR_ZIP"]
zip_path = Path(os.environ["ZIP_PATH_FOR_ZIP"])
stage_root = tmpdir / bundle

with zipfile.ZipFile(root / zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    zf.write(stage_root, arcname=bundle)
    for path in sorted(stage_root.rglob("*")):
        if path.name == ".DS_Store":
            continue
        arcname = Path(bundle) / path.relative_to(stage_root)
        zf.write(path, arcname=arcname)
PY

shasum -a 256 "$ZIP_PATH" > "$SHA_PATH"

cat > "$MANIFEST_PATH" <<EOF
Exp43c true outside-group handoff zip

exported_from_commit_short: ${SHORT_HASH}
exported_from_commit_full: ${FULL_HASH}
zip_filename: ${ZIP_NAME}
zip_sha256_file: $(basename "$SHA_PATH")

This zip was exported from the exact published HEAD recorded above.
It is intended for outside-project rerun by zip extraction, not redesign.
EOF

rm -rf "$TMPDIR"

printf 'Created %s\n' "$ZIP_PATH"
printf 'Created %s\n' "$SHA_PATH"
printf 'Created %s\n' "$MANIFEST_PATH"
