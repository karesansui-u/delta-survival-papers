#!/usr/bin/env python3
"""Negative tests for Oxford converted-training manifest guardrails.

This script uses synthetic converted CSV headers under /tmp. It does not inspect
Oxford payload values, endpoint values, features, predictions, metrics, or
support flags.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


TRAIN_CELL_IDS = [4, 8, 10, 14, 15, 18, 19, 20]
TEST_CELL_IDS = [3, 9, 11, 12]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_synthetic_manifest(root: Path, **overrides: Any) -> Path:
    tables = root / "tables"
    tables.mkdir(parents=True, exist_ok=True)

    cell_ids = overrides.pop("cell_ids", TRAIN_CELL_IDS)
    record_specs = overrides.pop("record_specs", None)
    record_overrides = overrides.pop("record_overrides", {})
    records = []
    if record_specs is None:
        record_specs = [
            {
                "archive": "Group_2.zip",
                "entry_name": f"Group 2/TPG2 - Cell {cell_id}.mat",
                "group_id": 2,
                "cell_id": cell_id,
                "diagnostic_index": 0,
            }
            for cell_id in cell_ids
        ]
    for spec in record_specs:
        cell_id = int(spec["cell_id"])
        group_id = int(spec["group_id"])
        diagnostic_index = int(spec["diagnostic_index"])
        csv_name = f"group{group_id}_cell{cell_id}_index{diagnostic_index}.csv"
        csv_path = tables / csv_name
        csv_path.write_text("time,current\n", encoding="utf-8")
        record = {
            "archive": spec["archive"],
            "entry_name": spec["entry_name"],
            "group_id": group_id,
            "cell_id": cell_id,
            "diagnostic_index": diagnostic_index,
            "column_names": ["time", "current"],
            "row_count": 2,
            "output_csv": f"tables/{csv_name}",
            "output_sha256": sha256_file(csv_path),
        }
        record.update(record_overrides)
        records.append(record)

    manifest = {
        "status": "train_smoke_conversion_manifest",
        "mode": "train_smoke",
        "train_cell_ids": TRAIN_CELL_IDS,
        "heldout_cell_ids": TEST_CELL_IDS,
        "heldout_payload_exported": False,
        "metrics_computed": False,
        "support_flags_emitted": False,
        "truncated_by_max_records": False,
        "record_count": len(records),
        "records": records,
    }
    manifest.update(overrides)

    manifest_path = root / "conversion_manifest.json"
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return manifest_path


def run_eval(
    repo_root: Path,
    data_root: Path,
    converted_root: Path,
    output: Path,
    *,
    allow_partial: bool = False,
) -> subprocess.CompletedProcess[str]:
    script = repo_root / "analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py"
    command = [
        sys.executable,
        str(script),
        "--root",
        str(data_root),
        "--output",
        str(output),
        "--train-smoke",
        "--converted-train-root",
        str(converted_root),
    ]
    if allow_partial:
        command.append("--allow-partial-converted-smoke")
    return subprocess.run(
        command,
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def expect_pass(name: str, result: subprocess.CompletedProcess[str]) -> None:
    if result.returncode != 0:
        raise SystemExit(f"{name} expected pass, got {result.returncode}: {result.stderr}")


def expect_fail(name: str, result: subprocess.CompletedProcess[str], pattern: str) -> None:
    if result.returncode == 0:
        raise SystemExit(f"{name} expected failure, got pass.")
    if pattern not in result.stderr:
        raise SystemExit(
            f"{name} expected stderr to contain {pattern!r}, got: {result.stderr}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        default="analysis/g4_battery_m_profile/data/oxford_path_dependent/part1",
        help="Oxford Part 1 root used only for zip-entry metadata parsing.",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[3]
    scripts_dir = repo_root / "analysis/g4_battery_m_profile/scripts"
    sys.path.insert(0, str(scripts_dir))
    from evaluate_oxford_part1_m_profile import parse_group_entries  # noqa: PLC0415

    data_root = (repo_root / args.root).resolve()
    if not data_root.exists():
        raise SystemExit(f"Missing Oxford Part 1 data root: {data_root}")
    parsed_entries, _ = parse_group_entries(data_root)
    full_training_specs = [
        {
            "archive": entry.archive,
            "entry_name": entry.entry_name,
            "group_id": entry.group,
            "cell_id": entry.cell,
            "diagnostic_index": entry.diagnostic_index,
        }
        for entry in parsed_entries
        if entry.cell in TRAIN_CELL_IDS
    ]

    with tempfile.TemporaryDirectory(prefix="oxford_manifest_guardrails_") as tmp:
        tmp_root = Path(tmp)

        valid_root = tmp_root / "valid"
        write_synthetic_manifest(valid_root, record_specs=full_training_specs)
        expect_pass("valid_manifest", run_eval(repo_root, data_root, valid_root, tmp_root / "valid.json"))

        duplicate_entry_root = tmp_root / "duplicate_training_entry"
        write_synthetic_manifest(
            duplicate_entry_root,
            record_specs=full_training_specs + [full_training_specs[0]],
        )
        expect_fail(
            "duplicate_training_entry",
            run_eval(repo_root, data_root, duplicate_entry_root, tmp_root / "duplicate_entry.json"),
            "duplicate training entries",
        )

        missing_entry_root = tmp_root / "missing_training_entry"
        write_synthetic_manifest(missing_entry_root, record_specs=full_training_specs[:-1])
        expect_fail(
            "missing_expected_training_entry",
            run_eval(repo_root, data_root, missing_entry_root, tmp_root / "missing_entry.json"),
            "does not match expected training entry count",
        )

        extra_csv_root = tmp_root / "extra_csv"
        write_synthetic_manifest(extra_csv_root, record_specs=full_training_specs)
        extra_csv = extra_csv_root / "tables" / "unreferenced_heldout_like.csv"
        extra_csv.write_text("time,current\n", encoding="utf-8")
        expect_fail(
            "unreferenced_csv",
            run_eval(repo_root, data_root, extra_csv_root, tmp_root / "extra_csv.json"),
            "unreferenced CSV",
        )

        partial_root = tmp_root / "partial"
        write_synthetic_manifest(
            partial_root,
            cell_ids=[4],
            truncated_by_max_records=True,
            record_count=1,
        )
        expect_fail(
            "partial_without_flag",
            run_eval(repo_root, data_root, partial_root, tmp_root / "partial_fail.json"),
            "truncated by max_records",
        )
        expect_pass(
            "partial_with_flag",
            run_eval(
                repo_root,
                data_root,
                partial_root,
                tmp_root / "partial_pass.json",
                allow_partial=True,
            ),
        )

        heldout_root = tmp_root / "heldout"
        write_synthetic_manifest(heldout_root, cell_ids=[3], record_count=1)
        expect_fail(
            "heldout_cell_record",
            run_eval(repo_root, data_root, heldout_root, tmp_root / "heldout.json"),
            "held-out cell ID",
        )

        mislabeled_root = tmp_root / "mislabeled"
        write_synthetic_manifest(
            mislabeled_root,
            cell_ids=[4],
            record_overrides={"entry_name": "Group 2/TPG2 - Cell 3.mat"},
            record_count=1,
        )
        expect_fail(
            "mislabeled_heldout_source_entry",
            run_eval(repo_root, data_root, mislabeled_root, tmp_root / "mislabeled.json"),
            "cell_id does not match entry_name",
        )

        guardrail_root = tmp_root / "bad_guardrail"
        write_synthetic_manifest(guardrail_root, metrics_computed=True)
        expect_fail(
            "bad_guardrail",
            run_eval(repo_root, data_root, guardrail_root, tmp_root / "guardrail.json"),
            "guardrail mismatch",
        )

        count_root = tmp_root / "bad_count"
        write_synthetic_manifest(count_root, record_count=2)
        expect_fail(
            "bad_record_count",
            run_eval(repo_root, data_root, count_root, tmp_root / "count.json"),
            "record_count",
        )

        outside_csv = tmp_root / "outside.csv"
        outside_csv.write_text("time,current\n", encoding="utf-8")
        outside_root = tmp_root / "outside_path"
        write_synthetic_manifest(
            outside_root,
            record_overrides={
                "output_csv": str(outside_csv),
                "output_sha256": sha256_file(outside_csv),
            },
        )
        expect_fail(
            "outside_csv_path",
            run_eval(repo_root, data_root, outside_root, tmp_root / "outside.json"),
            "escapes converted root",
        )

    print("converted manifest guardrail tests passed")


if __name__ == "__main__":
    main()
