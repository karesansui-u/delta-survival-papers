A12 S-t Cut-Spectrum Reliability Harness
========================================

This directory contains a smoke harness for the
`st_cut_spectrum_reliability` domain.

The harness is not validation evidence unless a later freeze manifest pins the
exact script hashes, command, seeds, and output directory before execution.

Smoke purpose:

- generate finite \(s\)-\(t\) reliability rows under independent edge failures;
- compute exact low-order minimal cutset counts for small graphs;
- audit labels against generated failure samples;
- evaluate whether the pipeline can compare a natural graph baseline against a
  frozen scalar cut-spectrum SP coordinate.
- write q-by-split prevalence diagnostics and attribution ablations for the
  scalar and term-vector parts of the cut-spectrum coordinate.

Freeze-prep discipline:

- support-bearing runs must pin script hashes, command lines, seeds, output
  directory, graph family, q-grid, cutset enumeration cap, and support rule
  before generating outcome labels;
- the current generator uses a two-cluster synthetic graph family, so any
  support claim on that surface must be bounded to that finite family unless a
  separate family-stratified package is frozen;
- A12-v0 uses scalar log-pressure as the primary coordinate. Term-vector and
  bundle variants are diagnostics, not support-bearing primaries;
- `B1_hazard` and `B1_hazard_SP_scalar` are guardrails for checking whether a
  scalar result is only a nonlinear \(q,\kappa\) hazard transform;
- A12-v0 is restricted to `kappa=2,3`. The baseline excludes
  `st_bridge_count` so first-order \(s\)-\(t\) cutset information does not leak
  into B1 if a later successor package explores `kappa=1`;
- if a frozen primary run fails, it must be recorded as no-support. A later
  attempt is allowed only as a new successor package with a separately frozen
  surface, not by reusing the failed outcome-bearing rows as support.

The intended claim boundary is:

- A31 remains the spanning-tree exact accounting anchor;
- A12 is the separate cutset / reliability prediction candidate.

Governance note:

- older raw `evaluation_summary.json` files may retain the legacy harness status
  name `smoke_evaluated_not_evidence`;
- support-bearing decisions are determined by the frozen manifest, the result
  summary, `frozen_packages.tsv`, and, where present, `governance_summary.json`;
- future successor packages may introduce a separately hashed evaluator with
  explicit primary status fields, but existing frozen script hashes are left
  unchanged.

Replication packet:

- `replication_packet_v0b_v0c_plan.md` defines the rerun-ready packet plan for
  the supported kappa=2 and kappa=3 surfaces, including hash-drift handling for
  the evolved generator.
