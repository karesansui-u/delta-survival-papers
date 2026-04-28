# Phase 5 admissible-map ladder

Status: Phase 5 ladder note after `1b64d69`.

This note answers a narrow planning question:

```text
Can Phase 5 be closed in one push?
```

Answer:

```text
No, not if Phase 5 means a necessary-and-sufficient characterization of all
admissible maps.

Yes, if Phase 5 means fixing the Bernoulli sufficient-condition ladder and the
exit criteria for moving to Phase 6.
```

The distinction matters. Phase 4 closed quickly because the Bernoulli path
measure, Chernoff/KL stack, total-production wrapper, and endpoint-defect
transfer were already present or could be connected thinly. Phase 5 is
different: the central risk is not proof length, but over-defining
"admissible map" too strongly or too weakly.

## 1. Phase 5 ladder

The current Bernoulli admissible-map route should be read as a ladder of
increasingly concrete compatibility layers.

| Level | Name | What is fixed | Lean anchor | Status |
|---|---|---|---|---|
| 0 | exact readout identity | no coarse loss; same terminal readout | `BernoulliTypicalSigma` micro certificates | closed |
| 1 | endpoint-defect transfer | terminal readout loses at most endpoint budget \(\delta\) | `BernoulliTypicalSigma.coarseBernoulliSigma_*_of_endpointDefectBudget` | closed |
| 2 | v0 sufficient coarse readout | terminal equality, endpoint defect budget, coarse monotonicity | `BernoulliAdmissibleMapV0.BernoulliCoarseReadoutV0` | closed |
| 3 | defect-controlled two-stage algebra | contracted-intermediate defects cancel in signed action | `DefectControlledAdmissibleMap.*` | closed at readout level |
| 4 | set-level defect-controlled instantiation | actual coarse maps, positive masses, feasible / contracted / repaired compatibility | not yet a full Lean wrapper | open |
| 5 | Bernoulli necessary-side pruning | which v0 assumptions are necessary, redundant, or replaceable | no Lean theorem yet | open |
| 6 | full Bernoulli admissible-map characterization | necessary/sufficient generated class | no Lean theorem yet | open |

This means Phase 5 v0 is closed, but Phase 5 full characterization is not.

## 2. What `1b64d69` closed

`Survival.BernoulliAdmissibleMapV0` packages the following sufficient
conditions:

```text
terminal equality:
  Sigma_bar_n = Sigma_n + e0 - en

endpoint defect budget:
  en - e0 <= delta

coarse monotonicity:
  Sigma_bar_0 <= Sigma_bar_n
```

Under these assumptions, the Phase-4 lower-bound and typical-growth
certificates transfer:

```text
center_n - r <= Sigma_n

becomes

center_n - r - delta <= Sigma_bar_n
```

on the same good event, with the same Chernoff failure profile.

This is a useful Phase-5 result because it gives an external reader a precise
checklist: if a coarse Bernoulli readout can supply these three facts, then the
coarse certificate follows mechanically.

## 3. What remains open

The following claims are intentionally not closed:

- Every natural coarse map satisfies the v0 package.
- The v0 package is necessary.
- Coarse monotonicity follows automatically from terminal equality and defect
  budget.
- Endpoint defect budget follows automatically from any set-level coarse map.
- Bernoulli-CSP universality is a maximal generated class.
- There is an unconditional coarse-graining DPI.

These are not small omissions. They are the real Phase-5 frontier.

## 4. Phase 5 exit criteria

There are two different exits.

### Exit A: enough for Phase 6

Phase 5 is sufficient for entering Phase 6 once the repo has:

1. a Bernoulli v0 sufficient package;
2. a ladder note distinguishing closed / open layers;
3. theorem-map entries that prevent the v0 package from being read as a full
   characterization;
4. roadmap wording that sends the next work to other classes rather than
   pretending the Bernoulli necessary side is solved.

This exit is now the intended short-term exit.

### Exit B: full Phase 5

Full Phase 5 would require:

1. set-level construction of the v0 package from actual coarse maps;
2. proof that the construction composes under admissible coarse maps;
3. a minimality or necessity analysis of terminal equality, endpoint budget,
   and coarse monotonicity;
4. a generated-class statement for Bernoulli-CSP admissible maps;
5. a failure or counterexample ledger for maps that violate the conditions.

This is not safe to claim yet.

## 5. Recommended next move

Use Exit A.

Phase 6 can begin with the v0 pattern as a reusable template:

```text
class-specific observable
  + lower-bound / typical-growth certificate
  + defect-budget transfer
  + explicit non-claims
```

The next class should not try to copy Bernoulli's iid bad-event structure
verbatim. It should instead ask:

```text
What is the class-specific observable?
What is the class-specific lower-bound or drift certificate?
What is the correct defect-budget transfer?
Which claims remain only expectation-level or fixed-time?
```

This makes Foster-Lyapunov / queueing the natural next candidate, with
repair-maintenance as the next finite-prefix balance candidate.

## 6. Public wording

Safe wording:

```text
Phase 5 v0 closes a Bernoulli sufficient-condition package for coarse Sigma
certificate transfer. This is enough to start Phase 6 class expansion, but not
enough to claim a necessary-and-sufficient admissible-map characterization.
```

Unsafe wording:

```text
Phase 5 proves the admissible-map characterization.
```

The second sentence is false at the current stage.
