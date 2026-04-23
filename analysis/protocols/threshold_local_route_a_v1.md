# Threshold-local Route A protocol v1

Status: protocol draft / infrastructure artifact. Not an experiment, not
validation evidence, and not a frozen preregistration for any specific run.

Date: 2026-04-23

## 1. Purpose

This note records the shared protocol for future Route A CSP feasibility
experiments after Exp43 q-coloring and Exp44 Cardinality-SAT showed the same
calibration pattern:

```text
broad rho grid -> SAT-saturated cells, one transition band, UNSAT-saturated cells
```

The lesson is not that Route A fails. The lesson is that random CSP feasibility
experiments have sharp finite-size transition regions, so a broad grid is a
poor validation design. Future Route A validation should use a
threshold-local design.

This protocol is a reusable design artifact for Exp43b, Exp44b, or later Route
A anchors. It is deliberately placed under `analysis/protocols/` rather than
inside an `exp*` directory because it is infrastructure, not a new empirical
claim.

## 2. Phase separation

Every threshold-local Route A experiment must separate three phases:

| Phase | Role | Evidence status |
|---|---|---|
| Calibration | Locate non-saturated transition windows, test runtime and verifier path | Exploration only |
| Freeze | Commit grid, seed streams, feature schema, predictors, and analysis scripts | Commitment point |
| Validation | Generate primary data with disjoint seeds and run the frozen analysis once | Evidence-bearing |

Calibration may iterate. Validation may not.

Calibration outputs must not be counted as theory-confirming evidence. They
may only justify the frozen primary grid and runtime feasibility.

## 3. Claim deflation

The validation claim is not:

```text
The theory predicted the absolute threshold location.
```

The validation claim is:

```text
Within a pre-frozen threshold-local window, the theory-specified
first-moment / drift coordinate ranks or predicts feasibility better than
raw-count, density, and encoding-size baselines.
```

Equivalently, the win condition is ordering / prediction near the transition,
not discovering the transition itself.

This distinction is mandatory. Without it, a threshold-local design can be
misread as window fitting.

## 4. Calibration requirements

A calibration run should identify, for each family unit, a transition window
where feasibility is neither saturated SAT nor saturated UNSAT.

The family unit depends on the experiment:

- q-coloring: usually `(q, n)` or a q-specific threshold-normalized band.
- Cardinality-SAT: usually `(mixture_id, n)` or a mixture-specific band.
- Later CSP anchors: the smallest unit over which transition location can
  shift materially.

Calibration should record:

1. SAT / UNSAT / TIMEOUT / MALFORMED counts by cell.
2. verifier pass counts for SAT assignments.
3. runtime summaries by cell.
4. informative bands, defined before calibration.
5. monotonicity of SAT rate with the primary threshold coordinate.
6. candidate primary windows and their buffers.
7. predictor rank-correlation diagnostics inside candidate windows.

Calibration stops when either:

- every family unit has a buffered threshold-local window suitable for the
  primary split; or
- the current anchor is declared calibration-inconclusive.

## 5. Window selection and buffer rule

The threshold-local window must not be frozen from a point estimate alone.

For each family unit:

1. Estimate the transition window from calibration cells whose SAT rate lies
   in `(5%, 95%)`, excluding timeouts.
2. If at least two informative grid points exist, choose the minimal interval
   covering them.
3. Add a buffer of at least one grid step on both sides when available.
4. If only one informative grid point exists, do not freeze from that point
   alone. Either run a newly preregistered calibration with finer local grid
   or declare the anchor inconclusive.

The buffer is required because the calibration window is estimated with finite
samples. Freezing exactly at the observed boundary risks reproducing the
Exp43/Exp44 failure mode: the primary run shifts slightly and leaves only one
informative band.

Alternative buffer policy:

```text
Use an 80% binomial confidence interval for the SAT rate and freeze only grid
points whose uncertainty interval intersects the non-saturated region.
```

If this alternative is used, it must be selected before primary data.

## 6. Power-collapse diagnostic

Threshold-local windows are narrower than broad exploratory grids. This
creates a power-collapse risk: inside a narrow window, the theory predictor
and raw / density / CNF-size baselines may become nearly collinear.

Before freeze, compute a rank-correlation matrix over the candidate primary
manifest using calibration-derived grid cells only:

```text
predictors:
  first_moment / fm_plus_n
  L_plus_n or L_plus_n_plus_family
  raw_count_plus_n
  density_plus_n
  cnf_count_plus_n
  cnf_density_plus_n
  family indicators or mixture indicators
```

Required reporting:

1. Spearman correlation matrix.
2. Kendall tau matrix if sample size is large enough.
3. A short statement of whether the theory predictor is distinguishable from
   raw / density / CNF baselines in the candidate window.

