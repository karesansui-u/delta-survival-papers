# Route A Mixed-CSP Empirical Replication

Status: frozen before primary data collection.

This experiment tests whether drift-weighted structural loss `L` / first-moment
log count predicts feasibility better than raw constraint count in a hard Route
A domain. Solver cost is retained as a secondary computational-cost endpoint.

The initial clean primary grid uses a two-type SAT/NAE mixture. Exactly-one
3-SAT is treated as a conditional stress extension: it can be promoted into the
primary grid only if the pre-primary pilot passes the preregistered SAT-rate and
CNF-expansion criteria.

The key guardrail:

```text
Do not test L vs raw count inside one constant-drift family.
```

Within a single family such as NAE-SAT, `L = m * constant`, so `L` and raw count
are equivalent. The empirical test must use mixed-constraint instances or
cross-family comparisons.

Planned files:

| File | Purpose |
|---|---|
| `mixed_csp_preregistration.md` | Frozen design and baseline comparison |
| `mixed_csp_generator.py` | Future instance generator |
| `mixed_csp_solvers.py` | Future solver wrappers |
| `analyze_mixed_csp.py` | Future model-comparison analysis |
| `mixed_csp_results_summary.md` | Future human-readable results |
