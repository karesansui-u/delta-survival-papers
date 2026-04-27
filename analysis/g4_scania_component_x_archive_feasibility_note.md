# G4 Scania Component X Exact Feasibility Note

Status: exact public-feasibility note. Not frozen. Not validation evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_v2_public_repair_flow_rescan_2026-04-27.md`
- `analysis/g4_v2_repair_flow_acquisition_brief.md`
- `analysis/g4_v2_stochastic_repair_bridge_note.md`

## 1. Purpose

Record one exact public version identity for the Scania Component X dataset and
enough structural facts to decide its current tier.

This note is not yet a repair-flow freeze. It only answers:

```text
Is Scania Component X best read as
  (a) a clean repair-flow primary,
  (b) a public stochastic reliability bridge, or
  (c) something weaker?
```

## 2. Exact Version Choice

Canonical dataset family:

```text
Scania Component X dataset on Researchdata.se
```

Dataset landing pages:

- Concept-level page: <https://researchdata.se/en/catalogue/dataset/2024-34>
- Version-specific page used for this note:
  <https://researchdata.se/en/catalogue/dataset/2024-34/3>

Exact version fixed for this feasibility note:

```text
Version 3
DOI: 10.5878/bnh5-ka77
Published: 2025-04-09
```

Version history relevant to later freeze:

- Version 1 DOI: `10.58141/1w9m-yz81`
- Version 2 DOI: `10.5878/jvb5-d390`
  - public rationale: **data added**
  - exact change: test labels added
- Version 3 DOI: `10.5878/bnh5-ka77`
  - public rationale: **metadata added**
  - exact change: manuscript PDF replaced by the final article version

Interpretation:

```text
Version 3 is the correct current public identity.
The main data-relevant expansion happened at version 2, when test labels were
added. Version 3 is the latest published state and should be the one cited.
```

## 3. Exact Public File Manifest (Version 3)

The Researchdata API for version 3 exposes 11 files with total listed content
size:

```text
1,655,183,186 bytes
```

Exact files:

| file | content size bytes | role |
|---|---:|---|
| `train_operational_readouts.csv` | `1219209878` | training time-series readouts |
| `train_tte.csv` | `345412` | training time-to-event / repair label table |
| `train_specifications.csv` | `1081118` | training vehicle-spec table |
| `validation_operational_readouts.csv` | `215593159` | validation partial readout history |
| `validation_labels.csv` | `38742` | validation endpoint labels |
| `validation_specifications.csv` | `231765` | validation spec table |
| `test_operational_readouts.csv` | `214897259` | test partial readout history |
| `test_labels.csv` | `38682` | test endpoint labels |
| `test_specifications.csv` | `231658` | test spec table |
| `2024_IDA_challenge_v2.pdf` | `231630` | challenge / documentation file |
| `Scania_Component_X.pdf` | `3283883` | final article PDF |

The API file endpoints are version-specific under:

```text
https://doris.snd.se/api/file/2024-34/3/...
```

## 4. Locally Verified Exact Small Files

Without downloading the full 1.54 GiB operational payload, this note locally
verified the small supervision/specification files and streamed the first lines
of the large readout files.

### 4.1 Supervision files

| file | bytes | sha256 | rows | header |
|---|---:|---|---:|---|
| `train_tte.csv` | `345412` | `d8c2379ed7c95a575dd869730b2b3b96d660317f49e57de300518ff3b08d53a5` | `23550` | `vehicle_id,length_of_study_time_step,in_study_repair` |
| `validation_labels.csv` | `38742` | `ad876c95c3696f4cfca2d76212ad6bb3cac6b2d2950a4aeaf218ee8b1548d08c` | `5046` | `vehicle_id,class_label` |
| `test_labels.csv` | `38682` | `60f923051d4ba1bef4c81166cf9e8ca01daf3b7a29c73016c6f48a23dcfa0223` | `5045` | `vehicle_id,class_label` |

### 4.2 Specification files

| file | bytes | sha256 | rows | header prefix |
|---|---:|---|---:|---|
| `train_specifications.csv` | `1081118` | `47cc9a67aee19d5e2ee8620fe8e467490b2125bacc7787ce781ce9f3c1f0c38f` | `23550` | `vehicle_id,Spec_0,...,Spec_7` |
| `validation_specifications.csv` | `231765` | `a31e832846538dd7a1829108b69420d9377dcd05d6446d8ac1270a974fc58ae2` | `5046` | `vehicle_id,Spec_0,...,Spec_7` |
| `test_specifications.csv` | `231658` | `40ac8a111f6d5b416107ec1786f639766ecf1293a1c9c0c0dbf24f14c1c5d0e7` | `5045` | `vehicle_id,Spec_0,...,Spec_7` |

### 4.3 Readout file headers

The three large `*_operational_readouts.csv` files were not fully downloaded in
this note, but their streamed first lines confirm:

- `107` columns;
- prefix `vehicle_id,time_step,...`;
- numeric readout features thereafter.

Observed header prefix:

```text
vehicle_id,time_step,171_0,666_0,427_0,837_0,...
```

## 5. Structural Facts From The Scientific Data Article

Primary article:

- <https://www.nature.com/articles/s41597-025-04802-6>

The paper gives the key structural counts and label semantics:

- train set split is `70%` of vehicles; validation and test are `15%` each;
- `train_operational_readouts.csv` has `1,122,452` readouts from `23,550`
  unique vehicles and `107` columns;
- `train_tte.csv` has `23,550` rows with label counts:
  `21,278` zero and `2,272` one;
- `validation_operational_readouts.csv` has `196,227` rows from `5,046`
  vehicles;
- `test_operational_readouts.csv` has `198,140` rows from `5,045` vehicles;
- the dataset is intended for regression, survival analysis, and
  classification.

Most important label interpretation from the article:

```text
train_tte.csv contains repair records of Component X and indicates the
time_to_event, i.e. the replacement time for Component X during the study
period.
```

And:

```text
validation_labels.csv and test_labels.csv label the last simulated readout of
each vehicle by time-window classes before failure / repair.
```

## 6. Exact Structural Reading

The current exact reading is:

| field family | structural role |
|---|---|
| `vehicle_id` | repeated unit |
| `time_step` | time axis |
| `*_operational_readouts.csv` | loss-side covariates / degradation history |
| `*_specifications.csv` | static unit metadata |
| `train_tte.csv` | training time-to-event / repair endpoint table |
| `validation_labels.csv`, `test_labels.csv` | held-out classification endpoint labels |

This is clearly stronger than a generic observational benchmark because:

1. repeated units are explicit;
2. time-to-event semantics are explicit;
3. censored / partial observation structure is explicit;
4. public versioning and DOI identity are explicit.

## 7. Why This Is Not Yet A Clean Repair-Flow Primary

The main blocker is not missing timestamps. It is the role of the repair signal.

The currently exposed repair semantics are best read as:

```text
endpoint / event-time labels for Component X replacement
```

rather than:

```text
pre-cutoff direct intervention variable with preventive / reactive classes and
post-intervention margin recovery semantics
```

Concretely:

- `in_study_repair` in `train_tte.csv` marks whether repair occurs at the
  recorded time-to-event;
- validation/test labels are time-window classes for the last simulated
  readout;
- the published files do not, at this stage, expose a separate repeated
  intervention-event table that could be frozen directly as \(g_t\).

So a repair-flow primary claim would overread the public structure.

## 8. Why This *Is* A Strong Public Stochastic Reliability Bridge Candidate

Scania Component X fits the public stochastic reliability bridge tier because:

1. the repeated-unit panel is explicit;
2. the time axis is explicit;
3. event-time / repair-time semantics are explicit;
4. censoring / partial observation are explicit;
5. survival-analysis and classification use are already part of the public data
   description.

That makes the safe current tier:

```text
public stochastic reliability bridge candidate
```

not:

```text
completed repair-flow empirical bridge
```

## 9. Current Verdict

```text
Scania Component X should currently be opened as a public stochastic
reliability / time-to-event bridge candidate, not as a clean public
repair-flow primary.
```

## 10. Next Clean Move

If this branch is continued, the clean next move is:

1. decide whether to open a Scania bridge package as
   - survival / time-to-event bridge, or
   - horizon-classification bridge;
2. keep all wording below direct repair-flow \(g_t\) support;
3. continue partner/local acquisition in parallel for the stronger target:
   directly logged pre-cutoff intervention variables.

## 11. Non-Claims

This note does not claim:

1. Scania Component X already closes the repair-flow empirical gap;
2. `train_tte.csv` is a direct \(g_t\) series;
3. Azure PdM or MetroPT-3 should be discarded permanently;
4. public-web data are enough by themselves to close G4 v2.

It claims only:

```text
Scania Component X is now the strongest current public candidate for a
stochastic reliability bridge, and its exact public version identity can be
fixed cleanly at version 3 / DOI 10.5878/bnh5-ka77.
```
