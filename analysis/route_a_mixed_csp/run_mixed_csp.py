#!/usr/bin/env python3
"""Append-safe runner for the Mixed-CSP Route A experiment."""

from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path
from typing import Iterable

from mixed_csp_generator import generate_instance, instance_metadata
from mixed_csp_solvers import solve_with_minisat

HERE = Path(__file__).resolve().parent
TRIALS_PATH = HERE / "mixed_csp_trials.jsonl"

PRIMARY_N = [80, 120, 160]
PRIMARY_DENSITIES = [2.0, 2.5, 3.0, 3.5]
PRIMARY_MIXTURES = [
    {"sat": 1.0, "nae": 0.0, "exact1": 0.0},
    {"sat": 0.75, "nae": 0.25, "exact1": 0.0},
    {"sat": 0.50, "nae": 0.50, "exact1": 0.0},
    {"sat": 0.25, "nae": 0.75, "exact1": 0.0},
    {"sat": 0.0, "nae": 1.0, "exact1": 0.0},
]
PRIMARY_INSTANCES_PER_CELL = 200

SMOKE_N = [20]
SMOKE_DENSITIES = [1.0]
SMOKE_MIXTURES = [
    {"sat": 1.0, "nae": 0.0, "exact1": 0.0},
    {"sat": 0.0, "nae": 1.0, "exact1": 0.0},
    {"sat": 0.5, "nae": 0.5, "exact1": 0.0},
    {"sat": 0.0, "nae": 0.0, "exact1": 1.0},
]
SMOKE_INSTANCES_PER_CELL = 5

EXACT_ONE_PILOT_N = [80, 120, 160]
# The preregistered exact-one pilot is 3 n-values * 2 stress mixtures * 50
# instances = 300 instances. Use the lowest primary density so the stress
# extension has a chance to remain informative rather than immediately
# saturating feasibility.
EXACT_ONE_PILOT_DENSITIES = [2.0]
EXACT_ONE_PILOT_MIXTURES = [
    {"sat": 0.80, "nae": 0.10, "exact1": 0.10},
    {"sat": 0.60, "nae": 0.20, "exact1": 0.20},
]
EXACT_ONE_PILOT_INSTANCES_PER_CELL = 50


def mixture_id(mixture: dict[str, float]) -> str:
    return (
        f"sat_{mixture['sat']:.2f}__"
        f"nae_{mixture['nae']:.2f}__"
        f"exact1_{mixture['exact1']:.2f}"
    )


def iter_plan(phase: str) -> Iterable[tuple[int, float, dict[str, float], int]]:
    if phase == "smoke":
        ns, densities, mixtures, per_cell = (
            SMOKE_N,
            SMOKE_DENSITIES,
            SMOKE_MIXTURES,
            SMOKE_INSTANCES_PER_CELL,
        )
    elif phase == "primary":
        ns, densities, mixtures, per_cell = (
            PRIMARY_N,
            PRIMARY_DENSITIES,
            PRIMARY_MIXTURES,
            PRIMARY_INSTANCES_PER_CELL,
        )
    elif phase == "exact_one_pilot":
        ns, densities, mixtures, per_cell = (
            EXACT_ONE_PILOT_N,
            EXACT_ONE_PILOT_DENSITIES,
            EXACT_ONE_PILOT_MIXTURES,
            EXACT_ONE_PILOT_INSTANCES_PER_CELL,
        )
    else:
        raise ValueError(f"unknown phase: {phase}")

    for n in ns:
        for density in densities:
            for mixture in mixtures:
                for instance_idx in range(per_cell):
                    yield n, density, mixture, instance_idx


def load_completed(path: Path) -> set[str]:
    completed: set[str] = set()
    if not path.exists():
        return completed
    with path.open() as f:
        for line in f:
            if not line.strip():
                continue
            rec = json.loads(line)
            completed.add(rec["instance_id"])
    return completed


