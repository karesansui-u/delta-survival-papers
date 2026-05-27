LLM Epistemic Premise Update v0 Runner
======================================

Status: scorer / schema for a frozen task surface; not validation evidence

Files:

- `make_output_template.py`: emits a JSONL template for raw output collection.
- `run_eval.py`: model-free scorer for externally supplied baseline and
  controlled outputs.
- `results_schema.json`: JSON schema for the emitted result artifact.

The scorer reads the frozen task surface at:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/tasks.jsonl
```

It requires a separate outputs JSONL file. Each row must contain:

```json
{
  "case_id": "pu_001_office_relocation_station",
  "horizon": 1,
  "baseline_condition": "ordinary_readout_without_dependency_refresh",
  "controlled_condition": "dependency_aware_premise_refresh",
  "readout_alignment": "premise_update_stale_loss_repair_v0",
  "baseline_output": "... raw baseline answer ...",
  "controlled_output": "... raw controlled answer ..."
}
```

Create a collection template from the frozen task surface:

```bash
python3 analysis/epistemic_control_premise_update_v0/make_output_template.py \
  --out /tmp/premise_update_outputs_template.jsonl
```

Run from the repository root:

```bash
python3 analysis/epistemic_control_premise_update_v0/run_eval.py \
  --outputs path/to/premise_update_outputs.jsonl \
  --out path/to/result.json \
  --summary-md path/to/result.md
```

The scorer:

- verifies the frozen task digest;
- checks one output row per frozen case;
- preserves raw baseline and controlled outputs in the result artifact;
- scores stale-only answers as loss;
- scores updated-premise or safe-unknown answers as repair;
- emits `support`, `no_support`, `invalid_run`, or `silence`.

Claim boundary:

```text
This runner does not call a model, validate benchmark semantics, or prove real
LLM performance. It only implements the predeclared marker readout for the
frozen premise-update task surface.
```
