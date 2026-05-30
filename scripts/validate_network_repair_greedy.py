#!/usr/bin/env python3
"""Compare greedy repair-cost estimates against exact search on small graphs.

The ensemble simulation uses a greedy estimate for `minRepairCostToTarget`.
That is acceptable for a visual/mechanistic demo, but it should be sanity
checked. This script runs small random graphs where exact search over restored
removed-edge subsets is still feasible, then reports how often greedy matches
the exact minimum.
"""

from __future__ import annotations

import csv
import itertools
import math
import random
from collections import deque
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data" / "simulations" if (ROOT / "data" / "simulations").exists() else ROOT / "data"
OUT_PATH = DATA_DIR / "network_repair_greedy_validation.csv"

NODES = 18
SEEDS = tuple(range(30))
REMOVED_COUNTS = (3, 4, 5, 6, 7, 8)
TARGET_GIANT_SIZE = math.ceil(0.72 * NODES)
MAX_EXACT_K = 8

Edge = tuple[int, int]


@dataclass(frozen=True)
class ValidationRow:
    seed: int
    removed_count: int
    active_giant_size: int
    target_giant_size: int
    greedy_cost: int | None
    exact_cost: int | None
    greedy_matches_exact: bool
    greedy_over_exact: int | None


def norm_edge(a: int, b: int) -> Edge:
    return (a, b) if a < b else (b, a)


def connected_er_graph(rng: random.Random) -> tuple[Edge, ...]:
    edges: set[Edge] = {norm_edge(i, i + 1) for i in range(NODES - 1)}
    for i in range(NODES):
        for j in range(i + 1, NODES):
            if rng.random() < 0.16:
                edges.add((i, j))
    return tuple(sorted(edges))


def adjacency(edges: tuple[Edge, ...]) -> list[list[int]]:
    adj: list[list[int]] = [[] for _ in range(NODES)]
    for a, b in edges:
        adj[a].append(b)
        adj[b].append(a)
    return adj


def giant_size(edges: tuple[Edge, ...]) -> int:
    adj = adjacency(edges)
    seen = [False] * NODES
    best = 0

    for start in range(NODES):
        if seen[start]:
            continue
        seen[start] = True
        q: deque[int] = deque([start])
        size = 0
        while q:
            node = q.popleft()
            size += 1
            for nxt in adj[node]:
                if not seen[nxt]:
                    seen[nxt] = True
                    q.append(nxt)
        best = max(best, size)

    return best


def greedy_repair_cost(
    active_edges: tuple[Edge, ...],
    removed_edges: tuple[Edge, ...],
    target_size: int,
) -> int | None:
    current = set(active_edges)
    candidates = set(removed_edges)
    if giant_size(tuple(sorted(current))) >= target_size:
        return 0

    cost = 0
    while candidates:
        base_giant = giant_size(tuple(sorted(current)))
        best_edge: Edge | None = None
        best_giant = base_giant

        for edge in sorted(candidates):
            candidate_giant = giant_size(tuple(sorted(current | {edge})))
            if candidate_giant > best_giant:
                best_giant = candidate_giant
                best_edge = edge

        if best_edge is None:
            return None

        current.add(best_edge)
        candidates.remove(best_edge)
        cost += 1
        if best_giant >= target_size:
            return cost

    return None


def exact_repair_cost(
    active_edges: tuple[Edge, ...],
    removed_edges: tuple[Edge, ...],
    target_size: int,
) -> int | None:
    if giant_size(active_edges) >= target_size:
        return 0

    active_set = set(active_edges)
    max_k = min(MAX_EXACT_K, len(removed_edges))
    for k in range(1, max_k + 1):
        for subset in itertools.combinations(removed_edges, k):
            candidate = tuple(sorted(active_set | set(subset)))
            if giant_size(candidate) >= target_size:
                return k
    return None


def run_validation() -> list[ValidationRow]:
    rows: list[ValidationRow] = []
    for seed in SEEDS:
        rng = random.Random(seed)
        initial_edges = connected_er_graph(rng)
        shuffled = list(initial_edges)
        rng.shuffle(shuffled)

        for removed_count in REMOVED_COUNTS:
            removed = tuple(sorted(shuffled[:removed_count]))
            removed_set = set(removed)
            active = tuple(edge for edge in initial_edges if edge not in removed_set)
            greedy = greedy_repair_cost(active, removed, TARGET_GIANT_SIZE)
            exact = exact_repair_cost(active, removed, TARGET_GIANT_SIZE)
            over = None if greedy is None or exact is None else greedy - exact
            rows.append(
                ValidationRow(
                    seed=seed,
                    removed_count=removed_count,
                    active_giant_size=giant_size(active),
                    target_giant_size=TARGET_GIANT_SIZE,
                    greedy_cost=greedy,
                    exact_cost=exact,
                    greedy_matches_exact=greedy == exact,
                    greedy_over_exact=over,
                )
            )
    return rows


def write_csv(rows: list[ValidationRow], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(ValidationRow.__annotations__.keys()))
        writer.writeheader()
        for row in rows:
            writer.writerow(row.__dict__)


def main() -> None:
    rows = run_validation()
    write_csv(rows, OUT_PATH)
    comparable = [row for row in rows if row.greedy_cost is not None and row.exact_cost is not None]
    matches = sum(row.greedy_matches_exact for row in comparable)
    worst_over = max((row.greedy_over_exact or 0 for row in comparable), default=0)
    print(f"wrote {OUT_PATH.relative_to(ROOT)}")
    print(f"comparable cases: {len(comparable)}")
    print(f"greedy exact matches: {matches}/{len(comparable)}")
    print(f"worst greedy over exact: {worst_over}")


if __name__ == "__main__":
    main()
