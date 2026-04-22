from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from cnf_encoder import (  # noqa: E402
    brute_force_satisfiable,
    encode_cardinality_sat,
    forbidden_patterns,
    verify_assignment,
)
from generator import CardinalityConstraint, SignedLiteral  # noqa: E402


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


class CNFEncoderTests(unittest.TestCase):
    def test_forbidden_pattern_counts(self) -> None:
        self.assertEqual(len(forbidden_patterns("AL1_4")), 1)
        self.assertEqual(len(forbidden_patterns("EX2_4")), 10)
        self.assertEqual(len(forbidden_patterns("EX1_4")), 12)

    def test_clause_count_matches_direct_forbidden_encoding(self) -> None:
        formula = encode_cardinality_sat(
            n=4,
            constraints=[
                positive_constraint("AL1_4"),
                positive_constraint("EX2_4"),
                positive_constraint("EX1_4"),
            ],
        )
        self.assertEqual(formula.num_vars, 4)
        self.assertEqual(formula.num_clauses, 23)

    def test_verify_assignment(self) -> None:
        constraint = positive_constraint("EX1_4")
        self.assertTrue(verify_assignment(n=4, constraints=[constraint], assignment=(True, False, False, False)))
        self.assertFalse(verify_assignment(n=4, constraints=[constraint], assignment=(True, True, False, False)))

    def test_bruteforce_detects_contradiction(self) -> None:
        constraints = [positive_constraint("EX1_4"), positive_constraint("EX2_4")]
        sat, model = brute_force_satisfiable(n=4, constraints=constraints)
        self.assertFalse(sat)
        self.assertIsNone(model)

    def test_bruteforce_detects_satisfiable_formula(self) -> None:
        constraints = [positive_constraint("AL1_4"), positive_constraint("EX2_4")]
        sat, model = brute_force_satisfiable(n=4, constraints=constraints)
        self.assertTrue(sat)
        self.assertIsNotNone(model)


if __name__ == "__main__":
    unittest.main()
