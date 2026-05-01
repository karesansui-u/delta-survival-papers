#!/usr/bin/env python3
"""Generate a pre-freeze A06-stop BEC peeling / stopping-set smoke dataset."""

from __future__ import annotations

import argparse
import csv
import itertools
import json
import math
import random
import sys
import time
from collections import defaultdict
from pathlib import Path

import numpy as np


def log_progress(message: str) -> None:
    print(f"[a06-stop-generate] {message}", file=sys.stderr, flush=True)


def parse_int_list(raw: str) -> list[int]:
    return [int(part.strip()) for part in raw.split(",") if part.strip()]


def parse_float_list(raw: str) -> list[float]:
    return [float(part.strip()) for part in raw.split(",") if part.strip()]


def stable_seed(*parts: int) -> int:
    value = 7919
    for part in parts:
        value = (value * 1000003 + int(part)) % (2**32)
    return value


def rank_gf2(matrix: np.ndarray) -> int:
    mat = np.array(matrix, dtype=np.uint8, copy=True) & 1
    if mat.size == 0:
        return 0
    rows, cols = mat.shape
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if mat[row, col]:
                pivot = row
                break
        if pivot is None:
            continue
        if pivot != rank:
            mat[[rank, pivot]] = mat[[pivot, rank]]
        for row in range(rows):
            if row != rank and mat[row, col]:
                mat[row, :] ^= mat[rank, :]
        rank += 1
        if rank == rows:
            break
    return rank


def column_to_int(column: np.ndarray) -> int:
    value = 0
    for idx, bit in enumerate(column.tolist()):
        if int(bit):
            value |= 1 << idx
    return value


def matrix_to_column_ints(matrix: np.ndarray) -> list[int]:
    return [column_to_int(matrix[:, idx]) for idx in range(matrix.shape[1])]


def column_ints_to_matrix(columns: list[int], rows: int) -> np.ndarray:
    matrix = np.zeros((rows, len(columns)), dtype=np.uint8)
    for col_idx, value in enumerate(columns):
        for row_idx in range(rows):
            matrix[row_idx, col_idx] = (int(value) >> row_idx) & 1
    return matrix


def generate_sparse_parity_check(
    n: int,
    r: int,
    column_weight: int,
    rng: random.Random,
    max_attempts: int,
) -> np.ndarray:
    if column_weight > r:
        raise ValueError(f"column_weight {column_weight} exceeds r={r}")
    for _ in range(max_attempts):
        matrix = np.zeros((r, n), dtype=np.uint8)
        for col in range(n):
            rows = rng.sample(range(r), column_weight)
            matrix[rows, col] = 1
        if rank_gf2(matrix) == r:
            return matrix
    raise RuntimeError(f"could not generate full-rank H for n={n}, r={r}")


def is_stopping_set(matrix: np.ndarray, columns: tuple[int, ...]) -> bool:
    if not columns:
        return False
    sub = matrix[:, columns]
    row_weights = sub.sum(axis=1)
    return bool(np.all(row_weights != 1))


def stopping_set_counts(matrix: np.ndarray, max_order: int) -> dict[str, int]:
    n = matrix.shape[1]
    counts = {order: 0 for order in range(2, max_order + 1)}
    tested = 0
    for order in range(2, max_order + 1):
        for combo in itertools.combinations(range(n), order):
            tested += 1
            if is_stopping_set(matrix, combo):
                counts[order] += 1
    nonzero = [order for order, count in counts.items() if count > 0]
    result: dict[str, int | str] = {
        "stopping_subset_tests": tested,
        "stopping_count_status": "exact_all",
        "min_stopping_order": min(nonzero) if nonzero else 99,
    }
    for order in range(2, max_order + 1):
        result[f"N_stop_{order}"] = counts[order]
    return result  # type: ignore[return-value]


def dependency_counts(matrix: np.ndarray, max_order: int) -> dict[str, int]:
    n = matrix.shape[1]
    counts = {order: 0 for order in range(2, max_order + 1)}
    tested = 0
    for order in range(2, max_order + 1):
        for combo in itertools.combinations(range(n), order):
            tested += 1
            if rank_gf2(matrix[:, combo]) < order:
                counts[order] += 1
    nonzero = [order for order, count in counts.items() if count > 0]
    result: dict[str, int | str] = {
        "dependency_subset_tests": tested,
        "dependency_count_status": "exact",
        "min_dependency_order": min(nonzero) if nonzero else 99,
    }
    for order in range(2, max_order + 1):
        result[f"N_dep_{order}"] = counts[order]
    return result  # type: ignore[return-value]


