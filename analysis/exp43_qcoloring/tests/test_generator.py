from __future__ import annotations

import math
import sys
import unittest
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

from generator import edge_count_from_rho, edge_list_hash, generate_instance  # noqa: E402


class GeneratorTests(unittest.TestCase):
    def test_generation_is_deterministic(self) -> None:
        a = generate_instance(phase="pilot", q=3, n=20, rho_fm=0.8, instance_idx=7)
        b = generate_instance(phase="pilot", q=3, n=20, rho_fm=0.8, instance_idx=7)
        self.assertEqual(a.edges, b.edges)
        self.assertEqual(a.edge_list_hash, b.edge_list_hash)

    def test_edges_are_simple_and_canonical(self) -> None:
        instance = generate_instance(phase="pilot", q=4, n=30, rho_fm=0.6, instance_idx=1)
        self.assertEqual(len(instance.edges), len(set(instance.edges)))
        self.assertTrue(all(u < v for u, v in instance.edges))
        self.assertEqual(tuple(sorted(instance.edges)), instance.edges)

    def test_edge_count_formula(self) -> None:
        q, n, rho = 3, 50, 0.8
        expected = round(rho * n * math.log(q) / math.log(q / (q - 1)))
        self.assertEqual(edge_count_from_rho(q=q, n=n, rho_fm=rho), expected)

    def test_edge_hash_is_canonical(self) -> None:
        self.assertEqual(edge_list_hash([(2, 1), (0, 3)]), edge_list_hash([(0, 3), (1, 2)]))


if __name__ == "__main__":
    unittest.main()
