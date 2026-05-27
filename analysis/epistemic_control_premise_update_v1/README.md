Premise Update v1 Scorer
========================

Status: deterministic scorer / preflight package for
`llm_epistemic_premise_update_v1`; not model validation by itself

Commands:

```bash
python3 analysis/epistemic_control_premise_update_v1/run_preflight.py
python3 analysis/epistemic_control_premise_update_v1/make_output_template.py \
  --out v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_template_result_001.jsonl
python3 analysis/epistemic_control_premise_update_v1/run_eval.py \
  --outputs v3/05_evidence/llm_epistemic_premise_update_v1/premise_update_outputs_result_001.jsonl \
  --out v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.json \
  --summary-md v3/05_evidence/llm_epistemic_premise_update_v1/llm_epistemic_premise_update_v1_result_001.md
```

The scorer returns nonzero unless the result is `support_clean` and
`promotable = true`. This is intentional: `silence`, `invalid_run`,
`mixed_inconclusive`, `ambiguous_inconclusive`, and `no_support` are valid audit
outcomes.

V1 differs from v0 by using finite slot-state readout fields instead of plain
substring buckets. Stale-current evidence remains loss even when updated
evidence is also present, unless the stale value is explicitly historical,
negated, or invalidated under frozen scope rules.
