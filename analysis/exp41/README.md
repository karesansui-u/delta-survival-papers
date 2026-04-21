# Exp.41 — Cross-Model Width Replication

Status: frozen before data collection.

Exp.41 is a low-cost width check after Exp.40. It repeats the most diagnostic
conditions across additional models:

```text
scoped / subtle / structural
```

The primary claim is deliberately narrow:

```text
accuracy(scoped) > accuracy(structural)
```

The secondary ordered diagnostic is:

```text
accuracy(scoped) >= accuracy(subtle) >= accuracy(structural)
```

`subtle` is treated as model-sensitive. A model that is insensitive to subtle
contradiction can fail the secondary ordering without falsifying the primary
width prediction.

Implemented files:

| File | Purpose |
|---|---|
| `exp41_preregistration.md` | Frozen design, predictions, exclusions |
| `exp41_width_replication.py` | Append-safe runner adapted from Exp.40 |
| `exp41_results_summary.md` | Human-readable result table, generated after execution |
| `exp41_summary.json` | Machine-readable primary / secondary decision summary |
| `exp41_model_comparison.json` | Machine-readable descriptive baseline-model comparison |

Dry-run:

```bash
python3 analysis/exp41/exp41_width_replication.py --include-diagnostic dry-run
```

Primary run with zero-sanity diagnostics:

```bash
python3 analysis/exp41/exp41_width_replication.py --include-diagnostic run --execute
python3 analysis/exp41/exp41_width_replication.py --include-diagnostic summarize
python3 analysis/exp41/exp41_width_replication.py --include-diagnostic compare
```

To include the `gpt-4.1-mini` positive control, add
`--include-positive-control` before the subcommand. The positive control is
reported separately and does not rescue the preregistered 2/2 primary width
decision.
