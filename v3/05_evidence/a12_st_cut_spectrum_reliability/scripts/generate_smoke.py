#!/usr/bin/env python3
"""Generate an A12 s-t cut-spectrum reliability dataset.

By default this is a smoke harness. It becomes support-bearing only when its
path, content hash, command, seeds, and output directory are pinned by a frozen
manifest before outcome-bearing execution.
"""

from __future__ import annotations

import argparse
import csv
import itertools
import json
import math
import random
import sys
import time
from collections import defaultdict, deque
from pathlib import Path

import networkx as nx
import numpy as np


Edge = tuple[int, int]


def log_progress(message: str) -> None:
    print(f"[a12-generate] {message}", file=sys.stderr, flush=True)


def parse_int_list(raw: str) -> list[int]:
    return [int(part.strip()) for part in raw.split(",") if part.strip()]


def parse_float_list(raw: str) -> list[float]:
    return [float(part.strip()) for part in raw.split(",") if part.strip()]


def stable_seed(*parts: int) -> int:
    value = 8191
    for part in parts:
        value = (value * 1000003 + int(part)) % (2**32)
    return value


def norm_edge(edge: tuple[int, int]) -> Edge:
    u, v = edge
    return (u, v) if u < v else (v, u)


def edge_list(graph: nx.Graph) -> list[Edge]:
    return sorted(norm_edge(edge) for edge in graph.edges())


def st_connected_without(graph: nx.Graph, removed: set[Edge], source: int, target: int) -> bool:
    if source == target:
        return True
    seen = {source}
    queue: deque[int] = deque([source])
    while queue:
        node = queue.popleft()
        for nbr in graph.neighbors(node):
            if norm_edge((node, nbr)) in removed:
                continue
            if nbr == target:
                return True
            if nbr not in seen:
                seen.add(nbr)
                queue.append(nbr)
    return False


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
    if edge_count < local_n - 1:
        raise ValueError(f"too few cluster edges for connectivity: {edge_count}")

    for _ in range(max_attempts):
        seed = rng.randrange(2**32)
        graph = nx.gnm_random_graph(local_n, edge_count, seed=seed)
        graph = nx.relabel_nodes(graph, {idx: nodes[idx] for idx in range(local_n)})
        if not nx.is_connected(graph):
            continue
        if min(dict(graph.degree()).values(), default=0) < kappa:
            continue
        if nx.edge_connectivity(graph) < kappa:
            continue
        return graph
    raise RuntimeError(
        f"could not sample cluster with n={local_n}, edges={edge_count}, kappa>={kappa}"
    )


