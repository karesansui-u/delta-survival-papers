# G7 True Outside-Group Handoff Overview

Status: coordination note for true outside-group reruns. Mixed-CSP now has a
completed requested outside-group set: `3/3` returned and `3/3` clean success.
Exp43c q-coloring now has three returned outside-group reruns: `3/3` returned
clean success.

Date: 2026-04-28

Purpose:

Summarize what has been handed to outside replicators, what has returned, and
what remains open.

Current published handoff baseline:

```text
Use the current published HEAD at send time, and state that exact commit hash
explicitly in the outbound message. Historical references remain useful only
for audit:
- 5088a71 = first post-rename send-ready baseline
- 55bef7f = first baseline that included the send/report templates
- 96de727 = earlier published-remote rehearsal
```

## 1. Current Route A G7 Position

The Route A handoff order was:

1. Mixed-CSP
2. Exp43c q-coloring
3. observational branches later, if needed

That order remains the correct historical rationale:

- Mixed-CSP is already primary validated and operationally simplest;
- Exp43c is already primary validated but has a richer threshold-local history;
- observational branches should not be the first external replication face of
  the program.

The current result is:

1. Mixed-CSP has completed the requested three-run outside-group set;
2. Exp43c has three returned outside-group rerun successes;
3. broader observational / non-CSP branches remain separate workstreams.

## 2. Current Preparation Level

Mixed-CSP currently has:

1. Level 1 audit replay;
2. Level 2 local fresh rerun;
3. external package note;
4. published-remote outside-workspace rerun;
5. final true outside-group handoff checklist;
6. three returned true outside-group rerun successes:
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`,
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`,
   and
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`;
7. a final outside-group report:
   `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`.

Exp43c currently has:

1. Level 2 local fresh rerun;
2. external package note;
3. published-remote outside-workspace rerun;
4. final true outside-group handoff checklist;
5. sender-side runbook, Japanese send packet, zip receiver guide, environment
   memo template, and return-report template;
6. three returned true outside-group rerun successes:
   `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`,
   `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`,
   and
   `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`;
7. a final package-level report:
   `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`;
8. a package-level Route A outside-replication summary:
   `analysis/g7_route_a_true_outside_replication_summary.md`.

## 3. What Still Counts As Open

The following remains open:

1. optional additional Exp43c outside-group returns, if more are later requested;
2. observational-branch replication;
3. non-CSP repair-flow / maintenance-log support;
4. outside-group environment notes and returned artifact hashes for future
   returns.

So:

```text
Route A now has outside-group success in two frozen packages: Mixed-CSP
completed 3/3 requested clean returns, and Exp43c q-coloring has three clean
returned outside-group reruns. This strengthens G7 for Route A, but does not
close observational, non-CSP, or universal-law replication.
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
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`

For Exp43c, use:

- `analysis/exp43_qcoloring/exp43c_external_rerun_package.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_handoff_checklist.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_send_runbook.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_send_packet_ja.md`
- `analysis/exp43_qcoloring/exp43c_zip_receiver_guide_ja.md`
- `analysis/exp43_qcoloring/exp43c_execution_environment_note_template_ja.md`
- `analysis/exp43_qcoloring/exp43c_g7_replication_report_template.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`
- `analysis/g7_route_a_true_outside_replication_summary.md`
- `analysis/exp43_qcoloring/handoff_exports/LOCKED_BUNDLE_NOTE.md`
- `analysis/exp43_qcoloring/handoff_exports/依頼文.md`
- `analysis/exp43_qcoloring/handoff_exports/返信が来たらやること.md`

## 5. Recommended Immediate Next Move

The next clean move is:

```text
keep the Mixed-CSP and Exp43c outside-group reports scoped to their packages;
then move to the next external-facing workstream or independent review
```

This preserves the current distinction: Route A outside-group reproducibility
has become materially stronger, while the broader program still needs
observational / non-CSP replication and independent review.
