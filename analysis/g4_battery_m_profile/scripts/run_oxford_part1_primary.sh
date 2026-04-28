#!/usr/bin/env bash
set -euo pipefail

# Frozen Oxford Part 1 one-time primary runner.
#
# This script converts held-out cells and evaluates the primary exactly once.
# It must not be used until the freeze manifest has been promoted and the
# one-time primary command slot has been filled.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

ROOT="${ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent/part1}"
CONVERTED_TRAIN_ROOT="${CONVERTED_TRAIN_ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/train_smoke}"
CONVERTED_TEST_ROOT="${CONVERTED_TEST_ROOT:-$REPO_ROOT/analysis/g4_battery_m_profile/data/oxford_path_dependent_converted/heldout_primary}"
PRIMARY_OUTPUT="${PRIMARY_OUTPUT:-$REPO_ROOT/analysis/g4_battery_m_profile/replication_outputs/oxford_part1_primary_results.json}"
PRIMARY_REPORT="${PRIMARY_REPORT:-$REPO_ROOT/analysis/g4_battery_m_profile/replication_outputs/oxford_part1_primary_report.md}"
FEATURE_SCHEMA="${FEATURE_SCHEMA:-$REPO_ROOT/analysis/g4_battery_m_profile/oxford_part1_training_feature_schema_frozen.json}"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
CONFIRM_FROZEN_PRIMARY="${CONFIRM_FROZEN_PRIMARY:-0}"
KEEP_STAGING="${KEEP_STAGING:-0}"

cd "$REPO_ROOT"

abspath_from_repo() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s/%s\n' "$REPO_ROOT" "$1" ;;
  esac
}

ROOT="$(abspath_from_repo "$ROOT")"
CONVERTED_TRAIN_ROOT="$(abspath_from_repo "$CONVERTED_TRAIN_ROOT")"
CONVERTED_TEST_ROOT="$(abspath_from_repo "$CONVERTED_TEST_ROOT")"
PRIMARY_OUTPUT="$(abspath_from_repo "$PRIMARY_OUTPUT")"
PRIMARY_REPORT="$(abspath_from_repo "$PRIMARY_REPORT")"
FEATURE_SCHEMA="$(abspath_from_repo "$FEATURE_SCHEMA")"

if [ "$CONFIRM_FROZEN_PRIMARY" != "1" ]; then
  printf 'Refusing held-out primary: set CONFIRM_FROZEN_PRIMARY=1 only after freeze promotion.\n' >&2
  exit 1
fi
if [ ! -d "$ROOT" ]; then
  printf 'Missing Oxford Part 1 root: %s\n' "$ROOT" >&2
  exit 1
fi
if [ ! -d "$CONVERTED_TRAIN_ROOT" ]; then
  printf 'Missing converted training root: %s\n' "$CONVERTED_TRAIN_ROOT" >&2
  exit 1
fi
if [ ! -f "$FEATURE_SCHEMA" ]; then
  printf 'Missing FEATURE_SCHEMA: %s\n' "$FEATURE_SCHEMA" >&2
  exit 1
fi
if [ -e "$CONVERTED_TEST_ROOT" ]; then
  printf 'Refusing to overwrite held-out converted root: %s\n' "$CONVERTED_TEST_ROOT" >&2
  exit 1
fi
if [ -e "$PRIMARY_OUTPUT" ]; then
  printf 'Refusing to overwrite primary output: %s\n' "$PRIMARY_OUTPUT" >&2
  exit 1
fi
if [ -e "$PRIMARY_REPORT" ]; then
  printf 'Refusing to overwrite primary report: %s\n' "$PRIMARY_REPORT" >&2
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

STAGING_ROOT="${CONVERTED_TEST_ROOT}.__staging_$$"
if [ -e "$STAGING_ROOT" ]; then
  printf 'Staging root already exists: %s\n' "$STAGING_ROOT" >&2
  exit 1
fi

mkdir -p "$(dirname "$CONVERTED_TEST_ROOT")"
mkdir -p "$(dirname "$PRIMARY_OUTPUT")"
mkdir -p "$(dirname "$PRIMARY_REPORT")"

matlab_quote() {
  printf "%s" "$1" | sed "s/'/''/g"
}

MATLAB_COMMAND_FILE="$(mktemp "${TMPDIR:-/tmp}/oxford_part1_primary_conversion_XXXXXX.m")"
TMP_PRIMARY_OUTPUT="${PRIMARY_OUTPUT}.__staging_$$.json"
TMP_PRIMARY_REPORT="${PRIMARY_REPORT}.__staging_$$.md"
cleanup() {
  rm -f "$MATLAB_COMMAND_FILE" "$TMP_PRIMARY_OUTPUT" "$TMP_PRIMARY_REPORT"
  if [ "$KEEP_STAGING" != "1" ] && [ -d "$STAGING_ROOT" ]; then
    rm -rf "$STAGING_ROOT"
  fi
}
trap cleanup EXIT

SCRIPT_DIR_MATLAB="$(matlab_quote "$SCRIPT_DIR")"
ROOT_MATLAB="$(matlab_quote "$ROOT")"
STAGING_ROOT_MATLAB="$(matlab_quote "$STAGING_ROOT")"

cat > "$MATLAB_COMMAND_FILE" <<MATLAB
addpath('$SCRIPT_DIR_MATLAB');
export_oxford_part1_training_tables('$ROOT_MATLAB','$STAGING_ROOT_MATLAB','heldout_primary',Inf);
MATLAB

"$MATLAB_BIN" -batch "run('$(matlab_quote "$MATLAB_COMMAND_FILE")')"
mv "$STAGING_ROOT" "$CONVERTED_TEST_ROOT"

"$PYTHON_BIN" analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py \
  --root "$ROOT" \
  --output "$TMP_PRIMARY_OUTPUT" \
  --allow-primary-run \
  --confirm-frozen-primary \
  --converted-train-root "$CONVERTED_TRAIN_ROOT" \
  --converted-test-root "$CONVERTED_TEST_ROOT" \
  --feature-schema "$FEATURE_SCHEMA" \
  --primary-report-output "$TMP_PRIMARY_REPORT"

mv "$TMP_PRIMARY_OUTPUT" "$PRIMARY_OUTPUT"
mv "$TMP_PRIMARY_REPORT" "$PRIMARY_REPORT"
printf 'Wrote primary output: %s\n' "$PRIMARY_OUTPUT"
printf 'Wrote primary report: %s\n' "$PRIMARY_REPORT"
