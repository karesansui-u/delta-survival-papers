#!/usr/bin/env python3
"""Generate deterministic Exp43 primary instance manifests without solving."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

try:  # pragma: no cover
    from .feature_extractor import build_base_record
    from .generator import generate_instance
    from .pilot_runner import iter_plan, load_config
except ImportError:  # pragma: no cover
    from feature_extractor import build_base_record
    from generator import generate_instance
    from pilot_runner import iter_plan, load_config

HERE = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = HERE / "config" / "exp43c_primary_config.json"
DEFAULT_OUTPUT = HERE / "data" / "exp43c_primary_manifest.jsonl"


def write_manifest(config: dict, output: Path) -> int:
    output.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with output.open("w", encoding="utf-8") as f:
        for q, n, rho_fm, instance_idx in iter_plan(config):
            instance = generate_instance(
                phase=str(config["phase"]),
                q=q,
                n=n,
                rho_fm=rho_fm,
                instance_idx=instance_idx,
            )
            record = build_base_record(instance) | {
                "solver_backend": str(config["solver_backend"]),
                "timeout_sec": float(config["timeout_sec"]),
            }
            f.write(json.dumps(record, ensure_ascii=False, sort_keys=True) + "\n")
            count += 1
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args()

    config = load_config(args.config)
    rows = list(iter_plan(config))
    print(f"phase: {config['phase']}")
    print(f"planned instances: {len(rows)}")
    print(f"cells: {len({(q, n, rho) for q, n, rho, _ in rows})}")
    print(f"output: {args.output}")
    if args.check_only:
        return
    count = write_manifest(config, args.output)
    print(f"written instances: {count}")


if __name__ == "__main__":
    main()
