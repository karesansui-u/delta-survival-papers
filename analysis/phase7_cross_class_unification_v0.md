# Phase 7 Cross-Class Unification V0

Status: Phase 7 v0 registry / common-profile note.

This note records the first cross-class unification step after three limited
class templates were staged:

- Bernoulli-CSP / one-sided iid bad-event exposure.
- Foster-Lyapunov / queueing.
- Repair-Maintenance finite-prefix / resource-bounded stochastic models.

This is not a universal second-law theorem, not a necessary/sufficient
admissible-map characterization, and not a proof that these are the only natural
limited classes.  It is the first reader-facing registry showing that the same
formal grammar has now appeared in three different class templates.

## 1. What Phase 7 v0 Closes

Phase 7 v0 closes the following narrow claim:

> The three currently registered limited classes all instantiate the same
> Phase-7 v0 profile: Sigma / total-production grammar, expectation-level
> tendency, finite-horizon high-probability certificate route, and conditional
> coarse-transfer route.

This profile is now also machine-registered in:

```text
lean/Survival/CrossClassUnificationV0.lean
```

The Lean registry is intentionally modest.  It records the current profile of
the three classes and proves:

```text
all_registered_classes_supportPhase7V0
```

It does not prove the generic theorem explaining why every future admissible
template class must have this profile.

## 2. The Three-Class Profile

| Class template | Sigma grammar | Expected tendency | High-probability certificate | Coarse transfer | Pathwise nondecrease | Engine |
|---|---:|---:|---:|---:|---:|---|
| Bernoulli-CSP | yes | yes | yes | yes | yes | Chernoff / KL |
| Foster-Lyapunov / queueing | yes | yes | yes | yes | no v0 claim | conditional Azuma |
| Repair-Maintenance | yes | yes | yes | yes | no v0 claim | resource-bounded Azuma |

The common profile is therefore:

```text
Sigma grammar
  + expectation-level tendency
  + finite-horizon high-probability certificate
  + conditional coarse transfer
```

The stronger pathwise nondecrease component is currently class-specific to the
one-sided Bernoulli-CSP template.  It should not be promoted to the cross-class
universal profile.

## 3. What the Three Classes Contribute

### Bernoulli-CSP

The Bernoulli-CSP template contributes the strongest finite-path anchor:

- one-sided bad-event emissions;
- pathwise adjacent-step nondecrease;
- expected Sigma monotonicity;
- KL / Chernoff lower-tail certificates;
- fixed-time typical-growth certificate;
- endpoint-defect coarse-transfer certificate.

Lean anchors:

- `Survival.BernoulliTypicalSigma`
- `Survival.BernoulliAdmissibleMapV0`
- `Survival.BernoulliCSPUniversality`

### Foster-Lyapunov / Queueing

The Foster-Lyapunov / queueing template contributes the second limited class,
with a different engine:

- Lyapunov / load increments as signed structural action;
- queue overload finite-prefix skeleton;
- conditional-Azuma and resource-bounded high-probability routes;
- coarse high-probability transfer under explicit stochastic compatibility.

It does not claim positive recurrence, geometric ergodicity, unconditional
Lyapunov second law, or Bernoulli-style pathwise nondecrease.

Lean anchors:

- `Survival.LyapunovBalanceEmbedding`
- `Survival.QueueStability`
- `Survival.ResourceBoundedConditionalAzuma`
- `Survival.FosterLyapunovTemplate`

### Repair-Maintenance

The Repair-Maintenance template contributes the third limited class, where both
sides of the signed balance are explicit:

- damage / repair finite-prefix net-consumption algebra;
- margin and threshold-crossing wrappers;
- `Sigma = B + C = L + repair_slack` grammar;
- resource-bounded stopped-collapse / hitting-time certificates;
- conditional coarse transfer.

It does not claim a stochastic reliability theorem, optimal maintenance policy,
unconditional repair law, or Bernoulli-style pathwise nondecrease.

Lean anchors:

- `Survival.RepairMaintenanceBalance`
- `Survival.SecondLawTotalProduction`
- `Survival.ResourceBoundedStochasticCollapse`
- `Survival.RepairMaintenanceTemplate`

## 4. Why This Matters

Before Phase 7 v0, the program had strong class-specific templates.  After Phase
7 v0, the program has a common cross-class profile.

This matters because the eventual Phase 7 target is not simply:

```text
Bernoulli-CSP has a tendency theorem.
```

It is closer to:

```text
Whenever a structural template supplies Sigma grammar, a tendency route,
concentration / certificate control, and conditional coarse transfer, it belongs
to a law-like limited-class profile.
```

Phase 7 v0 does not yet prove that generic statement.  It supplies the evidence
and registry from which that generic statement can be attempted.

## 5. Non-Claims

Phase 7 v0 does not claim:

- a single unconditional universal inequality;
- a physical second-law theorem;
- a generic theorem over all structural-maintenance problems;
- a necessary/sufficient admissible-map characterization;
- that pathwise nondecrease holds outside the Bernoulli-CSP class;
- that Chernoff / KL, conditional Azuma, or resource-bounded Azuma exhaust all
  possible certificate engines.

The correct reading is:

```text
Three limited classes now instantiate the same Phase-7 v0 profile.
This makes a cross-class unification theorem a concrete next target.
```

## 6. Next Work

The natural next steps are:

1. Phase 7 v1: extract the generic schema behind the three profiles.
2. Phase 7 v2: identify whether subadditivity, resource-cost lower bounds, or
   defect-controlled admissible maps provide the cleanest generic theorem.
3. Phase 5 open ladder: continue set-level instantiation and necessary-side
   pruning for admissible maps.
4. Phase 6 refinements: strengthen Repair-Maintenance or Foster-Lyapunov only
   when doing so clarifies the Phase 7 generic schema.

The main discipline is unchanged: do not turn the registry into a universal
claim before the generic theorem is actually written.
