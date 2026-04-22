from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from pilot_runner import iter_plan  # noqa: E402


class PilotRunnerTests(unittest.TestCase):
    def test_iter_plan_supports_global_rho_grid(self) -> None:
        config = {
            "q_values": [3, 4],
            "n_values": [20],
            "rho_fm_values": [0.5, 1.0],
            "instances_per_cell": 2,
        }
        rows = list(iter_plan(config))
        self.assertEqual(len(rows), 8)
        self.assertEqual(rows[0], (3, 20, 0.5, 0))
        self.assertEqual(rows[-1], (4, 20, 1.0, 1))

    def test_iter_plan_supports_per_q_rho_grid(self) -> None:
        config = {
            "n_values": [40, 80],
            "per_q_config": {
                "5": {"rho_fm_values": [0.8, 0.9]},
                "3": {"rho_fm_values": [0.4]},
            },
            "instances_per_cell": 3,
        }
        rows = list(iter_plan(config))
        self.assertEqual(len(rows), 18)
        self.assertEqual(rows[0], (3, 40, 0.4, 0))
        self.assertEqual(rows[5], (3, 80, 0.4, 2))
        self.assertEqual(rows[6], (5, 40, 0.8, 0))
        self.assertEqual(rows[-1], (5, 80, 0.9, 2))


if __name__ == "__main__":
    unittest.main()
