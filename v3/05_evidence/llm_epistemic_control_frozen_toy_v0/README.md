LLM Epistemic-Control Frozen Toy v0
===================================

Status: frozen toy protocol; not validation evidence

Files:

- `freeze_manifest_v0.md`: frozen protocol and decision rule.
- `tasks.jsonl`: three synthetic task records.
- `smoke_result_summary.json`: deterministic scorer output for the frozen
  fields.
- `smoke_result_summary.md`: reader-facing summary of that scorer output.
- `llm_epistemic_control_frozen_toy_v0_result_001.json`: first named
  deterministic result artifact for this frozen toy packet.
- `llm_epistemic_control_frozen_toy_v0_result_001.md`: reader-facing summary
  of that named result artifact.

This packet exists to show how the Lean benchmark protocol could be witnessed
by a small finite task surface. The named result artifact exercises the
deterministic certificate loop for the toy packet only. It is not validation
evidence for a real model or workflow.

Reproduce the toy scorer from the repository root:

```bash
python3 analysis/epistemic_control_frozen_toy_v0/run_eval.py \
  --result-id llm_epistemic_control_frozen_toy_v0_smoke \
  --tasks v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl \
  --out v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.json \
  --summary-md v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.md
```

Regenerate the named result artifact:

```bash
python3 analysis/epistemic_control_frozen_toy_v0/run_eval.py \
  --result-id llm_epistemic_control_frozen_toy_v0_result_001 \
  --tasks v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl \
  --out v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.json \
  --summary-md v3/05_evidence/llm_epistemic_control_frozen_toy_v0/llm_epistemic_control_frozen_toy_v0_result_001.md
```
