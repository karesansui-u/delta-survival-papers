# Exp.42 — Scope-Strength Dose Response

Status: frozen before data collection.

Exp.42 is the main follow-up to Exp.40. It directly addresses the objection
that Exp.40 merely instructed the model to ignore the conflicting value.

The design varies scope strength:

```text
strong_scope > medium_scope > weak_scope ≈ subtle
```

Planned files:

| File | Purpose |
|---|---|
| `exp42_preregistration.md` | Frozen design, predictions, exclusions |
| `exp42_scope_gradient.py` | Append-safe runner, summarizer, and model comparison |
| `exp42_<model>_results_summary.md` | Human-readable result table |
| `exp42_<model>_model_comparison.json` | Machine-readable baseline comparison |
| `exp42_<model>_model_comparison.md` | Human-readable baseline comparison |

## Usage

Dry run, primary cells only:

```bash
python3 analysis/exp42/exp42_scope_gradient.py dry-run
```

Dry run with optional diagnostics:

```bash
python3 analysis/exp42/exp42_scope_gradient.py dry-run --include-diagnostics
```

Paid API execution, primary cells only:

```bash
python3 analysis/exp42/exp42_scope_gradient.py run --execute
```

Paid API execution with optional diagnostics:

```bash
python3 analysis/exp42/exp42_scope_gradient.py run --execute --include-diagnostics
```

Summarize completed trials:

```bash
python3 analysis/exp42/exp42_scope_gradient.py summarize
```

Run the preregistered leave-one-target-out model comparison:

```bash
python3 analysis/exp42/exp42_scope_gradient.py compare
```

The runner refuses paid API calls unless `--execute` is passed.
