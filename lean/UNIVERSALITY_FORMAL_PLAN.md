# Universality Formal Work — Plan

Status: working formal plan.

## Purpose

The empirical axes test whether structure-aware / `L`-normalized predictors beat
simpler baselines. The formal axis asks a different question:

```text
Under which assumptions does a balance identity become a law of tendency?
```

This is the route from the signed exponential kernel / balance law to
expectation-level or high-probability monotone tendency statements.

## Existing Anchors

Relevant existing Lean layers:

| Layer | Representative files |
|---|---|
| signed balance kernel | `Survival/GeneralStateDynamics.lean` |
| total production | `Survival/TotalProduction.lean`, `Survival/StochasticTotalProduction.lean` |
| resource-bounded tendency | `Survival/ResourceBoundedDynamics.lean`, `Survival/ResourceBudgetToTotalProductionDrift.lean` |
| coarse tendency | `Survival/CoarseTypicalNondecrease.lean` |
| SAT tendency | `Survival/SATUnconditionalTendency.lean`, `Survival/SATStateDependentUnconditionalTendency.lean` |
| concentration / high probability | `Survival/AzumaHoeffding.lean`, `Survival/ResourceBoundedStochasticCollapse.lean` |

## Proposed Formal Target

Review target:

```text
If expected repair/resource contribution dominates expected contraction loss
on every prefix, then expected total production is nondecreasing; with bounded
increments, a high-probability stopped-collapse / non-collapse tendency follows.
```

This should be phrased as a reusable theorem schema rather than a domain claim.

## Work Packages

1. Map theorem names currently available for:
   - local balance;
   - expectation-level nondecrease;
   - coarse-grained typical nondecrease;
   - high-probability stopped collapse.
2. Identify the smallest theorem gap between the supplement's "target theorem
   4" language and current Lean files.
3. Add no new domain-specific axioms unless the gap is explicitly documented.
4. Update `lean/PAPER_MAPPING.md` if an existing theorem already covers the
   target in a different name.

## Milestones

### M1: Gap Analysis

Target: 2 weeks.

- Identify the smallest theorem gap between the supplement §12 target theorem 4
  and existing Lean layers.
- Output: `lean/UNIVERSALITY_GAP_MAP.md` with explicit proven / unproven steps.

### M2: SAT Concrete Instance

Target: 1 month.

- Prove or map the target schema for SAT state-dependent clause exposure.
- Anchors: `Survival/SATStateDependentUnconditionalTendency.lean` and related
  SAT state-dependent files.

### M3: Bernoulli CSP Generalization

Target: 2 months.

- Abstract the SAT proof pattern to the Bernoulli-CSP universality class.
- Anchor: `Survival/BernoulliCSPUniversality.lean`.

### M4: Stopped / Coarse Versions

Target: 3 months.

- Extend the schema to stopped-collapse and coarse-grained variants where the
  existing assumptions support it.
- Anchors: `Survival/CoarseTypicalNondecrease.lean` and
  `Survival/ResourceBoundedStochasticCollapse.lean`.

## Non-goals

- Do not prove empirical universality in Lean.
- Do not assert almost-sure infinite-horizon ergodic results in this stage.
- Do not collapse Route A/B/C distinctions; formal results remain conditional
  on their assumptions.
