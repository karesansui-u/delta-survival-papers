# Phase 6.1 Foster-Lyapunov / queueing template

Status: Phase 6.1 v1 template note after Phase 5 ladder. A thin Lean wrapper
now exists in `Survival.FosterLyapunovTemplate`, including resource-bounded
high-probability stopped-collapse / hitting-time certificates and coarse
high-probability transfer wrappers.

This note starts Phase 6 by asking how the Bernoulli-CSP `Sigma` template can
be reused in a second, genuinely different class: Foster-Lyapunov / queueing
drift systems.

It is not a proof of a new class-universality theorem. It is a template map:
which Bernoulli components have Foster-Lyapunov analogues, which parts already
exist in Lean, and which claims remain conditional.

## 1. Why Foster-Lyapunov / queueing is the next class

Bernoulli-CSP is a specification-fixed class with one-sided iid bad-event
exposure. Its finite-path `Sigma` certificates are built from:

- nonnegative one-step emissions;
- a deterministic center;
- Chernoff/KL lower-tail control;
- endpoint-defect coarse transfer.

Foster-Lyapunov / queueing is different. It is not an iid bad-event template.
Its natural anchors are:

- a Lyapunov or load coordinate \(Z_t\);
- increments \(Z_{t+1}-Z_t\), read as net-consumption amounts;
- drift / submartingale or supermartingale hypotheses;
- bounded-increment concentration, when high-probability statements are needed;
- queue overload or service-margin skeletons as concrete examples.

This makes it the right Phase-6 class: close enough to share the `Sigma` /
total-production grammar, but different enough to test whether the framework is
more than Bernoulli-CSP.

## 2. Existing Lean anchors

| Role | Lean anchor | Current status |
|---|---|---|
| Lyapunov/load increment | `LyapunovBalanceEmbedding.increment` | defined |
| cumulative Lyapunov action | `LyapunovBalanceEmbedding.cumulativeAction` | telescopes to `Z n - Z 0` |
| positive/negative increment split | `consumptionAmount`, `recoveryAmount` | proven decomposition |
| exponential maintenance coordinate | `relativeMaintenance` | local update proven |
| fluid queue load | `queueLoad` | queue backlog embedded as Lyapunov/load sequence |
| queue stable / overload regimes | `QueueStability.*` | deterministic skeleton proven |
| conditional-Azuma resource-bounded route | `ResourceBoundedConditionalAzuma.*` | expected monotonicity and stopped-collapse wrappers proven under assumptions |
| resource-bounded stochastic collapse route | `ResourceBoundedStochasticCollapse.*` | high-probability stopped-collapse / hitting-time and coarse-transfer wrappers proven under assumptions |
| total-production tendency | `SecondLawTotalProduction.*` | reader-facing `Sigma` core proven |
| coarse expectation route | `CoarseTypicalNondecrease.*` | expectation-level coarse tendency under assumptions |

The important point is that Phase 6.1 does not start from zero. The algebraic
Lyapunov embedding, conditional-Azuma expectation route, and resource-bounded
high-probability route already exist. The reader-facing organization layer is
now present in `Survival.FosterLyapunovTemplate`; it adds stable names and
class-template staging, not a new universal law.

## 3. Bernoulli template versus Foster-Lyapunov template

| Bernoulli-CSP Phase 4 | Foster-Lyapunov / queueing Phase 6.1 |
|---|---|
| bad-event trajectory `τ` | stochastic or deterministic load path |
| one-sided emission | Lyapunov/load increment or total-production increment |
| `Σ_n = cumulativeProduction` | cumulative total production or cumulative Lyapunov action |
| deterministic center `linearCenter` | expected cumulative drift / lower-bound trajectory |
| Chernoff/KL failure profile | Azuma / bounded-increment / conditional-martingale profile |
| fixed-time lower-bound certificate | expected-margin or lower-tail certificate under resource-bounded concentration assumptions |
| typical-growth certificate | expectation-level monotonicity plus stopped / hitting high-probability wrapper when assumptions are present |
| endpoint-defect coarse transfer | coarse stochastic compatibility plus a resource-bounded coarse model |

The two templates should not be forced to share the same proof engine.
Bernoulli uses Chernoff/KL. Foster-Lyapunov uses drift plus bounded-increment
concentration when a high-probability statement is needed.

## 4. Candidate Phase 6.1 v1 output

The safest Phase 6.1 v1 output is not yet a new Lean theorem named
`CoarseLyapunovSigmaTypicalGrowthWithFailureBound`.

That name may become appropriate later, but v1 first fixes the high-probability
certificate layer that can be stated without overclaim:

```text
Foster-Lyapunov / queueing class supports the same structural role as
Bernoulli-CSP, with a different concentration engine:

load / Lyapunov increment
  -> cumulative action / Sigma
  -> expectation-level tendency under drift assumptions
  -> high-probability stopped-collapse under conditional-Azuma assumptions
  -> coarse transfer only under explicit defect-budget compatibility.
```

This is the Phase-6 counterpart of Phase 5 ladder discipline: state exactly
which layer is closed and which is still conditional.

