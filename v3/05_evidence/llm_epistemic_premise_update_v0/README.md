LLM Epistemic Premise Update v0
===============================

Status: frozen task surface; not validation evidence

Files:

- `freeze_manifest_v0.md`: frozen protocol surface and decision rule.
- `tasks.jsonl`: 12 public-safe synthetic premise-update cases.

This packet freezes the first real-eval candidate task surface for the
epistemic-control benchmark protocol. It contains no model outputs and no
support decision. Outcome-bearing execution must be recorded in a separate
result artifact.

Current task digest:

```text
f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204
```

Scorer / schema:

```text
analysis/epistemic_control_premise_update_v0/run_eval.py
analysis/epistemic_control_premise_update_v0/results_schema.json
```

The runner reads `tasks.jsonl`, verifies the digest, scores externally supplied
baseline and controlled outputs with the frozen stale / updated / safe-unknown
markers, and emits a result certificate compatible with the epistemic benchmark
protocol chain. No outcome-bearing result artifact is included in this folder.
