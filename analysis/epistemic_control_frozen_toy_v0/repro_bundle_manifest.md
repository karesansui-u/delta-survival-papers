Epistemic-Control Frozen Toy v0 Repro Bundle Manifest
====================================================

Status: bundle manifest; not validation evidence

Bundle id:

```text
llm_epistemic_control_frozen_toy_v0_bundle
```

Recommended bundle contents:

```text
analysis/epistemic_control_frozen_toy_v0/README.md
analysis/epistemic_control_frozen_toy_v0/run_eval.py
analysis/epistemic_control_frozen_toy_v0/results_schema.json
analysis/epistemic_control_frozen_toy_v0/repro_bundle_manifest.md
v3/05_evidence/llm_epistemic_control_benchmark_manifest.md
v3/05_evidence/llm_epistemic_control_frozen_toy_v0/README.md
v3/05_evidence/llm_epistemic_control_frozen_toy_v0/freeze_manifest_v0.md
v3/05_evidence/llm_epistemic_control_frozen_toy_v0/tasks.jsonl
v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.json
v3/05_evidence/llm_epistemic_control_frozen_toy_v0/smoke_result_summary.md
```

Local bundle command from repository root:

```bash
zip -qr /private/tmp/llm_epistemic_control_frozen_toy_v0_bundle.zip \
  analysis/epistemic_control_frozen_toy_v0 \
  v3/05_evidence/llm_epistemic_control_benchmark_manifest.md \
  v3/05_evidence/llm_epistemic_control_frozen_toy_v0
```

The generated bundle is a reproducibility packet for the toy protocol shape.
It is not empirical support for a real model or workflow.
