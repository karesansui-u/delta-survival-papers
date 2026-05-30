#!/usr/bin/env python3
"""Randomized network ensemble check for repair-affordability dynamics.

This is the companion to `simulate_network_repair_affordability.py`. The first
demo is intentionally hand-crafted. This one checks the same SPT criterion on
random graph families and attack modes:

    graph families: ER, scale-free, small-world
    attacks: random edge failure, targeted high-degree edge removal
    L metric: global-efficiency log loss
    repair cost: greedy restored-edge estimate to recover a giant-component target

The output is still a mechanistic simulation, not empirical validation. Its job
is to make the hand-crafted demo less lonely: threshold crossing and
repair-cost infeasibility can be measured separately across graph ensembles.
"""

from __future__ import annotations

import csv
import math
import random
from collections import defaultdict, deque
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data" / "simulations" if (ROOT / "data" / "simulations").exists() else ROOT / "data"
FIGURE_DIR = ROOT / "paper" / "figures" if (ROOT / "paper").exists() else ROOT / "figures"
DETAIL_PATH = DATA_DIR / "network_repair_ensemble_detail.csv"
SUMMARY_PATH = DATA_DIR / "network_repair_ensemble_summary.csv"
SVG_PATH = FIGURE_DIR / "network_repair_ensemble.svg"

NODES = 64
TURNS = 96
SEEDS = tuple(range(12))
TARGET_GIANT_FRACTION = 0.75
TARGET_GIANT_SIZE = math.ceil(TARGET_GIANT_FRACTION * NODES)
M_BUDGET = 4
L_THRESHOLD = 0.25
L_METRIC = "global_efficiency_log_loss"
REPAIR_COST_METHOD = "greedy_restore_removed_edges_to_giant_component_target"
GRAPH_OFFSETS = {"er": 101, "scale_free": 211, "small_world": 307}
ATTACK_OFFSETS = {"random_failure": 17, "targeted_degree_attack": 43}

Edge = tuple[int, int]


@dataclass(frozen=True)
class DetailRow:
    graph_family: str
    seed: int
    attack_type: str
    turn: int
    removed_edges: int
    giant_fraction: float
    efficiency_fraction: float
    cumulative_loss: float
    repair_cost_to_target: int | None
    threshold_crossed: bool
    irreversible: bool


@dataclass(frozen=True)
class SummaryRow:
    graph_family: str
    attack_type: str
    turn: int
    mean_giant_fraction: float
    mean_efficiency_fraction: float
    mean_cumulative_loss: float
    mean_repair_cost_to_target: float
    threshold_crossed_rate: float
    irreversible_rate: float


def norm_edge(a: int, b: int) -> Edge:
    return (a, b) if a < b else (b, a)


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


def er_graph(rng: random.Random) -> tuple[Edge, ...]:
    p = 0.085
    edges = {norm_edge(i, j) for i in range(NODES) for j in range(i + 1, NODES) if rng.random() < p}
    return tuple(sorted(connect_backbone(edges)))


def scale_free_graph(rng: random.Random) -> tuple[Edge, ...]:
    m = 3
    edges: set[Edge] = {norm_edge(i, j) for i in range(m + 1) for j in range(i + 1, m + 1)}
    degree_list = [node for edge in edges for node in edge]

    for new_node in range(m + 1, NODES):
        targets: set[int] = set()
        while len(targets) < m:
            targets.add(rng.choice(degree_list))
        for target in targets:
            edges.add(norm_edge(new_node, target))
            degree_list.extend([new_node, target])

    return tuple(sorted(connect_backbone(edges)))


