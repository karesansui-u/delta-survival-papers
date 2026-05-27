Premise Update v1 Design Review
===============================

Status: review disposition for the successor v1 readout package; not validation
evidence

Date: 2026-05-27 JST


1. Review Scope
---------------

Three independent review threads were used before freezing the v1 design:

- methodology / evaluation-governance review;
- v0 scorer and result-readout review;
- Lean / documentation boundary review.

All three reviews converged on the same boundary: v1 should be a new external
readout / scorer package. It should not modify v0, rescore v0, or require a new
Lean theorem.


2. Accepted Changes
-------------------

Accepted:

- keep the v0 result as `silence`;
- create `llm_epistemic_premise_update_v1` as a successor package;
- use `premise_update_slot_state_v1` instead of the v0 stale / updated marker
  buckets;
- split output readout into concept, stance, and scope hits;
- make stale-current evidence remain a loss even when updated evidence also
  appears, unless a frozen historical / negation / invalidation scope applies;
- make `mixed_current` and `ambiguous_elliptical` first-class outcomes;
- require explicit `baseline_status` and `controlled_status`;
- make any non-`ok` status an `invalid_run` for v1;
- require scorer preflight before outcome-bearing output collection;
- record task, scorer, preflight, template, schema, and manifest digests;
- state `batch_as_single_step_horizon_1` explicitly;
- make only `support_clean` with `promotable = true` a candidate Lean
  certificate witness.


3. Deferred Or Rejected
-----------------------

Deferred:

- running a v1 model evaluation;
- creating a new Lean theorem;
- treating ambiguous rows as theorem-promotable evidence;
- proving natural-language semantics or real model performance.

Rejected:

- adding post-hoc v0 marker fixes;
- counting updated markers as automatically canceling stale-current claims;
- promoting a `silence`, `mixed_inconclusive`, or `support_with_ambiguity`
  result as a valid Lean benchmark-result certificate.


4. Remaining Obligations Before V1 Run
--------------------------------------

Before any outcome-bearing v1 generation:

- fill the `TODO` fields in `run_manifest_result_001.md`;
- generate and hash the raw-output template;
- record prompt and collector hashes;
- run the preflight suite;
- freeze the collection command and runtime settings;
- keep raw outputs unchanged after generation.


5. Post-Implementation Review Fixes
-----------------------------------

After the first v1 implementation pass, a second read-only review found several
scorer and documentation issues. These were accepted and fixed:

- stale-current loss is no longer erased by a broad scope word elsewhere in
  the claim unit;
- ambiguous claim units remain audit-visible even when another unit contains
  repair evidence;
- output rows must preserve `setup`, `update`, and `probe`;
- `protocol_shape_valid` now means structurally scoreable, not positive
  support;
- preflight now enforces sample ids / order and checks its own digest;
- the result schema now requires named check / total fields and encodes the
  `promotable -> decision = support_clean` invariant;
- stale v0-first documentation was updated to identify v1 as the current
  successor protocol.


6. Claim Boundary
-----------------

V1 is an evaluation-facing witness package. It can help a future result supply
the witnesses expected by the existing Lean certificate chain, but it is not
itself support evidence before an outcome-bearing result is produced.
