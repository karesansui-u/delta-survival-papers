#!/usr/bin/env python3
"""CNF encoding and independent verification for Exp44 Cardinality-SAT."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable

try:  # pragma: no cover
    from .generator import (
        CONSTRAINT_TYPES,
        CardinalityConstraint,
        CardinalitySATInstance,
        SignedLiteral,
        canonical_constraint,
    )
except ImportError:  # pragma: no cover
    from generator import (  # type: ignore
        CONSTRAINT_TYPES,
        CardinalityConstraint,
        CardinalitySATInstance,
        SignedLiteral,
        canonical_constraint,
    )


@dataclass(frozen=True)
class CNFFormula:
    num_vars: int
    clauses: tuple[tuple[int, ...], ...]

    @property
    def num_clauses(self) -> int:
        return len(self.clauses)

    def as_lists(self) -> list[list[int]]:
        return [list(clause) for clause in self.clauses]


def var_id(variable: int) -> int:
    if variable < 0:
        raise ValueError(f"variable must be >= 0, got {variable}")
    return variable + 1


def signed_lit_to_dimacs(lit: SignedLiteral) -> int:
    return var_id(lit.variable) if lit.positive else -var_id(lit.variable)


def pattern_satisfies_type(type_id: str, pattern: tuple[bool, ...]) -> bool:
    ctype = CONSTRAINT_TYPES[type_id]
    count = sum(pattern)
    if ctype.mode == "exactly":
        return count == ctype.threshold
    if ctype.mode == "at_least":
        return count >= ctype.threshold
    raise ValueError(f"unsupported constraint mode: {ctype.mode}")


def forbidden_patterns(type_id: str) -> tuple[tuple[bool, ...], ...]:
    ctype = CONSTRAINT_TYPES[type_id]
    return tuple(
        pattern
        for pattern in product((False, True), repeat=ctype.arity)
        if not pattern_satisfies_type(type_id, pattern)
    )


def clause_excluding_pattern(
    literals: tuple[SignedLiteral, ...],
    pattern: tuple[bool, ...],
) -> tuple[int, ...]:
    if len(literals) != len(pattern):
        raise ValueError("literal / pattern arity mismatch")
    clause: list[int] = []
    for lit, desired_truth in zip(literals, pattern, strict=True):
        dimacs = signed_lit_to_dimacs(lit)
        clause.append(-dimacs if desired_truth else dimacs)
    return tuple(clause)


def encode_constraint(constraint: CardinalityConstraint) -> tuple[tuple[int, ...], ...]:
    canonical = canonical_constraint(constraint)
    return tuple(
        clause_excluding_pattern(canonical.literals, pattern)
        for pattern in forbidden_patterns(canonical.type_id)
    )


def encode_cardinality_sat(
    *,
    n: int,
    constraints: Iterable[CardinalityConstraint],
) -> CNFFormula:
    clauses: list[tuple[int, ...]] = []
    for constraint in constraints:
        canonical = canonical_constraint(constraint)
        for lit in canonical.literals:
            if not 0 <= lit.variable < n:
                raise ValueError(f"literal variable {lit.variable} outside n={n}")
        clauses.extend(encode_constraint(canonical))
    return CNFFormula(num_vars=n, clauses=tuple(clauses))


def encode_instance(instance: CardinalitySATInstance) -> CNFFormula:
    return encode_cardinality_sat(n=instance.n, constraints=instance.constraints)


def decode_model_to_assignment(model: Iterable[int], *, n: int) -> tuple[bool, ...] | None:
    literals = set(model)
    values: list[bool] = []
    for variable in range(n):
        vid = var_id(variable)
        if vid in literals:
            values.append(True)
        elif -vid in literals:
            values.append(False)
        else:
            # PySAT models need not mention variables absent from the CNF.
            # They are semantically free, so choose a deterministic default
            # and let the independent verifier check the original constraints.
            values.append(False)
    return tuple(values)


def verify_assignment(
    *,
    n: int,
    constraints: Iterable[CardinalityConstraint],
    assignment: Iterable[bool],
) -> bool:
    values = tuple(assignment)
    if len(values) != n:
        return False
    for constraint in constraints:
        canonical = canonical_constraint(constraint)
        if any(lit.variable >= n for lit in canonical.literals):
            return False
        if not canonical.is_satisfied(values):
            return False
    return True


def model_satisfies_cnf(model: Iterable[int], formula: CNFFormula) -> bool:
    assignment = {abs(lit): lit > 0 for lit in model if lit != 0}
    for clause in formula.clauses:
        if not any(assignment.get(abs(lit), False) == (lit > 0) for lit in clause):
            return False
    return True


def brute_force_satisfiable(
    *,
    n: int,
    constraints: Iterable[CardinalityConstraint],
) -> tuple[bool, tuple[bool, ...] | None]:
    constraints_tuple = tuple(constraints)
    for values in product((False, True), repeat=n):
        if verify_assignment(n=n, constraints=constraints_tuple, assignment=values):
            return True, tuple(values)
    return False, None
