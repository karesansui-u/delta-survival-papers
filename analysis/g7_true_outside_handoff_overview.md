# G7 True Outside-Group Handoff Overview

Status: coordination note for the next true outside-group reruns. This is not
an empirical result and not validation evidence.

Date: 2026-04-27

Purpose:

Summarize what is now ready to hand to an outside replicator, and in what
order.

Current published handoff baseline:

```text
Use the current published HEAD at send time. The first post-rename
send-ready baseline is 5088a71. Earlier project-side published-remote rerun
rehearsals were exercised from 96de727.
```

## 1. Current Ready-To-Handoff Order

The Route A handoff order remains:

1. Mixed-CSP
2. Exp43c q-coloring
3. observational branches later, if needed

Reason:

- Mixed-CSP is already primary validated and operationally simplest;
- Exp43c is already primary validated but has a richer threshold-local history;
- observational branches should not be the first external replication face of
  the program.

## 2. Current Preparation Level

Mixed-CSP currently has:

1. Level 1 audit replay;
2. Level 2 local fresh rerun;
3. external package note;
4. published-remote outside-workspace rerun;
5. final true outside-group handoff checklist.

Exp43c currently has:

1. Level 2 local fresh rerun;
2. external package note;
3. published-remote outside-workspace rerun;
4. final true outside-group handoff checklist.

## 3. What Still Counts As Open

The following remains open:

1. a rerun initiated and executed by an actual outside group;
2. outside-group environment note and returned artifact hashes;
3. a final G7 replication report interpreting the returned rerun.

So:

```text
project-side reproducibility is now strong,
but G7 is not closed until a true outside-group rerun lands
```

## 4. Handoff Files

For Mixed-CSP, use:

- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_template.md`
- `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`

For Exp43c, use:

- `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`

## 5. Recommended Immediate Next Move

The next clean move is:

```text
send the Mixed-CSP handoff first, wait for outside-group rerun outcome, then
send the Exp43c handoff second
```

This keeps the first G7 face of the program on the most deterministic Route A
package.
