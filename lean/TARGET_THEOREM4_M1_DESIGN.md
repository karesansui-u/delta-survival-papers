# Target Theorem 4 M1 Design

Status: design draft for review.

Date: 2026-04-22

## 1. Purpose

M1 is not a new empirical experiment and not yet a new Lean proof sprint.

Its purpose is to turn the informal target theorem 4 in the signed-kernel /
set-valued dynamics supplement into a precise Lean-facing map:

```text
Which parts are already proven?
Which parts need only paper-side renaming / mapping?
Which parts need a thin wrapper theorem?
Which parts are genuinely future work?
```

The key calibration is:

```text
The project is not merely at balance-law level.
Several expectation-level tendency layers are already proven.
What is still missing is a single reader-facing target theorem 4 package
that connects the paper language to the existing Lean theorem names.
```

## 2. Informal Target

The paper-side target theorem 4 currently says, informally:

```text
Under admissible coarse-graining and resource-bounded set-valued dynamics,
if expected repair / resource contribution dominates contraction loss, then
coarse-grained total production is typically nondecreasing.
```

This should be split into two theorem schemas.

### Schema A: Expectation-Level Tendency

```text
If one-step total production is nonnegative in expectation, or almost surely
nonnegative before taking expectation, then expected cumulative total
production is monotone.
```

This is the clean "balance becomes tendency" layer.

### Schema B: High-Probability Stopped-Collapse / Non-Collapse

```text
If the expected margin is positive and increments are bounded / concentrated,
then stopped collapse or non-collapse admits a high-probability finite-horizon
bound.
```

This should not be merged with Schema A unless all concentration and margin
assumptions are explicitly stated.

## 3. Existing Lean Anchors

### 3.1 Balance / Accounting Layer

Files:

```text
Survival/GeneralStateDynamics.lean
Survival/TotalProduction.lean
```

Representative theorems:

```text
feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction
feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction
cumulativeLoss_le_cumulativeTotalProduction
```

Interpretation:

These prove the signed exponential kernel and resource accounting identities:

```text
m(V_n) = m(V_0) exp(-A_n)
```

and related total-production decompositions. They are balance laws, not yet
tendency laws.

### 3.2 Generic Expectation-Level Tendency

Files:

```text
Survival/StochasticTotalProduction.lean
Survival/TypicalNondecrease.lean
Survival/CoarseTypicalNondecrease.lean
```

Representative theorems:

```text
expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
deterministic_expectedCumulative_monotone
coarse_expectedCumulative_monotone_of_micro_nonnegative
coarse_expectedCumulative_monotone_of_micro_resourceBounded
coarse_expectedCumulative_monotone_of_micro_conditionalAzuma
```

Interpretation:

This is already a tendency layer, but it is phrased in Lean-native vocabulary:

```text
nonnegative step total production
resource-bounded micro dynamics
coarse stochastic compatibility
conditional Azuma wrapper
```

M1 should map these phrases to the paper-side phrase:

```text
repair/resource contribution dominates contraction loss
```

### 3.3 SAT Concrete Tendency

Files:

```text
Survival/SATUnconditionalTendency.lean
Survival/SATStateDependentUnconditionalTendency.lean
```

Representative theorems:

```text
expectedCumulative_monotone_random3ClauseStepModel
expectedCumulative_lower_linear_random3ClauseStepModel
expectedCumulative_monotone_stepModel
expectedCumulative_eq_initial_add_linear
```

Interpretation:

SAT already has an expectation-level law-of-tendency instance. The main gap is
reader-facing packaging, not mathematical substance.

### 3.4 Bernoulli-CSP Collapse / Drift Layer

File:

```text
Survival/BernoulliCSPUniversality.lean
```

Representative theorems / objects:

```text
ExposureModel
badProb
drift
expectedBadEmission_eq_drift
collapseWithChernoffBound_of_linearMargin
stoppedCollapseWithChernoffBound_of_linearMargin
hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
```

Interpretation:

Bernoulli-CSP is strong as a finite-horizon bad-event / collapse interface.
It is not naturally phrased as "repair dominates contraction." M1 should avoid
forcing repair language here. For Bernoulli-CSP, the native tendency wording is:

```text
positive drift / bad-event emission accumulates, and finite-horizon collapse
or hitting-time bounds follow under Chernoff margin assumptions.
```

This is related to target theorem 4, but it is not the same theorem schema as
resource-repair total production.

### 3.5 High-Probability / Stopped-Collapse Layer

Files:

```text
Survival/AzumaHoeffding.lean
Survival/ResourceBoundedStochasticCollapse.lean
Survival/CoarseStochasticStoppingTimeCollapse.lean
Survival/StoppingTimeHighProbabilityCollapse.lean
```

Representative theorems:

```text
collapseWithAzumaHoeffdingBound_of_expected_margin
collapseWithAzumaHoeffdingBound_of_initial_margin_martingaleLike
ResourceBoundedStochasticCollapse.expectedCumulative_monotone
```

Interpretation:

This is the concentration / stopped-collapse branch. It should be mapped as a
separate branch, not folded into the expectation-level monotonicity statement.

## 4. M1 Deliverables

M1 should produce four concrete artifacts.

### D1. Final Gap Map

Update:

```text
lean/UNIVERSALITY_GAP_MAP.md
```

from "M1 design draft" to "M1 gap map", with explicit decisions:

| Gap | M1 decision |
|---|---|
| G1 naming / mapping | real gap; solve in `PAPER_MAPPING.md` |
| G2 prefix dominance | paper wording must use stepwise or adjacent-prefix dominance |
| G3 SAT concrete instance | mapping sufficient unless paper needs a nicer wrapper |
| G4 Bernoulli-CSP wrapper | do not force repair language; map as collapse/drift tendency |
| G5 high probability wording | keep separate from expectation monotonicity |

### D2. PAPER_MAPPING Section

Add a section to:

```text
lean/PAPER_MAPPING.md
```

Proposed heading:

```text
## Target Theorem 4 / Law-of-Tendency Mapping
```

This section should include a table:

| Paper phrase | Lean vocabulary | Lean theorem | Status |
|---|---|---|---|
| signed exponential balance | local net action / feasible mass | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven |
| repair dominates contraction | nonnegative step total production | `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction` | proven |
| coarse-grained typical nondecrease | coarse stochastic compatibility | `coarse_expectedCumulative_monotone_of_micro_nonnegative` | proven |
| resource-bounded coarse tendency | resource-bounded micro dynamics | `coarse_expectedCumulative_monotone_of_micro_resourceBounded` | proven |
| SAT expected tendency | state-dependent SAT step model | `expectedCumulative_monotone_stepModel` | proven |
| Bernoulli-CSP finite collapse tendency | bad-event drift + Chernoff margin | `collapseWithChernoffBound_of_linearMargin` | proven, different schema |
| stopped collapse / non-collapse | margin + bounded increments / concentration | Azuma / stopped-collapse wrappers | proven under assumptions |

### D3. Paper-Side Wording Patch

The supplement should avoid saying:

```text
If repair dominates contraction on every prefix, then typical nondecrease follows.
```

unless "dominates on every prefix" is defined adjacent-step-wise.

Safer wording:

```text
At the expectation level, a law-of-tendency theorem is available when the
one-step total production is nonnegative, or when an equivalent resource-
bounded assumption implies nonnegative one-step total production. Under
admissible coarse-graining, this monotonicity transfers to the coarse process.
High-probability stopped-collapse statements require additional concentration
and margin assumptions and are treated as a separate theorem schema.
```

### D4. M2 Decision Note

At the end of M1, decide one of:

```text
M2-A: Mapping-only.
```

No new Lean file. `PAPER_MAPPING.md` is enough.

```text
M2-B: Thin wrapper.
```

Add a small reader-facing Lean file, likely:

```text
Survival/TargetTheorem4Mapping.lean
```

or

```text
Survival/SATTargetTheorem4Instance.lean
```

containing wrapper theorem names only, with proofs by direct application of
existing theorems.

## 5. Proposed Exact M2 Wrapper Shape

Only add wrappers if the paper needs theorem names that match target theorem 4.

### 5.1 Generic Expectation Wrapper

Candidate name:

```text
targetTheorem4_expected_tendency
```

Likely theorem shape:

```text
theorem targetTheorem4_expected_tendency
    (S : StepModel (μ := μ))
    (h : ∀ t, 0 ≤ᵐ[μ] stepTotalProductionRV S t) :
    Monotone S.toStochasticProcess.toExpectedProcess.expectedCumulative
```

