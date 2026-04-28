#!/usr/bin/env python3
"""Synthetic contract test for Oxford training schema drafting.

This test uses synthetic converted training CSV headers under /tmp. It does not
inspect Oxford payload values, training values, held-out values, predictions,
metrics, or support flags.
"""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path


TRAIN_CELL_IDS = [4, 8, 10, 14, 15, 18, 19, 20]
TEST_CELL_IDS = [3, 9, 11, 12]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_synthetic_converted_root(root: Path) -> None:
    tables = root / "tables"
    tables.mkdir(parents=True, exist_ok=True)
    records = []
    for cell_id in TRAIN_CELL_IDS:
        csv_name = f"group2_cell{cell_id}_index0.csv"
        csv_path = tables / csv_name
        csv_path.write_text(
            "time,voltage,current,temperature,capacity_now,capacity_next,resistance,recovery_proxy,protocol\n",
            encoding="utf-8",
        )
        records.append(
            {
                "archive": "Group_2.zip",
                "entry_name": f"Group 2/TPG2 - Cell {cell_id}.mat",
                "group_id": 2,
                "cell_id": cell_id,
                "diagnostic_index": 0,
                "column_names": [
                    "time",
                    "voltage",
                    "current",
                    "temperature",
                    "capacity_now",
                    "capacity_next",
                    "resistance",
                    "recovery_proxy",
                    "protocol",
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


def main() -> None:
    repo_root = Path(__file__).resolve().parents[3]
    scripts_dir = repo_root / "analysis/g4_battery_m_profile/scripts"
    script = repo_root / "analysis/g4_battery_m_profile/scripts/draft_oxford_training_feature_schema.py"
    with tempfile.TemporaryDirectory(prefix="oxford_schema_draft_contract_") as tmp:
        tmp_root = Path(tmp)
        converted_root = tmp_root / "converted"
        write_synthetic_converted_root(converted_root)
        output = tmp_root / "schema_draft.json"
        result = subprocess.run(
            [
                sys.executable,
                str(script),
                "--converted-train-root",
                str(converted_root),
                "--output",
                str(output),
            ],
            cwd=repo_root,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            raise SystemExit(f"schema draft expected pass, got {result.returncode}: {result.stderr}")
        payload = json.loads(output.read_text(encoding="utf-8"))
        if payload.get("status") != "training_feature_schema_header_draft":
            raise SystemExit(f"unexpected schema draft status: {payload.get('status')}")
        if payload.get("metrics_emitted") is not False:
            raise SystemExit("schema draft emitted metrics unexpectedly.")
        if payload.get("support_flags_emitted") is not False:
            raise SystemExit("schema draft emitted support flags unexpectedly.")
        candidates = payload["candidate_column_families"]
        if "capacity_next" not in candidates["endpoint_like_capacity"]:
            raise SystemExit("schema draft did not classify capacity_next as endpoint-like.")
        if payload["schema_template"]["endpoint_column"] != "TBD_SELECT_ONE_FROM_endpoint_like_capacity":
            raise SystemExit("schema template endpoint placeholder changed unexpectedly.")
        if payload["schema_template"]["status"] != "training_feature_smoke_schema_template":
            raise SystemExit("schema template must not be accepted directly by feature smoke.")
        if payload["schema_template"].get("human_finalized") is not False:
            raise SystemExit("schema template should require human finalization.")

        # Regression guard: schema drafting must not read CSV body bytes to hash
        # them. It may inspect headers only.
        sys.path.insert(0, str(scripts_dir))
        import draft_oxford_training_feature_schema as schema_draft  # noqa: PLC0415
        import evaluate_oxford_part1_m_profile as evaluator  # noqa: PLC0415

        original_sha256_file = evaluator.sha256_file
        original_argv = sys.argv[:]

        def fail_if_hashing_csv_body(path: Path) -> str:
            raise AssertionError(f"schema draft unexpectedly hashed CSV body bytes: {path}")

        evaluator.sha256_file = fail_if_hashing_csv_body
        try:
            sys.argv = [
                str(script),
                "--converted-train-root",
                str(converted_root),
                "--output",
                str(tmp_root / "schema_draft_no_hash.json"),
            ]
            schema_draft.main()
        finally:
            evaluator.sha256_file = original_sha256_file
            sys.argv = original_argv

    print("training schema-draft contract tests passed")


if __name__ == "__main__":
    main()
