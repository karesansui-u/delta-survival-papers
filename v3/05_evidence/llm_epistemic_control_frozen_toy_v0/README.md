LLM Epistemic-Control Frozen Toy v0
===================================

Status: frozen toy protocol; not validation evidence

Files:

- `freeze_manifest_v0.md`: frozen protocol and decision rule.
- `tasks.jsonl`: three synthetic task records.
- `smoke_result_summary.json`: deterministic scorer output for the frozen
  fields.
- `smoke_result_summary.md`: reader-facing summary of that scorer output.

This packet exists to show how the Lean benchmark protocol could be witnessed
by a small finite task surface. It is not a result summary and does not report
support. Outcome-bearing execution must be recorded separately.

Reproduce the toy scorer from the repository root:

```bash
python3 analysis/epistemic_control_frozen_toy_v0/run_eval.py \
  --tasks v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl \
  --out v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.json \
  --summary-md v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.md
```
