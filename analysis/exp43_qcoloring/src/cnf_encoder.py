#!/usr/bin/env python3
"""CNF encoding and independent verification for q-coloring."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable

try:  # pragma: no cover - exercised by direct script use
    from .generator import Edge, QColoringInstance, canonical_edges
except ImportError:  # pragma: no cover
    from generator import Edge, QColoringInstance, canonical_edges


@dataclass(frozen=True)
class CNFFormula:
    num_vars: int
    clauses: tuple[tuple[int, ...], ...]

    @property
    def num_clauses(self) -> int:
        return len(self.clauses)

    def as_lists(self) -> list[list[int]]:
        return [list(clause) for clause in self.clauses]


def var_id(vertex: int, color: int, q: int) -> int:
    if vertex < 0:
        raise ValueError(f"vertex must be >= 0, got {vertex}")
    if not 0 <= color < q:
        raise ValueError(f"color must be in [0, q), got color={color}, q={q}")
    return vertex * q + color + 1


def encode_q_coloring(*, n: int, q: int, edges: Iterable[Edge]) -> CNFFormula:
    canonical = canonical_edges(edges)
    clauses: list[tuple[int, ...]] = []

    for vertex in range(n):
        clauses.append(tuple(var_id(vertex, color, q) for color in range(q)))
        for c1 in range(q):
            for c2 in range(c1 + 1, q):
                clauses.append((-var_id(vertex, c1, q), -var_id(vertex, c2, q)))

    for u, v in canonical:
        if not (0 <= u < n and 0 <= v < n):
            raise ValueError(f"edge {(u, v)} outside vertex range n={n}")
        for color in range(q):
            clauses.append((-var_id(u, color, q), -var_id(v, color, q)))

    return CNFFormula(num_vars=n * q, clauses=tuple(clauses))


def encode_instance(instance: QColoringInstance) -> CNFFormula:
    return encode_q_coloring(n=instance.n, q=instance.q, edges=instance.edges)


def decode_model_to_coloring(model: Iterable[int], *, n: int, q: int) -> tuple[int, ...] | None:
    positive = {lit for lit in model if lit > 0}
    colors: list[int] = []
    for vertex in range(n):
        active = [color for color in range(q) if var_id(vertex, color, q) in positive]
        if len(active) != 1:
            return None
        colors.append(active[0])
    return tuple(colors)


def verify_coloring(*, n: int, q: int, edges: Iterable[Edge], coloring: Iterable[int]) -> bool:
    colors = tuple(coloring)
    if len(colors) != n:
        return False
    if any(color < 0 or color >= q for color in colors):
        return False
    return all(colors[u] != colors[v] for u, v in canonical_edges(edges))


def model_satisfies_cnf(model: Iterable[int], formula: CNFFormula) -> bool:
    assignment = {abs(lit): lit > 0 for lit in model if lit != 0}
    for clause in formula.clauses:
        if not any(assignment.get(abs(lit), False) == (lit > 0) for lit in clause):
            return False
    return True


def complete_graph(n: int) -> tuple[Edge, ...]:
    return tuple((u, v) for u in range(n) for v in range(u + 1, n))


def cycle_graph(n: int) -> tuple[Edge, ...]:
    if n < 3:
        raise ValueError("cycle graph requires n >= 3")
    return tuple((i, (i + 1) % n) for i in range(n))


def brute_force_q_colorable(*, n: int, q: int, edges: Iterable[Edge]) -> tuple[bool, tuple[int, ...] | None]:
    for colors in product(range(q), repeat=n):
        if verify_coloring(n=n, q=q, edges=edges, coloring=colors):
            return True, tuple(colors)
    return False, None
