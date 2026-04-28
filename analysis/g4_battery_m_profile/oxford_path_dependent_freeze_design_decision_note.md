# Oxford Path Dependent Freeze-Design Decision Note

Status: pre-freeze decision note. Not a freeze manifest, not validation
evidence, and not a claim that Oxford supports the battery M-profile branch.

Date: 2026-04-28

## 1. Current Position

Oxford Path Dependent has now passed four pre-freeze gates:

1. exact web feasibility for Parts 1-3;
2. Part 1 guide/readme + `EIS.zip` acquisition and parser smoke;
3. Part 1 `Group_2.zip` cycling/profile archive acquisition and bounded
   `.mat` parser smoke;
4. complete Part 1 identity plus no-metric RPT / diagnostic structure counts.

This is enough to keep Oxford as the first battery M-profile candidate and to
write a freeze-manifest draft, but not enough to run a primary validation.

Current decision:

```text
Oxford Path Dependent Part 1 should advance to a freeze-manifest draft, not
directly to feature extraction or primary validation.
```

## 2. Why Not Freeze Yet

The limiting issue is no longer basic parser feasibility. The limiting issue is
validation geometry and leakage-safe freezing.

Known risks before full parsing:

- independent cell count is modest;
- Parts 1 and 2 partly continue the same cells, so naïvely adding files may not
  add independent units;
- protocol groups are small, typically three cells per group;
- Part 2 Group 6 has only one cell;
- outcome horizon and reference-test indexing must be fixed from the guide /
  parser, not chosen after seeing predictive performance.
- repeated filename cell IDs occur across groups (`10` and `15`), so
  protocol-group holdout is not safe unless physical-cell identity is resolved.

Therefore the branch must not treat the successful Group 2 smoke as empirical
support.

## 3. Minimum Gate For Freezing Oxford

Oxford has now satisfied the no-metric parser-count gate for a freeze-manifest
draft. The parser pass records:

1. exact local file identities for all selected parts;
2. unique cell identifiers;
3. protocol group membership per cell;
4. available reference-test / diagnostic-test indices per cell;
5. capacity-like endpoint availability by reference-test index;
6. candidate prediction rows count before any train/test metric;
7. feasible held-out split count;
8. whether Parts 1-3 can be merged without duplicate-cell leakage.

This parser pass may record counts and structural availability. It must not
record model performance, baseline comparisons, support flags, or feature
ranking.

Promotion thresholds are fixed before the full parser pass:

```text
T1: at least 12 unique cells after duplicate-cell reconciliation;
T2: at least 4 protocol groups with at least 2 cells per retained group;
T3: at least 2 feasible held-out protocol-group folds, or at least 6 feasible
    held-out-cell folds if group-level holdout is impossible;
T4: at least 60 candidate prediction rows under one pre-fixed horizon H;
T5: at least 5 candidate prediction rows in every held-out fold;
T6: public metadata must indicate pre-cutoff source fields or protocol metadata
    for all candidate M/SP families. Concrete feature computability must still
    be proven by metadata-only / train-smoke execution before primary.
```

Observed Part 1 result:

```text
T1-T5 pass and T6 public-metadata availability passes under conservative
duplicate-cell reconciliation.
```

The split consequence is important:

```text
held-out protocol group falls back to held-out cell ID.
```

Part 1 has only `1` safe held-out protocol-group fold after treating repeated
cell IDs as the same physical unit, but it has `12` safe held-out cell-ID folds
with at least `14` H1 candidate rows per fold.

## 4. Candidate Freeze If Oxford Passes The Gate

After the no-metric T1-T5 count pass and T6 public-metadata availability pass,
the first Oxford freeze should be weak-validation framed.

Unit:

```text
cell
```

Time index:

```text
reference-test or diagnostic-test index k
```

Primary outcome candidate:

```text
future capacity at k + H
```

Fallback outcome candidate:

```text
capacity drop over [k, k + H]
```

Split priority:

```text
held-out protocol group > held-out cell ID > no primary
```

The split must prevent the same cell from appearing in both train and test.

Current Part 1 count selects:

```text
held-out cell ID
```

The later freeze-manifest draft fixes this as a single train/test cell-ID split,
not leave-one-cell-ID-out cross-validation, so that post-split train-smoke can
read training payloads without touching any held-out payload values.

Earlier bounded parser-smoke runs predate this fixed split and are treated as
schema-only grandfathered smoke: they emitted keys/shapes only, not endpoint
values, features, predictions, metrics, or support flags.

Primary question:

```text
Does domain baseline + frozen battery M/SP features improve out-of-sample
prediction over the frozen domain baseline?
```

Support strength:

```text
weak validation only.
```

## 5. Candidate M/SP Families

These are candidate families only. They are not yet frozen feature definitions.

`M_buffer` candidates:

- capacity margin to threshold;
- voltage-window margin;
- temperature margin where available;
- stress headroom under pre-cutoff protocol history.

`M_recovery` candidates:

- pre-cutoff relaxation / rebound-like signal after rest or calendar-aging
  segments;
- pseudo-OCV / EIS response changes available before the prediction cutoff.

`M_reconfiguration` candidates:

- protocol order;
- cycling/calendar periodicity;
- C-rate group;
- calendar-aging SoC condition;
- CCCV vs CC profile where applicable.

Consumption-side candidates:

- cumulative throughput;
- cycle count;
- calendar aging duration;
- C-rate severity;
- early pre-cutoff capacity-fade slope.

No candidate may use post-cutoff capacity improvement or future label
information.

## 6. Demotion Rule

Oxford should be demoted to feasibility-only if any of the following holds:

1. full parsing cannot cleanly identify unique cells across Parts 1-3;
2. reference-test capacity endpoints are too sparse for a fixed horizon;
3. no split can keep cells independent across train and test;
4. any of the pre-fixed thresholds T1-T6 fail;
5. M_recovery can only be defined using post-cutoff behavior.

If Oxford is demoted, the next candidate should be NASA
Randomized/Recommissioned. MIT-Stanford/TRI should remain the later hard
baseline challenge, not the first parser branch.

## 7. Next Artifact

The next artifact should be:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md
```

That draft now exists, and the metadata-only / train-smoke execution scaffold
now records an MCOS-table block. The converter-script draft and
training-conversion runner also now exist. The next implementation artifact
should be the MATLAB-environment converter execution result note. The one-time
primary run remains blocked until the draft is promoted to frozen with final
converter/script SHA and command.
