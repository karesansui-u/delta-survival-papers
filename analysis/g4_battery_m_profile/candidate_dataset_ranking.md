# Battery M-Profile Candidate Dataset Ranking

Status: candidate-ranking design note only. Not a freeze document and not
validation evidence.

Date: 2026-04-28

## 1. Ranking Criteria

A battery dataset is a good M-profile validation candidate if it has:

1. repeated cells or packs;
2. explicit time / cycle index;
3. future capacity, EOL, RUL, or degradation endpoint;
4. protocol variation that can be fixed before outcome inspection;
5. enough held-out units for cell-level evaluation;
6. public reproducible access or exact archive identity;
7. no need to infer "recovery" from future outcome labels.

The best first branch is not necessarily the largest dataset. It is the one
where the M/SP mapping can be frozen without leakage.

## 2. Candidate Ranking

### Rank 1: Oxford Path Dependent Battery Degradation Dataset

Source:

- Oxford Research Archive, Path Dependent Battery Degradation Dataset Part 1
- DOI: `10.5287/bodleian:v0ervBv6p`
- URL: `https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e`

Why it is attractive:

- explicitly about path dependence;
- cells are subjected to combined calendar and cyclic aging profiles;
- protocol order and periodicity are central, not incidental;
- this gives a natural \(M_{\mathrm{reconfiguration}}\)-like feature:
  operating-structure / protocol-order design;
- physical interpretation is cleaner than software intervention logs.

Main risk:

- small number of cells per group;
- may be better as a feasibility / weak validation branch than a full primary
  support branch unless additional parts are combined.

Recommended role:

```text
first feasibility target
```

Current branch status:

```text
exact web-feasibility note opened; Part 1 small-file, EIS, and Group_2 parser
smokes passed; complete Part 1 identity and bounded per-zip `.mat` smoke also
passed; Part 1 no-metric RPT / diagnostic structure counts now satisfy the
pre-fixed T1-T5 count thresholds plus the T6 public-metadata availability gate
for a freeze-manifest draft; the Oxford Part 1 freeze-manifest draft now exists
and keeps the primary run blocked until MATLAB conversion, strict converted
smoke, header-only schema draft, human schema finalization, training-feature
smoke, and final converter/script SHA insertion all pass. The first execution
scaffold passed metadata-only but train-smoke is blocked because the cycling
payloads are MATLAB MCOS tables exposed by SciPy as `MatlabOpaque`.
```

Parser-smoke artifact:

```text
analysis/g4_battery_m_profile/oxford_path_dependent_parser_smoke_plan.md
analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py
analysis/g4_battery_m_profile/oxford_path_dependent_full_archive_identity_plan.md
analysis/g4_battery_m_profile/oxford_path_dependent_part1_full_identity_note.md
analysis/g4_battery_m_profile/oxford_path_dependent_part1_rpt_structure_count_note.md
analysis/g4_battery_m_profile/oxford_path_dependent_freeze_manifest_draft.md
analysis/g4_battery_m_profile/oxford_path_dependent_metadata_train_smoke_note.md
analysis/g4_battery_m_profile/oxford_path_dependent_mcos_conversion_plan.md
analysis/g4_battery_m_profile/oxford_path_dependent_mcos_converter_script_note.md
```

### Rank 2: NASA Randomized and Recommissioned Battery Dataset

Source:

- NASA Open Data, Randomized and Recommissioned Battery Dataset
- URL: `https://data.nasa.gov/dataset/randomized-and-recommissioned-battery-dataset`

Why it is attractive:

- accelerated Li-ion battery life-cycle dataset;
- constant and variable loading conditions;
- load-level changes;
- second-life / recommissioned battery packs;
- 26 battery packs composed of two 18650 cells, according to the public
  dataset description.

M-profile relevance:

- load variation and load-level change can support degradation-side and
  reconfiguration-like features;
- second-life / recommissioning gives a strong candidate for external
  restructuring / reuse profile, if metadata is clean;
- pack-level structure may be closer to real operational maintenance than
  single-cell laboratory cycling.

Main risk:

- archive parsing and exact data availability must be checked;
- second-life structure may be too coarse for predictive validation if group
  sizes are small.

Recommended role:

```text
second feasibility target; potential stronger primary if archive shape is clean
```

