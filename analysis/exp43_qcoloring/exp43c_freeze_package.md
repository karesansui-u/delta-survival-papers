# Exp43c q-coloring freeze package

Status: frozen design package for Exp43c primary validation. Primary data may
be generated only after this package is committed and pushed.

Date: 2026-04-23

## 1. Frozen Preregistration

Fresh Exp43c preregistration draft:

```text
analysis/exp43_qcoloring/exp43c_threshold_local_preregistration_draft.md
```

Frozen preregistration base commit:

```text
5ee1ea41b50676732a0eb5733ed756ceb0a2ff8e
```

This is the commit that introduced Exp43c as a fresh preregistration after
Exp43b was closed as calibration no-go.

## 2. Calibration Closeout

Calibration closeout:

```text
analysis/exp43_qcoloring/exp43c_calibration_closeout.md
sha256: 37970ed90e754ddec24b9d2d5a19bafceb48392cc263f5dc73b17aea2cc4e8fa
```

Calibration outputs (gitignored raw artifacts):

```text
analysis/exp43_qcoloring/data/exp43c_calibration_results.jsonl
sha256: f4740795b7e94d40b6f540410591a209a8a1473943ed29ab1ddba13c753a428f

analysis/exp43_qcoloring/data/exp43c_calibration_summary.json
sha256: adb623f0f453eee839b562fd65347851123e22a0d7925cbd2a7730d0ae01599a
```

Calibration status:

```text
passed
```

Calibration data are exploration data only and are excluded from primary
support claims.

## 3. Primary Grid

Primary config:

```text
analysis/exp43_qcoloring/config/exp43c_primary_config.json
sha256: 5905d43012ac5ba7ed0a8c0f42dbae051c91ef76564fc98302d4a77b045fa2bb
```

Selected primary grid:

| q | n | rho_fm bands |
|---:|---:|---|
| 3 | 80 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86, 0.88 |
| 4 | 80 | 0.78, 0.80, 0.82, 0.84, 0.86, 0.88, 0.90 |
| 5 | 60 | 0.76, 0.78, 0.80, 0.82, 0.84, 0.86 |

Primary size:

```text
20 cells * 200 instances per cell = 4000 instances
```

## 4. Primary Seed Namespace

Primary phase namespace:

```text
exp43c_primary
```

The q-coloring generator hashes the phase string into the seed digest, so the
primary stream is disjoint from Exp43, Exp43b, and Exp43c calibration streams.

## 5. Manifest Generation

Primary manifest generation script:

```text
analysis/exp43_qcoloring/src/primary_manifest.py
sha256: c32437e5e165de3340d733107fd0df62513bc77f1b74e7670ed73bbdfbccb29a
```

Generated primary manifest (gitignored artifact):

```text
analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl
sha256: e0c0058fc0279de6dddace700d1929820e98c152382039051244faedcd0d0cf2
```

Manifest command:

```bash
python3 analysis/exp43_qcoloring/src/primary_manifest.py \
  --config analysis/exp43_qcoloring/config/exp43c_primary_config.json \
  --output analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl
```

## 6. Solver And Runtime Policy

Solver backend:

```text
PySAT 1.9.dev2
Minisat22
```

Timeout:

```text
120 seconds per instance
```

Runtime handling:

1. timeout instances are excluded from primary log-loss analysis;
2. timeout rate is reported by q/n/rho cell;
3. if any frozen primary cell exceeds 5% timeout, the affected q/n unit is
   marked runtime-unstable in the final report;
4. if runtime instability removes every q/n unit for any q, Exp43c is
   inconclusive and no cross-q primary support may be claimed.

Malformed encodings:

```text
any MALFORMED_ENCODING result invalidates the affected cell and requires a
bugfix before interpretation.
```

## 7. Feature Schema And Predictor List

Feature schema is defined by:

```text
analysis/exp43_qcoloring/src/feature_extractor.py
```

Primary predictors:

| name | features |
|---|---|
| `raw_plus_n_q` | `(m, n, q)` |
| `density_plus_n_q` | `(edge_density, n, q)` |
| `avg_degree_plus_n_q` | `(avg_degree, n, q)` |
| `cnf_count_plus_n_q` | `(cnf_clause_count, n, q)` |
| `fm_plus_n` | `(first_moment_log_count, n)` |

Diagnostics:

| name | features |
|---|---|
| `raw_edge` | `(m)` |
| `raw_density` | `(edge_density)` |
| `avg_degree` | `(avg_degree)` |
| `L_plus_n` | `(L, n)` |
| `L_plus_n_plus_q` | `(L, n, q)` |
| `first_moment` | `(first_moment_log_count)` |

## 8. Evaluation Script

Frozen evaluation script:

```text
analysis/exp43_qcoloring/src/evaluate_primary.py
sha256: ac026a93fd9a009d00b81af579959da1aaaf263881c95617c98fcfe1de670b5c
```

Model:

```text
sklearn LogisticRegression
penalty = l2
solver = lbfgs
C = 1.0
max_iter = 1000
feature standardization fit on train fold only
```

Runtime environment observed at freeze:

```text
numpy 2.4.2
sklearn 1.8.0
```

Primary split:

```text
leave-one-q-out
```

Primary metric:

```text
mean held-out log loss across q folds
```

Secondary metrics:

```text
Brier score
AUROC when both classes are present
accuracy@0.5
pooled log loss
```

Evaluation command after primary run:

```bash
python3 analysis/exp43_qcoloring/src/evaluate_primary.py \
  analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl \
  --output analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json
```

## 9. Decision Rules

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

## 10. Non-claims

Exp43c does not claim:

1. Exp43, Exp43b, or Exp43c calibration data are validation evidence.
2. the absolute q-coloring threshold was predicted by theory.
3. solver runtime is the primary endpoint.
4. q-coloring alone establishes universal law.
5. failure to pass H1 falsifies the entire structural persistence theory.
6. `fm_plus_n` superiority, if observed, explains all graph-coloring threshold
   phenomena.
7. excluding runtime-unstable q/n units proves anything about q-coloring solver
   dynamics.

## 11. Freeze Decision

Decision:

```text
FROZEN FOR PRIMARY DATA GENERATION
```

Primary data generation is allowed only after this freeze package is committed
and pushed.
