LLM Epistemic Premise Update v0 Result 001 Certificate Mapping
==============================================================

Status: result-certificate mapping note; protocol-local outcome is `silence`

This note maps the first output-bearing premise-update run to the theorem-side
benchmark certificate fields. It does not change the raw outputs, scorer, task
surface, or decision rule.


1. Result Artifacts
-------------------

Raw output JSONL:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/premise_update_outputs_result_001.jsonl
```

Raw output SHA256:

```text
a9ca07d8f9c07055cd7576619dfd53ff9a3c9349b9b9733c20844f653985f51c
```

Collection metadata:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/premise_update_output_collection_result_001.json
```

Collection metadata SHA256:

```text
a78744851c1c3744fdd54e931dd06d0b3641ba5272c27948e21a36f757d3ba6f
```

Scored result JSON:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.json
```

Scored result JSON SHA256:

```text
22d85a4a36084edf81909cf8ad7844e1a077115afd274bd53fc09bbfe9d60405
```

Scored result Markdown:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md
```

Scored result Markdown SHA256:

```text
e80f73398756a8f3624c10cc9821904bbba189952253ff381515ba240924a5d0
```


2. Protocol Outcome
-------------------

Decision:

```text
silence
```

Machine checks:

| Field | Value |
|---|---|
| frozen_task_surface | `true` |
| task_surface_digest_matches | `true` |
| frozen_readout | `true` |
| same_horizon | `true` |
| outputs_complete | `true` |
| raw_outputs_retained | `true` |
| metric_dominance | `true` |
| readout_alignment | `true` |
| no_worse_net_action | `true` |
| silence | `true` |
| invalid_run | `false` |
| protocol_shape_valid | `false` |

The protocol-local decision is `silence` because at least one output pair could
not be mapped to the frozen stale / updated / safe-unknown fields.

Silent case:

```text
pu_005_allergy_update_menu
```

The raw outputs are retained in the JSON result. The marker readout was not
edited after seeing the output.


3. Lean-Side Correspondence
---------------------------

| Lean / protocol witness | Result 001 status |
|---|---|
| frozen task surface | supplied |
| frozen readout | supplied |
| same finite horizon | supplied |
| raw output retention | supplied |
| metric dominance | supplied |
| readout alignment | supplied |
| no-worse net action | supplied |
| no silence / mappable rows | not supplied |
| valid benchmark result certificate | not supplied |

Because `silence = true`, this result does not instantiate a valid benchmark
result certificate and does not invoke the final coherent-mass comparison
theorem as support.


4. Interpretation
-----------------

This run still exercises the end-to-end workflow:

```text
frozen task surface
-> fixed run manifest
-> raw outputs
-> marker scorer
-> result certificate shape
-> protocol-local decision
```

It is not evidence that the controlled condition improves real LLM performance.
It is a first output-bearing run showing that the predeclared workflow can
return a non-supporting / silent outcome without changing the task surface or
scorer.


5. Non-Claims
-------------

This mapping note does not claim:

- general LLM performance;
- memory safety or continual-learning safety;
- that marker matching is full natural-language semantics;
- that `metric_dominance = true` is support when `silence = true`;
- that the Lean theorem proves the model behavior in this run.
