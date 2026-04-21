# Universality Formal Gap Map

Status: M1 design draft for review. This is not a proof file.

## 1. Target

The informal target theorem 4 is:

```text
If expected repair/resource contribution dominates expected contraction loss
on every prefix, then expected total production is nondecreasing; with bounded
increments, a high-probability stopped-collapse / non-collapse tendency follows.
```

The current Lean tree already proves several pieces of this target under more
specific names. The main task is to map the pieces and identify the smallest
bridge theorem still worth proving.

## 2. Existing Anchors

### A. Local Balance / Exponential Kernel

Representative file:

```text
Survival/GeneralStateDynamics.lean
```

Key anchors:

- `stepNetAction_eq_neg_log_feasible_ratio`
- `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction`
- `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction`
- pure-contraction specialization via `PureContraction`

Status:
  Proven. This is the balance / accounting layer, not yet a tendency theorem.

### B. Deterministic Total Production

Representative file:

```text
Survival/TotalProduction.lean
```

Key anchors:

- `stepRepairSlack`
- `cumulativeRepairSlack`
- `stepTotalProduction`
- `cumulativeTotalProduction`
- `cumulativeLoss_le_cumulativeTotalProduction`

Status:
  Proven definition and algebra layer. This gives conservative total production
  vocabulary but does not by itself state stochastic tendency.

### C. Expectation-Level Nondecrease

Representative files:

```text
Survival/StochasticTotalProduction.lean
Survival/TypicalNondecrease.lean
Survival/CoarseTypicalNondecrease.lean
```

Key anchors:

- `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction`
- `deterministic_expectedCumulative_monotone`
- `coarse_expectedCumulative_monotone_of_micro_nonnegative`
- `coarse_expectedCumulative_monotone_of_micro_resourceBounded`
- `coarse_expectedCumulative_monotone_of_micro_conditionalAzuma`

Status:
  Mostly proven. This is the closest existing Lean layer to "balance becomes
  tendency" at expectation level.

### D. SAT Concrete Tendency

Representative files:

```text
Survival/SATUnconditionalTendency.lean
Survival/SATStateDependentUnconditionalTendency.lean
```

Key anchors:

- `expectedIncrement_pos_of_le`
- `submartingaleLike_stepModel`
- `expectedCumulative_monotone_stepModel`
- `expectedCumulative_eq_initial_add_linear`

Status:
  Proven for SAT clause exposure. This is the likely M2 concrete target.

### E. Bernoulli CSP Interface

Representative file:

```text
Survival/BernoulliCSPUniversality.lean
```

Key anchors:

- `ExposureModel`
- `badProb`
- `drift`
- `expectedBadEmission_eq_drift`
- `collapseWithChernoffBound_of_linearMargin`
- `stoppedCollapseWithChernoffBound_of_linearMargin`
- `hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin`
- domain constructors: `kSAT`, `naeSAT`, `forbiddenPattern`,
  `exactlyOneSAT`, `exactRSAT`, `atMostRSAT`, `atLeastRSAT`,
  `hypergraphColoring`

Status:
  Proven as a finite-horizon Bernoulli bad-event collapse interface. It is
  strong for Route A collapse, but it is not yet phrased as the same generic
  repair-dominates-contraction tendency schema.

### F. High-Probability / Stopped Collapse

Representative files:

```text
Survival/AzumaHoeffding.lean
Survival/ResourceBoundedStochasticCollapse.lean
Survival/CoarseStochasticStoppingTimeCollapse.lean
Survival/StoppingTimeHighProbabilityCollapse.lean
```

Key anchors:

- `collapseWithAzumaHoeffdingBound_of_expected_margin`
- `collapseWithAzumaHoeffdingBound_of_initial_margin_martingaleLike`
- resource-bounded stopped-collapse wrappers
- coarse stopped-collapse wrappers

Status:
  Proven under existing concentration / margin assumptions. The theorem target
  should reuse these rather than introduce a new probability layer.

## 3. Gap Classification

### Gap G1: Naming / Mapping Gap

Problem:
  The current theorem names are domain- and construction-specific. The paper
  target says "repair/resource contribution dominates contraction loss", but
  Lean often phrases the condition as nonnegative step total production,
  resource-bounded dynamics, or submartingale-like expected increments.

Needed output:
  A mapping table in `lean/PAPER_MAPPING.md` from target theorem 4 language to
  existing theorem names.

Difficulty:
  Low.

### Gap G2: Prefix-Dominance Schema

Problem:
  The target theorem says "dominates on every prefix". Existing expectation
  results often use stepwise nonnegative total production or an already-packaged
  resource-bounded assumption.

Candidate bridge theorem:

```text
prefix_dominance_to_expectedCumulative_monotone
```

Informal statement:

```text
If for all t the expected step total production is nonnegative,
or equivalently if every prefix has nonnegative expected total production
increments, then expected cumulative total production is monotone.
```

Likely anchor:

```text
expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
```

Risk:
  If "prefix dominance" is stated only cumulatively rather than stepwise, the
  monotonicity proof needs a lemma turning cumulative prefix inequalities into
  adjacent-step inequalities. That lemma may be false without adjacent-prefix
  assumptions. The target should therefore use stepwise or adjacent-prefix
  dominance.

Difficulty:
  Low to medium, depending on the exact statement.

### Gap G3: SAT Concrete Instance to Generic Schema

