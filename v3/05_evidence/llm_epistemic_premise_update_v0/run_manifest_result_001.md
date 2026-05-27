LLM Epistemic Premise Update v0 Run Manifest: result 001
========================================================

Status: pre-run condition manifest for `result_001`; not model output and not
validation evidence

Run id:

```text
llm_epistemic_premise_update_v0_result_001
```

Run date:

```text
2026-05-27 JST
```

Operator:

```text
local repository operator via Codex session
```


1. Frozen Inputs
----------------

Task file:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/tasks.jsonl
```

Task SHA256:

```text
f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204
```

Output template:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/premise_update_outputs_template_result_001.jsonl
```

Output template SHA256:

```text
8cf961c71b238fdb912478438180f757d7074810a9aa613f568f04c3ea69749b
```


2. Model And Runtime
--------------------

Backend:

```text
local Ollama HTTP API
```

Model:

```text
qwen3.5:9b
```

Generation options:

```json
{
  "temperature": 0,
  "top_p": 1,
  "seed": 20260527,
  "num_predict": 96
}
```

Collector:

```text
analysis/epistemic_control_premise_update_v0/collect_with_ollama.py
```

Collector version:

```text
0.1.0
```

Pre-run repository commit:

```text
a8bce81
```


3. Prompt Versions
------------------

Baseline prompt version:

```text
ordinary_readout_without_dependency_refresh_v0
```

Controlled prompt version:

```text
dependency_aware_premise_refresh_v0
```

The baseline prompt asks the model to answer from the stored record and
appended update without adding a dependency-refresh or downstream-rewrite step.

The controlled prompt asks the model to treat the appended update as current and
to invalidate, refresh, or mark unknown the downstream dependency surface before
answering.


4. Planned Output Artifacts
---------------------------

Raw output JSONL:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/premise_update_outputs_result_001.jsonl
```

Collection metadata:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/premise_update_output_collection_result_001.json
```

Scored result JSON:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.json
```

Scored result summary:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md
```


5. Decision Rule
----------------

The scorer must emit one of:

- `support`
- `no_support`
- `invalid_run`
- `silence`

The first result must be recorded under the predeclared scorer output. A bad,
surprising, or no-support result must not be repaired by editing the task
surface, marker readout, output rows, or decision rule.


6. Non-Claims
-------------

This run manifest does not claim:

- that the model has already been run;
- that the future result will support the protocol;
- that marker-based scoring is full natural-language semantics;
- that this finite run proves general LLM performance, memory safety,
  continual-learning safety, or product-level reliability.