def peeling_residual(matrix: np.ndarray, erased: list[int]) -> list[int]:
    residual = set(erased)
    if not residual:
        return []
    supports = [set(np.flatnonzero(matrix[row, :]).tolist()) for row in range(matrix.shape[0])]
    changed = True
    while changed:
        changed = False
        for support in supports:
            unknown = support & residual
            if len(unknown) == 1:
                residual.remove(next(iter(unknown)))
                changed = True
    return sorted(residual)


def simulate_bec_sample(
    matrix: np.ndarray,
    p_value: float,
    seed: int,
) -> tuple[list[int], list[int], bool, int, int, bool]:
    rng = random.Random(seed)
    erased = [idx for idx in range(matrix.shape[1]) if rng.random() < p_value]
    residual = peeling_residual(matrix, erased)
    erased_rank = rank_gf2(matrix[:, erased]) if erased else 0
    ambiguity_dim = len(erased) - erased_rank
    return erased, residual, bool(residual), erased_rank, ambiguity_dim, ambiguity_dim > 0


def degree_features(matrix: np.ndarray) -> dict[str, float]:
    check_degrees = matrix.sum(axis=1).astype(float)
    variable_degrees = matrix.sum(axis=0).astype(float)
    result = {
        "parity_check_density": float(matrix.mean()),
        "check_degree_mean": float(check_degrees.mean()),
        "check_degree_variance": float(check_degrees.var()),
        "check_degree_min": float(check_degrees.min()),
        "check_degree_max": float(check_degrees.max()),
        "variable_degree_mean": float(variable_degrees.mean()),
        "variable_degree_variance": float(variable_degrees.var()),
        "variable_degree_min": float(variable_degrees.min()),
        "variable_degree_max": float(variable_degrees.max()),
    }
    for degree in range(1, 5):
        result[f"check_degree_count_{degree}"] = int(np.sum(check_degrees == degree))
        result[f"variable_degree_count_{degree}"] = int(np.sum(variable_degrees == degree))
    result["check_degree_count_ge5"] = int(np.sum(check_degrees >= 5))
    result["variable_degree_count_ge5"] = int(np.sum(variable_degrees >= 5))
    return result


def assign_splits(code_rows: list[dict[str, object]], split_seed: int) -> None:
    by_cell: dict[tuple[int, int, int], list[dict[str, object]]] = defaultdict(list)
    for row in code_rows:
        by_cell[(int(row["n"]), int(row["k"]), int(row["column_weight"]))].append(row)
    for key, rows in by_cell.items():
        rows.sort(key=lambda item: str(item["code_id"]))
        rng = random.Random(stable_seed(split_seed, *key))
        rng.shuffle(rows)
        if len(rows) < 5:
            raise RuntimeError(f"split cell needs at least 5 codes: {key}")
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


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fieldnames})


def sanity_cases() -> list[dict[str, object]]:
    cases = []
    identity = np.eye(3, dtype=np.uint8)
    cases.append(
        {
            "case": "identity_singletons_not_stopping",
            "passed": not is_stopping_set(identity, (0,)) and peeling_residual(identity, [0, 2]) == [],
        }
    )
    cycle = np.array([[1, 1, 0], [0, 1, 1], [1, 0, 1]], dtype=np.uint8)
    cases.append(
        {
            "case": "triangle_all_three_stopping",
            "passed": is_stopping_set(cycle, (0, 1, 2)) and peeling_residual(cycle, [0, 1, 2]) == [0, 1, 2],
        }
    )
    pair = np.array([[1, 1], [1, 1]], dtype=np.uint8)
    cases.append(
        {
            "case": "parallel_pair_stopping",
            "passed": is_stopping_set(pair, (0, 1)) and peeling_residual(pair, [0, 1]) == [0, 1],
        }
    )
    return cases


