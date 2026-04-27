# G7 True Outside-Group Handoff Overview

Status: coordination note for true outside-group reruns. Mixed-CSP now has an
interim returned-run layer: `1/3` requested reruns completed, `1/1` clean
success, `2` pending.

Date: 2026-04-27

Purpose:

Summarize what is now ready to hand to an outside replicator, and in what
order.

Current published handoff baseline:

```text
Use the current published HEAD at send time, and state that exact commit hash
explicitly in the outbound message. Historical references remain useful only
for audit:
- 5088a71 = first post-rename send-ready baseline
- 55bef7f = first baseline that included the send/report templates
- 96de727 = earlier published-remote rehearsal
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
5. final true outside-group handoff checklist;
6. one returned true outside-group rerun success:
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`;
7. an interim outside-group report:
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_interim_report.md`.

Exp43c currently has:

1. Level 2 local fresh rerun;
2. external package note;
3. published-remote outside-workspace rerun;
4. final true outside-group handoff checklist;
5. sender-side runbook, Japanese send packet, zip receiver guide, environment
   memo template, and return-report template.

## 3. What Still Counts As Open

The following remains open:

1. two pending requested Mixed-CSP outside-group returns;
2. a final Mixed-CSP G7 replication report after the requested returns resolve;
3. Exp43c true outside-group rerun return;
4. outside-group environment notes and returned artifact hashes for future
   returns.

So:

```text
project-side reproducibility is now strong, and Mixed-CSP has one clean returned
outside-group rerun; G7 is not closed until the requested Mixed-CSP returns are
resolved and Exp43c outside-group rerun is addressed
```

## 4. Handoff Files

For Mixed-CSP, use:

- `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_template.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_runbook.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_packet_ja.md`
- `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_interim_report.md`

For Exp43c, use:

- `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`
- `analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md`
- `analysis/exp43_qcoloring/exp43c_execution_environment_note_template_ja.md`
- `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`

## 5. Recommended Immediate Next Move

The next clean move is:

```text
send the Exp43c outside-group zip packet while absorbing the two pending
Mixed-CSP outside-group returns when they land
```

This avoids idle waiting while preserving the first G7 face of the program on
the most deterministic Route A package.
