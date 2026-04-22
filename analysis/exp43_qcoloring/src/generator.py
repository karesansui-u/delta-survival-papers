#!/usr/bin/env python3
"""Deterministic graph generation for Exp43 q-coloring."""

from __future__ import annotations

import hashlib
import json
import math
import random
from dataclasses import dataclass
from typing import Any, Iterable

EXPERIMENT_ID = "exp43_qcoloring"
VERSION = "0.1.0-draft"

Edge = tuple[int, int]


def ell_q(q: int) -> float:
    if q <= 1:
        raise ValueError(f"q must be > 1, got {q}")
    return math.log(q / (q - 1))


def edge_count_from_rho(*, q: int, n: int, rho_fm: float) -> int:
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    if rho_fm < 0:
        raise ValueError(f"rho_fm must be nonnegative, got {rho_fm}")
    return int(round(rho_fm * n * math.log(q) / ell_q(q)))


def max_edges(n: int) -> int:
    return n * (n - 1) // 2


def canonical_edges(edges: Iterable[Edge]) -> tuple[Edge, ...]:
    normalized = []
    for u, v in edges:
        if u == v:
            raise ValueError(f"self-loop is not allowed: {(u, v)}")
        a, b = (u, v) if u < v else (v, u)
        normalized.append((a, b))
    canonical = tuple(sorted(normalized))
    if len(set(canonical)) != len(canonical):
        raise ValueError("duplicate edges are not allowed")
    return canonical


def serialize_edges(edges: Iterable[Edge]) -> str:
    return "".join(f"{u},{v}\n" for u, v in canonical_edges(edges))


def edge_list_hash(edges: Iterable[Edge]) -> str:
    return hashlib.sha256(serialize_edges(edges).encode("utf-8")).hexdigest()


def seed_digest(*, phase: str, q: int, n: int, rho_fm: float, instance_idx: int) -> str:
    key = json.dumps(
        {
            "experiment": EXPERIMENT_ID,
            "version": VERSION,
            "phase": phase,
            "q": q,
            "n": n,
            "rho_fm": rho_fm,
            "instance_idx": instance_idx,
        },
        sort_keys=True,
    )
    return hashlib.sha256(key.encode("utf-8")).hexdigest()


def seed_int_from_digest(digest: str) -> int:
    return int(digest[:16], 16)


@dataclass(frozen=True)
class QColoringInstance:
    experiment: str
    version: str
    phase: str
    instance_id: str
    instance_seed: str
    instance_seed_int: int
    q: int
    n: int
    rho_fm: float
    instance_idx: int
    m: int
    edges: tuple[Edge, ...]

    @property
    def edge_list_hash(self) -> str:
        return edge_list_hash(self.edges)

    @property
    def edge_density(self) -> float:
        return self.m / self.n

    @property
    def avg_degree(self) -> float:
        return 2 * self.m / self.n

    @property
    def ell_q(self) -> float:
        return ell_q(self.q)

    @property
    def L(self) -> float:
        return self.m * self.ell_q

    @property
    def log_state(self) -> float:
        return self.n * math.log(self.q)

    @property
    def first_moment_log_count(self) -> float:
        return self.log_state - self.L

    @property
    def rho_fm_actual(self) -> float:
        return self.L / self.log_state

    @property
    def cnf_variable_count(self) -> int:
        return self.n * self.q

    @property
    def cnf_clause_count(self) -> int:
        return int(self.n * (1 + self.q * (self.q - 1) / 2) + self.m * self.q)

    def metadata(self) -> dict[str, Any]:
        return {
            "experiment": self.experiment,
            "version": self.version,
            "phase": self.phase,
            "instance_id": self.instance_id,
            "instance_seed": self.instance_seed,
            "instance_seed_int": self.instance_seed_int,
            "q": self.q,
            "n": self.n,
            "rho_fm": self.rho_fm,
            "rho_fm_actual": self.rho_fm_actual,
            "instance_idx": self.instance_idx,
            "m": self.m,
            "edge_density": self.edge_density,
            "avg_degree": self.avg_degree,
            "ell_q": self.ell_q,
            "L": self.L,
            "log_state": self.log_state,
            "first_moment_log_count": self.first_moment_log_count,
            "edge_list_hash": self.edge_list_hash,
            "cnf_variable_count": self.cnf_variable_count,
            "cnf_clause_count": self.cnf_clause_count,
        }


def all_possible_edges(n: int) -> list[Edge]:
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    return [(u, v) for u in range(n) for v in range(u + 1, n)]


def generate_instance(*, phase: str, q: int, n: int, rho_fm: float, instance_idx: int) -> QColoringInstance:
    m = edge_count_from_rho(q=q, n=n, rho_fm=rho_fm)
    if m > max_edges(n):
        raise ValueError(f"requested m={m} exceeds complete graph edge count {max_edges(n)}")
    digest = seed_digest(phase=phase, q=q, n=n, rho_fm=rho_fm, instance_idx=instance_idx)
    rng = random.Random(seed_int_from_digest(digest))
    edges = canonical_edges(rng.sample(all_possible_edges(n), m))
    instance_id = f"{phase}__q{q}__n{n}__rho{rho_fm:.2f}__i{instance_idx:05d}"
    return QColoringInstance(
        experiment=EXPERIMENT_ID,
        version=VERSION,
        phase=phase,
        instance_id=instance_id,
        instance_seed=digest,
        instance_seed_int=seed_int_from_digest(digest),
        q=q,
        n=n,
        rho_fm=rho_fm,
        instance_idx=instance_idx,
        m=m,
        edges=edges,
    )
