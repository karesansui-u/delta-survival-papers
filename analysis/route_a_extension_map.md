# Route A Extension Map

Status: calibration draft after Exp.41 and before Mixed-CSP execution.

This note separates three things that are easy to conflate:

1. formal Bernoulli-exposure instances already present in Lean;
2. empirical Route A tests suitable for near-term data collection;
3. analogous or sanity examples that should not be promoted to Route A
   universality anchors.

The organizing rule is conservative:

```text
Route A empirical priority goes to domains where L is domain-intrinsic,
drift weights are nontrivial across constraints or families, and the solver /
evaluator does not replace the intended phenomenon with a different polynomial
structure.
```

## 1. Current Priority

The next Route A empirical gate remains the frozen Mixed-CSP program.

Primary empirical question:

```text
Does L_plus_n beat raw_plus_n on held-out feasibility prediction?
```

The first implementation should keep the primary grid clean:

- 3-SAT;
- 3-NAE-SAT;
- SAT/NAE mixtures;
- exactly-one only as pilot / exploratory unless preregistered promotion
  criteria are met before primary data.

This is the first empirical universality-class anchor. Later Route A domains
should wait until Mixed-CSP has either passed or exposed a specific failure
branch.

## 2. Safe Empirical Route A Extensions

These are reasonable next candidates after Mixed-CSP.

| Candidate | Why It Is Safe | Lean Status | Empirical Role |
|---|---|---|---|
| `3-NAE-SAT` | No special polynomial solver shortcut for generic instances; drift differs from SAT: `log(4/3)` | Present via NAE-SAT Bernoulli templates / collapse wrappers | Already in Mixed-CSP primary |
| `q`-coloring, fixed coloring under edge exposure | Bad edge probability is `1/q`, drift `log(q/(q-1))`; varying `q` gives clean drift variation | Present via q-coloring Bernoulli template / Chernoff wrapper | Natural post-Mixed-CSP cross-family test |
| Cardinality-SAT family | Drift varies by binomial count, e.g. `log(2^k / C(k,r))`; one family can scan multiple drift levels | Present via exactly-`r`, at-most, at-least wrappers | Good post-Mixed-CSP robustness / dose-response test |
| Forbidden-pattern CSP | Direct Bernoulli bad-event semantics; drift is specified by number of forbidden patterns | Present in Bernoulli CSP interface | Good generalization if SAT/NAE passes |

For these candidates, the preferred empirical claim is not an absolute
prediction of a universal `c`. The preferred claim is:

```text
L-normalized predictors outperform raw count / raw density baselines
out of sample.
```

## 3. Risky Candidates: Keep, But Do Not Lead With Them

### XOR-SAT

XOR-SAT is useful as a formal exposure-level instance but risky as an empirical
solver-scaling anchor.

Reason:

- k-XOR-SAT has a polynomial Gaussian-elimination solution;
- empirical cost can be dominated by rank/nullity dynamics rather than generic
  SAT-style search;
- applying a generic SAT solver can make the result solver-artifact-sensitive.

Policy:

```text
Keep XOR-SAT as a Lean / exposure-level horizontal expansion.
Do not use it as a primary empirical c-scaling or Route A universality test.
```

### LDPC / Linear Codes

Parity checks give a clean first-moment shrinkage of the codeword space.
However, decoder performance is a separate object.

Separation:

| Layer | Status |
|---|---|
| First moment / feasible codeword volume | L is clean and domain-intrinsic |
| BP / syndrome / iterative decoding performance | Depends on decoder and channel |

Policy:

```text
Treat LDPC as an observational analog or future bridge domain.
Do not claim drift -> decoder c point prediction.
```

### SAT Chain v2.0 Ideas

Infinite horizon, adaptive clause selection, CDCL-adaptive dynamics,
almost-sure ergodic statements, and XOR rank/nullity dynamics are outside the
current SAT chain v1.0 freeze.

Reason:

- finite-horizon iid Bernoulli exposure is the closed formal scope;
- adaptive selection breaks the simple product / MGF structure;
- infinite-horizon path measures and almost-sure limits require a separate
  probability layer;
- solver-adaptive dynamics mix domain drift with algorithm state.

Policy:

```text
Do not describe v2.0 as the shortest route.
List it only as a long-horizon research program after current formal gates.
```

## 4. Not Route A Empirical Anchors

These can remain useful as analogies, sanity checks, or Route B/C candidates,
but should not be framed as the next Route A universality anchors.

| Candidate | Reason |
|---|---|
| Bootstrap percolation | Threshold-correlated dynamics; constraint shrinkage is not directly fixed by iid bad-event spec; better as Route B/C |
| Branching process extinction | Already useful as an expectation-level sanity / classical analog; not a new Route A universality anchor |
| Serial reliability | Textbook multiplicative sanity check; useful for intuition, not a frontier universality test |
| Generic percolation thresholds | Often natural for Route B or bridge claims, but require careful measure and finite-size threshold handling |

The criterion is not whether a domain resembles structural persistence. It is
whether it supports the strong Route A empirical protocol without changing the
meaning of the predictor or the endpoint.

## 5. Recommended Ordering

Near-term:

1. Run Mixed-CSP primary as frozen.
2. If Mixed-CSP passes, design q-coloring empirical replication.
3. Then design Cardinality-SAT drift-scan / robustness test.

Hold back:

- XOR-SAT empirical scaling;
- LDPC decoder performance claims;
- SAT chain v2.0 formal expansion;
- bootstrap percolation as Route A.

This ordering preserves the main methodological discipline:

```text
first prove that L carries predictive information beyond raw baselines,
then broaden the universality class.
```

## 6. Public Wording

Recommended:

```text
The formal Bernoulli-CSP layer already covers several horizontal instances.
For empirical Route A replication, we prioritize SAT/NAE Mixed-CSP first, then
q-coloring and Cardinality-SAT. XOR-SAT and LDPC-like examples are useful
formal or analogical cases, but they are not primary empirical solver-scaling
anchors because solver / decoder structure can dominate the observed c.
```

Avoid:

```text
XOR-SAT is the top empirical extension.
SAT chain v2.0 is the shortest next route.
Bootstrap percolation is Route A.
LDPC decoder performance should follow from drift-weighted L alone.
```
