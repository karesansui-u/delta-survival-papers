#!/usr/bin/env python3
"""Deterministic Cardinality-SAT instance generation for Exp44."""

from __future__ import annotations

import hashlib
import json
import math
import random
from dataclasses import dataclass
from typing import Any, Iterable

EXPERIMENT_ID = "exp44_cardinality_sat"
VERSION = "0.1.0-draft"

TYPE_ORDER = ("AL1_4", "EX2_4", "EX1_4")


@dataclass(frozen=True)
class ConstraintType:
    type_id: str
    mode: str
    threshold: int
    arity: int
    allowed_patterns: int
    forbidden_patterns: int

    @property
    def drift(self) -> float:
        return math.log((2**self.arity) / self.allowed_patterns)


CONSTRAINT_TYPES: dict[str, ConstraintType] = {
    "AL1_4": ConstraintType(
        type_id="AL1_4",
        mode="at_least",
        threshold=1,
        arity=4,
        allowed_patterns=15,
        forbidden_patterns=1,
    ),
    "EX2_4": ConstraintType(
        type_id="EX2_4",
        mode="exactly",
        threshold=2,
        arity=4,
        allowed_patterns=6,
        forbidden_patterns=10,
    ),
    "EX1_4": ConstraintType(
        type_id="EX1_4",
        mode="exactly",
        threshold=1,
        arity=4,
        allowed_patterns=4,
        forbidden_patterns=12,
    ),
}

MIXTURES: dict[str, dict[str, float]] = {
    "M0_low": {"AL1_4": 1.00, "EX2_4": 0.00, "EX1_4": 0.00},
    "M1_low_med": {"AL1_4": 0.75, "EX2_4": 0.25, "EX1_4": 0.00},
    "M2_bal_low_med": {"AL1_4": 0.50, "EX2_4": 0.50, "EX1_4": 0.00},
    "M3_threeway_low": {"AL1_4": 0.50, "EX2_4": 0.25, "EX1_4": 0.25},
    "M4_threeway_med": {"AL1_4": 0.25, "EX2_4": 0.50, "EX1_4": 0.25},
    "M5_med_high": {"AL1_4": 0.00, "EX2_4": 0.50, "EX1_4": 0.50},
}


@dataclass(frozen=True, order=True)
class SignedLiteral:
    variable: int
    positive: bool

    def eval(self, assignment: tuple[bool, ...]) -> bool:
        value = assignment[self.variable]
        return value if self.positive else not value

    def serialize(self) -> str:
        return f"{self.variable},{1 if self.positive else 0}"


@dataclass(frozen=True)
class CardinalityConstraint:
    type_id: str
    literals: tuple[SignedLiteral, ...]

    @property
    def constraint_type(self) -> ConstraintType:
        return CONSTRAINT_TYPES[self.type_id]

    def truth_count(self, assignment: tuple[bool, ...]) -> int:
        return sum(lit.eval(assignment) for lit in self.literals)

    def is_satisfied(self, assignment: tuple[bool, ...]) -> bool:
        count = self.truth_count(assignment)
        ctype = self.constraint_type
        if ctype.mode == "exactly":
            return count == ctype.threshold
        if ctype.mode == "at_least":
            return count >= ctype.threshold
        raise ValueError(f"unsupported constraint mode: {ctype.mode}")

    def serialize(self) -> str:
        literal_text = "|".join(lit.serialize() for lit in self.literals)
        return f"{self.type_id}|{literal_text}"


def canonical_literals(literals: Iterable[SignedLiteral]) -> tuple[SignedLiteral, ...]:
    canonical = tuple(sorted(literals, key=lambda lit: lit.variable))
    if len(canonical) != 4:
        raise ValueError(f"Exp44 constraints require arity 4, got {len(canonical)}")
    variables = [lit.variable for lit in canonical]
    if len(set(variables)) != len(variables):
        raise ValueError("duplicate variables inside a cardinality constraint are not allowed")
    return canonical


def canonical_constraint(constraint: CardinalityConstraint) -> CardinalityConstraint:
    if constraint.type_id not in CONSTRAINT_TYPES:
        raise ValueError(f"unknown constraint type: {constraint.type_id}")
    return CardinalityConstraint(
        type_id=constraint.type_id,
        literals=canonical_literals(constraint.literals),
    )


def serialize_constraints(constraints: Iterable[CardinalityConstraint]) -> str:
    canonical = [canonical_constraint(c) for c in constraints]
    return "".join(f"{c.serialize()}\n" for c in sorted(canonical, key=lambda c: c.serialize()))


def constraint_list_hash(constraints: Iterable[CardinalityConstraint]) -> str:
    return hashlib.sha256(serialize_constraints(constraints).encode("utf-8")).hexdigest()


def mixture_weights(mixture_id: str) -> dict[str, float]:
    if mixture_id not in MIXTURES:
        raise ValueError(f"unknown mixture_id: {mixture_id}")
    return MIXTURES[mixture_id]


def average_drift(mixture_id: str) -> float:
    weights = mixture_weights(mixture_id)
    return sum(weights[type_id] * CONSTRAINT_TYPES[type_id].drift for type_id in TYPE_ORDER)


def semantic_count_from_rho(*, n: int, rho_fm: float, mixture_id: str) -> int:
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    if rho_fm < 0:
        raise ValueError(f"rho_fm must be nonnegative, got {rho_fm}")
    avg = average_drift(mixture_id)
    if avg <= 0:
        raise ValueError(f"mixture has nonpositive average drift: {mixture_id}")
    return max(1, int(round(rho_fm * n * math.log(2) / avg)))


