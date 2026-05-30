#!/usr/bin/env python3
"""Simulate threshold-triggered repair infeasibility on a small network.

This is a dependency-free visual witness for the repair-affordability reading:

    L crosses a structural threshold.
    After that threshold, target-restoring repairs have a cost floor.
    If the available M budget is below that floor, recovery is infeasible.

The model is intentionally small and transparent. Eight dense modules are
connected by bridge edges. Early damage removes within-module redundancy, so
structural efficiency decays without disconnecting the whole graph. Later
damage removes bridges, causing fragmentation. The repair action is restoring
previously removed edges; its cost is the smallest number of restored edges
needed to recover a target giant-component size, estimated greedily.
"""

from __future__ import annotations

import csv
import math
from collections import deque
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data" / "simulations" if (ROOT / "data" / "simulations").exists() else ROOT / "data"
FIGURE_DIR = ROOT / "paper" / "figures" if (ROOT / "paper").exists() else ROOT / "figures"
DATA_PATH = DATA_DIR / "network_repair_affordability.csv"
SVG_PATH = FIGURE_DIR / "network_repair_affordability.svg"

MODULES = 8
MODULE_SIZE = 8
NODES = MODULES * MODULE_SIZE
TARGET_GIANT_FRACTION = 0.75
TARGET_GIANT_SIZE = math.ceil(TARGET_GIANT_FRACTION * NODES)
M_BUDGET = 4
TURNS = 42
SCENARIO = "clustered_bridge_demo"
SEED = 0
ATTACK_TYPE = "deterministic_internal_then_bridge_removal"
L_METRIC = "global_efficiency_log_loss"
REPAIR_COST_METHOD = "greedy_restore_removed_edges_to_giant_component_target"

Edge = tuple[int, int]


@dataclass(frozen=True)
class Snapshot:
    turn: int
    removed_edges: tuple[Edge, ...]
    active_edges: tuple[Edge, ...]
    giant_size: int
    giant_fraction: float
    efficiency_fraction: float
    cumulative_loss: float
    repair_cost_to_target: int | None
    threshold_crossed: bool
    irreversible: bool
    event: str


def norm_edge(a: int, b: int) -> Edge:
    return (a, b) if a < b else (b, a)


def build_initial_edges() -> list[Edge]:
    edges: list[Edge] = []

    for module in range(MODULES):
        start = module * MODULE_SIZE
        nodes = range(start, start + MODULE_SIZE)
        for i in nodes:
            for j in nodes:
                if i < j:
                    edges.append((i, j))

    for module in range(MODULES - 1):
        left = module * MODULE_SIZE
        right = (module + 1) * MODULE_SIZE
        edges.append((left, right))

    return edges


def build_damage_schedule() -> list[Edge]:
    """Return a deterministic edge-removal schedule.

    The first block removes within-module redundancy. The second block removes
    the inter-module bridges from left to right, producing fragmentation.
    """

    schedule: list[Edge] = []

    for module in range(MODULES):
        start = module * MODULE_SIZE
        for offset in range(1, 5):
            schedule.append(norm_edge(start, start + offset))

    for module in range(MODULES - 1):
        left = module * MODULE_SIZE
        right = (module + 1) * MODULE_SIZE
        schedule.append(norm_edge(left, right))

    return schedule


def adjacency(edges: tuple[Edge, ...]) -> list[list[int]]:
    adj: list[list[int]] = [[] for _ in range(NODES)]
    for a, b in edges:
        adj[a].append(b)
        adj[b].append(a)
    return adj


def component_sizes(edges: tuple[Edge, ...]) -> list[int]:
    adj = adjacency(edges)
    seen = [False] * NODES
    sizes: list[int] = []

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
        sizes.append(size)

    return sorted(sizes, reverse=True)


def giant_size(edges: tuple[Edge, ...]) -> int:
    return component_sizes(edges)[0]


def global_efficiency(edges: tuple[Edge, ...]) -> float:
    adj = adjacency(edges)
    total = 0.0
    pairs = NODES * (NODES - 1)

    for source in range(NODES):
        dist = [-1] * NODES
        dist[source] = 0
        q: deque[int] = deque([source])
        while q:
            node = q.popleft()
            for nxt in adj[node]:
                if dist[nxt] == -1:
                    dist[nxt] = dist[node] + 1
                    q.append(nxt)
        for target in range(NODES):
            if target != source and dist[target] > 0:
                total += 1.0 / dist[target]

    return total / pairs


def greedy_repair_cost(
    active_edges: tuple[Edge, ...],
    removed_edges: tuple[Edge, ...],
    target_size: int,
) -> int | None:
    """Estimate the minimum restore count needed to reach target giant size."""

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
            candidate_edges = tuple(sorted(current | {edge}))
            candidate_giant = giant_size(candidate_edges)
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


