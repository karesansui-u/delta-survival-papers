#!/usr/bin/env python3
"""Synthetic contract test for Oxford training-feature smoke.

This test uses synthetic converted training CSVs under /tmp. It does not inspect
Oxford payload values, held-out values, predictions, metrics, or support flags.
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


def write_synthetic_converted_root(root: Path, record_specs: list[dict[str, Any]]) -> None:
    tables = root / "tables"
    tables.mkdir(parents=True, exist_ok=True)
    records = []
    for offset, spec in enumerate(record_specs):
        cell_id = int(spec["cell_id"])
        group_id = int(spec["group_id"])
        diagnostic_index = int(spec["diagnostic_index"])
        csv_name = f"group{group_id}_cell{cell_id}_index{diagnostic_index}.csv"
        csv_path = tables / csv_name
        csv_path.write_text(
            "\n".join(
                [
                    "capacity_next,capacity_now,resistance,recovery_proxy,protocol,Amphr,Watthr,Amps,Volts,Temp1,TestTime",
                    f"{0.90 - offset * 0.01},{0.95 - offset * 0.01},{0.10 + offset * 0.01},{0.01 + offset * 0.001},P{offset % 2},0.0,0.0,0.5,3.8,25.0,0.0",
                    f"{0.89 - offset * 0.01},{0.94 - offset * 0.01},{0.11 + offset * 0.01},{0.02 + offset * 0.001},P{offset % 2},{1.0 + offset * 0.01},{3.7 + offset * 0.01},-0.5,3.6,26.0,10.0",
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
                "column_names": [
                    "capacity_next",
                    "capacity_now",
                    "resistance",
                    "recovery_proxy",
                    "protocol",
                    "Amphr",
                    "Watthr",
                    "Amps",
                    "Volts",
                    "Temp1",
                    "TestTime",
                ],
                "row_count": 2,
                "output_csv": f"tables/{csv_name}",
                "output_sha256": sha256_file(csv_path),
            }
        )
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
    (root / "conversion_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def write_schema(path: Path, *, missing_feature: bool = False) -> None:
    primary_features = [
        "_sp_diagnostic_index",
        "capacity_now",
        "resistance",
        "recovery_proxy",
        "protocol",
    ]
    if missing_feature:
        primary_features.append("does_not_exist")
    schema: dict[str, Any] = {
        "status": "training_feature_smoke_schema_frozen",
        "mode": "training_feature_smoke",
        "human_finalized": True,
        "train_cell_ids": TRAIN_CELL_IDS,
        "heldout_cell_ids": TEST_CELL_IDS,
        "endpoint_column": "capacity_next",
        "model_features": {
            "B1": ["_sp_diagnostic_index"],
            "B2": ["_sp_diagnostic_index", "_sp_group_id"],
            "B3": ["_sp_diagnostic_index", "capacity_now", "resistance"],
            "primary": primary_features,
        },
    }
    path.write_text(
        json.dumps(schema, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def write_endpoint_leak_schema(path: Path) -> None:
    schema: dict[str, Any] = {
        "status": "training_feature_smoke_schema_frozen",
        "mode": "training_feature_smoke",
        "human_finalized": True,
        "train_cell_ids": TRAIN_CELL_IDS,
        "heldout_cell_ids": TEST_CELL_IDS,
        "endpoint_column": "capacity_next",
        "model_features": {
            "B1": ["_sp_diagnostic_index"],
            "B2": ["_sp_diagnostic_index", "_sp_group_id"],
            "B3": ["_sp_diagnostic_index", "capacity_now", "resistance"],
            "primary": ["_sp_diagnostic_index", "capacity_next", "recovery_proxy"],
        },
    }
    path.write_text(
        json.dumps(schema, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def write_aggregate_schema(path: Path) -> None:
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


def run_feature_smoke(
    repo_root: Path,
    data_root: Path,
    converted_root: Path,
    schema_path: Path,
    output: Path,
) -> subprocess.CompletedProcess[str]:
    script = repo_root / "analysis/g4_battery_m_profile/scripts/evaluate_oxford_part1_m_profile.py"
    return subprocess.run(
        [
            sys.executable,
            str(script),
            "--root",
            str(data_root),
            "--output",
            str(output),
            "--training-feature-smoke",
            "--converted-train-root",
            str(converted_root),
            "--feature-schema",
            str(schema_path),
        ],
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def expect_pass(name: str, result: subprocess.CompletedProcess[str], output: Path) -> None:
    if result.returncode != 0:
        raise SystemExit(f"{name} expected pass, got {result.returncode}: {result.stderr}")
    payload = json.loads(output.read_text(encoding="utf-8"))
    if payload.get("status") != "training_feature_smoke_passed":
        raise SystemExit(f"{name} unexpected status: {payload.get('status')}")
    if payload.get("metrics_emitted") is not False:
        raise SystemExit(f"{name} emitted metrics unexpectedly.")
    if payload.get("support_flags_emitted") is not False:
        raise SystemExit(f"{name} emitted support flags unexpectedly.")
    if payload.get("heldout_payload_opened") is not False:
        raise SystemExit(f"{name} opened held-out payload unexpectedly.")
    if payload.get("training_feature_smoke_gate_passed") is not True:
        raise SystemExit(f"{name} did not record feature-smoke gate pass.")
    if payload.get("promotion_eligible_for_freeze_manifest") is not False:
        raise SystemExit(f"{name} should not auto-promote the freeze manifest.")
    forbidden_keys = {
        "predictions",
        "prediction",
        "y_true",
        "y_pred",
        "coefficients",
        "coef_",
        "intercept",
        "metric_values",
        "support_flags",
        "endpoint_values",
        "feature_values",
        "preprocessing_statistics",
        "scores",
        "rmse",
        "mae",
        "r2",
    }

    def walk(value: Any, path: str = "$") -> None:
        if isinstance(value, dict):
            for key, nested in value.items():
                if key in forbidden_keys:
                    raise SystemExit(f"{name} emitted forbidden key at {path}.{key}")
                walk(nested, f"{path}.{key}")
        elif isinstance(value, list):
            for index, nested in enumerate(value):
                walk(nested, f"{path}[{index}]")

    walk(payload)


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

    with tempfile.TemporaryDirectory(prefix="oxford_feature_smoke_contract_") as tmp:
        tmp_root = Path(tmp)
        converted_root = tmp_root / "converted"
        write_synthetic_converted_root(converted_root, full_training_specs)

        schema_path = tmp_root / "feature_schema.json"
        write_schema(schema_path)
        output = tmp_root / "feature_smoke.json"
        expect_pass(
            "valid_feature_smoke",
            run_feature_smoke(repo_root, data_root, converted_root, schema_path, output),
            output,
        )

        bad_schema_path = tmp_root / "bad_feature_schema.json"
        write_schema(bad_schema_path, missing_feature=True)
        expect_fail(
            "missing_feature_column",
            run_feature_smoke(
                repo_root,
                data_root,
                converted_root,
                bad_schema_path,
                tmp_root / "bad_feature_smoke.json",
            ),
            "missing required schema columns",
        )

        endpoint_leak_schema_path = tmp_root / "endpoint_leak_feature_schema.json"
        write_endpoint_leak_schema(endpoint_leak_schema_path)
        expect_fail(
            "endpoint_column_as_feature",
            run_feature_smoke(
                repo_root,
                data_root,
                converted_root,
                endpoint_leak_schema_path,
                tmp_root / "endpoint_leak_feature_smoke.json",
            ),
            "must not include endpoint_column",
        )

        aggregate_schema_path = tmp_root / "aggregate_feature_schema.json"
        write_aggregate_schema(aggregate_schema_path)
        aggregate_output = tmp_root / "aggregate_feature_smoke.json"
        expect_pass(
            "aggregate_feature_smoke",
            run_feature_smoke(
                repo_root,
                data_root,
                converted_root,
                aggregate_schema_path,
                aggregate_output,
            ),
            aggregate_output,
        )
        aggregate_payload = json.loads(aggregate_output.read_text(encoding="utf-8"))
        if aggregate_payload.get("feature_extraction") != "transition_aggregate_v1":
            raise SystemExit("aggregate feature smoke did not report transition_aggregate_v1.")

    print("training feature-smoke contract tests passed")


if __name__ == "__main__":
    main()
