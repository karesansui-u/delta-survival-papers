LLM Epistemic Premise Update v0 Score Summary
================================================

Status: marker-based protocol score; not model validation by itself

artifact_type: `premise_update_protocol_result`
protocol_id: `llm_epistemic_premise_update_v0`
result_id: `llm_epistemic_premise_update_v0_result_001`
runner_version: `0.1.0`
decision: `silence`
tasks_sha256: `f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204`
outputs_sha256: `a9ca07d8f9c07055cd7576619dfd53ff9a3c9349b9b9733c20844f653985f51c`

Checks
------

- frozen_task_surface: `true`
- task_surface_digest_matches: `true`
- frozen_readout: `true`
- same_horizon: `true`
- outputs_complete: `true`
- raw_outputs_retained: `true`
- metric_dominance: `true`
- readout_alignment: `true`
- no_worse_net_action: `true`
- silence: `true`
- silence_cases: `["pu_005_allergy_update_menu"]`
- invalid_run: `false`
- protocol_shape_valid: `false`

Totals
------

- baseline_loss_sum: `2`
- controlled_loss_sum: `0`
- baseline_repair_sum: `9`
- controlled_repair_sum: `12`
- baseline_net_action: `-7`
- controlled_net_action: `-12`

Claim Boundary
--------------

This result is a marker-based score over externally supplied baseline / controlled outputs for a frozen premise-update task surface. It does not prove real LLM semantics, model performance, memory safety, continual-learning safety, or workflow correctness.