def simulate() -> list[Snapshot]:
    initial_edges = tuple(sorted(build_initial_edges()))
    initial_efficiency = global_efficiency(initial_edges)
    damage_schedule = build_damage_schedule()
    threshold_turn = len(damage_schedule) - (MODULES - 1)

    snapshots: list[Snapshot] = []
    seen_irreversible = False

    for turn in range(TURNS + 1):
        removed = tuple(sorted(damage_schedule[: min(turn, len(damage_schedule))]))
        active = tuple(edge for edge in initial_edges if edge not in set(removed))
        g_size = giant_size(active)
        efficiency_fraction = global_efficiency(active) / initial_efficiency
        efficiency_fraction = max(efficiency_fraction, 1.0e-12)
        cumulative_loss = -math.log(efficiency_fraction)
        repair_cost = greedy_repair_cost(active, removed, TARGET_GIANT_SIZE)
        threshold_crossed = turn >= threshold_turn
        irreversible = repair_cost is None or repair_cost > M_BUDGET

        event = ""
        if threshold_crossed and turn == threshold_turn:
            event = "L_threshold_crossed"
        if irreversible and not seen_irreversible:
            event = "repair_cost_exceeds_M"
            seen_irreversible = True

        snapshots.append(
            Snapshot(
                turn=turn,
                removed_edges=removed,
                active_edges=active,
                giant_size=g_size,
                giant_fraction=g_size / NODES,
                efficiency_fraction=efficiency_fraction,
                cumulative_loss=cumulative_loss,
                repair_cost_to_target=repair_cost,
                threshold_crossed=threshold_crossed,
                irreversible=irreversible,
                event=event,
            )
        )

    return snapshots


def write_csv(rows: list[Snapshot], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "turn",
                "scenario",
                "seed",
                "attack_type",
                "L_metric",
                "repair_cost_method",
                "removed_edges",
                "giant_size",
                "giant_fraction",
                "efficiency_fraction",
                "L_cumulative_loss",
                "M_budget",
                "target_giant_size",
                "repair_cost_to_target",
                "threshold_crossed",
                "irreversible",
                "event",
            ],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "turn": row.turn,
                    "scenario": SCENARIO,
                    "seed": SEED,
                    "attack_type": ATTACK_TYPE,
                    "L_metric": L_METRIC,
                    "repair_cost_method": REPAIR_COST_METHOD,
                    "removed_edges": len(row.removed_edges),
                    "giant_size": row.giant_size,
                    "giant_fraction": row.giant_fraction,
                    "efficiency_fraction": row.efficiency_fraction,
                    "L_cumulative_loss": row.cumulative_loss,
                    "M_budget": M_BUDGET,
                    "target_giant_size": TARGET_GIANT_SIZE,
                    "repair_cost_to_target": (
                        "" if row.repair_cost_to_target is None else row.repair_cost_to_target
                    ),
                    "threshold_crossed": row.threshold_crossed,
                    "irreversible": row.irreversible,
                    "event": row.event,
                }
            )


def scale_points(
    rows: list[Snapshot],
    getter,
    left: float,
    top: float,
    width: float,
    height: float,
    ymin: float,
    ymax: float,
) -> str:
    pts: list[str] = []
    for row in rows:
        value = getter(row)
        x = left + width * row.turn / TURNS
        y = top + height - height * (value - ymin) / (ymax - ymin)
        pts.append(f"{x:.2f},{y:.2f}")
    return " ".join(pts)


def event_x(rows: list[Snapshot], event: str, left: float, width: float) -> float | None:
    for row in rows:
        if row.event == event:
            return left + width * row.turn / TURNS
    return None


