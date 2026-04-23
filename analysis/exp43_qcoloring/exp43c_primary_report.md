# Exp43c q-coloring primary report

Status: primary validation report.

Date: 2026-04-23

## 1. Frozen Inputs

Freeze package:

```text
analysis/exp43_qcoloring/exp43c_freeze_package.md
commit: 9d277f7
```

Primary config:

```text
analysis/exp43_qcoloring/config/exp43c_primary_config.json
```

Primary seed namespace:

```text
exp43c_primary
```

Frozen evaluation script:

```text
analysis/exp43_qcoloring/src/evaluate_primary.py
```

The evaluation model and regularization were fixed in the freeze package:

```text
sklearn LogisticRegression
penalty = l2
solver = lbfgs
C = 1.0
max_iter = 1000
feature standardization fit on train fold only
```

## 2. Primary Data

Primary output (gitignored raw artifact):

```text
analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl
sha256: 37e6381c876c20dbcdb5d7114a791453dabc6a778207097e83490ba7511a863b
```

Evaluation output (gitignored raw artifact):

```text
analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json
sha256: 901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
```

Run size:

```text
4000 records
20 cells
200 instances per cell
```

Solver status:

| status | count |
|---|---:|
| SAT | 2003 |
| UNSAT | 1997 |
| TIMEOUT | 0 |
| MALFORMED_ENCODING | 0 |

## 3. Cell-Level SAT Rates

| q | n | rho_fm | SAT rate |
|---:|---:|---:|---:|
| 3 | 80 | 0.76 | 0.830 |
| 3 | 80 | 0.78 | 0.790 |
| 3 | 80 | 0.80 | 0.620 |
| 3 | 80 | 0.82 | 0.325 |
| 3 | 80 | 0.84 | 0.285 |
| 3 | 80 | 0.86 | 0.180 |
| 3 | 80 | 0.88 | 0.080 |
| 4 | 80 | 0.78 | 1.000 |
| 4 | 80 | 0.80 | 0.965 |
| 4 | 80 | 0.82 | 0.885 |
| 4 | 80 | 0.84 | 0.565 |
| 4 | 80 | 0.86 | 0.275 |
| 4 | 80 | 0.88 | 0.115 |
| 4 | 80 | 0.90 | 0.000 |
| 5 | 60 | 0.76 | 0.995 |
| 5 | 60 | 0.78 | 0.865 |
| 5 | 60 | 0.80 | 0.700 |
| 5 | 60 | 0.82 | 0.375 |
| 5 | 60 | 0.84 | 0.125 |
| 5 | 60 | 0.86 | 0.040 |

## 4. Primary Log-Loss Results

Metric:

```text
mean held-out log loss across leave-one-q-out folds
```

| predictor | mean held-out log loss | mean Brier | pooled log loss |
|---|---:|---:|---:|
| `fm_plus_n` | 0.440189 | 0.138401 | 0.440866 |
| `first_moment` | 0.446814 | 0.139603 | 0.447822 |
| `raw_density` | 0.780910 | 0.287369 | 0.785275 |
| `avg_degree` | 0.780910 | 0.287369 | 0.785275 |
| `raw_edge` | 2.779498 | 0.352580 | 2.883836 |
| `density_plus_n_q` | 2.804019 | 0.410119 | 2.922313 |
| `avg_degree_plus_n_q` | 2.804019 | 0.410119 | 2.922313 |
| `L_plus_n` | 4.272283 | 0.444812 | 4.452707 |
| `L_plus_n_plus_q` | 7.535080 | 0.527376 | 7.508770 |
| `cnf_count_plus_n_q` | 7.700105 | 0.527489 | 7.838608 |
| `raw_plus_n_q` | 8.567224 | 0.527530 | 8.634729 |

Best raw baseline among the preregistered primary raw baselines:

```text
min(raw_plus_n_q, density_plus_n_q, avg_degree_plus_n_q)
= 2.804019
```

Primary improvement:

```text
(2.804019 - 0.440189) / 2.804019 = 84.3%
```

Encoding-size guardrail:

```text
fm_plus_n = 0.440189
cnf_count_plus_n_q = 7.700105
```

Technical observation:

The best predictors are the theory-specified scalar coordinates:

```text
fm_plus_n     = 0.440189
first_moment  = 0.446814
raw_density   = 0.780910
avg_degree    = 0.780910
```

By contrast, several tuple predictors that include `q` as an explicit learned
feature fail badly under leave-one-q-out evaluation:

```text
density_plus_n_q    = 2.804019
L_plus_n_plus_q     = 7.535080
cnf_count_plus_n_q  = 7.700105
raw_plus_n_q        = 8.567224
```

This matters because the held-out split tests extrapolation across q. A
coordinate such as `fm_plus_n = (n log q - L, n)` folds the q-dependence into
the first-moment geometry before learning. A raw tuple model that learns a
free coefficient for q can overfit the training q values and extrapolate poorly
to the held-out q. The result therefore supports the theory-specified
coordinate choice, not merely adding q as another regression feature.

## 5. Fold-Level H1 Check

H1 requires the `fm_plus_n` direction to hold for each held-out q.

| held-out q | `fm_plus_n` log loss | best primary raw baseline | H1 direction |
|---:|---:|---:|---|
| 3 | 0.570528 | 5.071990 | pass |
| 4 | 0.323388 | 2.901932 | pass |
| 5 | 0.426651 | 0.438133 | pass |

The q=5 margin is small:

```text
0.438133 - 0.426651 = 0.011482
relative improvement = 2.62%
```

This should be reported as a real but narrow fold-level win, not as a large
q=5 effect.

The narrow q=5 margin is consistent with the training-set log-q geometry:
when q=5 is held out, training uses q=3 and q=4, and `log 4` is closer to
`log 5` than the corresponding extrapolation distance for held-out q=3. Thus
coordinate-agnostic baselines can extrapolate more reasonably to q=5 than to
q=3. This is not a failure of H1, but it should keep the q=5 interpretation
modest.

## 6. Decision Rules

H1 primary support:

```text
pass
```

Reason:

```text
fm_plus_n beats the best preregistered primary raw baseline overall and in
each held-out-q fold.
```

Strong support, aggregate:

```text
pass
```

Checks:

```text
fm_plus_n = 0.440189 <= 0.90 * 2.804019 = 2.523617
first_moment = 0.446814 < 2.804019
fm_plus_n = 0.440189 <= cnf_count_plus_n_q = 7.700105
```

Cross-q generality:

```text
pass for H1 direction
```

Encoding guardrail:

```text
pass
```

Runtime guardrail:

```text
pass: TIMEOUT = 0
```

## 7. Interpretation

Exp43c provides primary Route A support for q-coloring as a visibly non-SAT
CSP family.

This is evidence for the narrower claim:

```text
Inside a frozen threshold-local q-coloring window, the first-moment / drift
coordinate predicts feasibility better than raw edge-count, density, and CNF
encoding-size baselines.
```

It is not evidence that:

1. the absolute q-coloring threshold was predicted;
2. q-coloring alone establishes universal law;
3. solver dynamics are explained;
4. structural persistence theory is fully universal.

The correct status update is:

```text
Route A width beyond SAT syntax: strengthened by one primary q-coloring
validation.
```
