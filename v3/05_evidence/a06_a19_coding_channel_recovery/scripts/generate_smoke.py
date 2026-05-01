#!/usr/bin/env python3
"""Generate a finite BEC / binary-linear-code smoke dataset."""

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
    print(f"[coding-generate] {message}", file=sys.stderr, flush=True)


def parse_int_list(raw: str) -> list[int]:
    return [int(part.strip()) for part in raw.split(",") if part.strip()]


def parse_float_list(raw: str) -> list[float]:
    return [float(part.strip()) for part in raw.split(",") if part.strip()]


def stable_seed(*parts: int) -> int:
    value = 3571
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


def dependency_counts(matrix: np.ndarray, max_order: int) -> dict[str, int]:
    n = matrix.shape[1]
    counts = {order: 0 for order in range(2, max_order + 1)}
    tested = 0
    for order in range(2, max_order + 1):
        for combo in itertools.combinations(range(n), order):
            tested += 1
            if rank_gf2(matrix[:, combo]) < order:
                counts[order] += 1
    result = {
        "N_dep_2": counts.get(2, 0),
        "N_dep_3": counts.get(3, 0),
        "N_dep_4": counts.get(4, 0),
        "dependency_subset_tests": tested,
        "dependency_count_status": "exact",
    }
    nonzero = [order for order, count in counts.items() if count > 0]
    result["min_dependency_order"] = min(nonzero) if nonzero else 99
    return result


def code_features(matrix: np.ndarray) -> dict[str, float]:
    row_weights = matrix.sum(axis=1).astype(float)
    col_weights = matrix.sum(axis=0).astype(float)
    return {
        "parity_check_density": float(matrix.mean()),
        "row_weight_mean": float(row_weights.mean()),
        "row_weight_variance": float(row_weights.var()),
        "row_weight_min": float(row_weights.min()),
        "row_weight_max": float(row_weights.max()),
        "column_weight_mean": float(col_weights.mean()),
        "column_weight_variance": float(col_weights.var()),
        "column_weight_min": float(col_weights.min()),
        "column_weight_max": float(col_weights.max()),
    }


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


def simulate_bec_sample(
    matrix: np.ndarray,
    p_value: float,
    seed: int,
) -> tuple[list[int], int, int, bool]:
    rng = random.Random(seed)
    erased = [idx for idx in range(matrix.shape[1]) if rng.random() < p_value]
    erased_rank = rank_gf2(matrix[:, erased]) if erased else 0
    ambiguity_dim = len(erased) - erased_rank
    return erased, erased_rank, ambiguity_dim, ambiguity_dim > 0


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fieldnames})


