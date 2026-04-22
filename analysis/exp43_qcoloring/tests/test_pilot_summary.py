from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from pilot_summary import summarize  # noqa: E402


class PilotSummaryTests(unittest.TestCase):
    def test_pilot_pass_requires_two_informative_bands_per_q(self) -> None:
        records = []
        for q in (3, 4):
            for rho, positives in ((0.6, 5), (0.8, 3)):
                for idx in range(10):
                    records.append(
                        {
                            "q": q,
                            "n": 20,
                            "rho_fm": rho,
                            "instance_id": f"{q}-{rho}-{idx}",
                            "q_colorable": idx < positives,
                            "timeout": False,
                            "status": "SAT" if idx < positives else "UNSAT",
                        }
                    )
        summary = summarize(records)
        self.assertTrue(summary["pilot_pass"])
        self.assertFalse(summary["inconclusive_by_30pct_rule"])

    def test_inconclusive_by_suspended_cell_fraction(self) -> None:
        records = []
        for cell_idx, rho in enumerate((0.6, 0.8, 1.0, 1.2)):
            for idx in range(10):
                records.append(
                    {
                        "q": 3,
                        "n": 20,
                        "rho_fm": rho,
                        "instance_id": f"{cell_idx}-{idx}",
                        "q_colorable": None if cell_idx < 2 else idx < 5,
                        "timeout": cell_idx < 2,
                        "status": "TIMEOUT" if cell_idx < 2 else ("SAT" if idx < 5 else "UNSAT"),
                    }
                )
        summary = summarize(records)
        self.assertTrue(summary["inconclusive_by_30pct_rule"])
        self.assertFalse(summary["pilot_pass"])

    def test_summary_reports_empty_informative_bands_for_every_q(self) -> None:
        records = []
        for q in (3, 4):
            for idx in range(5):
                records.append(
                    {
                        "q": q,
                        "n": 20,
                        "rho_fm": 0.5,
                        "instance_id": f"{q}-{idx}",
                        "q_colorable": True,
                        "timeout": False,
                        "status": "SAT",
                    }
                )
        summary = summarize(records)
        self.assertEqual(summary["informative_rho_bands_by_q"], {"3": [], "4": []})


if __name__ == "__main__":
    unittest.main()
