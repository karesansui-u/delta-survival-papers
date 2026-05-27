LLM Epistemic Premise Update v0 Output Collection Protocol
==========================================================

Status: output-collection protocol; not model output and not validation
evidence

This note fixes how raw baseline / controlled outputs should be collected for
the frozen premise-update task surface. It is intentionally separate from the
scored result artifact.


1. Frozen Inputs
----------------

The frozen task surface is:

```text
v3/05_evidence/llm_epistemic_premise_update_v0/tasks.jsonl
```

The required task digest is:

```text
f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204
```

No task row, case id, marker list, condition label, horizon, or readout label
may be changed during output collection. A changed task surface requires a new
manifest id.


2. Output Template
------------------

Generate a collection template from the repository root:

```bash
python3 analysis/epistemic_control_premise_update_v0/make_output_template.py \
  --out /tmp/premise_update_outputs_template.jsonl
```

The template has one row per frozen case. Each row must eventually contain the
raw answer for:

```text
baseline_output
controlled_output
```

The collector may keep the copied `setup`, `update`, and `probe` fields for
convenience. The scorer ignores those copied fields and reads the frozen task
surface again.


3. Baseline Condition
---------------------

The baseline condition label is:

```text
ordinary_readout_without_dependency_refresh
```

The baseline answer must be produced from the setup / update / probe context
without adding a dependency-refresh control step after the update. The exact
model, prompt wrapper, sampling settings, and execution environment must be
recorded in the future result summary.


4. Controlled Condition
-----------------------

The controlled condition label is:

```text
dependency_aware_premise_refresh
```

The controlled answer must treat the update as current and must refresh, block,
or mark unknown the downstream dependency surface before answering. The exact
control wrapper, prompt wrapper, sampling settings, and execution environment
must be recorded in the future result summary.


5. Raw Output Requirements
--------------------------

For every case:

- one baseline output and one controlled output must be recorded;
- both outputs must correspond to the same setup / update / probe;
- outputs must not be edited after model generation except for lossless
  transport escaping;
- refusals, empty answers, tool errors, and timeouts must be recorded as raw
  outputs or quarantine notes, not silently removed;
- the output JSONL row order must match the frozen task order.


6. Scoring Command
------------------

After raw outputs are collected, run:

```bash
python3 analysis/epistemic_control_premise_update_v0/run_eval.py \
  --outputs path/to/premise_update_outputs.jsonl \
  --out v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.json \
  --summary-md v3/05_evidence/llm_epistemic_premise_update_v0/llm_epistemic_premise_update_v0_result_001.md
```

Do not promote a result artifact unless the scorer reports:

```text
invalid_run = false
silence = false
outputs_complete = true
raw_outputs_retained = true
```


7. Decision Labels
------------------

The scorer emits one of:

- `support`: audit checks pass and the frozen metric dominance rule passes;
- `no_support`: audit checks pass but metric dominance fails;
- `invalid_run`: frozen task surface, row structure, horizon, condition, or
  readout alignment is broken;
- `silence`: outputs cannot be mapped to the frozen stale / updated /
  safe-unknown fields.

These labels are protocol-local labels. They are not universal claims about
LLM performance.


8. Non-Claims
-------------

This output-collection protocol does not claim:

- that any model has been run;
- that the future outputs will support the protocol;
- that marker-based scoring is a complete natural-language semantics;
- that dependency discovery is solved;
- memory safety, continual-learning safety, or product-level reliability.
