LLM Epistemic-Control Frozen Toy v0
===================================

Status: frozen toy protocol before outcome-bearing execution; not validation
evidence

Date frozen: 2026-05-27 JST

manifest_id: `llm_epistemic_control_frozen_toy_v0`

Protocol parent:

- `../llm_epistemic_control_benchmark_manifest.md`


1. Frozen Mapping
-----------------

- Target structural condition: finite epistemic-control comparison under a
  same-horizon benchmark protocol.
- Observation unit: one synthetic task instance.
- Interface readout: contradiction loss and repair gain indicators over a
  finite horizon.
- Lean target: `ValidEpistemicBenchmarkProtocol`.
- Inclusion criteria: synthetic tasks with explicit initial state, update,
  expected eligibility / dependency condition, baseline action, controlled
  action, and metric readout.
- Exclusion criteria: tasks that require natural-language semantic judgment not
  captured by the frozen fields.


2. Frozen Task Surface
----------------------

The frozen toy packet contains three synthetic cases:

| case_id | family | horizon |
|---|---|---|
| `toy_contradiction_001` | contradiction injection | 2 |
| `toy_memory_001` | memory eligibility | 2 |
| `toy_dependency_001` | dependency rewrite | 2 |

The cases are listed in:

- `tasks.jsonl`

No case may be added, removed, or relabeled after execution.


3. Baseline
-----------

Baseline policy:

- accept every raw memory or update;
- do not explicitly rewrite dependency closure;
- do not run a separate contradiction metabolism step.


4. Controlled
-------------

Controlled policy:

- apply memory eligibility before use;
- localize premise-update effects through dependency closure;
- run an explicit contradiction metabolism / repair step before final readout.


5. Metrics
----------

For each case and step:

- `baselineLoss(t)`: frozen contradiction-pressure indicator;
- `controlledLoss(t)`: frozen contradiction-pressure indicator after control;
- `baselineRepair(t)`: frozen repair-credit indicator;
- `controlledRepair(t)`: frozen repair-credit indicator after control.

The support-bearing aggregate is the sum over all frozen cases and steps.


6. Dominance Rule
-----------------

Protocol success requires both:

```text
sum controlledLoss <= sum baselineLoss
sum baselineRepair <= sum controlledRepair
```

on the frozen packet, with no post-hoc task edits.


7. Readout Alignment
--------------------

The toy packet treats the aggregate loss-minus-repair sum as the benchmark
readout for cumulative net action. This is a toy readout-alignment assumption,
not a claim about real model internals.


8. Decision Rule
----------------

- support: all audit checks pass and both dominance inequalities hold;
- no-support: audit checks pass and at least one dominance inequality fails;
- invalid-run: task surface, horizon, metric, or parser differs from this
  manifest;
- silence: output cannot be mapped to the frozen fields.


9. Non-Claims
-------------

This frozen toy protocol does not claim:

- real LLM performance support;
- general memory safety;
- real-world software or agent reliability;
- validation of natural-language semantics;
- support before an outcome-bearing execution is recorded.
