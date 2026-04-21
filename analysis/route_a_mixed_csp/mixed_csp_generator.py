#!/usr/bin/env python3
"""Deterministic Mixed-CSP instance generation and CNF encoding."""

from __future__ import annotations

import hashlib
import json
import math
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

EXPERIMENT_ID = "route_a_mixed_csp"
VERSION = "1.0.0"

ConstraintType = Literal["sat", "nae", "exact1"]

DRIFTS: dict[ConstraintType, float] = {
    "sat": math.log(8 / 7),
    "nae": math.log(4 / 3),
    "exact1": math.log(8 / 3),
}


@dataclass(frozen=True)
class Constraint:
    kind: ConstraintType
    literals: tuple[int, int, int]

    def to_cnf(self) -> list[list[int]]:
        x, y, z = self.literals
        if self.kind == "sat":
            return [[x, y, z]]
        if self.kind == "nae":
            return [[x, y, z], [-x, -y, -z]]
        if self.kind == "exact1":
            return [[x, y, z], [-x, -y], [-x, -z], [-y, -z]]
        raise ValueError(f"unknown constraint kind: {self.kind}")

    def is_satisfied(self, assignment: dict[int, bool]) -> bool:
        values = [literal_value(lit, assignment) for lit in self.literals]
        if self.kind == "sat":
            return any(values)
        if self.kind == "nae":
            return any(values) and not all(values)
        if self.kind == "exact1":
            return sum(1 for value in values if value) == 1
        raise ValueError(f"unknown constraint kind: {self.kind}")


@dataclass(frozen=True)
class MixedCSPInstance:
    experiment: str
    version: str
    phase: str
    instance_id: str
    instance_seed: str
    instance_seed_int: int
    n: int
    m: int
    density: float
    mixture_id: str
    mixture: dict[str, float]
    counts: dict[str, int]
    constraints: tuple[Constraint, ...]

    @property
    def cnf_clauses(self) -> list[list[int]]:
        clauses: list[list[int]] = []
        for constraint in self.constraints:
            clauses.extend(constraint.to_cnf())
        return clauses

    @property
    def semantic_raw_count(self) -> int:
        return len(self.constraints)

    @property
    def cnf_clause_count(self) -> int:
        return len(self.cnf_clauses)

    @property
    def cnf_variable_count(self) -> int:
        return self.n

    @property
    def L(self) -> float:
        return sum(self.counts[kind] * DRIFTS[kind] for kind in DRIFTS)

    @property
    def first_moment_log_count(self) -> float:
        return self.n * math.log(2) - self.L

    @property
    def predictors(self) -> dict[str, float | int]:
        return {
            "raw_count": self.semantic_raw_count,
            "raw_density": self.density,
            "L": self.L,
            "first_moment_log_count": self.first_moment_log_count,
            "cnf_clause_count": self.cnf_clause_count,
            "n": self.n,
        }

    def assignment_satisfies_semantics(self, model: list[int]) -> bool:
        assignment = {abs(lit): lit > 0 for lit in model if lit != 0}
        used_vars = {abs(lit) for constraint in self.constraints for lit in constraint.literals}
        if any(var not in assignment for var in used_vars):
            return False
        return all(constraint.is_satisfied(assignment) for constraint in self.constraints)


def literal_value(literal: int, assignment: dict[int, bool]) -> bool:
    value = assignment[abs(literal)]
    return value if literal > 0 else not value


def mixture_id(mixture: dict[str, float]) -> str:
    return (
        f"sat_{mixture['sat']:.2f}__"
        f"nae_{mixture['nae']:.2f}__"
        f"exact1_{mixture['exact1']:.2f}"
    )


def seed_digest(phase: str, n: int, density: float, mixture: dict[str, float], instance_idx: int) -> str:
    key = json.dumps(
        {
            "experiment": EXPERIMENT_ID,
            "version": VERSION,
            "phase": phase,
            "n": n,
            "density": density,
            "mixture_id": mixture_id(mixture),
            "instance_idx": instance_idx,
        },
        sort_keys=True,
    )
    return hashlib.sha256(key.encode()).hexdigest()


def seed_int_from_digest(digest: str) -> int:
    return int(digest[:16], 16)


def counts_from_mixture(m: int, mixture: dict[str, float]) -> dict[str, int]:
    counts_sat = math.floor(m * mixture["sat"])
    counts_nae = math.floor(m * mixture["nae"])
    counts_exact1 = m - counts_sat - counts_nae
    return {"sat": counts_sat, "nae": counts_nae, "exact1": counts_exact1}


def generate_constraint(rng: random.Random, kind: ConstraintType, n: int) -> Constraint:
    variables = rng.sample(range(1, n + 1), 3)
    literals = tuple(var if rng.random() < 0.5 else -var for var in variables)
    return Constraint(kind=kind, literals=literals)  # type: ignore[arg-type]


def generate_instance(
    *,
    phase: str,
    n: int,
    density: float,
    mixture: dict[str, float],
    instance_idx: int,
) -> MixedCSPInstance:
    m_float = n * density
    if abs(m_float - round(m_float)) > 1e-9:
        raise ValueError(f"n*density must be integral, got n={n}, density={density}")
    m = int(round(m_float))
    counts = counts_from_mixture(m, mixture)
    digest = seed_digest(phase, n, density, mixture, instance_idx)
    seed_int = seed_int_from_digest(digest)
    rng = random.Random(seed_int)
    constraints: list[Constraint] = []
    for kind in ("sat", "nae", "exact1"):
        for _ in range(counts[kind]):
            constraints.append(generate_constraint(rng, kind, n))  # type: ignore[arg-type]
    rng.shuffle(constraints)
    mid = mixture_id(mixture)
    instance_id = f"{phase}__n{n}__d{density:.2f}__{mid}__i{instance_idx:05d}"
    return MixedCSPInstance(
        experiment=EXPERIMENT_ID,
        version=VERSION,
        phase=phase,
        instance_id=instance_id,
        instance_seed=digest,
        instance_seed_int=seed_int,
        n=n,
        m=m,
        density=density,
        mixture_id=mid,
        mixture=dict(mixture),
        counts=counts,
        constraints=tuple(constraints),
    )


def write_dimacs(instance: MixedCSPInstance, path: Path) -> None:
    clauses = instance.cnf_clauses
    lines = [f"p cnf {instance.n} {len(clauses)}"]
    lines.extend(" ".join(str(lit) for lit in clause) + " 0" for clause in clauses)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def instance_metadata(instance: MixedCSPInstance) -> dict:
    return {
        "experiment": instance.experiment,
        "version": instance.version,
        "phase": instance.phase,
        "instance_id": instance.instance_id,
        "instance_seed": instance.instance_seed,
        "instance_seed_int": instance.instance_seed_int,
        "n": instance.n,
        "m": instance.m,
        "density": instance.density,
        "mixture_id": instance.mixture_id,
        "mixture": instance.mixture,
        "counts": instance.counts,
        "semantic_raw_count": instance.semantic_raw_count,
        "cnf_clause_count": instance.cnf_clause_count,
        "cnf_variable_count": instance.cnf_variable_count,
        "L": instance.L,
        "first_moment_log_count": instance.first_moment_log_count,
        "predictors": instance.predictors,
    }
