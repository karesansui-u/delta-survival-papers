#!/usr/bin/env python3
"""Summarize Exp43 pilot JSONL output and evaluate freeze gates."""

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


def summarize(records: list[dict[str, Any]], *, timeout_tolerance: float = 0.05) -> dict[str, Any]:
    cells: dict[tuple[int, int, float], list[dict[str, Any]]] = defaultdict(list)
    for rec in records:
        cells[(int(rec["q"]), int(rec["n"]), float(rec["rho_fm"]))].append(rec)

    cell_summaries = []
    suspended = 0
    for (q, n, rho_fm), rows in sorted(cells.items()):
        total = len(rows)
        timeout_count = sum(1 for row in rows if row.get("timeout") is True or row.get("status") == "TIMEOUT")
        solved = [row for row in rows if row.get("q_colorable") is not None]
        colorable = sum(1 for row in solved if row.get("q_colorable") is True)
        malformed = sum(1 for row in rows if row.get("status") == "MALFORMED_ENCODING")
        timeout_rate = timeout_count / total if total else 0.0
        colorability_rate = colorable / len(solved) if solved else None
        is_suspended = timeout_rate > timeout_tolerance
        suspended += int(is_suspended)
        cell_summaries.append(
            {
                "q": q,
                "n": n,
                "rho_fm": rho_fm,
                "total": total,
                "solved": len(solved),
                "timeout_count": timeout_count,
                "timeout_rate": timeout_rate,
                "malformed_count": malformed,
                "colorability_rate": colorability_rate,
                "suspended": is_suspended,
            }
        )

    q_to_informative_bands: dict[int, set[float]] = defaultdict(set)
    for cell in cell_summaries:
        rate = cell["colorability_rate"]
        if rate is not None and 0.05 < rate < 0.95:
            q_to_informative_bands[int(cell["q"])].add(float(cell["rho_fm"]))

    q_values = sorted({int(rec["q"]) for rec in records})
    pilot_pass = (
        all(not cell["suspended"] for cell in cell_summaries)
        and all(len(q_to_informative_bands[q]) >= 2 for q in q_values)
    )
    inconclusive = bool(cell_summaries) and suspended / len(cell_summaries) >= 0.30

    return {
        "total_records": len(records),
        "cell_count": len(cell_summaries),
        "suspended_cell_count": suspended,
        "suspended_cell_fraction": suspended / len(cell_summaries) if cell_summaries else 0.0,
        "pilot_pass": pilot_pass,
        "inconclusive_by_30pct_rule": inconclusive,
        "informative_rho_bands_by_q": {
            str(q): sorted(q_to_informative_bands.get(q, set())) for q in q_values
        },
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