def write_svg(rows: list[Snapshot], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    width = 1040
    height = 620
    left = 95
    top = 105
    chart_width = 850
    chart_height = 350
    bottom = top + chart_height
    max_cost = max(
        M_BUDGET + 1,
        max(row.repair_cost_to_target or 0 for row in rows),
        6,
    )
    threshold_x = event_x(rows, "L_threshold_crossed", left, chart_width)
    irreversible_x = event_x(rows, "repair_cost_exceeds_M", left, chart_width)

    efficiency_points = scale_points(
        rows,
        lambda row: row.efficiency_fraction,
        left,
        top,
        chart_width,
        chart_height,
        0.0,
        1.05,
    )
    giant_points = scale_points(
        rows,
        lambda row: row.giant_fraction,
        left,
        top,
        chart_width,
        chart_height,
        0.0,
        1.05,
    )
    repair_points = scale_points(
        rows,
        lambda row: row.repair_cost_to_target or max_cost,
        left,
        top,
        chart_width,
        chart_height,
        0.0,
        float(max_cost),
    )
    budget_y = top + chart_height - chart_height * M_BUDGET / max_cost

    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        "<style>",
        "text{font-family:Arial,Helvetica,sans-serif;fill:#1f2933}",
        ".title{font-size:24px;font-weight:700}",
        ".subtitle{font-size:13px;fill:#52606d}",
        ".axis{stroke:#64748b;stroke-width:1}",
        ".grid{stroke:#d9e2ec;stroke-width:1}",
        ".eff{fill:none;stroke:#006d77;stroke-width:3}",
        ".giant{fill:none;stroke:#7b2cbf;stroke-width:3}",
        ".repair{fill:none;stroke:#c2410c;stroke-width:3}",
        ".budget{stroke:#111827;stroke-width:2;stroke-dasharray:7 5}",
        ".threshold{stroke:#475569;stroke-width:2;stroke-dasharray:4 5}",
        ".irreversible{stroke:#b91c1c;stroke-width:2;stroke-dasharray:8 4}",
        ".label{font-size:12px;fill:#52606d}",
        ".strong{font-size:13px;font-weight:700;fill:#1f2933}",
        "</style>",
        '<rect width="100%" height="100%" fill="#ffffff"/>',
        '<text x="40" y="42" class="title">Network Repair Affordability Demo</text>',
        '<text x="40" y="64" class="subtitle">Structural degradation can cross a threshold without being irreversible; irreversibility starts when target repair cost exceeds M.</text>',
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" class="axis"/>',
        f'<line x1="{left}" y1="{bottom}" x2="{left + chart_width}" y2="{bottom}" class="axis"/>',
    ]

    for i in range(6):
        y = top + chart_height * i / 5
        svg.append(f'<line x1="{left}" y1="{y:.2f}" x2="{left + chart_width}" y2="{y:.2f}" class="grid"/>')

    svg.extend(
        [
            f'<polyline points="{efficiency_points}" class="eff"/>',
            f'<polyline points="{giant_points}" class="giant"/>',
            f'<polyline points="{repair_points}" class="repair"/>',
            f'<line x1="{left}" y1="{budget_y:.2f}" x2="{left + chart_width}" y2="{budget_y:.2f}" class="budget"/>',
            f'<text x="{left + chart_width + 8}" y="{budget_y + 4:.2f}" class="strong">M={M_BUDGET}</text>',
            f'<text x="42" y="{top + 5}" class="label">1.0</text>',
            f'<text x="51" y="{bottom + 4}" class="label">0</text>',
            f'<text x="{left}" y="{bottom + 24}" class="label">damage step 0</text>',
            f'<text x="{left + chart_width - 82}" y="{bottom + 24}" class="label">damage step {TURNS}</text>',
        ]
    )

    if threshold_x is not None:
        svg.extend(
            [
                f'<line x1="{threshold_x:.2f}" y1="{top}" x2="{threshold_x:.2f}" y2="{bottom}" class="threshold"/>',
                f'<text x="{threshold_x + 8:.2f}" y="{top + 18}" class="label">L threshold crossed</text>',
            ]
        )

    if irreversible_x is not None:
        svg.extend(
            [
                f'<line x1="{irreversible_x:.2f}" y1="{top}" x2="{irreversible_x:.2f}" y2="{bottom}" class="irreversible"/>',
                f'<text x="{irreversible_x + 8:.2f}" y="{top + 38}" class="strong">repair cost &gt; M</text>',
            ]
        )

    legend_y = 535
    svg.extend(
        [
            f'<line x1="45" y1="{legend_y}" x2="80" y2="{legend_y}" class="eff"/>',
            f'<text x="90" y="{legend_y + 4}" class="label">structural efficiency fraction, exp(-L)</text>',
            f'<line x1="345" y1="{legend_y}" x2="380" y2="{legend_y}" class="giant"/>',
            f'<text x="390" y="{legend_y + 4}" class="label">giant component fraction</text>',
            f'<line x1="575" y1="{legend_y}" x2="610" y2="{legend_y}" class="repair"/>',
            f'<text x="620" y="{legend_y + 4}" class="label">min restored edges to target</text>',
            '<text x="45" y="575" class="subtitle">Target: giant component >= 75% of nodes. Repair action: restore removed edges. Irreversible means no target-restoring repair is affordable under current M.</text>',
            "</svg>",
        ]
    )
    path.write_text("\n".join(svg))


def main() -> None:
    rows = simulate()
    write_csv(rows, DATA_PATH)
    write_svg(rows, SVG_PATH)
    print(f"wrote {DATA_PATH.relative_to(ROOT)}")
    print(f"wrote {SVG_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
