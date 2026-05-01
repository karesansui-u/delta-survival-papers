A06/A19 Coding-Channel Recovery Harness
=======================================

Status: smoke tooling only; not frozen; not validation evidence.

This directory contains a finite BEC / binary-linear-code harness for the
`coding_channel_recovery` domain.

The harness separates:

- exact rank accounting for erased columns;
- oracle-free prediction using a pre-fixed low-order dependency-pressure
  coordinate.

Smoke purpose:

- generate finite binary parity-check matrices;
- compute exact low-order dependent-column counts;
- sample BEC erasure sets and label unique-recovery failure;
- audit the identity \(a(E)=|E|-\operatorname{rank}(H_E)\);
- compare a natural coding baseline against a scalar SP dependency coordinate.

The raw smoke output is not evidence. A support-bearing run must be pinned by a
separate freeze manifest before outcome-bearing execution.

Smoke v0:

- run directory: `smoke_v0/`
- result summary: `smoke_result_summary.md`
- decision: smoke support rule would pass, but this is not validation evidence
  because the run was not frozen before execution

Primary v0:

- manifest: `freeze_manifest_v0.md`
- run directory: `primary_v0/`
- result summary: `primary_v0_result_summary.md`
- governance summary: `primary_v0/governance_summary.json`
- decision: support
