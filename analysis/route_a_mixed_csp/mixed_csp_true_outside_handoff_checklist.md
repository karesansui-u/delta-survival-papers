# Mixed-CSP True Outside-Group Handoff Checklist

Status: final handoff checklist for a true outside-group rerun. This is not a
new empirical result and not validation evidence.

Date: 2026-04-27

Upstream package notes:

- `analysis/g7_mixed_csp_replication_package_plan.md`
- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_template.md`
- `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`

Purpose:

Provide the exact checklist to use when handing the frozen Mixed-CSP package to
an outside replicator who is not operating from the project side.

## 1. Package Identity

Package to hand off:

```text
Mixed-CSP frozen primary package as shipped in the current published handoff
bundle at send time. The first post-rename send-ready published baseline is
5088a71. The project-side published-remote rerun was exercised earlier from
commit 96de727, and the first send-ready outside-group checklist was
assembled at 4a74e76.
```

Important distinction:

```text
The outside-group rerun should clone the current published HEAD at handoff
time. Commit 5088a71 is the first post-rename send-ready published baseline.
Commit 96de727 is the earlier published-remote rehearsal commit, and 4a74e76
is the first commit where the final outside-group checklist itself was checked
in. None of these should be confused with an unpublished local draft.
```

## 2. Before-Send Checklist

Before sending the package, verify all of the following:

1. `origin/main` and `codeberg/main` both point to the same published commit.
2. `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
   exists and matches the published hash.
3. `analysis/route_a_mixed_csp/mixed_csp_results.json` exists and matches the
   published hash.
4. `analysis/route_a_mixed_csp/mixed_csp_results_summary.md` exists and
   matches the published hash.
5. `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md` contains
   separate-output commands, not official-artifact overwrites.
6. `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`
   confirms project-side published-remote reproducibility.
7. The package text still explicitly says:
   - already primary validated;
   - rerun is replication, not redesign;
   - observational branches sit below Route A in evidence tier.

## 3. Minimum Bundle To Send

Send the following files and nothing more unless requested:

1. `analysis/route_a_mixed_csp/README.md`
2. `analysis/route_a_mixed_csp/mixed_csp_preregistration.md`
3. `analysis/route_a_mixed_csp/run_mixed_csp.py`
4. `analysis/route_a_mixed_csp/analyze_mixed_csp.py`
5. `analysis/route_a_mixed_csp/mixed_csp_generator.py`
6. `analysis/route_a_mixed_csp/mixed_csp_solvers.py`
7. `analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py`
8. `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
9. `analysis/route_a_mixed_csp/mixed_csp_results.json`
10. `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`
11. `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
12. `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
13. `requirements.txt`
14. `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_template.md`

Optional context only:

1. `analysis/route_a_mixed_csp/mixed_csp_audit_replay_note.md`
2. `analysis/route_a_mixed_csp/mixed_csp_level2_rerun_note.md`
3. `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`
4. `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`

Do not send:

1. unrelated observational artifacts;
2. local rerun outputs;
3. Backblaze / C-MAPSS branches;
4. repository-wide exploratory memos unless the replicator asks for them.

## 4. Reference Hashes To Include In The Handoff

Official reference artifacts:

| File | sha256 |
|---|---|
| `mixed_csp_primary_official_2026-04-22.jsonl` | `bcc01d7ddf74a898119eab69ce34a8a38b9005db8a89d1eb6206da6d9158e01c` |
| `mixed_csp_results.json` | `1d49c63281eec9a78e1b2be1e4361fc4c657c1bf2edb31daa34dcef1762f8375` |
| `mixed_csp_results_summary.md` | `e67025d9995ce13eed93abf22ed484134563eeccc7fe29cd8405ad1be4391136` |

Published-remote project-side rerun artifacts:

| File | sha256 |
|---|---|
| `mixed_csp_primary_external.jsonl` | `c60603aa7e738785ae459dfc25c4cb9ca0da965dfc38cb9be13f1a871dd21817` |
| `mixed_csp_primary_external_results.json` | `6fb2c5f9ba6bc1290656612bddcfcdb81bf4547c0308ca2fe0da63d9b74f4735` |
| `mixed_csp_primary_external_summary.md` | `ef5d91b672b31975908be8abd549244e747bfedfdb684a998b239056dd13ee0d` |

## 5. Exact Outside-Group Request

Ask the outside group to do exactly this:

1. clone the published repository state;
2. install from `requirements.txt`;
3. write all outputs to a separate directory;
4. run smoke dry-run;
5. run smoke execution;
6. run encoding diagnostics;
7. run primary dry-run;
8. run primary execution;
9. run held-out analysis;
10. return:
    - output file hashes;
    - row counts;
    - support flags;
    - held-out log-loss summary;
    - any runtime anomaly notes.

## 6. Exact Return Bundle Requested From The Outside Group

Ask the outside group to return these artifacts:

1. rerun JSONL
2. rerun machine-readable results JSON
3. rerun human-readable summary MD
4. a short environment note including:
   - OS
   - Python version
   - solver / dependency versions if available
5. a one-paragraph statement of whether any local workaround was needed

## 7. Success Criterion

Count the outside-group rerun as successful if:

1. the frozen design is followed without redesign;
2. `L_plus_n < raw_plus_n`;
3. `first_moment < raw_plus_n`;
4. `L_plus_n <= cnf_count_plus_n`;
5. all four support flags still pass;
6. no new malformed-encoding or timeout pathology changes the interpretation.

Exact bitwise identity is welcome but not required.

## 8. What Should Not Be Treated As Failure

Do not classify the rerun as failed solely because of:

1. different timestamps;
2. runtime metadata differences;
3. small floating-point drift with unchanged ordering and unchanged support
   flags;
4. different JSON row ordering if the checked content is equivalent.

## 9. What Would Count As A Real Replication Failure

Escalate to a dedicated replication note if any of these happen:

1. `L_plus_n` no longer beats `raw_plus_n`;
2. `first_moment` no longer beats `raw_plus_n`;
3. `L_plus_n` loses to `cnf_count_plus_n`;
4. a new malformed-encoding pattern appears;
5. timeout / runtime instability materially changes interpretation.

## 10. Final One-Line Handoff Language

Use this wording in the actual handoff:

```text
This package is a rerun of an already validated Mixed-CSP primary. It is a
replication task, not a redesign task. Please use separate outputs, do not
overwrite the official artifacts, and report whether the qualitative support
decision is reproduced.
```
