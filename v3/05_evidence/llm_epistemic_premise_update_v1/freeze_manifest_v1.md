LLM Epistemic Premise Update v1
===============================

Status: frozen task/readout surface before outcome-bearing execution; not
support evidence

Date frozen: 2026-05-27 JST

manifest_id: `llm_epistemic_premise_update_v1`

Readout alignment:

```text
premise_update_slot_state_v1
```

Horizon mode:

```text
batch_as_single_step_horizon_1
```

The 12 cases are aggregated as one finite metric step for the Lean-facing
readout. The scorer may report per-case diagnostics, but the package does not
claim a Lean per-case dominance theorem unless a future protocol explicitly
freezes that different horizon model.

Digest table:

| Artifact | SHA256 |
|---|---|
| `tasks.jsonl` | `ba273ed2f870a241053a508538ea39bf5c6c0a353d44c3b82005487be7279efb` |
| `../../../analysis/epistemic_control_premise_update_v1/run_eval.py` | `1b48b5a1094ff46e801da6167760f3167f413ee3c6d61565b4e4c79a324ca750` |
| `../../../analysis/epistemic_control_premise_update_v1/run_preflight.py` | `d61663d6faa48c4a9dae9287067112e31d2b4ab6112233df4d2098bff7073759` |
| `../../../analysis/epistemic_control_premise_update_v1/preflight_cases.jsonl` | `c29cf2a943955eb05f849cbf0a333394c88e8ad6547f3bdc70f2f1a8fb3a6266` |
| `../../../analysis/epistemic_control_premise_update_v1/make_output_template.py` | `5dd59546da751d223d18127779897c279b385785cd2392360e70b4d381ef24d1` |
| `../../../analysis/epistemic_control_premise_update_v1/results_schema.json` | `340a2a18f195d452b10a43604ec5fd2acf9f5f26e76ea36b6c0df240f83673aa` |


1. Purpose
----------

This packet is the successor frozen readout package for a premise-update /
dependency-staleness evaluation. It is motivated by the v0 `silence` result,
but it does not alter v0 and does not rescore v0 outputs.

V1 narrows the v0 observability failure by freezing a deterministic slot-state
readout before any v1 outcome-bearing generation:

- finite concept patterns;
- stale-current stance patterns;
- updated-current stance patterns;
- safe-unknown / refresh patterns;
- historical, negation, and invalidation scope patterns;
- explicit ambiguous and mixed outcomes;
- explicit per-condition generation status.


2. Lean / Protocol Target
-------------------------

The theorem-side target remains unchanged:

```text
ValidEpistemicBenchmarkProtocol
  -> NetActionNoWorse
  -> coherentMass baseline horizon <= coherentMass controlled horizon
```

This manifest does not itself provide a valid result certificate. A future v1
result must still supply frozen-surface, frozen-readout, same-horizon,
same-initial-mass, positivity, metric-dominance, readout-alignment, and result
certificate witnesses.


3. Frozen Task Surface
----------------------

The task surface contains the same 12 public-safe premise-update families as
v0, but with a new readout grammar. Each row fixes:

- `answer_target.slot_id`;
- `answer_target.probe_act`;
- `answer_target.expected_stance`;
- `concept_patterns`;
- `stale_current_patterns`;
- `updated_current_patterns`;
- `safe_unknown_patterns`;
- `historical_scope_patterns`;
- `negation_scope_patterns`;
- `invalidation_scope_patterns`.

No task, pattern, scope rule, status rule, dominance rule, or decision rule may
change after the first outcome-bearing v1 generation. Any change requires a new
manifest id.


4. V1 Scoring Semantics
-----------------------

The scorer splits each output into finite claim units. For each unit it records
concept, stance, and scope hits.

Primary labels:

- `stale_current`: stale downstream value asserted without historical,
  negation, or invalidation scope;
- `updated_current`: updated premise or updated downstream value asserted as
  current;
- `safe_unknown`: downstream value blocked, refreshed, rechecked, or marked
  unknown;
- `historical_or_negated_stale`: stale value mentioned only under historical,
  negation, or invalidation scope;
- `mixed_current`: stale-current evidence co-occurs with repair / refresh
  evidence in the same answer;
- `ambiguous_elliptical`: a frozen concept is mentioned without an explicit
  stance under the target probe;
- `unmapped`: no frozen concept, stance, or safe-unknown signal is visible.

Important v1 rule:

```text
stale-current evidence remains a loss even when updated markers also appear,
unless the stale value is explicitly historical, negated, or invalidated under
the frozen scope rules.
```


5. Output Status Semantics
--------------------------

Each output row must include:

```text
baseline_status
controlled_status
```

Allowed statuses:

- `ok`
- `timeout`
- `tool_error`
- `refusal`
- `empty`
- `truncated`

Only `ok` is scoreable. Any other status makes the run `invalid_run` for this
v1 package unless a future manifest freezes a different status policy before
collection.


6. Decision Rule
----------------

Decision labels:

- `support_clean`: all audit checks pass, all rows are mapped and determinate,
  no mixed / ambiguous / invalid status is present, and both dominance
  inequalities hold;
- `support_with_ambiguity`: no invalid or silence trigger fires, determinate
  rows satisfy dominance, but at least one ambiguity is recorded;
- `no_support`: audit checks pass and the clean dominance inequalities fail;
- `mixed_inconclusive`: stale-current and repair evidence co-occur in a
  decision-relevant way;
- `ambiguous_inconclusive`: ambiguity prevents a clean package-local decision;
- `silence`: at least one output cannot be mapped even to frozen concepts or
  slots;
- `invalid_run`: schema, digest, row order, horizon, status, condition, parser,
  or readout mismatch.

Promotion rule:

```text
promotable = true iff decision = support_clean and protocol_shape_valid = true
```

`support_with_ambiguity` is an audit-visible package result, not a valid Lean
benchmark-result certificate witness.


7. Preflight Requirement
------------------------

Before any outcome-bearing v1 generation, the scorer preflight suite must pass:

```bash
python3 analysis/epistemic_control_premise_update_v1/run_preflight.py
```

The frozen preflight suite covers:

- stale-current;
- updated-current;
- mixed stale-current plus repair;
- historical stale mention plus updated repair;
- terse ambiguous answer;
- unmapped answer;
- timeout status;
- negated stale plus updated repair.
- updated phrase containing a stale token;
- far historical scope that must not cancel current stale evidence;
- confirm-style stale assertion;
- pure safe-unknown / recheck answer;
- ambiguous unit plus repair unit.


8. Non-Claims
-------------

This v1 package does not claim:

- support before a valid outcome-bearing v1 result;
- retrospective support for v0 or any v0 result;
- theorem-side evidence by itself;
- real LLM semantics or performance;
- benchmark validity by itself;
- memory safety, continual-learning safety, or product-level reliability.
