#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SHORT_HASH="$(git rev-parse --short=12 HEAD)"
FULL_HASH="$(git rev-parse HEAD)"
OUTDIR="analysis/route_a_mixed_csp/handoff_exports"
ZIP_NAME="mixed_csp_true_outside_bundle_${SHORT_HASH}.zip"
ZIP_PATH="${OUTDIR}/${ZIP_NAME}"
SHA_PATH="${ZIP_PATH}.sha256"
MANIFEST_PATH="${OUTDIR}/mixed_csp_true_outside_bundle_${SHORT_HASH}.manifest.txt"
BUNDLE_DIR_NAME="mixed_csp_true_outside_bundle_${SHORT_HASH}"
TMPDIR="$(mktemp -d)"
STAGE_DIR="${TMPDIR}/${BUNDLE_DIR_NAME}"

mkdir -p "$OUTDIR"
mkdir -p "$STAGE_DIR"

FILES=(
  analysis/route_a_mixed_csp/run_mixed_csp.py
  analysis/route_a_mixed_csp/analyze_mixed_csp.py
  analysis/route_a_mixed_csp/mixed_csp_generator.py
  analysis/route_a_mixed_csp/mixed_csp_solvers.py
  analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py
  analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl
  analysis/route_a_mixed_csp/mixed_csp_results.json
  analysis/route_a_mixed_csp/mixed_csp_results_summary.md
)

for file in "${FILES[@]}"; do
  mkdir -p "${STAGE_DIR}/$(dirname "$file")"
  cp "$file" "${STAGE_DIR}/${file}"
done

cp analysis/route_a_mixed_csp/requirements_mixed_csp.txt "${STAGE_DIR}/requirements.txt"
cp analysis/route_a_mixed_csp/mixed_csp_zip_receiver_guide_ja.md "${STAGE_DIR}/手順書.md"

cat > "${STAGE_DIR}/BUNDLE_INFO.txt" <<EOF
Mixed-CSP true outside-group handoff bundle

exported_from_commit_short: ${SHORT_HASH}
exported_from_commit_full: ${FULL_HASH}

Use 手順書.md first if you received this bundle as a zip package.
This bundle was exported from the exact published HEAD recorded above.
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
        arcname = Path(bundle) / path.relative_to(stage_root)
        zf.write(path, arcname=arcname)
PY

shasum -a 256 "$ZIP_PATH" > "$SHA_PATH"

cat > "$MANIFEST_PATH" <<EOF
Mixed-CSP true outside-group handoff zip

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
