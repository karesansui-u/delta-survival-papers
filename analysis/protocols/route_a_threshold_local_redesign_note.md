# Route A Threshold-Local Redesign Note

Status: design note. Not validation evidence and not a frozen preregistration.

Date: 2026-04-23

## 1. Decision

The next Route A empirical attempt should be **Exp43b q-coloring with a
threshold-local protocol**.

Reason:

- q-coloring is visibly outside SAT syntax and therefore gives stronger Route
  A width value than another SAT-like family.
- Exp43 pilot_v1/v2 did not fail as a theory test. They showed that broad
  rho grids are too coarse for finite-size random graph colorability.
- The existing Exp43 harness is infrastructure-clean: generation, CNF encoding,
  exact solver path, independent verifier, and JSONL resume all work.

Therefore the correct move is not to abandon q-coloring, and not to silently
keep tuning. The correct move is to redesign it as a threshold-local
calibration -> freeze -> validation experiment.

## 2. What Exp43 showed

Exp43 pilot_v2:

```text
records: 1800
SAT: 955
UNSAT: 844
TIMEOUT: 1
MALFORMED: 0
pilot_pass: false
inconclusive_by_30pct_rule: false
informative rho bands:
  q=3: {0.60,0.70,0.80}
  q=4: {0.80}
  q=5: {0.80}
```

The blocker was not solver infrastructure. The blocker was transition-window
placement. q=4 and q=5 had only one informative band, which means the grid was
too coarse to support validation.

This is a calibration finding, not negative validation evidence.

## 3. Redesign principle

The next design must change the claim from:

```text
The theory predicts the absolute colorability threshold.
```

to:

```text
Within a pre-frozen threshold-local window, the first-moment / drift coordinate
predicts or ranks q-colorability better than raw edge count, density, and CNF
encoding-size baselines.
```

This is the right G3/G5 claim. The threshold location is learned during
calibration; the evidence-bearing claim is the relative predictor comparison
inside the frozen window.

## 4. Required phase separation

Exp43b must have three phases.

| phase | role | evidence status |
|---|---|---|
| calibration | locate non-saturated windows, test runtime, test verifier path | exploration only |
| freeze | commit final grid, seed streams, feature schema, predictors, analysis script | commitment |
| primary validation | generate primary data with disjoint seeds and run frozen analysis once | evidence-bearing |

Calibration data cannot be counted as theory-confirming evidence. It can only
select the primary window under precommitted rules.

## 5. Why q-coloring before Cardinality-SAT

Cardinality-SAT is useful, but it is rhetorically still SAT-like. q-coloring is
graph coloring and therefore better addresses the objection that Route A is
only SAT formalization.

Cardinality-SAT remains a good fallback if Exp43b calibration is
infrastructure-clean but still cannot produce distinguishable threshold-local
windows.

## 6. Exp43b design object

The freeze-ready draft is:

```text
analysis/exp43_qcoloring/exp43b_threshold_local_preregistration_draft.md
```

It uses the shared infrastructure protocol:

```text
analysis/protocols/threshold_local_route_a_v1.md
```

Key additions over Exp43:

1. q/n-specific local calibration grids instead of broad global grids.
2. deterministic window selection with one-grid-step buffer.
3. seed stream separation via `phase = calibration | primary`.
4. pre-freeze rank-correlation diagnostic to avoid power collapse.
5. primary validation only after a freeze commit.

## 7. Re-entry condition

Route A q-coloring re-enters validation only when the following exist:

1. calibration closeout note;
2. selected primary window manifest;
3. rank-correlation / power-collapse diagnostic;
4. frozen preregistration;
5. frozen analysis script;
6. disjoint primary seed stream;
7. explicit non-claim list.

Before that point, Exp43b remains exploration.

## 8. Non-claims

This redesign note does not claim:

1. Exp43 validated q-coloring.
2. Exp43b has already passed.
3. the threshold location is a theory prediction.
4. q-coloring alone establishes universal law.
5. solver runtime is the primary endpoint.

The only claim is methodological:

\begin{quote}
Random CSP Route A validation should be threshold-local, with calibration and
primary validation separated by a real freeze point.
\end{quote}
