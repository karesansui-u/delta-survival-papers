LLM Epistemic Premise Update v1 Run Manifest Result 001
=======================================================

Status: pre-run condition manifest template; not model output and not
validation evidence

Protocol id: `llm_epistemic_premise_update_v1`

Planned result id:

```text
llm_epistemic_premise_update_v1_result_001
```

This manifest must be completed before outcome-bearing v1 output collection.
Until the `TODO` fields are replaced and the output-template digest is recorded,
no v1 result should be treated as frozen.


1. Fixed Protocol Artifacts
---------------------------

| Field | Value |
|---|---|
| task path | `v3/05_evidence/llm_epistemic_premise_update_v1/tasks.jsonl` |
| task SHA256 | `ba273ed2f870a241053a508538ea39bf5c6c0a353d44c3b82005487be7279efb` |
| scorer path | `analysis/epistemic_control_premise_update_v1/run_eval.py` |
| scorer SHA256 | `1b48b5a1094ff46e801da6167760f3167f413ee3c6d61565b4e4c79a324ca750` |
| preflight path | `analysis/epistemic_control_premise_update_v1/preflight_cases.jsonl` |
| preflight SHA256 | `c29cf2a943955eb05f849cbf0a333394c88e8ad6547f3bdc70f2f1a8fb3a6266` |
| preflight runner SHA256 | `d61663d6faa48c4a9dae9287067112e31d2b4ab6112233df4d2098bff7073759` |
| template generator SHA256 | `5dd59546da751d223d18127779897c279b385785cd2392360e70b4d381ef24d1` |
| result schema SHA256 | `340a2a18f195d452b10a43604ec5fd2acf9f5f26e76ea36b6c0df240f83673aa` |


2. Required Pre-Run Fields
--------------------------

These fields must be completed before collection:

| Field | Value |
|---|---|
| repository commit before collection | `TODO_COMMIT` |
| output template path | `v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_template_result_001.jsonl` |
| output template SHA256 | `93625782dfcd3ee3659d872365c5b966e34e8e2f03990b46a10cdb423d8e9d27` |
| prompt template path | `TODO_PROMPT_TEMPLATE_PATH` |
| prompt template SHA256 | `TODO_PROMPT_TEMPLATE_SHA256` |
| collector path | `TODO_COLLECTOR_PATH_OR_MANUAL_COLLECTION` |
| collector SHA256 | `TODO_COLLECTOR_SHA256_OR_NA` |
| model | `TODO_MODEL` |
| runtime | `TODO_RUNTIME` |
| temperature | `TODO_TEMPERATURE` |
| top_p | `TODO_TOP_P` |
| max tokens / num_predict | `TODO_MAX_TOKENS` |
| timeout policy | `TODO_TIMEOUT_POLICY` |
| run date | `TODO_DATE` |
| operator | `TODO_OPERATOR` |


3. Preflight Command
--------------------

Before collection:

```bash
python3 analysis/epistemic_control_premise_update_v1/run_preflight.py
```

Expected preflight result:

```json
{"preflight_ok": true, "checked": 13}
```


4. Planned Artifacts
--------------------

| Artifact | Planned path |
|---|---|
| raw outputs | `v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_result_001.jsonl` |
| scored JSON | `v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.json` |
| scored Markdown | `v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.md` |
| certificate mapping | `v3/05_evidence/llm_epistemic_premise_update_v1/result_001_certificate_mapping.md` |


5. Boundary
-----------

This manifest is a planning and freeze artifact only. It does not contain
model output, does not imply support, and does not change the v0 `silence`
record.
