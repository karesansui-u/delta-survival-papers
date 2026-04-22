from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from cnf_encoder import (  # noqa: E402
    brute_force_q_colorable,
    complete_graph,
    cycle_graph,
    encode_q_coloring,
    verify_coloring,
)


class CNFEncoderTests(unittest.TestCase):
    def test_clause_count_formula(self) -> None:
        n, q = 4, 3
        edges = complete_graph(4)
        formula = encode_q_coloring(n=n, q=q, edges=edges)
        expected = n * (1 + q * (q - 1) // 2) + len(edges) * q
        self.assertEqual(formula.num_clauses, expected)
        self.assertEqual(formula.num_vars, n * q)

    def test_known_colorability_cases(self) -> None:
        self.assertEqual(brute_force_q_colorable(n=4, q=3, edges=complete_graph(4))[0], False)
        self.assertEqual(brute_force_q_colorable(n=4, q=4, edges=complete_graph(4))[0], True)
        self.assertEqual(brute_force_q_colorable(n=5, q=3, edges=cycle_graph(5))[0], True)
        self.assertEqual(brute_force_q_colorable(n=5, q=2, edges=cycle_graph(5))[0], False)

    def test_verifier_rejects_bad_coloring(self) -> None:
        edges = complete_graph(3)
        self.assertTrue(verify_coloring(n=3, q=3, edges=edges, coloring=(0, 1, 2)))
        self.assertFalse(verify_coloring(n=3, q=3, edges=edges, coloring=(0, 0, 1)))


if __name__ == "__main__":
    unittest.main()
