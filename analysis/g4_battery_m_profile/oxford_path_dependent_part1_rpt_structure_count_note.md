# Oxford Path Dependent Part 1 RPT Structure Count Note

Status: pre-freeze no-metric RPT / diagnostic structure count. Not a freeze
manifest, not validation evidence, not feature extraction, and not a support
claim.

Date: 2026-04-28

## 1. Purpose

This note records the first no-metric structural count for Oxford Path
Dependent Part 1 after complete Part 1 local archive identity and bounded
`.mat` smoke.

The count reads only:

```text
zip entry names
public guide / readme metadata
```

It does not open MATLAB values, compute capacity endpoints, construct features,
fit models, compare baselines, or emit support flags.

Source record:

```text
https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e
```

## 2. Command

Command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_rpt_structure.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output /tmp/oxford_rpt_structure_part1.json \
  --part part1
```

Script boundary:

```text
analysis/g4_battery_m_profile/scripts/inspect_oxford_rpt_structure.py
```

The script parses `.mat` entry names inside Part 1 `Group_*.zip` archives. It
does not inspect `.mat` payload values.

## 3. Archive Parse Summary

| Archive | `.mat` entries | Parsed entries | Unmatched entries |
|---|---:|---:|---:|
| `Group_1.zip` | `65` | `65` | `0` |
| `Group_2.zip` | `66` | `66` | `0` |
| `Group_3.zip` | `56` | `56` | `0` |
| `Group_4.zip` | `63` | `63` | `0` |

The filename parser matched all Part 1 group entries.

## 4. No-Metric Structural Counts

Pre-fixed count horizon:

```text
H_count = 1 diagnostic / reference-test index step
```

Secondary count-only horizon:

```text
H_count_secondary = 2 diagnostic / reference-test index steps
```

Observed counts:

| Quantity | Count |
|---|---:|
| Unique filename cell IDs | `12` |
| Group-cell series | `14` |
| Retained protocol groups | `4` |
| Candidate rows under `H_count = 1` | `223` |
| Candidate rows under `H_count_secondary = 2` | `222` |
| Safe held-out protocol-group folds | `1` |
| Safe held-out cell-ID folds | `12` |
| Minimum H1 rows per safe cell-ID fold | `14` |

Group-level H1 candidate rows:

| Group | H1 rows |
|---|---:|
| `1` | `59` |
| `2` | `58` |
| `3` | `49` |
| `4` | `57` |

The count uses filename-index adjacency only. It does not impute missing
diagnostic indices and does not treat a base file followed by a later numbered
file as an adjacent `H_count = 1` pair unless the numeric index also exists.

## 5. Duplicate Cell-ID Reconciliation

Part 1 contains repeated filename cell IDs across groups:

| Cell ID | Groups |
|---|---|
| `10` | `2`, `3` |
| `15` | `1`, `3` |

Conservative policy:

```text
Treat repeated cell IDs across groups as the same physical unit unless the
guide proves otherwise; do not split the same cell ID across train/test.
```

Under this policy, nominal held-out protocol-group folds reduce from `4` to
`1` safe group fold:

| Held-out group | Cell-ID overlap with train groups |
|---|---|
| `1` | `15` |
| `2` | `10` |
| `3` | `10`, `15` |
| `4` | none |

Therefore the pre-fixed split priority falls through from held-out protocol
group to held-out cell ID.

Chosen split level by the pre-fixed rule:

```text
heldout_cell_id
```

## 6. T1-T6 Promotion Check

| Gate | Result | Observed basis |
|---|---|---|
| T1: at least 12 unique cells after duplicate reconciliation | pass | `12` unique filename cell IDs |
| T2: at least 4 retained protocol groups with at least 2 cells each | pass | `4` groups, each at least `3` cell IDs |
| T3: at least 2 safe group folds or at least 6 cell folds | pass | `1` safe group fold, `12` safe cell-ID folds |
| T4: at least 60 H1 candidate rows | pass | `223` |
| T5: at least 5 H1 rows per chosen held-out fold | pass | minimum cell-ID fold rows `14` |
| T6: public-metadata availability for candidate families | pass as manual availability assertion only | buffer / recovery / reconfiguration / consumption families are described by public metadata; this is not automated feature-computability validation |

Threshold status:

```text
promotion_allowed_for_freeze_manifest_draft = true
```

This means only:

```text
Part 1 satisfies the pre-fixed no-metric structural-count gate for writing a
freeze-manifest draft.
```

It does not mean:

```text
Oxford supports the theory
Oxford has passed a primary validation
Oxford has a chosen feature set
Oxford has beaten a battery-domain baseline
```

T6 caveat:

```text
T6 is a public-metadata availability assertion only. The later metadata-only /
train-smoke script must still prove that concrete pre-cutoff feature columns can
be extracted without touching held-out payload values or future labels.
```

## 7. Interpretation

Oxford Path Dependent Part 1 is now strong enough to move from parser
feasibility into a freeze-manifest draft for weak predictive validation.

The primary validation geometry should be conservative:

```text
unit = filename cell ID
split = held-out cell ID
horizon = H_count = 1 diagnostic / reference-test index step
```

The held-out cell-ID fallback means there are `12` feasible no-leak held-out
cell choices by count. The later freeze-manifest draft fixes a single
train/test cell-ID split so that train-smoke can read training payloads without
touching held-out payload values after the split is fixed. Earlier bounded
parser-smoke runs predate that split and are treated as schema-only
grandfathered smoke. If the later endpoint parser reduces any retained test
cell below the T5 minimum, the branch must be demoted or a new freeze design
must be written before primary evaluation.

The freeze package should keep the main question predictive:

```text
Does domain baseline + frozen battery M/SP features improve out-of-sample
prediction over a frozen strong battery-domain baseline?
```

It should not claim intervention ranking or causal mitigation selection at this
stage.

## 8. Next Step

The clean next artifact is:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md
```

That draft now exists, and the metadata-only / train-smoke scaffold, MATLAB
converter-script draft, and training-conversion runner now exist. The next
implementation artifact should be a MATLAB-environment converter execution
result note for:

```text
analysis/g4_battery_m_profile/scripts/export_oxford_part1_training_tables.m
```
