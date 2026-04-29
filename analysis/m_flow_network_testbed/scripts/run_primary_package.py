#!/usr/bin/env python3
"""Guarded primary-package runner for the M flow-network testbed.

By default this script only prints the execution plan.  It executes the package
only when both of the following are supplied:

- --execute --confirm-token <token>
- environment variable named in the config equals the same token

This keeps the primary package reproducible without making accidental primary
execution easy.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parents[1]
SCRIPT_DIR = HERE / "scripts"


def load_config(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def rel_or_abs(path: str) -> Path:
    p = Path(path)
    if p.is_absolute():
        return p
    return Path.cwd() / p


def format_allocation(allocation: list[int]) -> str:
    if len(allocation) != 3:
        raise ValueError(f"allocation must have 3 components: {allocation}")
    return ",".join(str(int(x)) for x in allocation)


def setting_id(setting: dict[str, Any]) -> str:
    return str(setting["id"])


def simulator_command(config: dict[str, Any], setting: dict[str, Any], out_dir: Path) -> list[str]:
    simulator = rel_or_abs(config["scripts"]["simulator"])
    common = config["simulator_common"]
    if not common.get("full_grid", False):
        raise ValueError("primary package requires simulator_common.full_grid=true")
    cmd = [
        sys.executable,
        str(simulator),
        "primary-run",
        "--out-dir",
        str(out_dir),
        "--seed",
        str(config["seeds"]["start"]),
        "--seeds",
        str(config["seeds"]["count"]),
        "--layers",
        str(common["layers"]),
        "--width",
        str(common["width"]),
        "--edge-density",
        str(common["edge_density"]),
        "--capacity-max",
        str(common["capacity_max"]),
        "--required-flow",
        str(setting["required_flow_Q"]),
        "--horizon",
        str(setting["horizon_T"]),
        "--damage-intensity",
        str(setting["damage_intensity"]),
        "--confirm-frozen-primary",
    ]
    for allocation in config["allocation_grid"]:
        cmd.extend(["--allocation", format_allocation(allocation)])
    for allocation in config["held_out_allocations"]:
        cmd.extend(["--held-out-allocation", format_allocation(allocation)])
    return cmd


def evaluator_command(config: dict[str, Any], out_dir: Path) -> list[str]:
    evaluator = rel_or_abs(config["scripts"]["evaluator"])
    return [
        sys.executable,
        str(evaluator),
        "--runs",
        str(out_dir / "runs.csv"),
        "--out-dir",
        str(out_dir),
        "--primary-run",
        "--confirm-frozen-primary",
    ]


def degeneracy_command(config: dict[str, Any], out_dir: Path) -> list[str]:
    reporter = rel_or_abs(config["scripts"]["degeneracy_report"])
    return [
        sys.executable,
        str(reporter),
        "--runs",
        str(out_dir / "runs.csv"),
        "--out-dir",
        str(out_dir),
        "--primary-run",
        "--confirm-frozen-primary",
    ]


def build_plan(config: dict[str, Any]) -> list[dict[str, Any]]:
    output_root = rel_or_abs(config["output_root"])
    plan: list[dict[str, Any]] = []
    settings = [config["primary_setting"], *config["sensitivity_settings"]]
    for setting in settings:
        out_dir = output_root / setting_id(setting)
        plan.append(
            {
                "setting_id": setting_id(setting),
                "setting": setting,
                "out_dir": str(out_dir),
                "commands": {
                    "simulate": simulator_command(config, setting, out_dir),
                    "evaluate": evaluator_command(config, out_dir),
                    "degeneracy_report": degeneracy_command(config, out_dir),
                },
            }
        )
    return plan


def require_confirmation(config: dict[str, Any], token: str | None) -> None:
    confirm = config["confirm_guard"]
    expected = confirm["token"]
    env_var = confirm["env_var"]
    env_value = os.environ.get(env_var)
    if token != expected or env_value != expected:
        raise SystemExit(
            f"Refusing to execute primary package. Require --confirm-token {expected!r} "
            f"and {env_var}={expected!r}."
        )


def execute_plan(plan: list[dict[str, Any]]) -> None:
    for item in plan:
        out_dir = Path(item["out_dir"])
        out_dir.mkdir(parents=True, exist_ok=True)
        for name in ("simulate", "evaluate", "degeneracy_report"):
            cmd = item["commands"][name]
            print(json.dumps({"running": name, "setting_id": item["setting_id"], "cmd": cmd}, indent=2))
            subprocess.run(cmd, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--execute", action="store_true")
    parser.add_argument("--confirm-token")
    args = parser.parse_args()

    config = load_config(args.config)
    plan = build_plan(config)
    print(
        json.dumps(
            {
                "status": "execution_plan" if not args.execute else "execution_requested",
                "non_claim": "printing or running a package is not support evidence",
                "config": str(args.config),
                "execute": args.execute,
                "plan": plan,
            },
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
        )
    )

    if args.execute:
        require_confirmation(config, args.confirm_token)
        execute_plan(plan)


if __name__ == "__main__":
    main()