## 5. Safe Lean wrapper candidates

The thin Lean wrapper now added in `Survival.FosterLyapunovTemplate` uses
reader-facing aliases of existing theorems:

- `FosterLyapunovTemplate.lyapunov_cumulativeAction_eq_load_diff`
- `FosterLyapunovTemplate.lyapunov_increment_eq_consumption_sub_recovery`
- `FosterLyapunovTemplate.lyapunov_relativeMaintenance_succ_eq_mul_exp_neg_increment`
- `FosterLyapunovTemplate.queue_increment_eq_excessDemand`
- `FosterLyapunovTemplate.queue_cumulativeAction_eq_cumulativeOverloadLoss`
- `FosterLyapunovTemplate.queue_stable_increment_nonpos`
- `FosterLyapunovTemplate.queue_overloaded_increment_pos`
- `FosterLyapunovTemplate.expectedSigma_monotone_of_conditionalAzuma`
- `FosterLyapunovTemplate.fosterLyapunov_stoppedCollapseWithFailureBound_of_initialExpectedMargin`
- `FosterLyapunovTemplate.fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin`
- `FosterLyapunovTemplate.fosterLyapunov_resourceBoundedExpectedSigma_monotone`
- `FosterLyapunovTemplate.fosterLyapunov_stoppedCollapseWithFailureBound_of_resourceBoundedExpectedMargin`
- `FosterLyapunovTemplate.fosterLyapunov_stoppedCollapseWithFailureBound_of_resourceBoundedInitialMargin`
- `FosterLyapunovTemplate.fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_resourceBoundedExpectedMargin`
- `FosterLyapunovTemplate.fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_resourceBoundedInitialMargin`
- `FosterLyapunovTemplate.coarseExpectedSigma_monotone_of_conditionalAzuma`
- `FosterLyapunovTemplate.coarseFosterLyapunov_stoppedCollapseWithFailureBound_of_microExpectedMargin`
- `FosterLyapunovTemplate.coarseFosterLyapunov_stoppedCollapseWithFailureBound_of_microInitialMargin`
- `FosterLyapunovTemplate.coarseFosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_microExpectedMargin`
- `FosterLyapunovTemplate.coarseFosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_microInitialMargin`

These do not add an unconditional Lyapunov law. They make the class template
reader-facing, similar to what `BernoulliTypicalSigma` did for Bernoulli-CSP,
while preserving the explicit bounded-increment, margin, concentration, and
coarse-compatibility assumptions.

Avoid names like:

```text
lyapunovSecondLaw
universalLyapunovSigmaGrowth
fosterLyapunovAlwaysIncreases
```

Those would overclaim. Foster-Lyapunov drift gives conditional tendency, not an
unconditional second law.

## 6. What counts as Phase 6.1 v1 closed

Phase 6.1 v1 is closed when the repo has:

1. this template note;
2. theorem-map entries pointing to the existing Lyapunov / queueing / Azuma
   anchors;
3. roadmap wording that identifies Foster-Lyapunov / queueing as the next
   limited class after Bernoulli-CSP;
4. explicit non-claims separating expectation-level tendency from
   high-probability and almost-sure claims.
5. a thin Lean wrapper that exposes those anchors without strengthening them;
6. resource-bounded stopped-collapse / hitting-time high-probability wrappers;
7. coarse stopped-collapse / hitting-time high-probability transfer wrappers
   under explicit stochastic compatibility and a resource-bounded coarse model.

The current wrapper satisfies these items at the alias / reader-facing layer.

## 7. What remains open

Phase 6.1 v1 does not close:

- positive recurrence or geometric ergodicity;
- a full queueing stability theorem beyond the existing deterministic skeletons;
- unconditional high-probability nondecrease;
- Bernoulli-style pathwise nondecrease for arbitrary Foster-Lyapunov systems;
- a set-level admissible coarse map for Lyapunov systems;
- a cross-class unification theorem.

The correct reading is:

```text
Foster-Lyapunov / queueing is now staged as the second limited class. It shares
the Sigma / drift / concentration / coarse-transfer grammar, but it keeps its
own assumptions and concentration engine.
```

## 8. Recommended next move

After this note and wrapper, the next Lean-side step should not force a
Bernoulli-style pathwise nondecrease claim. The most natural next choices are:

1. record explicitly that Foster-Lyapunov Phase 6.1 has closed at the
   expectation / stopped-collapse / hitting-time certificate level, while
   pathwise nondecrease remains class-specific and generally unavailable;
2. proceed to Phase 6.2 Repair-Maintenance as the third limited class template;
3. only later return to set-level Lyapunov admissible maps or necessary-side
   Phase-5 pruning.

The current wrapper bundles existing names from:

- `Survival.LyapunovBalanceEmbedding`
- `Survival.QueueStability`
- `Survival.ResourceBoundedConditionalAzuma`
- `Survival.CoarseTypicalNondecrease`

If that wrapper stays thin, Phase 6.1 can progress without risking a false
claim that Foster-Lyapunov / queueing has already delivered the full class
universality theorem.
