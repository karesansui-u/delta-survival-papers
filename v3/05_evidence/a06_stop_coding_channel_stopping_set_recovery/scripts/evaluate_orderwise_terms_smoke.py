#!/usr/bin/env python3
"""Evaluate A06-stop v2 order-wise normalized-terms smoke with fixed model names."""

from __future__ import annotations

import sys

from evaluate_smoke import main as evaluate_main


ORDERWISE_ARGS = [
    "--primary-model",
    "B1_degree_SP_stop_orderwise_norm_terms",
    "--hazard-model",
    "B1_degree_hazard_SP_stop_orderwise_norm_terms",
    "--rankdep-model",
    "B1_degree_rankdep_SP_stop_orderwise_norm_terms",
]


def main() -> int:
    sys.argv = [sys.argv[0], *sys.argv[1:], *ORDERWISE_ARGS]
    return evaluate_main()


if __name__ == "__main__":
    raise SystemExit(main())
