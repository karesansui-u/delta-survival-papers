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

Planned files:

| File | Purpose |
|---|---|
| `exp41_preregistration.md` | Frozen design, predictions, exclusions |
| `exp41_width_replication.py` | Future append-safe runner, likely adapted from Exp.40 |
| `exp41_results_summary.md` | Future human-readable result table |
| `exp41_model_comparison.json` | Future machine-readable model-level outcomes |
