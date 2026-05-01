#!/usr/bin/env python3
"""Generate an A31 graph spanning-tree persistence dataset.

By default this is used for smoke checks. It becomes support-bearing only when
its exact path, content hash, command, seeds, and output location are pinned by
a frozen manifest before outcome-bearing execution.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import random
from collections import defaultdict
from pathlib import Path

import networkx as nx
import numpy as np


def parse_int_list(raw: str) -> list[int]:
    return [int(part.strip()) for part in raw.split(",") if part.strip()]


def parse_float_list(raw: str) -> list[float]:
    return [float(part.strip()) for part in raw.split(",") if part.strip()]


def stable_seed(*parts: int) -> int:
    value = 1729
    for part in parts:
        value = (value * 1000003 + int(part)) % (2**32)
    return value


def bareiss_det(matrix: list[list[int]]) -> int:
    """Return the exact integer determinant using Bareiss elimination."""
    n = len(matrix)
    if n == 0:
        return 1
    work = [row[:] for row in matrix]
    sign = 1
    previous = 1
    for k in range(n - 1):
        if work[k][k] == 0:
            swap = next((idx for idx in range(k + 1, n) if work[idx][k] != 0), None)
            if swap is None:
                return 0
            work[k], work[swap] = work[swap], work[k]
            sign *= -1
        pivot = work[k][k]
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                work[i][j] = (work[i][j] * pivot - work[i][k] * work[k][j]) // previous
        previous = pivot
        for i in range(k + 1, n):
            work[i][k] = 0
        for j in range(k + 1, n):
            work[k][j] = 0
    return sign * work[n - 1][n - 1]


def spanning_tree_count_exact(graph: nx.Graph) -> int:
    if not nx.is_connected(graph):
        return 0
    nodes = sorted(graph.nodes())
    index = {node: idx for idx, node in enumerate(nodes)}
    n = len(nodes)
    laplacian = [[0 for _ in range(n)] for _ in range(n)]
    for u, v in graph.edges():
        i = index[u]
        j = index[v]
        laplacian[i][i] += 1
        laplacian[j][j] += 1
        laplacian[i][j] -= 1
        laplacian[j][i] -= 1
    cofactor = [row[1:] for row in laplacian[1:]]
    tau = bareiss_det(cofactor)
    if tau < 0:
        raise RuntimeError(f"negative spanning-tree determinant: {tau}")
    return tau


def log_spanning_tree_count(tau: int) -> float:
    if tau <= 0:
        return float("-inf")
    return math.log(tau)


def spanning_tree_count_sanity_cases() -> list[dict[str, object]]:
    cases: list[tuple[str, nx.Graph, int]] = []
    for n in range(2, 8):
        cases.append((f"path_{n}", nx.path_graph(n), 1))
    for n in range(3, 8):
        cases.append((f"cycle_{n}", nx.cycle_graph(n), n))
    for n in range(2, 8):
        cases.append((f"complete_{n}", nx.complete_graph(n), n ** (n - 2)))

    results: list[dict[str, object]] = []
    for name, graph, expected in cases:
        actual = spanning_tree_count_exact(graph)
        passed = actual == expected
        results.append(
            {
                "case": name,
                "nodes": graph.number_of_nodes(),
                "edges": graph.number_of_edges(),
                "expected_tau": expected,
                "actual_tau": actual,
                "passed": passed,
            }
        )
        if not passed:
            raise RuntimeError(
                f"spanning-tree sanity check failed for {name}: "
                f"expected {expected}, got {actual}"
            )
    return results


def sample_cluster(
    nodes: list[int],
    edge_count: int,
    kappa: int,
    rng: random.Random,
    max_attempts: int,
) -> nx.Graph:
    local_n = len(nodes)
    max_edges = local_n * (local_n - 1) // 2
    if edge_count > max_edges:
        raise ValueError(f"too many cluster edges: {edge_count} > {max_edges}")

    for _ in range(max_attempts):
        seed = rng.randrange(2**32)
        graph = nx.gnm_random_graph(local_n, edge_count, seed=seed)
        mapping = {i: nodes[i] for i in range(local_n)}
        graph = nx.relabel_nodes(graph, mapping)
        if min(dict(graph.degree()).values(), default=0) < kappa:
            continue
        if not nx.is_connected(graph):
            continue
        if nx.edge_connectivity(graph) < kappa:
            continue
        return graph
    raise RuntimeError(
        f"could not sample cluster with n={local_n}, edges={edge_count}, kappa>={kappa}"
    )


def make_two_cluster_graph(
    n: int,
    edge_count: int,
    kappa: int,
    rng: random.Random,
    max_attempts: int,
) -> nx.Graph:
    left = list(range(n // 2))
    right = list(range(n // 2, n))
    internal_edges = edge_count - kappa
    left_edges = internal_edges // 2
    right_edges = internal_edges - left_edges

    for _ in range(max_attempts):
        graph = nx.Graph()
        graph.add_nodes_from(range(n))
        graph.update(sample_cluster(left, left_edges, kappa, rng, max_attempts))
        graph.update(sample_cluster(right, right_edges, kappa, rng, max_attempts))

        left_endpoints = left[:]
        right_endpoints = right[:]
        rng.shuffle(left_endpoints)
        rng.shuffle(right_endpoints)
        for idx in range(kappa):
            graph.add_edge(left_endpoints[idx], right_endpoints[idx])

        if graph.number_of_edges() != edge_count:
            continue
        if not nx.is_connected(graph):
            continue
        if nx.edge_connectivity(graph) != kappa:
            continue
        return graph

    raise RuntimeError(f"could not sample graph n={n}, e={edge_count}, kappa={kappa}")


def graph_feature_row(
    graph: nx.Graph,
    graph_id: str,
    state_id: str,
    split: str,
    n: int,
    e0: int,
    kappa0: int,
    tau_stratum: str,
    prefix_len: int,
    prefix_seed: int,
    tau0: int,
    tau: int,
    log_tau0: float,
    log_tau: float,
) -> dict[str, object]:
    raw_loss = log_tau0 - log_tau
    tolerance = 1.0e-10
    if raw_loss < -tolerance:
        raise RuntimeError(
            f"spanning-tree mass increased under deletion: "
            f"log_tau0={log_tau0}, log_tau={log_tau}"
        )
    loss = 0.0 if raw_loss < 0.0 else raw_loss
    degrees = np.array([deg for _, deg in graph.degree()], dtype=float)
    edge_count = graph.number_of_edges()
    density = nx.density(graph)
    laplacian = nx.laplacian_matrix(graph, nodelist=sorted(graph.nodes())).toarray().astype(float)
    lap_eigs = np.linalg.eigvalsh(laplacian)
    positive_lap = np.maximum(lap_eigs[1:], 1.0e-12)
    adjacency = nx.to_numpy_array(graph, nodelist=sorted(graph.nodes()), dtype=float)
    adj_eigs = np.linalg.eigvalsh(adjacency)
    betweenness = np.array(list(nx.betweenness_centrality(graph).values()), dtype=float)
    kappa_t = nx.edge_connectivity(graph) if nx.is_connected(graph) else 0
    bridge_count = len(list(nx.bridges(graph))) if nx.is_connected(graph) else 0

    return {
        "graph_id": graph_id,
        "state_id": state_id,
        "split": split,
        "n": n,
        "e0": e0,
        "et": edge_count,
        "kappa0": kappa0,
        "kappat": kappa_t,
        "tau_stratum": tau_stratum,
        "prefix_len": prefix_len,
        "prefix_seed": prefix_seed,
        "tau0": tau0,
        "tau": tau,
        "log_tau0": log_tau0,
        "log_tau": log_tau,
        "L_t": loss,
        "deleted_edge_count": e0 - edge_count,
        "deleted_edge_fraction": (e0 - edge_count) / e0,
        "edge_density": density,
        "mean_degree": float(degrees.mean()),
        "degree_variance": float(degrees.var()),
        "min_degree": int(degrees.min()),
        "bridge_count": bridge_count,
        "avg_shortest_path_length": float(nx.average_shortest_path_length(graph)),
        "diameter": int(nx.diameter(graph)),
        "algebraic_connectivity": float(lap_eigs[1]) if len(lap_eigs) > 1 else 0.0,
        "laplacian_spectral_radius": float(lap_eigs[-1]) if len(lap_eigs) else 0.0,
        "adjacency_spectral_gap": float(adj_eigs[-1] - adj_eigs[-2])
        if len(adj_eigs) > 1
        else 0.0,
        "kirchhoff_index": float(n * np.sum(1.0 / positive_lap)),
        "betweenness_mean": float(betweenness.mean()),
        "betweenness_max": float(betweenness.max()),
        "betweenness_std": float(betweenness.std()),
    }


def assign_splits(selected: list[dict[str, object]], split_seed: int) -> None:
    by_group: dict[tuple[object, ...], list[dict[str, object]]] = defaultdict(list)
    for row in selected:
        key = (row["n"], row["e0"], row["kappa0"], row["tau_stratum"])
        by_group[key].append(row)

    stratum_codes = {"low": 1, "mid": 2, "high": 3}
    for key, rows in by_group.items():
        n, e0, kappa0, tau_stratum = key
        rows.sort(key=lambda item: str(item["graph_id"]))
        rng = random.Random(
            stable_seed(
                split_seed,
                int(n),
                int(e0),
                int(kappa0),
                stratum_codes[str(tau_stratum)],
            )
        )
        rng.shuffle(rows)
        if len(rows) < 5:
            raise RuntimeError(
                f"split group needs at least 5 graphs for train/validation/test: {key}"
            )
        validation_count = max(1, math.floor(0.2 * len(rows)))
        test_count = max(1, math.floor(0.2 * len(rows)))
        train_count = len(rows) - validation_count - test_count
        if train_count < 1:
            raise RuntimeError(f"split group has no training rows after allocation: {key}")
        for idx, row in enumerate(rows):
            if idx < train_count:
                row["split"] = "train"
            elif idx < train_count + validation_count:
                row["split"] = "validation"
            else:
                row["split"] = "test"


def choose_strata(candidates: list[dict[str, object]], graphs_per_stratum: int) -> list[dict[str, object]]:
    candidates = sorted(candidates, key=lambda item: float(item["log_tau0"]))
    needed = graphs_per_stratum
    if len(candidates) < needed * 3:
        raise RuntimeError("not enough candidates to form low/mid/high tau strata")

    mid_start = max(needed, len(candidates) // 2 - needed // 2)
    strata = [
        ("low", candidates[:needed]),
        ("mid", candidates[mid_start : mid_start + needed]),
        ("high", candidates[-needed:]),
    ]
    selected: list[dict[str, object]] = []
    used = set()
    for stratum, rows in strata:
        for row in rows:
            if row["candidate_key"] in used:
                continue
            row = dict(row)
            row["tau_stratum"] = stratum
            selected.append(row)
            used.add(row["candidate_key"])
    return selected


def delete_prefix_edges(graph: nx.Graph, prefix_len: int, seed: int) -> nx.Graph:
    rng = random.Random(seed)
    out = graph.copy()
    edges = sorted(out.edges())
    rng.shuffle(edges)
    for edge in edges[:prefix_len]:
        out.remove_edge(*edge)
    return out


def first_future_collapse_step(graph: nx.Graph, max_h: int, seed: int) -> int | None:
    rng = random.Random(seed)
    out = graph.copy()
    edges = sorted(out.edges())
    rng.shuffle(edges)
    for step, edge in enumerate(edges[:max_h], start=1):
        out.remove_edge(*edge)
        if not nx.is_connected(out):
            return step
    return None


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({name: row.get(name, "") for name in fieldnames})


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--n-values", default="24,32")
    parser.add_argument("--edge-factors", default="2,3")
    parser.add_argument("--kappas", default="2,3")
    parser.add_argument("--candidate-count", type=int, default=75)
    parser.add_argument("--graphs-per-stratum", type=int, default=5)
    parser.add_argument("--prefix-fractions", default="0,0.05,0.10")
    parser.add_argument("--horizon-fractions", default="0.05,0.10,0.15")
    parser.add_argument("--future-trajectories", type=int, default=64)
    parser.add_argument("--seed", type=int, default=31031)
    parser.add_argument("--split-seed", type=int, default=41041)
    parser.add_argument("--max-attempts", type=int, default=400)
    args = parser.parse_args()

    n_values = parse_int_list(args.n_values)
    edge_factors = parse_int_list(args.edge_factors)
    kappas = parse_int_list(args.kappas)
    prefix_fractions = parse_float_list(args.prefix_fractions)
    horizon_fractions = parse_float_list(args.horizon_fractions)

    args.output_dir.mkdir(parents=True, exist_ok=True)
    spanning_tree_sanity = spanning_tree_count_sanity_cases()

    selected_graphs: list[dict[str, object]] = []
    graph_objects: dict[str, nx.Graph] = {}
    rejection_counts: dict[str, int] = defaultdict(int)

    for n in n_values:
        for edge_factor in edge_factors:
            e0 = edge_factor * n
            for kappa in kappas:
                candidates: list[dict[str, object]] = []
                attempts = 0
                while len(candidates) < args.candidate_count and attempts < args.candidate_count * 20:
                    attempts += 1
                    seed = stable_seed(args.seed, n, edge_factor, kappa, attempts)
                    rng = random.Random(seed)
                    try:
                        graph = make_two_cluster_graph(
                            n=n,
                            edge_count=e0,
                            kappa=kappa,
                            rng=rng,
                            max_attempts=args.max_attempts,
                        )
                    except RuntimeError:
                        rejection_counts[f"sample_failed_n{n}_e{e0}_k{kappa}"] += 1
                        continue
                    tau0 = spanning_tree_count_exact(graph)
                    log_tau0 = log_spanning_tree_count(tau0)
                    if not math.isfinite(log_tau0):
                        rejection_counts[f"bad_tau_n{n}_e{e0}_k{kappa}"] += 1
                        continue
                    candidate_key = f"n{n}_e{e0}_k{kappa}_c{attempts}"
                    candidates.append(
                        {
                            "candidate_key": candidate_key,
                            "n": n,
                            "e0": e0,
                            "kappa0": kappa,
                            "edge_factor": edge_factor,
                            "tau0": tau0,
                            "log_tau0": log_tau0,
                            "seed": seed,
                            "graph": graph,
                        }
                    )

                cell_selected = choose_strata(candidates, args.graphs_per_stratum)
                for idx, row in enumerate(cell_selected):
                    graph_id = (
                        f"g_n{row['n']}_e{row['e0']}_k{row['kappa0']}"
                        f"_{row['tau_stratum']}_{idx:02d}"
                    )
                    row["graph_id"] = graph_id
                    row["split"] = "unset"
                    graph_objects[graph_id] = row.pop("graph")
                    selected_graphs.append(row)

    assign_splits(selected_graphs, args.split_seed)

    graph_rows: list[dict[str, object]] = []
    state_rows: list[dict[str, object]] = []
    path_rows: list[dict[str, object]] = []
    label_rows: list[dict[str, object]] = []

    for graph_index, graph_meta in enumerate(selected_graphs):
        graph_id = str(graph_meta["graph_id"])
        graph = graph_objects[graph_id]
        n = int(graph_meta["n"])
        e0 = int(graph_meta["e0"])
        kappa0 = int(graph_meta["kappa0"])
        tau0 = int(graph_meta["tau0"])
        log_tau0 = float(graph_meta["log_tau0"])
        split = str(graph_meta["split"])
        tau_stratum = str(graph_meta["tau_stratum"])

        edge_list = sorted((min(u, v), max(u, v)) for u, v in graph.edges())
        graph_rows.append(
            {
                "graph_id": graph_id,
                "split": split,
                "n": n,
                "e0": e0,
                "kappa0": kappa0,
                "tau_stratum": tau_stratum,
                "tau0": tau0,
                "log_tau0": log_tau0,
                "seed": graph_meta["seed"],
                "edges": json.dumps(edge_list),
            }
        )

        for prefix_fraction in prefix_fractions:
            prefix_len = int(math.ceil(prefix_fraction * e0))
            prefix_seed = stable_seed(args.seed, graph_index, int(prefix_fraction * 10000), 41)
            state_graph = delete_prefix_edges(graph, prefix_len, prefix_seed)
            if not nx.is_connected(state_graph):
                rejection_counts["disconnected_prefix_state"] += 1
                continue
            tau = spanning_tree_count_exact(state_graph)
            log_tau = log_spanning_tree_count(tau)
            if not math.isfinite(log_tau):
                rejection_counts["bad_prefix_tau"] += 1
                continue
            state_id = f"{graph_id}_p{prefix_len}"
            state_rows.append(
                graph_feature_row(
                    graph=state_graph,
                    graph_id=graph_id,
                    state_id=state_id,
                    split=split,
                    n=n,
                    e0=e0,
                    kappa0=kappa0,
                    tau_stratum=tau_stratum,
                    prefix_len=prefix_len,
                    prefix_seed=prefix_seed,
                    tau0=tau0,
                    tau=tau,
                    log_tau0=log_tau0,
                    log_tau=log_tau,
                )
            )

            et = state_graph.number_of_edges()
            max_h = int(math.ceil(max(horizon_fractions) * et))
            first_steps: list[int | None] = []
            for future_index in range(args.future_trajectories):
                future_seed = stable_seed(args.seed, graph_index, prefix_len, future_index, 97)
                first_step = first_future_collapse_step(state_graph, max_h, future_seed)
                first_steps.append(first_step)
                path_rows.append(
                    {
                        "graph_id": graph_id,
                        "state_id": state_id,
                        "split": split,
                        "future_index": future_index,
                        "future_seed": future_seed,
                        "max_h": max_h,
                        "first_disconnect_step": "" if first_step is None else first_step,
                    }
                )

            for horizon_fraction in horizon_fractions:
                h_steps = int(math.ceil(horizon_fraction * et))
                z = sum(1 for step in first_steps if step is not None and step <= h_steps)
                label_rows.append(
                    {
                        "graph_id": graph_id,
                        "state_id": state_id,
                        "split": split,
                        "horizon_fraction": horizon_fraction,
                        "h_steps": h_steps,
                        "K": args.future_trajectories,
                        "z": z,
                        "collapse_fraction": z / args.future_trajectories,
                    }
                )

    graph_fields = [
        "graph_id",
        "split",
        "n",
        "e0",
        "kappa0",
        "tau_stratum",
        "tau0",
        "log_tau0",
        "seed",
        "edges",
    ]
    state_fields = list(state_rows[0].keys()) if state_rows else []
    path_fields = [
        "graph_id",
        "state_id",
        "split",
        "future_index",
        "future_seed",
        "max_h",
        "first_disconnect_step",
    ]
    label_fields = [
        "graph_id",
        "state_id",
        "split",
        "horizon_fraction",
        "h_steps",
        "K",
        "z",
        "collapse_fraction",
    ]

    write_csv(args.output_dir / "graphs.csv", graph_rows, graph_fields)
    write_csv(args.output_dir / "states.csv", state_rows, state_fields)
    write_csv(args.output_dir / "future_paths.csv", path_rows, path_fields)
    write_csv(args.output_dir / "labels_by_horizon.csv", label_rows, label_fields)
    (args.output_dir / "spanning_tree_count_sanity.json").write_text(
        json.dumps(
            {
                "status": "passed",
                "method": "exact_integer_matrix_tree_bareiss",
                "case_count": len(spanning_tree_sanity),
                "cases": spanning_tree_sanity,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )

    summary = {
        "status": "smoke_generated_not_evidence",
        "seed": args.seed,
        "n_values": n_values,
        "edge_factors": edge_factors,
        "kappas": kappas,
        "prefix_fractions": prefix_fractions,
        "horizon_fractions": horizon_fractions,
        "future_trajectories": args.future_trajectories,
        "split_seed": args.split_seed,
        "split_method": (
            "seeded_random_permutation_within_n_e0_kappa_tau_stratum_"
            "train_remainder_val_floor20_test_floor20"
        ),
        "spanning_tree_count_method": "exact_integer_matrix_tree_bareiss",
        "spanning_tree_count_sanity": "passed",
        "spanning_tree_count_sanity_cases": len(spanning_tree_sanity),
        "tau_monotonicity_tolerance": 1.0e-10,
        "graph_count": len(graph_rows),
        "state_count": len(state_rows),
        "future_path_count": len(path_rows),
        "label_count": len(label_rows),
        "rejection_counts": dict(sorted(rejection_counts.items())),
        "output_files": [
            "graphs.csv",
            "states.csv",
            "future_paths.csv",
            "labels_by_horizon.csv",
            "spanning_tree_count_sanity.json",
        ],
    }
    (args.output_dir / "generation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
