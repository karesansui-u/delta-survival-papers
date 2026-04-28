# Oxford Path Dependent Battery Feasibility Note

Status: exact web-feasibility note. Large archive contents not downloaded or
inspected here; Part 1 small-file / EIS smoke is recorded separately. Not
frozen and not validation evidence.

Date: 2026-04-28

## 1. Candidate Identity

Candidate branch:

```text
G4 Battery M-Profile / Oxford Path Dependent feasibility
```

Primary source family:

```text
Path Dependent Battery Degradation Dataset Parts 1-3
Oxford Research Archive
```

This note records public archive feasibility only. It does not inspect the
large `.mat` contents, compute features, or choose a primary endpoint.

## 2. Source Records

| Part | ORA record | DOI | Publication date | Stated role |
|---|---|---|---|---|
| Part 1 | `https://ora.ox.ac.uk/objects/uuid%3Ade62b5d2-6154-426d-bcbb-30253ddb7d1e` | `10.5287/bodleian:v0ervBv6p` | 2020 | beginning-of-life to middle-of-life path-dependence dataset |
| Part 2 | `https://ora.ox.ac.uk/objects/uuid%3Abe3d304e-51fd-4b37-a818-b6fa1ac2ba9d` | `10.5287/bodleian:2zvyknyRg` | 2021 | continuation of Part 1 from middle-of-life to end-of-life, plus groups 5 and 6 |
| Part 3 | `https://ora.ox.ac.uk/objects/uuid%3A78f66fa8-deb9-468a-86f3-63983a7391a9` | `10.5287/bodleian:j1a2eD7ow` | 2021 | modified calendar/cyclic condition path-dependence dataset |
| Paper | `https://ora.ox.ac.uk/objects/uuid%3Ac097fba0-a992-485d-a6bf-86c28c9b5df9` | publisher DOI `10.1002/batt.202000160` | 2020 | peer-reviewed path-dependence study |

Terms / license:

- ORA records list ODC Open Database License links for dataset files.
- Dataset copyright / disclaimer remains with Oxford and the dataset
  researchers.

## 3. Archive Contents From Public Record

### Part 1 files

Part 1 contains:

| File | Public size |
|---|---:|
| `Guide_to_Datafiles.pdf` | 122.6KB |
| `Guide_to_Datafiles.xlsx` | 21.4KB |
| `Half_Cell.zip` | 8.5MB |
| `Group_1.zip` | 822.4MB |
| `Group_2.zip` | 724.6MB |
| `Group_3.zip` | 773.7MB |
| `Group_4.zip` | 790.6MB |
| `Readme.txt` | 4.5KB |
| `EIS.zip` | 185.8KB |

Part 1 public record states digital size `3.15GB`, file format `.mat`, and
temporal coverage `2017-2020`.

### Part 2 files

Part 2 contains:

| File | Public size |
|---|---:|
| `EIS.zip` | 204.8KB |
| `Group_1.zip` | 379.2MB |
| `Group_2.zip` | 376.0MB |
| `Group_3.zip` | 366.4MB |
| `Group_4.zip` | 352.8MB |
| `Group_5.zip` | 1.2GB |
| `Group_6.zip` | 202.0MB |
| `Guide_to_Datafiles_2.pdf` | 110.8KB |
| `Readme.txt` | 5.1KB |
| `Guide_to_Datafiles_2.xlsx` | 15.0KB |

Part 2 public record states temporal coverage `2017-2020`.

### Part 3 files

Part 3 contains:

| File | Public size |
|---|---:|
| `EIS.zip` | 111.2KB |
| `Group_7.zip` | 521.8MB |
| `Group_8.zip` | 550.6MB |
| `Group_9.zip` | 531.7MB |
| `Group_10.zip` | 858.6MB |
| `Guide_to_Datafiles_3.pdf` | 101.5KB |
| `Guide_to_Datafiles_3.xlsx` | 13.1KB |
| `Readme.txt` | 4.6KB |

Part 3 public record states file format `.mat` and temporal coverage
`2018-2020`.

## 4. Unit And Protocol Structure

The readme files describe the test subjects as:

```text
NCR18650BD cells
NCA positive electrode / graphite negative electrode
3Ah
```

Part 1:

- 12 cells total;
- 4 groups;
- 3 cells per group;
- all tests at 24 degC;
- data fields include time, current, voltage, capacity, and temperature;
- reference performance tests every 48 cycles.

Group descriptions:

| Group | Combined profile |
|---|---|
| Group 1 | 1 day cycling at C/2 + 5 days calendar aging at 90% SoC |
| Group 2 | 1 day cycling at C/4 + 5 days calendar aging at 90% SoC |
| Group 3 | 2 days cycling at C/2 + 10 days calendar aging at 90% SoC |
| Group 4 | 2 days cycling at C/4 + 10 days calendar aging at 90% SoC |

Part 2:

- continuation of Part 1 after middle of life for groups 1-4;
- adds Group 5 with 3 cells under continuous CC cycling at C/2;
- adds Group 6 with 1 cell under continuous calendar aging at 90% SoC;
- all data files include time, current, voltage, capacity, and temperature;
- EIS at BoL, MoL, and EoL for all groups, except no MoL EIS for group 5.

