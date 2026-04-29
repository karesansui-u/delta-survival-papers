#!/usr/bin/env python3
"""Simulator v0 for the M-profile flow-network testbed.

This is a dry-run simulator, not a primary validation runner.  It is designed to
exercise the data schema, allocation-grid handling, held-out allocation tags,
max-flow readouts, and degeneracy flags before freezing a primary manifest.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import os
import random
from collections import Counter, deque
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


HERE = Path(__file__).resolve().parents[1]
DEFAULT_OUT_DIR = HERE / "dry_runs" / "v0_smoke"
DEFAULT_PRIMARY_OUT_DIR = HERE / "primary_runs" / "primary_v1"

GRAPH_FAMILIES = ("layered_dag", "grid", "series_parallel", "random_geometric")
DAMAGE_FAMILIES = (
    "random_attrition",
    "bottleneck_attack",
    "clustered_failure",
    "demand_shock",
    "repairable_wear",
    "scalar_only_control",
)

DEFAULT_ALLOCATIONS = (
    (10, 0, 0),
    (8, 2, 0),
    (8, 0, 2),
    (6, 4, 0),
    (6, 2, 2),
    (4, 3, 3),
    (0, 8, 2),
    (0, 2, 8),
    (0, 10, 0),
    (0, 0, 10),
    (3, 4, 3),
)
DEFAULT_HELD_OUT_ALLOCATIONS = ((3, 4, 3),)


@dataclass
class Edge:
    u: int
    v: int
    capacity: int
    target_capacity: int
    active: bool
    kind: str
    layer: int


@dataclass
class Graph:
    n: int
    source: int
    sink: int
    edges: list[Edge]
    bypass_candidates: list[Edge]
    node_layers: list[int]


def stable_hash(obj: Any) -> str:
    payload = json.dumps(obj, ensure_ascii=True, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:16]


def edge_snapshot(graph: Graph) -> list[dict[str, Any]]:
    return [
        {
            "u": e.u,
            "v": e.v,
            "capacity": e.capacity,
            "target_capacity": e.target_capacity,
            "active": e.active,
            "kind": e.kind,
            "layer": e.layer,
        }
        for e in graph.edges
    ]


def graph_hash(graph: Graph) -> str:
    return stable_hash(
        {
            "n": graph.n,
            "source": graph.source,
            "sink": graph.sink,
            "edges": edge_snapshot(graph),
        }
    )


def active_edge_indices(graph: Graph) -> list[int]:
    return [
        idx
        for idx, edge in enumerate(graph.edges)
        if edge.active and edge.capacity > 0 and edge.u != edge.v
    ]


def add_edge(
    edges: list[Edge],
    seen: set[tuple[int, int]],
    u: int,
    v: int,
    capacity: int,
    *,
    kind: str,
    layer: int,
) -> None:
    if u == v or (u, v) in seen:
        return
    seen.add((u, v))
    edges.append(
        Edge(
            u=u,
            v=v,
            capacity=capacity,
            target_capacity=capacity,
            active=True,
            kind=kind,
            layer=layer,
        )
    )


def make_bypass_candidates(
    *,
    n: int,
    source: int,
    sink: int,
    node_layers: list[int],
    existing: set[tuple[int, int]],
    rng: random.Random,
    max_candidates: int,
) -> list[Edge]:
    candidates: list[Edge] = []
    pairs: list[tuple[int, int]] = []
    for u in range(n):
        for v in range(n):
            if u == v or (u, v) in existing or u == sink or v == source:
                continue
            if node_layers[v] - node_layers[u] >= 2:
                pairs.append((u, v))
    rng.shuffle(pairs)
    for u, v in pairs[:max_candidates]:
        candidates.append(
            Edge(
                u=u,
                v=v,
                capacity=0,
                target_capacity=1,
                active=False,
                kind="bypass",
                layer=node_layers[u],
            )
        )
    return candidates


def generate_layered_dag(
    rng: random.Random,
    *,
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
) -> Graph:
    source = 0
    layers: list[list[int]] = []
    node_layers = [0]
    next_node = 1
    for layer in range(1, n_layers + 1):
        current = list(range(next_node, next_node + width))
        layers.append(current)
        node_layers.extend([layer] * width)
        next_node += width
    sink = next_node
    node_layers.append(n_layers + 1)
    edges: list[Edge] = []
    seen: set[tuple[int, int]] = set()

    for j, v in enumerate(layers[0]):
        add_edge(edges, seen, source, v, rng.randint(2, capacity_max), kind="base", layer=0)
        for layer_idx in range(len(layers) - 1):
            u = layers[layer_idx][j % width]
            w = layers[layer_idx + 1][j % width]
            add_edge(
                edges,
                seen,
                u,
                w,
                rng.randint(1, capacity_max),
                kind="base",
                layer=layer_idx + 1,
            )
        add_edge(edges, seen, layers[-1][j], sink, rng.randint(2, capacity_max), kind="base", layer=n_layers)

    for prev_layer, next_layer in zip([[source]] + layers, layers + [[sink]]):
        for u in prev_layer:
            for v in next_layer:
                if (u, v) not in seen and rng.random() < edge_density:
                    add_edge(
                        edges,
                        seen,
                        u,
                        v,
                        rng.randint(1, capacity_max),
                        kind="base",
                        layer=node_layers[u],
                    )

    candidates = make_bypass_candidates(
        n=sink + 1,
        source=source,
        sink=sink,
        node_layers=node_layers,
        existing=seen,
        rng=rng,
        max_candidates=4 * width * n_layers,
    )
    return Graph(sink + 1, source, sink, edges, candidates, node_layers)


def generate_grid(
    rng: random.Random,
    *,
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
) -> Graph:
    source = 0
    offset = 1
    sink = offset + n_layers * width
    node_layers = [0] + [1 + col for col in range(n_layers) for _row in range(width)] + [n_layers + 1]

    def node(col: int, row: int) -> int:
        return offset + col * width + row

    edges: list[Edge] = []
    seen: set[tuple[int, int]] = set()
    for row in range(width):
        add_edge(edges, seen, source, node(0, row), rng.randint(1, capacity_max), kind="base", layer=0)
        add_edge(edges, seen, node(n_layers - 1, row), sink, rng.randint(1, capacity_max), kind="base", layer=n_layers)
    for col in range(n_layers - 1):
        for row in range(width):
            for delta in (-1, 0, 1):
                nr = row + delta
                if 0 <= nr < width and (delta == 0 or rng.random() < edge_density):
                    add_edge(
                        edges,
                        seen,
                        node(col, row),
                        node(col + 1, nr),
                        rng.randint(1, capacity_max),
                        kind="base",
                        layer=col + 1,
                    )
    candidates = make_bypass_candidates(
        n=sink + 1,
        source=source,
        sink=sink,
        node_layers=node_layers,
        existing=seen,
        rng=rng,
        max_candidates=4 * width * n_layers,
    )
    return Graph(sink + 1, source, sink, edges, candidates, node_layers)


def generate_series_parallel(
    rng: random.Random,
    *,
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
) -> Graph:
    source = 0
    layers: list[list[int]] = []
    node_layers = [0]
    next_node = 1
    for layer in range(1, n_layers + 1):
        layer_width = 1 if layer % 3 == 0 else max(2, width)
        current = list(range(next_node, next_node + layer_width))
        layers.append(current)
        node_layers.extend([layer] * layer_width)
        next_node += layer_width
    sink = next_node
    node_layers.append(n_layers + 1)
    edges: list[Edge] = []
    seen: set[tuple[int, int]] = set()
    for prev_layer, next_layer in zip([[source]] + layers, layers + [[sink]]):
        for u in prev_layer:
            for v in next_layer:
                if rng.random() < max(edge_density, 0.45) or len(prev_layer) == 1 or len(next_layer) == 1:
                    add_edge(
                        edges,
                        seen,
                        u,
                        v,
                        rng.randint(1, capacity_max),
                        kind="base",
                        layer=node_layers[u],
                    )
    candidates = make_bypass_candidates(
        n=sink + 1,
        source=source,
        sink=sink,
        node_layers=node_layers,
        existing=seen,
        rng=rng,
        max_candidates=4 * width * n_layers,
    )
    return Graph(sink + 1, source, sink, edges, candidates, node_layers)


def generate_random_geometric(
    rng: random.Random,
    *,
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
) -> Graph:
    inner_n = max(8, n_layers * width)
    points = [(rng.random(), rng.random()) for _ in range(inner_n)]
    order = sorted(range(inner_n), key=lambda i: points[i][0])
    rank = {old: i + 1 for i, old in enumerate(order)}
    source = 0
    sink = inner_n + 1
    node_layers = [0] + [1 + int(points[i][0] * n_layers) for i in range(inner_n)] + [n_layers + 1]
    edges: list[Edge] = []
    seen: set[tuple[int, int]] = set()

    for idx in range(len(order) - 1):
        u = rank[order[idx]]
        v = rank[order[idx + 1]]
        add_edge(edges, seen, u, v, capacity_max, kind="base", layer=node_layers[u])
    for old in order[: max(2, width)]:
        add_edge(edges, seen, source, rank[old], rng.randint(max(2, capacity_max // 2), capacity_max), kind="base", layer=0)
    for old in order[-max(2, width) :]:
        add_edge(
            edges,
            seen,
            rank[old],
            sink,
            rng.randint(max(2, capacity_max // 2), capacity_max),
            kind="base",
            layer=node_layers[rank[old]],
        )

    radius = 0.25 + 0.25 * edge_density
    for i in range(inner_n):
        for j in range(inner_n):
            if points[j][0] <= points[i][0]:
                continue
            dist = math.dist(points[i], points[j])
            if dist <= radius and rng.random() < edge_density:
                add_edge(
                    edges,
                    seen,
                    rank[i],
                    rank[j],
                    rng.randint(1, capacity_max),
                    kind="base",
                    layer=node_layers[rank[i]],
                )
    candidates = make_bypass_candidates(
        n=sink + 1,
        source=source,
        sink=sink,
        node_layers=node_layers,
        existing=seen,
        rng=rng,
        max_candidates=4 * width * n_layers,
    )
    return Graph(sink + 1, source, sink, edges, candidates, node_layers)


def generate_graph(
    family: str,
    rng: random.Random,
    *,
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
) -> Graph:
    kwargs = {
        "rng": rng,
        "n_layers": n_layers,
        "width": width,
        "edge_density": edge_density,
        "capacity_max": capacity_max,
    }
    if family == "layered_dag":
        return generate_layered_dag(**kwargs)
    if family == "grid":
        return generate_grid(**kwargs)
    if family == "series_parallel":
        return generate_series_parallel(**kwargs)
    if family == "random_geometric":
        return generate_random_geometric(**kwargs)
    raise ValueError(f"unknown graph family: {family}")


def max_flow(graph: Graph) -> tuple[int, dict[int, int], list[int]]:
    residual: list[list[dict[str, int]]] = [[] for _ in range(graph.n)]
    edge_positions: list[tuple[int, int] | None] = [None] * len(graph.edges)

    def add_residual(u: int, v: int, cap: int, edge_idx: int) -> None:
        fwd = {"to": v, "rev": len(residual[v]), "cap": cap, "edge_idx": edge_idx}
        rev = {"to": u, "rev": len(residual[u]), "cap": 0, "edge_idx": edge_idx}
        residual[u].append(fwd)
        residual[v].append(rev)
        edge_positions[edge_idx] = (u, len(residual[u]) - 1)

    for idx in active_edge_indices(graph):
        edge = graph.edges[idx]
        add_residual(edge.u, edge.v, edge.capacity, idx)

    total = 0
    while True:
        parent: list[tuple[int, int] | None] = [None] * graph.n
        q: deque[int] = deque([graph.source])
        parent[graph.source] = (-1, -1)
        while q and parent[graph.sink] is None:
            u = q.popleft()
            for i, edge in enumerate(residual[u]):
                if edge["cap"] > 0 and parent[edge["to"]] is None:
                    parent[edge["to"]] = (u, i)
                    q.append(edge["to"])
                    if edge["to"] == graph.sink:
                        break
        if parent[graph.sink] is None:
            break
        aug = 10**9
        v = graph.sink
        while v != graph.source:
            u, i = parent[v]  # type: ignore[misc]
            aug = min(aug, residual[u][i]["cap"])
            v = u
        v = graph.sink
        while v != graph.source:
            u, i = parent[v]  # type: ignore[misc]
            rev = residual[u][i]["rev"]
            residual[u][i]["cap"] -= aug
            residual[v][rev]["cap"] += aug
            v = u
        total += aug

    flows: dict[int, int] = {}
    for idx, pos in enumerate(edge_positions):
        if pos is None:
            continue
        u, i = pos
        edge = graph.edges[idx]
        flows[idx] = edge.capacity - residual[u][i]["cap"]

    reachable = [False] * graph.n
    q = deque([graph.source])
    reachable[graph.source] = True
    while q:
        u = q.popleft()
        for edge in residual[u]:
            if edge["cap"] > 0 and not reachable[edge["to"]]:
                reachable[edge["to"]] = True
                q.append(edge["to"])
    cut = [
        idx
        for idx in active_edge_indices(graph)
        if reachable[graph.edges[idx].u] and not reachable[graph.edges[idx].v]
    ]
    return total, flows, cut


def spend_on_edges(graph: Graph, edge_indices: list[int], budget: int) -> int:
    spent = 0
    if budget <= 0 or not edge_indices:
        return spent
    cursor = 0
    while spent < budget and edge_indices:
        idx = edge_indices[cursor % len(edge_indices)]
        graph.edges[idx].capacity += 1
        graph.edges[idx].target_capacity += 1
        spent += 1
        cursor += 1
    return spent


def apply_buffer(graph: Graph, budget: int) -> int:
    _value, _flows, cut = max_flow(graph)
    if not cut:
        cut = sorted(active_edge_indices(graph), key=lambda idx: graph.edges[idx].capacity)[: max(1, budget)]
    return spend_on_edges(graph, cut, budget)


def activate_reconfiguration(graph: Graph, budget: int) -> tuple[int, int]:
    spent = 0
    active_count = 0
    while spent < budget and graph.bypass_candidates:
        _value, _flows, cut = max_flow(graph)
        cut_u = {graph.edges[idx].u for idx in cut}
        cut_v = {graph.edges[idx].v for idx in cut}
        chosen_pos = None
        for pos, candidate in enumerate(graph.bypass_candidates):
            if candidate.u in cut_u or candidate.v in cut_v:
                chosen_pos = pos
                break
        if chosen_pos is None:
            chosen_pos = 0
        candidate = graph.bypass_candidates.pop(chosen_pos)
        candidate.capacity = 1
        candidate.target_capacity = 1
        candidate.active = True
        graph.edges.append(candidate)
        spent += 1
        active_count += 1
    return spent, active_count


def apply_damage(
    graph: Graph,
    family: str,
    rng: random.Random,
    *,
    intensity: float,
    previous_flows: dict[int, int],
) -> list[int]:
    damaged: list[int] = []
    active = active_edge_indices(graph)
    if not active:
        return damaged

    def lose(idx: int, amount: int = 1) -> None:
        if graph.edges[idx].capacity <= 0:
            return
        graph.edges[idx].capacity = max(0, graph.edges[idx].capacity - amount)
        damaged.append(idx)

    if family == "random_attrition":
        p = min(0.9, max(0.0, intensity))
        for idx in active:
            if rng.random() < p:
                lose(idx)
    elif family == "bottleneck_attack":
        _value, _flows, cut = max_flow(graph)
        targets = cut or active
        rng.shuffle(targets)
        count = max(1, round(max(intensity, 0.05) * len(targets)))
        for idx in targets[:count]:
            lose(idx)
    elif family == "clustered_failure":
        layers = [graph.edges[idx].layer for idx in active]
        layer = rng.choice(layers)
        targets = [idx for idx in active if abs(graph.edges[idx].layer - layer) <= 1]
        rng.shuffle(targets)
        count = max(1, round(max(intensity, 0.05) * len(targets)))
        for idx in targets[:count]:
            lose(idx)
    elif family == "demand_shock":
        return damaged
    elif family == "repairable_wear":
        used = [idx for idx, flow in previous_flows.items() if flow > 0 and idx in active]
        targets = used or active
        rng.shuffle(targets)
        count = max(1, round(max(intensity, 0.05) * len(targets)))
        for idx in targets[:count]:
            lose(idx)
    elif family == "scalar_only_control":
        p = min(0.25, max(0.0, intensity / 3.0))
        for idx in active:
            if rng.random() < p:
                lose(idx)
    else:
        raise ValueError(f"unknown damage family: {family}")
    return damaged


def apply_recovery(graph: Graph, damaged: list[int], budget_remaining: int) -> int:
    spent = 0
    candidates = sorted(set(damaged), key=lambda idx: graph.edges[idx].target_capacity - graph.edges[idx].capacity, reverse=True)
    while spent < budget_remaining:
        candidates = [
            idx
            for idx in candidates
            if graph.edges[idx].active and graph.edges[idx].capacity < graph.edges[idx].target_capacity
        ]
        if not candidates:
            break
        idx = candidates[0]
        graph.edges[idx].capacity += 1
        spent += 1
    return spent


def q_for_step(base_q: int, family: str, intensity: float, step: int, horizon: int) -> int:
    if family != "demand_shock":
        return base_q
    middle = horizon // 3 <= step < (2 * horizon) // 3
    if not middle:
        return base_q
    return base_q + max(1, round(base_q * max(0.05, intensity)))


def label_allocation(allocation: tuple[int, int, int]) -> str:
    b, r, c = allocation
    if max(allocation) - min(allocation) <= 1:
        return "balanced"
    if b >= r and b >= c:
        return "buffer_heavy"
    if r >= b and r >= c:
        return "recovery_heavy"
    return "reconfiguration_heavy"


def run_instance(
    *,
    seed: int,
    graph_family: str,
    damage_family: str,
    allocation: tuple[int, int, int],
    held_out_allocations: set[tuple[int, int, int]],
    n_layers: int,
    width: int,
    edge_density: float,
    capacity_max: int,
    required_flow_q: int,
    horizon: int,
    damage_intensity: float,
) -> dict[str, Any]:
    graph_seed = stable_hash({"seed": seed, "graph_family": graph_family})
    # Keep the damage stream fixed across allocations so intervention ranking
    # compares policies against the same stochastic environment.
    damage_seed = stable_hash({"seed": seed, "graph_family": graph_family, "damage_family": damage_family})
    graph_rng = random.Random(int(graph_seed, 16))
    damage_rng = random.Random(int(damage_seed, 16))
    graph = generate_graph(
        graph_family,
        graph_rng,
        n_layers=n_layers,
        width=width,
        edge_density=edge_density,
        capacity_max=capacity_max,
    )
    initial_graph_hash = graph_hash(graph)
    initial_max_flow, previous_flows, _cut = max_flow(graph)
    buffer_budget, recovery_budget, reconfiguration_budget = allocation
    buffer_spent = apply_buffer(graph, buffer_budget)
    reconfiguration_spent = 0
    active_bypass_edges = 0
    post_policy_max_flow, previous_flows, _cut = max_flow(graph)

    recovery_spent = 0
    q_values: list[int] = []
    max_flows: list[int] = []
    margins: list[int] = []
    collapse_time: int | None = None

    for step in range(horizon):
        damaged = apply_damage(
            graph,
            damage_family,
            damage_rng,
            intensity=damage_intensity,
            previous_flows=previous_flows,
        )
        recovery_spent += apply_recovery(graph, damaged, recovery_budget - recovery_spent)
        reconfig_spent_now, active_now = activate_reconfiguration(
            graph,
            reconfiguration_budget - reconfiguration_spent,
        )
        reconfiguration_spent += reconfig_spent_now
        active_bypass_edges += active_now
        q_t = q_for_step(required_flow_q, damage_family, damage_intensity, step, horizon)
        flow_t, previous_flows, _cut = max_flow(graph)
        margin_t = flow_t - q_t
        q_values.append(q_t)
        max_flows.append(flow_t)
        margins.append(margin_t)
        if collapse_time is None and margin_t < 0:
            collapse_time = step

    maintained_steps = sum(1 for margin in margins if margin >= 0)
    maintained_step_ratio = maintained_steps / horizon if horizon else 0.0
    maintained_flow_ratio = (
        sum(min(flow / max(q_value, 1), 1.0) for flow, q_value in zip(max_flows, q_values)) / horizon
        if horizon
        else 0.0
    )
    min_margin = min(margins) if margins else post_policy_max_flow - required_flow_q
    final_graph_hash = graph_hash(graph)
    flags: list[str] = []
    if initial_max_flow < required_flow_q:
        flags.append("initially_collapsed")
    if collapse_time == 0:
        flags.append("collapse_at_first_step")
    if collapse_time is None:
        flags.append("no_collapse")
    if min_margin > required_flow_q:
        flags.append("far_above_q")
    if allocation[1] > 0 and recovery_spent == 0:
        flags.append("recovery_unused")
    if allocation[2] > 0 and active_bypass_edges == 0:
        flags.append("reconfiguration_impossible")
    if not graph.bypass_candidates and active_bypass_edges == 0:
        flags.append("no_alternate_path")
    if post_policy_max_flow < required_flow_q:
        flags.append("post_policy_below_q")

    config = {
        "seed": seed,
        "graph_family": graph_family,
        "damage_family": damage_family,
        "allocation": allocation,
        "required_flow_Q": required_flow_q,
        "horizon_T": horizon,
        "damage_intensity": damage_intensity,
    }
    return {
        "config_hash": stable_hash(config),
        "graph_hash": initial_graph_hash,
        "damage_seed": damage_seed,
        "seed": seed,
        "graph_family": graph_family,
        "graph_split": "primary_heldout" if graph_family == "random_geometric" else "calibration",
        "damage_family": damage_family,
        "damage_split": "primary_heldout" if damage_family == "repairable_wear" else "calibration",
        "policy_anchor": label_allocation(allocation),
        "allocation_buffer": allocation[0],
        "allocation_recovery": allocation[1],
        "allocation_reconfiguration": allocation[2],
        "allocation_split": "primary_heldout" if allocation in held_out_allocations else "calibration",
        "total_energy_E": sum(allocation),
        "initial_max_flow": initial_max_flow,
        "post_policy_max_flow": post_policy_max_flow,
        "required_flow_Q": required_flow_q,
        "horizon_T": horizon,
        "damage_intensity": damage_intensity,
        "max_flow_series": json.dumps(max_flows, separators=(",", ":")),
        "q_series": json.dumps(q_values, separators=(",", ":")),
        "margin_series": json.dumps(margins, separators=(",", ":")),
        "collapse_time": "" if collapse_time is None else collapse_time,
        "maintained_step_ratio": maintained_step_ratio,
        "maintained_flow_ratio": maintained_flow_ratio,
        "minimum_margin": min_margin,
        "buffer_energy_spent": buffer_spent,
        "recovery_energy_spent": recovery_spent,
        "reconfiguration_energy_spent": reconfiguration_spent,
        "active_bypass_edges": active_bypass_edges,
        "degeneracy_flags": "|".join(sorted(flags)),
        "final_graph_hash": final_graph_hash,
    }


def parse_allocation(text: str) -> tuple[int, int, int]:
    parts = tuple(int(x) for x in text.split(","))
    if len(parts) != 3:
        raise argparse.ArgumentTypeError("allocation must be formatted as b,r,c")
    if min(parts) < 0:
        raise argparse.ArgumentTypeError("allocation values must be nonnegative")
    return parts


def summarize(rows: list[dict[str, Any]], *, status: str, non_claim: str) -> dict[str, Any]:
    flags = Counter()
    for row in rows:
        for flag in str(row["degeneracy_flags"]).split("|"):
            if flag:
                flags[flag] += 1
    by_family = Counter(row["graph_family"] for row in rows)
    by_damage = Counter(row["damage_family"] for row in rows)
    by_allocation_split = Counter(row["allocation_split"] for row in rows)
    collapse_rows = [row for row in rows if row["collapse_time"] != ""]
    return {
        "status": status,
        "run_count": len(rows),
        "graph_family_counts": dict(sorted(by_family.items())),
        "damage_family_counts": dict(sorted(by_damage.items())),
        "allocation_split_counts": dict(sorted(by_allocation_split.items())),
        "degeneracy_flag_counts": dict(sorted(flags.items())),
        "collapse_fraction": len(collapse_rows) / len(rows) if rows else 0.0,
        "mean_maintained_flow_ratio": (
            sum(float(row["maintained_flow_ratio"]) for row in rows) / len(rows) if rows else 0.0
        ),
        "schema_fields": list(rows[0].keys()) if rows else [],
        "non_claim": non_claim,
    }


def write_outputs(rows: list[dict[str, Any]], out_dir: Path, *, status: str, non_claim: str) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    runs_path = out_dir / "runs.csv"
    summary_path = out_dir / "summary.json"
    if rows:
        with runs_path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()), lineterminator="\n")
            writer.writeheader()
            writer.writerows(rows)
    summary = summarize(rows, status=status, non_claim=non_claim)
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def iter_plan(args: argparse.Namespace) -> Iterable[tuple[int, str, str, tuple[int, int, int]]]:
    graph_families = GRAPH_FAMILIES if args.full_grid else ("layered_dag", "grid", "random_geometric")
    damage_families = DAMAGE_FAMILIES if args.full_grid else (
        "random_attrition",
        "bottleneck_attack",
        "repairable_wear",
        "scalar_only_control",
    )
    allocations = args.allocation or list(DEFAULT_ALLOCATIONS)
    for seed in range(args.seed, args.seed + args.seeds):
        for graph_family in graph_families:
            for damage_family in damage_families:
                for allocation in allocations:
                    yield seed, graph_family, damage_family, allocation


def fail_if_outputs_exist(out_dir: Path, filenames: tuple[str, ...], *, allow_overwrite: bool) -> None:
    existing = [str(out_dir / name) for name in filenames if (out_dir / name).exists()]
    if existing and not allow_overwrite:
        raise SystemExit(
            "refusing to overwrite existing primary output(s): "
            + ", ".join(existing)
            + " (use --allow-overwrite only for explicitly labeled reruns)"
        )


def require_primary_confirmation(args: argparse.Namespace) -> None:
    if not getattr(args, "confirm_frozen_primary", False):
        raise SystemExit("primary-run requires --confirm-frozen-primary")
    if not os.environ.get("CONFIRM_M_FLOW_PRIMARY"):
        raise SystemExit("primary-run requires CONFIRM_M_FLOW_PRIMARY to be set")


def run_plan(args: argparse.Namespace, *, status: str, non_claim: str) -> None:
    held_out_allocations = set(args.held_out_allocation or DEFAULT_HELD_OUT_ALLOCATIONS)
    rows = [
        run_instance(
            seed=seed,
            graph_family=graph_family,
            damage_family=damage_family,
            allocation=allocation,
            held_out_allocations=held_out_allocations,
            n_layers=args.layers,
            width=args.width,
            edge_density=args.edge_density,
            capacity_max=args.capacity_max,
            required_flow_q=args.required_flow,
            horizon=args.horizon,
            damage_intensity=args.damage_intensity,
        )
        for seed, graph_family, damage_family, allocation in iter_plan(args)
    ]
    write_outputs(rows, args.out_dir, status=status, non_claim=non_claim)
    summary = summarize(rows, status=status, non_claim=non_claim)
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))
    print(f"wrote: {args.out_dir / 'runs.csv'}")
    print(f"wrote: {args.out_dir / 'summary.json'}")


def run_dry_run(args: argparse.Namespace) -> None:
    run_plan(
        args,
        status="dry_run_only",
        non_claim="schema smoke test only; not M-primary support",
    )


def run_primary_run(args: argparse.Namespace) -> None:
    require_primary_confirmation(args)
    args.full_grid = True
    fail_if_outputs_exist(
        args.out_dir,
        ("runs.csv", "summary.json"),
        allow_overwrite=args.allow_overwrite,
    )
    run_plan(
        args,
        status="primary_run_raw_uninterpreted",
        non_claim=(
            "raw primary simulator output only; support requires the frozen "
            "evaluator, degeneracy report, and support-rule decision"
        ),
    )


def add_run_arguments(parser: argparse.ArgumentParser, *, default_out_dir: Path, primary_defaults: bool) -> None:
    parser.add_argument("--out-dir", type=Path, default=default_out_dir)
    parser.add_argument("--seed", type=int, default=2000 if primary_defaults else 1000)
    parser.add_argument("--seeds", type=int, default=50 if primary_defaults else 1)
    parser.add_argument("--layers", type=int, default=4)
    parser.add_argument("--width", type=int, default=4)
    parser.add_argument("--edge-density", type=float, default=0.45)
    parser.add_argument("--capacity-max", type=int, default=4)
    parser.add_argument("--required-flow", type=int, default=4 if primary_defaults else 3)
    parser.add_argument("--horizon", type=int, default=8)
    parser.add_argument("--damage-intensity", type=float, default=0.34 if primary_defaults else 0.18)
    parser.add_argument("--allocation", type=parse_allocation, action="append")
    parser.add_argument("--held-out-allocation", type=parse_allocation, action="append")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)
    dry = sub.add_parser("dry-run", help="Run a schema smoke test.")
    add_run_arguments(dry, default_out_dir=DEFAULT_OUT_DIR, primary_defaults=False)
    dry.add_argument("--full-grid", action="store_true")

    primary = sub.add_parser("primary-run", help="Run the frozen primary simulator plan.")
    add_run_arguments(primary, default_out_dir=DEFAULT_PRIMARY_OUT_DIR, primary_defaults=True)
    primary.add_argument("--confirm-frozen-primary", action="store_true")
    primary.add_argument("--allow-overwrite", action="store_true")

    args = parser.parse_args()

    if args.cmd == "dry-run":
        run_dry_run(args)
    elif args.cmd == "primary-run":
        run_primary_run(args)


if __name__ == "__main__":
    main()
