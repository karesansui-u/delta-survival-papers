Specification-Fixed Replication Strengthening Plan
==================================================

status: design_plan_not_evidence

date: 2026-05-01 JST

This memo plans the next replication-oriented step for the supported
specification-fixed packages. It does not create new evidence and does not
change any support / no-support / invalid-run decision.

The goal is not to rescue failed packages. The goal is to make the current
supported non-CSP specification-fixed anchors easier to rerun, audit, and
eventually hand to outside executors.


1. Why This Comes Next
----------------------

The current evidence dashboard identifies three strong pillars:

1. finite CSP / q-coloring support with outside reruns;
2. finite graph and coding-channel support beyond CSP;
3. explicit no-support / invalid-run records that constrain overclaiming.

The second pillar is now the natural strengthening target. A12 and A06/A19
already have support-bearing frozen packages, but they do not yet have the
same outside-rerun maturity as Mixed-CSP and q-coloring.

The immediate task is therefore packaging and replication discipline, not a new
theory claim.


2. Priority Order
-----------------

| priority | package | reason |
|---:|---|---|
| 1 | A06/A19 coding-channel recovery v0 | strongest information-theory-facing non-CSP support; exact Lean accounting anchor now exists |
| 2 | A12 s-t cut-spectrum reliability v0b/v0c | graph reliability support on two separately frozen kappa surfaces |
| 3 | A31 matched residual v1 | useful global-redundancy support, but its claim is more specialized than A06/A19 or A12 |

A06-stop is not in this priority list because its current support-bearing v2
package is no-support. Any A06-stop successor should be a separate design
package focused on separating rank-dependency from stopping-set pressure.


3. Replication Package Types
----------------------------

Each supported package can be strengthened in three increasingly external
forms.

### 3.1 Rerun-Ready Internal Packet

Purpose: make the package easy to rerun locally from a clean checkout.

Required contents:

- frozen manifest;
- generation and evaluation scripts;
- exact commands;
- script SHA256 hashes;
- seed schedule;
- expected summary metrics;
- expected decision;
- artifact manifest for any bundled raw rows.

### 3.2 Fresh-Seed Internal Replication

Purpose: test whether the support decision is stable under a separately frozen
seed schedule or minor pre-fixed surface variation.

Rules:

- new manifest before execution;
- new seeds before labels;
- same primary decision rule unless the manifest explicitly defines a new
  claim;
- old rows cannot be reused as new support;
- no result-dependent retuning.

### 3.3 Outside-Rerun Packet

Purpose: allow an outside executor to reproduce the support decision without
using the author's environment.

Required contents:

- minimal dependency instructions;
- single-command run path where possible;
- expected output schema;
- checksum or signature of scripts and config;
- instructions for reporting mismatch, invalid-run, or non-failure with minor
  runtime drift;
- no hidden local data dependency.


4. A06/A19 Coding-Channel Recovery
----------------------------------

Current status:

```text
primary_v0: support
v1_rate625_cw4: invalid_run_generation_infeasible
v1b_rate625_cw3: no_support
```

Replication target:

```text
a06_a19_coding_channel_recovery_v0
```

Why this is first:

- It is the cleanest information-theory-facing support package.
- It connects to a specification-fixed exact accounting anchor:
  \(a(E)=|E|-\operatorname{rank}(H_E)\) and \(L_E=a(E)\log 2\).
- The Lean module `Survival.LinearCodeErasureAccountingToy` now fixes only the
  exact accounting skeleton, while keeping empirical proxy support separate.

Replication discipline:

- Do not treat final rank, final ambiguity, exact failure probability, or
  Monte Carlo failure estimates as model features.
- Keep the empirical coordinate as the frozen low-order dependency pressure,
  not the exact oracle.
- Record v1 invalid-run and v1b no-support as scope constraints, not as
  contradictions of v0.
- Use artifact bundling for large erasure-sample tables.

Recommended next artifact:

```text
05_evidence/a06_a19_coding_channel_recovery/replication_packet_v0_plan.md
```


5. A12 S-t Cut-Spectrum Reliability
-----------------------------------

Current status:

```text
v0: invalid_run_generation_infeasible
v0b_kappa2: support
v0c_kappa3: support
```

Replication target:

```text
a12_st_cut_spectrum_reliability_v0b_kappa2
a12_st_cut_spectrum_reliability_v0c_kappa3
```

Why this is second:

- It is the cleanest graph reliability prediction package.
- It directly addresses the lesson from A31 primary_v0: short-horizon
  disconnection is a cutset / reliability endpoint, not a spanning-tree mass
  endpoint.
- It has two supported surfaces after separating the invalid original surface.

Replication discipline:

- Keep kappa=2 and kappa=3 surfaces separate unless a new feasibility-checked
  joint generator is frozen.
- Preflight generator feasibility before any label-bearing run.
- Do not include exact reliability, future failed-edge state, final
  connectivity, or Monte Carlo reliability estimates as model features.
- Report hazard guardrails prominently if they absorb the cut-spectrum gain.

Recommended next artifact:

```text
05_evidence/a12_st_cut_spectrum_reliability/replication_packet_v0b_v0c_plan.md
```


6. A31 Matched Residual
-----------------------

Current status:

```text
primary_v0: no_support
matched_residual_v1: support
```

Replication target:

```text
a31_graph_spanning_tree_persistence_matched_residual_v1
```

Why this is third:

- It supports a narrower but useful claim: current `log_tau` has residual
  collapse-risk ordering value under matched graph groups.
- It should not be confused with primary_v0, which did not support generic
  near-term disconnection prediction from the spanning-tree bundle.

Replication discipline:

- Preserve the matched-group design.
- Keep primary_v0 no-support visible.
- Do not relabel spanning-tree mass as A12-style cut-spectrum reliability.
- Treat this as global redundancy ordering support, not exact reliability
  superiority.

Recommended next artifact:

```text
05_evidence/a31_graph_spanning_tree_persistence/replication_packet_matched_residual_v1_plan.md
```


7. Artifact Policy
------------------

Future replication packages should follow:

```text
04_operations/55_artifact_storage_policy.md
```

Default handling:

- keep manifests, summaries, governance files, scripts, checksums, and small
  diagnostics in Git;
- bundle large row-level artifacts such as erasure samples and future-path
  samples;
- record bundle SHA256, size, file list, commands, script hashes, and row
  counts;
- keep failed / invalid summaries as ordinary tracked files.


8. Non-Claims
-------------

This plan does not claim:

- new support for A06/A19, A12, or A31;
- outside reproduction has already happened for these non-CSP packages;
- A06-stop has been rescued;
- no-support rows are superseded;
- exact accounting anchors are prediction support.


9. Current Packet Status And Next Step
--------------------------------------

First-round internal rerun packet plans now cover:

```text
05_evidence/a06_a19_coding_channel_recovery/replication_packet_v0_plan.md
05_evidence/a12_st_cut_spectrum_reliability/replication_packet_v0b_v0c_plan.md
05_evidence/a31_graph_spanning_tree_persistence/replication_packet_matched_residual_v1_plan.md
```

The next concrete step is to choose one package for an actual local clean
rerun or outside-rerun handoff. The recommended order remains A06/A19 first,
then A12, then A31, because A06/A19 is the strongest information-theory-facing
non-CSP support package and already has a Lean exact-accounting anchor.
