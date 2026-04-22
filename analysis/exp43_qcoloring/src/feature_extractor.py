#!/usr/bin/env python3
"""Feature extraction for Exp43 q-coloring records."""

from __future__ import annotations

from typing import Any

try:  # pragma: no cover
    from .generator import QColoringInstance
except ImportError:  # pragma: no cover
    from generator import QColoringInstance


def extract_features(instance: QColoringInstance) -> dict[str, float | int]:
    return {
        "q": instance.q,
        "n": instance.n,
        "m": instance.m,
        "rho_fm": instance.rho_fm,
        "rho_fm_actual": instance.rho_fm_actual,
        "ell_q": instance.ell_q,
        "L": instance.L,
        "log_state": instance.log_state,
        "first_moment_log_count": instance.first_moment_log_count,
        "edge_density": instance.edge_density,
        "avg_degree": instance.avg_degree,
        "semantic_edge_count": instance.m,
        "cnf_variable_count": instance.cnf_variable_count,
        "cnf_clause_count": instance.cnf_clause_count,
    }


def predictor_vectors(instance: QColoringInstance) -> dict[str, tuple[float, ...]]:
    features = extract_features(instance)
    return {
        "raw_edge": (float(features["m"]),),
        "raw_density": (float(features["edge_density"]),),
        "avg_degree": (float(features["avg_degree"]),),
        "raw_plus_n": (float(features["m"]), float(features["n"])),
        "raw_plus_n_plus_q": (float(features["m"]), float(features["n"]), float(features["q"])),
        "density_plus_n_plus_q": (
            float(features["edge_density"]),
            float(features["n"]),
            float(features["q"]),
        ),
        "avg_degree_plus_n_plus_q": (
            float(features["avg_degree"]),
            float(features["n"]),
            float(features["q"]),
        ),
        "cnf_count_plus_n_plus_q": (
            float(features["cnf_clause_count"]),
            float(features["n"]),
            float(features["q"]),
        ),
        "L_plus_n": (float(features["L"]), float(features["n"])),
        "L_plus_n_plus_q": (float(features["L"]), float(features["n"]), float(features["q"])),
        "fm_plus_n": (
            float(features["first_moment_log_count"]),
            float(features["n"]),
        ),
        "first_moment": (float(features["first_moment_log_count"]),),
    }


def build_base_record(instance: QColoringInstance) -> dict[str, Any]:
    return instance.metadata() | {
        "features": extract_features(instance),
        "predictor_vectors": predictor_vectors(instance),
    }
