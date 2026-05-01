A06/A19 Primary v1 Rate-0.625 CW4 Invalid-Run Summary
=====================================================

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v1_rate625_cw4

manifest: 05_evidence/a06_a19_coding_channel_recovery/freeze_manifest_v1_rate625_cw4.md

date: 2026-05-01 JST

decision: invalid_run_generation_infeasible


1. Scope
--------

This package attempted an independently seeded successor surface after the
supported A06/A19 primary_v0 package:

- \(n\in\{32,40\}\);
- rate \(0.625\);
- column weight \(4\);
- \(q\in\{0.16,0.22,0.28,0.34\}\);
- 120 codes per cell;
- 256 independent erasure samples per code / \(q\) row.


2. Failure Point
----------------

The generator failed before any outcome-bearing erasure labels were produced:

```text
RuntimeError: could not generate full-rank H for n=32, r=12
```

No `codes.csv`, labels, sample rows, or evaluation metrics were produced.


3. Cause
--------

The frozen generator uses a fixed exact column weight. When that column weight
is even, every parity-check column has even parity. Therefore all columns lie in
the even-parity subspace of \(\mathbb F_2^r\), whose dimension is at most
\(r-1\). A full row-rank \(r\times n\) parity-check matrix cannot be generated
under this exact-even-column-weight constraint.

Thus the failure is a generation-surface infeasibility, not a no-support result
for the dependency-pressure coordinate.


4. Governance
-------------

This run is recorded as invalid-run, not no-support.

Any successor package must be frozen separately before execution. Natural
successors include:

- an odd fixed column weight, such as column weight \(3\) or \(5\);
- a mixed column-weight generator with a separately frozen script and manifest.