def small_world_graph(rng: random.Random) -> tuple[Edge, ...]:
    k = 4
    rewire_p = 0.12
    edges: set[Edge] = set()

    for node in range(NODES):
        for offset in range(1, k // 2 + 1):
            edges.add(norm_edge(node, (node + offset) % NODES))

    for edge in sorted(list(edges)):
        if rng.random() >= rewire_p:
            continue
        a, b = edge
        edges.remove(edge)
        candidate = rng.randrange(NODES)
        while candidate == a or norm_edge(a, candidate) in edges:
            candidate = rng.randrange(NODES)
        edges.add(norm_edge(a, candidate))

    return tuple(sorted(connect_backbone(edges)))


def connect_backbone(edges: set[Edge]) -> set[Edge]:
    for node in range(NODES - 1):
        edges.add(norm_edge(node, node + 1))
    return edges


def removal_schedule(edges: tuple[Edge, ...], rng: random.Random, attack_type: str) -> list[Edge]:
    if attack_type == "random_failure":
        shuffled = list(edges)
        rng.shuffle(shuffled)
        return shuffled

    degrees = [0] * NODES
    for a, b in edges:
        degrees[a] += 1
        degrees[b] += 1
    return sorted(edges, key=lambda edge: (degrees[edge[0]] + degrees[edge[1]], edge), reverse=True)


def simulate_one(graph_family: str, seed: int, attack_type: str) -> list[DetailRow]:
    rng = random.Random(10_000 * seed + GRAPH_OFFSETS[graph_family] + ATTACK_OFFSETS[attack_type])
    if graph_family == "er":
        initial_edges = er_graph(rng)
    elif graph_family == "scale_free":
        initial_edges = scale_free_graph(rng)
    elif graph_family == "small_world":
        initial_edges = small_world_graph(rng)
    else:
        raise ValueError(graph_family)

    schedule = removal_schedule(initial_edges, rng, attack_type)
    initial_efficiency = max(global_efficiency(initial_edges), 1.0e-12)
    rows: list[DetailRow] = []

    for turn in range(TURNS + 1):
        removed = tuple(sorted(schedule[: min(turn, len(schedule))]))
        removed_set = set(removed)
        active = tuple(edge for edge in initial_edges if edge not in removed_set)
        g_fraction = giant_size(active) / NODES
        efficiency_fraction = max(global_efficiency(active) / initial_efficiency, 1.0e-12)
        cumulative_loss = -math.log(efficiency_fraction)
        repair_cost = greedy_repair_cost(active, removed, TARGET_GIANT_SIZE)
        threshold_crossed = cumulative_loss >= L_THRESHOLD
        irreversible = repair_cost is None or repair_cost > M_BUDGET

        rows.append(
            DetailRow(
                graph_family=graph_family,
                seed=seed,
                attack_type=attack_type,
                turn=turn,
                removed_edges=len(removed),
                giant_fraction=g_fraction,
                efficiency_fraction=efficiency_fraction,
                cumulative_loss=cumulative_loss,
                repair_cost_to_target=repair_cost,
                threshold_crossed=threshold_crossed,
                irreversible=irreversible,
            )
        )

    return rows


def summarize(rows: list[DetailRow]) -> list[SummaryRow]:
    grouped: dict[tuple[str, str, int], list[DetailRow]] = defaultdict(list)
    for row in rows:
        grouped[(row.graph_family, row.attack_type, row.turn)].append(row)

    summary: list[SummaryRow] = []
    for (graph_family, attack_type, turn), group in sorted(grouped.items()):
        repair_values = [
            float(row.repair_cost_to_target if row.repair_cost_to_target is not None else M_BUDGET + 8)
            for row in group
        ]
        summary.append(
            SummaryRow(
                graph_family=graph_family,
                attack_type=attack_type,
                turn=turn,
                mean_giant_fraction=sum(row.giant_fraction for row in group) / len(group),
                mean_efficiency_fraction=sum(row.efficiency_fraction for row in group) / len(group),
                mean_cumulative_loss=sum(row.cumulative_loss for row in group) / len(group),
                mean_repair_cost_to_target=sum(repair_values) / len(repair_values),
                threshold_crossed_rate=sum(row.threshold_crossed for row in group) / len(group),
                irreversible_rate=sum(row.irreversible for row in group) / len(group),
            )
        )
    return summary


def write_detail(rows: list[DetailRow], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "graph_family",
                "seed",
                "attack_type",
                "L_metric",
                "repair_cost_method",
                "turn",
                "removed_edges",
                "giant_fraction",
                "efficiency_fraction",
                "L_cumulative_loss",
                "M_budget",
                "target_giant_size",
                "repair_cost_to_target",
                "threshold_crossed",
                "irreversible",
            ],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "graph_family": row.graph_family,
                    "seed": row.seed,
                    "attack_type": row.attack_type,
                    "L_metric": L_METRIC,
                    "repair_cost_method": REPAIR_COST_METHOD,
                    "turn": row.turn,
                    "removed_edges": row.removed_edges,
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
                }
            )


def write_summary(rows: list[SummaryRow], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(SummaryRow.__annotations__.keys()))
        writer.writeheader()
        for row in rows:
            writer.writerow(row.__dict__)


