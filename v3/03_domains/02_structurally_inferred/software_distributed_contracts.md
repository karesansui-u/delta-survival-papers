Software Distributed-Contract Contradictions
============================================

domain_id: software_distributed_contracts

domain_name: Software distributed-contract contradiction detection

observability_layer: structurally_inferred

status: field_demonstration + internal_calibration


1. Maintenance Target
---------------------

- Target structure: a distributed contract set remains mutually consistent across
  code, configuration, documentation, runtime behavior, tests, APIs, callers, and
  lifecycle surfaces.
- Failure / collapse boundary: not long-horizon software collapse. The current
  boundary is a validated distributed-contract contradiction, accepted fix, or
  maintainer-recognized mismatch.
- Observation unit: repository, frozen commit, selected scope, context packet, or
  submitted PR / Issue.
- Time horizon: static or bounded-snapshot detection for the current track.
  Longitudinal maintainability / collapse prediction is a separate future track.


2. Structural Coordinates
-------------------------

- \(V\): coherent future modification / execution / documentation paths that
  preserve the distributed contract set.
- \(m\): not directly counted; approximated by validated root contradictions and
  bounded benchmark outcomes.
- \(d_t\): contradiction pressure from scoped changes, stale documentation,
  boundary-value divergence, config-runtime mismatch, lifecycle mismatch, or
  caller / callee contract drift.
- \(r_t\): patch, propagation, synchronization, documentation update, test
  update, rollback, refactor, or maintainer-accepted repair. The current
  DeltaLint benchmark primarily tests detection of \(d_t\), not a measured
  recovery process.
- \(L\): accumulated or item-level distributed-contract contradiction signal.
- \(B\): not the primary coordinate in the current static-code track; use only
  when repair / recovery is explicitly measured.
- \(M\)-side readout: none in this domain profile. M-side software / SaaS
  validation belongs to `software_saas_m_profile`.


3. Baselines
------------

- simple baseline: raw finding count or unvalidated candidate count, descriptive
  only.
- domain baseline: same-scope generic review under the same frozen context,
  model, budget, and validation depth.
- domain baseline + SP: structural-lens / DeltaLint workflow output compared
  against the same-scope generic review by incremental validated root causes.
- wide baseline, if any: static analyzers, type checks, tests, linters, or
  security scanners when available and recorded as separate comparison surfaces.


4. Validation Status
--------------------

- current status: field demonstration plus internal bounded calibration.
- field demonstration record: `../../05_evidence/field_demonstrations.tsv`.
- bounded benchmark record: `../../05_evidence/bounded_benchmarks.tsv`.
- detailed analysis note:
  `../../../analysis/deltalint_software_operational_benchmark_note.md`.


5. Claims
---------

This domain supports:

- an operational claim that the structural-contradiction coordinate can produce
  useful distributed-contract mismatch candidates in public OSS workflows;
- an initial internal calibration claim that DeltaLint Product-arm / structural
  workflow can add validated distributed-contract roots over same-scope generic
  review on selected frozen OSS items.

This domain does not support:

- direct software-collapse prediction;
- raw detector precision / recall;
- provider superiority;
- M-side intervention-ranking support;
- support transfer to software / SaaS operational M-profile validation;
- universal law claims.
