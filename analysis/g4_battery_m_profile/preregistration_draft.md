# Battery M-Profile Preregistration Draft

Status: preregistration skeleton only. Not frozen. Not validation evidence.

Date: 2026-04-28

## 1. Branch Identity

Branch:

```text
G4 Battery M-Profile Predictive Validation
```

Role:

```text
non-CSP physical degradation branch; M-profile predictive validation; not
repair-flow evidence and not universal-law evidence.
```

Primary target:

```text
baseline + M/SP features improves out-of-sample battery degradation prediction
over a strong battery-domain baseline.
```

## 2. Dataset Candidate Before Freeze

Dataset:

```text
Oxford Path Dependent Battery Degradation Dataset, Part 1
```

Current role:

```text
freeze-manifest draft candidate after no-metric T1-T5 count pass plus T6
public-metadata availability gate
```

Fallback candidate order:

1. NASA Randomized and Recommissioned Battery Dataset;
2. MIT-Stanford/TRI fast-charging cycle-life dataset.

The final freeze package must still be written before feature inspection beyond
schema, metadata, and allowed feasibility summaries.

## 3. Unit, Time, And Split

Unit:

```text
filename cell ID
```

Time index:

```text
diagnostic / reference-test index
```

Split rule:

```text
fixed held-out cell ID split; never split the same cell ID across train/test
```

Reason:

```text
Part 1 has repeated filename cell IDs across groups, so conservative
protocol-group holdout is not safe unless physical-cell identity is resolved.
```

Allowed phases:

| Phase | Allowed data use |
|---|---|
| metadata-only | file identity, row counts, cell counts, schema, protocol labels |
| train-smoke | training cell-ID payloads only; feature extraction and model fit sanity |
| validation-smoke | optional calibration split only; no primary-test metrics |
| primary | held-out test cells/packs only after freeze |

## 4. Outcome

Preferred primary outcome:

```text
future capacity after fixed horizon H
```

Alternative outcomes if required by dataset:

- future capacity drop over horizon \(H\);
- log cycle life;
- EOL-before-horizon.

The final outcome and horizon must be frozen before primary evaluation.

## 5. Feature Families

### Domain baseline features

The domain baseline should include:

- cycle index / elapsed time;
- protocol metadata available before the prediction time;
- cumulative throughput or usage exposure;
- temperature / C-rate / voltage-window exposure if present;
- standard early degradation features, if these are accepted battery-domain
  predictors for the chosen dataset.

### M/SP features

M/SP features must be defined before primary test evaluation.
The final endpoint column must be disjoint from every feature list. The future
label at \(k+1\) cannot be reused as a B1/B2/B3/primary input feature.

Candidate feature groups:

| Feature group | Meaning |
|---|---|
| `M_buffer_proxy` | remaining physical margin before EOL / unacceptable capacity |
| `M_recovery_proxy` | reversible relaxation or rebound-like response after rest / diagnostic cycle |
| `M_reconfiguration_proxy` | protocol-order / load-pattern / usage-structure indicators |
| `SP_balance_proxy` | interaction of stress exposure with M-side margin or relaxation |

The final feature extraction functions must be recorded in the freeze package.

## 6. Models

Use a small frozen model ladder.

Regression ladder:

| Model | Features |
|---|---|
| `B0` | train mean |
| `B1` | time/cycle only |
| `B2` | time/cycle + protocol metadata |
| `B3` | strong battery-domain baseline |
| `primary` | `B3 + frozen M/SP features` |

Recommended model family:

```text
regularized linear / ridge / elastic-net model
```

The first branch should avoid black-box gains that are hard to interpret.

## 7. Primary Metric

For continuous capacity / capacity-drop endpoint:

```text
MAE or RMSE on held-out cells/packs
```

For cycle-life endpoint:

```text
MAE/RMSE on log cycle life
```

For binary EOL-before-horizon endpoint:

```text
log loss
```

Metric must be frozen before primary run.

## 8. Success Rules

Primary support:

```text
metric(primary) <= 0.95 * metric(B3)
```

Weak support:

```text
metric(primary) < metric(B3)
but improvement is less than 5%
```

No-support:

```text
metric(primary) >= metric(B3)
```

Silence:

```text
dataset does not allow non-leaky M/SP features, cell-level held-out split, or
pre-outcome endpoint construction
```

## 9. Guardrails

The branch must not:

1. inspect held-out test outcomes before freeze;
2. split cycles from the same cell into both train and test;
3. define recovery-like features using future capacity changes;
4. rename standard battery predictors as M features without added structure;
5. rescue a failed primary on the same archive;
6. claim causal intervention ranking from observational protocol metadata.

## 10. Interpretation

If support passes:

```text
The frozen battery M/SP mapping adds predictive value over the chosen
battery-domain baseline on this dataset.
```

If support fails:

```text
The frozen battery M/SP mapping did not add predictive value on this dataset.
```

If silence:

```text
The dataset is not suitable for this M-profile validation branch.
```

None of these outcomes should be treated as:

- universal M law;
- battery intervention theorem;
- proof of physical repair;
- refutation of the Lean-backed representation layer.

## 11. Next Work Items

1. Run the training-cell MATLAB / MCOS converter in a MATLAB environment via
   `scripts/run_oxford_part1_training_conversion_smoke.sh`.
2. Rerun Python train-smoke through the existing `--converted-train-root`
   manifest/header interface without held-out payload values or metrics.
3. Run the header-only schema draft to list candidate endpoint/feature columns
   without reading training values.
4. Human-finalize the `FEATURE_SCHEMA` from the header draft, converted
   training schema, and public guide information only.
5. Run the training-only endpoint/feature extraction and model-fit smoke
   without held-out values, metrics, or support flags.
6. Fill the freeze manifest with final endpoint, metric, split, feature-family
   definitions, converter/script hash, and one-time primary command.
