# G4 Scania Component X Large Readout Exact Acquisition Note

Status: exact public archive-acquisition note. Not frozen. Not validation
evidence. Not repair-flow evidence.

Date: 2026-04-27

Upstream notes:

- `analysis/g4_scania_component_x_archive_feasibility_note.md`
- `analysis/g4_scania_component_x_bridge_package_draft.md`

## 1. Purpose

Close the remaining large-file acquisition gate for the public Scania bridge
route by recording exact local acquisition of the three operational-readout
files from the fixed public identity:

```text
Scania Component X
Version 3
DOI: 10.5878/bnh5-ka77
```

This note is about archive identity only. It does not freeze a model, metric,
or primary path.

## 2. Acquisition Method

The three large public CSV files were acquired locally from the version-3 file
endpoints under:

```text
https://doris.snd.se/api/file/2024-34/3/data?filePath=...
```

Because the files are large and the server supports `Accept-Ranges: bytes`, the
local exact acquisition used an 8-way ranged parallel download and then
reassembled the completed parts into the final CSV files.

Local non-repo staging directory:

```text
/tmp/scania_component_x_v3_exact
```

The raw CSV files remain outside git. Only the exact size / hash / row-count
record is kept here.

## 3. Exact Acquired Files

| file | bytes | sha256 | total lines | data rows | unique `vehicle_id` | columns |
|---|---:|---|---:|---:|---:|---:|
| `train_operational_readouts.csv` | `1219209878` | `e01cb0bd87dfab4c9dbad215d51d81282fc0d413be96d6f819ea872fb7a3c715` | `1122453` | `1122452` | `23550` | `107` |
| `validation_operational_readouts.csv` | `215593159` | `1e1597eec866588c2ad95eb923555ad719c64b3697d9140f9cec6809349809af` | `196228` | `196227` | `5046` | `107` |
| `test_operational_readouts.csv` | `214897259` | `81f2709cd339e0ff561f5fd3188d7f431680e32400bd788814880d7759615ba1` | `198141` | `198140` | `5045` | `107` |

Observed header prefix in all three:

```text
vehicle_id,time_step,171_0,666_0,427_0,837_0,167_0,167_1,167_2,167_3,...
```

## 4. Consistency Check Against The Public Article

The exact acquired readout files match the structural counts described in the
Scientific Data article after removing the header row:

- train readouts: article `1,122,452`; exact file data rows `1,122,452`
- validation readouts: article `196,227`; exact file data rows `196,227`
- test readouts: article `198,140`; exact file data rows `198,140`

The unique repeated-unit counts also match the public split:

- train `23,550`
- validation `5,046`
- test `5,045`

This closes the large-readout identity question for the public bridge route.

## 5. What This Closes

This note closes the following gate from the bridge-package draft:

```text
full exact acquisition + sha256 of the three operational-readout CSV files
```

So the Scania bridge route is no longer blocked on large-file identity.

## 6. What Still Remains Open

This note does not yet close the Scania bridge package.

Remaining freeze-stage decisions still include:

1. lock the held-out `class_label` grammar explicitly;
2. choose one primary path only:
   - survival / TTE bridge, or
   - horizon-classification bridge;
3. freeze baseline family, feature family, model class, metric, and split
   policy.

## 7. Bottom Line

```text
The Scania public bridge route now has exact local acquisition of all three
large operational-readout files. The remaining work is no longer archive
identity; it is label-grammar lock plus bridge-package freeze design.
```
