# Oxford Path Dependent Parser Smoke Plan

Status: pre-freeze parser-smoke plan. Not validation evidence, not a freeze
manifest, and not an M/SP feature definition.

Date: 2026-04-28

## 1. Purpose

The Oxford Path Dependent branch should not jump from public web feasibility to
primary validation. The next clean step is a parser smoke that records archive
identity and verifies that the data can be read without inspecting held-out
outcomes or tuning features.

The parser smoke asks only:

```text
Can the public files be acquired, hashed, listed, and minimally parsed in a
way that supports a later frozen battery M-profile design?
```

## 2. Local Data Layout

Place acquired files under:

```text
analysis/g4_battery_m_profile/data/oxford_path_dependent/
```

Either a flat layout or a split layout is acceptable:

```text
part1/
part2/
part3/
```

The `data/` directory is git-ignored. Only manifests and notes should be
checked in.

## 3. Smoke Script

Script:

```text
analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py
```

Manifest-only command:

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output analysis/g4_battery_m_profile/replication_outputs/oxford_manifest_smoke.json \
  --manifest-only
```

Legacy `.mat` structure smoke:

After the fixed train/test split, this mode must not be rerun as new evidence
because it can open cells that are now held out. It is retained only for
historical reproduction of the pre-split schema-smoke layer and now requires
an explicit legacy acknowledgement flag.

```bash
python3 analysis/g4_battery_m_profile/scripts/inspect_oxford_path_dependent.py \
  --root analysis/g4_battery_m_profile/data/oxford_path_dependent \
  --output analysis/g4_battery_m_profile/replication_outputs/oxford_mat_smoke.json \
  --inspect-mat \
  --allow-legacy-presplit-mat-smoke \
  --max-mat-files 3 \
  --max-mat-files-per-zip 0 \
  --max-mat-bytes 26214400
```

The `.mat` smoke may require `scipy`. The byte cap is intentional: the smoke
must stay bounded even when a large or malformed group archive is present.

## 4. Allowed Outputs

Allowed parser-smoke outputs:

- file presence / absence;
- byte counts;
- SHA256 hashes;
- zip entry counts;
- `.mat` entry counts;
- top-level `.mat` keys and array shapes for a tiny sample.
- bounded parser statuses such as `inspected`, `skipped_too_large`, or `error`.
- run-level parser limits such as `max_mat_files` and `max_mat_bytes`.
- optional per-zip parser limits such as `max_mat_files_per_zip`.

Disallowed before freeze:

- future capacity prediction metrics;
- baseline comparison;
- support flags;
- feature selection based on outcome performance;
- recovery definitions based on post-cutoff improvement;
- held-out group/cell performance inspection.

## 5. Pass Criteria

The parser smoke passes only if:

1. acquired files have stable hashes recorded;
2. the expected guide/readme/group archives can be located;
3. zip files can be opened without archive errors;
4. `.mat` files can be minimally inspected, or a clear dependency/parser issue
   is documented;
5. no outcome-driven M/SP feature choice is made during the smoke.

If these criteria fail, Oxford remains a feasibility-only branch and the next
candidate should be NASA Randomized/Recommissioned.

## 6. Next Decision After Parser Smoke

After parser smoke, choose one of three paths:

```text
promote Oxford to freeze design
demote Oxford to feasibility-only and test NASA
use Oxford only as parser/feature-extraction infrastructure
```

No primary validation should be run until a freeze manifest fixes:

- units;
- split;
- endpoint;
- prediction horizon;
- baseline ladder;
- M_buffer / M_recovery / M_reconfiguration feature definitions;
- metric;
- no-support and weak-support criteria.
