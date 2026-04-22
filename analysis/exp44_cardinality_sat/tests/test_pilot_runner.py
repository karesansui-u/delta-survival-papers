from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from pilot_runner import iter_plan  # noqa: E402


class PilotRunnerTests(unittest.TestCase):
    def test_iter_plan_supports_global_grid(self) -> None:
        config = {
            "mixture_ids": ["M0_low", "M5_med_high"],
            "n_values": [20],
            "rho_fm_values": [0.7, 1.0],
            "instances_per_cell": 2,
        }
        rows = list(iter_plan(config))
        self.assertEqual(len(rows), 8)
        self.assertEqual(rows[0], ("M0_low", 20, 0.7, 0))
        self.assertEqual(rows[-1], ("M5_med_high", 20, 1.0, 1))

    def test_iter_plan_supports_per_mixture_grid(self) -> None:
        config = {
            "n_values": [40, 80],
            "per_mixture_config": {
                "M5_med_high": {"rho_fm_values": [0.8, 0.9]},
                "M0_low": {"rho_fm_values": [0.4]},
            },
            "instances_per_cell": 3,
        }
        rows = list(iter_plan(config))
        self.assertEqual(len(rows), 18)
        self.assertEqual(rows[0], ("M0_low", 40, 0.4, 0))
        self.assertEqual(rows[5], ("M0_low", 80, 0.4, 2))
        self.assertEqual(rows[6], ("M5_med_high", 40, 0.8, 0))
        self.assertEqual(rows[-1], ("M5_med_high", 80, 0.9, 2))


if __name__ == "__main__":
    unittest.main()

