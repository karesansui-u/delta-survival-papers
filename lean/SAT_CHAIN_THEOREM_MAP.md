# SAT / k-SAT Chain Theorem Map

Freeze snapshot: **SAT chain v1.0**

Date: 2026-04-21

Scope: finite-horizon, iid Bernoulli bad-event CSPs, random 3-SAT, and random k-SAT clause exposure.

Build target: `lake build Survival`

This map fixes what is already closed in Lean and what is intentionally outside
the current scope. It is meant to be the reader-facing index before horizontal
expansion to XOR-SAT, coloring, or other CSPs.

For the cross-domain template after the XOR-SAT and q-coloring expansions, see
[`BERNOULLI_CSP_UNIVERSALITY_MAP.md`](BERNOULLI_CSP_UNIVERSALITY_MAP.md).

## Executive Claim

For the SAT/k-SAT branch, the Lean stack now verifies the following pipeline:

```text
random SAT/k-SAT problem data
  -> actual finite-horizon path measure
  -> non-flat bad-outcome additive functional
  -> internally derived MGF product
  -> Chernoff/KL lower-tail profile
  -> high-probability collapse / stopped-collapse / hitting-time bounds
```

The key point is that the final collapse and hitting-time statements are not
fed by an external concentration assumption. The path measure, MGF product, and
Chernoff/KL profile are derived inside the Lean development.

## Main Theorem Map

| Layer | Claim | Key Lean object | File | Status |
|---|---|---|---|---|
| 1 | Random 3-SAT first-moment drift is fixed by the problem definition | `random3ClauseDrift_eq_log` / drift corollaries | [`Survival/SATDriftLowerBound.lean`](Survival/SATDriftLowerBound.lean) | Derived |
| 2 | Resource/contraction lower bounds lift to expected Sigma drift | `expectedIncrement_lowerBound_of_stepLoss_lowerBound` and cumulative variants | [`Survival/ResourceBudgetToSigmaDrift.lean`](Survival/ResourceBudgetToSigmaDrift.lean) | Derived |
| 3 | SAT has an unconditional expectation-level tendency law | `expectedCumulative_monotone_random3ClauseStepModel` | [`Survival/SATUnconditionalTendency.lean`](Survival/SATUnconditionalTendency.lean) | Derived |
| 4 | Actual finite path measure for 3-SAT clause exposure exists | `pathPMF`, `pathMeasure` | [`Survival/SATClauseExposureProcess.lean`](Survival/SATClauseExposureProcess.lean) | Derived |
| 5 | The observable can be non-flat and outcome-dependent | `oneSidedUnsatEmission` | [`Survival/SATStateDependentClauseExposure.lean`](Survival/SATStateDependentClauseExposure.lean) | Derived |
| 6 | Non-flat SAT emission preserves the first-moment drift | state-dependent mean/cumulative drift theorems | [`Survival/SATStateDependentClauseExposure.lean`](Survival/SATStateDependentClauseExposure.lean) | Derived |
| 7 | Count lower-tail reduces the additive-functional tail | count-reduction theorems | [`Survival/SATStateDependentCountReduction.lean`](Survival/SATStateDependentCountReduction.lean) | Derived |
| 8 | Support endpoints and clipped failure profiles are exact enough for safe bounds | support/clipped upper-bound theorems | [`Survival/SATStateDependentCountSupportBound.lean`](Survival/SATStateDependentCountSupportBound.lean), [`Survival/SATStateDependentCountSupportClippedUpperBound.lean`](Survival/SATStateDependentCountSupportClippedUpperBound.lean) | Derived |
| 9 | MGF product is derived from the actual path PMF | `mgf_unsatCountRV_eq_bernoulliUnsatMGF_pow` | [`Survival/SATStateDependentCountMGFProduct.lean`](Survival/SATStateDependentCountMGFProduct.lean) | Derived |
| 10 | Closed MGF Chernoff bounds apply to SAT count tails | `hasCountFailureUpperBound_closedMGF_pathPMF` and wrappers | [`Survival/SATStateDependentClosedMGFChernoff.lean`](Survival/SATStateDependentClosedMGFChernoff.lean) | Derived |
| 11 | Optimized Chernoff profile is the Bernoulli KL lower-tail rate in the interior | KL algebra / optimized MGF theorems | [`Survival/SATStateDependentCountChernoffKL.lean`](Survival/SATStateDependentCountChernoffKL.lean), [`Survival/SATStateDependentCountChernoffKLAlgebra.lean`](Survival/SATStateDependentCountChernoffKLAlgebra.lean) | Derived |
| 12 | SAT high-probability collapse follows from the derived Chernoff/KL profile | `collapseWithNonnegativeMarginChernoffBound_pathPMF` and stopped/hitting variants | [`Survival/SATStateDependentCountChernoffKLAlgebra.lean`](Survival/SATStateDependentCountChernoffKLAlgebra.lean) | Derived |
| 13 | Bernoulli bad-event CSPs have a reusable parameter template | `Parameters`, `chernoffFailureBound` | [`Survival/BernoulliCSPTemplate.lean`](Survival/BernoulliCSPTemplate.lean) | Derived |
| 14 | Bernoulli CSP finite path measures generate their own MGF witnesses | `pathPMF`, `mgf_badCountRV_eq_bernoulliBadMGF_pow` | [`Survival/BernoulliCSPPathMeasure.lean`](Survival/BernoulliCSPPathMeasure.lean) | Derived |
| 15 | Generic Bernoulli CSP path tails satisfy the KL/Chernoff profile | `exactCountFailureBound_le_chernoffFailureBound_of_interior` | [`Survival/BernoulliCSPPathChernoff.lean`](Survival/BernoulliCSPPathChernoff.lean) | Derived |
| 16 | Generic Bernoulli CSP path tails imply operational collapse/hitting bounds | `thresholdCrossingWithChernoffBound_of_linearMargin` and wrappers | [`Survival/BernoulliCSPPathCollapse.lean`](Survival/BernoulliCSPPathCollapse.lean) | Derived |
| 17 | Random k-SAT is an instance with bad probability `(1/2)^k` | `kSATParameters`, `kSAT_expectedBadEmission_eq_drift` | [`Survival/KSATBernoulliTemplate.lean`](Survival/KSATBernoulliTemplate.lean) | Derived |
| 18 | Random k-SAT path exposure inherits generic path/MGF machinery | `mgf_badCountRV_eq_kSATBadMGF_pow` | [`Survival/KSATClauseExposureProcess.lean`](Survival/KSATClauseExposureProcess.lean) | Derived |
| 19 | Random k-SAT inherits Chernoff/KL collapse and hitting-time wrappers | `stoppedCollapseWithChernoffBound_of_linearMargin` and variants | [`Survival/KSATChernoffCollapse.lean`](Survival/KSATChernoffCollapse.lean) | Derived |
| 20 | k = 3 agrees with the existing random 3-SAT stack | `kSAT3_chernoffFailureBound_eq_countChernoffFailureBound` and operational bridge theorems | [`Survival/KSATToSATChernoffBridge.lean`](Survival/KSATToSATChernoffBridge.lean), [`Survival/BernoulliCSPToSATBridge.lean`](Survival/BernoulliCSPToSATBridge.lean) | Derived |

