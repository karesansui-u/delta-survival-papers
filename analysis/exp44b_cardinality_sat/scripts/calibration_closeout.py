#!/usr/bin/env python3
"""Exp44b-specific calibration closeout gate.

This script summarizes an Exp44b calibration JSONL and checks the gates in
analysis/exp44b_cardinality_sat/preregistration_draft.md. It is intentionally
separate from the historical Exp44 pilot summary script.
"""

from __future__ import annotations

import argparse
import json
import math
from collections import defaultdict
from pathlib import Path
from statistics import median
from typing import Any


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with path.open(encoding="utf-8") as f:
        for line in f:
            if line.strip():
                records.append(json.loads(line))
    return records


def expected_cells(config: dict[str, Any]) -> dict[tuple[str, int, float], int]:
    cells: dict[tuple[str, int, float], int] = {}
    for mixture_id, mixture_config in sorted(config["per_mixture_config"].items()):
        for n in config["n_values"]:
            for rho in mixture_config["rho_fm_values"]:
                cells[(str(mixture_id), int(n), float(rho))] = int(config["instances_per_cell"])
    return cells


def feature(record: dict[str, Any], name: str) -> float:
    if name in record:
        return float(record[name])
    nested = record.get("features") or {}
    if name in nested:
        return float(nested[name])
    raise KeyError(name)


def is_timeout(record: dict[str, Any]) -> bool:
    return bool(record.get("timeout") is True or record.get("status") == "TIMEOUT")


def is_malformed(record: dict[str, Any]) -> bool:
    return str(record.get("status")) in {"MALFORMED", "MALFORMED_ENCODING"}


def solved_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [row for row in records if row.get("sat_feasible") is not None]


def sat_rate(records: list[dict[str, Any]]) -> float | None:
    solved = solved_records(records)
    if not solved:
        return None
    return sum(1 for row in solved if row.get("sat_feasible") is True) / len(solved)


def is_informative(rate: float | None) -> bool:
    return rate is not None and 0.05 < rate < 0.95


def is_monotone_nonincreasing(values: list[float | None]) -> bool:
    concrete = [value for value in values if value is not None]
    return all(a >= b for a, b in zip(concrete, concrete[1:], strict=False))


def ranks(values: list[float]) -> list[float] | None:
    if len(set(values)) <= 1:
        return None
    indexed = sorted(enumerate(values), key=lambda item: item[1])
    out = [0.0] * len(values)
    i = 0
    while i < len(indexed):
        j = i + 1
        while j < len(indexed) and indexed[j][1] == indexed[i][1]:
            j += 1
        avg_rank = (i + 1 + j) / 2.0
        for k in range(i, j):
            out[indexed[k][0]] = avg_rank
        i = j
    return out


def pearson(xs: list[float], ys: list[float]) -> float | None:
    if len(xs) != len(ys) or len(xs) < 2:
        return None
    mx = sum(xs) / len(xs)
    my = sum(ys) / len(ys)
    dx = [x - mx for x in xs]
    dy = [y - my for y in ys]
    vx = sum(x * x for x in dx)
    vy = sum(y * y for y in dy)
    if vx == 0 or vy == 0:
        return None
    return sum(x * y for x, y in zip(dx, dy, strict=True)) / math.sqrt(vx * vy)


def spearman(xs: list[float], ys: list[float]) -> float | None:
    rx = ranks(xs)
    ry = ranks(ys)
    if rx is None or ry is None:
        return None
    return pearson(rx, ry)


