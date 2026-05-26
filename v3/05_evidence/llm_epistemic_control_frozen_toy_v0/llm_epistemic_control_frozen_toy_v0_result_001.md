LLM Epistemic-Control Frozen Toy v0 Score Summary
=================================================

Status: deterministic toy-protocol score; not validation evidence

artifact_type: `deterministic_toy_protocol_result`
protocol_id: `llm_epistemic_control_frozen_toy_v0`
result_id: `llm_epistemic_control_frozen_toy_v0_result_001`
runner_version: `0.2.0`
tasks_sha256: `9b206393333f2fba8e3aa1490c4623d3e347467919cf8adcf6dd96208925cbff`

Checks
------

- frozen_task_surface: `true`
- frozen_readout: `true`
- same_horizon: `true`
- metric_dominance: `true`
- readout_alignment: `true`
- no_worse_net_action: `true`
- protocol_shape_valid: `true`

Totals
------

- baseline_loss_sum: `6.0`
- controlled_loss_sum: `3.0`
- baseline_repair_sum: `0.0`
- controlled_repair_sum: `3.0`
- baseline_net_action: `6.0`
- controlled_net_action: `0.0`

Claim Boundary
--------------

This is a deterministic toy-protocol scoring summary. It does not prove real LLM semantics, model performance, memory safety, or workflow correctness.