## Assumptions vs Derived Components

| Component | Status in v1.0 |
|---|---|
| finite horizon | Scope assumption |
| iid Bernoulli bad events | Scope assumption |
| fixed assignment / bad-event exposure viewpoint | Scope assumption |
| bad-event probability `p` | Domain input, then checked as `0 < p < 1` |
| 3-SAT bad probability `1/8` | Derived from the SAT specialization |
| k-SAT bad probability `(1/2)^k` | Derived from the k-SAT specialization |
| drift sign | Derived from first moment / Bernoulli parameters |
| non-flat observable mean | Derived |
| MGF product | Derived from path PMF recursion |
| Chernoff/KL profile | Derived from MGF and KL algebra |
| collapse / stopped-collapse / hitting-time bound | Derived from the lower-tail profile |

## What Is Intentionally Not Claimed

- Infinite-horizon Ionescu-Tulcea construction is not part of SAT chain v1.0.
- Almost-sure Birkhoff/ergodic theorems are not part of SAT chain v1.0.
- Non-iid or adaptively selected clauses are not part of SAT chain v1.0.
- Solver-adaptive dynamics such as CDCL or WalkSAT policy dynamics are not part of SAT chain v1.0.
- XOR-SAT rank/nullity dynamics are not part of SAT chain v1.0.
- General open-system thermodynamics is not claimed; the scope is the Bernoulli bad-event CSP class.

These exclusions are design boundaries, not proof gaps in the stated v1.0 claim.

## Reusable Interface for Horizontal Expansion

To instantiate a new domain in the same style, provide:

1. A bad-event probability `p` with proofs `0 < p` and `p < 1`.
2. A one-sided emission scale and drift satisfying the Bernoulli template.
3. A finite-horizon path PMF or a specialization of `BernoulliCSPPathMeasure`.
4. A bridge from the domain-facing count/additive functional to the generic bad-count tail.
5. Optional operational wrappers to expose collapse, stopped-collapse, and hitting-time bounds.

The first horizontal-expansion pilot is now present:

- [`Survival/XORSATBernoulliTemplate.lean`](Survival/XORSATBernoulliTemplate.lean)
  instantiates the Bernoulli template with bad-event probability `1 / 2`.
- [`Survival/XORSATClauseExposureProcess.lean`](Survival/XORSATClauseExposureProcess.lean)
  supplies the finite-horizon path PMF and MGF product.
- [`Survival/XORSATChernoffCollapse.lean`](Survival/XORSATChernoffCollapse.lean)
  exposes the same collapse, stopped-collapse, and hitting-time wrappers.

This is fixed-assignment `k`-XOR-SAT as a Bernoulli bad-event exposure model.
Full rank dynamics should be treated as a later, separate extension.

The second horizontal-expansion pilot is also present:

- [`Survival/QColoringBernoulliTemplate.lean`](Survival/QColoringBernoulliTemplate.lean)
  instantiates the Bernoulli template with bad-event probability `1 / q`.
- [`Survival/QColoringEdgeExposureProcess.lean`](Survival/QColoringEdgeExposureProcess.lean)
  supplies the finite-horizon edge-exposure path PMF and MGF product.
- [`Survival/QColoringChernoffCollapse.lean`](Survival/QColoringChernoffCollapse.lean)
  exposes the same collapse, stopped-collapse, and hitting-time wrappers.

This is fixed-coloring `q`-coloring edge exposure.  Random graph dependencies,
degree correlations, and coloring-algorithm dynamics should be treated as later,
separate extensions.

## Build Check

The snapshot is intended to build through the top-level target:

```bash
cd lean
lake build Survival
```