If the theory predictor has absolute Spearman correlation at least `0.98` with
every baseline in the candidate window, the design is underpowered for the
intended comparison and must not be frozen as a primary validation design.

For Cardinality-SAT, mixture heterogeneity should usually preserve power. This
must still be checked rather than assumed.

## 7. Runtime-instability rule

Solver runtime is not the Route A primary endpoint, but runtime instability can
invalidate a feasibility-validation design by making primary log-loss depend on
which instances timed out.

For future threshold-local Route A preregistrations:

1. A cell is runtime-suspended if its timeout rate exceeds the preregistered
   tolerance.
2. A family unit is primary-eligible only if its selected buffered primary
   window contains no runtime-suspended cell.
3. If dropping runtime-suspended units leaves any family value without at
   least one primary-eligible unit, the experiment is calibration no-go and no
   primary data may be generated for a strict subset of family values.
4. A fresh preregistration may reduce the relevant size grid, change timeout
   policy, or choose a different anchor, but calibration outcomes from the
   failed design remain exploration only.

This rule is general. It is not an amendment that rescues any particular
experiment after observing its calibration output.

## 8. Seed stream separator

Calibration and primary instances must use disjoint seed streams, not merely
different numeric seed values.

The seed digest must include a phase namespace:

```json
{
  "experiment": "Exp44b",
  "version": "threshold_local_v1",
  "phase": "calibration" | "primary",
  "family_unit": "...",
  "n": 100,
  "rho_fm": 0.925,
  "instance_idx": 17
}
```

The primary stream must never reuse calibration instance ids. The manifest
should make this mechanically checkable by including:

- `phase`
- `instance_id`
- seed digest
- semantic instance hash
- generator version
- solver / verifier version

## 9. Freeze package

Before primary validation, commit or otherwise timestamp:

1. frozen preregistration;
2. calibration closeout note;
3. final threshold-local grid;
4. window buffer rule;
5. disjoint seed-stream rule;
6. instance manifest generation script;
7. feature schema;
8. primary / secondary predictors;
9. coefficient-tuned diagnostic models;
10. rank-correlation / power-collapse diagnostic;
11. timeout and runtime-unstable rules;
12. exclusion rules;
13. analysis script;
14. non-claim list.

The calibration closeout note must contain:

1. per family-unit / cell SAT rate, timeout rate, and malformed count;
2. informative cells marked under the preregistered definition;
3. selected primary window per family unit;
4. buffer application record;
5. rank-correlation matrix and power-collapse verdict;
6. deviations from the preregistration, with rationale;
7. explicit pass / inconclusive decision and whether primary data may be
   generated.

No primary data should be generated before this freeze package exists.

## 10. Re-entry condition for Route A

Route A empirical calibration is paused after Exp43 / Exp44 until both of the
following exist:

1. this threshold-local protocol v1 is recorded and accepted as the shared
   design discipline; and
2. the next anchor has a fresh preregistration that treats all earlier pilots
   as calibration only.

For the current program, the recommended sequencing is:

```text
threshold-local protocol note
-> G6-c formal mapping scope / draft
-> choose whether Exp43b, Exp44b, or a non-CSP anchor is the next validation
```

This is not abandonment of Route A. It is a pause to prevent calibration chase
and to improve anchor selection.

## 11. Non-claims

This protocol does not claim:

1. that Exp43 or Exp44 validated the theory;
2. that the threshold window position is itself a theory prediction;
3. that pilot data are evidence for the primary claim;
4. that threshold-local tuning may continue after primary data are seen;
5. that CSP anchors alone establish a universal law;
6. that solver cost is the Route A primary endpoint;
7. that a future Exp43b or Exp44b must pass.

The only intended claim is methodological:

```text
Future Route A CSP validation should separate transition-window calibration
from evidence-bearing primary prediction, and should test relative coordinate
quality inside a frozen threshold-local window.
```

## 12. Relation to Exp43 and Exp44

Exp43 q-coloring showed:

```text
pilot_v2 infrastructure clean
q=3 informative bands: {0.60,0.70,0.80}
q=4 informative bands: {0.80}
q=5 informative bands: {0.80}
```

Exp44 Cardinality-SAT showed:

```text
pilot_v3 infrastructure clean
M0/M1/M2 informative bands: {0.90}
M3/M4/M5 informative bands: at least two bands
```

Both patterns point to the same protocol lesson: broad or semi-broad grids are
not enough when finite-size transitions are sharp. The next CSP validation
must be explicitly threshold-local or should be postponed.

Exp43b q-coloring showed:

```text
threshold-local calibration located informative windows for q=3, q=4, q=5
but q=5, n=80, rho_fm=0.86 exceeded the timeout tolerance
```

This adds a second protocol lesson: threshold-local windows must also be
runtime-stable before they can be frozen for primary validation.
