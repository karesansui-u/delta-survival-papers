from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from pilot_summary import summarize  # noqa: E402


def make_rows(mixture_id: str, rho: float, sat_rate: float, *, n: int = 40, total: int = 20) -> list[dict]:
    sat_count = int(round(total * sat_rate))
    rows = []
    for idx in range(total):
        rows.append(
            {
                "mixture_id": mixture_id,
                "n": n,
                "rho_fm": rho,
                "status": "SAT" if idx < sat_count else "UNSAT",
                "sat_feasible": idx < sat_count,
                "timeout": False,
            }
        )
    return rows


class PilotSummaryTests(unittest.TestCase):
    def test_pilot_pass_requires_informative_bands_and_monotonicity(self) -> None:
        rows = []
        for mixture_id in ["M0_low", "M1_low_med", "M2_bal_low_med", "M3_threeway_low"]:
            rows += make_rows(mixture_id, 0.7, 0.9)
            rows += make_rows(mixture_id, 1.0, 0.5)
            rows += make_rows(mixture_id, 1.3, 0.1)
        summary = summarize(rows)
        self.assertTrue(summary["pilot_pass"])
        self.assertEqual(summary["monotone_mixture_count"], 4)

    def test_timeout_fraction_can_make_inconclusive(self) -> None:
        rows = []
        for mixture_id in ["M0_low", "M1_low_med"]:
            for rho in [0.7, 1.0]:
                for idx in range(10):
                    rows.append(
                        {
                            "mixture_id": mixture_id,
                            "n": 40,
                            "rho_fm": rho,
                            "status": "TIMEOUT" if idx == 0 else "SAT",
                            "sat_feasible": None if idx == 0 else True,
                            "timeout": idx == 0,
                        }
                    )
        summary = summarize(rows)
        self.assertTrue(summary["inconclusive_by_30pct_rule"])
        self.assertFalse(summary["pilot_pass"])


if __name__ == "__main__":
    unittest.main()
