LLM Epistemic Premise Update v0
===============================

Status: frozen task surface; not validation evidence

Files:

- `freeze_manifest_v0.md`: frozen protocol surface and decision rule.
- `tasks.jsonl`: 12 public-safe synthetic premise-update cases.
- `output_collection_protocol_v0.md`: output collection rule for future
  baseline / controlled outputs.
- `run_manifest_result_001.md`: fixed model / prompt / runtime condition for
  the first output-bearing run.
- `premise_update_outputs_template_result_001.jsonl`: generated raw-output
  template for `result_001`.
- `collection_attempt_result_001_timeout_qwen35_9b.md`: audit note for an
  aborted qwen3.5:9b collection attempt that emitted no result artifact.
- `premise_update_outputs_result_001.jsonl`: raw baseline / controlled outputs
  for the first completed run.
- `premise_update_output_collection_result_001.json`: collection metadata for
  the first completed run.
- `llm_epistemic_premise_update_v0_result_001.json`: scored result artifact.
- `llm_epistemic_premise_update_v0_result_001.md`: reader-facing scored result
  summary.
- `result_001_certificate_mapping.md`: theorem-side certificate mapping note.

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
analysis/epistemic_control_premise_update_v0/make_output_template.py
analysis/epistemic_control_premise_update_v0/collect_with_ollama.py
analysis/epistemic_control_premise_update_v0/run_eval.py
analysis/epistemic_control_premise_update_v0/results_schema.json
```

The runner reads `tasks.jsonl`, verifies the digest, scores externally supplied
baseline and controlled outputs with the frozen stale / updated / safe-unknown
markers, and emits a result certificate compatible with the epistemic benchmark
protocol chain. No outcome-bearing result artifact is included in this folder.

Result 001 status:

```text
decision = silence
protocol_shape_valid = false
```

The raw outputs are retained. The result is not support evidence because one
case did not map to the frozen marker readout.
