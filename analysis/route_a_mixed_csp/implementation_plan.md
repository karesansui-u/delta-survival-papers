# Mixed-CSP Implementation Plan

Status: design draft for review. This document implements the frozen
pre-registration without changing it.

## 1. Goal

Build a reproducible zero-API pipeline for the Mixed-CSP Route A test:

```text
generate mixed SAT/NAE(/optional exact-one) instances
  -> encode to CNF
  -> solve feasibility with MiniSat/CDCL
  -> record semantic and encoding metadata
  -> compare L-normalized predictors against raw baselines
```

The primary endpoint is feasibility / SAT rate. Solver cost is secondary.

## 2. Proposed Files

| File | Role |
|---|---|
| `mixed_csp_generator.py` | deterministic instance generation and CNF encoding |
| `mixed_csp_solvers.py` | PySAT / MiniSat wrapper and optional WalkSAT-style evaluator |
| `run_mixed_csp.py` | append-safe experiment runner |
| `analyze_mixed_csp.py` | leave-one-mixture-out model comparison |
| `mixed_csp_results_summary.md` | generated human-readable result summary |
| `mixed_csp_results.json` | generated machine-readable summary |
| `mixed_csp_trials.jsonl` | raw trial records |
| `exact_one_pilot_summary.md` | generated only if the pre-primary pilot is run |

Keep generation, solving, and analysis separate so solver failures do not
invalidate generation reproducibility.

## 3. Data Model

Each raw JSONL row should contain:

```json
{
  "experiment": "route_a_mixed_csp",
  "version": "1.0.0",
  "phase": "primary | exact_one_pilot | exploratory",
  "instance_id": "...",
  "instance_seed": "...",
  "n": 120,
  "m": 300,
  "density": 2.5,
  "mixture_id": "sat_0.50__nae_0.50__exact1_0.00",
  "mixture": {"sat": 0.5, "nae": 0.5, "exact1": 0.0},
  "counts": {"sat": 150, "nae": 150, "exact1": 0},
  "semantic_raw_count": 300,
  "cnf_clause_count": 300,
  "cnf_variable_count": 120,
  "L": 63.2,
  "first_moment_log_count": 19.9,
  "predictors": {
    "raw_count": 300,
    "raw_density": 2.5,
    "L": 63.2,
    "first_moment_log_count": 19.9,
    "cnf_clause_count": 300
  },
  "solver": {
    "name": "minisat22",
    "pysat_version": "...",
    "timeout_sec": 30.0
  },
  "sat_feasible": true,
  "timeout": false,
  "runtime_sec": 0.012,
  "conflicts": 41,
  "decisions": 95,
  "propagations": 1300,
  "assignment_verified": true,
  "status": "succeeded | timeout | solver_error | malformed_encoding",
  "error": null
}
```

Use `null` for unavailable solver stats. Do not infer UNSAT from timeout.

For the encodings in this first implementation, `cnf_variable_count` should
equal `n` because no auxiliary variables are introduced. The field is retained
for forward compatibility with Tseitin, commander, or logarithmic encodings.

## 4. Instance Generation

### Variables and Literals

- Variables are indexed `1..n` for DIMACS / PySAT compatibility.
- A signed literal is represented as an integer: positive for non-negated,
  negative for negated.
- Each constraint samples three distinct variables without replacement.
- Literal signs are iid fair coin flips.

### Constraint Semantics

3-SAT:
  A clause is satisfied when at least one signed literal is true. CNF encoding
  is one 3-literal clause.

3-NAE-SAT:
  A clause is satisfied when the signed literals are not all equal. CNF
  encoding uses two clauses:

```text
(x ∨ y ∨ z) ∧ (¬x ∨ ¬y ∨ ¬z)
```

where `x,y,z` are already signed literals. In implementation, the second clause
is the negation of each signed literal.

Exactly-one-3-SAT:
  Satisfied when exactly one signed literal is true. Keep exploratory /
  conditional unless the pilot promotes it. CNF encoding:

```text
(x ∨ y ∨ z)
∧ (¬x ∨ ¬y)
∧ (¬x ∨ ¬z)
∧ (¬y ∨ ¬z)
```

### Mixture Rounding

Implement the preregistered fixed-order rule:

```text
counts_sat = floor(m * w_sat)
counts_nae = floor(m * w_nae)
counts_exact1 = m - counts_sat - counts_nae
```

Record both requested weights and realized counts.

### Seeds

Use:

```text
instance_seed = sha256(experiment_id, phase, n, density, mixture_id, instance_idx)
```

Convert to an integer RNG seed by taking the first 16 hex digits. Record the
full hex digest and the integer seed.

## 5. Solver Wrapper

Primary solver:

```text
python-sat with Minisat22 if available
```

Runner behavior:

- instantiate solver with generated CNF clauses;
- apply a wall-clock timeout from outside the solver if PySAT does not expose a
  reliable conflict budget;
- record solver name and PySAT version;
- if SAT, verify the returned assignment against the semantic constraints, not
  only CNF clauses;
- if UNSAT, record `sat_feasible = false`;
- if timeout, record `timeout = true`, `sat_feasible = null`, `status =
  "timeout"`.

Primary feasibility analysis excludes timeout rows rather than counting them as
UNSAT, as frozen in the pre-registration.

## 6. Execution Phases

### Phase 0: Smoke Tests

Small grid:

