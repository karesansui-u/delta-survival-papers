from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from cnf_encoder import complete_graph  # noqa: E402
from solver import pysat_available, solve_graph  # noqa: E402


@unittest.skipUnless(pysat_available(), "python-sat is not installed")
class OptionalSolverTests(unittest.TestCase):
    def test_solver_known_cases(self) -> None:
        unsat = solve_graph(n=4, q=3, edges=complete_graph(4), timeout_sec=10)
        self.assertEqual(unsat.status, "UNSAT")
        self.assertEqual(unsat.q_colorable, False)

        sat = solve_graph(n=4, q=4, edges=complete_graph(4), timeout_sec=10)
        self.assertEqual(sat.status, "SAT")
        self.assertEqual(sat.q_colorable, True)
        self.assertEqual(sat.coloring_verified, True)


if __name__ == "__main__":
    unittest.main()