def type_counts_from_mixture(*, m: int, mixture_id: str) -> dict[str, int]:
    if m < 0:
        raise ValueError(f"m must be nonnegative, got {m}")
    weights = mixture_weights(mixture_id)
    counts: dict[str, int] = {}
    running = 0
    for type_id in TYPE_ORDER[:-1]:
        count = int(math.floor(m * weights[type_id]))
        counts[type_id] = count
        running += count
    counts[TYPE_ORDER[-1]] = m - running
    return counts


def seed_digest(*, phase: str, n: int, rho_fm: float, mixture_id: str, instance_idx: int) -> str:
    key = json.dumps(
        {
            "experiment": EXPERIMENT_ID,
            "version": VERSION,
            "phase": phase,
            "n": n,
            "rho_fm": rho_fm,
            "mixture_id": mixture_id,
            "instance_idx": instance_idx,
        },
        sort_keys=True,
    )
    return hashlib.sha256(key.encode("utf-8")).hexdigest()


def seed_int_from_digest(digest: str) -> int:
    return int(digest[:16], 16)


@dataclass(frozen=True)
class CardinalitySATInstance:
    experiment: str
    version: str
    phase: str
    instance_id: str
    instance_seed: str
    instance_seed_int: int
    n: int
    rho_fm: float
    mixture_id: str
    instance_idx: int
    m_semantic: int
    type_counts: dict[str, int]
    constraints: tuple[CardinalityConstraint, ...]

    @property
    def m_AL1_4(self) -> int:
        return self.type_counts["AL1_4"]

    @property
    def m_EX2_4(self) -> int:
        return self.type_counts["EX2_4"]

    @property
    def m_EX1_4(self) -> int:
        return self.type_counts["EX1_4"]

    @property
    def semantic_density(self) -> float:
        return self.m_semantic / self.n

    @property
    def L(self) -> float:
        return sum(self.type_counts[type_id] * CONSTRAINT_TYPES[type_id].drift for type_id in TYPE_ORDER)

    @property
    def log_state(self) -> float:
        return self.n * math.log(2)

    @property
    def first_moment_log_count(self) -> float:
        return self.log_state - self.L

    @property
    def rho_fm_actual(self) -> float:
        return self.L / self.log_state

    @property
    def cnf_variable_count(self) -> int:
        return self.n

    @property
    def cnf_clause_count(self) -> int:
        return sum(
            self.type_counts[type_id] * CONSTRAINT_TYPES[type_id].forbidden_patterns
            for type_id in TYPE_ORDER
        )

    @property
    def cnf_density(self) -> float:
        return self.cnf_clause_count / self.n

    @property
    def constraint_list_hash(self) -> str:
        return constraint_list_hash(self.constraints)

    def metadata(self) -> dict[str, Any]:
        return {
            "experiment": self.experiment,
            "version": self.version,
            "phase": self.phase,
            "instance_id": self.instance_id,
            "instance_seed": self.instance_seed,
            "instance_seed_int": self.instance_seed_int,
            "n": self.n,
            "rho_fm": self.rho_fm,
            "rho_fm_actual": self.rho_fm_actual,
            "mixture_id": self.mixture_id,
            "mixture_index": mixture_index(self.mixture_id),
            "instance_idx": self.instance_idx,
            "m_semantic": self.m_semantic,
            "m_AL1_4": self.m_AL1_4,
            "m_EX2_4": self.m_EX2_4,
            "m_EX1_4": self.m_EX1_4,
            "semantic_density": self.semantic_density,
            "L": self.L,
            "log_state": self.log_state,
            "first_moment_log_count": self.first_moment_log_count,
            "cnf_variable_count": self.cnf_variable_count,
            "cnf_clause_count": self.cnf_clause_count,
            "cnf_density": self.cnf_density,
            "constraint_list_hash": self.constraint_list_hash,
        }


def mixture_index(mixture_id: str) -> int:
    return sorted(MIXTURES).index(mixture_id)


def make_constraint(rng: random.Random, *, n: int, type_id: str) -> CardinalityConstraint:
    if n < 4:
        raise ValueError(f"n must be at least 4 for arity-4 constraints, got {n}")
    variables = rng.sample(range(n), 4)
    literals = [
        SignedLiteral(variable=variable, positive=bool(rng.getrandbits(1)))
        for variable in variables
    ]
    return CardinalityConstraint(type_id=type_id, literals=canonical_literals(literals))


def generate_instance(
    *,
    phase: str,
    n: int,
    rho_fm: float,
    mixture_id: str,
    instance_idx: int,
) -> CardinalitySATInstance:
    m = semantic_count_from_rho(n=n, rho_fm=rho_fm, mixture_id=mixture_id)
    type_counts = type_counts_from_mixture(m=m, mixture_id=mixture_id)
    digest = seed_digest(
        phase=phase,
        n=n,
        rho_fm=rho_fm,
        mixture_id=mixture_id,
        instance_idx=instance_idx,
    )
    rng = random.Random(seed_int_from_digest(digest))
    constraints: list[CardinalityConstraint] = []
    for type_id in TYPE_ORDER:
        for _ in range(type_counts[type_id]):
            constraints.append(make_constraint(rng, n=n, type_id=type_id))
    rng.shuffle(constraints)
    instance_id = f"{phase}__{mixture_id}__n{n}__rho{rho_fm:.2f}__i{instance_idx:05d}"
    return CardinalitySATInstance(
        experiment=EXPERIMENT_ID,
        version=VERSION,
        phase=phase,
        instance_id=instance_id,
        instance_seed=digest,
        instance_seed_int=seed_int_from_digest(digest),
        n=n,
        rho_fm=rho_fm,
        mixture_id=mixture_id,
        instance_idx=instance_idx,
        m_semantic=m,
        type_counts=type_counts,
        constraints=tuple(constraints),
    )