def append_record(path: Path, record: dict) -> None:
    with path.open("a") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


def build_record(phase: str, n: int, density: float, mixture: dict[str, float], instance_idx: int) -> dict:
    instance = generate_instance(
        phase=phase,
        n=n,
        density=density,
        mixture=mixture,
        instance_idx=instance_idx,
    )
    rec = instance_metadata(instance)
    rec["generated_at"] = datetime.now().isoformat()
    return rec


def print_plan(phase: str, output: Path) -> None:
    rows = list(iter_plan(phase))
    completed = load_completed(output)
    remaining = 0
    cells: dict[tuple[int, float, str], int] = {}
    for n, density, mixture, instance_idx in rows:
        rec = build_record(phase, n, density, mixture, instance_idx)
        key = (n, density, rec["mixture_id"])
        cells[key] = cells.get(key, 0) + 1
        if rec["instance_id"] not in completed:
            remaining += 1
    print("=" * 72)
    print("MIXED-CSP ROUTE A RUNNER")
    print("=" * 72)
    print(f"phase: {phase}")
    print(f"output: {output}")
    print(f"planned instances: {len(rows)}")
    print(f"completed instances in output: {len(completed)}")
    print(f"remaining instances: {remaining}")
    print(f"cells: {len(cells)}")
    for key in sorted(cells)[:10]:
        print(f"  n={key[0]} density={key[1]} mixture={key[2]} count={cells[key]}")
    if len(cells) > 10:
        print(f"  ... {len(cells)-10} more cells")


def dry_run(phase: str, output: Path) -> None:
    print_plan(phase, output)
    print("\nExample instances:")
    for idx, (n, density, mixture, instance_idx) in enumerate(iter_plan(phase)):
        if idx >= 5:
            break
        rec = build_record(phase, n, density, mixture, instance_idx)
        print(
            f"  {rec['instance_id']}: m={rec['m']} counts={rec['counts']} "
            f"L={rec['L']:.4f} cnf={rec['cnf_clause_count']}"
        )


def run_phase(
    *,
    phase: str,
    output: Path,
    execute: bool,
    no_resume: bool,
    timeout_sec: float,
) -> None:
    if not execute:
        raise SystemExit("Refusing solver run without --execute. Use dry-run first.")
    print_plan(phase, output)
    completed = set() if no_resume else load_completed(output)
    for n, density, mixture, instance_idx in iter_plan(phase):
        instance = generate_instance(
            phase=phase,
            n=n,
            density=density,
            mixture=mixture,
            instance_idx=instance_idx,
        )
        if instance.instance_id in completed:
            continue
        result = solve_with_minisat(instance, timeout_sec=timeout_sec)
        record = instance_metadata(instance) | result.to_json()
        record["recorded_at"] = datetime.now().isoformat()
        append_record(output, record)
        status = (
            "SAT"
            if result.sat_feasible is True
            else "UNSAT"
            if result.sat_feasible is False
            else result.status
        )
        print(
            f"{instance.instance_id} {status} "
            f"t={result.runtime_sec:.4f}s cnf={instance.cnf_clause_count}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "phase",
        choices=["smoke", "exact_one_pilot", "primary"],
        help="Execution phase.",
    )
    parser.add_argument("--output", type=Path, default=TRIALS_PATH)
    parser.add_argument("--timeout-sec", type=float, default=30.0)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("dry-run")
    run_p = sub.add_parser("run")
    run_p.add_argument("--execute", action="store_true")
    run_p.add_argument("--no-resume", action="store_true")

    args = parser.parse_args()
    if args.cmd == "dry-run":
        dry_run(args.phase, args.output)
    elif args.cmd == "run":
        run_phase(
            phase=args.phase,
            output=args.output,
            execute=args.execute,
            no_resume=args.no_resume,
            timeout_sec=args.timeout_sec,
        )


if __name__ == "__main__":
    main()
