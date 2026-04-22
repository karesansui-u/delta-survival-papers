#!/usr/bin/env python3
"""Summarize Exp44 pilot JSONL output and evaluate freeze gates."""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Any


def load_records(path: Path) -> list[dict[str, Any]]:
    records = []
    with path.open(encoding="utf-8") as f:
        for line in f:
            if line.strip():
                records.append(json.loads(line))
    return records


def _is_monotone_nonincreasing(values: list[float | None]) -> bool:
    concrete = [value for value in values if value is not None]
    return all(a >= b for a, b in zip(concrete, concrete[1:], strict=False))


def summarize(records: list[dict[str, Any]], *, timeout_tolerance: float = 0.05) -> dict[str, Any]:
    cells: dict[tuple[str, int, float], list[dict[str, Any]]] = defaultdict(list)
    mixture_rho: dict[tuple[str, float], list[dict[str, Any]]] = defaultdict(list)
    for rec in records:
        key = (str(rec["mixture_id"]), int(rec["n"]), float(rec["rho_fm"]))
        cells[key].append(rec)
        mixture_rho[(str(rec["mixture_id"]), float(rec["rho_fm"]))].append(rec)

    cell_summaries = []
    suspended = 0
    malformed_total = 0
    for (mixture_id, n, rho_fm), rows in sorted(cells.items()):
        total = len(rows)
        timeout_count = sum(1 for row in rows if row.get("timeout") is True or row.get("status") == "TIMEOUT")
        solved = [row for row in rows if row.get("sat_feasible") is not None]
        sat = sum(1 for row in solved if row.get("sat_feasible") is True)
        malformed = sum(1 for row in rows if row.get("status") == "MALFORMED_ENCODING")
        malformed_total += malformed
        timeout_rate = timeout_count / total if total else 0.0
        sat_rate = sat / len(solved) if solved else None
        is_suspended = timeout_rate > timeout_tolerance
        suspended += int(is_suspended)
        cell_summaries.append(
            {
                "mixture_id": mixture_id,
                "n": n,
                "rho_fm": rho_fm,
                "total": total,
                "solved": len(solved),
                "timeout_count": timeout_count,
                "timeout_rate": timeout_rate,
                "malformed_count": malformed,
                "sat_rate": sat_rate,
                "suspended": is_suspended,
            }
        )

    mixture_rho_summaries = []
    for (mixture_id, rho_fm), rows in sorted(mixture_rho.items()):
        solved = [row for row in rows if row.get("sat_feasible") is not None]
        sat = sum(1 for row in solved if row.get("sat_feasible") is True)
        mixture_rho_summaries.append(
            {
                "mixture_id": mixture_id,
                "rho_fm": rho_fm,
                "total": len(rows),
                "solved": len(solved),
                "sat_rate": sat / len(solved) if solved else None,
            }
        )

    mixture_to_informative_bands: dict[str, set[float]] = defaultdict(set)
    mixture_to_rates: dict[str, list[tuple[float, float | None]]] = defaultdict(list)
    for row in mixture_rho_summaries:
        rate = row["sat_rate"]
        mixture_id = str(row["mixture_id"])
        rho_fm = float(row["rho_fm"])
        mixture_to_rates[mixture_id].append((rho_fm, rate))
        if rate is not None and 0.05 < rate < 0.95:
            mixture_to_informative_bands[mixture_id].add(rho_fm)

    mixture_ids = sorted({str(rec["mixture_id"]) for rec in records})
    monotone_by_mixture = {}
    for mixture_id in mixture_ids:
        rates = [rate for _rho, rate in sorted(mixture_to_rates[mixture_id])]
        monotone_by_mixture[mixture_id] = _is_monotone_nonincreasing(rates)

    monotone_count = sum(monotone_by_mixture.values())
    pilot_pass = (
        all(not cell["suspended"] for cell in cell_summaries)
        and malformed_total == 0
        and all(len(mixture_to_informative_bands[mid]) >= 2 for mid in mixture_ids)
        and monotone_count >= min(4, len(mixture_ids))
    )
    inconclusive = bool(cell_summaries) and suspended / len(cell_summaries) >= 0.30

    return {
        "total_records": len(records),
        "cell_count": len(cell_summaries),
        "suspended_cell_count": suspended,
        "suspended_cell_fraction": suspended / len(cell_summaries) if cell_summaries else 0.0,
        "malformed_total": malformed_total,
        "monotone_mixture_count": monotone_count,
        "pilot_pass": pilot_pass,
        "inconclusive_by_30pct_rule": inconclusive,
        "informative_rho_bands_by_mixture": {
            mixture_id: sorted(mixture_to_informative_bands.get(mixture_id, set()))
            for mixture_id in mixture_ids
        },
        "monotone_by_mixture": monotone_by_mixture,
        "mixture_rho": mixture_rho_summaries,
        "cells": cell_summaries,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jsonl", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    summary = summarize(load_records(args.jsonl))
    text = json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True)
    if args.output:
        args.output.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)


if __name__ == "__main__":
    main()