### Rank 3: MIT-Stanford/TRI Fast-Charging Battery Cycle-Life Dataset

Source:

- Nature Energy 2019, "Data-driven prediction of battery cycle life before
  capacity degradation"
- Data availability: `https://data.matr.io/1`
- Paper URL: `https://www.nature.com/articles/s41560-019-0356-8`

Why it is attractive:

- 124 commercial LFP/graphite cells;
- wide cycle-life range;
- fast-charging protocols;
- strong existing battery-domain baseline literature;
- good for testing whether M/SP features add anything beyond strong voltage
  curve features.

M-profile relevance:

- \(M_{\mathrm{buffer}}\): early capacity / voltage margin;
- \(M_{\mathrm{reconfiguration}}\): fast-charge protocol differences;
- \(M_{\mathrm{recovery}}\): likely weak unless rest / relaxation data are
  explicitly usable.

Main risk:

- existing voltage-curve features are already very strong;
- a weak M/SP feature set may not beat domain-native baselines;
- this is a hard test, not an easy first feasibility branch.

Recommended role:

```text
strong baseline challenge after pipeline feasibility
```

### Rank 4: NASA PCoE Li-ion Battery Aging Datasets

Source:

- NASA Open Data, Li-ion Battery Aging Datasets
- URL: `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets`

Why it is attractive:

- classic prognostics benchmark;
- 18650 Li-ion cells;
- charge, discharge, and EIS profiles;
- different temperatures and load levels;
- EOL criterion described as 30% fade from 2 Ah to 1.4 Ah.

Main risk:

- current NASA page reports no direct data resource on the Open Data mirror;
- direct download path must be verified through Dashlink / NASA repository.

Recommended role:

```text
classic benchmark if exact archive access is clean
```

### Rank 5: CALCE CS2

Source:

- CALCE Battery Data Archive
- URL: `https://web.calce.umd.edu/batteries/data/`

Why it is attractive:

- well-known public battery aging data;
- small prismatic LiCoO2 cells;
- standard CC/CV charging protocol;
- capacity degradation is easy to model.

Main risk:

- weaker protocol/intervention variation;
- likely better for loss-only or capacity-fade modeling than M-profile
  intervention logic.

Recommended role:

```text
loss-only / baseline sanity control
```

### Rank 6: Oxford Battery Degradation Dataset 1

Source:

- Oxford Research Archive, Oxford Battery Degradation Dataset 1
- DOI: `10.5287/bodleian:KO2kdmYGg`
- URL: `https://ora.ox.ac.uk/objects/uuid%3A03ba4b01-cfed-46d3-9b1a-7d4a7bdf6fac`

Why it is attractive:

- long-term cycling of 8 Kokam 740 mAh Li-ion pouch cells;
- real lab degradation data;
- downloadable `.mat` archive listed in ORA.

Main risk:

- only 8 cells;
- likely too small for primary validation;
- useful for parser / feature-extraction feasibility.

Recommended role:

```text
small feasibility / parser smoke target
```

## 3. Recommended First Sequence

The clean sequence is:

```text
1. run the MATLAB / MCOS converter in a MATLAB environment for training cells
   first via `scripts/run_oxford_part1_training_conversion_smoke.sh`
2. rerun the existing Python `--converted-train-root` train-smoke interface
   without held-out payload values, parsed values, or metrics
3. run the header-only schema draft to list candidate columns without reading
   training values
4. human-finalize the exact endpoint / feature field paths from the converted
   training schema and public guide only
5. run the training-only endpoint/feature extraction and model-fit smoke
   without held-out values or metrics
6. promote the draft to frozen only after training-feature smoke passes and
   converter/script SHA plus command are inserted
7. run held-out primary once
8. NASA Randomized/Recommissioned exact feasibility only if Oxford fails
   train-smoke or is demoted before primary
```

If Oxford Path Dependent is too small:

```text
demote to feasibility and move NASA Randomized/Recommissioned to primary
candidate
```

If NASA archive parsing is too hard:

```text
use MIT-Stanford/TRI as a hard baseline challenge
```

## 4. Candidate Decision Rule

Before any freeze, choose the dataset with the best combination of:

```text
unit count + protocol variation + endpoint clarity + no-leak split + public
reproducibility
```

Do not choose a dataset merely because it has an appealing battery story.
