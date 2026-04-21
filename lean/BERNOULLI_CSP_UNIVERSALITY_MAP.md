# Bernoulli-CSP Universality Map

Freeze snapshot: **Bernoulli CSP universality v1.1**

Freeze date: 2026-04-21

This map records the common theorem stack now shared by the Bernoulli bad-event
CSP instances in the Lean development.

Version v1.1 freezes the finite-horizon iid Bernoulli bad-event pipeline after
the SAT/k-SAT core and the first horizontal expansions to NAE-SAT, XOR-SAT,
q-coloring, generic finite-alphabet forbidden-pattern CSPs, and hypergraph
coloring.

The scope is deliberately narrow:

- finite horizon;
- iid Bernoulli bad-event exposure;
- fixed assignment / fixed coloring semantics;
- operational finite-prefix collapse, stopped-collapse, and hitting-time bounds.

It does not claim infinite-horizon dynamics, almost-sure ergodic theorems,
solver-adaptive dynamics, XOR-SAT rank/nullity dynamics, or random graph
dependence.

## Generic Pipeline

```text
domain-specific bad-event probability p in (0,1)
  -> BernoulliCSPTemplate.Parameters
  -> finite path PMF over good/bad exposure outcomes
  -> active-prefix bad-count MGF product
  -> optimized Chernoff/KL lower-tail profile
  -> one-sided cumulative-production process
  -> collapse / stopped-collapse / hitting-time wrappers
```

## Generic Lean Layer

| Layer | Key module | Role |
|---|---|---|
| Algebra | [`Survival/BernoulliCSPTemplate.lean`](Survival/BernoulliCSPTemplate.lean) | Bernoulli KL, optimized MGF, drift, bad-emission scale |
| Path measure | [`Survival/BernoulliCSPPathMeasure.lean`](Survival/BernoulliCSPPathMeasure.lean) | Finite iid good/bad path PMF and exact MGF product |
| Chernoff/KL | [`Survival/BernoulliCSPPathChernoff.lean`](Survival/BernoulliCSPPathChernoff.lean) | Count-tail and cumulative-production lower-tail bounds |
| Operational collapse | [`Survival/BernoulliCSPPathCollapse.lean`](Survival/BernoulliCSPPathCollapse.lean) | Threshold crossing, collapse, stopped-collapse, hitting-time wrappers |
| Universality wrapper | [`Survival/BernoulliCSPUniversality.lean`](Survival/BernoulliCSPUniversality.lean) | Common interface over all currently instantiated Bernoulli-CSP domains |

## Current Instances

| Domain instance | Bad probability | Drift | Instance modules | Status |
|---|---:|---:|---|---|
| Random `k`-SAT fixed-assignment clause exposure | `(1/2)^k` | `log (1 / (1 - (1/2)^k))` | `KSATBernoulliTemplate`, `KSATClauseExposureProcess`, `KSATChernoffCollapse` | Derived |
| Random `k`-NAE-SAT fixed-assignment clause exposure | `(1/2)^(k - 1)` for `k >= 2` | `log (1 / (1 - (1/2)^(k - 1)))` | `NAESATBernoulliTemplate`, `NAESATClauseExposureProcess`, `NAESATChernoffCollapse` | Derived |
| Random `k`-XOR-SAT fixed-assignment equation exposure | `1/2` | `log 2` | `XORSATBernoulliTemplate`, `XORSATClauseExposureProcess`, `XORSATChernoffCollapse` | Derived |
| Fixed-coloring `q`-coloring edge exposure | `1/q` | `log (q / (q - 1))` for `q > 1` | `QColoringBernoulliTemplate`, `QColoringEdgeExposureProcess`, `QColoringChernoffCollapse` | Derived |
| Finite-alphabet forbidden-pattern exposure | `forbidden / alphabet^arity` | `log (alphabet^arity / (alphabet^arity - forbidden))` | `ForbiddenPatternCSPTemplate`, `ForbiddenPatternCSPExposureProcess`, `ForbiddenPatternCSPChernoffCollapse` | Derived |
| Fixed-coloring `q`-coloring `k`-uniform hyperedge exposure | `q / q^k` | `log (q^k / (q^k - q))` for `q > 1`, `k > 1` | `HypergraphColoringChernoffCollapse` | Derived |

## Shared Output Theorems

Every instance routed through
[`Survival/BernoulliCSPUniversality.lean`](Survival/BernoulliCSPUniversality.lean)
inherits the same theorem shapes:

- `ExposureModel.mgf_badCountRV_eq_bernoulliBadMGF_pow`
- `ExposureModel.exactCountFailureBound_le_chernoffFailureBound_of_interior`
- `ExposureModel.collapseWithChernoffBound_of_linearMargin`
- `ExposureModel.stoppedCollapseWithChernoffBound_of_linearMargin`
- `ExposureModel.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin`

The instance constructors are:

- `BernoulliCSPUniversality.kSAT`
- `BernoulliCSPUniversality.naeSAT`
- `BernoulliCSPUniversality.xorSAT`
- `BernoulliCSPUniversality.qColoring`
- `BernoulliCSPUniversality.forbiddenPattern`
- `BernoulliCSPUniversality.hypergraphColoring`

## Scope Boundaries

These boundaries are intentional:

- `k`-SAT is fixed-assignment clause exposure, not solver dynamics.
- NAE-SAT is fixed-assignment clause exposure, not solver dynamics.
- XOR-SAT is fixed-assignment bad-equation exposure, not rank/nullity dynamics.
- q-coloring is fixed-coloring edge exposure, not full random graph dependence
  or coloring-algorithm dynamics.
- Forbidden-pattern CSP is iid local-pattern exposure, not overlapping
  constraint dependence or adaptive sampling.
- Hypergraph coloring is fixed-coloring iid hyperedge exposure, not random
  hypergraph dependence or coloring-algorithm dynamics.
- All results are finite-prefix / high-probability statements, not almost-sure
  infinite-horizon ergodic theorems.

## Next Expansion Candidates

Good next targets are domains that can expose a clean Bernoulli bad-event rate:

- finite alphabet CSPs with multiple forbidden patterns and domain-specific
  combinatorial witnesses;
- hypergraph coloring with dependent edge exposure or random-hypergraph
  degree correlations;
- eventually, dependent or adaptive versions after the iid template is fully
  documented.

## Build Check

Snapshot v1.1 is intended to be checked as the top-level imported development:

```bash
cd lean
lake build Survival.BernoulliCSPUniversality
lake build Survival
```

At freeze time the top-level import contains `120` `Survival/*` modules.
