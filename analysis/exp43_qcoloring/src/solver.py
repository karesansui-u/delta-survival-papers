#!/usr/bin/env python3
"""Optional PySAT solver wrapper for Exp43 q-coloring."""

from __future__ import annotations

import multiprocessing as mp
import platform
import queue
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Iterable

try:  # pragma: no cover
    from .cnf_encoder import decode_model_to_coloring, encode_instance, encode_q_coloring, verify_coloring
    from .generator import Edge, QColoringInstance
except ImportError:  # pragma: no cover
    from cnf_encoder import decode_model_to_coloring, encode_instance, encode_q_coloring, verify_coloring
    from generator import Edge, QColoringInstance


@dataclass(frozen=True)
class SolveResult:
    q_colorable: bool | None
    timeout: bool
    runtime_sec: float
    conflicts: int | None
    decisions: int | None
    propagations: int | None
    coloring_verified: bool | None
    status: str
    error: str | None
    solver: dict[str, Any]
    started_at: str
    ended_at: str

    def to_json(self) -> dict[str, Any]:
        return {
            "q_colorable": self.q_colorable,
            "timeout": self.timeout,
            "runtime_sec": self.runtime_sec,
            "conflicts": self.conflicts,
            "decisions": self.decisions,
            "propagations": self.propagations,
            "coloring_verified": self.coloring_verified,
            "status": self.status,
            "error": self.error,
            "solver": self.solver,
            "timestamp_start": self.started_at,
            "timestamp_end": self.ended_at,
        }


def pysat_available() -> bool:
    try:
        import pysat  # type: ignore  # noqa: F401

        return True
    except Exception:
        return False


def solver_environment(*, backend: str, timeout_sec: float) -> dict[str, Any]:
    try:
        import pysat  # type: ignore

        pysat_version = getattr(pysat, "__version__", "unknown")
    except Exception:
        pysat_version = None
    return {
        "backend": backend,
        "package": "python-sat",
        "pysat_version": pysat_version,
        "python_version": sys.version.split()[0],
        "platform": platform.platform(),
        "processor": platform.processor(),
        "timeout_sec": timeout_sec,
    }


def _solver_class(backend: str):
    from pysat.solvers import Glucose4, Minisat22  # type: ignore

    normalized = backend.lower()
    if normalized in {"minisat22", "minisat"}:
        return Minisat22
    if normalized in {"glucose4", "glucose"}:
        return Glucose4
    raise ValueError(f"unsupported backend: {backend}")


def _solve_worker(clauses: list[list[int]], backend: str, out: mp.Queue) -> None:
    try:
        solver_cls = _solver_class(backend)
        with solver_cls(bootstrap_with=clauses) as solver:
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


def solve_graph(
    *,
    n: int,
    q: int,
    edges: Iterable[Edge],
    timeout_sec: float = 120.0,
    backend: str = "minisat22",
) -> SolveResult:
    started_at = datetime.now(timezone.utc).isoformat()
    start = time.perf_counter()
    solver_meta = solver_environment(backend=backend, timeout_sec=timeout_sec)
    formula = encode_q_coloring(n=n, q=q, edges=edges)
    out: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(target=_solve_worker, args=(formula.as_lists(), backend, out))
    process.start()
    process.join(timeout=timeout_sec)
    runtime = time.perf_counter() - start

    if process.is_alive():
        process.terminate()
        process.join(timeout=2)
        return SolveResult(
            q_colorable=None,
            timeout=True,
            runtime_sec=runtime,
            conflicts=None,
            decisions=None,
            propagations=None,
            coloring_verified=None,
            status="TIMEOUT",
            error=None,
            solver=solver_meta,
            started_at=started_at,
            ended_at=datetime.now(timezone.utc).isoformat(),
        )

    try:
        payload = out.get_nowait()
    except queue.Empty:
        payload = {"error": f"solver process exited with code {process.exitcode} without payload"}

    if "error" in payload:
        return SolveResult(
            q_colorable=None,
            timeout=False,
            runtime_sec=runtime,
            conflicts=None,
            decisions=None,
            propagations=None,
            coloring_verified=None,
            status="ERROR",
            error=payload["error"],
            solver=solver_meta,
            started_at=started_at,
            ended_at=datetime.now(timezone.utc).isoformat(),
        )

    sat = bool(payload["sat"])
    verified = None
    status = "SAT" if sat else "UNSAT"
    error = None
    if sat:
        model = payload.get("model") or []
        coloring = decode_model_to_coloring(model, n=n, q=q)
        verified = coloring is not None and verify_coloring(n=n, q=q, edges=edges, coloring=coloring)
        if not verified:
            status = "MALFORMED_ENCODING"
            error = "SAT model failed independent q-coloring verification"

    return SolveResult(
        q_colorable=sat if status in {"SAT", "UNSAT"} else None,
        timeout=False,
        runtime_sec=runtime,
        conflicts=payload.get("conflicts"),
        decisions=payload.get("decisions"),
        propagations=payload.get("propagations"),
        coloring_verified=verified,
        status=status,
        error=error,
        solver=solver_meta,
        started_at=started_at,
        ended_at=datetime.now(timezone.utc).isoformat(),
    )


def solve_instance(instance: QColoringInstance, *, timeout_sec: float = 120.0, backend: str = "minisat22") -> SolveResult:
    return solve_graph(n=instance.n, q=instance.q, edges=instance.edges, timeout_sec=timeout_sec, backend=backend)
