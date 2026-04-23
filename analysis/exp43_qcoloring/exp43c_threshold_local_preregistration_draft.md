# Exp43c q-coloring Threshold-Local Preregistration Draft

Status: fresh preregistration draft, not frozen. No primary data may be
generated from this document until the freeze checklist in §15 is completed.

Date: 2026-04-23

Target domain: random q-colorability on Erdős-Rényi graphs.

Related protocol:
`analysis/protocols/threshold_local_route_a_v1.md`.

Related exploration history:

- `analysis/exp43_qcoloring/phase_status.md`
- `analysis/exp43_qcoloring/exp43b_calibration_closeout.md`

## 1. Purpose

Exp43c is a fresh threshold-local q-coloring preregistration. It replaces the
Exp43b design rather than amending it after calibration outcomes.

Exp43c tests whether the Route A first-moment / drift coordinate predicts
q-colorability better than raw edge count, density, and CNF encoding-size
baselines inside a frozen threshold-local window.

This is a G3 / G5 experiment:

- G3: Route A width beyond SAT syntax.
- G5: prospective prediction under a frozen preregistration.

It is not a universal-law declaration.

## 2. Why Exp43c Is Fresh

Exp43b remained exploration. It located informative threshold-local windows
but failed its strict all-cell timeout gate because:

```text
q=5, n=80, rho_fm=0.86
TIMEOUT = 5/50 = 10% > 5%
```

Exp43c does not reinterpret Exp43b as validation evidence and does not
generate primary data from Exp43b's draft. Instead, Exp43c applies the shared
runtime-instability rule from `threshold_local_route_a_v1.md` as a fresh
design discipline.

The main design change is:

```text
q=5: replace n={40,80} with n={40,60}
```

The motivation is runtime stability, not threshold fitting.

## 3. Claim Deflation

The experiment does not claim that structural persistence theory predicts the
absolute q-coloring threshold.

The primary claim is:

\begin{quote}
Inside a threshold-local window selected by precommitted calibration rules and
frozen before primary data, the first-moment / drift coordinate predicts
held-out q-colorability better than raw edge-count, density, and CNF-size
baselines.
\end{quote}

The threshold window location is calibration output, not theory evidence.

## 4. Hypotheses

Let
\[
  \ell_q=\log\frac{q}{q-1},
  \qquad
  L=m\ell_q,
  \qquad
  F=n\log q-L.
\]

Here \(F\) is the first-moment log-count coordinate.

### H1 Primary

The primary predictor

```text
fm_plus_n = (F, n)
```

has lower held-out log loss than the best raw baseline:

```text
min(raw_plus_n_q, density_plus_n_q, avg_degree_plus_n_q)
```

on the frozen primary validation set.

### H2 Strong Support

Strong support requires:

```text
logloss(fm_plus_n)
  <= 0.90 * min(logloss(raw_plus_n_q),
                logloss(density_plus_n_q),
                logloss(avg_degree_plus_n_q))
```

and

```text
logloss(first_moment) < min(raw baseline log losses)
```

and

```text
logloss(fm_plus_n) <= logloss(cnf_count_plus_n_q)
```

### H3 Encoding Guardrail

If CNF-size predictors beat `fm_plus_n`, the result is not counted as Route A
support. It is reported as possible encoding-size confounding.

### H4 Cross-q Generality

H1 is evaluated per held-out q. Full cross-q support requires the direction to
hold for each \(q\in\{3,4,5\}\).

## 5. Phase Structure

Exp43c has three phases.

| phase | data status | allowed use |
|---|---|---|
| calibration | exploration | select windows, test runtime, compute collinearity diagnostics |
| freeze | no new data | commit final primary manifest and analysis script |
| primary | validation | evaluate H1-H4 once |

Calibration data are excluded from all primary support claims.

## 6. Calibration Design

The calibration phase uses q/n-specific fine grids derived from Exp43,
Exp43b, and the shared threshold-local protocol. Earlier Exp43 / Exp43b data
are exploration history only; Exp43c uses a disjoint seed namespace.

Calibration grids:

