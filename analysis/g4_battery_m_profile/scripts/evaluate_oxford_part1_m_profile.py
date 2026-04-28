#!/usr/bin/env python3
"""Oxford Path Dependent Part 1 battery M-profile execution scaffold.

Modes:
- --metadata-only: parse file identities, zip entry names, split geometry, and
                   public readme availability only. Does not open MATLAB
                   payloads.
- --train-smoke:   open training-cell MATLAB payloads only to test whether the
                   frozen pipeline can extract features and fit. Does not open
                   held-out payloads and does not emit metrics.
                   If --converted-train-root is supplied, inspect the converted
                   training manifest / CSV headers instead of opening .mat
                   payloads.
- --training-feature-smoke:
                   read converted training tables only, validate frozen
                   endpoint/feature field paths, and fit the model ladder
                   without emitting values or metrics.
- --allow-primary-run:
                   run the one-time held-out primary only when paired with
                   --confirm-frozen-primary, frozen schema, converted training
                   root, and converted held-out root.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import math
import re
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


H_COUNT = 1
TRAIN_CELL_IDS = {4, 8, 10, 14, 15, 18, 19, 20}
TEST_CELL_IDS = {3, 9, 11, 12}
DEFAULT_PRIMARY_RESULT_NOTE = Path(
    "analysis/g4_battery_m_profile/oxford_path_dependent_primary_result_note.md"
)

GROUP_ARCHIVES = ["Group_1.zip", "Group_2.zip", "Group_3.zip", "Group_4.zip"]
REQUIRED_FILES = [
    "Guide_to_Datafiles.pdf",
    "Guide_to_Datafiles.xlsx",
    "Readme.txt",
    "Group_1.zip",
    "Group_2.zip",
    "Group_3.zip",
    "Group_4.zip",
]
OPTIONAL_FILES = ["EIS.zip", "Half_Cell.zip"]

EXPECTED_SHA256 = {
    "Guide_to_Datafiles.pdf": "7431d5a7f94881e19d209452ab44820f9a0ddec0424ae930cbc2f474dead493c",
    "Guide_to_Datafiles.xlsx": "54f8fddb5d71e9c7179ac25d45b751b12f2b413573a7f190a8ffef95135a6aa7",
    "Readme.txt": "59489534eaa5cddd2cef74b057855d2074bbef802d3aa12db6e082f9886dc59c",
    "Group_1.zip": "72425bb5bb4c205161bd6d688219cdb8db54bc069249aedee1bd06ae4d771c1d",
    "Group_2.zip": "4641d6cfc8bc9535c8ec8fe69ed45d02447b2e3420816c0b66785f56687a61a6",
    "Group_3.zip": "f4ee448f0e35ee41ee249382fb3cd6f7c0a2abb1b5774a32146a7c5f5d7e0159",
    "Group_4.zip": "57b2ebeb6775525aa2275905c8e1406c2be8c63f49ba0c5ef28019f18e8cf736",
    "EIS.zip": "64d1fc94dcd3b2403d3f84b88666781a4f6153068e2ef4311d7cde97106a6d27",
    "Half_Cell.zip": "43682be83c416f12e046ba97ee7d45b3b311615e0ef4b93c243e3f3462ec4dcd",
}

ENTRY_RE = re.compile(
    r"^Group\s+(?P<group>\d+)/TPG(?P=group)(?:\.(?P<index>\d+))?\s*-\s*Cell\s*(?P<cell>\d+)\.mat$",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class FileIdentity:
    filename: str
    path: str
    bytes: int
    sha256: str
    sha256_matches_expected: bool
    required: bool
    zip_entries: int | None = None
    zip_mat_entries: int | None = None


@dataclass(frozen=True)
class ParsedEntry:
    archive: str
    entry_name: str
    group: int
    cell: int
    diagnostic_index: int
    file_size: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        required=True,
        help="Directory containing Oxford Path Dependent Part 1 files.",
    )
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument("--metadata-only", action="store_true")
    parser.add_argument("--train-smoke", action="store_true")
    parser.add_argument("--training-feature-smoke", action="store_true")
    parser.add_argument("--allow-primary-run", action="store_true")
    parser.add_argument(
        "--max-train-payloads",
        type=int,
        default=1,
        help="Maximum training-cell MATLAB payloads opened in --train-smoke.",
    )
    parser.add_argument(
        "--converted-train-root",
        default=None,
        help="Optional training-only converted table root containing conversion_manifest.json.",
    )
    parser.add_argument(
        "--converted-test-root",
        default=None,
        help="Optional held-out converted table root for the frozen one-time primary.",
    )
    parser.add_argument(
        "--feature-schema",
        default=None,
        help="JSON schema for training-only endpoint/feature smoke.",
    )
    parser.add_argument(
        "--primary-report-output",
        default=None,
        help="Optional markdown report path for the frozen one-time primary.",
    )
    parser.add_argument(
        "--confirm-frozen-primary",
        action="store_true",
        help="Required with --allow-primary-run to avoid accidental held-out evaluation.",
    )
    parser.add_argument(
        "--primary-result-note",
        default="analysis/g4_battery_m_profile/oxford_path_dependent_primary_result_note.md",
        help="Checked-in result note used as the one-time primary sentinel.",
    )
    parser.add_argument(
        "--allow-primary-rerun",
        action="store_true",
        help="Allow an explicitly labeled rerun after the primary result note exists.",
    )
    parser.add_argument(
        "--allow-partial-converted-smoke",
        action="store_true",
        help="Allow MAX_RECORDS partial converted smoke. Never promotion-eligible.",
    )
    args = parser.parse_args()
    if sum(
        bool(x)
        for x in (
            args.metadata_only,
            args.train_smoke,
            args.training_feature_smoke,
            args.allow_primary_run,
        )
    ) != 1:
        raise SystemExit("Choose exactly one mode.")
    if args.max_train_payloads < 1:
        raise SystemExit("--max-train-payloads must be positive.")
    return args


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def part1_path(root: Path, filename: str) -> Path:
    candidates = [
        root / filename,
        root / "part1" / filename,
        root / "Part1" / filename,
        root / "PART1" / filename,
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise SystemExit(f"Missing required Part 1 file: {filename}")


def file_identity(root: Path, filename: str, required: bool) -> FileIdentity:
    path = part1_path(root, filename)
    digest = sha256_file(path)
    zip_entries = None
    zip_mat_entries = None
    if path.suffix.lower() == ".zip":
        with zipfile.ZipFile(path) as archive:
            names = archive.namelist()
        zip_entries = len(names)
        zip_mat_entries = sum(1 for name in names if name.lower().endswith(".mat"))
    return FileIdentity(
        filename=filename,
        path=str(path),
        bytes=path.stat().st_size,
        sha256=digest,
        sha256_matches_expected=digest == EXPECTED_SHA256[filename],
        required=required,
        zip_entries=zip_entries,
        zip_mat_entries=zip_mat_entries,
    )


def parse_entry_name(archive_name: str, name: str, file_size: int) -> ParsedEntry | None:
    match = ENTRY_RE.match(name)
    if match is None:
        return None
    raw_index = match.group("index")
    return ParsedEntry(
        archive=archive_name,
        entry_name=name,
        group=int(match.group("group")),
        cell=int(match.group("cell")),
        diagnostic_index=0 if raw_index is None else int(raw_index),
        file_size=file_size,
    )


def parse_group_entries(root: Path) -> tuple[list[ParsedEntry], list[str]]:
    entries: list[ParsedEntry] = []
    unmatched: list[str] = []
    for archive_name in GROUP_ARCHIVES:
        archive_path = part1_path(root, archive_name)
        with zipfile.ZipFile(archive_path) as archive:
            for info in archive.infolist():
                if not info.filename.lower().endswith(".mat"):
                    continue
                parsed = parse_entry_name(archive_name, info.filename, info.file_size)
                if parsed is None:
                    unmatched.append(info.filename)
                    continue
                entries.append(parsed)
    return entries, unmatched


def count_candidate_rows(indices: list[int], horizon: int = H_COUNT) -> int:
    available = set(indices)
    return sum(1 for index in sorted(available) if index + horizon in available)


def split_geometry(entries: list[ParsedEntry]) -> dict[str, Any]:
    by_group_cell: dict[tuple[int, int], list[int]] = {}
    for entry in entries:
        by_group_cell.setdefault((entry.group, entry.cell), []).append(entry.diagnostic_index)

    per_cell_h1: dict[int, int] = {}
    per_group_h1: dict[int, int] = {}
    for (group, cell), indices in by_group_cell.items():
        rows = count_candidate_rows(indices)
        per_cell_h1[cell] = per_cell_h1.get(cell, 0) + rows
        per_group_h1[group] = per_group_h1.get(group, 0) + rows

    train_rows = sum(rows for cell, rows in per_cell_h1.items() if cell in TRAIN_CELL_IDS)
    test_rows = sum(rows for cell, rows in per_cell_h1.items() if cell in TEST_CELL_IDS)
    unexpected_cells = sorted(set(per_cell_h1) - TRAIN_CELL_IDS - TEST_CELL_IDS)
    missing_split_cells = sorted((TRAIN_CELL_IDS | TEST_CELL_IDS) - set(per_cell_h1))

    return {
        "h_count": H_COUNT,
        "unit": "filename cell ID",
        "train_cell_ids": sorted(TRAIN_CELL_IDS),
        "test_cell_ids": sorted(TEST_CELL_IDS),
        "unique_cell_ids": len(per_cell_h1),
        "candidate_rows_h1_total": sum(per_cell_h1.values()),
        "candidate_rows_h1_train": train_rows,
        "candidate_rows_h1_test": test_rows,
        "candidate_rows_h1_per_cell": {str(k): v for k, v in sorted(per_cell_h1.items())},
        "candidate_rows_h1_per_group": {str(k): v for k, v in sorted(per_group_h1.items())},
        "unexpected_cells": unexpected_cells,
        "missing_split_cells": missing_split_cells,
        "split_complete": not unexpected_cells and not missing_split_cells,
        "no_leak_rule": "train-smoke may open training cell payloads only; primary may open held-out test payloads only after final freeze.",
    }


def read_readme_availability(root: Path) -> dict[str, Any]:
    readme = part1_path(root, "Readme.txt").read_text(encoding="utf-8", errors="replace")
    lowered = readme.lower()
    keywords = ["time", "current", "voltage", "capacity", "temperature"]
    return {
        "source": str(part1_path(root, "Readme.txt")),
        "contains_keywords": {keyword: keyword in lowered for keyword in keywords},
        "matlab_required_statement_present": "you need matlab" in lowered,
        "reference_test_statement_present": "reference performance tests were conducted every 48 cycles" in lowered,
        "endpoint_status": "capacity public-metadata availability only; exact MATLAB table field unresolved",
    }


def metadata_only(root: Path) -> dict[str, Any]:
    identities = [
        file_identity(root, filename, required=True) for filename in REQUIRED_FILES
    ]
    for filename in OPTIONAL_FILES:
        path_candidates = [root / filename, root / "part1" / filename]
        if any(path.exists() for path in path_candidates):
            identities.append(file_identity(root, filename, required=False))
    entries, unmatched = parse_group_entries(root)
    return {
        "status": "metadata_only_passed",
        "mode": "metadata_only",
        "matlab_payload_opened": False,
        "heldout_payload_opened": False,
        "file_identities": [asdict(identity) for identity in identities],
        "sha256_all_required_match": all(
            identity.sha256_matches_expected for identity in identities if identity.required
        ),
        "unmatched_entries": unmatched,
        "split_geometry": split_geometry(entries),
        "public_readme_availability": read_readme_availability(root),
        "primary_blocked": True,
        "primary_blocked_reason": "held-out primary requires the frozen one-time command and --confirm-frozen-primary.",
        "non_claims": [
            "no MATLAB payload values opened",
            "no endpoint values emitted",
            "no features computed",
            "no model fit attempted",
            "no metrics emitted",
            "no support flags emitted",
        ],
    }


def first_training_payload(root: Path, entries: list[ParsedEntry]) -> tuple[ParsedEntry, bytes]:
    train_entries = sorted(
        [entry for entry in entries if entry.cell in TRAIN_CELL_IDS],
        key=lambda entry: (entry.cell, entry.group, entry.diagnostic_index, entry.entry_name),
    )
    if not train_entries:
        raise SystemExit("No training entries found.")
    entry = train_entries[0]
    with zipfile.ZipFile(part1_path(root, entry.archive)) as archive:
        payload = archive.read(entry.entry_name)
    return entry, payload


def train_smoke(root: Path, max_train_payloads: int) -> dict[str, Any]:
    try:
        from scipy.io import loadmat
    except ImportError as exc:
        raise SystemExit("scipy is required for --train-smoke.") from exc

    entries, unmatched = parse_group_entries(root)
    geometry = split_geometry(entries)
    opened_payloads: list[dict[str, Any]] = []
    blocked_reason = None

    train_entries = sorted(
        [entry for entry in entries if entry.cell in TRAIN_CELL_IDS],
        key=lambda entry: (entry.cell, entry.group, entry.diagnostic_index, entry.entry_name),
    )[:max_train_payloads]

    for entry in train_entries:
        with zipfile.ZipFile(part1_path(root, entry.archive)) as archive:
            payload = archive.read(entry.entry_name)
        loaded = loadmat(io.BytesIO(payload), squeeze_me=False, struct_as_record=False)
        public_keys = sorted(key for key in loaded if not key.startswith("__"))
        key_types = {key: type(loaded[key]).__name__ for key in public_keys}
        key_shapes = {key: tuple(getattr(loaded[key], "shape", ())) for key in public_keys}
        opened_payloads.append(
            {
                "archive": entry.archive,
                "entry_name": entry.entry_name,
                "cell": entry.cell,
                "group": entry.group,
                "diagnostic_index": entry.diagnostic_index,
                "public_keys": public_keys,
                "key_types": key_types,
                "key_shapes": key_shapes,
            }
        )
        if public_keys == ["None"] and key_types.get("None") == "MatlabOpaque":
            blocked_reason = (
                "Training payload is a MATLAB MCOS table exposed by scipy as MatlabOpaque; "
                "concrete endpoint/features require a MATLAB-side or MCOS-aware conversion step."
            )
            break

    return {
        "status": "train_smoke_blocked_mcos_table" if blocked_reason else "train_smoke_payload_schema_checked",
        "mode": "train_smoke",
        "matlab_payload_opened": True,
        "opened_training_payload_count": len(opened_payloads),
        "heldout_payload_opened": False,
        "heldout_cell_ids": sorted(TEST_CELL_IDS),
        "unmatched_entries": unmatched,
        "split_geometry": geometry,
        "opened_training_payload_schemas": opened_payloads,
        "blocked_reason": blocked_reason,
        "model_fit_attempted": False,
        "metrics_emitted": False,
        "primary_blocked": True,
        "next_required_step": "Run the no-peek MATLAB/MCOS-aware training conversion runner, then rerun train-smoke via --converted-train-root.",
        "non_claims": [
            "no held-out payload values opened",
            "no endpoint values emitted",
            "no features emitted",
            "no preprocessing statistics emitted",
            "no predictions emitted",
            "no metrics emitted",
            "no support flags emitted",
        ],
    }


def validate_converted_training_manifest(
    converted_root: Path,
    *,
    allow_partial: bool = False,
    hash_csv_contents: bool = True,
    expected_training_entries: list[ParsedEntry] | None = None,
    split: str = "train",
) -> dict[str, Any]:
    manifest_path = converted_root / "conversion_manifest.json"
    if split not in {"train", "heldout"}:
        raise SystemExit(f"Unsupported converted manifest split: {split}")
    split_label = "training" if split == "train" else "held-out"
    if not manifest_path.exists():
        raise SystemExit(f"Missing converted {split_label} manifest: {manifest_path}")

    converted_root_resolved = converted_root.resolve()

    with manifest_path.open("r", encoding="utf-8") as handle:
        manifest = json.load(handle)

    if split == "train":
        expected_cell_ids = TRAIN_CELL_IDS
        forbidden_cell_ids = TEST_CELL_IDS
        expected_status = "train_smoke_conversion_manifest"
        expected_mode = "train_smoke"
        expected_heldout_payload_exported = False
    else:
        expected_cell_ids = TEST_CELL_IDS
        forbidden_cell_ids = TRAIN_CELL_IDS
        expected_status = "heldout_primary_conversion_manifest"
        expected_mode = "heldout_primary"
        expected_heldout_payload_exported = True

    expected_guardrails = {
        "status": expected_status,
        "mode": expected_mode,
        "heldout_payload_exported": expected_heldout_payload_exported,
        "metrics_computed": False,
        "support_flags_emitted": False,
    }
    for key, expected in expected_guardrails.items():
        if manifest.get(key) != expected:
            raise SystemExit(
                f"Converted manifest guardrail mismatch for {key}: "
                f"expected {expected!r}, got {manifest.get(key)!r}"
            )

    if sorted(int(cell) for cell in manifest.get("train_cell_ids", [])) != sorted(TRAIN_CELL_IDS):
        raise SystemExit("Converted manifest train_cell_ids do not match the frozen split.")
    if sorted(int(cell) for cell in manifest.get("heldout_cell_ids", [])) != sorted(TEST_CELL_IDS):
        raise SystemExit("Converted manifest heldout_cell_ids do not match the frozen split.")
    truncated_by_max_records = bool(manifest.get("truncated_by_max_records", False))
    if truncated_by_max_records and not allow_partial:
        raise SystemExit("Converted manifest is truncated by max_records but partial smoke is not allowed.")

    records = manifest.get("records", [])
    if isinstance(records, dict):
        records = [records]
    if not isinstance(records, list):
        raise SystemExit("conversion_manifest.json must contain a records list.")
    if int(manifest.get("record_count", -1)) != len(records):
        raise SystemExit("conversion_manifest.json record_count does not match records length.")
    if not records:
        raise SystemExit("conversion_manifest.json contains no converted records.")

    checked_records: list[dict[str, Any]] = []
    exported_cells: set[int] = set()
    column_name_union: set[str] = set()
    total_rows = 0
    manifest_entry_keys: list[tuple[str, str, int, int, int]] = []
    referenced_csvs: set[Path] = set()
    referenced_csv_list: list[Path] = []

    for record in records:
        parsed_entry = parse_entry_name(
            str(record.get("archive", "")),
            str(record.get("entry_name", "")),
            file_size=0,
        )
        if parsed_entry is None:
            raise SystemExit(f"Converted manifest has unparsable entry_name: {record.get('entry_name')}")

        cell_id = int(record["cell_id"])
        group_id = int(record["group_id"])
        diagnostic_index = int(record["diagnostic_index"])
        if parsed_entry.group != group_id:
            raise SystemExit(f"Converted manifest group_id does not match entry_name for {record['entry_name']}")
        if parsed_entry.cell != cell_id:
            raise SystemExit(f"Converted manifest cell_id does not match entry_name for {record['entry_name']}")
        if parsed_entry.diagnostic_index != diagnostic_index:
            raise SystemExit(
                f"Converted manifest diagnostic_index does not match entry_name for {record['entry_name']}"
            )
        if cell_id in forbidden_cell_ids:
            forbidden_label = "held-out" if split == "train" else "training"
            raise SystemExit(
                f"Converted {split_label} manifest contains forbidden {forbidden_label} cell ID: {cell_id}"
            )
        if cell_id not in expected_cell_ids:
            raise SystemExit(
                f"Converted {split_label} manifest contains unexpected cell ID: {cell_id}"
            )

        output_csv_raw = Path(record["output_csv"])
        csv_candidates = [output_csv_raw]
        if not output_csv_raw.is_absolute():
            csv_candidates.extend(
                [
                    converted_root / output_csv_raw,
                    converted_root / "tables" / output_csv_raw.name,
                ]
            )
        output_csv = next((candidate for candidate in csv_candidates if candidate.exists()), None)
        if output_csv is None:
            raise SystemExit(f"Converted CSV missing: {record['output_csv']}")
        output_csv_resolved = output_csv.resolve()
        try:
            output_csv_resolved.relative_to(converted_root_resolved)
        except ValueError as exc:
            raise SystemExit(
                f"Converted CSV path escapes converted root: {output_csv_resolved}"
            ) from exc

        column_names = list(record.get("column_names", []))
        row_count = int(record.get("row_count", -1))
        if row_count < 0:
            raise SystemExit(f"Invalid row_count in converted manifest for {output_csv}")
        manifest_entry_keys.append(
            (
                str(record.get("archive", "")),
                str(record.get("entry_name", "")),
                group_id,
                cell_id,
                diagnostic_index,
            )
        )
        referenced_csvs.add(output_csv_resolved)
        referenced_csv_list.append(output_csv_resolved)

        # Header-only read: this verifies parseability without inspecting values.
        try:
            import pandas as pd
        except ImportError as exc:
            raise SystemExit("pandas is required to inspect converted CSV headers.") from exc
        header = list(pd.read_csv(output_csv, nrows=0).columns)
        if column_names and header != column_names:
            raise SystemExit(f"Converted CSV header mismatch for {output_csv}")

        expected_digest = record.get("output_sha256")
        digest = None
        if hash_csv_contents:
            digest = sha256_file(output_csv_resolved)
            if expected_digest and digest != expected_digest:
                raise SystemExit(f"Converted CSV sha256 mismatch for {output_csv}")

        exported_cells.add(cell_id)
        total_rows += row_count
        column_name_union.update(header)
        checked_record = {
            "cell_id": cell_id,
            "group_id": group_id,
            "diagnostic_index": diagnostic_index,
            "source_archive": record.get("archive"),
            "source_entry": record.get("entry_name"),
            "output_csv": str(record.get("output_csv")),
            "row_count": row_count,
            "column_count": len(header),
            "output_sha256_checked": hash_csv_contents,
        }
        if hash_csv_contents:
            checked_record["output_sha256"] = digest
        else:
            checked_record["output_sha256_manifest"] = expected_digest
        checked_records.append(checked_record)

    missing_cell_ids = sorted(expected_cell_ids - exported_cells)
    if missing_cell_ids and not allow_partial:
        raise SystemExit(
            f"Converted manifest is missing {split_label} cell IDs: {missing_cell_ids}"
        )

    expected_entry_count = None
    if expected_training_entries is not None and not allow_partial:
        duplicate_manifest_entries = sorted(
            {key for key in manifest_entry_keys if manifest_entry_keys.count(key) > 1}
        )
        if duplicate_manifest_entries:
            raise SystemExit(
                f"Converted manifest contains duplicate {split_label} entries: "
                f"{duplicate_manifest_entries[:5]}"
            )
        expected_keys = {
            (
                entry.archive,
                entry.entry_name,
                entry.group,
                entry.cell,
                entry.diagnostic_index,
            )
            for entry in expected_training_entries
            if entry.cell in expected_cell_ids
        }
        manifest_entry_key_set = set(manifest_entry_keys)
        expected_entry_count = len(expected_keys)
        if len(manifest_entry_keys) != expected_entry_count:
            raise SystemExit(
                f"Converted manifest record count does not match expected {split_label} "
                f"entry count: got {len(manifest_entry_keys)}, expected {expected_entry_count}"
            )
        missing_entries = sorted(expected_keys - manifest_entry_key_set)
        unexpected_entries = sorted(manifest_entry_key_set - expected_keys)
        if missing_entries:
            raise SystemExit(
                f"Converted manifest is missing expected {split_label} entries: "
                f"{missing_entries[:5]}"
            )
        if unexpected_entries:
            raise SystemExit(
                f"Converted manifest contains unexpected {split_label} entries: "
                f"{unexpected_entries[:5]}"
            )

    actual_csvs = {path.resolve() for path in converted_root_resolved.rglob("*.csv")}
    duplicate_referenced_csvs = sorted(
        {path for path in referenced_csv_list if referenced_csv_list.count(path) > 1}
    )
    if duplicate_referenced_csvs:
        relative_duplicates = [
            str(path.relative_to(converted_root_resolved)) for path in duplicate_referenced_csvs[:5]
        ]
        raise SystemExit(
            "Converted manifest references duplicate CSV files: "
            f"{relative_duplicates}"
        )
    unreferenced_csvs = sorted(actual_csvs - referenced_csvs)
    if unreferenced_csvs:
        relative_unreferenced = [
            str(path.relative_to(converted_root_resolved)) for path in unreferenced_csvs[:5]
        ]
        raise SystemExit(
            "Converted root contains unreferenced CSV files: "
            f"{relative_unreferenced}"
        )

    summary = {
        "converted_root": str(converted_root),
        "manifest_path": str(manifest_path),
        "manifest_guardrails_checked": True,
        "split": split,
        "converted_csv_read_scope": (
            "headers_and_sha256_file_bytes" if hash_csv_contents else "headers_only"
        ),
        "converted_csv_content_sha256_checked": hash_csv_contents,
        "partial_runtime_sanity": allow_partial,
        "truncated_by_max_records": truncated_by_max_records,
        "promotion_eligible_converted_smoke": not allow_partial and not truncated_by_max_records,
        "record_count": len(checked_records),
        "expected_cell_ids": sorted(expected_cell_ids),
        "exported_cell_ids": sorted(exported_cells),
        "missing_cell_ids": missing_cell_ids,
        "heldout_cell_ids": sorted(TEST_CELL_IDS),
        "heldout_payload_present_in_manifest_records": split == "heldout",
        "training_payload_present_in_manifest_records": split == "train",
        "manifest_record_count_matches_records": True,
        "expected_training_entry_set_checked": expected_training_entries is not None
        and not allow_partial,
        "expected_training_entry_count": expected_entry_count,
        "expected_entry_count": expected_entry_count,
        "exclusive_csv_set_checked": True,
        "unreferenced_csv_count": 0,
        "total_rows_in_converted_tables": total_rows,
        "column_name_union": sorted(column_name_union),
        "checked_records": checked_records,
    }
    if split == "train":
        summary.update(
            {
                "expected_training_cell_ids": sorted(TRAIN_CELL_IDS),
                "exported_training_cell_ids": sorted(exported_cells),
                "missing_training_cell_ids": missing_cell_ids,
                "total_training_rows_in_converted_tables": total_rows,
            }
        )
    else:
        summary.update(
            {
                "expected_heldout_cell_ids": sorted(TEST_CELL_IDS),
                "exported_heldout_cell_ids": sorted(exported_cells),
                "missing_heldout_cell_ids": missing_cell_ids,
                "total_heldout_rows_in_converted_tables": total_rows,
            }
        )
    return summary


def converted_train_smoke(
    root: Path,
    converted_train_root: Path,
    *,
    allow_partial: bool = False,
) -> dict[str, Any]:
    entries, unmatched = parse_group_entries(root)
    geometry = split_geometry(entries)
    converted_summary = validate_converted_training_manifest(
        converted_train_root,
        allow_partial=allow_partial,
        expected_training_entries=entries,
    )
    return {
        "status": (
            "converted_train_smoke_partial_runtime_sanity_checked"
            if allow_partial
            else "converted_train_smoke_manifest_checked"
        ),
        "mode": "train_smoke_converted",
        "matlab_payload_opened": False,
        "converted_training_tables_read": "headers_and_sha256_file_bytes",
        "heldout_payload_opened": False,
        "unmatched_entries": unmatched,
        "split_geometry": geometry,
        "converted_training_manifest": converted_summary,
        "model_fit_attempted": False,
        "metrics_emitted": False,
        "support_flags_emitted": False,
        "primary_blocked": True,
        "promotion_eligible": not allow_partial,
        "next_required_step": "Add frozen endpoint/feature extraction from converted training tables, then rerun train-smoke before freezing primary.",
        "non_claims": [
            "no held-out payload values opened",
            "no endpoint values emitted",
            "no features emitted",
            "no preprocessing statistics emitted",
            "no predictions emitted",
            "no metrics emitted",
            "no support flags emitted",
        ],
    }


def require_string_list(value: Any, *, field: str) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise SystemExit(f"{field} must be a list of strings.")
    return value


def load_feature_schema(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        schema = json.load(handle)
    if schema.get("status") != "training_feature_smoke_schema_frozen":
        raise SystemExit("feature schema status must be training_feature_smoke_schema_frozen.")
    if schema.get("mode") != "training_feature_smoke":
        raise SystemExit("feature schema mode must be training_feature_smoke.")
    if schema.get("human_finalized") is not True:
        raise SystemExit("feature schema must set human_finalized=true.")
    if sorted(int(cell) for cell in schema.get("train_cell_ids", [])) != sorted(TRAIN_CELL_IDS):
        raise SystemExit("feature schema train_cell_ids do not match the frozen split.")
    if sorted(int(cell) for cell in schema.get("heldout_cell_ids", [])) != sorted(TEST_CELL_IDS):
        raise SystemExit("feature schema heldout_cell_ids do not match the frozen split.")
    feature_extraction = schema.get("feature_extraction", "direct_table_columns_v1")
    if feature_extraction not in {"direct_table_columns_v1", "transition_aggregate_v1"}:
        raise SystemExit("feature schema feature_extraction is unsupported.")

    endpoint_column = schema.get("endpoint_column")
    if not isinstance(endpoint_column, str) or not endpoint_column:
        raise SystemExit("feature schema endpoint_column must be a non-empty string.")

    model_features = schema.get("model_features")
    if not isinstance(model_features, dict):
        raise SystemExit("feature schema model_features must be an object.")
    required_models = ["B1", "B2", "B3", "primary"]
    for model_name in required_models:
        feature_columns = require_string_list(
            model_features.get(model_name),
            field=f"model_features.{model_name}",
        )
        if len(feature_columns) != len(set(feature_columns)):
            raise SystemExit(f"feature schema model_features.{model_name} contains duplicate columns.")
        if endpoint_column in feature_columns:
            raise SystemExit(
                f"feature schema model_features.{model_name} must not include endpoint_column."
            )

    return schema


def numeric_series(table: Any, column: str) -> Any:
    import pandas as pd

    if column not in table.columns:
        return pd.Series(dtype="float64")
    return pd.to_numeric(table[column], errors="coerce")


def summarize_training_table(table: Any, record: dict[str, Any]) -> dict[str, Any]:
    import math

    amphr = numeric_series(table, "Amphr")
    watthr = numeric_series(table, "Watthr")
    amps = numeric_series(table, "Amps")
    volts = numeric_series(table, "Volts")
    temp = numeric_series(table, "Temp1")
    test_time = numeric_series(table, "TestTime")

    def finite_or_none(value: Any) -> float | None:
        if value is None:
            return None
        value = float(value)
        return value if math.isfinite(value) else None

    voltage_min = finite_or_none(volts.min(skipna=True)) if not volts.empty else None
    voltage_tail_mean = (
        finite_or_none(volts.tail(max(1, int(len(volts) * 0.01))).mean(skipna=True))
        if not volts.empty
        else None
    )
    capacity_ah = finite_or_none(amphr.max(skipna=True)) if not amphr.empty else None
    energy_wh = finite_or_none(watthr.max(skipna=True)) if not watthr.empty else None
    abs_current = amps.abs() if not amps.empty else amps

    voltage_recovery_proxy = None
    if voltage_min is not None and voltage_tail_mean is not None:
        voltage_recovery_proxy = voltage_tail_mean - voltage_min

    return {
        "_sp_group_id": int(record["group_id"]),
        "_sp_cell_id": int(record["cell_id"]),
        "_sp_diagnostic_index": int(record["diagnostic_index"]),
        "capacity_ah_current": capacity_ah,
        "energy_wh_current": energy_wh,
        "duration_s_current": finite_or_none(test_time.max(skipna=True)) if not test_time.empty else None,
        "abs_current_mean": finite_or_none(abs_current.mean(skipna=True)) if not abs_current.empty else None,
        "abs_current_max": finite_or_none(abs_current.max(skipna=True)) if not abs_current.empty else None,
        "voltage_mean": finite_or_none(volts.mean(skipna=True)) if not volts.empty else None,
        "voltage_min": voltage_min,
        "voltage_max": finite_or_none(volts.max(skipna=True)) if not volts.empty else None,
        "temperature_mean": finite_or_none(temp.mean(skipna=True)) if not temp.empty else None,
        "temperature_max": finite_or_none(temp.max(skipna=True)) if not temp.empty else None,
        "m_buffer_capacity_ah": capacity_ah,
        "m_buffer_voltage_min": voltage_min,
        "m_recovery_voltage_tail_minus_min": voltage_recovery_proxy,
    }


def build_transition_aggregate_frame(
    converted_train_root: Path,
    converted_summary: dict[str, Any],
) -> Any:
    import pandas as pd

    summaries: dict[tuple[int, int, int], dict[str, Any]] = {}
    for record in converted_summary["checked_records"]:
        output_csv = converted_train_root / str(record["output_csv"])
        table = pd.read_csv(
            output_csv,
            usecols=lambda column: column
            in {"Amphr", "Watthr", "Amps", "Volts", "Temp1", "TestTime"},
        )
        key = (
            int(record["group_id"]),
            int(record["cell_id"]),
            int(record["diagnostic_index"]),
        )
        summaries[key] = summarize_training_table(table, record)

    rows: list[dict[str, Any]] = []
    for key, summary in sorted(summaries.items()):
        group_id, cell_id, diagnostic_index = key
        next_key = (group_id, cell_id, diagnostic_index + H_COUNT)
        next_summary = summaries.get(next_key)
        if next_summary is None:
            continue
        row = dict(summary)
        row["next_capacity_ah"] = next_summary["capacity_ah_current"]
        rows.append(row)
    if not rows:
        raise SystemExit("No training transition rows available for feature smoke.")
    return pd.DataFrame(rows)


def training_feature_smoke(
    root: Path,
    converted_train_root: Path,
    feature_schema_path: Path,
) -> dict[str, Any]:
    try:
        import pandas as pd
        from sklearn.compose import ColumnTransformer
        from sklearn.linear_model import Ridge
        from sklearn.pipeline import Pipeline
        from sklearn.preprocessing import OneHotEncoder, StandardScaler
    except ImportError as exc:
        raise SystemExit(
            "pandas and scikit-learn are required for --training-feature-smoke."
        ) from exc

    entries, unmatched = parse_group_entries(root)
    geometry = split_geometry(entries)
    converted_summary = validate_converted_training_manifest(
        converted_train_root,
        allow_partial=False,
        expected_training_entries=entries,
    )
    schema = load_feature_schema(feature_schema_path)

    endpoint_column = str(schema["endpoint_column"])
    feature_extraction = str(schema.get("feature_extraction", "direct_table_columns_v1"))
    model_features: dict[str, list[str]] = {
        name: list(columns)
        for name, columns in schema["model_features"].items()
    }

    if feature_extraction == "transition_aggregate_v1":
        training_frame = build_transition_aggregate_frame(converted_train_root, converted_summary)
    else:
        required_columns = {endpoint_column}
        for columns in model_features.values():
            required_columns.update(columns)

        frame_parts: list[Any] = []
        for record in converted_summary["checked_records"]:
            output_csv = converted_train_root / str(record["output_csv"])
            table = pd.read_csv(output_csv)
            table["_sp_group_id"] = int(record["group_id"])
            table["_sp_cell_id"] = int(record["cell_id"])
            table["_sp_diagnostic_index"] = int(record["diagnostic_index"])
            missing_columns = sorted(required_columns - set(table.columns))
            if missing_columns:
                raise SystemExit(f"Converted table missing required schema columns: {missing_columns}")
            table = table[list(required_columns)].copy()
            frame_parts.append(table)

        if not frame_parts:
            raise SystemExit("No converted training tables available for feature smoke.")
        training_frame = pd.concat(frame_parts, ignore_index=True)

    required_frame_columns = {endpoint_column}
    for columns in model_features.values():
        required_frame_columns.update(columns)
    missing_frame_columns = sorted(required_frame_columns - set(training_frame.columns))
    if missing_frame_columns:
        raise SystemExit(f"Training feature frame missing required schema columns: {missing_frame_columns}")
    training_frame = training_frame.dropna(subset=[endpoint_column])
    if training_frame.empty:
        raise SystemExit("No non-null training endpoint rows available for feature smoke.")

    fit_results: dict[str, Any] = {}
    for model_name in ["B0", "B1", "B2", "B3", "primary"]:
        if model_name == "B0":
            fit_results[model_name] = {
                "fit_success": True,
                "feature_count": 0,
                "row_count": int(len(training_frame)),
                "emits_metric": False,
            }
            continue

        feature_columns = model_features[model_name]
        model_frame = training_frame.dropna(subset=feature_columns + [endpoint_column])
        if model_frame.empty:
            raise SystemExit(f"No non-null rows available for model {model_name}.")
        x = model_frame[feature_columns]
        y = model_frame[endpoint_column]
        numeric_columns = [
            column for column in feature_columns if pd.api.types.is_numeric_dtype(x[column])
        ]
        categorical_columns = [
            column for column in feature_columns if column not in numeric_columns
        ]
        transformers = []
        if numeric_columns:
            transformers.append(("numeric", StandardScaler(), numeric_columns))
        if categorical_columns:
            transformers.append(
                (
                    "categorical",
                    OneHotEncoder(handle_unknown="ignore"),
                    categorical_columns,
                )
            )
        if not transformers:
            raise SystemExit(f"Model {model_name} has no usable feature columns.")
        pipeline = Pipeline(
            [
                ("preprocess", ColumnTransformer(transformers=transformers)),
                ("model", Ridge(alpha=1.0, fit_intercept=True)),
            ]
        )
        pipeline.fit(x, y)
        transformed = pipeline.named_steps["preprocess"].transform(x)
        fit_results[model_name] = {
            "fit_success": True,
            "row_count": int(len(model_frame)),
            "input_feature_count": len(feature_columns),
            "transformed_feature_count": int(transformed.shape[1]),
            "numeric_feature_count": len(numeric_columns),
            "categorical_feature_count": len(categorical_columns),
            "emits_metric": False,
        }

    return {
        "status": "training_feature_smoke_passed",
        "mode": "training_feature_smoke",
        "matlab_payload_opened": False,
        "heldout_payload_opened": False,
        "converted_training_tables_read": "training_values_only",
        "feature_extraction": feature_extraction,
        "endpoint_field_path": endpoint_column,
        "model_feature_columns": model_features,
        "fit_results": fit_results,
        "converted_training_manifest": {
            "manifest_guardrails_checked": converted_summary["manifest_guardrails_checked"],
            "record_count": converted_summary["record_count"],
            "exported_training_cell_ids": converted_summary["exported_training_cell_ids"],
            "missing_training_cell_ids": converted_summary["missing_training_cell_ids"],
            "promotion_eligible_converted_smoke": converted_summary[
                "promotion_eligible_converted_smoke"
            ],
        },
        "split_geometry": geometry,
        "unmatched_entries": unmatched,
        "primary_blocked": True,
        "metrics_emitted": False,
        "support_flags_emitted": False,
        "training_feature_smoke_gate_passed": True,
        "promotion_eligible_for_freeze_manifest": False,
        "next_required_step": "Review this smoke output, then run the frozen one-time primary command only after accepting the freeze manifest.",
        "non_claims": [
            "no held-out payload values opened",
            "no endpoint values emitted",
            "no feature values emitted",
            "no preprocessing statistics emitted",
            "no coefficients emitted",
            "no predictions emitted",
            "no metrics emitted",
            "no support flags emitted",
        ],
    }


def build_direct_feature_frame(converted_root: Path, converted_summary: dict[str, Any], schema: dict[str, Any]) -> Any:
    import pandas as pd

    endpoint_column = str(schema["endpoint_column"])
    required_columns = {endpoint_column}
    for columns in schema["model_features"].values():
        required_columns.update(columns)

    frame_parts: list[Any] = []
    for record in converted_summary["checked_records"]:
        output_csv = converted_root / str(record["output_csv"])
        table = pd.read_csv(output_csv)
        table["_sp_group_id"] = int(record["group_id"])
        table["_sp_cell_id"] = int(record["cell_id"])
        table["_sp_diagnostic_index"] = int(record["diagnostic_index"])
        missing_columns = sorted(required_columns - set(table.columns))
        if missing_columns:
            raise SystemExit(f"Converted table missing required schema columns: {missing_columns}")
        frame_parts.append(table[list(required_columns)].copy())
    if not frame_parts:
        raise SystemExit("No converted tables available for primary.")
    return pd.concat(frame_parts, ignore_index=True)


def fit_and_score_model(
    train_frame: Any,
    test_frame: Any,
    endpoint_column: str,
    feature_columns: list[str],
) -> dict[str, Any]:
    import numpy as np
    import pandas as pd
    from sklearn.compose import ColumnTransformer
    from sklearn.dummy import DummyRegressor
    from sklearn.linear_model import Ridge
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import OneHotEncoder, StandardScaler

    if not feature_columns:
        train_model_frame = train_frame.dropna(subset=[endpoint_column])
        test_model_frame = test_frame.dropna(subset=[endpoint_column])
        if train_model_frame.empty or test_model_frame.empty:
            raise SystemExit("No non-null rows available for B0 primary evaluation.")
        model = DummyRegressor(strategy="mean")
        model.fit(train_model_frame[[endpoint_column]], train_model_frame[endpoint_column])
        predictions = model.predict(test_model_frame[[endpoint_column]])
        y_true = test_model_frame[endpoint_column].to_numpy(dtype=float)
        transformed_feature_count = 0
        numeric_feature_count = 0
        categorical_feature_count = 0
    else:
        train_model_frame = train_frame.dropna(subset=feature_columns + [endpoint_column])
        test_model_frame = test_frame.dropna(subset=feature_columns + [endpoint_column])
        if train_model_frame.empty or test_model_frame.empty:
            raise SystemExit("No non-null rows available for primary model evaluation.")
        x_train = train_model_frame[feature_columns]
        y_train = train_model_frame[endpoint_column]
        x_test = test_model_frame[feature_columns]
        y_true = test_model_frame[endpoint_column].to_numpy(dtype=float)
        numeric_columns = [
            column for column in feature_columns if pd.api.types.is_numeric_dtype(x_train[column])
        ]
        categorical_columns = [
            column for column in feature_columns if column not in numeric_columns
        ]
        transformers = []
        if numeric_columns:
            transformers.append(("numeric", StandardScaler(), numeric_columns))
        if categorical_columns:
            transformers.append(
                (
                    "categorical",
                    OneHotEncoder(handle_unknown="ignore"),
                    categorical_columns,
                )
            )
        if not transformers:
            raise SystemExit("Primary model has no usable feature columns.")
        model = Pipeline(
            [
                ("preprocess", ColumnTransformer(transformers=transformers)),
                ("model", Ridge(alpha=1.0, fit_intercept=True)),
            ]
        )
        model.fit(x_train, y_train)
        predictions = model.predict(x_test)
        transformed = model.named_steps["preprocess"].transform(x_train)
        transformed_feature_count = int(transformed.shape[1])
        numeric_feature_count = len(numeric_columns)
        categorical_feature_count = len(categorical_columns)

    residual = y_true - np.asarray(predictions, dtype=float)
    rmse = float(math.sqrt(float(np.mean(residual ** 2))))
    mae = float(np.mean(np.abs(residual)))
    return {
        "train_row_count": int(len(train_model_frame)),
        "test_row_count": int(len(test_model_frame)),
        "input_feature_count": len(feature_columns),
        "transformed_feature_count": transformed_feature_count,
        "numeric_feature_count": numeric_feature_count,
        "categorical_feature_count": categorical_feature_count,
        "rmse": rmse,
        "mae": mae,
    }


def primary_run(
    root: Path,
    converted_train_root: Path,
    converted_test_root: Path,
    feature_schema_path: Path,
    primary_report_output: Path | None,
) -> dict[str, Any]:
    try:
        import pandas as pd
    except ImportError as exc:
        raise SystemExit("pandas and scikit-learn are required for --allow-primary-run.") from exc

    entries, unmatched = parse_group_entries(root)
    geometry = split_geometry(entries)
    train_summary = validate_converted_training_manifest(
        converted_train_root,
        allow_partial=False,
        expected_training_entries=entries,
        split="train",
    )
    heldout_summary = validate_converted_training_manifest(
        converted_test_root,
        allow_partial=False,
        expected_training_entries=entries,
        split="heldout",
    )
    schema = load_feature_schema(feature_schema_path)

    endpoint_column = str(schema["endpoint_column"])
    feature_extraction = str(schema.get("feature_extraction", "direct_table_columns_v1"))
    model_features: dict[str, list[str]] = {
        name: list(columns)
        for name, columns in schema["model_features"].items()
    }

    if feature_extraction == "transition_aggregate_v1":
        train_frame = build_transition_aggregate_frame(converted_train_root, train_summary)
        test_frame = build_transition_aggregate_frame(converted_test_root, heldout_summary)
    else:
        train_frame = build_direct_feature_frame(converted_train_root, train_summary, schema)
        test_frame = build_direct_feature_frame(converted_test_root, heldout_summary, schema)

    required_frame_columns = {endpoint_column}
    for columns in model_features.values():
        required_frame_columns.update(columns)
    missing_train_columns = sorted(required_frame_columns - set(train_frame.columns))
    missing_test_columns = sorted(required_frame_columns - set(test_frame.columns))
    if missing_train_columns:
        raise SystemExit(f"Training primary frame missing required columns: {missing_train_columns}")
    if missing_test_columns:
        raise SystemExit(f"Held-out primary frame missing required columns: {missing_test_columns}")

    results: dict[str, Any] = {}
    results["B0"] = fit_and_score_model(train_frame, test_frame, endpoint_column, [])
    for model_name in ["B1", "B2", "B3", "primary"]:
        results[model_name] = fit_and_score_model(
            train_frame,
            test_frame,
            endpoint_column,
            model_features[model_name],
        )

    b3_rmse = float(results["B3"]["rmse"])
    primary_rmse = float(results["primary"]["rmse"])
    support_flags = {
        "H1_strong_incremental_support": primary_rmse <= 0.95 * b3_rmse,
        "H2_weak_incremental_support": primary_rmse < b3_rmse,
        "H3_no_support": primary_rmse >= b3_rmse,
        "primary_support": primary_rmse < b3_rmse,
        "strong_threshold_rmse": 0.95 * b3_rmse,
    }

    cell_summary: dict[str, Any] = {}
    if "_sp_cell_id" in test_frame.columns:
        cell_summary = {
            str(cell_id): int(len(group.dropna(subset=[endpoint_column])))
            for cell_id, group in test_frame.groupby("_sp_cell_id")
        }

    payload = {
        "status": "primary_run_completed",
        "mode": "allow_primary_run",
        "matlab_payload_opened_by_python": False,
        "heldout_payload_opened": True,
        "converted_training_tables_read": "training_values_for_primary_fit",
        "converted_heldout_tables_read": "heldout_values_for_one_time_primary",
        "feature_extraction": feature_extraction,
        "endpoint_field_path": endpoint_column,
        "model_feature_columns": model_features,
        "feature_schema_path": str(feature_schema_path),
        "feature_schema_sha256": sha256_file(feature_schema_path),
        "train_transition_rows": int(len(train_frame.dropna(subset=[endpoint_column]))),
        "heldout_transition_rows": int(len(test_frame.dropna(subset=[endpoint_column]))),
        "heldout_rows_by_cell": cell_summary,
        "metrics": results,
        "support_flags": support_flags,
        "decision_rule": {
            "H1": "RMSE(primary) <= 0.95 * RMSE(B3)",
            "H2": "RMSE(primary) < RMSE(B3)",
            "H3": "RMSE(primary) >= RMSE(B3)",
        },
        "split_geometry": geometry,
        "unmatched_entries": unmatched,
        "converted_training_manifest": {
            "manifest_guardrails_checked": train_summary["manifest_guardrails_checked"],
            "record_count": train_summary["record_count"],
            "exported_training_cell_ids": train_summary["exported_training_cell_ids"],
        },
        "converted_heldout_manifest": {
            "manifest_guardrails_checked": heldout_summary["manifest_guardrails_checked"],
            "record_count": heldout_summary["record_count"],
            "exported_heldout_cell_ids": heldout_summary["exported_heldout_cell_ids"],
        },
        "metrics_emitted": True,
        "support_flags_emitted": True,
        "non_claims": [
            "no causal intervention ranking",
            "no literal repair-flow claim",
            "no universal-law claim",
            "no same-archive rescue if primary loses to B3",
        ],
    }
    if primary_report_output is not None:
        write_primary_report(primary_report_output, payload)
        payload["primary_report_output"] = str(primary_report_output)
    return payload


def write_primary_report(path: Path, payload: dict[str, Any]) -> None:
    if path.exists():
        raise SystemExit(f"Refusing to overwrite primary report: {path}")
    metrics = payload["metrics"]
    flags = payload["support_flags"]
    lines = [
        "# Oxford Part 1 Battery M-Profile Primary Report",
        "",
        "Status: one-time held-out primary result. This is not causal intervention evidence.",
        "",
        "## Metrics",
        "",
        "| Model | RMSE | MAE | Train rows | Test rows |",
        "|---|---:|---:|---:|---:|",
    ]
    for model_name in ["B0", "B1", "B2", "B3", "primary"]:
        row = metrics[model_name]
        lines.append(
            f"| `{model_name}` | `{row['rmse']:.12g}` | `{row['mae']:.12g}` | "
            f"`{row['train_row_count']}` | `{row['test_row_count']}` |"
        )
    lines.extend(
        [
            "",
            "## Support Flags",
            "",
            f"- `H1_strong_incremental_support = {str(flags['H1_strong_incremental_support']).lower()}`",
            f"- `H2_weak_incremental_support = {str(flags['H2_weak_incremental_support']).lower()}`",
            f"- `H3_no_support = {str(flags['H3_no_support']).lower()}`",
            f"- `primary_support = {str(flags['primary_support']).lower()}`",
            "",
            "## Non-Claims",
            "",
            "- No causal intervention ranking.",
            "- No literal repair-flow claim.",
            "- No universal-law claim.",
            "- No same-archive rescue if primary loses to B3.",
            "",
        ]
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def path_is_labeled_rerun(path: Path | None) -> bool:
    return path is not None and "rerun" in str(path).lower()


def guard_primary_invocation(args: argparse.Namespace, output: Path) -> None:
    report = Path(args.primary_report_output) if args.primary_report_output is not None else None
    if output.exists():
        raise SystemExit(f"Refusing to overwrite primary output: {output}")
    if report is not None and report.exists():
        raise SystemExit(f"Refusing to overwrite primary report: {report}")
    if not args.confirm_frozen_primary:
        raise SystemExit("Primary run is fail-closed until --confirm-frozen-primary is supplied.")

    result_notes = {DEFAULT_PRIMARY_RESULT_NOTE, Path(args.primary_result_note)}
    existing_result_notes = sorted(str(path) for path in result_notes if path.exists())
    if existing_result_notes and not args.allow_primary_rerun:
        raise SystemExit(
            f"Primary result is already recorded at {existing_result_notes[0]}; "
            "future executions must be explicitly labeled as reruns."
        )
    if args.allow_primary_rerun:
        converted_test = Path(args.converted_test_root) if args.converted_test_root is not None else None
        if not (
            path_is_labeled_rerun(output)
            and path_is_labeled_rerun(report)
            and path_is_labeled_rerun(converted_test)
        ):
            raise SystemExit(
                "--allow-primary-rerun requires rerun-labeled output, report, "
                "and converted-test paths."
            )


def primary_blocked(root: Path) -> dict[str, Any]:
    entries, unmatched = parse_group_entries(root)
    return {
        "status": "primary_blocked",
        "mode": "allow_primary_run",
        "matlab_payload_opened": False,
        "heldout_payload_opened": False,
        "unmatched_entries": unmatched,
        "split_geometry": split_geometry(entries),
        "blocked_reason": "Freeze manifest is still draft or --confirm-frozen-primary / converted roots are missing.",
        "metrics_emitted": False,
        "support_flags_emitted": False,
    }


def main() -> None:
    args = parse_args()
    root = Path(args.root)
    output = Path(args.output)
    if args.allow_primary_run:
        guard_primary_invocation(args, output)

    if args.metadata_only:
        payload = metadata_only(root)
    elif args.train_smoke:
        if args.converted_train_root is not None:
            payload = converted_train_smoke(
                root,
                Path(args.converted_train_root),
                allow_partial=args.allow_partial_converted_smoke,
            )
        else:
            payload = train_smoke(root, args.max_train_payloads)
    elif args.training_feature_smoke:
        if args.converted_train_root is None:
            raise SystemExit("--training-feature-smoke requires --converted-train-root.")
        if args.feature_schema is None:
            raise SystemExit("--training-feature-smoke requires --feature-schema.")
        payload = training_feature_smoke(
            root,
            Path(args.converted_train_root),
            Path(args.feature_schema),
        )
    else:
        if args.converted_train_root is None:
            raise SystemExit("--allow-primary-run requires --converted-train-root.")
        if args.converted_test_root is None:
            raise SystemExit("--allow-primary-run requires --converted-test-root.")
        if args.feature_schema is None:
            raise SystemExit("--allow-primary-run requires --feature-schema.")
        payload = primary_run(
            root,
            Path(args.converted_train_root),
            Path(args.converted_test_root),
            Path(args.feature_schema),
            Path(args.primary_report_output) if args.primary_report_output is not None else None,
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")


if __name__ == "__main__":
    main()
