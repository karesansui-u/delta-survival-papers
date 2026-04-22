#!/usr/bin/env python3
"""Append-safe pilot runner for Exp43 q-coloring."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

try:  # pragma: no cover
    from .feature_extractor import build_base_record
    from .generator import generate_instance
    from .solver import solve_instance
except ImportError:  # pragma: no cover
    from feature_extractor import build_base_record
    from generator import generate_instance
    from solver import solve_instance

HERE = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = HERE / "config" / "pilot_config.json"
DEFAULT_OUTPUT = HERE / "data" / "pilot_results.jsonl"


def load_config(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def iter_q_rho_pairs(config: dict[str, Any]) -> Iterable[tuple[int, float]]:
    """Yield q/rho pairs from either the global or per-q grid schema."""
    if "per_q_config" in config:
        for q_text, q_config in sorted(config["per_q_config"].items(), key=lambda item: int(item[0])):
            for rho_fm in q_config["rho_fm_values"]:
                yield int(q_text), float(rho_fm)
        return

    for q in config["q_values"]:
        for rho_fm in config["rho_fm_values"]:
            yield int(q), float(rho_fm)


def iter_plan(config: dict[str, Any]) -> Iterable[tuple[int, int, float, int]]:
    for q, rho_fm in iter_q_rho_pairs(config):
        for n in config["n_values"]:
            for instance_idx in range(config["instances_per_cell"]):
                yield int(q), int(n), float(rho_fm), int(instance_idx)


def load_completed(path: Path) -> set[str]:
    if not path.exists():
        return set()
    completed: set[str] = set()
    with path.open(encoding="utf-8") as f:
        for line in f:
            if line.strip():
                completed.add(json.loads(line)["instance_id"])
    return completed


def append_jsonl(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False, sort_keys=True) + "\n")


def build_instance_record(*, phase: str, q: int, n: int, rho_fm: float, instance_idx: int) -> dict[str, Any]:
    instance = generate_instance(phase=phase, q=q, n=n, rho_fm=rho_fm, instance_idx=instance_idx)
    return build_base_record(instance) | {
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }


def print_plan(config: dict[str, Any], output: Path) -> None:
    rows = list(iter_plan(config))
    completed = load_completed(output)
    cells: dict[tuple[int, int, float], int] = {}
    for q, n, rho_fm, _idx in rows:
        key = (q, n, rho_fm)
        cells[key] = cells.get(key, 0) + 1
    print("=" * 72)
    print("EXP43 Q-COLORING PILOT")
    print("=" * 72)
    print(f"phase: {config['phase']}")
    print(f"output: {output}")
    print(f"planned instances: {len(rows)}")
    print(f"completed instances in output: {len(completed)}")
    print(f"cells: {len(cells)}")
    for key in sorted(cells)[:12]:
        print(f"  q={key[0]} n={key[1]} rho_fm={key[2]:.2f} count={cells[key]}")
    if len(cells) > 12:
        print(f"  ... {len(cells) - 12} more cells")


def dry_run(config: dict[str, Any], output: Path) -> None:
    print_plan(config, output)
    print("\nExample instances:")
    for idx, (q, n, rho_fm, instance_idx) in enumerate(iter_plan(config)):
        if idx >= 5:
            break
        rec = build_instance_record(
            phase=config["phase"],
            q=q,
            n=n,
            rho_fm=rho_fm,
            instance_idx=instance_idx,
        )
        print(
            f"  {rec['instance_id']}: m={rec['m']} "
            f"L={rec['L']:.4f} fm={rec['first_moment_log_count']:.4f} "
            f"cnf={rec['cnf_clause_count']}"
        )


def run(config: dict[str, Any], output: Path, *, execute: bool, no_resume: bool) -> None:
    if not execute:
        raise SystemExit("Refusing solver run without --execute. Use dry-run first.")
    print_plan(config, output)
    completed = set() if no_resume else load_completed(output)
    for q, n, rho_fm, instance_idx in iter_plan(config):
        instance = generate_instance(phase=config["phase"], q=q, n=n, rho_fm=rho_fm, instance_idx=instance_idx)
        if instance.instance_id in completed:
            continue
        result = solve_instance(
            instance,
            timeout_sec=float(config["timeout_sec"]),
            backend=str(config["solver_backend"]),
        )
        record = build_base_record(instance) | result.to_json() | {
            "recorded_at": datetime.now(timezone.utc).isoformat(),
        }
        append_jsonl(output, record)
        print(
            f"{instance.instance_id} {result.status} "
            f"t={result.runtime_sec:.4f}s m={instance.m} cnf={instance.cnf_clause_count}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("dry-run")
    run_p = sub.add_parser("run")
    run_p.add_argument("--execute", action="store_true")
    run_p.add_argument("--no-resume", action="store_true")
    args = parser.parse_args()

    config = load_config(args.config)
    if args.cmd == "dry-run":
        dry_run(config, args.output)
    elif args.cmd == "run":
        run(config, args.output, execute=args.execute, no_resume=args.no_resume)


if __name__ == "__main__":
    main()