| q | n | calibration rho_fm grid |
|---:|---:|---|
| 3 | 40 | {0.55,0.60,0.65,0.70,0.75,0.80,0.85} |
| 3 | 80 | {0.76,0.78,0.80,0.82,0.84,0.86,0.88} |
| 4 | 40 | {0.74,0.76,0.78,0.80,0.82,0.84,0.86} |
| 4 | 80 | {0.78,0.80,0.82,0.84,0.86,0.88,0.90} |
| 5 | 40 | {0.70,0.725,0.75,0.775,0.80,0.825,0.85} |
| 5 | 60 | {0.76,0.78,0.80,0.82,0.84,0.86,0.88} |

Calibration instances per cell:

```text
N_calibration = 50
```

Timeout:

```text
120 seconds per instance
```

Calibration pass requires:

1. no malformed encodings;
2. timeout rate <= 5% in every cell;
3. each q has at least two non-saturated rho bands after pooling across n;
4. each q has at least one n-specific primary-eligible window;
5. SAT rate is broadly non-increasing in rho_fm within each q/n unit, allowing
   one adjacent inversion due to sampling noise.

## 7. Runtime-instability Rule

Exp43c adopts the shared runtime-instability rule.

Definitions:

1. A cell is runtime-suspended if its timeout rate exceeds 5%.
2. A q/n unit is primary-eligible only if its selected buffered primary window
   contains no runtime-suspended cell.
3. If any q in `{3,4,5}` lacks at least one primary-eligible q/n unit, Exp43c
   is calibration no-go and no primary data may be generated for a strict
   subset of q values.

This rule is applied before primary data generation.

## 8. Window Selection Rule

For each q/n unit:

1. Define informative cells as solved cells with SAT rate in `(5%,95%)`.
2. If at least two informative cells exist, select the minimal rho interval
   covering them.
3. Add one grid-step buffer on both sides when available.
4. If only one informative cell exists, that q/n unit is not primary-eligible.
5. If the buffered window contains a runtime-suspended cell, that q/n unit is
   not primary-eligible.

The primary validation grid is the union of selected q/n windows for one or
more primary-eligible q/n units per q.

If a q has multiple primary-eligible n units, the freeze closeout must choose
one of the following before primary data:

1. include all eligible n units for that q; or
2. choose the eligible n unit with lower maximum timeout rate, breaking ties
   by larger n.

The chosen rule must be recorded in the calibration closeout.

If the minimal covering interval includes calibration-non-informative cells
between informative cells, those intermediate cells are retained in the
primary grid. They contribute to held-out log-loss as high-confidence
predictions, but they do not count toward the "two informative cells"
eligibility criterion.

This rule is deterministic and must be applied before primary data generation.

## 9. Power-Collapse Diagnostic

Before freeze, compute rank-correlation diagnostics on the candidate primary
manifest using calibration-grid features only.

Predictors:

- `first_moment`
- `fm_plus_n`
- `L_plus_n`
- `raw_plus_n_q`
- `density_plus_n_q`
- `avg_degree_plus_n_q`
- `cnf_count_plus_n_q`

Required diagnostics:

1. Spearman correlation matrix.
2. Kendall tau matrix when enough distinct grid points exist.
3. A statement on whether `fm_plus_n` is distinguishable from raw / density /
   CNF-size baselines.

If `abs(Spearman(fm_plus_n, baseline)) >= 0.98` for every raw / density /
CNF-size baseline inside the candidate window, the design is declared
underpowered and must not be frozen as primary validation.

## 10. Seed Stream Separation

Calibration and primary use disjoint seed streams.

The existing generator includes `phase` in the seed digest. For Exp43c, the
phase strings must be:

```text
exp43c_calibration
exp43c_primary
```

The primary stream must not reuse any calibration instance id or seed digest.
Exp43c streams are also disjoint from Exp43, Exp43b, and all earlier q-coloring
pilot streams because the phase namespace differs.

## 11. Primary Validation Design

After calibration closeout and freeze, primary validation uses:

```text
N_primary = 200 per frozen q/n/rho cell
```

Primary outcome:

```text
q_colorable = 1
q_uncolorable = 0
```

Solver:

- PySAT backend, exact CNF solving.
- Independent verifier checks every SAT coloring against original graph edges.
- Timeout remains 120 seconds unless calibration closeout freezes a different
  timeout policy before primary data.

Timeout handling:

