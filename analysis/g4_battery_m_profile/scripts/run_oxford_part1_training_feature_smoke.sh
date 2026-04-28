#!/usr/bin/env bash
set -euo pipefail

# No-peek Oxford Part 1 training-feature smoke runner.
#
# This script runs after the MATLAB training conversion and full converted
# manifest/header smoke have passed. It may read training values only. It does
# not read held-out cells, emit values, compute metrics, or run the primary.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

ROOT="${ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent/part1}"
CONVERTED_TRAIN_ROOT="${CONVERTED_TRAIN_ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke}"
SMOKE_OUTPUT="${SMOKE_OUTPUT:-$REPO_ROOT/analysis/g4_battery_m_profile/replication_outputs/oxford_part1_training_feature_smoke.json}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
FEATURE_SCHEMA="${FEATURE_SCHEMA:-}"

cd "$REPO_ROOT"

if [ ! -d "$ROOT" ]; then
  printf 'Missing Oxford Part 1 root: %s\n' "$ROOT" >&2
  exit 1
fi
if [ ! -d "$CONVERTED_TRAIN_ROOT" ]; then
  printf 'Missing converted training root: %s\n' "$CONVERTED_TRAIN_ROOT" >&2
  exit 1
fi
if [ -z "$FEATURE_SCHEMA" ]; then
  printf 'FEATURE_SCHEMA is required for training-feature smoke.\n' >&2
  exit 1
fi
if [ ! -f "$FEATURE_SCHEMA" ]; then
  printf 'Missing FEATURE_SCHEMA: %s\n' "$FEATURE_SCHEMA" >&2
  exit 1
fi
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  printf 'Python command not found: %s\n' "$PYTHON_BIN" >&2
  printf 'Set PYTHON_BIN=/path/to/python3.\n' >&2
  exit 1
fi

mkdir -p "$(dirname "$SMOKE_OUTPUT")"

"$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
  --root "$ROOT" \
  --output "$SMOKE_OUTPUT" \
  --training-feature-smoke \
  --converted-train-root "$CONVERTED_TRAIN_ROOT" \
  --feature-schema "$FEATURE_SCHEMA"

printf 'Wrote training-feature smoke output: %s\n' "$SMOKE_OUTPUT"