def main() -> int:
    started_at = time.monotonic()
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--n-values", default="24,32")
    parser.add_argument("--rates", default="0.50")
    parser.add_argument("--column-weight", type=int, default=3)
    parser.add_argument("--q-values", default="0.18,0.24,0.30,0.36")
    parser.add_argument("--codes-per-cell", type=int, default=40)
    parser.add_argument("--samples", type=int, default=128)
    parser.add_argument("--dependency-order", type=int, default=4)
    parser.add_argument("--seed", type=int, default=81221)
    parser.add_argument("--split-seed", type=int, default=81231)
    parser.add_argument("--max-attempts", type=int, default=500)
    args = parser.parse_args()

    n_values = parse_int_list(args.n_values)
    rates = parse_float_list(args.rates)
    q_values = parse_float_list(args.q_values)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    log_progress(
        f"start out={args.output_dir} n={n_values} rates={rates} "
        f"column_weight={args.column_weight} q={q_values} "
        f"codes_per_cell={args.codes_per_cell} samples={args.samples}"
    )

    code_rows: list[dict[str, object]] = []
    matrices: dict[str, np.ndarray] = {}
    dependency_rows: list[dict[str, object]] = []
    feature_rows: list[dict[str, object]] = []
    sample_rows: list[dict[str, object]] = []
    label_rows: list[dict[str, object]] = []

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
                dependency_rows.append({"code_id": code_id, **deps})
                if (code_index + 1) % 10 == 0:
                    log_progress(f"cell progress n={n} k={k} generated={code_index + 1}")
            log_progress(f"cell done n={n} k={k} generated={args.codes_per_cell}")

    assign_splits(code_rows, args.split_seed)
    split_by_code = {str(row["code_id"]): str(row["split"]) for row in code_rows}
    deps_by_code = {str(row["code_id"]): row for row in dependency_rows}

    for code_index, code_row in enumerate(code_rows):
        code_id = str(code_row["code_id"])
        matrix = matrices[code_id]
        split = split_by_code[code_id]
        static = code_features(matrix)
        deps = deps_by_code[code_id]
        n_dep_2 = int(deps["N_dep_2"])
        n_dep_3 = int(deps["N_dep_3"])
        n_dep_4 = int(deps["N_dep_4"])
        log_progress(f"simulate code {code_index + 1}/{len(code_rows)} code_id={code_id}")
        for q_index, q_value in enumerate(q_values):
            q_id = f"q{q_index:02d}"
            term2 = n_dep_2 * (q_value**2)
            term3 = n_dep_3 * (q_value**3)
            term4 = n_dep_4 * (q_value**4)
            h_dep_4 = term2 + term3 + term4
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
                    **deps,
                    "q_power_2": q_value**2,
                    "q_power_3": q_value**3,
                    "q_power_4": q_value**4,
                    "N_dep_2_q2": term2,
                    "N_dep_3_q3": term3,
                    "N_dep_4_q4": term4,
                    "H_dep_4": h_dep_4,
                    "log1p_H_dep_4": math.log1p(h_dep_4),
                }
            )
            z_value = 0
            ambiguity_sum = 0
            for sample_index in range(args.samples):
                sample_seed = stable_seed(args.seed, code_index, q_index, sample_index, 1777)
                erased, erased_rank, ambiguity_dim, failure = simulate_bec_sample(
                    matrix, q_value, sample_seed
                )
                if failure:
                    z_value += 1
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
                        "erased_rank": erased_rank,
                        "ambiguity_dim": ambiguity_dim,
                        "failure": int(failure),
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
                    "z": z_value,
                    "failure_fraction": z_value / args.samples,
                    "mean_ambiguity_dim": ambiguity_sum / args.samples,
                }
            )

    write_csv(
        args.output_dir / "codes.csv",
        code_rows,
        ["code_id", "split", "n", "k", "r", "rate", "column_weight", "seed", "columns"],
    )
    write_csv(
        args.output_dir / "dependencies.csv",
        dependency_rows,
        [
            "code_id",
            "N_dep_2",
            "N_dep_3",
            "N_dep_4",
            "dependency_subset_tests",
            "dependency_count_status",
            "min_dependency_order",
        ],
    )
    write_csv(args.output_dir / "features.csv", feature_rows, list(feature_rows[0].keys()))
    write_csv(
        args.output_dir / "erasure_samples.csv",
        sample_rows,
        [
            "row_id",
            "code_id",
            "q_id",
            "split",
            "sample_index",
            "sample_seed",
            "erased_indices",
            "erased_count",
            "erased_rank",
            "ambiguity_dim",
            "failure",
        ],
    )
    write_csv(
        args.output_dir / "labels.csv",
        label_rows,
        ["row_id", "code_id", "q_id", "split", "q", "K", "z", "failure_fraction", "mean_ambiguity_dim"],
    )

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
        "dependency_order": args.dependency_order,
        "code_count": len(code_rows),
        "feature_row_count": len(feature_rows),
        "sample_row_count": len(sample_rows),
        "label_row_count": len(label_rows),
        "dependency_count_method": "exact_gf2_subset_rank_low_order",
        "split_method": "seeded_random_permutation_within_n_k_column_weight_train_remainder_val_floor20_test_floor20",
        "output_files": [
            "codes.csv",
            "dependencies.csv",
            "features.csv",
            "erasure_samples.csv",
            "labels.csv",
        ],
    }
    (args.output_dir / "generation_summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n"
    )
    log_progress(f"done elapsed_s={time.monotonic() - started_at:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
