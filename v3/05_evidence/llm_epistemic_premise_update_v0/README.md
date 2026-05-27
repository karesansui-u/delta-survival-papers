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

Next implementation step:

```text
analysis/epistemic_control_premise_update_v0/run_eval.py
```

The future runner should read `tasks.jsonl`, verify the digest, score baseline
and controlled outputs with the frozen stale / updated / safe-unknown markers,
and emit a result certificate compatible with the epistemic benchmark protocol
chain.
