from __future__ import annotations

import math
import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from generator import (  # noqa: E402
    CONSTRAINT_TYPES,
    CardinalityConstraint,
    SignedLiteral,
    average_drift,
    constraint_list_hash,
    generate_instance,
    semantic_count_from_rho,
    type_counts_from_mixture,
)


class GeneratorTests(unittest.TestCase):
    def test_drift_values(self) -> None:
        self.assertAlmostEqual(CONSTRAINT_TYPES["AL1_4"].drift, math.log(16 / 15))
        self.assertAlmostEqual(CONSTRAINT_TYPES["EX2_4"].drift, math.log(16 / 6))
        self.assertAlmostEqual(CONSTRAINT_TYPES["EX1_4"].drift, math.log(16 / 4))

    def test_semantic_count_from_rho(self) -> None:
        m = semantic_count_from_rho(n=80, rho_fm=1.0, mixture_id="M0_low")
        expected = round(80 * math.log(2) / math.log(16 / 15))
        self.assertEqual(m, expected)

    def test_type_count_rounding_sums_to_m(self) -> None:
        counts = type_counts_from_mixture(m=101, mixture_id="M3_threeway_low")
        self.assertEqual(sum(counts.values()), 101)
        self.assertEqual(counts["AL1_4"], 50)
        self.assertEqual(counts["EX2_4"], 25)
        self.assertEqual(counts["EX1_4"], 26)

    def test_generation_is_deterministic(self) -> None:
        a = generate_instance(phase="test", n=24, rho_fm=1.0, mixture_id="M2_bal_low_med", instance_idx=7)
        b = generate_instance(phase="test", n=24, rho_fm=1.0, mixture_id="M2_bal_low_med", instance_idx=7)
        self.assertEqual(a.constraints, b.constraints)
        self.assertEqual(a.constraint_list_hash, b.constraint_list_hash)

    def test_constraint_hash_is_order_canonical(self) -> None:
        c1 = CardinalityConstraint(
            "EX1_4",
            (
                SignedLiteral(3, True),
                SignedLiteral(1, False),
                SignedLiteral(2, True),
                SignedLiteral(0, False),
            ),
        )
        c2 = CardinalityConstraint(
            "AL1_4",
            (
                SignedLiteral(4, True),
                SignedLiteral(5, True),
                SignedLiteral(6, False),
                SignedLiteral(7, False),
            ),
        )
        self.assertEqual(constraint_list_hash([c1, c2]), constraint_list_hash([c2, c1]))

    def test_average_drift_positive(self) -> None:
        self.assertGreater(average_drift("M5_med_high"), average_drift("M1_low_med"))


if __name__ == "__main__":
    unittest.main()

