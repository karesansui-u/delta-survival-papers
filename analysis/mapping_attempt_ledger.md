# Mapping Attempt Ledger

Status: live ledger for candidate signals, frozen tests, no-support outcomes,
weak-axis failures, and silence decisions. This is not a support document by
itself.

Date opened: 2026-04-28

## 1. Purpose

This ledger prevents failed or weak mapping attempts from disappearing into
scattered notes. A failed attempt should constrain future designs. It should
not be silently renamed, rescued on the same archive, or counted as support.

The future-facing promotion and replacement protocol is recorded in
`analysis/proxy_ecosystem_protocol.md`. This ledger records the actual
attempts; the ecosystem protocol records how attempts may be promoted,
superseded, or retired over time.

The central vocabulary is:

```text
signal -> candidate -> frozen test -> support / no-support / silence
```

Use `support` narrowly:

```text
support = a frozen mapping beats its preregistered baseline on the
specified holdout / future / fresh-archive / outside-rerun surface.
```

Exploratory gains are not support. They are candidate signals or validation
candidates.

## 2. Status Vocabulary

| Status | Meaning | Counts as support? |
|---|---|---|
| `candidate_signal` | A useful exploratory correlation, direction, metric gain, monotonicity, or visualization. | No |
| `validation_candidate` | A candidate signal promoted to a future frozen test. | No |
| `frozen_test` | Mapping, features, split, metric, baseline, and failure rules are fixed before outcome inspection. | Not yet |
| `weak_support` | Frozen SP-only predictor beats a simple baseline out-of-sample. | Limited |
| `incremental_support` | Frozen `domain baseline + SP` beats the domain baseline out-of-sample. | Yes |
| `replication_support` | A frozen support result is reproduced by outside rerun or independent execution. | Yes, scoped |
| `no_support` | Frozen mapping fails its preregistered primary rule. | No |
| `failed_candidate` | Exploration-stage candidate is not promoted. | No |
| `weak_axis_mapping_failure` | Claimed SP additions substantially duplicate the baseline or come from the same state proxy under a new name. | No |
| `silence` | No natural mapping, measurement, or non-leaky validation surface is available. | No claim |

## 3. Current Ledger

| Attempt | Domain / data | Status | Main outcome | Failure or support mode | Reusable lesson | Next treatment |
|---|---|---|---|---|---|---|
| Mixed-CSP primary | Route A SAT / NAE-SAT mixture | `incremental_support` + `replication_support` | `L_plus_n` log loss `0.0970` beats raw baseline; `3/3` returned outside reruns clean | Frozen Route A support | Drift-weighted coordinate can beat quality-blind counts when mixture identity breaks raw-count sufficiency | Keep as scoped Route A support |
| Exp43c q-coloring | Route A q-coloring | `incremental_support` + `replication_support` | `fm_plus_n` log loss `0.440189` beats raw / density / CNF-size baselines; `3/3` returned outside reruns clean | Frozen Route A support | First-moment coordinate can transfer across held-out q better than tuple/raw baselines | Keep as scoped Route A support |
| Exp44 Cardinality-SAT pilot | Route A cardinality-style CSP | `failed_candidate` | Informative-band / runtime gate not ready for primary | Calibration no-go | Heterogeneous CSP extension needs threshold-local calibration before freeze | Do not count as evidence; redesign only as new prereg |
| Exp44b Cardinality-SAT v1 | Route A cardinality-style CSP | `failed_candidate` | Calibration-v1 completed `4800/4800` rows across `96` cells with `0` timeouts and `0` malformed rows, but closeout returned `calibration_no_go` because `M3_threeway_low` failed the monotonicity gate | Calibration no-go; row audit shows small local reversal rather than execution failure | Informative rho bands alone are not enough; strict pointwise monotonicity at `50` rows per n/rho cell is too brittle for this heterogeneous calibration surface | Keep as calibration history only; no primary from this v1 design; future retry must be a versioned redesign with a noise-aware calibration gate |
| Backblaze Q4 2025 v1 | Public drive reliability | `no_support` | High AUC but failed preregistered log-loss and sign guardrail | Calibration / sign failure | AUC alone is insufficient; calibration and sign rules must be primary when probabilities are claimed | Keep visible as no-support |
| Backblaze Q3 2025 v2 | Public drive reliability | `incremental_support` | Calibrated log loss improved over best baseline; core SMART directions passed | Same-domain calibrated support | Calibration-aware loss-only design can work in drive reliability | Same-domain only; do not erase v1 |
| C-MAPSS FD001 | Turbofan degradation | `weak_support` / weakening outcome | `D_pc1` beat simple baseline but failed wide-sensor guardrail | Compression guardrail fail | Low-dimensional structural degradation may carry signal without beating wide raw sensors | Keep as weakening outcome; no same-archive rescue |
| Scania Component X horizon bridge | Public stochastic reliability / TTE bridge | `no_support` | Compressed primary beat wide baseline but failed simple baseline gate | Public bridge no-support | Horizon labels were clean enough for a bridge test, but compressed `D_pc1` was not sufficient | Keep closed; no same-archive rescue |
| Oxford Path Dependent Part 1 | Battery M/SP profile | `no_support` + `weak_axis_mapping_failure` | Primary RMSE `0.2350867` did not improve over `B3 = 0.2296039` | M/SP axis duplicated battery state proxies too closely | Battery structure should be future service-envelope / operation-path margin, not capacity state renamed as M | Close Oxford v1; use lesson only for battery v2 prereg |
| M-flow network final candidate v0 | Controlled synthetic flow-network M-side testbed | `no_support` | Guarded primary executed once. In the primary setting, M-profile regret improved over total-resource regret (`0.2204` vs `0.2372`) but did not beat policy-prior regret (`0.1506`). Sensitivity settings retained the same qualitative pattern | Frozen-rule no-support because the calibration-best policy-prior baseline beat M-profile on the primary ranking metric | The allocation vector carries some information beyond scalar total budget, but a simple linear M-profile is not enough to beat a strong policy-prior intervention baseline in this controlled testbed | Keep as closed controlled-mechanistic no-support; no primary rescue from the same package. Any retry must be a versioned redesign before outcomes |

## 4. Required Entry Template

Use this template before a new attempt is promoted to a frozen test or after an
attempt is closed:

```text
Attempt id:
Domain / archive:
Date opened:
Date closed:
Status:

Target structure:
Structure granularity:
Mapping:
Baseline:
SP-only:
Baseline + SP:
Primary metric:
Validation surface:

Outcome:
Support decision:
Failure mode:
Reusable lesson:
Next treatment:
Same-archive rescue allowed: yes/no
```

## 5. Rules

1. Exploratory gains become `candidate_signal`, not support.
2. A candidate becomes support only after a frozen validation surface is passed.
3. No-support attempts remain visible.
4. Weak-axis failures must be recorded when the SP addition is a relabeled or
   near-duplicate baseline feature.
5. A post-hoc redesign from a failed archive may become a future
   `validation_candidate`, but it must not rescue the already failed frozen
   attempt.
6. If a domain accumulates repeated no-support or weak-axis outcomes without a
   natural non-leaky mapping, mark it as `silence` until a genuinely new
   measurement surface appears.
