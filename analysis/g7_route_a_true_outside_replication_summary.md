# Route A True Outside-Group Replication Summary

Status: package-scoped G7 summary after returned outside-group reruns for the
two frozen Route A empirical packages.

Date: 2026-04-28

## 1. Summary

Route A now has returned outside-group rerun success for two frozen empirical
packages:

| Package | Returned runs | Clean successes | Primary rows per run | Checked core mismatches | Qualitative decision |
|---|---:|---:|---:|---:|---|
| Mixed-CSP | `3` | `3` | `12000` | `0` in each returned run | reproduced support flags |
| Exp43c q-coloring | `3` | `3` | `4000` | `0` in each returned run | reproduced support decision |

This is a package-level replication layer. It shows that frozen Route A
artifacts can be executed outside the author environment and recover the same
decision-relevant outputs. It does not by itself establish a universal law,
non-CSP support, or observational-branch causal evidence.

## 2. Mixed-CSP Returned Set

Returned run notes:

| Runner | Note | Result |
|---|---|---|
| `katsumasa1234` | `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md` | clean success |
| `SCRAPRO` | `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md` | clean success |
| `philia_channel` | `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md` | clean success |

Final report:

```text
analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md
```

Decision-relevant checks:

```text
requested returned runs = 3
completed returned runs = 3
clean successes = 3
primary rows per returned run = 12000
checked core mismatches = 0 in each returned run
support flags = reproduced in each returned run
reported workaround = none
```

## 3. Exp43c Q-Coloring Returned Set

Returned run notes:

| Runner | Note | Result |
|---|---|---|
| `philia_channel` | `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md` | clean success |
| `katsumasa1234` | `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md` | clean success |
| `SCRAPRO` | `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md` | clean success |

Final report:

```text
analysis/exp43_qcoloring/exp43c_true_outside_final_report.md
```

Decision-relevant checks:

```text
returned runs = 3
clean successes = 3
primary rows per returned run = 4000
checked core mismatches = 0 in each returned run
TIMEOUT = 0 in each returned run
MALFORMED = 0 in each returned run
qualitative support decision = reproduced in each returned run
reported workaround = none
```

The Exp43c returned runs include two Windows/cmd runs and one WSL/Ubuntu run.
The Windows runs differ from the official manifest bytes because of newline
serialization, but their parsed JSON manifest rows match the official manifest
exactly.

## 4. Claim Boundary

This summary supports the following narrow claim:

```text
Two frozen Route A empirical packages have been rerun outside the author
environment by three returned outside runners each, with decision-relevant
outputs reproduced.
```

It does not claim:

- independent theoretical endorsement of structural persistence theory;
- non-CSP repair-flow support;
- Route C causal proof;
- universal-law closure;
- that future Route A families must pass.

The current position is therefore strong but scoped: Route A package
reproducibility is now materially better than a local rerun or a published
remote fresh-clone rehearsal, while the broader research program still depends
on additional domains, negative-evidence tracking, and future independent
review.
