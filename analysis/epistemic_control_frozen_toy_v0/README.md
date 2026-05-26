Epistemic-Control Frozen Toy v0 Runner
======================================

Status: deterministic protocol-shape runner; not validation evidence

This directory contains the minimal runner for the frozen toy packet in:

- `../../v3/05_evidence/llm_epistemic_control_frozen_toy_v0/`

The runner does not call an LLM and does not validate real model performance.
It reads the frozen `tasks.jsonl` file, checks the v0 task surface and readout
fields, computes aggregate loss / repair dominance, and emits a JSON result
matching `results_schema.json`.


Run
---

From the repository root:

```bash
python3 analysis/epistemic_control_frozen_toy_v0/run_eval.py \
  --tasks v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl \
  --out v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.json \
  --summary-md v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.md
```


Interpretation
--------------

The output can say whether the toy packet has the expected protocol shape:

- frozen task surface matches the v0 case ids;
- metric arrays match the frozen horizon;
- aggregate loss / repair dominance holds;
- the toy readout-alignment label is present;
- controlled net action is no worse than baseline net action under the toy
  readout.

This is a toy scoring certificate for a frozen protocol packet. It is not a
proof of LLM semantics, model performance, memory safety, or workflow
correctness.


Files
-----

- `run_eval.py`: deterministic stdlib-only scorer.
- `results_schema.json`: JSON schema for the scorer output.
