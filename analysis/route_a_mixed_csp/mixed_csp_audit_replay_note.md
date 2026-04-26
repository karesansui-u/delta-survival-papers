# Mixed-CSP Audit Replay Note

Status: G7 Level 1 audit replay only. Not a fresh rerun. Not new validation
evidence.

Date: 2026-04-27

Upstream planning note:

- `analysis/g7_mixed_csp_replication_package_plan.md`

Purpose:

Carry out the first concrete G7 action for Mixed-CSP:

```text
confirm that the official frozen artifacts are self-consistent and that the
checked-in analyzer reproduces the checked-in official summary from the
official primary JSONL
```

This is an audit replay of the official package, not a fresh regeneration of
instances or solver rows.

## 1. Official Artifacts Checked

Files inspected:

- `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
- `analysis/route_a_mixed_csp/mixed_csp_results.json`
- `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`
- `analysis/route_a_mixed_csp/README.md`
- `analysis/route_a_mixed_csp/mixed_csp_preregistration.md`
- `analysis/route_a_mixed_csp/analyze_mixed_csp.py`

Observed artifact hashes:

| File | sha256 |
|---|---|
| `mixed_csp_primary_official_2026-04-22.jsonl` | `bcc01d7ddf74a898119eab69ce34a8a38b9005db8a89d1eb6206da6d9158e01c` |
| `mixed_csp_results.json` | `1d49c63281eec9a78e1b2be1e4361fc4c657c1bf2edb31daa34dcef1762f8375` |
| `mixed_csp_results_summary.md` | `e67025d9995ce13eed93abf22ed484134563eeccc7fe29cd8405ad1be4391136` |

Observed official row count:

```text
12000
```

## 2. Audit-Replay Command

The audit replay used the analyzer directly on the official frozen JSONL:

```bash
python3 analysis/route_a_mixed_csp/analyze_mixed_csp.py \
  --input analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl \
  analyze
```

Important handling note:

```text
the analyzer rewrites generated_at timestamps in the checked-in summary files
```

Those timestamps were restored to the official 2026-04-22 values after the
replay so that the official artifact identity remains unchanged.

## 3. Replay Result

The replay reproduced the official checked-in values:

| Metric | Replayed value | Official target |
|---|---:|---:|
| rows total | `12000` | `12000` |
| eligible primary rows | `12000` | `12000` |
| `L_plus_n` log loss | `0.09701224545154162` | `0.0970` |
| `raw_plus_n` log loss | `0.7524844242572775` | `0.7525` |
| `first_moment` log loss | `0.14891645806196216` | `0.1489` |
| `cnf_count_plus_n` log loss | `0.10101906308115063` | `0.1010` |
| relative improvement vs `raw_plus_n` | `0.8710774039644803` | `0.8710774039644803` |

Support flags reproduced:

```json
{
  "primary_supported": true,
  "strong_support": true,
  "theory_pure_support": true,
  "encoding_guardrail_passed": true
}
```

Cell-level consistency also matched the checked-in summary:

- no timeout-flagged primary cells;
- zero malformed rows in the official primary;
- row total and model ordering unchanged.

## 4. Interpretation

This replay establishes:

```text
the official Mixed-CSP primary package is internally coherent at the
artifact-analysis level
```

It does not yet establish:

```text
independent fresh regeneration of the official rows on a new machine
```

So the G7 status becomes:

- Level 1 audit replay: complete
- Level 2 fresh full rerun: still open

## 5. Next Action

The next clean Mixed-CSP replication step is the Level 2 fresh rerun described
in `analysis/g7_mixed_csp_replication_package_plan.md`:

1. smoke dry-run;
2. smoke execution;
3. encoding diagnostics;
4. primary dry-run;
5. primary rerun from scratch;
6. held-out reanalysis and comparison to the official reference.

Until then, Mixed-CSP should be described as:

```text
validated primary with a completed audit replay, but not yet independently
rerun from scratch under the G7 workstream
```
