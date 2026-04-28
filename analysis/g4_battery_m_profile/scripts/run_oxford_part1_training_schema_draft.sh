#!/usr/bin/env bash
set -euo pipefail

# Draft Oxford Part 1 training-feature schema candidates from converted headers.
# This reads only conversion manifest / header metadata and emits no values or
# metrics.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

CONVERTED_TRAIN_ROOT="${CONVERTED_TRAIN_ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke}"
OUTPUT="${OUTPUT:-$REPO_ROOT/analysis/g4_battery_m_profile/replication_outputs/oxford_part1_training_schema_draft.json}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
ALLOW_PARTIAL="${ALLOW_PARTIAL:-0}"

cd "$REPO_ROOT"

if [ ! -d "$CONVERTED_TRAIN_ROOT" ]; then
  printf 'Missing converted training root: %s\n' "$CONVERTED_TRAIN_ROOT" >&2
  exit 1
fi
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  printf 'Python command not found: %s\n' "$PYTHON_BIN" >&2
  printf 'Set PYTHON_BIN=/path/to/python3.\n' >&2
  exit 1
fi

if [ "$ALLOW_PARTIAL" = "1" ]; then
  EXTRA_ARG="--allow-partial-converted-smoke"
elif [ "$ALLOW_PARTIAL" != "0" ]; then
  printf 'ALLOW_PARTIAL must be 0 or 1, got: %s\n' "$ALLOW_PARTIAL" >&2
  exit 1
else
  EXTRA_ARG=""
fi

if [ -n "$EXTRA_ARG" ]; then
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/draft_oxford_training_feature_schema.py \
    --converted-train-root "$CONVERTED_TRAIN_ROOT" \
    --output "$OUTPUT" \
    "$EXTRA_ARG"
else
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/draft_oxford_training_feature_schema.py \
    --converted-train-root "$CONVERTED_TRAIN_ROOT" \
    --output "$OUTPUT"
fi

printf 'Wrote training schema draft: %s\n' "$OUTPUT"