- timeout instances are excluded from primary log-loss analysis;
- timeout rate is reported by q/n/rho cell;
- if any frozen primary cell exceeds 5% timeout, the affected q/n unit is
  marked runtime-unstable in the final report;
- if runtime instability removes every q/n unit for any q, Exp43c is
  inconclusive and no cross-q primary support may be claimed.

## 12. Predictor Set

The predictor set is frozen before primary data.

| name | features | role |
|---|---|---|
| `raw_edge` | \(m\) | diagnostic |
| `raw_density` | \(m/n\) | diagnostic |
| `avg_degree` | \(2m/n\) | diagnostic |
| `raw_plus_n_q` | \((m,n,q)\) | primary raw baseline |
| `density_plus_n_q` | \((m/n,n,q)\) | primary density baseline |
| `avg_degree_plus_n_q` | \((2m/n,n,q)\) | primary degree baseline |
| `cnf_count_plus_n_q` | \((n(1+\binom q2)+mq,n,q)\) | encoding guardrail |
| `L_plus_n` | \((L,n)\) | drift diagnostic |
| `L_plus_n_plus_q` | \((L,n,q)\) | coefficient-tuned diagnostic |
| `fm_plus_n` | \((n\log q-L,n)\) | primary structure-aware predictor |
| `first_moment` | \(n\log q-L\) | theory-pure diagnostic |

Model:

- logistic regression;
- L2 regularization;
- regularization value fixed in freeze manifest;
- feature standardization fit on train fold only.

## 13. Evaluation

Primary split:

```text
leave-one-q-out
```

For each held-out q, train on the other q values and test on the held-out q.
The primary metric is mean held-out log loss across q folds.

Secondary split:

```text
within-q leave-one-rho-band-out
```

Secondary metrics:

- Brier score;
- AUROC;
- accuracy@0.5;
- calibration curves.

## 14. Decision Rules

Primary support:

```text
logloss(fm_plus_n)
  < min(logloss(raw_plus_n_q),
        logloss(density_plus_n_q),
        logloss(avg_degree_plus_n_q))
```

Strong support:

```text
primary support
and logloss(fm_plus_n) <= 0.90 * best_raw_logloss
and logloss(first_moment) < best_raw_logloss
and logloss(fm_plus_n) <= logloss(cnf_count_plus_n_q)
```

Weakening outcomes:

| outcome | interpretation |
|---|---|
| `fm_plus_n` beats raw but not CNF-size | possible encoding confound |
| `L_plus_n_plus_q` beats raw but `fm_plus_n` does not | coefficient tuning, not primary support |
| one q passes but others fail | q-specific support, not cross-q support |
| power-collapse diagnostic fails | design underpowered, no primary claim |
| runtime instability appears in primary | runtime limitation, not Route A support |

## 15. Freeze Checklist

Before primary data generation, the following must be committed or otherwise
timestamped:

1. calibration run config;
2. calibration JSONL or archived hash;
3. calibration closeout note;
4. selected primary q/n/rho grid;
5. runtime-instability decision record;
6. one-grid-step buffer application record;
7. rank-correlation / power-collapse diagnostic;
8. solver version and backend;
9. timeout policy;
10. primary instance manifest generation script;
11. primary seed namespace `exp43c_primary`;
12. feature schema;
13. predictor list;
14. evaluation script;
15. non-claim list;
16. exact commit SHA for the frozen preregistration.

If any item is missing, Exp43c is not frozen and primary data must not be
generated.

## 16. Non-claims

Exp43c does not claim:

1. Exp43, Exp43b, or Exp43c calibration data are validation evidence.
2. the absolute q-coloring threshold was predicted by theory.
3. solver runtime is the primary endpoint.
4. q-coloring alone establishes universal law.
5. failure to pass H1 falsifies the entire structural persistence theory.
6. `fm_plus_n` superiority, if observed, explains all graph-coloring threshold
   phenomena.
7. excluding runtime-unstable q/n units proves anything about q-coloring
   solver dynamics.

## 17. Current Status

This document is a draft. It is not frozen.

Before calibration, the following implementation artifacts are still required:

1. `exp43c_calibration_config.json`;
2. dry-run manifest count;
3. smoke or calibration command record;
4. post-calibration closeout note under the shared protocol format.

Until then, Exp43c remains planned exploration.
