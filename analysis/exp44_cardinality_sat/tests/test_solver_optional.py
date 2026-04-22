from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from generator import CardinalityConstraint, SignedLiteral  # noqa: E402
from solver import pysat_available, solve_formula  # noqa: E402


def positive_constraint(type_id: str) -> CardinalityConstraint:
    return CardinalityConstraint(
        type_id,
        (
            SignedLiteral(0, True),
            SignedLiteral(1, True),
            SignedLiteral(2, True),
            SignedLiteral(3, True),
        ),
    )


class SolverOptionalTests(unittest.TestCase):
    def setUp(self) -> None:
        if not pysat_available():
            self.skipTest("PySAT is not installed")

    def test_solver_finds_satisfiable_formula(self) -> None:
        result = solve_formula(
            n=4,
            constraints=[positive_constraint("AL1_4"), positive_constraint("EX2_4")],
            timeout_sec=10,
        )
        self.assertEqual(result.status, "SAT")
        self.assertIs(result.sat_feasible, True)
        self.assertIs(result.assignment_verified, True)

    def test_solver_finds_unsatisfiable_formula(self) -> None:
        result = solve_formula(
            n=4,
            constraints=[positive_constraint("EX1_4"), positive_constraint("EX2_4")],
            timeout_sec=10,
        )
        self.assertEqual(result.status, "UNSAT")
        self.assertIs(result.sat_feasible, False)


if __name__ == "__main__":
    unittest.main()