Part 3:

- 4 groups;
- 3 cells per group;
- all data files include time, current, voltage, capacity, and temperature,
  but first 3-4 files in groups 7, 8, and 9 do not have temperature data;
- reference performance tests every 48 cycles;
- EIS at beginning and end of life at 80%, 50%, and 20% SoC.

Group descriptions:

| Group | Combined profile |
|---|---|
| Group 7 | 1 day CCCV cycling at C/2 + 5 days calendar aging at 90% SoC |
| Group 8 | 2 days CCCV cycling at C/2 + 10 days calendar aging at 90% SoC |
| Group 9 | 1 day CCCV cycling at C/2 + 5 days calendar aging at 4.2V |
| Group 10 | 2 days CCCV cycling at C/2 + 10 days calendar aging at 4.2V |

## 5. Feasibility Assessment

### What looks strong

This archive is unusually well aligned with the battery M-profile branch:

- repeated cells exist;
- time / cycle index exists;
- capacity is directly recorded;
- current, voltage, temperature, and EIS are present;
- protocol order and periodicity are the actual experimental design;
- calendar aging vs cyclic aging is explicit;
- the peer-reviewed paper frames the issue as path-dependent degradation.

This is especially valuable for \(M_{\mathrm{reconfiguration}}\), because the
candidate M-side signal is not an after-the-fact label. It is encoded in the
experimental protocol.

### What looks risky

The main risk is sample size:

- groups are typically 3 cells each;
- Part 2 group 6 has only one cell;
- even combining Parts 1-3 may give a modest number of independent cells;
- a held-out cell-level primary may be underpowered.

Therefore this branch should not jump directly to strong empirical support.
The safer initial status is:

```text
positive exact feasibility; likely parser/feature-smoke target; possible weak
validation if held-out split is acceptable after exact parsing.
```

## 6. Candidate M/SP Mapping Before Data Inspection

The following mapping can be fixed before inspecting outcome metrics.

| M/SP family | Battery proxy | Pre-outcome source |
|---|---|---|
| \(M_{\mathrm{buffer}}\) | capacity margin to threshold; voltage-window margin; temperature margin where available | reference tests and cycle measurements before cutoff |
| \(M_{\mathrm{recovery}}\) | reversible relaxation / rebound-like response after calendar-aging or rest segments; pseudo-OCV / pulse response changes | reference tests before cutoff |
| \(M_{\mathrm{reconfiguration}}\) | protocol order / periodicity / C-rate / calendar-aging SoC group | group assignment and protocol metadata |
| \(\hat L\) / consumption side | cumulative cycling exposure, C-rate severity, calendar-aging duration, throughput, early capacity-fade slope | pre-cutoff cycle history |

Important boundary:

```text
M_recovery must not be defined as future capacity improvement after the
prediction cutoff.
```

It may only use pre-cutoff relaxation or rebound-like signals.

## 7. Candidate Predictive Designs

### Design A: future capacity at fixed horizon

Unit:

```text
cell
```

Prediction rows:

```text
reference-test index k for a given cell
```

Outcome:

```text
capacity at k + H
```

Split:

```text
held-out cells or held-out groups
```

Risk:

```text
small number of cells may make held-out-cell performance noisy.
```

### Design B: leave-one-group-out protocol generalization

Unit:

```text
protocol group
```

Train:

```text
all but one protocol group
```

Test:

```text
held-out protocol group
```

Purpose:

```text
tests whether M/SP features generalize across protocol regimes.
```

Risk:

```text
only a small number of groups; should be weak validation unless very stable.
```

### Design C: feasibility-only parser / feature smoke

Purpose:

```text
verify exact archive parsing, cell counts, reference-test extraction, and
pre-cutoff M/SP feature construction.
```

This is the recommended next step before a freeze.

## 8. Historical Decision And Current Status

Historical decision:

```text
Oxford Path Dependent should remain Rank 1 for exact feasibility and parser
smoke, but should not yet be promoted to primary validation until the exact
archive parse confirms enough independent held-out units.
```

That parser / identity path has now advanced through Part 1 small-file smoke,
one group smoke, full Part 1 identity, no-metric RPT structure counts,
freeze-manifest draft, metadata/train-smoke, and a MATLAB conversion packet.

Current recommended next move:

```text
run the Oxford Part 1 training-conversion runner in a MATLAB environment,
then fix endpoint / feature field paths from training schema plus public guide
information before any held-out conversion.
```

The earlier staged acquisition plan was:

1. small-file parser feasibility using guide/readme and one group archive;
2. full archive acquisition only after parser feasibility is confirmed.

## 9. Non-Claims

This note does not claim:

1. empirical support for M-profile features;
2. intervention-ranking support;
3. recovery-flow evidence in the repair-maintenance sense;
4. literal electrochemical repair;
5. that Oxford Path Dependent is large enough for primary validation;
6. that Part 1, Part 2, and Part 3 can be merged without exact parsing.

It claims only:

```text
Oxford Path Dependent is a strong public physical-degradation feasibility
candidate for the battery M-profile branch, with a special strength on
protocol-order / path-dependence structure and a special risk from small
independent-cell counts.
```
