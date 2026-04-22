# DeltaLint / Paper 3 Static-Code Extension Note

Status: review note, not a main preprint.

Date: 2026-04-22

Purpose: keep DeltaLint out of Paper 5's load-bearing M-framework while
preserving its strong software evidence as a separate L-side / Paper 3
extension candidate.

Source memo: `/Users/sunagawa/Project/delta-PJT/oss/strategy/feasibility.md`

---

## 1. Position

DeltaLint should not be treated as a direct implementation of Paper 5's
maintenance-mode framework.

The clean position is:

```text
Paper 5:
  M-side operationalization and intervention-ranking protocol.

DeltaLint:
  L-side static-code extension candidate inspired by Paper 3.
```

DeltaLint mainly observes unresolved premise mismatch, guard gaps, ordering
dependencies, configuration interference, and related structural contradictions
inside static code. These are closer to local `L_hat` or `Delta L` risk than to
`M_b / M_r / M_a` mode composition.

DeltaLint becomes relevant to `M_r` only when its findings are coupled to a
repair workflow: triage, patching, CI gating, rollback, migration, or
maintainer review. The detector alone is not a maintenance mode.

## 2. Why Not Paper 1 Direct Application

DeltaLint is not, by itself, a direct Route A / Paper 1 application.

Paper 1's minimal form concerns a time-indexed contraction process:

```text
V^(0) ⊇ V^(1) ⊇ ... ⊇ V^(n)
```

with a naturally specified cumulative loss. DeltaLint usually scans one static
code snapshot and reports structural anomalies already present in that
snapshot. In that setting:

- `V^(0)` is not naturally fixed;
- the measure `m` over code-maintaining states is not domain-intrinsic;
- the constraint sequence `C_i` is not preregistered;
- the time horizon is not part of the scan.

Therefore DeltaLint should be described as inspired by structural-persistence
ideas, not as a finished instantiation of the minimal theorem.

## 3. What Current Evidence Shows

The existing feasibility survey should be described as strong feasibility
evidence, not as baseline-controlled proof.

Conservative statement:

```text
In a 63-repository feasibility survey, DeltaLint-style inspection identified
PR/Issue-worthy confirmed bug candidates in 62 repositories. Across 101
manually rechecked candidates, 92 were judged confirmed and 9 were judged false
positive. Some findings were accepted by OSS maintainers and merged.
```

Interpretation:

```text
This shows that the pattern class is not toy-only and appears in real OSS
codebases. It does not yet prove incremental predictive power over existing
static-analysis tools.
```

Do not write, unless independently verified:

```text
Existing tools already missed all of these bugs.
DeltaLint has proven superiority over ESLint / TypeScript / CodeQL / SonarQube.
DeltaLint validates Paper 5.
```

Those require reproducing the baseline tool stack at a fixed cutoff.

## 4. Central Additive Prediction

The natural empirical claim is additive, not replacement-based:

```text
existing tools + DeltaLint > existing tools alone
```

More precisely:

```text
At the same alert budget, an existing static-analysis stack plus DeltaLint
should identify more held-out future bug-fix locations than the existing
static-analysis stack alone.
```

This is the same methodological shape as the rest of the program:

| Domain | Structure-aware comparison |
|---|---|
| Paper 3 | scoped / attributed conflict handling > quality-blind contradiction handling |
| Mixed-CSP | `L_plus_n` > raw count / raw density baseline |
| DeltaLint candidate | existing tools + DeltaLint > existing tools alone |

## 5. Phase 2 Preregistration Skeleton

Before using DeltaLint as load-bearing evidence, freeze a baseline-controlled
protocol.

### Inputs

- Repository set `R`: fixed before analysis.
- Cutoff time `T`: fixed before analysis.
- Baseline stack `B`: fixed tool names, versions, and configs, e.g.
  TypeScript, ESLint, CodeQL, SonarQube, or project-native CI tools.
- DeltaLint version/config: fixed before analysis.

### Warning Sets

```text
Control:   warnings from B at time T
Treatment: warnings from B ∪ DeltaLint at time T
```

Alert budget must be controlled. Use one of:

- same top-k alerts per repository;
- same severity threshold;
- same expected reviewer budget;
- same false-positive budget after calibration.

### Ground Truth

Use future outcomes after `T`, such as:

- bug-fix commits merged in `T ... T + 6 months`;
- security fixes;
- regression-fix commits;
- maintainer-confirmed fixes.

### Primary Metrics

- top-k precision on future bug-fix locations;
- recall at fixed alert budget;
- AUPRC;
- Brier / log loss if scores are calibrated.

### Primary Decision

Predeclare a threshold, for example:

```text
Treatment supports the prediction if it improves top-k precision or AUPRC by
at least K% over the baseline stack, with K fixed before outcome inspection.
```

### Guardrails

Report whether gains remain after controlling for:

- LOC;
- churn;
- cyclomatic complexity;
- file age;
- prior incidents;
- existing linter/static-analysis warning count;
- code-smell counts.

## 6. Relation To Paper 5

Paper 5 may cite this note only as related work / future validation.

Safe wording:

```text
DeltaLint is a candidate L-side software extension inspired by the same
structural-persistence program. It is not used as evidence for Paper 5's
M-mode intervention-ranking claim. Its load-bearing test is a separate
additive-prediction protocol against existing static-analysis baselines.
```

This keeps Paper 5 thin and strong while preserving DeltaLint as a promising
software empirical track.

