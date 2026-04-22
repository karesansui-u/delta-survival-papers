# Universality Formal Gap Map

Status: M1 gap analysis completed for review. This is not a proof file.

Date: 2026-04-22

## 1. Target

The informal target theorem 4 is:

```text
If expected repair/resource contribution dominates expected contraction loss
on every prefix, then expected total production is nondecreasing; with bounded
increments, a high-probability stopped-collapse / non-collapse tendency follows.
```

The current Lean tree already proves several pieces of this target under more
specific names. M1 therefore treats target theorem 4 as a **mapping and
packaging problem first**, not as an immediate new proof obligation.

M1 conclusion:

```text
Expectation-level tendency is already formally accessible through existing
Lean theorems. The remaining work is reader-facing theorem mapping and careful
paper-side wording. A new Lean wrapper is optional, not required.
```

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

M1 decision:
  Real gap, but documentation-only. Solved by the target theorem 4 mapping
  table in `PAPER_MAPPING.md`.

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

M1 decision:
  Do not add a bridge theorem for vague cumulative-prefix dominance. The paper
  wording should instead use one-step / adjacent-prefix nonnegative total
  production, matching the existing Lean assumption layer.

Difficulty:
  Low if wording is corrected; medium only if the paper insists on a broader
  cumulative-prefix statement.

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

M1 decision:
  Mapping is sufficient for now. A wrapper such as
  `SAT_targetTheorem4_expected_tendency` is optional M2 polish only.

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

M1 decision:
  Do not force repair-dominance vocabulary onto Bernoulli-CSP. Map it as a
  finite-horizon bad-event drift / Chernoff collapse tendency interface. This
  is formally useful and empirically aligned with Mixed-CSP, but it is a
  different schema from resource-repair total production.

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

M1 decision:
  Existing high-probability wrappers are sufficient under their stated
  concentration and margin assumptions. They should be cited as a separate
  branch, not as the expectation-level theorem itself.

Difficulty:
  Medium for wording; low if existing wrappers are simply mapped.

## 4. M1 Deliverables

M1 produces:

1. This final gap map.
2. A theorem mapping table in `PAPER_MAPPING.md`.
3. A decision on whether M2 needs a new Lean file or only a mapping update.

The core mapping is:

| Informal target phrase | Existing Lean theorem | Gap |
|---|---|---|
| local balance law | `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction` | none |
| cumulative exponential balance | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | none |
| expected tendency from nonnegative production | `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction` | naming / wrapper |
| coarse expected tendency | `coarse_expectedCumulative_monotone_of_micro_*` | none / mapping |
| SAT state-dependent tendency | `expectedCumulative_monotone_stepModel` | mapping |
| Bernoulli CSP collapse wrapper | `collapseWithChernoffBound_of_linearMargin` | tendency wrapper optional |
| stopped collapse with concentration | resource/coarse stopped-collapse wrappers | wording |

## 5. M2 Decision

M2 recommendation:

```text
M2-A: mapping-only is sufficient.
```

Rationale:

- expectation-level tendency is already covered by
  `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction`,
  `expectedCumulative_monotone`, and the coarse wrappers;
- SAT concrete tendency is already covered by
  `expectedCumulative_monotone_stepModel`;
- high-probability stopped-collapse is already covered by resource/coarse
  stopped-collapse wrappers under explicit concentration assumptions.

Optional M2 polish:

```text
M2-B: add thin reader-facing wrapper names only if the paper needs them.
```

Candidate wrapper shape:

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

## 6. Paper-Side Wording Required by M1

Avoid:

```text
If repair dominates contraction on every prefix, then typical nondecrease follows.
```

unless "dominates on every prefix" is explicitly adjacent-step-wise.

Safer wording:

```text
At the expectation level, a law-of-tendency theorem is available when one-step
total production is nonnegative, or when an equivalent resource-bounded
assumption implies nonnegative one-step total production. Under admissible
coarse-graining, this monotonicity transfers to the coarse process.
High-probability stopped-collapse statements require additional concentration
and margin assumptions and are treated as a separate theorem schema.
```

## 7. Recommended M3 Target

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

## 8. Non-Goals for M1-M2

- No new axioms.
- No empirical claims in Lean.
- No infinite-horizon almost-sure theorem.
- No claim that Route A, LLM scope repair, and external metabolism are the same
  mechanism.
- No attempt to prove a universal coefficient.
