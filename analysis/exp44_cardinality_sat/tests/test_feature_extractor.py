from __future__ import annotations

import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from feature_extractor import build_base_record, predictor_vectors  # noqa: E402
from generator import generate_instance  # noqa: E402


class FeatureExtractorTests(unittest.TestCase):
    def test_predictor_vectors_include_preregistered_models(self) -> None:
        instance = generate_instance(phase="test", n=24, rho_fm=1.0, mixture_id="M3_threeway_low", instance_idx=0)
        predictors = predictor_vectors(instance)
        expected = {
            "fm_plus_n",
            "first_moment_only",
            "raw_plus_n",
            "density_plus_n",
            "raw_plus_n_mixture",
            "cnf_count_plus_n",
            "cnf_density_plus_n",
            "type_counts_plus_n",
        }
        self.assertEqual(set(predictors), expected)
        self.assertEqual(len(predictors["type_counts_plus_n"]), 4)

    def test_build_base_record_has_required_fields(self) -> None:
        instance = generate_instance(phase="test", n=24, rho_fm=0.85, mixture_id="M1_low_med", instance_idx=2)
        record = build_base_record(instance)
        self.assertIn("features", record)
        self.assertIn("predictor_vectors", record)
        self.assertEqual(record["m_semantic"], record["m_AL1_4"] + record["m_EX2_4"] + record["m_EX1_4"])
        self.assertEqual(record["cnf_clause_count"], record["m_AL1_4"] + 10 * record["m_EX2_4"] + 12 * record["m_EX1_4"])


if __name__ == "__main__":
    unittest.main()