Problem:
  SAT state-dependent tendency is already proven, but not explicitly advertised
  as an instance of target theorem 4.

Candidate output:

```text
Survival/SATTargetTheorem4Instance.lean
```

or a paper mapping without new theorem if existing names suffice.

Likely theorem to expose:

```text
expectedCumulative_monotone_stepModel
```

Difficulty:
  Low if mapped only; medium if wrapped under a new generic theorem statement.

Decision rule:
  Add a new wrapper theorem only if either:

- the existing theorem name `expectedCumulative_monotone_stepModel` is harder
  for paper readers to connect to target theorem 4 than a wrapper such as
  `SAT_targetTheorem4_expected_tendency`; or
- Paper 3 / the supplement cites target theorem 4 in a place where the existing
  Lean name would look misaligned.

Otherwise, a `PAPER_MAPPING.md` entry is sufficient.

### Gap G4: Bernoulli CSP General Tendency Wrapper

Problem:
  `BernoulliCSPUniversality.lean` focuses on Bernoulli bad-event collapse and
  Chernoff wrappers. It exposes drift and collapse uniformly, but it may not
  include an expectation-level total-production monotonicity theorem stated in
  the same vocabulary as SAT tendency.

Candidate output:

```text
BernoulliCSP_expectedCumulative_monotone
```

or a wrapper connecting `ExposureModel.drift_pos` and
`expectedBadEmission_eq_drift` to an existing stochastic total-production
process.

Risk:
  The Bernoulli CSP interface may be collapse-centered rather than
  repair-centered. If so, M3 should avoid forcing repair language and instead
  state a collapse/tendency wrapper in the native bad-event exposure vocabulary.

Difficulty:
  Medium.

### Gap G5: High-Probability Non-Collapse Wording

Problem:
  The target says "stopped-collapse / non-collapse tendency follows." Current
  files have stopped-collapse and hitting-time bounds, but the direction may be
  phrased as collapse probability under margin assumptions rather than
  non-collapse under repair dominance.

Resolution:
  Keep two theorem schemas separate:

1. expectation-level nondecrease under nonnegative production;
2. high-probability stopped-collapse / hitting-time bound under concentration
   and margin assumptions.

Do not merge these into a single theorem unless the assumptions are explicit.

Difficulty:
  Medium for wording; low if existing wrappers are simply mapped.

## 4. Proposed M1 Deliverables

M1 should produce:

1. A final version of this gap map.
2. A theorem mapping table:

| Informal target phrase | Existing Lean theorem | Gap |
|---|---|---|
| local balance law | `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction` | none |
| cumulative exponential balance | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | none |
| expected tendency from nonnegative production | `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction` | naming / wrapper |
| coarse expected tendency | `coarse_expectedCumulative_monotone_of_micro_*` | none / mapping |
| SAT state-dependent tendency | `expectedCumulative_monotone_stepModel` | mapping |
| Bernoulli CSP collapse wrapper | `collapseWithChernoffBound_of_linearMargin` | tendency wrapper optional |
| stopped collapse with concentration | resource/coarse stopped-collapse wrappers | wording |

3. A decision on whether M2 needs a new Lean file or only a mapping update.

### 4.1 Best-Case Outcome

If the mapping table shows every gap as `none` or `mapping`, then M2 requires
no new Lean file. A `PAPER_MAPPING.md` update alone suffices.

In that case, target theorem 4 should be described as formally accessible via
existing theorems rather than as a newly proved theorem.

### 4.2 Worst-Case Outcome

If G2 requires stepwise assumptions that the paper-side target language does
not naturally imply, the target wording itself should be adjusted. In that
case:

- document the gap in `PAPER_MAPPING.md` as "target language incompatible with
  current assumption layer";
- propose paper-side wording that uses stepwise or adjacent-prefix dominance;
- avoid stating the generic theorem until paper wording and Lean assumptions
  align.

## 5. Recommended M2 Target

Conservative M2:

```text
Add a SAT target-theorem-4 wrapper theorem only if it reduces paper ambiguity.
Otherwise update PAPER_MAPPING.md with the existing SAT theorem names.
```

Preferred theorem shape if new wrapper is added:

```text
theorem SAT_targetTheorem4_expected_tendency
    (N : ℕ) (s₀ : ℝ) :
    Monotone
      (stepModel N s₀ oneSidedUnsatEmission)
        .toStochasticProcess
        .toExpectedProcess
        .expectedCumulative
```

This is likely a thin wrapper around:

```text
SATStateDependentUnconditionalTendency.expectedCumulative_monotone_stepModel
```

## 6. Recommended M3 Target

Do not start by proving a very abstract "all CSPs repair dominance" theorem.
Instead, expose the existing Bernoulli CSP interface as a common collapse /
drift tendency layer:

```text
For every ExposureModel with 0 < badProb < 1, drift = -log(1-badProb) > 0,
and the finite-horizon Bernoulli bad-event process inherits the existing
Chernoff collapse and stopped-collapse wrappers.
```

Then decide whether an expectation-level total-production wrapper is natural in
the existing process vocabulary.

## 7. Non-Goals for M1-M2

- No new axioms.
- No empirical claims in Lean.
- No infinite-horizon almost-sure theorem.
- No claim that Route A, LLM scope repair, and external metabolism are the same
  mechanism.
- No attempt to prove a universal coefficient.
