LLM Structural-Blind Persistence Plan
=====================================

status: proposed_future_package

date: 2026-05-02 JST

domain: llm_reasoning

classification: inference-layer candidate, not evidence


1. Motivation
-------------

The existing LLM reasoning companion shows that structural conflicts can damage
logical consistency more than context length alone, and that scope markers or
external metabolism can repair part of the damage. It also contains nearby
failure-mode observations:

- Exp42 reports that `structural_anchor` produced no numeric answer in 18/20
  failed rows, unlike subtle conflicts that often produced an exact wrong-sum
  uptake.
- Exp41 shows model-dependent failure modes: GPT-4.1-nano largely failed the
  structural condition by not completing the numeric task, while Gemini 3.1
  Flash Lite often continued with numeric wrong answers.
- ON/OFF dialogue experiments show that unorganized contradictions lower
  logical consistency, while external metabolism improves it.
- The continual-learning companion shows that parameter updates can continue
  even when dependency consistency and old-knowledge fidelity remain low.

These observations are adjacent to structural-blind persistence, but they were
not frozen with continuation, refusal, self-diagnosis, or repair-choice as the
primary endpoint. This file records a future package design and does not create
support.


2. Core Question
----------------

Given matched visible resources \(M\), does a structurally blind agent continue
acting after the structural feasibility region has collapsed, while a
structure-sensitive agent stops, flags inconsistency, requests repair, or
switches to redesign?

Operational reading:

> A low-resolution agent sees remaining local action budget, context budget, or
> response budget. A higher-resolution agent also detects shrinkage of the
> feasible structural region \(V_G\) or a large accumulated loss \(B_n\).

The claim is not that a weaker agent is stronger. The candidate phenomenon is
that blind continuation can be persistence in appearance but collapse
non-detection in substance.


3. Candidate Variables
----------------------

Visible resource proxy \(M\):

- fixed context length;
- fixed token budget;
- fixed number of allowed tool calls or reasoning steps;
- fixed response format and time budget.

Structural pressure proxy:

- conflict class: scoped, subtle, structural, impossible;
- number of unscoped conflicting updates;
- dependency depth affected by an update;
- contradiction density, with context length matched.

Perceived structural pressure:

- explicit impossibility or inconsistency diagnosis;
- request for clarification or repair;
- refusal to produce a final answer because constraints are inconsistent;
- self-rated feasibility before answering, if collected under a frozen prompt.


4. Primary Endpoints
--------------------

Use endpoints that separate continuing from correctly recognizing the boundary.

`blind_continuation`:
  The model produces a final task answer without flagging inconsistency,
  underspecification, or repair need.

`calibrated_stop`:
  The model flags inconsistency, impossibility, missing scope, or repair need
  before giving a final answer.

`wrong_continuation`:
  The model blind-continues and the final answer is wrong.

`repair_switch`:
  The model changes behavior from answering to scope-seeking, contradiction
  resolution, or explicit state repair.

The primary endpoint for a future package should be chosen before seeing new
rows. A clean first target is `wrong_continuation` under structurally
inconsistent but resource-matched prompts.


5. Existing-Data Reanalysis First
---------------------------------

Before collecting new rows, audit the existing LLM reasoning artifacts if the
row-level outputs are available.

Frozen reanalysis candidate:

1. Use only already collected Exp40 / Exp42 / Exp41 rows.
2. Add a frozen output-status coder:
   - `numeric_final_answer`;
   - `no_numeric_answer`;
   - `explicit_inconsistency_flag`;
   - `repair_request_or_scope_request`;
   - `other_format_failure`.
3. Compare failure-mode rates across scoped, subtle, structural, and
   zero-sanity rows.
4. Treat this as retrospective diagnostic evidence only, unless the coder and
   metric can be frozen before any manual row inspection.

Expected nearby pattern from existing summaries:

- subtle conflicts tend to create wrong-value uptake;
- structural anchors can induce non-completion in some models;
- some models continue numerically under structural pressure, showing a
  candidate blind-continuation signature.

This is not yet a support claim because the original primary endpoints were
logical correctness and scope-as-repair, not blind continuation.


6. New Frozen Package Sketch
----------------------------

Task families:

- arithmetic with conflicting values and impossible constraints;
- dependency QA with updated premises and stale downstream facts;
- rule-following tasks with inconsistent rule sets;
- small formal proof or planning tasks with unsatisfiable assumptions.

Model families:

- at least one small / fast model;
- at least one stronger model;
- optional same-model prompting variants with and without explicit
  self-diagnosis instruction.

Primary comparison:

- resource-visible baseline:
  context length, token budget, prompt family, and conflict-present indicator;
- structure-aware predictor:
  conflict type, scope marker level, dependency depth, and impossible-condition
  indicator;
- optional agent-sensitivity readout:
  whether the model stops, repairs, or blind-continues.

Candidate support rule:

> On held-out tasks or future model rows, structural pressure predicts
> `wrong_continuation` or `calibrated_stop` beyond resource-visible baselines,
> and repair/scope markers reduce `wrong_continuation` under matched visible
> resource.

The package must not reward mere refusal. A `calibrated_stop` is only positive
when the prompt is actually inconsistent or underspecified under the frozen
label.


7. Non-Claims
-------------

This package would not claim:

- that low intelligence is better;
- that all weak models blind-continue;
- that all strong models correctly stop;
- that refusal is always good;
- that existing LLM experiments already support this endpoint;
- that human groups or organizations are measured by the LLM package.

The intended claim is narrower:

> Under matched visible resources, structural-blind policies may continue
> producing actions after \(V_G\) has become empty or near-empty, while
> structure-sensitive policies detect the boundary and switch to stop, repair,
> or redesign.


8. Governance
-------------

This is a proposed future package. It should remain separate from the current
LLM reasoning companion evidence and from the continual-learning companion
evidence.

If an existing-data reanalysis is performed, record it as a diagnostic
reanalysis unless the row coder, metric, and support rule are frozen before row
inspection. A true support-bearing run requires a new manifest, held-out rows or
future model rows, and a pre-fixed baseline.
