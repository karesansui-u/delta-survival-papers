LLM Epistemic Premise Update v1 Output Collection Protocol
==========================================================

Status: output-collection protocol; not model output and not validation
evidence

Protocol id: `llm_epistemic_premise_update_v1`

Readout alignment:

```text
premise_update_slot_state_v1
```


1. Boundary
-----------

This protocol governs future raw-output collection for v1. It does not call a
model, does not validate a model, and does not modify v0. Any v1 result is
package-scoped and must be read through the v1 scorer and certificate mapping.


2. Pre-Collection Freeze Checklist
----------------------------------

Before the first outcome-bearing generation, record:

- repository commit;
- task SHA256;
- scorer SHA256;
- preflight-suite SHA256;
- preflight runner SHA256;
- output-template SHA256;
- prompt-template SHA256;
- collector SHA256, if a collector is used;
- model name and local/runtime identifier;
- temperature, top_p, max-token / `num_predict`, and timeout settings;
- run operator and run date.

The frozen preflight suite must pass before collection:

```bash
python3 analysis/epistemic_control_premise_update_v1/run_preflight.py
```


3. Output Template
------------------

Create the raw-output template with:

```bash
python3 analysis/epistemic_control_premise_update_v1/make_output_template.py \
  --out v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_template_result_001.jsonl
```

Each row must preserve:

- `case_id`;
- `horizon = 1`;
- `horizon_mode = batch_as_single_step_horizon_1`;
- `baseline_condition`;
- `controlled_condition`;
- `readout_alignment = premise_update_slot_state_v1`;
- raw `setup`, `update`, and `probe`;
- `baseline_status`;
- `controlled_status`;
- raw `baseline_output`;
- raw `controlled_output`.


4. Status Rules
---------------

Allowed status values:

- `ok`
- `timeout`
- `tool_error`
- `refusal`
- `empty`
- `truncated`

Only `ok` is scoreable in v1. If either side has a non-`ok` status, the result
is `invalid_run` unless a future manifest freezes a different policy before
collection. Do not replace non-`ok` outputs with cleaned text.


5. Raw Output Rules
-------------------

Raw outputs must be retained exactly as produced. Do not normalize, rewrite,
summarize, or remove awkward answers before scoring.

If an answer is terse, mixed, contradictory, truncated, or awkward, keep it.
The scorer has explicit `ambiguous`, `mixed`, and status outcomes for this
reason.

After collection and before scoring, record the raw-output JSONL SHA256.


6. Scoring
----------

Score with:

```bash
python3 analysis/epistemic_control_premise_update_v1/run_eval.py \
  --outputs v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_result_001.jsonl \
  --out v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.json \
  --summary-md v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.md
```

The scorer exits zero when the emitted artifact is structurally scoreable under
the v1 protocol, even if the protocol-local decision is `no_support`,
`mixed_inconclusive`, `ambiguous_inconclusive`, or `support_with_ambiguity`.
It exits nonzero for `silence` or `invalid_run`. In all cases, only
`support_clean` with `promotable = true` is a candidate Lean certificate
witness.


7. Promotion Boundary
---------------------

The result is a candidate Lean certificate witness only if all are true:

- `decision = support_clean`;
- `silence = false`;
- `ambiguous = false`;
- `mixed = false`;
- `invalid_run = false`;
- `protocol_shape_valid = true`;
- `promotable = true`.

All other decisions must be recorded as package-local audit outcomes and must
not be described as support for the Lean coherent-mass comparison theorem.