def cell_summaries(
    records: list[dict[str, Any]],
    expected: dict[tuple[str, int, float], int],
) -> tuple[list[dict[str, Any]], dict[tuple[str, int, float], dict[str, Any]]]:
    grouped: dict[tuple[str, int, float], list[dict[str, Any]]] = defaultdict(list)
    for row in records:
        key = (str(row["mixture_id"]), int(row["n"]), float(row["rho_fm"]))
        grouped[key].append(row)

    summaries = []
    by_key: dict[tuple[str, int, float], dict[str, Any]] = {}
    for key, expected_count in sorted(expected.items()):
        rows = grouped.get(key, [])
        timeout_count = sum(1 for row in rows if is_timeout(row))
        malformed_count = sum(1 for row in rows if is_malformed(row))
        completed = [row for row in rows if not is_timeout(row)]
        runtimes = [float(row.get("runtime_sec", 0.0)) for row in completed]
        slow_completed = sum(1 for value in runtimes if value > 60.0)
        median_runtime = median(runtimes) if runtimes else None
        slow_fraction = slow_completed / len(completed) if completed else 0.0
        timeout_rate = timeout_count / len(rows) if rows else 0.0
        runtime_unstable = bool(
            (median_runtime is not None and median_runtime > 30.0)
            or slow_fraction >= 0.20
        )
        timeout_suspended = timeout_rate > 0.05
        summary = {
            "mixture_id": key[0],
            "n": key[1],
            "rho_fm": key[2],
            "expected": expected_count,
            "total": len(rows),
            "missing_count": max(0, expected_count - len(rows)),
            "solved": len(solved_records(rows)),
            "sat_rate": sat_rate(rows),
            "timeout_count": timeout_count,
            "timeout_rate": timeout_rate,
            "malformed_count": malformed_count,
            "median_runtime_sec": median_runtime,
            "slow_completed_fraction": slow_fraction,
            "timeout_suspended": timeout_suspended,
            "runtime_unstable": runtime_unstable,
        }
        summaries.append(summary)
        by_key[key] = summary
    return summaries, by_key


def buffered_window(
    *,
    rho_values: list[float],
    informative: list[float],
) -> list[float]:
    if len(informative) < 2:
        return []
    ordered = sorted(rho_values)
    lo = ordered.index(min(informative))
    hi = ordered.index(max(informative))
    return ordered[max(0, lo - 1) : min(len(ordered), hi + 2)]


def projection(record: dict[str, Any], name: str) -> float:
    if name == "fm_plus_n":
        return feature(record, "first_moment_log_count") + feature(record, "n")
    if name == "raw_plus_n":
        return feature(record, "m_semantic") + feature(record, "n")
    if name == "density_plus_n":
        return feature(record, "semantic_density") + feature(record, "n")
    if name == "cnf_count_plus_n":
        return feature(record, "cnf_clause_count") + feature(record, "n")
    if name == "cnf_density_plus_n":
        return feature(record, "cnf_density") + feature(record, "n")
    raise ValueError(f"unknown projection: {name}")


