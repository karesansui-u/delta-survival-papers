#!/usr/bin/env python3
"""Frozen evaluation script for the Backblaze loss-only G4 anchor.

This script is intended to be hashed in the freeze manifest before any primary
run. It implements the preregistered loss-only observational analysis only.
It does not contain repair-flow logic.
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import math
import zipfile
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import Iterable


SMART_FIELDS = [
    "smart_5_raw",
    "smart_187_raw",
    "smart_188_raw",
    "smart_197_raw",
    "smart_198_raw",
    "smart_199_raw",
]

METADATA_B1 = ["model", "capacity_bytes", "is_legacy_format"]
METADATA_B2 = [
    "model",
    "capacity_bytes",
    "datacenter",
    "cluster_id",
    "vault_id",
    "pod_id",
    "pod_slot_num",
    "is_legacy_format",
]

PRIMARY_HORIZON_DAYS = 30
MIN_FINAL_TEST_FAILURE_EVENTS = 200
LOGISTIC_C = 1.0
RANDOM_SEED = 43001


@dataclass(frozen=True)
class SplitDates:
    train: list[str]
    validation: list[str]
    test: list[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, help="Backblaze quarterly zip archive.")
    parser.add_argument("--output", required=True, help="JSON output path.")
    parser.add_argument(
        "--max-rows",
        type=int,
        default=None,
        help="Debug-only row limit. Must be omitted for the frozen primary run.",
    )
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="Only emit archive metadata and split information; do not fit models.",
    )
    return parser.parse_args()


def list_csv_files(archive: zipfile.ZipFile) -> list[str]:
    return sorted(info.filename for info in archive.infolist() if info.filename.endswith(".csv"))


def read_header(archive: zipfile.ZipFile, csv_name: str) -> list[str]:
    with archive.open(csv_name) as handle:
        text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
        return next(csv.reader(text))


def date_range_from_names(csv_names: Iterable[str]) -> list[str]:
    dates = []
    for name in csv_names:
        stem = Path(name).stem
        date.fromisoformat(stem)
        dates.append(stem)
    return sorted(dates)


def eligible_prediction_dates(all_dates: list[str], horizon_days: int) -> list[str]:
    max_date = date.fromisoformat(all_dates[-1])
    eligible = []
    for value in all_dates:
        current = date.fromisoformat(value)
        if current + timedelta(days=horizon_days) <= max_date:
            eligible.append(value)
    return eligible


def split_dates(eligible_dates: list[str]) -> SplitDates:
    n = len(eligible_dates)
    train_end = int(n * 0.70)
    validation_end = int(n * 0.85)
    return SplitDates(
        train=eligible_dates[:train_end],
        validation=eligible_dates[train_end:validation_end],
        test=eligible_dates[validation_end:],
    )


def required_columns_present(header: list[str]) -> dict[str, bool]:
    required = ["date", "serial_number", "model", "capacity_bytes", "failure"]
    metadata = sorted(set(METADATA_B2 + ["drive_age_days"]))
    fields = sorted(set(required + SMART_FIELDS + metadata) - {"drive_age_days"})
    return {field: field in header for field in fields}


def count_raw_failures_by_date(archive: zipfile.ZipFile, csv_names: list[str]) -> dict[str, int]:
    failures_by_date: dict[str, int] = defaultdict(int)
    for name in csv_names:
        with archive.open(name) as handle:
            text = io.TextIOWrapper(handle, encoding="utf-8-sig", newline="")
            reader = csv.DictReader(text)
            for row in reader:
                if row.get("failure") == "1":
                    failures_by_date[row["date"]] += 1
    return dict(failures_by_date)


def endpoint_dates_for_test(test_dates: list[str], horizon_days: int) -> list[str]:
    start = date.fromisoformat(test_dates[0]) + timedelta(days=1)
    end = date.fromisoformat(test_dates[-1]) + timedelta(days=horizon_days)
    return [(start + timedelta(days=i)).isoformat() for i in range((end - start).days + 1)]


def log1p_or_zero(value: str) -> float:
    if value == "" or value is None:
        return 0.0
    try:
        parsed = float(value)
    except ValueError:
        return 0.0
    if parsed < 0:
        return 0.0
    return math.log1p(parsed)


def main() -> None:
    args = parse_args()
    archive_path = Path(args.archive)
    output_path = Path(args.output)

    with zipfile.ZipFile(archive_path) as archive:
        csv_names = list_csv_files(archive)
        if not csv_names:
            raise SystemExit("No CSV files found in archive.")

        header = read_header(archive, csv_names[0])
        all_dates = date_range_from_names(csv_names)
        eligible = eligible_prediction_dates(all_dates, PRIMARY_HORIZON_DAYS)
        splits = split_dates(eligible)
        failures_by_date = count_raw_failures_by_date(archive, csv_names)
        endpoint_dates = endpoint_dates_for_test(splits.test, PRIMARY_HORIZON_DAYS)
        endpoint_failures = sum(failures_by_date.get(d, 0) for d in endpoint_dates)

    metadata = {
        "archive": str(archive_path),
        "n_csv_files": len(csv_names),
        "date_range": [all_dates[0], all_dates[-1]],
        "eligible_prediction_date_range": [eligible[0], eligible[-1]],
        "split_dates": {
            "train": [splits.train[0], splits.train[-1], len(splits.train)],
            "validation": [splits.validation[0], splits.validation[-1], len(splits.validation)],
            "test": [splits.test[0], splits.test[-1], len(splits.test)],
        },
        "horizon_days": PRIMARY_HORIZON_DAYS,
        "min_final_test_failure_events": MIN_FINAL_TEST_FAILURE_EVENTS,
        "raw_failures_in_test_endpoint_horizon": endpoint_failures,
        "columns_present": required_columns_present(header),
        "model_class": "L2-regularized logistic regression",
        "regularization_C": LOGISTIC_C,
        "random_seed": RANDOM_SEED,
        "metadata_only": args.metadata_only,
        "max_rows": args.max_rows,
    }

    if args.metadata_only:
        output_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n")
        return

    raise SystemExit(
        "Model fitting is intentionally not implemented in this freeze skeleton yet. "
        "Freeze the manifest and review this script hash before adding/running primary evaluation."
    )


if __name__ == "__main__":
    main()