def construct_cluster(
    nodes: list[int],
    edge_count: int,
    kappa: int,
    rng: random.Random,
) -> nx.Graph:
    """Construct a kappa-edge-connected cluster, then add random surplus edges."""
    local_n = len(nodes)
    max_edges = local_n * (local_n - 1) // 2
    min_edges = math.ceil(kappa * local_n / 2)
    if edge_count < min_edges:
        raise ValueError(
            f"too few cluster edges for constructive kappa={kappa}: "
            f"{edge_count} < {min_edges}"
        )
    if edge_count > max_edges:
        raise ValueError(f"too many cluster edges: {edge_count} > {max_edges}")
    if kappa % 2 == 1 and local_n % 2 == 1:
        raise ValueError("odd kappa constructive clusters require an even local_n")

    graph = nx.Graph()
    graph.add_nodes_from(nodes)

    def add_local_edge(left_idx: int, right_idx: int) -> None:
        graph.add_edge(nodes[left_idx % local_n], nodes[right_idx % local_n])

    for offset in range(1, kappa // 2 + 1):
        for idx in range(local_n):
            add_local_edge(idx, idx + offset)
    if kappa % 2 == 1:
        half = local_n // 2
        for idx in range(half):
            add_local_edge(idx, idx + half)

    possible_edges = [
        (nodes[left], nodes[right])
        for left in range(local_n)
        for right in range(left + 1, local_n)
        if not graph.has_edge(nodes[left], nodes[right])
    ]
    rng.shuffle(possible_edges)
    while graph.number_of_edges() < edge_count:
        if not possible_edges:
            raise RuntimeError("constructive cluster ran out of surplus edges")
        graph.add_edge(*possible_edges.pop())

    if not nx.is_connected(graph):
        raise RuntimeError("constructive cluster is disconnected")
    if min(dict(graph.degree()).values(), default=0) < kappa:
        raise RuntimeError("constructive cluster degree check failed")
    if nx.edge_connectivity(graph) < kappa:
        raise RuntimeError("constructive cluster edge-connectivity check failed")
    return graph


def make_two_cluster_graph(
    n: int,
    edge_count: int,
    kappa: int,
    rng: random.Random,
    max_attempts: int,
    cluster_generator: str,
) -> tuple[nx.Graph, int, int]:
    left = list(range(n // 2))
    right = list(range(n // 2, n))
    source = left[0]
    target = right[0]
    internal_edges = edge_count - kappa
    left_edges = internal_edges // 2
    right_edges = internal_edges - left_edges

    for _ in range(max_attempts):
        graph = nx.Graph()
        graph.add_nodes_from(range(n))
        try:
            if cluster_generator == "random":
                graph.update(sample_cluster(left, left_edges, kappa, rng, max_attempts))
                graph.update(sample_cluster(right, right_edges, kappa, rng, max_attempts))
            elif cluster_generator == "constructive":
                graph.update(construct_cluster(left, left_edges, kappa, rng))
                graph.update(construct_cluster(right, right_edges, kappa, rng))
            else:
                raise ValueError(f"unknown cluster_generator: {cluster_generator}")
        except (RuntimeError, ValueError):
            continue

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
        if nx.edge_connectivity(graph, source, target) != kappa:
            continue
        return graph, source, target

    raise RuntimeError(f"could not sample graph n={n}, e={edge_count}, kappa={kappa}")


def count_low_order_minimal_cutsets(
    graph: nx.Graph,
    source: int,
    target: int,
    max_extra: int,
    max_subset_tests: int | None = None,
) -> dict[str, int]:
    kappa = nx.edge_connectivity(graph, source, target)
    edges = edge_list(graph)
    counts: dict[int, int] = {kappa + offset: 0 for offset in range(max_extra + 1)}
    tested = 0
    for size in range(kappa, kappa + max_extra + 1):
        for combo in itertools.combinations(edges, size):
            tested += 1
            if max_subset_tests is not None and tested > max_subset_tests:
                raise RuntimeError(
                    "cutset enumeration exceeded max_subset_tests="
                    f"{max_subset_tests}"
                )
            removed = set(combo)
            if st_connected_without(graph, removed, source, target):
                continue
            minimal = True
            if size > kappa:
                for sub_combo in itertools.combinations(combo, size - 1):
                    if not st_connected_without(graph, set(sub_combo), source, target):
                        minimal = False
                        break
            if minimal:
                counts[size] += 1
    return {
        "kappa": int(kappa),
        "N_kappa": counts.get(kappa, 0),
        "N_kappa_plus_1": counts.get(kappa + 1, 0),
        "N_kappa_plus_2": counts.get(kappa + 2, 0),
        "cutset_subset_tests": tested,
        "cutset_count_status": "exact",
    }


def cutset_sanity_cases() -> list[dict[str, object]]:
    cases: list[tuple[str, nx.Graph, int, int, dict[str, int]]] = []
    path = nx.path_graph(5)
    cases.append(("path_5", path, 0, 4, {"kappa": 1, "N_kappa": 4}))
    cycle = nx.cycle_graph(6)
    cases.append(("cycle_6_opposite", cycle, 0, 3, {"kappa": 2, "N_kappa": 9}))
    complete = nx.complete_graph(5)
    cases.append(("complete_5", complete, 0, 1, {"kappa": 4, "N_kappa": 2}))

    results: list[dict[str, object]] = []
    for name, graph, source, target, expected in cases:
        actual = count_low_order_minimal_cutsets(graph, source, target, 2)
        row: dict[str, object] = {
            "case": name,
            "nodes": graph.number_of_nodes(),
            "edges": graph.number_of_edges(),
            "source": source,
            "target": target,
            "passed": True,
        }
        for key, value in expected.items():
            observed = actual[key]
            row[f"expected_{key}"] = value
            row[f"actual_{key}"] = observed
            if observed != value:
                row["passed"] = False
        results.append(row)
        if not row["passed"]:
            raise RuntimeError(f"cutset sanity failed: {row}")
    return results


def graph_static_features(graph: nx.Graph, source: int, target: int) -> dict[str, object]:
    degrees = np.array([deg for _, deg in graph.degree()], dtype=float)
    laplacian = nx.laplacian_matrix(graph, nodelist=sorted(graph.nodes())).toarray().astype(float)
    lap_eigs = np.linalg.eigvalsh(laplacian)
    betweenness = np.array(list(nx.betweenness_centrality(graph).values()), dtype=float)
    bridges = list(nx.bridges(graph))
    st_bridge_count = sum(
        1
        for edge in bridges
        if not st_connected_without(graph, {norm_edge(edge)}, source, target)
    )

    lap_pinv = np.linalg.pinv(laplacian)
    src_idx = sorted(graph.nodes()).index(source)
    dst_idx = sorted(graph.nodes()).index(target)
    effective_resistance = (
        lap_pinv[src_idx, src_idx]
        + lap_pinv[dst_idx, dst_idx]
        - 2.0 * lap_pinv[src_idx, dst_idx]
    )

    return {
        "n": graph.number_of_nodes(),
        "m": graph.number_of_edges(),
        "edge_density": nx.density(graph),
        "mean_degree": float(degrees.mean()),
        "degree_variance": float(degrees.var()),
        "degree_s": int(graph.degree(source)),
        "degree_t": int(graph.degree(target)),
        "shortest_st_path_length": int(nx.shortest_path_length(graph, source, target)),
        "bridge_count": len(bridges),
        "st_bridge_count": st_bridge_count,
        "algebraic_connectivity": float(lap_eigs[1]) if len(lap_eigs) > 1 else 0.0,
        "laplacian_spectral_radius": float(lap_eigs[-1]) if len(lap_eigs) else 0.0,
        "effective_resistance_st": float(effective_resistance),
        "betweenness_mean": float(betweenness.mean()),
        "betweenness_max": float(betweenness.max()),
        "betweenness_std": float(betweenness.std()),
    }


def assign_splits(selected: list[dict[str, object]], split_seed: int) -> None:
    by_cell: dict[tuple[int, int, int], list[dict[str, object]]] = defaultdict(list)
    for row in selected:
        by_cell[(int(row["n"]), int(row["m"]), int(row["kappa"]))].append(row)

    for key, rows in by_cell.items():
        rows.sort(key=lambda item: str(item["graph_id"]))
        rng = random.Random(stable_seed(split_seed, *key))
        rng.shuffle(rows)
        if len(rows) < 5:
            raise RuntimeError(f"split cell needs at least 5 graphs: {key}")
        validation_count = max(1, math.floor(0.2 * len(rows)))
        test_count = max(1, math.floor(0.2 * len(rows)))
        train_count = len(rows) - validation_count - test_count
        if train_count < 1:
            raise RuntimeError(f"split cell has no training rows: {key}")
        for idx, row in enumerate(rows):
            if idx < train_count:
                row["split"] = "train"
            elif idx < train_count + validation_count:
                row["split"] = "validation"
            else:
                row["split"] = "test"


def simulate_failure(
    graph: nx.Graph,
    edges: list[Edge],
    source: int,
    target: int,
    q_value: float,
    seed: int,
) -> tuple[list[int], bool]:
    rng = random.Random(seed)
    failed_indices = [idx for idx, _ in enumerate(edges) if rng.random() < q_value]
    removed = {edges[idx] for idx in failed_indices}
    disconnected = not st_connected_without(graph, removed, source, target)
    return failed_indices, disconnected


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({name: row.get(name, "") for name in fieldnames})


def main() -> int:
    started_at = time.monotonic()
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--n-values", default="12,14")
    parser.add_argument("--edge-factors", default="2.0")
    parser.add_argument("--kappas", default="2,3")
    parser.add_argument("--q-values", default="0.12,0.24,0.36")
    parser.add_argument("--candidate-count", type=int, default=30)
    parser.add_argument("--graphs-per-cell", type=int, default=5)
    parser.add_argument("--failure-samples", type=int, default=32)
    parser.add_argument("--seed", type=int, default=51203)
    parser.add_argument("--split-seed", type=int, default=61213)
    parser.add_argument("--max-attempts", type=int, default=300)
    parser.add_argument("--max-cutset-subset-tests", type=int, default=250000)
    parser.add_argument(
        "--cluster-generator",
        choices=["random", "constructive"],
        default="random",
        help="Cluster generator used before adding the kappa cross edges.",
    )
    args = parser.parse_args()

    n_values = parse_int_list(args.n_values)
    edge_factors = parse_float_list(args.edge_factors)
    kappas = parse_int_list(args.kappas)
    q_values = parse_float_list(args.q_values)

    args.output_dir.mkdir(parents=True, exist_ok=True)
    log_progress(
        "start "
        f"out={args.output_dir} n={n_values} edge_factors={edge_factors} "
        f"kappas={kappas} q={q_values} candidates={args.candidate_count} "
        f"graphs_per_cell={args.graphs_per_cell} K={args.failure_samples} "
        f"cluster_generator={args.cluster_generator}"
    )
    cutset_sanity = cutset_sanity_cases()
    log_progress(f"cutset sanity passed cases={len(cutset_sanity)}")

    selected: list[dict[str, object]] = []
    graph_objects: dict[str, nx.Graph] = {}
    rejection_counts: dict[str, int] = defaultdict(int)

    for n in n_values:
        for edge_factor_index, edge_factor in enumerate(edge_factors):
            edge_count = int(round(n * edge_factor))
            for kappa in kappas:
                cell_started_at = time.monotonic()
                log_progress(
                    f"cell start n={n} m={edge_count} kappa={kappa} "
                    f"target_candidates={args.candidate_count}"
                )
                candidates: list[dict[str, object]] = []
                attempts = 0
                while len(candidates) < args.candidate_count and attempts < args.candidate_count * 30:
                    attempts += 1
                    seed = stable_seed(args.seed, n, edge_factor_index, kappa, attempts)
                    rng = random.Random(seed)
                    try:
                        graph, source, target = make_two_cluster_graph(
                            n=n,
                            edge_count=edge_count,
                            kappa=kappa,
                            rng=rng,
                            max_attempts=args.max_attempts,
                            cluster_generator=args.cluster_generator,
                        )
                        cut_counts = count_low_order_minimal_cutsets(
                            graph,
                            source,
                            target,
                            2,
                            max_subset_tests=args.max_cutset_subset_tests,
                        )
                    except RuntimeError:
                        rejection_counts[f"sample_failed_n{n}_m{edge_count}_k{kappa}"] += 1
                        if attempts % 50 == 0:
                            log_progress(
                                f"cell progress n={n} m={edge_count} kappa={kappa} "
                                f"attempts={attempts} accepted={len(candidates)} "
                                f"elapsed_s={time.monotonic() - cell_started_at:.1f}"
                            )
                        continue

                    graph_id = f"g_n{n}_m{edge_count}_k{kappa}_{len(candidates):03d}"
                    candidates.append(
                        {
                            "graph_id": graph_id,
                            "n": n,
                            "m": edge_count,
                            "kappa": kappa,
                            "edge_factor": edge_factor,
                            "source": source,
                            "target": target,
                            "seed": seed,
                            "cut_counts": cut_counts,
                            "graph": graph,
                        }
                    )
                    log_progress(
                        f"accepted {graph_id} attempts={attempts} "
                        f"subset_tests={cut_counts['cutset_subset_tests']} "
                        f"elapsed_s={time.monotonic() - cell_started_at:.1f}"
                    )

                if len(candidates) < args.graphs_per_cell:
                    raise RuntimeError(
                        f"not enough candidates for n={n}, m={edge_count}, kappa={kappa}"
                    )
                for row in candidates[: args.graphs_per_cell]:
                    graph = row.pop("graph")
                    graph_objects[str(row["graph_id"])] = graph
                    selected.append(row)
                log_progress(
                    f"cell done n={n} m={edge_count} kappa={kappa} "
                    f"accepted={len(candidates)} retained={args.graphs_per_cell} "
                    f"elapsed_s={time.monotonic() - cell_started_at:.1f}"
                )

    assign_splits(selected, args.split_seed)
    log_progress(f"split assigned graphs={len(selected)}")

    graph_rows: list[dict[str, object]] = []
    cutset_rows: list[dict[str, object]] = []
    feature_rows: list[dict[str, object]] = []
    sample_rows: list[dict[str, object]] = []
    label_rows: list[dict[str, object]] = []

    for graph_index, meta in enumerate(selected):
        graph_id = str(meta["graph_id"])
        graph = graph_objects[graph_id]
        source = int(meta["source"])
        target = int(meta["target"])
        split = str(meta["split"])
        edges = edge_list(graph)
        cut_counts = dict(meta["cut_counts"])
        static = graph_static_features(graph, source, target)

        graph_rows.append(
            {
                "graph_id": graph_id,
                "split": split,
                "n": meta["n"],
                "m": meta["m"],
                "kappa": meta["kappa"],
                "edge_factor": meta["edge_factor"],
                "source": source,
                "target": target,
                "seed": meta["seed"],
                "edges": json.dumps(edges),
            }
        )
        cutset_rows.append({"graph_id": graph_id, "split": split, **cut_counts})
        log_progress(
            f"simulate graph {graph_index + 1}/{len(selected)} "
            f"graph_id={graph_id} split={split}"
        )

        for q_index, q_value in enumerate(q_values):
            q_id = f"q{q_index:02d}"
            n_k = int(cut_counts["N_kappa"])
            n_k1 = int(cut_counts["N_kappa_plus_1"])
            n_k2 = int(cut_counts["N_kappa_plus_2"])
            kappa = int(cut_counts["kappa"])
            term_k = n_k * (q_value**kappa)
            term_k1 = n_k1 * (q_value ** (kappa + 1))
            term_k2 = n_k2 * (q_value ** (kappa + 2))
            q_power_kappa = q_value**kappa
            q_power_kappa_plus_1 = q_value ** (kappa + 1)
            q_power_kappa_plus_2 = q_value ** (kappa + 2)
            h_cut_2 = term_k + term_k1 + term_k2
            row_id = f"{graph_id}_{q_id}"
            feature_rows.append(
                {
                    "row_id": row_id,
                    "graph_id": graph_id,
                    "q_id": q_id,
                    "split": split,
                    "q": q_value,
                    **static,
                    **cut_counts,
                    "q_power_kappa": q_power_kappa,
                    "q_power_kappa_plus_1": q_power_kappa_plus_1,
                    "q_power_kappa_plus_2": q_power_kappa_plus_2,
                    "N_kappa_q_kappa": term_k,
                    "N_kappa_plus_1_q": term_k1,
                    "N_kappa_plus_2_q": term_k2,
                    "H_cut_2": h_cut_2,
                    "log1p_H_cut_2": math.log1p(h_cut_2),
                }
            )

            z_value = 0
            for sample_index in range(args.failure_samples):
                sample_seed = stable_seed(args.seed, graph_index, q_index, sample_index, 991)
                failed_indices, disconnected = simulate_failure(
                    graph, edges, source, target, q_value, sample_seed
                )
                if disconnected:
                    z_value += 1
                sample_rows.append(
                    {
                        "row_id": row_id,
                        "graph_id": graph_id,
                        "q_id": q_id,
                        "split": split,
                        "sample_index": sample_index,
                        "sample_seed": sample_seed,
                        "failed_edge_indices": json.dumps(failed_indices),
                        "disconnected": int(disconnected),
                    }
                )
            label_rows.append(
                {
                    "row_id": row_id,
                    "graph_id": graph_id,
                    "q_id": q_id,
                    "split": split,
                    "q": q_value,
                    "K": args.failure_samples,
                    "z": z_value,
                    "disconnect_fraction": z_value / args.failure_samples,
                }
            )

    graph_fields = [
        "graph_id",
        "split",
        "n",
        "m",
        "kappa",
        "edge_factor",
        "source",
        "target",
        "seed",
        "edges",
    ]
    cutset_fields = [
        "graph_id",
        "split",
        "kappa",
        "N_kappa",
        "N_kappa_plus_1",
        "N_kappa_plus_2",
        "cutset_subset_tests",
        "cutset_count_status",
    ]
    feature_fields = list(feature_rows[0].keys()) if feature_rows else []
    sample_fields = [
        "row_id",
        "graph_id",
        "q_id",
        "split",
        "sample_index",
        "sample_seed",
        "failed_edge_indices",
        "disconnected",
    ]
    label_fields = ["row_id", "graph_id", "q_id", "split", "q", "K", "z", "disconnect_fraction"]

    write_csv(args.output_dir / "graphs.csv", graph_rows, graph_fields)
    log_progress(f"wrote graphs.csv rows={len(graph_rows)}")
    write_csv(args.output_dir / "cutsets.csv", cutset_rows, cutset_fields)
    log_progress(f"wrote cutsets.csv rows={len(cutset_rows)}")
    write_csv(args.output_dir / "features.csv", feature_rows, feature_fields)
    log_progress(f"wrote features.csv rows={len(feature_rows)}")
    write_csv(args.output_dir / "failure_samples.csv", sample_rows, sample_fields)
    log_progress(f"wrote failure_samples.csv rows={len(sample_rows)}")
    write_csv(args.output_dir / "labels.csv", label_rows, label_fields)
    log_progress(f"wrote labels.csv rows={len(label_rows)}")
    (args.output_dir / "cutset_count_sanity.json").write_text(
        json.dumps(
            {
                "status": "passed",
                "method": "exact_subset_enumeration_low_order_minimal_st_cutsets",
                "case_count": len(cutset_sanity),
                "cases": cutset_sanity,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )

    summary = {
        "status": "smoke_generated_not_evidence",
        "seed": args.seed,
        "split_seed": args.split_seed,
        "n_values": n_values,
        "edge_factors": edge_factors,
        "kappas": kappas,
        "q_values": q_values,
        "candidate_count": args.candidate_count,
        "graphs_per_cell": args.graphs_per_cell,
        "failure_samples": args.failure_samples,
        "cluster_generator": args.cluster_generator,
        "max_cutset_subset_tests": args.max_cutset_subset_tests,
        "graph_count": len(graph_rows),
        "feature_row_count": len(feature_rows),
        "failure_sample_count": len(sample_rows),
        "label_count": len(label_rows),
        "cutset_count_method": "exact_subset_enumeration_low_order_minimal_st_cutsets",
        "cutset_count_sanity": "passed",
        "cutset_count_sanity_cases": len(cutset_sanity),
        "split_method": "seeded_random_permutation_within_n_m_kappa_train_remainder_val_floor20_test_floor20",
        "rejection_counts": dict(sorted(rejection_counts.items())),
        "output_files": [
            "graphs.csv",
            "cutsets.csv",
            "features.csv",
            "failure_samples.csv",
            "labels.csv",
            "cutset_count_sanity.json",
        ],
    }
    (args.output_dir / "generation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    log_progress(f"done elapsed_s={time.monotonic() - started_at:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
