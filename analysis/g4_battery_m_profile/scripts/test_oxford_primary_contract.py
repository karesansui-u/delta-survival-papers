#!/usr/bin/env python3
"""Synthetic contract test for the Oxford one-time primary runner.

This test uses synthetic converted train / held-out CSVs under /tmp. It does
not open Oxford MATLAB payload values and does not run the real held-out
primary.
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


def synthetic_capacity(spec: dict[str, Any]) -> float:
    return (
        2.0
        - 0.01 * int(spec["diagnostic_index"])
        - 0.001 * int(spec["cell_id"])
        + 0.02 * int(spec["group_id"])
    )


def write_converted_root(root: Path, record_specs: list[dict[str, Any]], *, split: str) -> None:
    tables = root / "tables"
    tables.mkdir(parents=True, exist_ok=True)
    records = []
    for spec in record_specs:
        cell_id = int(spec["cell_id"])
        group_id = int(spec["group_id"])
        diagnostic_index = int(spec["diagnostic_index"])
        capacity = synthetic_capacity(spec)
        csv_name = f"group{group_id}_cell{cell_id}_index{diagnostic_index}.csv"
        csv_path = tables / csv_name
        csv_path.write_text(
            "\n".join(
                [
                    "Amphr,Watthr,Amps,Volts,Temp1,TestTime",
                    f"0.0,0.0,0.5,3.9,25.0,0.0",
                    f"{capacity:.8f},{capacity * 3.7:.8f},-0.5,{3.6 + capacity * 0.01:.8f},26.0,10.0",
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        records.append(
            {
                "archive": spec["archive"],
                "entry_name": spec["entry_name"],
                "group_id": group_id,
                "cell_id": cell_id,
                "diagnostic_index": diagnostic_index,
                "column_names": ["Amphr", "Watthr", "Amps", "Volts", "Temp1", "TestTime"],
                "row_count": 2,
                "output_csv": f"tables/{csv_name}",
                "output_sha256": sha256_file(csv_path),
            }
        )

    if split == "train":
        status = "train_smoke_conversion_manifest"
        mode = "train_smoke"
        heldout_payload_exported = False
    elif split == "heldout":
        status = "heldout_primary_conversion_manifest"
        mode = "heldout_primary"
        heldout_payload_exported = True
    else:
        raise ValueError(f"Unsupported split: {split}")

    manifest = {
        "status": status,
        "mode": mode,
        "train_cell_ids": TRAIN_CELL_IDS,
        "heldout_cell_ids": TEST_CELL_IDS,
        "heldout_payload_exported": heldout_payload_exported,
        "metrics_computed": False,
        "support_flags_emitted": False,
        "truncated_by_max_records": False,
        "record_count": len(records),
        "records": records,
    }
    (root / "conversion_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def write_schema(path: Path) -> None:
    schema: dict[str, Any] = {
        "status": "training_feature_smoke_schema_frozen",
        "mode": "training_feature_smoke",
        "human_finalized": True,
        "feature_extraction": "transition_aggregate_v1",
        "train_cell_ids": TRAIN_CELL_IDS,
        "heldout_cell_ids": TEST_CELL_IDS,
        "endpoint_column": "next_capacity_ah",
        "model_features": {
            "B1": ["_sp_diagnostic_index"],
            "B2": ["_sp_diagnostic_index", "_sp_group_id"],
            "B3": [
                "_sp_diagnostic_index",
                "_sp_group_id",
                "capacity_ah_current",
                "energy_wh_current",
                "duration_s_current",
                "abs_current_mean",
                "abs_current_max",
                "voltage_mean",
                "voltage_min",
                "voltage_max",
                "temperature_mean",
                "temperature_max",
            ],
            "primary": [
                "_sp_diagnostic_index",
                "_sp_group_id",
                "capacity_ah_current",
                "energy_wh_current",
                "duration_s_current",
                "abs_current_mean",
                "abs_current_max",
                "voltage_mean",
                "voltage_min",
                "voltage_max",
                "temperature_mean",
                "temperature_max",
                "m_buffer_capacity_ah",
                "m_buffer_voltage_min",
                "m_recovery_voltage_tail_minus_min",
            ],
        },
    }
    path.write_text(
        json.dumps(schema, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def run_primary(
    repo_root: Path,
    data_root: Path,
    converted_train_root: Path,
    converted_test_root: Path,
    schema_path: Path,
    output: Path,
    report: Path,
    *,
    confirm: bool,
    primary_result_note: Path | None = None,
    allow_primary_rerun: bool = False,
) -> subprocess.CompletedProcess[str]:
    script = repo_root / "analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py"
    command = [
        sys.executable,
        str(script),
        "--root",
        str(data_root),
        "--output",
        str(output),
        "--allow-primary-run",
        "--converted-train-root",
        str(converted_train_root),
        "--converted-test-root",
        str(converted_test_root),
        "--feature-schema",
        str(schema_path),
        "--primary-report-output",
        str(report),
    ]
    if confirm:
        command.append("--confirm-frozen-primary")
    if primary_result_note is not None:
        command.extend(["--primary-result-note", str(primary_result_note)])
    if allow_primary_rerun:
        command.append("--allow-primary-rerun")
    return subprocess.run(
        command,
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def expect_pass(name: str, result: subprocess.CompletedProcess[str], output: Path, report: Path) -> None:
    if result.returncode != 0:
        raise SystemExit(f"{name} expected pass, got {result.returncode}: {result.stderr}")
    payload = json.loads(output.read_text(encoding="utf-8"))
    if payload.get("status") != "primary_run_completed":
        raise SystemExit(f"{name} unexpected status: {payload.get('status')}")
    if payload.get("metrics_emitted") is not True:
        raise SystemExit(f"{name} did not emit primary metrics.")
    if payload.get("support_flags_emitted") is not True:
        raise SystemExit(f"{name} did not emit primary support flags.")
    if payload.get("heldout_payload_opened") is not True:
        raise SystemExit(f"{name} did not mark held-out payload as opened.")
    if not report.exists():
        raise SystemExit(f"{name} did not write primary report.")
    for forbidden_key in ["predictions", "coefficients", "endpoint_values", "feature_values"]:
        if forbidden_key in json.dumps(payload):
            raise SystemExit(f"{name} emitted forbidden key: {forbidden_key}")


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
    train_specs = [
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
    heldout_specs = [
        {
            "archive": entry.archive,
            "entry_name": entry.entry_name,
            "group_id": entry.group,
            "cell_id": entry.cell,
            "diagnostic_index": entry.diagnostic_index,
        }
        for entry in parsed_entries
        if entry.cell in TEST_CELL_IDS
    ]

    with tempfile.TemporaryDirectory(prefix="oxford_primary_contract_") as tmp:
        tmp_root = Path(tmp)
        converted_train_root = tmp_root / "converted_train"
        converted_test_root = tmp_root / "converted_heldout"
        write_converted_root(converted_train_root, train_specs, split="train")
        write_converted_root(converted_test_root, heldout_specs, split="heldout")
        schema_path = tmp_root / "schema.json"
        write_schema(schema_path)

        blocked_output = tmp_root / "blocked.json"
        expect_fail(
            "primary_without_confirmation",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                converted_test_root,
                schema_path,
                blocked_output,
                tmp_root / "blocked.md",
                confirm=False,
            ),
            "Primary run is fail-closed",
        )
        if blocked_output.exists():
            raise SystemExit("primary_without_confirmation wrote an output file.")

        rerun_heldout_root = tmp_root / "rerun_converted_heldout"
        write_converted_root(rerun_heldout_root, heldout_specs, split="heldout")
        primary_output = tmp_root / "rerun_primary.json"
        primary_report = tmp_root / "rerun_primary.md"
        expect_pass(
            "primary_rerun_with_confirmation",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                rerun_heldout_root,
                schema_path,
                primary_output,
                primary_report,
                confirm=True,
                allow_primary_rerun=True,
            ),
            primary_output,
            primary_report,
        )

        expect_fail(
            "primary_output_overwrite",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                converted_test_root,
                schema_path,
                primary_output,
                tmp_root / "primary_overwrite.md",
                confirm=True,
                allow_primary_rerun=True,
            ),
            "Refusing to overwrite primary output",
        )

        expect_fail(
            "recorded_primary_requires_rerun_label",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                converted_test_root,
                schema_path,
                tmp_root / "second_primary.json",
                tmp_root / "second_primary.md",
                confirm=True,
            ),
            "Primary result is already recorded",
        )

        expect_fail(
            "rerun_requires_all_paths_labeled",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                converted_test_root,
                schema_path,
                tmp_root / "rerun_primary_2.json",
                tmp_root / "rerun_primary_2.md",
                confirm=True,
                allow_primary_rerun=True,
            ),
            "rerun-labeled output",
        )

        bad_heldout_root = tmp_root / "bad_rerun_heldout"
        write_converted_root(bad_heldout_root, heldout_specs + train_specs[:1], split="heldout")
        expect_fail(
            "heldout_manifest_contains_training_cell",
            run_primary(
                repo_root,
                data_root,
                converted_train_root,
                bad_heldout_root,
                schema_path,
                tmp_root / "bad_primary_rerun.json",
                tmp_root / "bad_primary_rerun.md",
                confirm=True,
                allow_primary_rerun=True,
            ),
            "forbidden training cell ID",
        )

    print("primary contract tests passed")


if __name__ == "__main__":
    main()