def points(
    rows: list[SummaryRow],
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
        x = left + width * row.turn / TURNS
        y = top + height - height * (getter(row) - ymin) / (ymax - ymin)
        pts.append(f"{x:.2f},{y:.2f}")
    return " ".join(pts)


def write_svg(summary: list[SummaryRow], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    panels = [
        ("er", "random_failure"),
        ("er", "targeted_degree_attack"),
        ("scale_free", "random_failure"),
        ("scale_free", "targeted_degree_attack"),
        ("small_world", "random_failure"),
        ("small_world", "targeted_degree_attack"),
    ]
    grouped: dict[tuple[str, str], list[SummaryRow]] = defaultdict(list)
    for row in summary:
        grouped[(row.graph_family, row.attack_type)].append(row)

    svg_width = 1120
    panel_width = 500
    panel_height = 185
    lefts = [75, 590]
    tops = [105, 335, 565]
    svg_height = 805
    max_repair = max(row.mean_repair_cost_to_target for row in summary)
    ymax_repair = max(max_repair, M_BUDGET + 2)

    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{svg_width}" height="{svg_height}" viewBox="0 0 {svg_width} {svg_height}">',
        "<style>",
        "text{font-family:Arial,Helvetica,sans-serif;fill:#1f2933}",
        ".title{font-size:24px;font-weight:700}",
        ".note{font-size:12px;fill:#52606d}",
        ".panel{font-size:15px;font-weight:700}",
        ".axis{stroke:#64748b;stroke-width:1}",
        ".grid{stroke:#d9e2ec;stroke-width:1}",
        ".eff{fill:none;stroke:#006d77;stroke-width:2.5}",
        ".giant{fill:none;stroke:#7b2cbf;stroke-width:2.5}",
        ".repair{fill:none;stroke:#c2410c;stroke-width:2.5}",
        ".budget{stroke:#111827;stroke-width:1.5;stroke-dasharray:6 4}",
        "</style>",
        '<rect width="100%" height="100%" fill="#ffffff"/>',
        '<text x="40" y="42" class="title">Network Repair Ensemble Check</text>',
        '<text x="40" y="64" class="note">Mean trajectories over 12 seeds. This is a randomized simulation check, not empirical validation.</text>',
    ]

    for idx, key in enumerate(panels):
        graph_family, attack_type = key
        rows = grouped[key]
        left = lefts[idx % 2]
        top = tops[idx // 2]
        bottom = top + panel_height
        title = f"{graph_family.replace('_', '-')} / {attack_type.replace('_', ' ')}"
        budget_y = top + panel_height - panel_height * M_BUDGET / ymax_repair

        svg.extend(
            [
                f'<text x="{left}" y="{top - 15}" class="panel">{title}</text>',
                f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" class="axis"/>',
                f'<line x1="{left}" y1="{bottom}" x2="{left + panel_width}" y2="{bottom}" class="axis"/>',
                f'<line x1="{left}" y1="{top}" x2="{left + panel_width}" y2="{top}" class="grid"/>',
                f'<line x1="{left}" y1="{top + panel_height / 2}" x2="{left + panel_width}" y2="{top + panel_height / 2}" class="grid"/>',
                f'<polyline points="{points(rows, lambda r: r.mean_efficiency_fraction, left, top, panel_width, panel_height, 0.0, 1.05)}" class="eff"/>',
                f'<polyline points="{points(rows, lambda r: r.mean_giant_fraction, left, top, panel_width, panel_height, 0.0, 1.05)}" class="giant"/>',
                f'<polyline points="{points(rows, lambda r: r.mean_repair_cost_to_target, left, top, panel_width, panel_height, 0.0, ymax_repair)}" class="repair"/>',
                f'<line x1="{left}" y1="{budget_y:.2f}" x2="{left + panel_width}" y2="{budget_y:.2f}" class="budget"/>',
                f'<text x="{left + panel_width + 7}" y="{budget_y + 4:.2f}" class="note">M</text>',
            ]
        )

    legend_y = 765
    svg.extend(
        [
            f'<line x1="45" y1="{legend_y}" x2="80" y2="{legend_y}" class="eff"/>',
            f'<text x="90" y="{legend_y + 4}" class="note">mean exp(-L), global efficiency</text>',
            f'<line x1="315" y1="{legend_y}" x2="350" y2="{legend_y}" class="giant"/>',
            f'<text x="360" y="{legend_y + 4}" class="note">mean giant component fraction</text>',
            f'<line x1="615" y1="{legend_y}" x2="650" y2="{legend_y}" class="repair"/>',
            f'<text x="660" y="{legend_y + 4}" class="note">mean greedy repair cost to target</text>',
            "</svg>",
        ]
    )
    path.write_text("\n".join(svg))


def main() -> None:
    detail: list[DetailRow] = []
    for graph_family in ("er", "scale_free", "small_world"):
        for attack_type in ("random_failure", "targeted_degree_attack"):
            for seed in SEEDS:
                detail.extend(simulate_one(graph_family, seed, attack_type))

    summary = summarize(detail)
    write_detail(detail, DETAIL_PATH)
    write_summary(summary, SUMMARY_PATH)
    write_svg(summary, SVG_PATH)
    print(f"wrote {DETAIL_PATH.relative_to(ROOT)}")
    print(f"wrote {SUMMARY_PATH.relative_to(ROOT)}")
    print(f"wrote {SVG_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
