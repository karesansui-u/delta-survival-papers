# Overview

This file is a short orientation page. The current public structure is `v3/`.
Older `v1/` and `v2/` documents remain for archive, preprint, and PDF build
compatibility.

## One-Sentence View

構造は、資源が残っていても保てなくなりうる。その構造として存在し続けられる
状態領域が失われるからである。

Structural Persistence Theory studies this loss of maintainable state region
using log-ratio coordinates.

## What To Read

1. [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md)
   Whole map of the v3 organization.
2. [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md)
   Reader-facing overview of the theory.
3. [`v3/01_theory/02_accounting_framework.md`](v3/01_theory/02_accounting_framework.md)
   Core paper combining the Paper 1 / Paper 2 reading path.
4. [`v3/01_theory/10_log_ratio_accounting.md`](v3/01_theory/10_log_ratio_accounting.md)
   Minimal form: structural depletion and the \(S = M e^{-L}\) kernel.
5. [`v3/01_theory/11_balance_accounting.md`](v3/01_theory/11_balance_accounting.md)
   Balance principle: recovery and the \(S = M e^{-B}\) kernel.

English:

- [`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md)
- [`v3/01_theory/en/10_paper1_minimal_form_en.md`](v3/01_theory/en/10_paper1_minimal_form_en.md)
- [`v3/01_theory/en/11_paper2_balance_principle_en.md`](v3/01_theory/en/11_paper2_balance_principle_en.md)

## Claim Boundaries

The main law-side claim is limited to the specification-fixed structural layer,
where the state space, maintainability condition, measure, and boundary can be
fixed before evaluation.

Observation-difficult domains use frozen observational or estimated indicators.
Their value is judged by out-of-sample incremental prediction, diagnosis, or
design transfer. They are not treated as universal-law proof.

Existing theories can also be conditionally embedded into the same coordinates.
This is a bridge, not a claim to replace those theories.

See [`v3/CLAIMS.md`](v3/CLAIMS.md).

## Evidence

The current hard empirical entry point is package-scoped outside rerun support
for two specification-fixed packages:

- Mixed-CSP: 3/3 outside reruns, 12,000 rows each, 0 checked core mismatches.
- q-coloring / Exp43c: 3/3 outside reruns, 4,000 rows each, 0 checked core
  mismatches, TIMEOUT = 0, MALFORMED = 0.

See:

- [`v3/05_evidence/README.md`](v3/05_evidence/README.md)
- [`v3/05_evidence/outside_reruns.tsv`](v3/05_evidence/outside_reruns.tsv)
- [`analysis/g7_route_a_true_outside_replication_summary.md`](analysis/g7_route_a_true_outside_replication_summary.md)

## Formalization

Lean formalization is in [`lean/`](lean/):

- `166 Survival modules`
- no project-level `sorry`, `admit`, or declared `axiom` in the imported
  `Survival` target

The reader-facing theorem map is [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md),
and the Lean landing page is [`lean/README.md`](lean/README.md).

## OSF

The current OSF public entry point is:

- [Structural Persistence Theory (v3)](https://osf.io/mdh7b/)

Legacy OSF root files have been moved into `archive_root_legacy_2026-04-30/`.
