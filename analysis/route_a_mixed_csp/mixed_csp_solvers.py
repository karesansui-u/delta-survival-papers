#!/usr/bin/env python3
"""Solver wrappers for the Mixed-CSP Route A experiment."""

from __future__ import annotations

import multiprocessing as mp
import platform
import queue
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from typing import Any

from mixed_csp_generator import MixedCSPInstance


@dataclass(frozen=True)
class SolveResult:
    sat_feasible: bool | None
    timeout: bool
    runtime_sec: float
    conflicts: int | None
    decisions: int | None
    propagations: int | None
    assignment_verified: bool | None
    status: str
    error: str | None
    solver: dict[str, Any]

    def to_json(self) -> dict[str, Any]:
        return {
            "solver": self.solver,
            "sat_feasible": self.sat_feasible,
            "timeout": self.timeout,
            "runtime_sec": self.runtime_sec,
            "conflicts": self.conflicts,
            "decisions": self.decisions,
            "propagations": self.propagations,
            "assignment_verified": self.assignment_verified,
            "status": self.status,
            "error": self.error,
        }


def solver_environment(timeout_sec: float) -> dict[str, Any]:
    try:
        import pysat  # type: ignore

        pysat_version = getattr(pysat, "__version__", "unknown")
    except Exception:
        pysat_version = None
    return {
        "name": "minisat22",
        "backend": "python-sat",
        "pysat_version": pysat_version,
        "python_version": sys.version.split()[0],
        "platform": platform.platform(),
        "processor": platform.processor(),
        "timeout_sec": timeout_sec,
    }


def _solve_worker(clauses: list[list[int]], n: int, out: mp.Queue) -> None:
    try:
        from pysat.solvers import Minisat22  # type: ignore

        with Minisat22(bootstrap_with=clauses) as solver:
            sat = bool(solver.solve())
            model = solver.get_model() if sat else None
            stats = solver.accum_stats() or {}
        out.put(
            {
                "sat": sat,
                "model": model,
                "conflicts": stats.get("conflicts"),
                "decisions": stats.get("decisions"),
                "propagations": stats.get("propagations"),
            }
        )
    except Exception as exc:
        out.put({"error": f"{type(exc).__name__}: {exc}"})


def solve_with_minisat(instance: MixedCSPInstance, timeout_sec: float = 30.0) -> SolveResult:
    """Solve an instance with PySAT Minisat22 under an external wall-clock timeout."""

    start = time.perf_counter()
    solver_meta = solver_environment(timeout_sec)
    clauses = instance.cnf_clauses
    out: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(target=_solve_worker, args=(clauses, instance.n, out))
    process.start()
    process.join(timeout=timeout_sec)
    runtime = time.perf_counter() - start

    if process.is_alive():
        process.terminate()
        process.join(timeout=2)
        return SolveResult(
            sat_feasible=None,
            timeout=True,
            runtime_sec=runtime,
            conflicts=None,
            decisions=None,
            propagations=None,
            assignment_verified=None,
            status="timeout",
            error=None,
            solver=solver_meta,
        )

    try:
        payload = out.get_nowait()
    except queue.Empty:
        payload = {"error": f"solver process exited with code {process.exitcode} without payload"}

    if "error" in payload:
        return SolveResult(
            sat_feasible=None,
            timeout=False,
            runtime_sec=runtime,
            conflicts=None,
            decisions=None,
            propagations=None,
            assignment_verified=None,
            status="solver_error",
            error=payload["error"],
            solver=solver_meta,
        )

    sat = bool(payload["sat"])
    assignment_verified = None
    status = "succeeded"
    error = None
    if sat:
        model = payload.get("model") or []
        assignment_verified = instance.assignment_satisfies_semantics(model)
        if not assignment_verified:
            status = "malformed_encoding"
            error = "SAT assignment failed semantic verification"

    return SolveResult(
        sat_feasible=sat if status == "succeeded" else None,
        timeout=False,
        runtime_sec=runtime,
        conflicts=payload.get("conflicts"),
        decisions=payload.get("decisions"),
        propagations=payload.get("propagations"),
        assignment_verified=assignment_verified,
        status=status,
        error=error,
        solver=solver_meta | {"started_at": datetime.now().isoformat()},
    )
