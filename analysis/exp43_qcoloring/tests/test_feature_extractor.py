from __future__ import annotations

import math
import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from feature_extractor import extract_features, predictor_vectors  # noqa: E402
from generator import generate_instance  # noqa: E402


class FeatureExtractorTests(unittest.TestCase):
    def test_features_match_preregistration_formulas(self) -> None:
        instance = generate_instance(phase="pilot", q=5, n=25, rho_fm=0.9, instance_idx=2)
        features = extract_features(instance)
        self.assertAlmostEqual(features["ell_q"], math.log(5 / 4))
        self.assertAlmostEqual(features["L"], instance.m * math.log(5 / 4))
        self.assertAlmostEqual(features["log_state"], 25 * math.log(5))
        self.assertAlmostEqual(
            features["first_moment_log_count"],
            features["log_state"] - features["L"],
        )
        self.assertEqual(features["cnf_clause_count"], 25 * (1 + 5 * 4 / 2) + instance.m * 5)

    def test_predictor_vectors_include_primary(self) -> None:
        instance = generate_instance(phase="pilot", q=3, n=20, rho_fm=1.0, instance_idx=0)
        vectors = predictor_vectors(instance)
        self.assertIn("fm_plus_n", vectors)
        self.assertEqual(len(vectors["fm_plus_n"]), 2)
        self.assertIn("cnf_count_plus_n_plus_q", vectors)


if __name__ == "__main__":
    unittest.main()