def main() -> int:
    started_at = time.monotonic()
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--n-values", default="24,32")
    parser.add_argument("--rates", default="0.50")
    parser.add_argument("--column-weight", type=int, default=3)
    parser.add_argument("--q-values", default="0.18,0.24,0.30,0.36")
    parser.add_argument("--codes-per-cell", type=int, default=8)
    parser.add_argument("--samples", type=int, default=64)
    parser.add_argument("--stopping-order", type=int, default=5)
    parser.add_argument("--dependency-order", type=int, default=4)
    parser.add_argument("--seed", type=int, default=12221)
    parser.add_argument("--split-seed", type=int, default=12231)
    parser.add_argument("--max-attempts", type=int, default=500)
    parser.add_argument("--microbench-codes", type=int, default=3)
    args = parser.parse_args()

    n_values = parse_int_list(args.n_values)
    rates = parse_float_list(args.rates)
    q_values = parse_float_list(args.q_values)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    log_progress(
        f"start out={args.output_dir} n={n_values} rates={rates} "
        f"column_weight={args.column_weight} q={q_values} codes_per_cell={args.codes_per_cell} "
        f"samples={args.samples} stopping_order={args.stopping_order}"
    )

    sanity = sanity_cases()
    if not all(bool(row["passed"]) for row in sanity):
        raise RuntimeError(f"sanity cases failed: {sanity}")
    log_progress("sanity cases passed")

    code_rows: list[dict[str, object]] = []
    matrices: dict[str, np.ndarray] = {}
    stopping_rows: list[dict[str, object]] = []
    dependency_rows: list[dict[str, object]] = []
    feature_rows: list[dict[str, object]] = []
    sample_rows: list[dict[str, object]] = []
    label_rows: list[dict[str, object]] = []
    microbench_rows: list[dict[str, object]] = []

    for n in n_values:
        for rate_index, rate in enumerate(rates):
            k = int(round(n * rate))
            r = n - k
            if k <= 0 or r <= 0:
                raise ValueError(f"invalid n/rate pair: n={n}, rate={rate}")
            log_progress(f"cell start n={n} k={k} r={r}")
            for code_index in range(args.codes_per_cell):
                seed = stable_seed(args.seed, n, rate_index, args.column_weight, code_index)
                rng = random.Random(seed)
                matrix = generate_sparse_parity_check(
                    n=n,
                    r=r,
                    column_weight=args.column_weight,
                    rng=rng,
                    max_attempts=args.max_attempts,
                )
                code_id = f"code_n{n}_k{k}_cw{args.column_weight}_{code_index:03d}"
                matrices[code_id] = matrix
                bench_start = time.monotonic()
                stops = stopping_set_counts(matrix, args.stopping_order)
                stop_elapsed = time.monotonic() - bench_start
                deps = dependency_counts(matrix, args.dependency_order)
                code_rows.append(
                    {
                        "code_id": code_id,
                        "split": "",
                        "n": n,
                        "k": k,
                        "r": r,
                        "rate": k / n,
                        "column_weight": args.column_weight,
                        "seed": seed,
                        "columns": json.dumps(matrix_to_column_ints(matrix)),
                    }
                )
                stopping_rows.append({"code_id": code_id, **stops})
                dependency_rows.append({"code_id": code_id, **deps})
                if code_index < args.microbench_codes:
                    microbench_rows.append(
                        {
                            "code_id": code_id,
                            "n": n,
                            "k": k,
                            "r": r,
                            "column_weight": args.column_weight,
                            "stopping_order": args.stopping_order,
                            "subset_tests": stops["stopping_subset_tests"],
                            "N_stop_total": sum(int(stops.get(f"N_stop_{j}", 0)) for j in range(2, args.stopping_order + 1)),
                            "elapsed_s": stop_elapsed,
                        }
                    )
                if (code_index + 1) % 4 == 0:
                    log_progress(f"cell progress n={n} k={k} generated={code_index + 1}")
            log_progress(f"cell done n={n} k={k} generated={args.codes_per_cell}")

    assign_splits(code_rows, args.split_seed)
    split_by_code = {str(row["code_id"]): str(row["split"]) for row in code_rows}
    stops_by_code = {str(row["code_id"]): row for row in stopping_rows}
    deps_by_code = {str(row["code_id"]): row for row in dependency_rows}

    for code_index, code_row in enumerate(code_rows):
        code_id = str(code_row["code_id"])
        matrix = matrices[code_id]
        split = split_by_code[code_id]
        static = degree_features(matrix)
        stops = stops_by_code[code_id]
        deps = deps_by_code[code_id]
        log_progress(f"simulate code {code_index + 1}/{len(code_rows)} code_id={code_id}")
        for q_index, q_value in enumerate(q_values):
            q_id = f"q{q_index:02d}"
            stop_terms: dict[str, float] = {}
            stop_norm_terms: dict[str, float] = {}
            h_stop = 0.0
            h_stop_norm = 0.0
            for order in range(2, args.stopping_order + 1):
                count = int(stops.get(f"N_stop_{order}", 0))
                subset_volume = math.comb(int(code_row["n"]), order)
                term = count * (q_value**order)
                norm_term = (count / subset_volume) * (q_value**order)
                stop_terms[f"N_stop_{order}_q{order}"] = term
                stop_norm_terms[f"N_stop_{order}_norm_q{order}"] = norm_term
                h_stop += term
                h_stop_norm += norm_term
            dep_terms: dict[str, float] = {}
            h_dep = 0.0
            for order in range(2, args.dependency_order + 1):
                term = int(deps.get(f"N_dep_{order}", 0)) * (q_value**order)
                dep_terms[f"N_dep_{order}_q{order}"] = term
                h_dep += term
            row_id = f"{code_id}_{q_id}"
            feature_rows.append(
                {
                    "row_id": row_id,
                    "code_id": code_id,
                    "q_id": q_id,
                    "split": split,
                    "q": q_value,
                    "n": code_row["n"],
                    "k": code_row["k"],
                    "r": code_row["r"],
                    "rate": code_row["rate"],
                    "capacity_margin": 1.0 - q_value - float(code_row["rate"]),
                    "column_weight": code_row["column_weight"],
                    **static,
                    **stops,
                    **deps,
                    "q_power_2": q_value**2,
                    "q_power_3": q_value**3,
                    "q_power_4": q_value**4,
                    "q_power_5": q_value**5,
                    **stop_terms,
                    **stop_norm_terms,
                    **dep_terms,
                    "H_stop_5": h_stop,
                    "log1p_H_stop_5": math.log1p(h_stop),
                    "H_stop_5_norm": h_stop_norm,
                    "log1p_H_stop_5_norm": math.log1p(h_stop_norm),
                    "H_dep_4": h_dep,
                    "log1p_H_dep_4": math.log1p(h_dep),
                }
            )
            z_stop = 0
            z_rank = 0
            residual_sum = 0
            ambiguity_sum = 0
            for sample_index in range(args.samples):
                sample_seed = stable_seed(args.seed, code_index, q_index, sample_index, 4111)
                erased, residual, stop_failure, erased_rank, ambiguity_dim, rank_failure = simulate_bec_sample(
                    matrix, q_value, sample_seed
                )
                if stop_failure:
                    z_stop += 1
                if rank_failure:
                    z_rank += 1
                residual_sum += len(residual)
                ambiguity_sum += ambiguity_dim
                sample_rows.append(
                    {
                        "row_id": row_id,
                        "code_id": code_id,
                        "q_id": q_id,
                        "split": split,
                        "sample_index": sample_index,
                        "sample_seed": sample_seed,
                        "erased_indices": json.dumps(erased),
                        "erased_count": len(erased),
                        "peeling_residual": json.dumps(residual),
                        "residual_size": len(residual),
                        "stopping_failure": int(stop_failure),
                        "erased_rank": erased_rank,
                        "ambiguity_dim": ambiguity_dim,
                        "rank_failure": int(rank_failure),
                    }
                )
            label_rows.append(
                {
                    "row_id": row_id,
                    "code_id": code_id,
                    "q_id": q_id,
                    "split": split,
                    "q": q_value,
                    "K": args.samples,
                    "z": z_stop,
                    "failure_fraction": z_stop / args.samples,
                    "rank_z": z_rank,
                    "rank_failure_fraction": z_rank / args.samples,
                    "mean_residual_size": residual_sum / args.samples,
                    "mean_ambiguity_dim": ambiguity_sum / args.samples,
                }
            )

    write_csv(args.output_dir / "codes.csv", code_rows, ["code_id", "split", "n", "k", "r", "rate", "column_weight", "seed", "columns"])
    write_csv(args.output_dir / "stopping_sets.csv", stopping_rows, list(stopping_rows[0].keys()))
    write_csv(args.output_dir / "dependencies.csv", dependency_rows, list(dependency_rows[0].keys()))
    write_csv(args.output_dir / "features.csv", feature_rows, list(feature_rows[0].keys()))
    write_csv(args.output_dir / "erasure_samples.csv", sample_rows, list(sample_rows[0].keys()))
    write_csv(args.output_dir / "labels.csv", label_rows, list(label_rows[0].keys()))
    write_csv(args.output_dir / "counter_microbench.csv", microbench_rows, list(microbench_rows[0].keys()))
    write_csv(args.output_dir / "sanity_cases.csv", sanity, ["case", "passed"])

    summary = {
        "status": "smoke_generated_not_evidence",
        "seed": args.seed,
        "split_seed": args.split_seed,
        "n_values": n_values,
        "rates": rates,
        "column_weight": args.column_weight,
        "q_values": q_values,
        "codes_per_cell": args.codes_per_cell,
        "samples": args.samples,
        "stopping_order": args.stopping_order,
        "dependency_order": args.dependency_order,
        "code_count": len(code_rows),
        "feature_row_count": len(feature_rows),
        "sample_row_count": len(sample_rows),
        "label_row_count": len(label_rows),
        "stopping_count_method": "exact_all_subset_scan",
        "dependency_count_method": "exact_gf2_subset_rank_low_order",
        "split_method": "seeded_random_permutation_within_n_k_column_weight_train_remainder_val_floor20_test_floor20",
        "microbench_mean_elapsed_s": float(np.mean([float(row["elapsed_s"]) for row in microbench_rows])),
        "output_files": [
            "codes.csv",
            "stopping_sets.csv",
            "dependencies.csv",
            "features.csv",
            "erasure_samples.csv",
            "labels.csv",
            "counter_microbench.csv",
            "sanity_cases.csv",
        ],
    }
    (args.output_dir / "generation_summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    log_progress(f"done elapsed_s={time.monotonic() - started_at:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