def closeout(records: list[dict[str, Any]], config: dict[str, Any]) -> dict[str, Any]:
    expected = expected_cells(config)
    cells, cell_by_key = cell_summaries(records, expected)
    mixture_ids = sorted(config["per_mixture_config"])
    n_values = [int(n) for n in config["n_values"]]
    all_rhos_by_mixture = {
        str(mixture_id): [float(rho) for rho in mix_config["rho_fm_values"]]
        for mixture_id, mix_config in config["per_mixture_config"].items()
    }

    pooled_rates: dict[str, list[tuple[float, float | None]]] = {}
    pooled_informative: dict[str, list[float]] = {}
    monotone_by_mixture: dict[str, bool] = {}
    for mixture_id in mixture_ids:
        rates = []
        informative = []
        for rho in all_rhos_by_mixture[mixture_id]:
            pooled_rows = [
                row
                for row in records
                if str(row["mixture_id"]) == mixture_id and float(row["rho_fm"]) == rho
            ]
            rate = sat_rate(pooled_rows)
            rates.append((rho, rate))
            if is_informative(rate):
                informative.append(rho)
        pooled_rates[mixture_id] = rates
        pooled_informative[mixture_id] = informative
        monotone_by_mixture[mixture_id] = is_monotone_nonincreasing([rate for _rho, rate in rates])

    n_specific_windows: dict[str, list[dict[str, Any]]] = {}
    candidate_window_keys: set[tuple[str, int, float]] = set()
    for mixture_id in mixture_ids:
        windows = []
        for n in n_values:
            informative = [
                rho
                for rho in all_rhos_by_mixture[mixture_id]
                if is_informative(cell_by_key[(mixture_id, n, rho)]["sat_rate"])
            ]
            window = buffered_window(
                rho_values=all_rhos_by_mixture[mixture_id],
                informative=informative,
            )
            bad_cells = [
                rho
                for rho in window
                if cell_by_key[(mixture_id, n, rho)]["timeout_suspended"]
                or cell_by_key[(mixture_id, n, rho)]["runtime_unstable"]
            ]
            eligible = bool(len(window) >= 3 and not bad_cells)
            if eligible:
                for rho in window:
                    candidate_window_keys.add((mixture_id, n, rho))
            windows.append(
                {
                    "n": n,
                    "informative_rho": informative,
                    "buffered_window": window,
                    "bad_cells_in_window": bad_cells,
                    "eligible": eligible,
                }
            )
        n_specific_windows[mixture_id] = windows

    candidate_rows = [
        row
        for row in records
        if (str(row["mixture_id"]), int(row["n"]), float(row["rho_fm"])) in candidate_window_keys
        and row.get("sat_feasible") is not None
    ]
    distinct_grid_rows = len(
        {
            (str(row["mixture_id"]), int(row["n"]), float(row["rho_fm"]))
            for row in candidate_rows
        }
    )
    correlations: dict[str, float | None] = {}
    theory = [projection(row, "fm_plus_n") for row in candidate_rows]
    for baseline in ("raw_plus_n", "density_plus_n", "cnf_count_plus_n", "cnf_density_plus_n"):
        base_values = [projection(row, baseline) for row in candidate_rows]
        correlations[baseline] = spearman(theory, base_values)
    available_corrs = [abs(value) for value in correlations.values() if value is not None]
    power_collapse = bool(available_corrs and all(value >= 0.98 for value in available_corrs))
    power_diagnostic_pass = bool(available_corrs and not power_collapse and distinct_grid_rows >= 10)

    malformed_total = sum(cell["malformed_count"] for cell in cells)
    missing_total = sum(cell["missing_count"] for cell in cells)
    timeout_gate_pass = all(not cell["timeout_suspended"] for cell in cells)
    runtime_gate_pass = all(not cell["runtime_unstable"] for cell in cells)
    informative_gate_pass = all(len(pooled_informative[mixture_id]) >= 2 for mixture_id in mixture_ids)
    n_specific_gate_pass = all(any(window["eligible"] for window in n_specific_windows[mid]) for mid in mixture_ids)
    monotonicity_gate_pass = all(monotone_by_mixture.values())
    complete_gate_pass = missing_total == 0 and len(records) == sum(expected.values())
    malformed_gate_pass = malformed_total == 0

    gate_status = {
        "complete_gate_pass": complete_gate_pass,
        "malformed_gate_pass": malformed_gate_pass,
        "timeout_gate_pass": timeout_gate_pass,
        "runtime_gate_pass": runtime_gate_pass,
        "informative_gate_pass": informative_gate_pass,
        "n_specific_window_gate_pass": n_specific_gate_pass,
        "monotonicity_gate_pass": monotonicity_gate_pass,
        "power_diagnostic_pass": power_diagnostic_pass,
    }
    calibration_pass = all(gate_status.values())
    if calibration_pass:
        status = "calibration_pass"
    elif complete_gate_pass:
        status = "calibration_no_go"
    else:
        status = "calibration_inconclusive"

    return {
        "status": status,
        "phase": config["phase"],
        "total_records": len(records),
        "expected_records": sum(expected.values()),
        "cell_count": len(cells),
        "expected_cell_count": len(expected),
        "gate_status": gate_status,
        "pooled_informative_rho_by_mixture": pooled_informative,
        "monotone_by_mixture": monotone_by_mixture,
        "n_specific_windows_by_mixture": n_specific_windows,
        "power_collapse_diagnostic": {
            "candidate_grid_row_count": distinct_grid_rows,
            "spearman_abs_cutoff": 0.98,
            "spearman_with_fm_plus_n": correlations,
            "power_collapse": power_collapse,
            "low_resolution": distinct_grid_rows < 10,
        },
        "cell_summaries": cells,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--jsonl", type=Path, required=True)
    parser.add_argument("--output-json", type=Path)
    args = parser.parse_args()

    summary = closeout(load_jsonl(args.jsonl), load_json(args.config))
    text = json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True)
    if args.output_json:
        args.output_json.parent.mkdir(parents=True, exist_ok=True)
        args.output_json.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)


if __name__ == "__main__":
    main()