```text
n in {20}
density in {1.0}
mixtures in {(1,0,0), (0,1,0), (0.5,0.5,0)}
instances per cell = 5
```

Checks:

- all CNF encodings are accepted by MiniSat;
- all SAT assignments pass semantic verification;
- pure SAT `cnf_clause_count = semantic_raw_count`;
- pure NAE `cnf_clause_count = 2 * semantic_raw_count`;
- pure exact-one `cnf_clause_count = 4 * semantic_raw_count` for the pairwise
  encoding;
- deterministic rerun produces identical instance hashes.
- record median and P90 solver runtime per instance;
- extrapolate primary-grid runtime as `median_runtime * 12000` and
  `P90_runtime * 12000`;
- if extrapolated runtime exceeds the target budget, create a preregistration
  addendum reducing `instances_per_cell` before primary data collection.

### Phase 1: Exact-One Pre-primary Pilot

Run only if exact-one promotion is still desired:

```text
n in {80, 120, 160}
stress mixtures in {(0.80,0.10,0.10), (0.60,0.20,0.20)}
instances per cell = 50
```

Promotion rule is exactly the preregistered rule:

```text
SAT rate > 30% in at least 2/3 n values for each stress mixture
and
median(cnf_clause_count / semantic_raw_count) < 5.0 in every stress cell.
```

The pilot decision must be written before primary data collection.

Recommended conservative default:
  Keep exact-one exploratory unless the pilot is clearly healthy. The SAT/NAE
  two-type grid is already sufficient to make `L` non-collinear with raw count.

### Phase 2: Primary SAT/NAE Grid

Grid:

```text
n in {80, 120, 160}
density in {2.0, 2.5, 3.0, 3.5}
mixtures in {
  (1.0, 0.0, 0.0),
  (0.75, 0.25, 0.0),
  (0.50, 0.50, 0.0),
  (0.25, 0.75, 0.0),
  (0.0, 1.0, 0.0)
}
instances per cell = 200
```

Total primary instances:

```text
3 * 4 * 5 * 200 = 12,000
```

This is large enough for feasibility models but may be heavy depending on
solver runtime. If runtime is unexpectedly high during smoke testing, reduce
only after creating a preregistration addendum before primary data.

## 7. Analysis Plan

Primary data frame columns:

```text
sat_feasible, raw_count, raw_density, L, first_moment_log_count,
n, cnf_clause_count, mixture_id
```

Model family:

- logistic regression;
- held-out evaluation by leave-one-mixture-out;
- report total held-out log loss and per-held-mixture log loss;
- standardize continuous predictors within the training fold only, using
  training-fold z-scores: subtract the training-fold mean and divide by the
  training-fold standard deviation;
- record the intercept and all predictor scaling parameters per fold;
- keep intercept unpenalized if using L2 regularization.

Candidate models:

```text
raw_count
raw_density
L_only
first_moment
L_plus_n
raw_plus_n
cnf_count_plus_n
```

Primary support:

```text
log_loss(L_plus_n) < log_loss(raw_plus_n)
```

Strong support:

```text
relative improvement >= 10%
and
log_loss(L_plus_n) <= log_loss(cnf_count_plus_n)
```

Theory-pure support:

```text
log_loss(first_moment) < log_loss(raw_plus_n)
```

Diagnostics:

- timeout rate per cell;
- SAT rate per cell;
- calibration by predicted-probability decile;
- per-mixture residual / log-loss contribution;
- CNF expansion ratio by mixture;
- coefficient signs and fold stability.

## 8. Failure Branches

| Observation | Interpretation | Next move |
|---|---|---|
| `L_plus_n < raw_plus_n` and `L_plus_n <= cnf_count_plus_n` | Clean support | integrate as Route A empirical anchor |
| `L_plus_n < raw_plus_n` but `cnf_count_plus_n < L_plus_n` | Encoding-size confound | report as weakened; consider native evaluator |
| `raw_plus_n <= L_plus_n` | Primary not supported | inspect grid informativeness and threshold distance |
| timeout rate > 5% in cells | Feasibility endpoint contaminated | suspend affected-cell interpretation |
| pure-family folds dominate loss | leave-one-mixture-out too harsh or family endpoints too separated | report per-fold; consider later cross-family design |
| exact-one pilot fails | keep exact-one exploratory | primary remains SAT/NAE clean grid |

## 9. Review Checklist Before Coding

- Confirm PySAT / Minisat22 availability on the target machine.
- Confirm whether exact-one should be piloted or simply left exploratory.
- Confirm whether 12,000 primary instances is acceptable.
- Confirm whether the first implementation should include only primary
  feasibility, postponing secondary solver-cost regression.
- Confirm output filenames and whether OSF upload is expected after results.

## 10. Author Decisions to Record Before Implementation

Recommended defaults:

1. First implementation scope: primary feasibility only.
   Secondary solver-cost regression is deferred to a second pass. Rationale:
   this reduces initial scope; cost can be recomputed from existing JSONL if
   solver stats are recorded during the primary run.
2. Exact-one primary inclusion: default exploratory.
   Run the pilot only if time allows before the primary grid. Rationale:
   the SAT/NAE grid alone is sufficient to decorrelate `L` from raw count, and
   exact-one carries both saturation and encoding-size risk.
3. Primary instance count: start with 12,000.
   If smoke-test extrapolated runtime exceeds the chosen runtime budget, reduce
   `instances_per_cell` via preregistration addendum before primary data.
