# Mixed-CSP True Outside-Group Send Template

Status: send template for an actual outside-group rerun request. This is not
an empirical result and not validation evidence.

Use this only after the final handoff checklist has been verified.

## 1. Short Email / Message Version

```text
Subject: Outside-group rerun request for frozen Mixed-CSP primary package

Hello,

I am sending a frozen rerun package for an already validated Mixed-CSP primary
result. This is a replication request, not a redesign request.

Please clone the current published repository HEAD at commit
`<SEND_COMMIT_HASH>`, install from requirements.txt, and run the Mixed-CSP
package using separate outputs only. Please do not overwrite the official
artifacts.

The exact package instructions are:
- analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md
- analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md

What we are asking you to report back:
- rerun output hashes
- row counts
- support flags
- held-out log-loss summary
- any runtime anomaly notes
- a short environment note

Official reference artifacts attached / included:
- mixed_csp_primary_official_2026-04-22.jsonl
- mixed_csp_results.json
- mixed_csp_results_summary.md

The qualitative question is simply whether the already validated support
decision reproduces under your environment.

Thank you.
```

## 2. Longer Cover Note

```text
This package corresponds to an already validated Mixed-CSP Route A primary at
published commit `<SEND_COMMIT_HASH>`.
Project-side reproducibility is already strong: we have an internal Level 1
audit replay, a separate-output Level 2 fresh rerun, a fresh-clone rehearsal,
and a rerun from a fresh clone of the published remote. What remains open is a
true outside-group rerun.

This request is therefore not asking for redesign, tuning, or alternate model
selection. It is asking whether the frozen package reproduces its qualitative
support decision outside the project side.

Please follow the published package as-is. If any workaround is required,
record it explicitly in the return note.
```

## 3. Attach / Include Checklist

When sending, attach or point to:

1. `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
2. `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
3. official reference artifacts listed in that checklist
4. `requirements.txt`

Optional:

1. `analysis/route_a_mixed_csp/mixed_csp_published_remote_rerun_note.md`
2. `analysis/g7_true_outside_handoff_overview.md`

## 4. One-Sentence Verbal Framing

If this is sent in a shorter human conversation, use:

```text
Could you rerun this frozen Mixed-CSP primary package from the published repo
state and tell us whether the qualitative support decision reproduces in your
environment?
```
