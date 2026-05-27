LLM Epistemic Premise Update v1
===============================

Status: successor frozen readout package; not validation evidence before an
outcome-bearing result

This packet is a v1 redesign after the v0 result recorded protocol-local
`silence`. It does not modify, reinterpret, or retrospectively rescue v0.

The v1 change is limited to the external witness/readout layer:

- the task surface uses `readout_alignment = premise_update_slot_state_v1`;
- concept hits, stale-current stance hits, updated-current stance hits,
  safe-unknown hits, historical / negation / invalidation scope hits are
  frozen before outcome-bearing execution;
- ambiguous and mixed outputs are first-class outcomes;
- every raw output row records an explicit generation status;
- only `decision = support_clean` with `promotable = true` is a candidate Lean
  benchmark-result certificate witness.

Files:

- `tasks.jsonl`: frozen v1 task/readout surface.
- `premise_update_outputs_template_result_001.jsonl`: generated raw-output
  collection template for the planned first v1 run.
- `design_review_v1.md`: disposition of the independent review findings that
  shaped the v1 redesign.
- `freeze_manifest_v1.md`: manifest, digest table, decision boundary.
- `output_collection_protocol_v1.md`: raw-output collection protocol.
- `run_manifest_result_001.md`: pre-run manifest template for the first v1
  outcome-bearing run. It is not model output.
- `result_001_certificate_mapping.md`: placeholder mapping note to be completed
  only after a v1 result artifact exists.
- `../../../analysis/epistemic_control_premise_update_v1/run_eval.py`: v1
  deterministic scorer.
- `../../../analysis/epistemic_control_premise_update_v1/run_preflight.py`:
  scorer preflight runner.
- `../../../analysis/epistemic_control_premise_update_v1/preflight_cases.jsonl`:
  frozen synthetic coverage tests.
- `../../../analysis/epistemic_control_premise_update_v1/results_schema.json`:
  result JSON schema.

Boundary:

V1 is not a theorem upgrade. The Lean layer is unchanged: if a future frozen
protocol and result certificate supply the required witnesses, the existing
benchmark-protocol and coherent-mass comparison theorems apply. V1 only
specifies a stronger external readout package for producing those witnesses.
