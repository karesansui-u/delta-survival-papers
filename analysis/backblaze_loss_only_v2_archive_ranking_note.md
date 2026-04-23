# Backblaze Loss-Only v2 Archive Ranking Note

Status: metadata-only archive ranking note. Not a preregistration, not a
freeze package, not a validation run, and not predictor-performance evidence.

Date: 2026-04-24

Upstream design boundary:

- `analysis/backblaze_loss_only_v2_exploration_note.md`

## 1. Purpose

This note selects the next Backblaze archive candidate for a possible
Backblaze v2 loss-only retry using metadata-only criteria.

It does not inspect:

- model performance;
- SMART predictive strength;
- failure rates by predictor;
- calibration quality;
- train / validation / test metrics.

It only records archive-level facts needed to choose the next untouched
quarter before any v2 preregistration or modeling work.

## 2. Fixed Boundary From v1

Backblaze Q4 2025 is excluded from ranking:

```text
reason: already consumed by the frozen v1 primary validation
status: closed no-support result
```

Therefore the archive ranking for v2 must start from untouched quarters only.

## 3. Archive Selection Rule

The ranking rule comes from the v2 exploration note:

1. prefer the nearest forward untouched quarter after Q4 2025 if publicly
   available;
2. otherwise prefer the nearest earlier untouched quarter with compatible
   schema and feasible archive size;
3. continue backward by quarter if needed.

Ranking inputs are restricted to metadata-only facts:

- official public availability;
- archive URL;
- nominal quarter / date span;
- download size or `Content-Length`;
- expected schema compatibility with the current Backblaze Drive Stats format;
- operational feasibility in the current environment.

## 4. Official Availability Check

Official Backblaze dataset page checked on 2026-04-24:

- <https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data>

Observed public quarterly archives on that page extend through:

```text
Q4 2025
```

Therefore:

```text
no forward untouched quarter after Q4 2025 was publicly available from the
official page at the time of this ranking note
```

This means the ranking falls back to the nearest earlier untouched compatible
quarter.

## 5. Candidate Archive Table

| Rank | Archive | URL | Content-Length | Metadata-only reasoning |
|---|---|---|---:|---|
| 1 | `data_Q3_2025.zip` | `https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2025.zip` | `1,111,587,745` | nearest earlier untouched quarter; same 2025 schema family as Q4 2025; large enough to be operationally comparable without reusing the consumed archive |
| 2 | `data_Q2_2025.zip` | `https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2025.zip` | `1,067,562,257` | next earlier untouched quarter; likely same quarterly schema family; slightly smaller operational footprint |
| 3 | `data_Q1_2025.zip` | `https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2025.zip` | `1,020,483,699` | third fallback if Q3/Q2 fail schema or feasibility checks |

Notes:

- `Content-Length` was checked by `HEAD` request only.
- `Last-Modified` / `ETag` were not returned by the file host for these
  requests.
- exact SHA256 values are intentionally **not** recorded yet because no v2
  archive has been downloaded or frozen.
- exact per-column compatibility is also intentionally deferred to a later
  feasibility check on the selected archive.

## 6. Why Q3 2025 Ranks First

Q3 2025 is ranked first for v2 because:

1. it is the nearest earlier untouched quarter after the consumed Q4 2025
   archive;
2. it remains within the same 2025 Backblaze Drive Stats family;
3. its size is close enough to Q4 2025 to make operational comparison fair
   without requiring a new domain;
4. this ranking does not use any predictor-level or outcome-level performance
   information.

This is a metadata-only choice, not a performance-based choice.

## 7. What This Note Does Not Decide

This note does not decide:

1. whether Backblaze v2 will use Platt scaling, class-weight changes, or
   another calibration-aware design;
2. whether `smart_199_raw` will be excluded;
3. the final horizon or split;
4. the final model family;
5. whether Q3 2025 is fully eligible after schema and feasibility inspection.

Those decisions belong to:

- a later archive feasibility note for the selected quarter; and
- a separate Backblaze v2 preregistration / freeze process.

## 8. Current Decision

The current metadata-only ranking decision is:

```text
primary v2 archive candidate: data_Q3_2025.zip
fallback candidate 1:        data_Q2_2025.zip
fallback candidate 2:        data_Q1_2025.zip
```

The next clean step is:

```text
run a schema / feasibility check on Q3 2025 only, without any predictor-level
inspection, and stop if the archive is ineligible
```
