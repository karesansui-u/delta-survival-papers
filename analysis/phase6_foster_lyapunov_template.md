# Phase 6.1 Foster-Lyapunov / queueing template

Status: Phase 6.1 v0 planning note after Phase 5 ladder.

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
| total-production tendency | `SecondLawTotalProduction.*` | reader-facing `Sigma` core proven |
| coarse expectation route | `CoarseTypicalNondecrease.*` | expectation-level coarse tendency under assumptions |

The important point is that Phase 6.1 does not start from zero. The algebraic
Lyapunov embedding and the conditional-Azuma concentration route already
exist. The missing piece is reader-facing organization, not a new universal
law.

## 3. Bernoulli template versus Foster-Lyapunov template

| Bernoulli-CSP Phase 4 | Foster-Lyapunov / queueing Phase 6.1 |
|---|---|
| bad-event trajectory `τ` | stochastic or deterministic load path |
| one-sided emission | Lyapunov/load increment or total-production increment |
| `Σ_n = cumulativeProduction` | cumulative total production or cumulative Lyapunov action |
| deterministic center `linearCenter` | expected cumulative drift / lower-bound trajectory |
| Chernoff/KL failure profile | Azuma / bounded-increment / conditional-martingale profile |
| fixed-time lower-bound certificate | expected-margin or lower-tail certificate under concentration assumptions |
| typical-growth certificate | expectation-level monotonicity plus high-probability wrapper when assumptions are present |
| endpoint-defect coarse transfer | same defect-budget pattern, if a coarse readout supplies terminal equality and budget |

The two templates should not be forced to share the same proof engine.
Bernoulli uses Chernoff/KL. Foster-Lyapunov uses drift plus bounded-increment
concentration when a high-probability statement is needed.

## 4. Candidate Phase 6.1 v0 output

The safest Phase 6.1 v0 output is not yet a new Lean theorem named
`CoarseLyapunovSigmaTypicalGrowthWithFailureBound`.

That name may become appropriate later, but v0 should first fix the template:

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

If a Lean wrapper is added next, the safest names are reader-facing aliases of
existing theorems:

- `FosterLyapunovTemplate.lyapunov_cumulativeAction_eq_load_diff`
- `FosterLyapunovTemplate.lyapunov_increment_eq_consumption_sub_recovery`
- `FosterLyapunovTemplate.queue_increment_eq_excessDemand`
- `FosterLyapunovTemplate.queue_stable_increment_nonpos`
- `FosterLyapunovTemplate.queue_overloaded_increment_pos`
- `FosterLyapunovTemplate.expectedSigma_monotone_of_conditionalAzuma`
- `FosterLyapunovTemplate.stoppedCollapseWithFailureBound_of_initialExpectedMargin`

These would not add new mathematics. They would make the class template
reader-facing, similar to what `BernoulliTypicalSigma` did for Bernoulli-CSP.

Avoid names like:

```text
lyapunovSecondLaw
universalLyapunovSigmaGrowth
fosterLyapunovAlwaysIncreases
```

Those would overclaim. Foster-Lyapunov drift gives conditional tendency, not an
unconditional second law.

## 6. What would count as Phase 6.1 v0 closed

Phase 6.1 v0 is closed when the repo has:

1. this template note;
2. theorem-map entries pointing to the existing Lyapunov / queueing / Azuma
   anchors;
3. roadmap wording that identifies Foster-Lyapunov / queueing as the next
   limited class after Bernoulli-CSP;
4. explicit non-claims separating expectation-level tendency from
   high-probability and almost-sure claims.

Lean wrappers can be added after this, but they should be thin aliases first.

## 7. What remains open

Phase 6.1 v0 does not close:

- positive recurrence or geometric ergodicity;
- a full queueing stability theorem beyond the existing deterministic skeletons;
- unconditional high-probability nondecrease;
- a set-level admissible coarse map for Lyapunov systems;
- a cross-class unification theorem.

The correct reading is:

```text
Foster-Lyapunov / queueing is now staged as the second limited class. It shares
the Sigma / drift / concentration / coarse-transfer grammar, but it keeps its
own assumptions and concentration engine.
```

## 8. Recommended next move

After this note, add a thin Lean wrapper only if it improves theorem-map
readability. The first wrapper should not create new assumptions. It should
bundle existing names from:

- `Survival.LyapunovBalanceEmbedding`
- `Survival.QueueStability`
- `Survival.ResourceBoundedConditionalAzuma`
- `Survival.SecondLawTotalProduction`

If that wrapper stays thin, Phase 6.1 can progress without risking a false
claim that Foster-Lyapunov / queueing has already delivered the full class
universality theorem.
