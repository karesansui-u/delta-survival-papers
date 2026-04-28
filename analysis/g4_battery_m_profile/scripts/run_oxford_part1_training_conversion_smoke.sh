#!/usr/bin/env bash
set -euo pipefail

# No-peek Oxford Part 1 training-conversion runner.
#
# This script intentionally runs only the pre-primary training conversion and
# converted-table smoke check. It does not convert held-out cells, compute
# endpoint values, fit models, emit metrics, or run the primary evaluation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

ROOT="${ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent/part1}"
OUTPUT_ROOT="${OUTPUT_ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke}"
SMOKE_OUTPUT="${SMOKE_OUTPUT:-$REPO_ROOT/analysis/g4_battery_m_profile/replication_outputs/oxford_part1_converted_train_smoke.json}"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
MAX_RECORDS="${MAX_RECORDS:-}"
KEEP_STAGING="${KEEP_STAGING:-0}"

cd "$REPO_ROOT"

abspath_from_repo() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s/%s\n' "$REPO_ROOT" "$1" ;;
  esac
}

ROOT="$(abspath_from_repo "$ROOT")"
OUTPUT_ROOT="$(abspath_from_repo "$OUTPUT_ROOT")"
SMOKE_OUTPUT="$(abspath_from_repo "$SMOKE_OUTPUT")"

if [ ! -d "$ROOT" ]; then
  printf 'Missing Oxford Part 1 root: %s\n' "$ROOT" >&2
  exit 1
fi

if [ -n "$MAX_RECORDS" ] && ! [[ "$MAX_RECORDS" =~ ^([1-9][0-9]*|Inf)$ ]]; then
  printf 'MAX_RECORDS must be a positive integer or Inf, got: %s\n' "$MAX_RECORDS" >&2
  exit 1
fi

if ! command -v "$MATLAB_BIN" >/dev/null 2>&1; then
  printf 'MATLAB command not found: %s\n' "$MATLAB_BIN" >&2
  printf 'Set MATLAB_BIN=/path/to/matlab or run this on a MATLAB-enabled machine.\n' >&2
  exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  printf 'Python command not found: %s\n' "$PYTHON_BIN" >&2
  printf 'Set PYTHON_BIN=/path/to/python3.\n' >&2
  exit 1
fi

if [ -d "$OUTPUT_ROOT" ] && [ -n "$(find "$OUTPUT_ROOT" -mindepth 1 -print -quit)" ]; then
  printf 'Refusing to write into non-empty output root: %s\n' "$OUTPUT_ROOT" >&2
  printf 'Use a fresh OUTPUT_ROOT for an intentional rerun.\n' >&2
  exit 1
fi
if [ -e "$OUTPUT_ROOT" ] && [ ! -d "$OUTPUT_ROOT" ]; then
  printf 'Output root exists but is not a directory: %s\n' "$OUTPUT_ROOT" >&2
  exit 1
fi

STAGING_ROOT="${OUTPUT_ROOT}.__staging_$$"
if [ -e "$STAGING_ROOT" ]; then
  printf 'Staging root already exists: %s\n' "$STAGING_ROOT" >&2
  exit 1
fi

mkdir -p "$(dirname "$SMOKE_OUTPUT")"
mkdir -p "$(dirname "$OUTPUT_ROOT")"
if [ -d "$OUTPUT_ROOT" ]; then
  rmdir "$OUTPUT_ROOT"
fi

matlab_quote() {
  printf "%s" "$1" | sed "s/'/''/g"
}

MATLAB_COMMAND_FILE="$(mktemp "${TMPDIR:-/tmp}/oxford_part1_training_conversion_XXXXXX.m")"
TMP_SMOKE_OUTPUT="${SMOKE_OUTPUT}.__staging_$$.json"
cleanup() {
  rm -f "$MATLAB_COMMAND_FILE" "$TMP_SMOKE_OUTPUT"
  if [ "$KEEP_STAGING" != "1" ] && [ -d "$STAGING_ROOT" ]; then
    rm -rf "$STAGING_ROOT"
  fi
}
trap cleanup EXIT

SCRIPT_DIR_MATLAB="$(matlab_quote "$SCRIPT_DIR")"
ROOT_MATLAB="$(matlab_quote "$ROOT")"
STAGING_ROOT_MATLAB="$(matlab_quote "$STAGING_ROOT")"
if [ -n "$MAX_RECORDS" ]; then
  MAX_RECORDS_MATLAB="$MAX_RECORDS"
  PARTIAL_ARG="--allow-partial-converted-smoke"
else
  MAX_RECORDS_MATLAB="Inf"
  PARTIAL_ARG=""
fi

cat > "$MATLAB_COMMAND_FILE" <<MATLAB
addpath('$SCRIPT_DIR_MATLAB');
export_oxford_part1_training_tables('$ROOT_MATLAB','$STAGING_ROOT_MATLAB','train_smoke',$MAX_RECORDS_MATLAB);
MATLAB

"$MATLAB_BIN" -batch "run('$(matlab_quote "$MATLAB_COMMAND_FILE")')"

if [ -n "$PARTIAL_ARG" ]; then
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
    --root "$ROOT" \
    --output "$TMP_SMOKE_OUTPUT" \
    --train-smoke \
    --converted-train-root "$STAGING_ROOT" \
    "$PARTIAL_ARG"
else
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
    --root "$ROOT" \
    --output "$TMP_SMOKE_OUTPUT" \
    --train-smoke \
    --converted-train-root "$STAGING_ROOT"
fi

mv "$STAGING_ROOT" "$OUTPUT_ROOT"

if [ -n "$PARTIAL_ARG" ]; then
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
    --root "$ROOT" \
    --output "$SMOKE_OUTPUT" \
    --train-smoke \
    --converted-train-root "$OUTPUT_ROOT" \
    "$PARTIAL_ARG"
else
  "$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
    --root "$ROOT" \
    --output "$SMOKE_OUTPUT" \
    --train-smoke \
    --converted-train-root "$OUTPUT_ROOT"
fi

rm -f "$TMP_SMOKE_OUTPUT"
printf 'Wrote converted train-smoke output: %s\n' "$SMOKE_OUTPUT"
