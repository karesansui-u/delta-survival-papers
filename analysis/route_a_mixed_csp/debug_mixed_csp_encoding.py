#!/usr/bin/env python3
"""Diagnostics for Mixed-CSP CNF / semantic agreement.

This script is intentionally separate from the primary runner. It is for
pre-primary implementation checks and regression debugging only.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any

from mixed_csp_generator import MixedCSPInstance, generate_instance, literal_value

HERE = Path(__file__).resolve().parent
DEFAULT_ARCHIVE = HERE / "mixed_csp_aborted_primary_attempt_2026-04-22_0338.jsonl"


def used_vars(instance: MixedCSPInstance) -> set[int]:
    return {abs(lit) for constraint in instance.constraints for lit in constraint.literals}


def model_assignment(model: list[int]) -> dict[int, bool]:
    return {abs(lit): lit > 0 for lit in model if lit != 0}


def clause_satisfied(clause: list[int], assignment: dict[int, bool]) -> bool:
    try:
        return any(literal_value(lit, assignment) for lit in clause)
    except KeyError:
        return False


def cnf_satisfied(instance: MixedCSPInstance, model: list[int]) -> bool:
    assignment = model_assignment(model)
    return all(clause_satisfied(clause, assignment) for clause in instance.cnf_clauses)


def semantic_failures(instance: MixedCSPInstance, model: list[int]) -> list[dict[str, Any]]:
    assignment = model_assignment(model)
    failures: list[dict[str, Any]] = []
    for idx, constraint in enumerate(instance.constraints):
        try:
            ok = constraint.is_satisfied(assignment)
        except KeyError as exc:
            ok = False
            missing_var = int(exc.args[0])
        else:
            missing_var = None
        if not ok:
            failures.append(
                {
                    "constraint_index": idx,
                    "kind": constraint.kind,
                    "literals": list(constraint.literals),
                    "missing_var": missing_var,
                }
            )
    return failures


def solve_model(instance: MixedCSPInstance) -> tuple[bool, list[int] | None, dict[str, Any]]:
    from pysat.solvers import Minisat22  # type: ignore

    with Minisat22(bootstrap_with=instance.cnf_clauses) as solver:
        sat = bool(solver.solve())
        model = solver.get_model() if sat else None
        stats = solver.accum_stats() or {}
    return sat, model, stats


def regenerate_from_record(record: dict[str, Any]) -> MixedCSPInstance:
    instance_idx = int(record["instance_id"].split("__i")[-1])
    return generate_instance(
        phase=record["phase"],
        n=int(record["n"]),
        density=float(record["density"]),
        mixture={k: float(v) for k, v in record["mixture"].items()},
        instance_idx=instance_idx,
    )


def old_all_variable_verifier(instance: MixedCSPInstance, model: list[int]) -> bool:
    assignment = model_assignment(model)
    if any(var not in assignment for var in range(1, instance.n + 1)):
        return False
    return all(constraint.is_satisfied(assignment) for constraint in instance.constraints)


def inspect_instance(instance: MixedCSPInstance) -> dict[str, Any]:
    sat, model, stats = solve_model(instance)
    if not sat:
        return {
            "instance_id": instance.instance_id,
            "sat": False,
            "stats": stats,
        }
    assert model is not None
    assignment = model_assignment(model)
    missing_all = sorted(set(range(1, instance.n + 1)) - set(assignment))
    missing_used = sorted(used_vars(instance) - set(assignment))
    failures = semantic_failures(instance, model)
    return {
        "instance_id": instance.instance_id,
        "sat": True,
        "model_len": len(model),
        "zero_in_model": 0 in model,
        "duplicate_model_vars": len([lit for lit in model if lit != 0])
        - len({abs(lit) for lit in model if lit != 0}),
        "missing_all_count": len(missing_all),
        "missing_all_first": missing_all[:20],
        "missing_used_count": len(missing_used),
        "missing_used_first": missing_used[:20],
        "cnf_satisfied": cnf_satisfied(instance, model),
        "semantic_satisfied": instance.assignment_satisfies_semantics(model),
        "old_all_variable_verifier": old_all_variable_verifier(instance, model),
        "semantic_failures_first": failures[:5],
        "stats": stats,
    }


def regression(args: argparse.Namespace) -> int:
    archive = Path(args.archive)
    records = [
        json.loads(line)
        for line in archive.read_text().splitlines()
        if line.strip()
    ]
    targets = [record for record in records if record.get("status") == "malformed_encoding"]
    if not targets:
        print(f"No malformed_encoding rows found in {archive}")
        return 1

    ok = True
    for record in targets:
        instance = regenerate_from_record(record)
        report = inspect_instance(instance)
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
        ok = ok and bool(report.get("cnf_satisfied")) and bool(report.get("semantic_satisfied"))

    if ok:
        print(f"PASS: {len(targets)} archived malformed rows are valid under the fixed verifier.")
        return 0
    print("FAIL: at least one archived malformed row still fails CNF / semantic agreement.")
    return 2


def agreement(args: argparse.Namespace) -> int:
    mixture = {"sat": 0.5, "nae": 0.5, "exact1": 0.0}
    counts: Counter[str] = Counter()
    first_failure: dict[str, Any] | None = None
    for instance_idx in range(args.instances):
        instance = generate_instance(
            phase=args.phase,
            n=args.n,
            density=args.density,
            mixture=mixture,
            instance_idx=instance_idx,
        )
        sat, model, stats = solve_model(instance)
        if not sat:
            counts["unsat"] += 1
            continue
        assert model is not None
        counts["sat"] += 1
        cnf_ok = cnf_satisfied(instance, model)
        semantic_ok = instance.assignment_satisfies_semantics(model)
        if not cnf_ok or not semantic_ok:
            counts["agreement_failure"] += 1
            first_failure = {
                "instance_id": instance.instance_id,
                "cnf_satisfied": cnf_ok,
                "semantic_satisfied": semantic_ok,
                "stats": stats,
                "inspection": inspect_instance(instance),
            }
            break
        counts["agreement_ok"] += 1

    summary = {
        "instances_requested": args.instances,
        "n": args.n,
        "density": args.density,
        "mixture": mixture,
        "counts": dict(counts),
        "first_failure": first_failure,
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))
    return 0 if not first_failure else 2


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    reg = sub.add_parser("regression", help="Replay archived malformed rows.")
    reg.add_argument("--archive", default=DEFAULT_ARCHIVE)

    agr = sub.add_parser("agreement", help="Run SAT/NAE CNF-semantic agreement checks.")
    agr.add_argument("--instances", type=int, default=1000)
    agr.add_argument("--n", type=int, default=50)
    agr.add_argument("--density", type=float, default=2.5)
    agr.add_argument("--phase", default="agreement_test")

    args = parser.parse_args()
    if args.cmd == "regression":
        raise SystemExit(regression(args))
    if args.cmd == "agreement":
        raise SystemExit(agreement(args))
    raise AssertionError(args.cmd)


if __name__ == "__main__":
    main()
