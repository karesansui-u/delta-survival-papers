#!/usr/bin/env python3
"""Feature extraction for Exp44 Cardinality-SAT records."""

from __future__ import annotations

from typing import Any

try:  # pragma: no cover
    from .generator import MIXTURES, CardinalitySATInstance
except ImportError:  # pragma: no cover
    from generator import MIXTURES, CardinalitySATInstance  # type: ignore


def mixture_one_hot(mixture_id: str) -> tuple[float, ...]:
    ids = sorted(MIXTURES)
    return tuple(1.0 if mixture_id == mid else 0.0 for mid in ids)


def extract_features(instance: CardinalitySATInstance) -> dict[str, float | int | str]:
    return {
        "n": instance.n,
        "rho_fm": instance.rho_fm,
        "rho_fm_actual": instance.rho_fm_actual,
        "mixture_id": instance.mixture_id,
        "mixture_index": sorted(MIXTURES).index(instance.mixture_id),
        "m_semantic": instance.m_semantic,
        "m_AL1_4": instance.m_AL1_4,
        "m_EX2_4": instance.m_EX2_4,
        "m_EX1_4": instance.m_EX1_4,
        "L": instance.L,
        "log_state": instance.log_state,
        "first_moment_log_count": instance.first_moment_log_count,
        "semantic_density": instance.semantic_density,
        "cnf_variable_count": instance.cnf_variable_count,
        "cnf_clause_count": instance.cnf_clause_count,
        "cnf_density": instance.cnf_density,
    }


def predictor_vectors(instance: CardinalitySATInstance) -> dict[str, tuple[float, ...]]:
    return {
        "fm_plus_n": (instance.first_moment_log_count, float(instance.n)),
        "first_moment_only": (instance.first_moment_log_count,),
        "raw_plus_n": (float(instance.m_semantic), float(instance.n)),
        "density_plus_n": (instance.semantic_density, float(instance.n)),
        "raw_plus_n_mixture": (
            float(instance.m_semantic),
            float(instance.n),
            *mixture_one_hot(instance.mixture_id),
        ),
        "cnf_count_plus_n": (float(instance.cnf_clause_count), float(instance.n)),
        "cnf_density_plus_n": (instance.cnf_density, float(instance.n)),
        "type_counts_plus_n": (
            float(instance.m_AL1_4),
            float(instance.m_EX2_4),
            float(instance.m_EX1_4),
            float(instance.n),
        ),
    }


def build_base_record(instance: CardinalitySATInstance) -> dict[str, Any]:
    return instance.metadata() | {
        "features": extract_features(instance),
        "predictor_vectors": predictor_vectors(instance),
    }