This should be a thin alias of:

```text
expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
```

### 5.2 Coarse Wrapper

Candidate name:

```text
targetTheorem4_coarse_expected_tendency
```

Likely theorem shape:

```text
theorem targetTheorem4_coarse_expected_tendency
    (hcomp : CoarseStochasticCompatibility Smicro Scoarse)
    (hStep : ∀ t, 0 ≤ᵐ[μ] stepTotalProductionRV Smicro t) :
    Monotone Scoarse.toStochasticProcess.toExpectedProcess.expectedCumulative
```

This should be a thin alias of:

```text
coarse_expectedCumulative_monotone_of_micro_nonnegative
```

### 5.3 SAT Wrapper

Candidate name:

```text
SAT_targetTheorem4_expected_tendency
```

Likely theorem shape:

```text
theorem SAT_targetTheorem4_expected_tendency
    (N : ℕ) (s₀ : ℝ) :
    Monotone
      (stepModel N s₀ oneSidedUnsatEmission)
        .toStochasticProcess
        .toExpectedProcess
        .expectedCumulative
```

This should be a thin alias of:

```text
SATStateDependentUnconditionalTendency.expectedCumulative_monotone_stepModel
```

## 6. Prefix-Dominance Discipline

The most important M1 correction is to avoid a false implication.

The following is safe:

```text
∀ t, E[Σ_{t+1} - Σ_t] ≥ 0
```

or:

```text
∀ t, E[step total production at t] ≥ 0
```

These imply monotonicity of expected cumulative total production.

The following is not enough unless stated for adjacent prefixes:

```text
∀ n, E[Σ_n] ≥ 0
```

This only says the cumulative quantity stays above zero; it does not imply
that the sequence is nondecreasing. M1 should require paper wording to use
stepwise or adjacent-prefix dominance.

## 7. Relation to Empirical Program

M1 is formal packaging, not another empirical claim.

The empirical situation after Exp.40/41/42 and Mixed-CSP is:

```text
LLM scope/attribution repair: prospective support for structure-aware
coordinates over quality-blind baselines.

Mixed-CSP feasibility: prospective support for drift-weighted L over raw-count
baselines in a Bernoulli-CSP Route A domain.
```

These support a Level 2 universality candidate. They do not prove target theorem
4. M1 should keep this separation:

```text
empirical universality support != formal law-of-tendency theorem
```

## 8. Relation to Paper 5 / M Operationalization

Paper 5's resource decomposition:

```text
M = (M_b, M_r, M_a, M_x)
```

is relevant to target theorem 4 because it gives operational content to the
"repair/resource contribution" side of total production.

However, M1 should not wait for Paper 5. The formal theorem can remain abstract:

```text
stepCost / repairSlack / totalProduction
```

Paper 5 can later instantiate those abstract quantities in software,
organizations, physiology, or infrastructure.

Recommended separation:

| Workstream | Question |
|---|---|
| Lean M1 | Which theorem names already prove expectation-level tendency? |
| Paper 5 | How do concrete domains operationalize resource / repair capacity? |
| Software pilot | Does an operational M/L proxy beat raw size or age baselines? |

## 9. Acceptance Criteria

M1 is complete when all of the following are true:

1. `UNIVERSALITY_GAP_MAP.md` has final M1 decisions for G1-G5.
2. `PAPER_MAPPING.md` contains a target theorem 4 mapping table.
3. The paper-side target wording avoids cumulative-prefix ambiguity.
4. A clear M2 decision is recorded:
   - mapping-only, or
   - thin wrapper theorem file.
5. No new axioms, no sorry, no empirical claim is introduced into Lean.

## 10. Recommended M1 Outcome

Current best guess:

```text
M1 will probably conclude that target theorem 4 is already formally accessible
at the expectation level through existing Lean theorems, but needs reader-facing
mapping and possibly thin wrapper names.
```

The high-probability stopped-collapse branch is also largely available, but it
should remain a separate theorem schema with explicit concentration and margin
assumptions.

The Bernoulli-CSP layer should be described as a finite-horizon bad-event
collapse / drift tendency interface, not as a repair-dominance theorem.

