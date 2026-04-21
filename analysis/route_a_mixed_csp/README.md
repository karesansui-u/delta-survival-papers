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

Implemented files:

| File | Purpose |
|---|---|
| `mixed_csp_preregistration.md` | Frozen design and baseline comparison |
| `implementation_plan.md` | Implementation design and failure branches |
| `mixed_csp_generator.py` | Deterministic instance generator and CNF encoder |
| `mixed_csp_solvers.py` | PySAT / MiniSat wrapper with wall-clock timeout |
| `run_mixed_csp.py` | Append-safe smoke / pilot / primary runner |
| `analyze_mixed_csp.py` | Leave-one-mixture-out model-comparison analysis |
| `mixed_csp_trials.jsonl` | Future raw solver records |
| `mixed_csp_results_summary.md` | Future human-readable results |
| `mixed_csp_results.json` | Future machine-readable results |

Dependency note:

```bash
pip install -r requirements.txt
```

The repository requirements include `python-sat`, `numpy`, and `scipy`.

Smoke dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py smoke dry-run
```

Smoke execution:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py smoke run --execute
```

Primary dry-run:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py primary dry-run
```

Primary execution after smoke checks and any required addendum:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py primary run --execute
python3 analysis/route_a_mixed_csp/analyze_mixed_csp.py analyze
```

Exact-one remains non-primary unless the optional pre-primary pilot is run and
passes the frozen promotion criteria. The runner implements the pilot as
`3 n-values * 2 stress mixtures * 50 = 300` instances at the lowest primary
density (`m/n = 2.0`) to avoid immediate feasibility saturation:

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py exact_one_pilot dry-run
python3 analysis/route_a_mixed_csp/run_mixed_csp.py exact_one_pilot run --execute
python3 analysis/route_a_mixed_csp/analyze_mixed_csp.py exact-one-pilot
```
